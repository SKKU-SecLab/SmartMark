



pragma solidity ^0.5.16;

contract Owned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {

        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


interface IAddressResolver {

    function getAddress(bytes32 name) external view returns (address);


    function getSynth(bytes32 key) external view returns (address);


    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address);

}


interface ISynth {

    function currencyKey() external view returns (bytes32);


    function transferableSynths(address account) external view returns (uint);


    function transferAndSettle(address to, uint value) external returns (bool);


    function transferFromAndSettle(
        address from,
        address to,
        uint value
    ) external returns (bool);


    function burn(address account, uint amount) external;


    function issue(address account, uint amount) external;

}


interface IIssuer {

    function anySynthOrSNXRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availableSynthCount() external view returns (uint);


    function availableSynths(uint index) external view returns (ISynth);


    function canBurnSynths(address account) external view returns (bool);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function collateralisationRatioAndAnyRatesInvalid(address _issuer)
        external
        view
        returns (uint cratio, bool anyRateIsInvalid);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint debtBalance);


    function issuanceRatio() external view returns (uint);


    function lastIssueEvent(address account) external view returns (uint);


    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);


    function minimumStakeTime() external view returns (uint);


    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function synths(bytes32 currencyKey) external view returns (ISynth);


    function getSynths(bytes32[] calldata currencyKeys) external view returns (ISynth[] memory);


    function synthsByAddress(address synthAddress) external view returns (bytes32);


    function totalIssuedSynths(bytes32 currencyKey, bool excludeOtherCollateral) external view returns (uint);


    function transferableSynthetixAndAnyRateIsInvalid(address account, uint balance)
        external
        view
        returns (uint transferable, bool anyRateIsInvalid);


    function issueSynths(address from, uint amount) external;


    function issueSynthsOnBehalf(
        address issueFor,
        address from,
        uint amount
    ) external;


    function issueMaxSynths(address from) external;


    function issueMaxSynthsOnBehalf(address issueFor, address from) external;


    function burnSynths(address from, uint amount) external;


    function burnSynthsOnBehalf(
        address burnForAddress,
        address from,
        uint amount
    ) external;


    function burnSynthsToTarget(address from) external;


    function burnSynthsToTargetOnBehalf(address burnForAddress, address from) external;


    function burnForRedemption(
        address deprecatedSynthProxy,
        address account,
        uint balance
    ) external;


    function liquidateDelinquentAccount(
        address account,
        uint susdAmount,
        address liquidator
    ) external returns (uint totalRedeemed, uint amountToLiquidate);

}






contract AddressResolver is Owned, IAddressResolver {

    mapping(bytes32 => address) public repository;

    constructor(address _owner) public Owned(_owner) {}


    function importAddresses(bytes32[] calldata names, address[] calldata destinations) external onlyOwner {

        require(names.length == destinations.length, "Input lengths must match");

        for (uint i = 0; i < names.length; i++) {
            bytes32 name = names[i];
            address destination = destinations[i];
            repository[name] = destination;
            emit AddressImported(name, destination);
        }
    }


    function rebuildCaches(MixinResolver[] calldata destinations) external {

        for (uint i = 0; i < destinations.length; i++) {
            destinations[i].rebuildCache();
        }
    }


    function areAddressesImported(bytes32[] calldata names, address[] calldata destinations) external view returns (bool) {

        for (uint i = 0; i < names.length; i++) {
            if (repository[names[i]] != destinations[i]) {
                return false;
            }
        }
        return true;
    }

    function getAddress(bytes32 name) external view returns (address) {

        return repository[name];
    }

    function requireAndGetAddress(bytes32 name, string calldata reason) external view returns (address) {

        address _foundAddress = repository[name];
        require(_foundAddress != address(0), reason);
        return _foundAddress;
    }

    function getSynth(bytes32 key) external view returns (address) {

        IIssuer issuer = IIssuer(repository["Issuer"]);
        require(address(issuer) != address(0), "Cannot find Issuer address");
        return address(issuer.synths(key));
    }


    event AddressImported(bytes32 name, address destination);
}




