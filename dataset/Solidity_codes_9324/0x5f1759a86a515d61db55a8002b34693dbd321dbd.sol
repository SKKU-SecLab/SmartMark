
pragma solidity >0.4.13 >=0.4.23 >=0.5.10 >=0.5.12 >=0.6.0 <0.7.0 >=0.6.7 <0.7.0;


library MathLib {


    uint256 constant public WAD      = 10 ** 18;
    uint256 constant public RAY      = 10 ** 27;
    uint256 constant public RAD      = 10 ** 45;
    uint256 constant public THOUSAND = 10 ** 3;
    uint256 constant public MILLION  = 10 ** 6;

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

interface JoinLike {

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

    function ilkData(bytes32) external returns (
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

    function setAddress(bytes32, address) external;

    function removeAddress(bytes32) external;

}


contract DssExecLib {


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

        setGlobalDebtCeiling(_vat, MathLib.add(DssVat(_vat).Line() / MathLib.RAD, _amount));
    }
    function decreaseGlobalDebtCeiling(address _vat, uint256 _amount) public {

        setGlobalDebtCeiling(_vat, MathLib.sub(DssVat(_vat).Line() / MathLib.RAD, _amount));
    }
    function setDSR(address _pot, uint256 _rate) public {

        require((_rate >= MathLib.RAY) && (_rate < 2 * MathLib.RAY));  // "LibDssExec/dsr-out-of-bounds"
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

        require(_pct_bps < 10 * MathLib.THOUSAND);  // "LibDssExec/incorrect-flap-beg-precision"
        Fileable(_flap).file("beg", MathLib.wdiv(_pct_bps, 10 * MathLib.THOUSAND));
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

        require(_pct_bps < 10 * MathLib.THOUSAND);  // "LibDssExec/incorrect-flap-beg-precision"
        Fileable(_flop).file("beg", MathLib.wdiv(_pct_bps, 10 * MathLib.THOUSAND));
    }
    function setDebtAuctionBidDuration(address _flop, uint256 _duration) public {

        Fileable(_flop).file("ttl", _duration);
    }
    function setDebtAuctionDuration(address _flop, uint256 _duration) public {

        Fileable(_flop).file("tau", _duration);
    }
    function setDebtAuctionMKRIncreaseRate(address _flop, uint256 _pct_bps) public {

        Fileable(_flop).file("pad", MathLib.wdiv(MathLib.add(_pct_bps, 10 * MathLib.THOUSAND), 10 * MathLib.THOUSAND));
    }
    function setMaxTotalDAILiquidationAmount(address _cat, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-vow-dump-precision"
        Fileable(_cat).file("box", _amount * MathLib.RAD);
    }
    function setEmergencyShutdownProcessingTime(address _end, uint256 _duration) public {

        Fileable(_end).file("wait", _duration);
    }
    function setGlobalStabilityFee(address _jug, uint256 _rate) public {

        require((_rate >= MathLib.RAY) && (_rate < 2 * MathLib.RAY));  // "LibDssExec/global-stability-fee-out-of-bounds"
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

        (,,,uint256 line_,) = DssVat(_vat).ilks(_ilk);
        setIlkDebtCeiling(_vat, _ilk, MathLib.add(line_ / MathLib.RAD, _amount));
        if (_global) { increaseGlobalDebtCeiling(_vat, _amount); }
    }
    function decreaseIlkDebtCeiling(address _vat, bytes32 _ilk, uint256 _amount, bool _global) public {

        (,,,uint256 line_,) = DssVat(_vat).ilks(_ilk);
        setIlkDebtCeiling(_vat, _ilk, MathLib.sub(line_ / MathLib.RAD, _amount));
        if (_global) { decreaseGlobalDebtCeiling(_vat, _amount); }
    }
    function setIlkMinVaultAmount(address _vat, bytes32 _ilk, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-ilk-dust-precision"
        Fileable(_vat).file(_ilk, "dust", _amount * MathLib.RAD);
    }
    function setIlkLiquidationPenalty(address _cat, bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < 10 * MathLib.THOUSAND);  // "LibDssExec/incorrect-ilk-chop-precision"
        Fileable(_cat).file(_ilk, "chop", MathLib.wdiv(MathLib.add(_pct_bps, 10 * MathLib.THOUSAND), 10 * MathLib.THOUSAND));
    }
    function setIlkMaxLiquidationAmount(address _cat, bytes32 _ilk, uint256 _amount) public {

        require(_amount < MathLib.WAD);  // "LibDssExec/incorrect-ilk-dunk-precision"
        Fileable(_cat).file(_ilk, "dunk", _amount * MathLib.RAD);
    }
    function setIlkLiquidationRatio(address _spot, bytes32 _ilk, uint256 _pct_bps) public {

        require(_pct_bps < 100 * MathLib.THOUSAND);  // "LibDssExec/incorrect-ilk-mat-precision" // Fails if pct >= 1000%
        Fileable(_spot).file(_ilk, "mat", MathLib.rdiv(_pct_bps, 10 * MathLib.THOUSAND));
    }
    function setIlkMinAuctionBidIncrease(address _flip, uint256 _pct_bps) public {

        require(_pct_bps < 10 * MathLib.THOUSAND);  // "LibDssExec/incorrect-ilk-chop-precision"
        Fileable(_flip).file("beg", MathLib.wdiv(_pct_bps, 10 * MathLib.THOUSAND));
    }
    function setIlkBidDuration(address _flip, uint256 _duration) public {

        Fileable(_flip).file("ttl", _duration);
    }
    function setIlkAuctionDuration(address _flip, uint256 _duration) public {

        Fileable(_flip).file("tau", _duration);
    }
    function setIlkStabilityFee(address _jug, bytes32 _ilk, uint256 _rate, bool _doDrip) public {

        require((_rate >= MathLib.RAY) && (_rate < 2 * MathLib.RAY));  // "LibDssExec/ilk-stability-fee-out-of-bounds"
        if (_doDrip) Drippable(_jug).drip(_ilk);

        Fileable(_jug).file(_ilk, "duty", _rate);
    }

    function updateCollateralAuctionContract(
        address _vat,
        address _cat,
        address _end,
        address _flipperMom,
        bytes32 _ilk,
        address _newFlip,
        address _oldFlip
    ) public {

        setContract(_cat, _ilk, "flip", _newFlip);

        authorize(_newFlip, _cat);
        authorize(_newFlip, _end);
        authorize(_newFlip, _flipperMom);

        deauthorize(_oldFlip, _cat);
        deauthorize(_oldFlip, _end);
        deauthorize(_oldFlip, _flipperMom);

        Fileable(_newFlip).file("beg", AuctionLike(_oldFlip).beg());
        Fileable(_newFlip).file("ttl", AuctionLike(_oldFlip).ttl());
        Fileable(_newFlip).file("tau", AuctionLike(_oldFlip).tau());

        require(AuctionLike(_newFlip).ilk() == _ilk);  // "non-matching-ilk"
        require(AuctionLike(_newFlip).vat() == _vat);  // "non-matching-vat"
    }
    function updateSurplusAuctionContract(address _vat, address _vow, address _newFlap, address _oldFlap) public {


        setContract(_vow, "flapper", _newFlap);

        authorize(_newFlap, _vow);

        deauthorize(_oldFlap, _vow);

        Fileable(_newFlap).file("beg", AuctionLike(_oldFlap).beg());
        Fileable(_newFlap).file("ttl", AuctionLike(_oldFlap).ttl());
        Fileable(_newFlap).file("tau", AuctionLike(_oldFlap).tau());

        require(AuctionLike(_newFlap).gem() == AuctionLike(_oldFlap).gem());  // "non-matching-gem"
        require(AuctionLike(_newFlap).vat() == _vat);  // "non-matching-vat"
    }
    function updateDebtAuctionContract(address _vat, address _vow, address _mkrAuthority, address _newFlop, address _oldFlop) public {

        setContract(_vow, "flopper", _newFlop);

        authorize(_newFlop, _vow);
        authorize(_vat, _newFlop);
        authorize(_mkrAuthority, _newFlop);

        deauthorize(_oldFlop, _vow);
        deauthorize(_vat, _oldFlop);
        deauthorize(_mkrAuthority, _oldFlop);

        Fileable(_newFlop).file("beg", AuctionLike(_oldFlop).beg());
        Fileable(_newFlop).file("pad", AuctionLike(_oldFlop).pad());
        Fileable(_newFlop).file("ttl", AuctionLike(_oldFlop).ttl());
        Fileable(_newFlop).file("tau", AuctionLike(_oldFlop).tau());

        require(AuctionLike(_newFlop).gem() == AuctionLike(_oldFlop).gem()); // "non-matching-gem"
        require(AuctionLike(_newFlop).vat() == _vat);  // "non-matching-vat"
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


    function addNewCollateral(
        bytes32          _ilk,
        address[] memory _addresses,
        bool             _liquidatable,
        bool[] memory    _oracleSettings,
        uint256          _ilkDebtCeiling,
        uint256          _minVaultAmount,
        uint256          _maxLiquidationAmount,
        uint256          _liquidationPenalty,
        uint256          _ilkStabilityFee,
        uint256          _bidIncrease,
        uint256          _bidDuration,
        uint256          _auctionDuration,
        uint256          _liquidationRatio
    ) public {

        require(JoinLike(_addresses[1]).vat() == _addresses[4]);    // "join-vat-not-match"
        require(JoinLike(_addresses[1]).ilk() == _ilk);             // "join-ilk-not-match"
        require(JoinLike(_addresses[1]).gem() == _addresses[0]);    // "join-gem-not-match"
        require(JoinLike(_addresses[1]).dec() == 18);               // "join-dec-not-match"
        require(AuctionLike(_addresses[2]).vat() == _addresses[4]); // "flip-vat-not-match"
        require(AuctionLike(_addresses[2]).cat() == _addresses[5]); // "flip-cat-not-match"
        require(AuctionLike(_addresses[2]).ilk() == _ilk);          // "flip-ilk-not-match"

        setContract(_addresses[8], _ilk, "pip", _addresses[3]);

        setContract(_addresses[5], _ilk, "flip", _addresses[2]);

        Initializable(_addresses[4]).init(_ilk);
        Initializable(_addresses[6]).init(_ilk);

        authorize(_addresses[4], _addresses[1]);
        authorize(_addresses[5], _addresses[2]);
        authorize(_addresses[2], _addresses[5]);
        authorize(_addresses[2], _addresses[7]);
        authorize(_addresses[2], _addresses[10]);
        if(!_liquidatable) deauthorize(_addresses[10], _addresses[2]);

        if(_oracleSettings[0]) {
            authorize(_addresses[3], _addresses[11]);
            if (_oracleSettings[1]) {
                addReaderToMedianWhitelist(address(OracleLike(_addresses[3]).src()), _addresses[3]);
            }
            addReaderToOSMWhitelist(_addresses[3], _addresses[8]);
            addReaderToOSMWhitelist(_addresses[3], _addresses[7]);
            allowOSMFreeze(_addresses[11], _addresses[3], _ilk);
        }

        RegistryLike(_addresses[9]).add(_addresses[1]);

        increaseGlobalDebtCeiling(_addresses[4], _ilkDebtCeiling);
        setIlkDebtCeiling(_addresses[4], _ilk, _ilkDebtCeiling);
        setIlkMinVaultAmount(_addresses[4], _ilk, _minVaultAmount);
        setIlkMaxLiquidationAmount(_addresses[5], _ilk, _maxLiquidationAmount);
        setIlkLiquidationPenalty(_addresses[5], _ilk, _liquidationPenalty);
        setIlkStabilityFee(_addresses[6], _ilk, _ilkStabilityFee, true);
        setIlkMinAuctionBidIncrease(_addresses[2], _bidIncrease);
        setIlkBidDuration(_addresses[2], _bidDuration);
        setIlkAuctionDuration(_addresses[2], _auctionDuration);
        setIlkLiquidationRatio(_addresses[8], _ilk, _liquidationRatio);

        updateCollateralPrice(_addresses[8], _ilk);
    }
}