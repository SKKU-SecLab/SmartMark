
pragma solidity >=0.6.12 <0.7.0;
pragma experimental ABIEncoderV2;


struct CollateralOpts {
    bytes32 ilk;
    address gem;
    address join;
    address clip;
    address calc;
    address pip;
    bool    isLiquidatable;
    bool    isOSM;
    bool    whitelistOSM;
    uint256 ilkDebtCeiling;
    uint256 minVaultAmount;
    uint256 maxLiquidationAmount;
    uint256 liquidationPenalty;
    uint256 ilkStabilityFee;
    uint256 startingPriceFactor;
    uint256 breakerTolerance;
    uint256 auctionDuration;
    uint256 permittedDrop;
    uint256 liquidationRatio;
    uint256 kprFlatReward;
    uint256 kprPctReward;
}

/* pragma experimental ABIEncoderV2; */


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

interface ClipLike_4 {

    function vat() external returns (address);

    function dog() external returns (address);

    function spotter() external view returns (address);

    function calc() external view returns (address);

    function ilk() external returns (bytes32);

}

interface JoinLike_2 {

    function vat() external returns (address);

    function ilk() external returns (bytes32);

    function gem() external returns (address);

    function dec() external returns (uint256);

    function join(address, uint) external;

    function exit(address, uint) external;

}

interface OracleLike_3 {

    function src() external view returns (address);

    function lift(address[] calldata) external;

    function drop(address[] calldata) external;

    function setBar(uint256) external;

    function kiss(address) external;

    function diss(address) external;

    function kiss(address[] calldata) external;

    function diss(address[] calldata) external;

    function orb0() external view returns (address);

    function orb1() external view returns (address);

}

interface MomLike {

    function setOsm(bytes32, address) external;

    function setPriceTolerance(address, uint256) external;

}

interface RegistryLike {

    function add(address) external;

    function xlip(bytes32) external view returns (address);

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

interface LerpFactoryLike {

    function newLerp(bytes32 name_, address target_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external returns (address);

    function newIlkLerp(bytes32 name_, address target_, bytes32 ilk_, bytes32 what_, uint256 startTime_, uint256 start_, uint256 end_, uint256 duration_) external returns (address);

}

interface LerpLike {