contract MixinResolver {

    AddressResolver public resolver;

    mapping(bytes32 => address) private addressCache;

    constructor(address _resolver) internal {
        resolver = AddressResolver(_resolver);
    }


    function combineArrays(bytes32[] memory first, bytes32[] memory second)
        internal
        pure
        returns (bytes32[] memory combination)
    {

        combination = new bytes32[](first.length + second.length);

        for (uint i = 0; i < first.length; i++) {
            combination[i] = first[i];
        }

        for (uint j = 0; j < second.length; j++) {
            combination[first.length + j] = second[j];
        }
    }


    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {}


    function rebuildCache() public {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            address destination =
                resolver.requireAndGetAddress(name, string(abi.encodePacked("Resolver missing target: ", name)));
            addressCache[name] = destination;
            emit CacheUpdated(name, destination);
        }
    }


    function isResolverCached() external view returns (bool) {

        bytes32[] memory requiredAddresses = resolverAddressesRequired();
        for (uint i = 0; i < requiredAddresses.length; i++) {
            bytes32 name = requiredAddresses[i];
            if (resolver.getAddress(name) != addressCache[name] || addressCache[name] == address(0)) {
                return false;
            }
        }

        return true;
    }


    function requireAndGetAddress(bytes32 name) internal view returns (address) {

        address _foundAddress = addressCache[name];
        require(_foundAddress != address(0), string(abi.encodePacked("Missing address: ", name)));
        return _foundAddress;
    }


    event CacheUpdated(bytes32 name, address destination);
}


interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint);


    function balanceOf(address owner) external view returns (uint);


    function allowance(address owner, address spender) external view returns (uint);


    function transfer(address to, uint value) external returns (bool);


    function approve(address spender, uint value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint value);

    event Approval(address indexed owner, address indexed spender, uint value);
}


interface ISynthRedeemer {

    function redemptions(address synthProxy) external view returns (uint redeemRate);


    function balanceOf(IERC20 synthProxy, address account) external view returns (uint balanceOfInsUSD);


    function totalSupply(IERC20 synthProxy) external view returns (uint totalSupplyInsUSD);


    function redeem(IERC20 synthProxy) external;


    function redeemAll(IERC20[] calldata synthProxies) external;


    function redeemPartial(IERC20 synthProxy, uint amountOfSynth) external;


    function deprecate(IERC20 synthProxy, uint rateToRedeem) external;

}


library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}




library SafeDecimalMath {

    using SafeMath for uint;

    uint8 public constant decimals = 18;
    uint8 public constant highPrecisionDecimals = 27;

    uint public constant UNIT = 10**uint(decimals);

    uint public constant PRECISE_UNIT = 10**uint(highPrecisionDecimals);
    uint private constant UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR = 10**uint(highPrecisionDecimals - decimals);

    function unit() external pure returns (uint) {

        return UNIT;
    }

    function preciseUnit() external pure returns (uint) {

        return PRECISE_UNIT;
    }

    function multiplyDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(y) / UNIT;
    }

    function _multiplyDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint quotientTimesTen = x.mul(y) / (precisionUnit / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function multiplyDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, PRECISE_UNIT);
    }

    function multiplyDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _multiplyDecimalRound(x, y, UNIT);
    }

    function divideDecimal(uint x, uint y) internal pure returns (uint) {

        return x.mul(UNIT).div(y);
    }

    function _divideDecimalRound(
        uint x,
        uint y,
        uint precisionUnit
    ) private pure returns (uint) {

        uint resultTimesTen = x.mul(precisionUnit * 10).div(y);

        if (resultTimesTen % 10 >= 5) {
            resultTimesTen += 10;
        }

        return resultTimesTen / 10;
    }

    function divideDecimalRound(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, UNIT);
    }

    function divideDecimalRoundPrecise(uint x, uint y) internal pure returns (uint) {

        return _divideDecimalRound(x, y, PRECISE_UNIT);
    }

    function decimalToPreciseDecimal(uint i) internal pure returns (uint) {

        return i.mul(UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR);
    }

    function preciseDecimalToDecimal(uint i) internal pure returns (uint) {

        uint quotientTimesTen = i / (UNIT_TO_HIGH_PRECISION_CONVERSION_FACTOR / 10);

        if (quotientTimesTen % 10 >= 5) {
            quotientTimesTen += 10;
        }

        return quotientTimesTen / 10;
    }

    function floorsub(uint a, uint b) internal pure returns (uint) {

        return b >= a ? 0 : a - b;
    }
}








