pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}pragma solidity ^0.5.0;

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}pragma solidity 0.5.17;


library AddressArrayUtils {


    function contains(address[] memory self, address _address)
        internal
        pure
        returns (bool)
    {

        for (uint i = 0; i < self.length; i++) {
            if (_address == self[i]) {
                return true;
            }
        }
        return false;
    }

    function removeAddress(address[] storage self, address _addressToRemove)
        internal
        returns (address[] storage)
    {

        for (uint i = 0; i < self.length; i++) {
            if (_addressToRemove == self[i]) {
                for (uint j = i; j < self.length-1; j++) {
                    self[j] = self[j+1];
                }
                self.length--;
                i--;
            }
        }
        return self;
    }
}pragma solidity 0.5.17;


library PercentUtils {

    using SafeMath for uint256;

    function percent(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(b).div(100);
    }

    function asPercentOf(uint256 a, uint256 b) internal pure returns (uint256) {

        return a.mul(100).div(b);
    }
}pragma solidity 0.5.17;


contract KeepRegistry {

    enum ContractStatus {New, Approved, Disabled}

    address public governance;

    address public registryKeeper;

    mapping(address => address) public panicButtons;

    address public defaultPanicButton;

    mapping(address => address) public operatorContractUpgraders;

    mapping(address => address) public serviceContractUpgraders;

    mapping(address => ContractStatus) public operatorContracts;

    event OperatorContractApproved(address operatorContract);
    event OperatorContractDisabled(address operatorContract);

    event GovernanceUpdated(address governance);
    event RegistryKeeperUpdated(address registryKeeper);
    event DefaultPanicButtonUpdated(address defaultPanicButton);
    event OperatorContractPanicButtonDisabled(address operatorContract);
    event OperatorContractPanicButtonUpdated(
        address operatorContract,
        address panicButton
    );
    event OperatorContractUpgraderUpdated(
        address serviceContract,
        address upgrader
    );
    event ServiceContractUpgraderUpdated(
        address operatorContract,
        address keeper
    );

    modifier onlyGovernance() {

        require(governance == msg.sender, "Not authorized");
        _;
    }

    modifier onlyRegistryKeeper() {

        require(registryKeeper == msg.sender, "Not authorized");
        _;
    }

    modifier onlyPanicButton(address _operatorContract) {

        address panicButton = panicButtons[_operatorContract];
        require(panicButton != address(0), "Panic button disabled");
        require(panicButton == msg.sender, "Not authorized");
        _;
    }

    modifier onlyForNewContract(address _operatorContract) {

        require(
            isNewOperatorContract(_operatorContract),
            "Not a new operator contract"
        );
        _;
    }

    modifier onlyForApprovedContract(address _operatorContract) {

        require(
            isApprovedOperatorContract(_operatorContract),
            "Not an approved operator contract"
        );
        _;
    }

    constructor() public {
        governance = msg.sender;
        registryKeeper = msg.sender;
        defaultPanicButton = msg.sender;
    }

    function setGovernance(address _governance) public onlyGovernance {

        governance = _governance;
        emit GovernanceUpdated(governance);
    }

    function setRegistryKeeper(address _registryKeeper) public onlyGovernance {

        registryKeeper = _registryKeeper;
        emit RegistryKeeperUpdated(registryKeeper);
    }

    function setDefaultPanicButton(address _panicButton) public onlyGovernance {

        defaultPanicButton = _panicButton;
        emit DefaultPanicButtonUpdated(defaultPanicButton);
    }

    function setOperatorContractPanicButton(
        address _operatorContract,
        address _panicButton
    ) public onlyForApprovedContract(_operatorContract) onlyGovernance {

        require(
            panicButtons[_operatorContract] != address(0),
            "Disabled panic button cannot be updated"
        );
        require(
            _panicButton != address(0),
            "Panic button must be non-zero address"
        );

        panicButtons[_operatorContract] = _panicButton;

        emit OperatorContractPanicButtonUpdated(
            _operatorContract,
            _panicButton
        );
    }

    function disableOperatorContractPanicButton(address _operatorContract)
        public
        onlyForApprovedContract(_operatorContract)
        onlyGovernance
    {

        require(
            panicButtons[_operatorContract] != address(0),
            "Panic button already disabled"
        );

        panicButtons[_operatorContract] = address(0);

        emit OperatorContractPanicButtonDisabled(_operatorContract);
    }

    function setOperatorContractUpgrader(
        address _serviceContract,
        address _operatorContractUpgrader
    ) public onlyGovernance {

        operatorContractUpgraders[_serviceContract] = _operatorContractUpgrader;
        emit OperatorContractUpgraderUpdated(
            _serviceContract,
            _operatorContractUpgrader
        );
    }

    function setServiceContractUpgrader(
        address _operatorContract,
        address _serviceContractUpgrader
    ) public onlyGovernance {

        serviceContractUpgraders[_operatorContract] = _serviceContractUpgrader;
        emit ServiceContractUpgraderUpdated(
            _operatorContract,
            _serviceContractUpgrader
        );
    }

    function approveOperatorContract(address operatorContract)
        public
        onlyForNewContract(operatorContract)
        onlyRegistryKeeper
    {

        operatorContracts[operatorContract] = ContractStatus.Approved;
        panicButtons[operatorContract] = defaultPanicButton;
        emit OperatorContractApproved(operatorContract);
    }

    function disableOperatorContract(address operatorContract)
        public
        onlyForApprovedContract(operatorContract)
        onlyPanicButton(operatorContract)
    {

        operatorContracts[operatorContract] = ContractStatus.Disabled;
        emit OperatorContractDisabled(operatorContract);
    }

    function isNewOperatorContract(address operatorContract)
        public
        view
        returns (bool)
    {

        return operatorContracts[operatorContract] == ContractStatus.New;
    }

    function isApprovedOperatorContract(address operatorContract)
        public
        view
        returns (bool)
    {

        return operatorContracts[operatorContract] == ContractStatus.Approved;
    }

    function operatorContractUpgraderFor(address _serviceContract)
        public
        view
        returns (address)
    {

        return operatorContractUpgraders[_serviceContract];
    }

    function serviceContractUpgraderFor(address _operatorContract)
        public
        view
        returns (address)
    {

        return serviceContractUpgraders[_operatorContract];
    }
}/**
▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓▌        ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
  ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓

                           Trust math, not hardware.
*/

