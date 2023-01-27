


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


contract BaseMigration is Owned {

    address public deployer;

    constructor(address _owner) internal Owned(_owner) {
        deployer = msg.sender;
    }

    function returnOwnership(address forContract) external {

        bytes memory payload = abi.encodeWithSignature("nominateNewOwner(address)", owner);

        (bool success, ) = forContract.call(payload);

        if (!success) {
            bytes memory legacyPayload = abi.encodeWithSignature("nominateOwner(address)", owner);

            (bool legacySuccess, ) = forContract.call(legacyPayload);

            require(legacySuccess, "Legacy nomination failed");
        }
    }

    function _requireDeployer() private view {

        require(msg.sender == deployer, "Only the deployer can invoke this");
    }

    modifier onlyDeployer() {

        _requireDeployer();
        _;
    }
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


    function totalIssuedSynths(bytes32 currencyKey, bool excludeEtherCollateral) external view returns (uint);


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


    function liquidateDelinquentAccount(
        address account,
        uint susdAmount,
        address liquidator
    ) external returns (uint totalRedeemed, uint amountToLiquidate);

}



contract ReadProxy is Owned {

    address public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(address _target) external onlyOwner {

        target = _target;
        emit TargetUpdated(target);
    }

    function() external {
        assembly {
            calldatacopy(0, 0, calldatasize)

            let result := staticcall(gas, sload(target_slot), 0, calldatasize, 0, 0)
            returndatacopy(0, 0, returndatasize)

            if iszero(result) {
                revert(0, returndatasize)
            }
            return(0, returndatasize)
        }
    }

    event TargetUpdated(address newTarget);
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






contract Proxyable is Owned {


    Proxy public proxy;
    Proxy public integrationProxy;

    address public messageSender;

    constructor(address payable _proxy) internal {
        require(owner != address(0), "Owner must be set");

        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setProxy(address payable _proxy) external onlyOwner {

        proxy = Proxy(_proxy);
        emit ProxyUpdated(_proxy);
    }

    function setIntegrationProxy(address payable _integrationProxy) external onlyOwner {

        integrationProxy = Proxy(_integrationProxy);
    }

    function setMessageSender(address sender) external onlyProxy {

        messageSender = sender;
    }

    modifier onlyProxy {

        _onlyProxy();
        _;
    }

    function _onlyProxy() private view {

        require(Proxy(msg.sender) == proxy || Proxy(msg.sender) == integrationProxy, "Only the proxy can call");
    }

    modifier optionalProxy {

        _optionalProxy();
        _;
    }

    function _optionalProxy() private {

        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
    }

    modifier optionalProxy_onlyOwner {

        _optionalProxy_onlyOwner();
        _;
    }

    function _optionalProxy_onlyOwner() private {

        if (Proxy(msg.sender) != proxy && Proxy(msg.sender) != integrationProxy && messageSender != msg.sender) {
            messageSender = msg.sender;
        }
        require(messageSender == owner, "Owner only function");
    }

    event ProxyUpdated(address proxyAddress);
}






contract Proxy is Owned {

    Proxyable public target;

    constructor(address _owner) public Owned(_owner) {}

    function setTarget(Proxyable _target) external onlyOwner {

        target = _target;
        emit TargetUpdated(_target);
    }

    function _emit(
        bytes calldata callData,
        uint numTopics,
        bytes32 topic1,
        bytes32 topic2,
        bytes32 topic3,
        bytes32 topic4
    ) external onlyTarget {

        uint size = callData.length;
        bytes memory _callData = callData;

        assembly {
            switch numTopics
                case 0 {
                    log0(add(_callData, 32), size)
                }
                case 1 {
                    log1(add(_callData, 32), size, topic1)
                }
                case 2 {
                    log2(add(_callData, 32), size, topic1, topic2)
                }
                case 3 {
                    log3(add(_callData, 32), size, topic1, topic2, topic3)
                }
                case 4 {
                    log4(add(_callData, 32), size, topic1, topic2, topic3, topic4)
                }
        }
    }

    function() external payable {
        target.setMessageSender(msg.sender);

        assembly {
            let free_ptr := mload(0x40)
            calldatacopy(free_ptr, 0, calldatasize)

            let result := call(gas, sload(target_slot), callvalue, free_ptr, calldatasize, 0, 0)
            returndatacopy(free_ptr, 0, returndatasize)

            if iszero(result) {
                revert(free_ptr, returndatasize)
            }
            return(free_ptr, returndatasize)
        }
    }

    modifier onlyTarget {

        require(Proxyable(msg.sender) == target, "Must be proxy target");
        _;
    }

    event TargetUpdated(Proxyable newTarget);
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




contract ProxyERC20 is Proxy, IERC20 {

    constructor(address _owner) public Proxy(_owner) {}


    function name() public view returns (string memory) {

        return IERC20(address(target)).name();
    }

    function symbol() public view returns (string memory) {

        return IERC20(address(target)).symbol();
    }

    function decimals() public view returns (uint8) {

        return IERC20(address(target)).decimals();
    }


    function totalSupply() public view returns (uint256) {

        return IERC20(address(target)).totalSupply();
    }

    function balanceOf(address account) public view returns (uint256) {

        return IERC20(address(target)).balanceOf(account);
    }

    function allowance(address owner, address spender) public view returns (uint256) {

        return IERC20(address(target)).allowance(owner, spender);
    }

    function transfer(address to, uint256 value) public returns (bool) {

        target.setMessageSender(msg.sender);

        IERC20(address(target)).transfer(to, value);

        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        target.setMessageSender(msg.sender);

        IERC20(address(target)).approve(spender, value);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {

        target.setMessageSender(msg.sender);

        IERC20(address(target)).transferFrom(from, to, value);

        return true;
    }
}




contract State is Owned {

    address public associatedContract;

    constructor(address _associatedContract) internal {
        require(owner != address(0), "Owner must be set");

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    function setAssociatedContract(address _associatedContract) external onlyOwner {

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    modifier onlyAssociatedContract {

        require(msg.sender == associatedContract, "Only the associated contract can perform this action");
        _;
    }


    event AssociatedContractUpdated(address associatedContract);
}


interface IExchangeState {

    struct ExchangeEntry {
        bytes32 src;
        uint amount;
        bytes32 dest;
        uint amountReceived;
        uint exchangeFeeRate;
        uint timestamp;
        uint roundIdForSrc;
        uint roundIdForDest;
    }

    function getLengthOfEntries(address account, bytes32 currencyKey) external view returns (uint);


    function getEntryAt(
        address account,
        bytes32 currencyKey,
        uint index
    )
        external
        view
        returns (
            bytes32 src,
            uint amount,
            bytes32 dest,
            uint amountReceived,
            uint exchangeFeeRate,
            uint timestamp,
            uint roundIdForSrc,
            uint roundIdForDest
        );


    function getMaxTimestamp(address account, bytes32 currencyKey) external view returns (uint);


    function appendExchangeEntry(
        address account,
        bytes32 src,
        uint amount,
        bytes32 dest,
        uint amountReceived,
        uint exchangeFeeRate,
        uint timestamp,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external;


    function removeEntries(address account, bytes32 currencyKey) external;

}




contract ExchangeState is Owned, State, IExchangeState {

    mapping(address => mapping(bytes32 => IExchangeState.ExchangeEntry[])) public exchanges;

    uint public maxEntriesInQueue = 12;

    constructor(address _owner, address _associatedContract) public Owned(_owner) State(_associatedContract) {}


    function setMaxEntriesInQueue(uint _maxEntriesInQueue) external onlyOwner {

        maxEntriesInQueue = _maxEntriesInQueue;
    }


    function appendExchangeEntry(
        address account,
        bytes32 src,
        uint amount,
        bytes32 dest,
        uint amountReceived,
        uint exchangeFeeRate,
        uint timestamp,
        uint roundIdForSrc,
        uint roundIdForDest
    ) external onlyAssociatedContract {

        require(exchanges[account][dest].length < maxEntriesInQueue, "Max queue length reached");

        exchanges[account][dest].push(
            ExchangeEntry({
                src: src,
                amount: amount,
                dest: dest,
                amountReceived: amountReceived,
                exchangeFeeRate: exchangeFeeRate,
                timestamp: timestamp,
                roundIdForSrc: roundIdForSrc,
                roundIdForDest: roundIdForDest
            })
        );
    }

    function removeEntries(address account, bytes32 currencyKey) external onlyAssociatedContract {

        delete exchanges[account][currencyKey];
    }


    function getLengthOfEntries(address account, bytes32 currencyKey) external view returns (uint) {

        return exchanges[account][currencyKey].length;
    }

    function getEntryAt(
        address account,
        bytes32 currencyKey,
        uint index
    )
        external
        view
        returns (
            bytes32 src,
            uint amount,
            bytes32 dest,
            uint amountReceived,
            uint exchangeFeeRate,
            uint timestamp,
            uint roundIdForSrc,
            uint roundIdForDest
        )
    {

        ExchangeEntry storage entry = exchanges[account][currencyKey][index];
        return (
            entry.src,
            entry.amount,
            entry.dest,
            entry.amountReceived,
            entry.exchangeFeeRate,
            entry.timestamp,
            entry.roundIdForSrc,
            entry.roundIdForDest
        );
    }

    function getMaxTimestamp(address account, bytes32 currencyKey) external view returns (uint) {

        ExchangeEntry[] storage userEntries = exchanges[account][currencyKey];
        uint timestamp = 0;
        for (uint i = 0; i < userEntries.length; i++) {
            if (userEntries[i].timestamp > timestamp) {
                timestamp = userEntries[i].timestamp;
            }
        }
        return timestamp;
    }
}


interface ISystemStatus {

    struct Status {
        bool canSuspend;
        bool canResume;
    }

    struct Suspension {
        bool suspended;
        uint248 reason;
    }

    function accessControl(bytes32 section, address account) external view returns (bool canSuspend, bool canResume);


    function requireSystemActive() external view;


    function requireIssuanceActive() external view;


    function requireExchangeActive() external view;


    function requireExchangeBetweenSynthsAllowed(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function requireSynthActive(bytes32 currencyKey) external view;


    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view;


    function systemSuspension() external view returns (bool suspended, uint248 reason);


    function issuanceSuspension() external view returns (bool suspended, uint248 reason);


    function exchangeSuspension() external view returns (bool suspended, uint248 reason);


    function synthExchangeSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function synthSuspension(bytes32 currencyKey) external view returns (bool suspended, uint248 reason);


    function getSynthExchangeSuspensions(bytes32[] calldata synths)
        external
        view
        returns (bool[] memory exchangeSuspensions, uint256[] memory reasons);


    function getSynthSuspensions(bytes32[] calldata synths)
        external
        view
        returns (bool[] memory suspensions, uint256[] memory reasons);


    function suspendSynth(bytes32 currencyKey, uint256 reason) external;


    function updateAccessControl(
        bytes32 section,
        address account,
        bool canSuspend,
        bool canResume
    ) external;

}




contract SystemStatus is Owned, ISystemStatus {

    mapping(bytes32 => mapping(address => Status)) public accessControl;

    uint248 public constant SUSPENSION_REASON_UPGRADE = 1;

    bytes32 public constant SECTION_SYSTEM = "System";
    bytes32 public constant SECTION_ISSUANCE = "Issuance";
    bytes32 public constant SECTION_EXCHANGE = "Exchange";
    bytes32 public constant SECTION_SYNTH_EXCHANGE = "SynthExchange";
    bytes32 public constant SECTION_SYNTH = "Synth";

    Suspension public systemSuspension;

    Suspension public issuanceSuspension;

    Suspension public exchangeSuspension;

    mapping(bytes32 => Suspension) public synthExchangeSuspension;

    mapping(bytes32 => Suspension) public synthSuspension;

    constructor(address _owner) public Owned(_owner) {}

    function requireSystemActive() external view {

        _internalRequireSystemActive();
    }

    function requireIssuanceActive() external view {

        _internalRequireSystemActive();

        _internalRequireIssuanceActive();
    }

    function requireExchangeActive() external view {

        _internalRequireSystemActive();

        _internalRequireExchangeActive();
    }

    function requireSynthExchangeActive(bytes32 currencyKey) external view {

        _internalRequireSystemActive();
        _internalRequireSynthExchangeActive(currencyKey);
    }

    function requireSynthActive(bytes32 currencyKey) external view {

        _internalRequireSystemActive();
        _internalRequireSynthActive(currencyKey);
    }

    function requireSynthsActive(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view {

        _internalRequireSystemActive();
        _internalRequireSynthActive(sourceCurrencyKey);
        _internalRequireSynthActive(destinationCurrencyKey);
    }

    function requireExchangeBetweenSynthsAllowed(bytes32 sourceCurrencyKey, bytes32 destinationCurrencyKey) external view {

        _internalRequireSystemActive();

        _internalRequireExchangeActive();

        _internalRequireSynthExchangeActive(sourceCurrencyKey);
        _internalRequireSynthExchangeActive(destinationCurrencyKey);

        _internalRequireSynthActive(sourceCurrencyKey);
        _internalRequireSynthActive(destinationCurrencyKey);
    }

    function isSystemUpgrading() external view returns (bool) {

        return systemSuspension.suspended && systemSuspension.reason == SUSPENSION_REASON_UPGRADE;
    }

    function getSynthExchangeSuspensions(bytes32[] calldata synths)
        external
        view
        returns (bool[] memory exchangeSuspensions, uint256[] memory reasons)
    {

        exchangeSuspensions = new bool[](synths.length);
        reasons = new uint256[](synths.length);

        for (uint i = 0; i < synths.length; i++) {
            exchangeSuspensions[i] = synthExchangeSuspension[synths[i]].suspended;
            reasons[i] = synthExchangeSuspension[synths[i]].reason;
        }
    }

    function getSynthSuspensions(bytes32[] calldata synths)
        external
        view
        returns (bool[] memory suspensions, uint256[] memory reasons)
    {

        suspensions = new bool[](synths.length);
        reasons = new uint256[](synths.length);

        for (uint i = 0; i < synths.length; i++) {
            suspensions[i] = synthSuspension[synths[i]].suspended;
            reasons[i] = synthSuspension[synths[i]].reason;
        }
    }

    function updateAccessControl(
        bytes32 section,
        address account,
        bool canSuspend,
        bool canResume
    ) external onlyOwner {

        _internalUpdateAccessControl(section, account, canSuspend, canResume);
    }

    function updateAccessControls(
        bytes32[] calldata sections,
        address[] calldata accounts,
        bool[] calldata canSuspends,
        bool[] calldata canResumes
    ) external onlyOwner {

        require(
            sections.length == accounts.length &&
                accounts.length == canSuspends.length &&
                canSuspends.length == canResumes.length,
            "Input array lengths must match"
        );
        for (uint i = 0; i < sections.length; i++) {
            _internalUpdateAccessControl(sections[i], accounts[i], canSuspends[i], canResumes[i]);
        }
    }

    function suspendSystem(uint256 reason) external {

        _requireAccessToSuspend(SECTION_SYSTEM);
        systemSuspension.suspended = true;
        systemSuspension.reason = uint248(reason);
        emit SystemSuspended(systemSuspension.reason);
    }

    function resumeSystem() external {

        _requireAccessToResume(SECTION_SYSTEM);
        systemSuspension.suspended = false;
        emit SystemResumed(uint256(systemSuspension.reason));
        systemSuspension.reason = 0;
    }

    function suspendIssuance(uint256 reason) external {

        _requireAccessToSuspend(SECTION_ISSUANCE);
        issuanceSuspension.suspended = true;
        issuanceSuspension.reason = uint248(reason);
        emit IssuanceSuspended(reason);
    }

    function resumeIssuance() external {

        _requireAccessToResume(SECTION_ISSUANCE);
        issuanceSuspension.suspended = false;
        emit IssuanceResumed(uint256(issuanceSuspension.reason));
        issuanceSuspension.reason = 0;
    }

    function suspendExchange(uint256 reason) external {

        _requireAccessToSuspend(SECTION_EXCHANGE);
        exchangeSuspension.suspended = true;
        exchangeSuspension.reason = uint248(reason);
        emit ExchangeSuspended(reason);
    }

    function resumeExchange() external {

        _requireAccessToResume(SECTION_EXCHANGE);
        exchangeSuspension.suspended = false;
        emit ExchangeResumed(uint256(exchangeSuspension.reason));
        exchangeSuspension.reason = 0;
    }

    function suspendSynthExchange(bytes32 currencyKey, uint256 reason) external {

        bytes32[] memory currencyKeys = new bytes32[](1);
        currencyKeys[0] = currencyKey;
        _internalSuspendSynthExchange(currencyKeys, reason);
    }

    function suspendSynthsExchange(bytes32[] calldata currencyKeys, uint256 reason) external {

        _internalSuspendSynthExchange(currencyKeys, reason);
    }

    function resumeSynthExchange(bytes32 currencyKey) external {

        bytes32[] memory currencyKeys = new bytes32[](1);
        currencyKeys[0] = currencyKey;
        _internalResumeSynthsExchange(currencyKeys);
    }

    function resumeSynthsExchange(bytes32[] calldata currencyKeys) external {

        _internalResumeSynthsExchange(currencyKeys);
    }

    function suspendSynth(bytes32 currencyKey, uint256 reason) external {

        bytes32[] memory currencyKeys = new bytes32[](1);
        currencyKeys[0] = currencyKey;
        _internalSuspendSynths(currencyKeys, reason);
    }

    function suspendSynths(bytes32[] calldata currencyKeys, uint256 reason) external {

        _internalSuspendSynths(currencyKeys, reason);
    }

    function resumeSynth(bytes32 currencyKey) external {

        bytes32[] memory currencyKeys = new bytes32[](1);
        currencyKeys[0] = currencyKey;
        _internalResumeSynths(currencyKeys);
    }

    function resumeSynths(bytes32[] calldata currencyKeys) external {

        _internalResumeSynths(currencyKeys);
    }


    function _requireAccessToSuspend(bytes32 section) internal view {

        require(accessControl[section][msg.sender].canSuspend, "Restricted to access control list");
    }

    function _requireAccessToResume(bytes32 section) internal view {

        require(accessControl[section][msg.sender].canResume, "Restricted to access control list");
    }

    function _internalRequireSystemActive() internal view {

        require(
            !systemSuspension.suspended,
            systemSuspension.reason == SUSPENSION_REASON_UPGRADE
                ? "Synthetix is suspended, upgrade in progress... please stand by"
                : "Synthetix is suspended. Operation prohibited"
        );
    }

    function _internalRequireIssuanceActive() internal view {

        require(!issuanceSuspension.suspended, "Issuance is suspended. Operation prohibited");
    }

    function _internalRequireExchangeActive() internal view {

        require(!exchangeSuspension.suspended, "Exchange is suspended. Operation prohibited");
    }

    function _internalRequireSynthExchangeActive(bytes32 currencyKey) internal view {

        require(!synthExchangeSuspension[currencyKey].suspended, "Synth exchange suspended. Operation prohibited");
    }

    function _internalRequireSynthActive(bytes32 currencyKey) internal view {

        require(!synthSuspension[currencyKey].suspended, "Synth is suspended. Operation prohibited");
    }

    function _internalSuspendSynths(bytes32[] memory currencyKeys, uint256 reason) internal {

        _requireAccessToSuspend(SECTION_SYNTH);
        for (uint i = 0; i < currencyKeys.length; i++) {
            bytes32 currencyKey = currencyKeys[i];
            synthSuspension[currencyKey].suspended = true;
            synthSuspension[currencyKey].reason = uint248(reason);
            emit SynthSuspended(currencyKey, reason);
        }
    }

    function _internalResumeSynths(bytes32[] memory currencyKeys) internal {

        _requireAccessToResume(SECTION_SYNTH);
        for (uint i = 0; i < currencyKeys.length; i++) {
            bytes32 currencyKey = currencyKeys[i];
            emit SynthResumed(currencyKey, uint256(synthSuspension[currencyKey].reason));
            delete synthSuspension[currencyKey];
        }
    }

    function _internalSuspendSynthExchange(bytes32[] memory currencyKeys, uint256 reason) internal {

        _requireAccessToSuspend(SECTION_SYNTH_EXCHANGE);
        for (uint i = 0; i < currencyKeys.length; i++) {
            bytes32 currencyKey = currencyKeys[i];
            synthExchangeSuspension[currencyKey].suspended = true;
            synthExchangeSuspension[currencyKey].reason = uint248(reason);
            emit SynthExchangeSuspended(currencyKey, reason);
        }
    }

    function _internalResumeSynthsExchange(bytes32[] memory currencyKeys) internal {

        _requireAccessToResume(SECTION_SYNTH_EXCHANGE);
        for (uint i = 0; i < currencyKeys.length; i++) {
            bytes32 currencyKey = currencyKeys[i];
            emit SynthExchangeResumed(currencyKey, uint256(synthExchangeSuspension[currencyKey].reason));
            delete synthExchangeSuspension[currencyKey];
        }
    }

    function _internalUpdateAccessControl(
        bytes32 section,
        address account,
        bool canSuspend,
        bool canResume
    ) internal {

        require(
            section == SECTION_SYSTEM ||
                section == SECTION_ISSUANCE ||
                section == SECTION_EXCHANGE ||
                section == SECTION_SYNTH_EXCHANGE ||
                section == SECTION_SYNTH,
            "Invalid section supplied"
        );
        accessControl[section][account].canSuspend = canSuspend;
        accessControl[section][account].canResume = canResume;
        emit AccessControlUpdated(section, account, canSuspend, canResume);
    }


    event SystemSuspended(uint256 reason);
    event SystemResumed(uint256 reason);

    event IssuanceSuspended(uint256 reason);
    event IssuanceResumed(uint256 reason);

    event ExchangeSuspended(uint256 reason);
    event ExchangeResumed(uint256 reason);

    event SynthExchangeSuspended(bytes32 currencyKey, uint256 reason);
    event SynthExchangeResumed(bytes32 currencyKey, uint256 reason);

    event SynthSuspended(bytes32 currencyKey, uint256 reason);
    event SynthResumed(bytes32 currencyKey, uint256 reason);

    event AccessControlUpdated(bytes32 indexed section, address indexed account, bool canSuspend, bool canResume);
}


contract LegacyOwned {

    address public owner;
    address public nominatedOwner;

    constructor(address _owner) public {
        owner = _owner;
    }

    function nominateOwner(address _owner) external onlyOwner {

        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {

        require(msg.sender == nominatedOwner);
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


contract LegacyTokenState is LegacyOwned {

    address public associatedContract;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    constructor(address _owner, address _associatedContract) public LegacyOwned(_owner) {
        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }


    function setAssociatedContract(address _associatedContract) external onlyOwner {

        associatedContract = _associatedContract;
        emit AssociatedContractUpdated(_associatedContract);
    }

    function setAllowance(
        address tokenOwner,
        address spender,
        uint value
    ) external onlyAssociatedContract {

        allowance[tokenOwner][spender] = value;
    }

    function setBalanceOf(address account, uint value) external onlyAssociatedContract {

        balanceOf[account] = value;
    }


    modifier onlyAssociatedContract {

        require(msg.sender == associatedContract);
        _;
    }


    event AssociatedContractUpdated(address _associatedContract);
}


interface IRewardEscrow {

    function balanceOf(address account) external view returns (uint);


    function numVestingEntries(address account) external view returns (uint);


    function totalEscrowedAccountBalance(address account) external view returns (uint);


    function totalVestedAccountBalance(address account) external view returns (uint);


    function getVestingScheduleEntry(address account, uint index) external view returns (uint[2] memory);


    function getNextVestingIndex(address account) external view returns (uint);


    function appendVestingEntry(address account, uint quantity) external;


    function vest() external;

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


interface IFeePool {


    function FEE_ADDRESS() external view returns (address);


    function feesAvailable(address account) external view returns (uint, uint);


    function feePeriodDuration() external view returns (uint);


    function isFeesClaimable(address account) external view returns (bool);


    function targetThreshold() external view returns (uint);


    function totalFeesAvailable() external view returns (uint);


    function totalRewardsAvailable() external view returns (uint);


    function claimFees() external returns (bool);


    function claimOnBehalf(address claimingForAddress) external returns (bool);


    function closeCurrentFeePeriod() external;


    function appendAccountIssuanceRecord(
        address account,
        uint lockedAmount,
        uint debtEntryIndex
    ) external;


    function recordFeePaid(uint sUSDAmount) external;


    function setRewardsToDistribute(uint amount) external;

}


interface IVirtualSynth {

    function balanceOfUnderlying(address account) external view returns (uint);


    function rate() external view returns (uint);


    function readyToSettle() external view returns (bool);


    function secsLeftInWaitingPeriod() external view returns (uint);


    function settled() external view returns (bool);


    function synth() external view returns (ISynth);


    function settle(address account) external;

}


interface ISynthetix {

    function anySynthOrSNXRateIsInvalid() external view returns (bool anyRateInvalid);


    function availableCurrencyKeys() external view returns (bytes32[] memory);


    function availableSynthCount() external view returns (uint);


    function availableSynths(uint index) external view returns (ISynth);


    function collateral(address account) external view returns (uint);


    function collateralisationRatio(address issuer) external view returns (uint);


    function debtBalanceOf(address issuer, bytes32 currencyKey) external view returns (uint);


    function isWaitingPeriod(bytes32 currencyKey) external view returns (bool);


    function maxIssuableSynths(address issuer) external view returns (uint maxIssuable);


    function remainingIssuableSynths(address issuer)
        external
        view
        returns (
            uint maxIssuable,
            uint alreadyIssued,
            uint totalSystemDebt
        );


    function synths(bytes32 currencyKey) external view returns (ISynth);


    function synthsByAddress(address synthAddress) external view returns (bytes32);


    function totalIssuedSynths(bytes32 currencyKey) external view returns (uint);


    function totalIssuedSynthsExcludeEtherCollateral(bytes32 currencyKey) external view returns (uint);


    function transferableSynthetix(address account) external view returns (uint transferable);


    function burnSynths(uint amount) external;


    function burnSynthsOnBehalf(address burnForAddress, uint amount) external;


    function burnSynthsToTarget() external;


    function burnSynthsToTargetOnBehalf(address burnForAddress) external;


    function exchange(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function exchangeOnBehalf(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey
    ) external returns (uint amountReceived);


    function exchangeWithTracking(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address rewardAddress,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeWithTrackingForInitiator(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address rewardAddress,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeOnBehalfWithTracking(
        address exchangeForAddress,
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        address rewardAddress,
        bytes32 trackingCode
    ) external returns (uint amountReceived);


    function exchangeWithVirtual(
        bytes32 sourceCurrencyKey,
        uint sourceAmount,
        bytes32 destinationCurrencyKey,
        bytes32 trackingCode
    ) external returns (uint amountReceived, IVirtualSynth vSynth);


    function issueMaxSynths() external;


    function issueMaxSynthsOnBehalf(address issueForAddress) external;


    function issueSynths(uint amount) external;


    function issueSynthsOnBehalf(address issueForAddress, uint amount) external;


    function mint() external returns (bool);


    function settle(bytes32 currencyKey)
        external
        returns (
            uint reclaimed,
            uint refunded,
            uint numEntries
        );


    function liquidateDelinquentAccount(address account, uint susdAmount) external returns (bool);



    function mintSecondary(address account, uint amount) external;


    function mintSecondaryRewards(uint amount) external;


    function burnSecondary(address account, uint amount) external;

}








contract RewardEscrow is Owned, IRewardEscrow {

    using SafeMath for uint;

    ISynthetix public synthetix;

    IFeePool public feePool;

    mapping(address => uint[2][]) public vestingSchedules;

    mapping(address => uint) public totalEscrowedAccountBalance;

    mapping(address => uint) public totalVestedAccountBalance;

    uint public totalEscrowedBalance;

    uint internal constant TIME_INDEX = 0;
    uint internal constant QUANTITY_INDEX = 1;

    uint public constant MAX_VESTING_ENTRIES = 52 * 5;


    constructor(
        address _owner,
        ISynthetix _synthetix,
        IFeePool _feePool
    ) public Owned(_owner) {
        synthetix = _synthetix;
        feePool = _feePool;
    }


    function setSynthetix(ISynthetix _synthetix) external onlyOwner {

        synthetix = _synthetix;
        emit SynthetixUpdated(address(_synthetix));
    }

    function setFeePool(IFeePool _feePool) external onlyOwner {

        feePool = _feePool;
        emit FeePoolUpdated(address(_feePool));
    }


    function balanceOf(address account) public view returns (uint) {

        return totalEscrowedAccountBalance[account];
    }

    function _numVestingEntries(address account) internal view returns (uint) {

        return vestingSchedules[account].length;
    }

    function numVestingEntries(address account) external view returns (uint) {

        return vestingSchedules[account].length;
    }

    function getVestingScheduleEntry(address account, uint index) public view returns (uint[2] memory) {

        return vestingSchedules[account][index];
    }

    function getVestingTime(address account, uint index) public view returns (uint) {

        return getVestingScheduleEntry(account, index)[TIME_INDEX];
    }

    function getVestingQuantity(address account, uint index) public view returns (uint) {

        return getVestingScheduleEntry(account, index)[QUANTITY_INDEX];
    }

    function getNextVestingIndex(address account) public view returns (uint) {

        uint len = _numVestingEntries(account);
        for (uint i = 0; i < len; i++) {
            if (getVestingTime(account, i) != 0) {
                return i;
            }
        }
        return len;
    }

    function getNextVestingEntry(address account) public view returns (uint[2] memory) {

        uint index = getNextVestingIndex(account);
        if (index == _numVestingEntries(account)) {
            return [uint(0), 0];
        }
        return getVestingScheduleEntry(account, index);
    }

    function getNextVestingTime(address account) external view returns (uint) {

        return getNextVestingEntry(account)[TIME_INDEX];
    }

    function getNextVestingQuantity(address account) external view returns (uint) {

        return getNextVestingEntry(account)[QUANTITY_INDEX];
    }

    function checkAccountSchedule(address account) public view returns (uint[520] memory) {

        uint[520] memory _result;
        uint schedules = _numVestingEntries(account);
        for (uint i = 0; i < schedules; i++) {
            uint[2] memory pair = getVestingScheduleEntry(account, i);
            _result[i * 2] = pair[0];
            _result[i * 2 + 1] = pair[1];
        }
        return _result;
    }


    function _appendVestingEntry(address account, uint quantity) internal {

        require(quantity != 0, "Quantity cannot be zero");

        totalEscrowedBalance = totalEscrowedBalance.add(quantity);
        require(
            totalEscrowedBalance <= IERC20(address(synthetix)).balanceOf(address(this)),
            "Must be enough balance in the contract to provide for the vesting entry"
        );

        uint scheduleLength = vestingSchedules[account].length;
        require(scheduleLength <= MAX_VESTING_ENTRIES, "Vesting schedule is too long");

        uint time = now + 52 weeks;

        if (scheduleLength == 0) {
            totalEscrowedAccountBalance[account] = quantity;
        } else {
            require(
                getVestingTime(account, scheduleLength - 1) < time,
                "Cannot add new vested entries earlier than the last one"
            );
            totalEscrowedAccountBalance[account] = totalEscrowedAccountBalance[account].add(quantity);
        }

        vestingSchedules[account].push([time, quantity]);

        emit VestingEntryCreated(account, now, quantity);
    }

    function appendVestingEntry(address account, uint quantity) external onlyFeePool {

        _appendVestingEntry(account, quantity);
    }

    function vest() external {

        uint numEntries = _numVestingEntries(msg.sender);
        uint total;
        for (uint i = 0; i < numEntries; i++) {
            uint time = getVestingTime(msg.sender, i);
            if (time > now) {
                break;
            }
            uint qty = getVestingQuantity(msg.sender, i);
            if (qty > 0) {
                vestingSchedules[msg.sender][i] = [0, 0];
                total = total.add(qty);
            }
        }

        if (total != 0) {
            totalEscrowedBalance = totalEscrowedBalance.sub(total);
            totalEscrowedAccountBalance[msg.sender] = totalEscrowedAccountBalance[msg.sender].sub(total);
            totalVestedAccountBalance[msg.sender] = totalVestedAccountBalance[msg.sender].add(total);
            IERC20(address(synthetix)).transfer(msg.sender, total);
            emit Vested(msg.sender, now, total);
        }
    }


    modifier onlyFeePool() {

        bool isFeePool = msg.sender == address(feePool);

        require(isFeePool, "Only the FeePool contracts can perform this action");
        _;
    }


    event SynthetixUpdated(address newSynthetix);

    event FeePoolUpdated(address newFeePool);

    event Vested(address indexed beneficiary, uint time, uint value);

    event VestingEntryCreated(address indexed beneficiary, uint time, uint value);
}


interface IRewardsDistribution {

    struct DistributionData {
        address destination;
        uint amount;
    }

    function authority() external view returns (address);


    function distributions(uint index) external view returns (address destination, uint amount); // DistributionData


    function distributionsLength() external view returns (uint);


    function distributeRewards(uint amount) external returns (bool);

}








contract RewardsDistribution is Owned, IRewardsDistribution {

    using SafeMath for uint;
    using SafeDecimalMath for uint;

    address public authority;

    address public synthetixProxy;

    address public rewardEscrow;

    address public feePoolProxy;

    DistributionData[] public distributions;

    constructor(
        address _owner,
        address _authority,
        address _synthetixProxy,
        address _rewardEscrow,
        address _feePoolProxy
    ) public Owned(_owner) {
        authority = _authority;
        synthetixProxy = _synthetixProxy;
        rewardEscrow = _rewardEscrow;
        feePoolProxy = _feePoolProxy;
    }


    function setSynthetixProxy(address _synthetixProxy) external onlyOwner {

        synthetixProxy = _synthetixProxy;
    }

    function setRewardEscrow(address _rewardEscrow) external onlyOwner {

        rewardEscrow = _rewardEscrow;
    }

    function setFeePoolProxy(address _feePoolProxy) external onlyOwner {

        feePoolProxy = _feePoolProxy;
    }

    function setAuthority(address _authority) external onlyOwner {

        authority = _authority;
    }


    function addRewardDistribution(address destination, uint amount) external onlyOwner returns (bool) {

        require(destination != address(0), "Cant add a zero address");
        require(amount != 0, "Cant add a zero amount");

        DistributionData memory rewardsDistribution = DistributionData(destination, amount);
        distributions.push(rewardsDistribution);

        emit RewardDistributionAdded(distributions.length - 1, destination, amount);
        return true;
    }

    function removeRewardDistribution(uint index) external onlyOwner {

        require(index <= distributions.length - 1, "index out of bounds");

        for (uint i = index; i < distributions.length - 1; i++) {
            distributions[i] = distributions[i + 1];
        }
        distributions.length--;

    }

    function editRewardDistribution(
        uint index,
        address destination,
        uint amount
    ) external onlyOwner returns (bool) {

        require(index <= distributions.length - 1, "index out of bounds");

        distributions[index].destination = destination;
        distributions[index].amount = amount;

        return true;
    }

    function distributeRewards(uint amount) external returns (bool) {

        require(amount > 0, "Nothing to distribute");
        require(msg.sender == authority, "Caller is not authorised");
        require(rewardEscrow != address(0), "RewardEscrow is not set");
        require(synthetixProxy != address(0), "SynthetixProxy is not set");
        require(feePoolProxy != address(0), "FeePoolProxy is not set");
        require(
            IERC20(synthetixProxy).balanceOf(address(this)) >= amount,
            "RewardsDistribution contract does not have enough tokens to distribute"
        );

        uint remainder = amount;

        for (uint i = 0; i < distributions.length; i++) {
            if (distributions[i].destination != address(0) || distributions[i].amount != 0) {
                remainder = remainder.sub(distributions[i].amount);

                IERC20(synthetixProxy).transfer(distributions[i].destination, distributions[i].amount);

                bytes memory payload = abi.encodeWithSignature("notifyRewardAmount(uint256)", distributions[i].amount);

                (bool success, ) = distributions[i].destination.call(payload);

                if (!success) {
                }
            }
        }

        IERC20(synthetixProxy).transfer(rewardEscrow, remainder);

        IFeePool(feePoolProxy).setRewardsToDistribute(remainder);

        emit RewardsDistributed(amount);
        return true;
    }


    function distributionsLength() external view returns (uint) {

        return distributions.length;
    }


    event RewardDistributionAdded(uint index, address destination, uint amount);
    event RewardsDistributed(uint amount);
}


interface ISynthetixNamedContract {

    function CONTRACT_NAME() external view returns (bytes32);

}

contract Migration_Alnitak is BaseMigration {

    address public constant OWNER = 0xEb3107117FEAd7de89Cd14D463D340A2E6917769;

    AddressResolver public constant addressresolver_i = AddressResolver(0x823bE81bbF96BEc0e25CA13170F5AaCb5B79ba83);
    ProxyERC20 public constant proxyerc20_i = ProxyERC20(0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F);
    Proxy public constant proxysynthetix_i = Proxy(0xC011A72400E58ecD99Ee497CF89E3775d4bd732F);
    ExchangeState public constant exchangestate_i = ExchangeState(0x545973f28950f50fc6c7F52AAb4Ad214A27C0564);
    SystemStatus public constant systemstatus_i = SystemStatus(0x1c86B3CDF2a60Ae3a574f7f71d44E2C50BDdB87E);
    LegacyTokenState public constant tokenstatesynthetix_i = LegacyTokenState(0x5b1b5fEa1b99D83aD479dF0C222F0492385381dD);
    RewardEscrow public constant rewardescrow_i = RewardEscrow(0xb671F2210B1F6621A2607EA63E6B2DC3e2464d1F);
    RewardsDistribution public constant rewardsdistribution_i =
        RewardsDistribution(0x29C295B046a73Cde593f21f63091B072d407e3F2);

    constructor() public BaseMigration(OWNER) {}

    function contractsRequiringOwnership() external pure returns (address[] memory contracts) {

        contracts = new address[](8);
        contracts[0] = address(addressresolver_i);
        contracts[1] = address(proxyerc20_i);
        contracts[2] = address(proxysynthetix_i);
        contracts[3] = address(exchangestate_i);
        contracts[4] = address(systemstatus_i);
        contracts[5] = address(tokenstatesynthetix_i);
        contracts[6] = address(rewardescrow_i);
        contracts[7] = address(rewardsdistribution_i);
    }

    function migrate(address currentOwner) external onlyDeployer {

        require(owner == currentOwner, "Only the assigned owner can be re-assigned when complete");

        address new_Synthetix_contract = 0x43AE8037179a5746D618DA077A38DdeEa9640cBa;
        address new_DebtCache_contract = 0x5c296E9dCa708B5722257D775Cf92052f99Da63f;
        address new_Exchanger_contract = 0x613c773c7a1D85D2F1DCC051B0573D33470762Eb;

        require(
            ISynthetixNamedContract(new_Synthetix_contract).CONTRACT_NAME() == "Synthetix",
            "Invalid contract supplied for Synthetix"
        );
        require(
            ISynthetixNamedContract(new_DebtCache_contract).CONTRACT_NAME() == "DebtCache",
            "Invalid contract supplied for DebtCache"
        );
        require(
            ISynthetixNamedContract(new_Exchanger_contract).CONTRACT_NAME() == "Exchanger",
            "Invalid contract supplied for Exchanger"
        );

        addressresolver_i.acceptOwnership();
        proxyerc20_i.acceptOwnership();
        proxysynthetix_i.acceptOwnership();
        exchangestate_i.acceptOwnership();
        systemstatus_i.acceptOwnership();
        tokenstatesynthetix_i.acceptOwnership();
        rewardescrow_i.acceptOwnership();
        rewardsdistribution_i.acceptOwnership();

        bytes32[] memory addressresolver_importAddresses_names_0_0 = new bytes32[](3);
        addressresolver_importAddresses_names_0_0[0] = bytes32("Synthetix");
        addressresolver_importAddresses_names_0_0[1] = bytes32("DebtCache");
        addressresolver_importAddresses_names_0_0[2] = bytes32("Exchanger");
        address[] memory addressresolver_importAddresses_destinations_0_1 = new address[](3);
        addressresolver_importAddresses_destinations_0_1[0] = address(new_Synthetix_contract);
        addressresolver_importAddresses_destinations_0_1[1] = address(new_DebtCache_contract);
        addressresolver_importAddresses_destinations_0_1[2] = address(new_Exchanger_contract);
        addressresolver_i.importAddresses(
            addressresolver_importAddresses_names_0_0,
            addressresolver_importAddresses_destinations_0_1
        );
        MixinResolver[] memory addressresolver_rebuildCaches_destinations_1_0 = new MixinResolver[](20);
        addressresolver_rebuildCaches_destinations_1_0[0] = MixinResolver(0xDA4eF8520b1A57D7d63f1E249606D1A459698876);
        addressresolver_rebuildCaches_destinations_1_0[1] = MixinResolver(0xAD95C918af576c82Df740878C3E983CBD175daB6);
        addressresolver_rebuildCaches_destinations_1_0[2] = MixinResolver(0xcf9E60005C9aca983caf65d3669a24fDd0775fc0);
        addressresolver_rebuildCaches_destinations_1_0[3] = MixinResolver(new_Exchanger_contract);
        addressresolver_rebuildCaches_destinations_1_0[4] = MixinResolver(0xB774711F0BC1306ce892ef8C02D0476dCccB46B7);
        addressresolver_rebuildCaches_destinations_1_0[5] = MixinResolver(0x62922670313bf6b41C580143d1f6C173C5C20019);
        addressresolver_rebuildCaches_destinations_1_0[6] = MixinResolver(0xCd9D4988C0AE61887B075bA77f08cbFAd2b65068);
        addressresolver_rebuildCaches_destinations_1_0[7] = MixinResolver(0xd69b189020EF614796578AfE4d10378c5e7e1138);
        addressresolver_rebuildCaches_destinations_1_0[8] = MixinResolver(new_Synthetix_contract);
        addressresolver_rebuildCaches_destinations_1_0[9] = MixinResolver(new_DebtCache_contract);
        addressresolver_rebuildCaches_destinations_1_0[10] = MixinResolver(0x4D8dBD193d89b7B506BE5dC9Db75B91dA00D6a1d);
        addressresolver_rebuildCaches_destinations_1_0[11] = MixinResolver(0xC61b352fCc311Ae6B0301459A970150005e74b3E);
        addressresolver_rebuildCaches_destinations_1_0[12] = MixinResolver(0x388fD1A8a7d36e03eFA1ab100a1c5159a3A3d427);
        addressresolver_rebuildCaches_destinations_1_0[13] = MixinResolver(0x37B648a07476F4941D3D647f81118AFd55fa8a04);
        addressresolver_rebuildCaches_destinations_1_0[14] = MixinResolver(0xEF285D339c91aDf1dD7DE0aEAa6250805FD68258);
        addressresolver_rebuildCaches_destinations_1_0[15] = MixinResolver(0xcf9bB94b5d65589039607BA66e3DAC686d3eFf01);
        addressresolver_rebuildCaches_destinations_1_0[16] = MixinResolver(0xCeC4e038371d32212C6Dcdf36Fdbcb6F8a34C6d8);
        addressresolver_rebuildCaches_destinations_1_0[17] = MixinResolver(0x5eDf7dd83fE2889D264fa9D3b93d0a6e6A45D6C6);
        addressresolver_rebuildCaches_destinations_1_0[18] = MixinResolver(0x9745606DA6e162866DAD7bF80f2AbF145EDD7571);
        addressresolver_rebuildCaches_destinations_1_0[19] = MixinResolver(0x2962EA4E749e54b10CFA557770D597027BA67cB3);
        addressresolver_i.rebuildCaches(addressresolver_rebuildCaches_destinations_1_0);
        MixinResolver[] memory addressresolver_rebuildCaches_destinations_2_0 = new MixinResolver[](20);
        addressresolver_rebuildCaches_destinations_2_0[0] = MixinResolver(0xDB91E4B3b6E19bF22E810C43273eae48C9037e74);
        addressresolver_rebuildCaches_destinations_2_0[1] = MixinResolver(0xab4e760fEEe20C5c2509061b995e06b542D3112B);
        addressresolver_rebuildCaches_destinations_2_0[2] = MixinResolver(0xda3c83750b1FA31Fda838136ef3f853b41cb7a5a);
        addressresolver_rebuildCaches_destinations_2_0[3] = MixinResolver(0x47bD14817d7684082E04934878EE2Dd3576Ae19d);
        addressresolver_rebuildCaches_destinations_2_0[4] = MixinResolver(0x6F927644d55E32318629198081923894FbFe5c07);
        addressresolver_rebuildCaches_destinations_2_0[5] = MixinResolver(0xe3D5E1c1bA874C0fF3BA31b999967F24d5ca04e5);
        addressresolver_rebuildCaches_destinations_2_0[6] = MixinResolver(0xA962208CDC8588F9238fae169d0F63306c353F4F);
        addressresolver_rebuildCaches_destinations_2_0[7] = MixinResolver(0xcd980Fc5CcdAe62B18A52b83eC64200121A929db);
        addressresolver_rebuildCaches_destinations_2_0[8] = MixinResolver(0xAf090d6E583C082f2011908cf95c2518BE7A53ac);
        addressresolver_rebuildCaches_destinations_2_0[9] = MixinResolver(0x21ee4afBd6c151fD9A69c1389598170B1d45E0e3);
        addressresolver_rebuildCaches_destinations_2_0[10] = MixinResolver(0xcb6Cb218D558ae7fF6415f95BDA6616FCFF669Cb);
        addressresolver_rebuildCaches_destinations_2_0[11] = MixinResolver(0x7B29C9e188De18563B19d162374ce6836F31415a);
        addressresolver_rebuildCaches_destinations_2_0[12] = MixinResolver(0xC22e51FA362654ea453B4018B616ef6f6ab3b779);
        addressresolver_rebuildCaches_destinations_2_0[13] = MixinResolver(0xaB38249f4f56Ef868F6b5E01D9cFa26B952c1270);
        addressresolver_rebuildCaches_destinations_2_0[14] = MixinResolver(0xAa1b12E3e5F70aBCcd1714F4260A74ca21e7B17b);
        addressresolver_rebuildCaches_destinations_2_0[15] = MixinResolver(0x0F393ce493d8FB0b83915248a21a3104932ed97c);
        addressresolver_rebuildCaches_destinations_2_0[16] = MixinResolver(0xfD0435A588BF5c5a6974BA19Fa627b772833d4eb);
        addressresolver_rebuildCaches_destinations_2_0[17] = MixinResolver(0x4287dac1cC7434991119Eba7413189A66fFE65cF);
        addressresolver_rebuildCaches_destinations_2_0[18] = MixinResolver(0x34c76BC146b759E58886e821D62548AC1e0BA7Bc);
        addressresolver_rebuildCaches_destinations_2_0[19] = MixinResolver(0x0E8Fa2339314AB7E164818F26207897bBe29C3af);
        addressresolver_i.rebuildCaches(addressresolver_rebuildCaches_destinations_2_0);
        MixinResolver[] memory addressresolver_rebuildCaches_destinations_3_0 = new MixinResolver[](20);
        addressresolver_rebuildCaches_destinations_3_0[0] = MixinResolver(0xe615Df79AC987193561f37E77465bEC2aEfe9aDb);
        addressresolver_rebuildCaches_destinations_3_0[1] = MixinResolver(0x3E2dA260B4A85782A629320EB027A3B7c28eA9f1);
        addressresolver_rebuildCaches_destinations_3_0[2] = MixinResolver(0xc02DD182Ce029E6d7f78F37492DFd39E4FEB1f8b);
        addressresolver_rebuildCaches_destinations_3_0[3] = MixinResolver(0x0d1c4e5C07B071aa4E6A14A604D4F6478cAAC7B4);
        addressresolver_rebuildCaches_destinations_3_0[4] = MixinResolver(0x13D0F5B8630520eA04f694F17A001fb95eaFD30E);
        addressresolver_rebuildCaches_destinations_3_0[5] = MixinResolver(0x815CeF3b7773f35428B4353073B086ecB658f73C);
        addressresolver_rebuildCaches_destinations_3_0[6] = MixinResolver(0xb0e0BA880775B7F2ba813b3800b3979d719F0379);
        addressresolver_rebuildCaches_destinations_3_0[7] = MixinResolver(0x8e082925e78538955bC0e2F363FC5d1Ab3be739b);
        addressresolver_rebuildCaches_destinations_3_0[8] = MixinResolver(0x399BA516a6d68d6Ad4D5f3999902D0DeAcaACDdd);
        addressresolver_rebuildCaches_destinations_3_0[9] = MixinResolver(0x9530FA32a3059114AC20A5812870Da12D97d1174);
        addressresolver_rebuildCaches_destinations_3_0[10] = MixinResolver(0x249612F641111022f2f48769f3Df5D85cb3E26a2);
        addressresolver_rebuildCaches_destinations_3_0[11] = MixinResolver(0x04720DbBD4599aD26811545595d97fB813E84964);
        addressresolver_rebuildCaches_destinations_3_0[12] = MixinResolver(0x2acfe6265D358d982cB1c3B521199973CD443C71);
        addressresolver_rebuildCaches_destinations_3_0[13] = MixinResolver(0x46A7Af405093B27DA6DeF193C508Bd9240A255FA);
        addressresolver_rebuildCaches_destinations_3_0[14] = MixinResolver(0x8350d1b2d6EF5289179fe49E5b0F208165B4e32e);
        addressresolver_rebuildCaches_destinations_3_0[15] = MixinResolver(0x29DD4A59F4D339226867e77aF211724eaBb45c02);
        addressresolver_rebuildCaches_destinations_3_0[16] = MixinResolver(0xf7B8dF8b16dA302d85603B8e7F95111a768458Cc);
        addressresolver_rebuildCaches_destinations_3_0[17] = MixinResolver(0x0517A56da8A517e3b2D484Cc5F1Da4BDCfE68ec3);
        addressresolver_rebuildCaches_destinations_3_0[18] = MixinResolver(0x099CfAd1640fc7EA686ab1D83F0A285Ba0470882);
        addressresolver_rebuildCaches_destinations_3_0[19] = MixinResolver(0x19cC1f63e344D74A87D955E3F3E95B28DDDc61d8);
        addressresolver_i.rebuildCaches(addressresolver_rebuildCaches_destinations_3_0);
        MixinResolver[] memory addressresolver_rebuildCaches_destinations_4_0 = new MixinResolver[](19);
        addressresolver_rebuildCaches_destinations_4_0[0] = MixinResolver(0x4D50A0e5f068ACdC80A1da2dd1f0Ad48845df2F8);
        addressresolver_rebuildCaches_destinations_4_0[1] = MixinResolver(0xb73c665825dAa926D6ef09417FbE5654473c1b49);
        addressresolver_rebuildCaches_destinations_4_0[2] = MixinResolver(0x806A599d60B2FdBda379D5890287D2fba1026cC0);
        addressresolver_rebuildCaches_destinations_4_0[3] = MixinResolver(0xCea42504874586a718954746A564B72bc7eba3E3);
        addressresolver_rebuildCaches_destinations_4_0[4] = MixinResolver(0x947d5656725fB9A8f9c826A91b6082b07E2745B7);
        addressresolver_rebuildCaches_destinations_4_0[5] = MixinResolver(0x186E56A62E7caCE1308f1A1B0dbb27f33F80f16f);
        addressresolver_rebuildCaches_destinations_4_0[6] = MixinResolver(0x931c5516EE121a177bD2B60e0122Da5B27630ABc);
        addressresolver_rebuildCaches_destinations_4_0[7] = MixinResolver(0x6Dc6a64724399524184C2c44a526A2cff1BaA507);
        addressresolver_rebuildCaches_destinations_4_0[8] = MixinResolver(0x87eb6e935e3C7E3E3A0E31a5658498bC87dE646E);
        addressresolver_rebuildCaches_destinations_4_0[9] = MixinResolver(0x53869BDa4b8d85aEDCC9C6cAcf015AF9447Cade7);
        addressresolver_rebuildCaches_destinations_4_0[10] = MixinResolver(0x1cB27Ac646afAE192dF9928A2808C0f7f586Af7d);
        addressresolver_rebuildCaches_destinations_4_0[11] = MixinResolver(0x3dD7b893c25025CabFBd290A5E06BaFF3DE335b8);
        addressresolver_rebuildCaches_destinations_4_0[12] = MixinResolver(0x1A4505543C92084bE57ED80113eaB7241171e7a8);
        addressresolver_rebuildCaches_destinations_4_0[13] = MixinResolver(0xF6ce55E09De0F9F97210aAf6DB88Ed6b6792Ca1f);
        addressresolver_rebuildCaches_destinations_4_0[14] = MixinResolver(0xacAAB69C2BA65A2DB415605F309007e18D4F5E8C);
        addressresolver_rebuildCaches_destinations_4_0[15] = MixinResolver(0x9A5Ea0D8786B8d17a70410A905Aed1443fae5A38);
        addressresolver_rebuildCaches_destinations_4_0[16] = MixinResolver(0x5c8344bcdC38F1aB5EB5C1d4a35DdEeA522B5DfA);
        addressresolver_rebuildCaches_destinations_4_0[17] = MixinResolver(0xaa03aB31b55DceEeF845C8d17890CC61cD98eD04);
        addressresolver_rebuildCaches_destinations_4_0[18] = MixinResolver(0x1F2c3a1046c32729862fcB038369696e3273a516);
        addressresolver_i.rebuildCaches(addressresolver_rebuildCaches_destinations_4_0);
        proxyerc20_i.setTarget(Proxyable(new_Synthetix_contract));
        proxysynthetix_i.setTarget(Proxyable(new_Synthetix_contract));
        exchangestate_i.setAssociatedContract(new_Exchanger_contract);
        systemstatus_i.updateAccessControl("Synth", new_Exchanger_contract, true, false);
        tokenstatesynthetix_i.setAssociatedContract(new_Synthetix_contract);
        rewardescrow_i.setSynthetix(ISynthetix(new_Synthetix_contract));
        rewardsdistribution_i.setAuthority(new_Synthetix_contract);

        addressresolver_i.nominateNewOwner(owner);
        proxyerc20_i.nominateNewOwner(owner);
        proxysynthetix_i.nominateNewOwner(owner);
        exchangestate_i.nominateNewOwner(owner);
        systemstatus_i.nominateNewOwner(owner);
        tokenstatesynthetix_i.nominateOwner(owner);
        rewardescrow_i.nominateNewOwner(owner);
        rewardsdistribution_i.nominateNewOwner(owner);
    }
}