contract SynthRedeemer is ISynthRedeemer, MixinResolver {

    using SafeDecimalMath for uint;

    bytes32 public constant CONTRACT_NAME = "SynthRedeemer";

    mapping(address => uint) public redemptions;

    bytes32 private constant CONTRACT_ISSUER = "Issuer";
    bytes32 private constant CONTRACT_SYNTHSUSD = "SynthsUSD";

    constructor(address _resolver) public MixinResolver(_resolver) {}

    function resolverAddressesRequired() public view returns (bytes32[] memory addresses) {

        addresses = new bytes32[](2);
        addresses[0] = CONTRACT_ISSUER;
        addresses[1] = CONTRACT_SYNTHSUSD;
    }

    function issuer() internal view returns (IIssuer) {

        return IIssuer(requireAndGetAddress(CONTRACT_ISSUER));
    }

    function sUSD() internal view returns (IERC20) {

        return IERC20(requireAndGetAddress(CONTRACT_SYNTHSUSD));
    }

    function totalSupply(IERC20 synthProxy) public view returns (uint supplyInsUSD) {

        supplyInsUSD = synthProxy.totalSupply().multiplyDecimal(redemptions[address(synthProxy)]);
    }

    function balanceOf(IERC20 synthProxy, address account) external view returns (uint balanceInsUSD) {

        balanceInsUSD = synthProxy.balanceOf(account).multiplyDecimal(redemptions[address(synthProxy)]);
    }

    function redeemAll(IERC20[] calldata synthProxies) external {

        for (uint i = 0; i < synthProxies.length; i++) {
            _redeem(synthProxies[i], synthProxies[i].balanceOf(msg.sender));
        }
    }

    function redeem(IERC20 synthProxy) external {

        _redeem(synthProxy, synthProxy.balanceOf(msg.sender));
    }

    function redeemPartial(IERC20 synthProxy, uint amountOfSynth) external {

        require(synthProxy.balanceOf(msg.sender) >= amountOfSynth, "Insufficient balance");
        _redeem(synthProxy, amountOfSynth);
    }

    function _redeem(IERC20 synthProxy, uint amountOfSynth) internal {

        uint rateToRedeem = redemptions[address(synthProxy)];
        require(rateToRedeem > 0, "Synth not redeemable");
        require(amountOfSynth > 0, "No balance of synth to redeem");
        issuer().burnForRedemption(address(synthProxy), msg.sender, amountOfSynth);
        uint amountInsUSD = amountOfSynth.multiplyDecimal(rateToRedeem);
        sUSD().transfer(msg.sender, amountInsUSD);
        emit SynthRedeemed(address(synthProxy), msg.sender, amountOfSynth, amountInsUSD);
    }

    function deprecate(IERC20 synthProxy, uint rateToRedeem) external onlyIssuer {

        address synthProxyAddress = address(synthProxy);
        require(redemptions[synthProxyAddress] == 0, "Synth is already deprecated");
        require(rateToRedeem > 0, "No rate for synth to redeem");
        uint totalSynthSupply = synthProxy.totalSupply();
        uint supplyInsUSD = totalSynthSupply.multiplyDecimal(rateToRedeem);
        require(sUSD().balanceOf(address(this)) >= supplyInsUSD, "sUSD must first be supplied");
        redemptions[synthProxyAddress] = rateToRedeem;
        emit SynthDeprecated(address(synthProxy), rateToRedeem, totalSynthSupply, supplyInsUSD);
    }

    function requireOnlyIssuer() internal view {

        require(msg.sender == address(issuer()), "Restricted to Issuer contract");
    }

    modifier onlyIssuer() {

        requireOnlyIssuer();
        _;
    }

    event SynthRedeemed(address synth, address account, uint amountOfSynth, uint amountInsUSD);
    event SynthDeprecated(address synth, uint rateToRedeem, uint totalSynthSupply, uint supplyInsUSD);
}