    function tick() external;

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

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x);
    }
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x);
    }
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require(y == 0 || (z = x * y) / y == x);
    }
    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = add(mul(x, RAY), y / 2) / y;
    }

    function dai()        public view returns (address) { return getChangelogAddress("MCD_DAI"); }

    function mkr()        public view returns (address) { return getChangelogAddress("MCD_GOV"); }

    function vat()        public view returns (address) { return getChangelogAddress("MCD_VAT"); }

    function cat()        public view returns (address) { return getChangelogAddress("MCD_CAT"); }

    function dog()        public view returns (address) { return getChangelogAddress("MCD_DOG"); }

    function jug()        public view returns (address) { return getChangelogAddress("MCD_JUG"); }

    function pot()        public view returns (address) { return getChangelogAddress("MCD_POT"); }

    function vow()        public view returns (address) { return getChangelogAddress("MCD_VOW"); }

    function end()        public view returns (address) { return getChangelogAddress("MCD_END"); }

    function esm()        public view returns (address) { return getChangelogAddress("MCD_ESM"); }

    function reg()        public view returns (address) { return getChangelogAddress("ILK_REGISTRY"); }

    function spotter()    public view returns (address) { return getChangelogAddress("MCD_SPOT"); }

    function flap()       public view returns (address) { return getChangelogAddress("MCD_FLAP"); }

    function flop()       public view returns (address) { return getChangelogAddress("MCD_FLOP"); }

    function osmMom()     public view returns (address) { return getChangelogAddress("OSM_MOM"); }

    function govGuard()   public view returns (address) { return getChangelogAddress("GOV_GUARD"); }

    function flipperMom() public view returns (address) { return getChangelogAddress("FLIPPER_MOM"); }

    function clipperMom() public view returns (address) { return getChangelogAddress("CLIPPER_MOM"); }

    function pauseProxy() public view returns (address) { return getChangelogAddress("MCD_PAUSE_PROXY"); }

    function autoLine()   public view returns (address) { return getChangelogAddress("MCD_IAM_AUTO_LINE"); }

    function daiJoin()    public view returns (address) { return getChangelogAddress("MCD_JOIN_DAI"); }

    function lerpFab()    public view returns (address) { return getChangelogAddress("LERP_FAB"); }


    function clip(bytes32 _ilk) public view returns (address _clip) {

        _clip = RegistryLike(reg()).xlip(_ilk);
    }

    function flip(bytes32 _ilk) public view returns (address _flip) {

        _flip = RegistryLike(reg()).xlip(_ilk);
    }

    function calc(bytes32 _ilk) public view returns (address _calc) {

        _calc = ClipLike_4(clip(_ilk)).calc();
    }

    function getChangelogAddress(bytes32 _key) public view returns (address) {

        return ChainlogLike(LOG).getAddress(_key);
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


    function canCast(uint40 _ts, bool _officeHours) public pure returns (bool) {

        if (_officeHours) {
            uint256 day = (_ts / 1 days + 3) % 7;
            if (day >= 5)                 { return false; }  // Can only be cast on a weekday
            uint256 hour = _ts / 1 hours % 24;
            if (hour < 14 || hour >= 21)  { return false; }  // Outside office hours
        }
        return true;
    }

    function nextCastTime(uint40 _eta, uint40 _ts, bool _officeHours) public pure returns (uint256 castTime) {

        require(_eta != 0);  // "DssExecLib/invalid eta"
        require(_ts  != 0);  // "DssExecLib/invalid ts"
        castTime = _ts > _eta ? _ts : _eta; // Any day at XX:YY

        if (_officeHours) {
            uint256 day    = (castTime / 1 days + 3) % 7;
            uint256 hour   = castTime / 1 hours % 24;
            uint256 minute = castTime / 1 minutes % 60;
            uint256 second = castTime % 60;

            if (day >= 5) {
                castTime += (6 - day) * 1 days;                 // Go to Sunday XX:YY
                castTime += (24 - hour + 14) * 1 hours;         // Go to 14:YY UTC Monday
                castTime -= minute * 1 minutes + second;        // Go to 14:00 UTC
            } else {
                if (hour >= 21) {
                    if (day == 4) castTime += 2 days;           // If Friday, fast forward to Sunday XX:YY
                    castTime += (24 - hour + 14) * 1 hours;     // Go to 14:YY UTC next day
                    castTime -= minute * 1 minutes + second;    // Go to 14:00 UTC
                } else if (hour < 14) {
                    castTime += (14 - hour) * 1 hours;          // Go to 14:YY UTC same day
                    castTime -= minute * 1 minutes + second;    // Go to 14:00 UTC
                }
            }
        }
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
    function setValue(address _base, bytes32 _what, uint256 _amt) public {

        Fileable(_base).file(_what, _amt);
    }
    function setValue(address _base, bytes32 _ilk, bytes32 _what, uint256 _amt) public {

        Fileable(_base).file(_ilk, _what, _amt);
    }

    function setGlobalDebtCeiling(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-global-Line-precision"
        setValue(vat(), "Line", _amount * RAD);
    }
    function increaseGlobalDebtCeiling(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-Line-increase-precision"
        address _vat = vat();
        setValue(_vat, "Line", add(DssVat(_vat).Line(), _amount * RAD));
    }
    function decreaseGlobalDebtCeiling(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-Line-decrease-precision"
        address _vat = vat();
        setValue(_vat, "Line", sub(DssVat(_vat).Line(), _amount * RAD));
    }
    function setDSR(uint256 _rate, bool _doDrip) public {

        require((_rate >= RAY) && (_rate <= RATES_ONE_HUNDRED_PCT));  // "LibDssExec/dsr-out-of-bounds"
        if (_doDrip) Drippable(pot()).drip();
        setValue(pot(), "dsr", _rate);
    }
    function setSurplusAuctionAmount(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-bump-precision"
        setValue(vow(), "bump", _amount * RAD);
    }
    function setSurplusBuffer(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-hump-precision"
        setValue(vow(), "hump", _amount * RAD);
    }
    function setMinSurplusAuctionBidIncrease(uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-flap-beg-precision"
        setValue(flap(), "beg", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
    }
    function setSurplusAuctionBidDuration(uint256 _duration) public {

        setValue(flap(), "ttl", _duration);
    }
    function setSurplusAuctionDuration(uint256 _duration) public {

        setValue(flap(), "tau", _duration);
    }
    function setDebtAuctionDelay(uint256 _duration) public {

        setValue(vow(), "wait", _duration);
    }
    function setDebtAuctionDAIAmount(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-sump-precision"
        setValue(vow(), "sump", _amount * RAD);
    }
    function setDebtAuctionMKRAmount(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-vow-dump-precision"
        setValue(vow(), "dump", _amount * WAD);
    }
    function setMinDebtAuctionBidIncrease(uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-flap-beg-precision"
        setValue(flop(), "beg", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
    }
    function setDebtAuctionBidDuration(uint256 _duration) public {

        setValue(flop(), "ttl", _duration);
    }
    function setDebtAuctionDuration(uint256 _duration) public {

        setValue(flop(), "tau", _duration);
    }
    function setDebtAuctionMKRIncreaseRate(uint256 _pct_bps) public {

        setValue(flop(), "pad", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
    }
    function setMaxTotalDAILiquidationAmount(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-dog-Hole-precision"
        setValue(dog(), "Hole", _amount * RAD);
    }
    function setMaxTotalDAILiquidationAmountLEGACY(uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-cat-box-amount"
        setValue(cat(), "box", _amount * RAD);
    }
    function setEmergencyShutdownProcessingTime(uint256 _duration) public {

        setValue(end(), "wait", _duration);
    }
    function setGlobalStabilityFee(uint256 _rate) public {

        require((_rate >= RAY) && (_rate <= RATES_ONE_HUNDRED_PCT));  // "LibDssExec/global-stability-fee-out-of-bounds"
        setValue(jug(), "base", _rate);
    }
    function setDAIReferenceValue(uint256 _value) public {

        require(_value < WAD);  // "LibDssExec/incorrect-par-precision"
        setValue(spotter(), "par", rdiv(_value, 1000));
    }

    function setIlkDebtCeiling(bytes32 _ilk, uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        setValue(vat(), _ilk, "line", _amount * RAD);
    }
    function increaseIlkDebtCeiling(bytes32 _ilk, uint256 _amount, bool _global) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        address _vat = vat();
        (,,,uint256 line_,) = DssVat(_vat).ilks(_ilk);
        setValue(_vat, _ilk, "line", add(line_, _amount * RAD));
        if (_global) { increaseGlobalDebtCeiling(_amount); }
    }
    function decreaseIlkDebtCeiling(bytes32 _ilk, uint256 _amount, bool _global) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        address _vat = vat();
        (,,,uint256 line_,) = DssVat(_vat).ilks(_ilk);
        setValue(_vat, _ilk, "line", sub(line_, _amount * RAD));
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
        setValue(vat(), _ilk, "dust", _amount * RAD);
        (bool ok,) = clip(_ilk).call(abi.encodeWithSignature("upchost()")); ok;
    }
    function setIlkLiquidationPenalty(bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-ilk-chop-precision"
        setValue(dog(), _ilk, "chop", add(WAD, wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT)));
        (bool ok,) = clip(_ilk).call(abi.encodeWithSignature("upchost()")); ok;
    }
    function setIlkMaxLiquidationAmount(bytes32 _ilk, uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-hole-precision"
        setValue(dog(), _ilk, "hole", _amount * RAD);
    }
    function setIlkLiquidationRatio(bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < 10 * BPS_ONE_HUNDRED_PCT); // "LibDssExec/incorrect-ilk-mat-precision" // Fails if pct >= 1000%
        require(_pct_bps >= BPS_ONE_HUNDRED_PCT); // the liquidation ratio has to be bigger or equal to 100%
        setValue(spotter(), _ilk, "mat", rdiv(_pct_bps, BPS_ONE_HUNDRED_PCT));
    }
    function setStartingPriceMultiplicativeFactor(bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < 10 * BPS_ONE_HUNDRED_PCT); // "LibDssExec/incorrect-ilk-mat-precision" // Fails if gt 10x
        require(_pct_bps >= BPS_ONE_HUNDRED_PCT); // fail if start price is less than OSM price
        setValue(clip(_ilk), "buf", rdiv(_pct_bps, BPS_ONE_HUNDRED_PCT));
    }

    function setAuctionTimeBeforeReset(bytes32 _ilk, uint256 _duration) public {

        setValue(clip(_ilk), "tail", _duration);
    }

    function setAuctionPermittedDrop(bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT); // "LibDssExec/incorrect-clip-cusp-value"
        setValue(clip(_ilk), "cusp", rdiv(_pct_bps, BPS_ONE_HUNDRED_PCT));
    }

    function setKeeperIncentivePercent(bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT); // "LibDssExec/incorrect-clip-chip-precision"
        setValue(clip(_ilk), "chip", wdiv(_pct_bps, BPS_ONE_HUNDRED_PCT));
    }

    function setKeeperIncentiveFlatRate(bytes32 _ilk, uint256 _amount) public {

        require(_amount < WAD); // "LibDssExec/incorrect-clip-tip-precision"
        setValue(clip(_ilk), "tip", _amount * RAD);
    }

    function setLiquidationBreakerPriceTolerance(address _clip, uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT);  // "LibDssExec/incorrect-clippermom-price-tolerance"
        MomLike(clipperMom()).setPriceTolerance(_clip, rdiv(_pct_bps, BPS_ONE_HUNDRED_PCT));
    }

    function setIlkStabilityFee(bytes32 _ilk, uint256 _rate, bool _doDrip) public {

        require((_rate >= RAY) && (_rate <= RATES_ONE_HUNDRED_PCT));  // "LibDssExec/ilk-stability-fee-out-of-bounds"
        address _jug = jug();
        if (_doDrip) Drippable(_jug).drip(_ilk);

        setValue(_jug, _ilk, "duty", _rate);
    }



    function setLinearDecrease(address _calc, uint256 _duration) public {

        setValue(_calc, "tau", _duration);
    }

    function setStairstepExponentialDecrease(address _calc, uint256 _duration, uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT); // DssExecLib/cut-too-high
        setValue(_calc, "cut", rdiv(_pct_bps, BPS_ONE_HUNDRED_PCT));
        setValue(_calc, "step", _duration);
    }
    function setExponentialDecrease(address _calc, uint256 _pct_bps) public {

        require(_pct_bps < BPS_ONE_HUNDRED_PCT); // DssExecLib/cut-too-high
        setValue(_calc, "cut", rdiv(_pct_bps, BPS_ONE_HUNDRED_PCT));
    }

    function whitelistOracleMedians(address _oracle) public {

        (bool ok, bytes memory data) = _oracle.call(abi.encodeWithSignature("orb0()"));
        if (ok) {
            address median0 = abi.decode(data, (address));
            addReaderToMedianWhitelist(median0, _oracle);
            addReaderToMedianWhitelist(OracleLike_3(_oracle).orb1(), _oracle);
        } else {
            addReaderToMedianWhitelist(OracleLike_3(_oracle).src(), _oracle);
        }
    }

    function addWritersToMedianWhitelist(address _median, address[] memory _feeds) public {

        OracleLike_3(_median).lift(_feeds);
    }
    function removeWritersFromMedianWhitelist(address _median, address[] memory _feeds) public {

        OracleLike_3(_median).drop(_feeds);
    }
    function addReadersToMedianWhitelist(address _median, address[] memory _readers) public {

        OracleLike_3(_median).kiss(_readers);
    }
    function addReaderToMedianWhitelist(address _median, address _reader) public {

        OracleLike_3(_median).kiss(_reader);
    }
    function removeReadersFromMedianWhitelist(address _median, address[] memory _readers) public {

        OracleLike_3(_median).diss(_readers);
    }
    function removeReaderFromMedianWhitelist(address _median, address _reader) public {

        OracleLike_3(_median).diss(_reader);
    }
    function setMedianWritersQuorum(address _median, uint256 _minQuorum) public {

        OracleLike_3(_median).setBar(_minQuorum);
    }
    function addReaderToOSMWhitelist(address _osm, address _reader) public {

        OracleLike_3(_osm).kiss(_reader);
    }
    function removeReaderFromOSMWhitelist(address _osm, address _reader) public {

        OracleLike_3(_osm).diss(_reader);
    }
    function allowOSMFreeze(address _osm, bytes32 _ilk) public {

        MomLike(osmMom()).setOsm(_ilk, _osm);
    }



    function addCollateralBase(
        bytes32 _ilk,
        address _gem,
        address _join,
        address _clip,
        address _calc,
        address _pip
    ) public {

        address _vat = vat();
        address _dog = dog();
        address _spotter = spotter();
        require(JoinLike_2(_join).vat() == _vat);     // "join-vat-not-match"
        require(JoinLike_2(_join).ilk() == _ilk);     // "join-ilk-not-match"
        require(JoinLike_2(_join).gem() == _gem);     // "join-gem-not-match"
        require(JoinLike_2(_join).dec() ==
                   ERC20(_gem).decimals());         // "join-dec-not-match"
        require(ClipLike_4(_clip).vat() == _vat);     // "clip-vat-not-match"
        require(ClipLike_4(_clip).dog() == _dog);     // "clip-dog-not-match"
        require(ClipLike_4(_clip).ilk() == _ilk);     // "clip-ilk-not-match"
        require(ClipLike_4(_clip).spotter() == _spotter);  // "clip-ilk-not-match"

        setContract(spotter(), _ilk, "pip", _pip);

        setContract(_dog, _ilk, "clip", _clip);
        setContract(_clip, "vow", vow());
        setContract(_clip, "calc", _calc);

        Initializable(_vat).init(_ilk);  // Vat
        Initializable(jug()).init(_ilk);  // Jug

        authorize(_vat, _join);
        authorize(_vat, _clip);
        authorize(_dog, _clip);
        authorize(_clip, _dog);
        authorize(_clip, end());
        authorize(_clip, esm());

        RegistryLike(reg()).add(_join);
    }

    function addNewCollateral(CollateralOpts memory co) public {

        addCollateralBase(co.ilk, co.gem, co.join, co.clip, co.calc, co.pip);
        address clipperMom_ = clipperMom();

        if (!co.isLiquidatable) {
            setValue(co.clip, "stopped", 3);
        } else {
            authorize(co.clip, clipperMom_);
        }

        if(co.isOSM) { // If pip == OSM
            authorize(co.pip, osmMom());
            if (co.whitelistOSM) { // If median is src in OSM
                whitelistOracleMedians(co.pip);
            }
            addReaderToOSMWhitelist(co.pip, spotter());
            addReaderToOSMWhitelist(co.pip, co.clip);
            addReaderToOSMWhitelist(co.pip, clipperMom_);
            addReaderToOSMWhitelist(co.pip, end());
            allowOSMFreeze(co.pip, co.ilk);
        }
        increaseGlobalDebtCeiling(co.ilkDebtCeiling);
        setIlkDebtCeiling(co.ilk, co.ilkDebtCeiling);
        setIlkMinVaultAmount(co.ilk, co.minVaultAmount);
        setIlkMaxLiquidationAmount(co.ilk, co.maxLiquidationAmount);
        setIlkLiquidationPenalty(co.ilk, co.liquidationPenalty);

        setIlkStabilityFee(co.ilk, co.ilkStabilityFee, true);

        setStartingPriceMultiplicativeFactor(co.ilk, co.startingPriceFactor);

        setAuctionTimeBeforeReset(co.ilk, co.auctionDuration);

        setAuctionPermittedDrop(co.ilk, co.permittedDrop);

        setIlkLiquidationRatio(co.ilk, co.liquidationRatio);

        setLiquidationBreakerPriceTolerance(co.clip, co.breakerTolerance);

        setKeeperIncentiveFlatRate(co.ilk, co.kprFlatReward);

        setKeeperIncentivePercent(co.ilk, co.kprPctReward);

        updateCollateralPrice(co.ilk);
    }

    function sendPaymentFromSurplusBuffer(address _target, uint256 _amount) public {

        require(_amount < WAD);  // "LibDssExec/incorrect-ilk-line-precision"
        DssVat(vat()).suck(vow(), address(this), _amount * RAD);
        JoinLike_2(daiJoin()).exit(_target, _amount * WAD);
    }

    function linearInterpolation(bytes32 _name, address _target, bytes32 _what, uint256 _startTime, uint256 _start, uint256 _end, uint256 _duration) public returns (address) {

        address lerp = LerpFactoryLike(lerpFab()).newLerp(_name, _target, _what, _startTime, _start, _end, _duration);
        Authorizable(_target).rely(lerp);
        LerpLike(lerp).tick();
        return lerp;
    }
    function linearInterpolation(bytes32 _name, address _target, bytes32 _ilk, bytes32 _what, uint256 _startTime, uint256 _start, uint256 _end, uint256 _duration) public returns (address) {

        address lerp = LerpFactoryLike(lerpFab()).newIlkLerp(_name, _target, _ilk, _what, _startTime, _start, _end, _duration);
        Authorizable(_target).rely(lerp);
        LerpLike(lerp).tick();
        return lerp;
    }
}