pragma solidity 0.5.17;


interface IRandomBeacon {

    event RelayEntryGenerated(uint256 requestId, uint256 entry);

    function entryFeeEstimate(uint256 callbackGas)
        external
        view
        returns (uint256);


    function requestRelayEntry(address callbackContract, uint256 callbackGas)
        external
        payable
        returns (uint256);


    function requestRelayEntry() external payable returns (uint256);

}


interface IRandomBeaconConsumer {

    function __beaconCallback(uint256 relayEntry) external;

}/**
▓▓▌ ▓▓ ▐▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▄
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▌▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓    ▓▓▓▓▓▓▓▀    ▐▓▓▓▓▓▓    ▐▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▄▄▓▓▓▓▓▓▓▀      ▐▓▓▓▓▓▓▄▄▄▄         ▓▓▓▓▓▓▄▄▄▄         ▐▓▓▓▓▓▌   ▐▓▓▓▓▓▓
  ▓▓▓▓▓▓▓▓▓▓▓▓▓▀        ▐▓▓▓▓▓▓▓▓▓▓         ▓▓▓▓▓▓▓▓▓▓▌        ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
  ▓▓▓▓▓▓▀▀▓▓▓▓▓▓▄       ▐▓▓▓▓▓▓▀▀▀▀         ▓▓▓▓▓▓▀▀▀▀         ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▀
  ▓▓▓▓▓▓   ▀▓▓▓▓▓▓▄     ▐▓▓▓▓▓▓     ▓▓▓▓▓   ▓▓▓▓▓▓     ▓▓▓▓▓   ▐▓▓▓▓▓▌
▓▓▓▓▓▓▓▓▓▓ █▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓
▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓ ▐▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓

                           Trust math, not hardware.
*/

pragma solidity 0.5.17;



interface OperatorContract {

    function entryVerificationFee() external view returns(uint256);

    function groupCreationFee() external view returns(uint256);

    function groupProfitFee() external view returns(uint256);

    function gasPriceCeiling() external view returns(uint256);

    function sign(
        uint256 requestId,
        bytes calldata previousEntry
    ) external payable;

    function numberOfGroups() external view returns(uint256);

    function createGroup(uint256 newEntry, address payable submitter) external payable;

    function isGroupSelectionPossible() external view returns (bool);

}

contract KeepRandomBeaconServiceImplV1 is ReentrancyGuard, IRandomBeacon {

    using SafeMath for uint256;
    using PercentUtils for uint256;
    using AddressArrayUtils for address[];

    event RelayEntryRequested(uint256 requestId);

    uint256 internal _dkgContributionMargin;

    uint256 internal _dkgFeePool;

    uint256 internal _requestSubsidyFeePool;

    uint256 internal _requestCounter;

    bytes internal _previousEntry;

    uint256 internal _baseCallbackGas;

    struct Callback {
        address callbackContract;
        uint256 callbackFee;
        uint256 callbackGas;
        address payable surplusRecipient;
    }

    mapping(uint256 => Callback) internal _callbacks;

    address internal _registry;

    address[] internal _operatorContracts;

    mapping (string => bool) internal _initialized;

    bytes constant internal _beaconSeed =
    hex"15c30f4b6cf6dbbcbdcc10fe22f54c8170aea44e198139b776d512d8f027319a1b9e8bfaf1383978231ce98e42bafc8129f473fc993cf60ce327f7d223460663";

    modifier onlyOperatorContractUpgrader() {

        address operatorContractUpgrader = KeepRegistry(_registry).operatorContractUpgraderFor(address(this));
        require(operatorContractUpgrader == msg.sender, "Caller is not operator contract upgrader");
        _;
    }

    constructor() public {
        _initialized["KeepRandomBeaconServiceImplV1"] = true;
    }

    function initialize(
        uint256 dkgContributionMargin,
        address registry
    )
        public
    {

        require(!initialized(), "Contract is already initialized.");
        require(registry != address(0), "Incorrect registry address");

        _initialized["KeepRandomBeaconServiceImplV1"] = true;
        _dkgContributionMargin = dkgContributionMargin;
        _previousEntry = _beaconSeed;
        _registry = registry;
        _baseCallbackGas = 10226;
    }

    function initialized() public view returns (bool) {

        return _initialized["KeepRandomBeaconServiceImplV1"];
    }

    function addOperatorContract(address operatorContract) public onlyOperatorContractUpgrader {

        require(
            KeepRegistry(_registry).isApprovedOperatorContract(operatorContract),
            "Operator contract is not approved"
        );
        _operatorContracts.push(operatorContract);
    }

    function removeOperatorContract(address operatorContract) public onlyOperatorContractUpgrader {

        _operatorContracts.removeAddress(operatorContract);
    }

    function fundDkgFeePool() public payable {

        _dkgFeePool += msg.value;
    }

    function fundRequestSubsidyFeePool() public payable {

        _requestSubsidyFeePool += msg.value;
    }

    function selectOperatorContract(uint256 seed) public view returns (address) {


        uint256 totalNumberOfGroups;

        uint256 approvedContractsCounter;
        address[] memory approvedContracts = new address[](_operatorContracts.length);

        for (uint i = 0; i < _operatorContracts.length; i++) {
            if (KeepRegistry(_registry).isApprovedOperatorContract(_operatorContracts[i])) {
                totalNumberOfGroups += OperatorContract(_operatorContracts[i]).numberOfGroups();
                approvedContracts[approvedContractsCounter] = _operatorContracts[i];
                approvedContractsCounter++;
            }
        }

        require(totalNumberOfGroups > 0, "Total number of groups must be greater than zero.");

        uint256 selectedIndex = seed % totalNumberOfGroups;

        uint256 selectedContract;
        uint256 indexByGroupCount;

        for (uint256 i = 0; i < approvedContractsCounter; i++) {
            indexByGroupCount += OperatorContract(approvedContracts[i]).numberOfGroups();
            if (selectedIndex < indexByGroupCount) {
                return approvedContracts[selectedContract];
            }
            selectedContract++;
        }

        return approvedContracts[selectedContract];
    }

    function requestRelayEntry() public payable returns (uint256) {

        return requestRelayEntry(address(0), 0);
    }

    function requestRelayEntry(
        address callbackContract,
        uint256 callbackGas
    ) public nonReentrant payable returns (uint256) {

        require(
            callbackGas <= 2000000,
            "Callback gas exceeds 2000000 gas limit"
        );

        require(
            msg.value >= entryFeeEstimate(callbackGas),
            "Payment is less than required minimum."
        );

        (
            uint256 entryVerificationFee,
            uint256 dkgContributionFee,
            uint256 groupProfitFee,
            uint256 gasPriceCeiling
        ) = entryFeeBreakdown();

        uint256 callbackFee = msg.value.sub(entryVerificationFee)
            .sub(dkgContributionFee).sub(groupProfitFee);

        _dkgFeePool += dkgContributionFee;

        OperatorContract operatorContract = OperatorContract(
            selectOperatorContract(uint256(keccak256(_previousEntry)))
        );

        uint256 selectedOperatorContractFee = operatorContract.groupProfitFee().add(
            operatorContract.entryVerificationFee()
        );

        _requestCounter++;
        uint256 requestId = _requestCounter;

        operatorContract.sign.value(
            selectedOperatorContractFee.add(callbackFee)
        )(requestId, _previousEntry);

        uint256 surplus = entryVerificationFee.add(groupProfitFee).sub(selectedOperatorContractFee);
        _requestSubsidyFeePool = _requestSubsidyFeePool.add(surplus);

        if (callbackContract != address(0)) {
            _callbacks[requestId] = Callback(callbackContract, callbackFee, callbackGas, msg.sender);
        }

        if (_requestSubsidyFeePool >= 100) {
            uint256 amount = _requestSubsidyFeePool.percent(1);
            _requestSubsidyFeePool -= amount;
            (bool success, ) = msg.sender.call.value(amount)("");
            require(success, "Failed send subsidy fee");
        }

        emit RelayEntryRequested(requestId);
        return requestId;
    }

    function entryCreated(uint256 requestId, bytes memory entry, address payable submitter) public {

        require(
            _operatorContracts.contains(msg.sender),
            "Only authorized operator contract can call relay entry."
        );

        _previousEntry = entry;
        uint256 entryAsNumber = uint256(keccak256(entry));
        emit RelayEntryGenerated(requestId, entryAsNumber);

        createGroupIfApplicable(entryAsNumber, submitter);
    }

    function executeCallback(uint256 requestId, uint256 entry) public {

        require(
            _operatorContracts.contains(msg.sender),
            "Only authorized operator contract can call execute callback."
        );

        require(
            _callbacks[requestId].callbackContract != address(0),
            "Callback contract not found"
        );

        _callbacks[requestId].callbackContract.call(
            abi.encodeWithSignature("__beaconCallback(uint256)", entry)
        );

        delete _callbacks[requestId];
    }

    function createGroupIfApplicable(uint256 entry, address payable submitter) internal {

        address latestOperatorContract = _operatorContracts[_operatorContracts.length.sub(1)];
        uint256 groupCreationFee = OperatorContract(latestOperatorContract).groupCreationFee();

        if (_dkgFeePool >= groupCreationFee && OperatorContract(latestOperatorContract).isGroupSelectionPossible()) {
            OperatorContract(latestOperatorContract).createGroup.value(groupCreationFee)(entry, submitter);
            _dkgFeePool = _dkgFeePool.sub(groupCreationFee);
        }
    }

    function baseCallbackGas() public view returns(uint256) {

        return _baseCallbackGas;
    }

    function callbackFee(
        uint256 _callbackGas,
        uint256 _gasPriceCeiling
    ) internal view returns(uint256) {

        uint256 callbackGas = _callbackGas == 0 ? 0 : _callbackGas.add(_baseCallbackGas);
        return callbackGas.mul(_gasPriceCeiling);
    }

    function entryFeeEstimate(uint256 callbackGas) public view returns(uint256) {

        require(
            callbackGas <= 2000000,
            "Callback gas exceeds 2000000 gas limit"
        );

        (
            uint256 entryVerificationFee,
            uint256 dkgContributionFee,
            uint256 groupProfitFee,
            uint256 gasPriceCeiling
        ) = entryFeeBreakdown();

        return entryVerificationFee
            .add(dkgContributionFee)
            .add(groupProfitFee)
            .add(callbackFee(callbackGas, gasPriceCeiling));
    }

    function entryFeeBreakdown() public view returns(
        uint256 entryVerificationFee,
        uint256 dkgContributionFee,
        uint256 groupProfitFee,
        uint256 gasPriceCeiling
    ) {

        for (uint i = 0; i < _operatorContracts.length; i++) {
            OperatorContract operator = OperatorContract(_operatorContracts[i]);

            if (operator.numberOfGroups() > 0) {
                uint256 operatorBid = operator.entryVerificationFee();
                if (operatorBid > entryVerificationFee) {
                    entryVerificationFee = operatorBid;
                }

                operatorBid = operator.groupProfitFee();
                if (operatorBid > groupProfitFee) {
                    groupProfitFee = operatorBid;
                }

                operatorBid = operator.gasPriceCeiling();
                if (operatorBid > gasPriceCeiling) {
                    gasPriceCeiling = operatorBid;
                }
            }
        }

        address latestOperatorContract = _operatorContracts[_operatorContracts.length.sub(1)];
        uint256 groupCreationFee = OperatorContract(latestOperatorContract).groupCreationFee();

        return (
            entryVerificationFee,
            groupCreationFee.percent(_dkgContributionMargin),
            groupProfitFee,
            gasPriceCeiling
        );
    }

    function dkgContributionMargin() public view returns(uint256) {

        return _dkgContributionMargin;
    }

    function dkgFeePool() public view returns(uint256) {

        return _dkgFeePool;
    }

    function requestSubsidyFeePool() public view returns(uint256) {

        return _requestSubsidyFeePool;
    }

    function callbackSurplusRecipient(uint256 requestId) public view returns(address payable) {

        return _callbacks[requestId].surplusRecipient;
    }

    function version() public pure returns (string memory) {

        return "V1";
    }
}