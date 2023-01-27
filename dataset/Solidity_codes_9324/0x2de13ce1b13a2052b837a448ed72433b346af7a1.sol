
pragma solidity 0.5.8;

interface IVoting {


    function changeBallotStatus(uint256 _ballotId, bool _isActive) external;


    function getBallotResults(uint256 _ballotId) external view returns(
        uint256[] memory voteWeighting,
        uint256[] memory tieWith,
        uint256 winningProposal,
        bool isVotingSucceed,
        uint256 totalVoters
    );


    function getSelectedProposal(uint256 _ballotId, address _voter) external view returns(uint256 proposalId);


    function getBallotDetails(uint256 _ballotId) external view returns(
        uint256 quorum,
        uint256 totalSupplyAtCheckpoint,
        uint256 checkpointId,
        uint256 startTime,
        uint256 endTime,
        uint256 totalProposals,
        uint256 totalVoters,
        bool isActive
    );


}

interface IModule {

    function getInitFunction() external pure returns(bytes4 initFunction);


    function getPermissions() external view returns(bytes32[] memory permissions);


}

contract Pausable {

    event Pause(address account);
    event Unpause(address account);

    bool public paused = false;

    modifier whenNotPaused() {

        require(!paused, "Contract is paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "Contract is not paused");
        _;
    }

    function _pause() internal whenNotPaused {

        paused = true;
        emit Pause(msg.sender);
    }

    function _unpause() internal whenPaused {

        paused = false;
        emit Unpause(msg.sender);
    }

}

interface IModuleFactory {

    event ChangeSetupCost(uint256 _oldSetupCost, uint256 _newSetupCost);
    event ChangeCostType(bool _isOldCostInPoly, bool _isNewCostInPoly);
    event GenerateModuleFromFactory(
        address _module,
        bytes32 indexed _moduleName,
        address indexed _moduleFactory,
        address _creator,
        uint256 _setupCost,
        uint256 _setupCostInPoly
    );
    event ChangeSTVersionBound(string _boundType, uint8 _major, uint8 _minor, uint8 _patch);

    function deploy(bytes calldata _data) external returns(address moduleAddress);


    function version() external view returns(string memory moduleVersion);


    function name() external view returns(bytes32 moduleName);


    function title() external view returns(string memory moduleTitle);


    function description() external view returns(string memory moduleDescription);


    function setupCost() external returns(uint256 usdSetupCost);


    function getTypes() external view returns(uint8[] memory moduleTypes);


    function getTags() external view returns(bytes32[] memory moduleTags);


    function changeSetupCost(uint256 _newSetupCost) external;


    function changeCostAndType(uint256 _setupCost, bool _isCostInPoly) external;


    function changeSTVersionBounds(string calldata _boundType, uint8[] calldata _newVersion) external;


    function setupCostInPoly() external returns (uint256 polySetupCost);


    function getLowerSTVersionBounds() external view returns(uint8[] memory lowerBounds);


    function getUpperSTVersionBounds() external view returns(uint8[] memory upperBounds);


    function changeTags(bytes32[] calldata _tagsData) external;


    function changeName(bytes32 _name) external;


    function changeDescription(string calldata _description) external;


    function changeTitle(string calldata _title) external;


}

interface IDataStore {

    function setSecurityToken(address _securityToken) external;


    function setUint256(bytes32 _key, uint256 _data) external;


    function setBytes32(bytes32 _key, bytes32 _data) external;


    function setAddress(bytes32 _key, address _data) external;


    function setString(bytes32 _key, string calldata _data) external;


    function setBytes(bytes32 _key, bytes calldata _data) external;


    function setBool(bytes32 _key, bool _data) external;


    function setUint256Array(bytes32 _key, uint256[] calldata _data) external;


    function setBytes32Array(bytes32 _key, bytes32[] calldata _data) external ;


    function setAddressArray(bytes32 _key, address[] calldata _data) external;


    function setBoolArray(bytes32 _key, bool[] calldata _data) external;


    function insertUint256(bytes32 _key, uint256 _data) external;


    function insertBytes32(bytes32 _key, bytes32 _data) external;


    function insertAddress(bytes32 _key, address _data) external;


    function insertBool(bytes32 _key, bool _data) external;


    function deleteUint256(bytes32 _key, uint256 _index) external;


    function deleteBytes32(bytes32 _key, uint256 _index) external;


    function deleteAddress(bytes32 _key, uint256 _index) external;


    function deleteBool(bytes32 _key, uint256 _index) external;


    function setUint256Multi(bytes32[] calldata _keys, uint256[] calldata _data) external;


    function setBytes32Multi(bytes32[] calldata _keys, bytes32[] calldata _data) external;


    function setAddressMulti(bytes32[] calldata _keys, address[] calldata _data) external;


    function setBoolMulti(bytes32[] calldata _keys, bool[] calldata _data) external;


    function insertUint256Multi(bytes32[] calldata _keys, uint256[] calldata _data) external;


    function insertBytes32Multi(bytes32[] calldata _keys, bytes32[] calldata _data) external;


    function insertAddressMulti(bytes32[] calldata _keys, address[] calldata _data) external;


    function insertBoolMulti(bytes32[] calldata _keys, bool[] calldata _data) external;


    function getUint256(bytes32 _key) external view returns(uint256);


    function getBytes32(bytes32 _key) external view returns(bytes32);


    function getAddress(bytes32 _key) external view returns(address);


    function getString(bytes32 _key) external view returns(string memory);


    function getBytes(bytes32 _key) external view returns(bytes memory);


    function getBool(bytes32 _key) external view returns(bool);


    function getUint256Array(bytes32 _key) external view returns(uint256[] memory);


    function getBytes32Array(bytes32 _key) external view returns(bytes32[] memory);


    function getAddressArray(bytes32 _key) external view returns(address[] memory);


    function getBoolArray(bytes32 _key) external view returns(bool[] memory);


    function getUint256ArrayLength(bytes32 _key) external view returns(uint256);


    function getBytes32ArrayLength(bytes32 _key) external view returns(uint256);


    function getAddressArrayLength(bytes32 _key) external view returns(uint256);


    function getBoolArrayLength(bytes32 _key) external view returns(uint256);


    function getUint256ArrayElement(bytes32 _key, uint256 _index) external view returns(uint256);


    function getBytes32ArrayElement(bytes32 _key, uint256 _index) external view returns(bytes32);


    function getAddressArrayElement(bytes32 _key, uint256 _index) external view returns(address);


    function getBoolArrayElement(bytes32 _key, uint256 _index) external view returns(bool);


    function getUint256ArrayElements(bytes32 _key, uint256 _startIndex, uint256 _endIndex) external view returns(uint256[] memory);


    function getBytes32ArrayElements(bytes32 _key, uint256 _startIndex, uint256 _endIndex) external view returns(bytes32[] memory);


    function getAddressArrayElements(bytes32 _key, uint256 _startIndex, uint256 _endIndex) external view returns(address[] memory);


    function getBoolArrayElements(bytes32 _key, uint256 _startIndex, uint256 _endIndex) external view returns(bool[] memory);

}

interface ISecurityToken {

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function decimals() external view returns(uint8);

    function totalSupply() external view returns(uint256);

    function balanceOf(address owner) external view returns(uint256);

    function allowance(address owner, address spender) external view returns(uint256);

    function transfer(address to, uint256 value) external returns(bool);

    function transferFrom(address from, address to, uint256 value) external returns(bool);

    function approve(address spender, uint256 value) external returns(bool);

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function canTransfer(address _to, uint256 _value, bytes calldata _data) external view returns (byte statusCode, bytes32 reasonCode);


    event ModuleAdded(
        uint8[] _types,
        bytes32 indexed _name,
        address indexed _moduleFactory,
        address _module,
        uint256 _moduleCost,
        uint256 _budget,
        bytes32 _label,
        bool _archived
    );

    event UpdateTokenDetails(string _oldDetails, string _newDetails);
    event UpdateTokenName(string _oldName, string _newName);
    event GranularityChanged(uint256 _oldGranularity, uint256 _newGranularity);
    event FreezeIssuance();
    event FreezeTransfers(bool _status);
    event CheckpointCreated(uint256 indexed _checkpointId, uint256 _investorLength);
    event SetController(address indexed _oldController, address indexed _newController);
    event TreasuryWalletChanged(address _oldTreasuryWallet, address _newTreasuryWallet);
    event DisableController();
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TokenUpgraded(uint8 _major, uint8 _minor, uint8 _patch);

    event ModuleArchived(uint8[] _types, address _module); //Event emitted by the tokenLib.
    event ModuleUnarchived(uint8[] _types, address _module); //Event emitted by the tokenLib.
    event ModuleRemoved(uint8[] _types, address _module); //Event emitted by the tokenLib.
    event ModuleBudgetChanged(uint8[] _moduleTypes, address _module, uint256 _oldBudget, uint256 _budget); //Event emitted by the tokenLib.

    event TransferByPartition(
        bytes32 indexed _fromPartition,
        address _operator,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);
    event RevokedOperator(address indexed operator, address indexed tokenHolder);
    event AuthorizedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);
    event RevokedOperatorByPartition(bytes32 indexed partition, address indexed operator, address indexed tokenHolder);

    event IssuedByPartition(bytes32 indexed partition, address indexed to, uint256 value, bytes data);
    event RedeemedByPartition(bytes32 indexed partition, address indexed operator, address indexed from, uint256 value, bytes data, bytes operatorData);

    event DocumentRemoved(bytes32 indexed _name, string _uri, bytes32 _documentHash);
    event DocumentUpdated(bytes32 indexed _name, string _uri, bytes32 _documentHash);

    event ControllerTransfer(
        address _controller,
        address indexed _from,
        address indexed _to,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event ControllerRedemption(
        address _controller,
        address indexed _tokenHolder,
        uint256 _value,
        bytes _data,
        bytes _operatorData
    );

    event Issued(address indexed _operator, address indexed _to, uint256 _value, bytes _data);
    event Redeemed(address indexed _operator, address indexed _from, uint256 _value, bytes _data);

    function initialize(address _getterDelegate) external;


    function canTransferByPartition(
        address _from,
        address _to,
        bytes32 _partition,
        uint256 _value,
        bytes calldata _data
    )
        external
        view
        returns (byte statusCode, bytes32 reasonCode, bytes32 partition);


    function canTransferFrom(address _from, address _to, uint256 _value, bytes calldata _data) external view returns (byte statusCode, bytes32 reasonCode);


    function setDocument(bytes32 _name, string calldata _uri, bytes32 _documentHash) external;


    function removeDocument(bytes32 _name) external;


    function getDocument(bytes32 _name) external view returns (string memory documentUri, bytes32 documentHash, uint256 documentTime);


    function getAllDocuments() external view returns (bytes32[] memory documentNames);


    function isControllable() external view returns (bool controlled);


    function isModule(address _module, uint8 _type) external view returns(bool isValid);


    function issue(address _tokenHolder, uint256 _value, bytes calldata _data) external;


    function issueMulti(address[] calldata _tokenHolders, uint256[] calldata _values) external;


    function issueByPartition(bytes32 _partition, address _tokenHolder, uint256 _value, bytes calldata _data) external;


    function redeemByPartition(bytes32 _partition, uint256 _value, bytes calldata _data) external;


    function redeem(uint256 _value, bytes calldata _data) external;


    function redeemFrom(address _tokenHolder, uint256 _value, bytes calldata _data) external;


    function operatorRedeemByPartition(
        bytes32 _partition,
        address _tokenHolder,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _operatorData
    ) external;


    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool hasPermission);


    function getModule(address _module) external view returns (bytes32 moduleName, address moduleAddress, address factoryAddress, bool isArchived, uint8[] memory moduleTypes, bytes32 moduleLabel);


    function getModulesByName(bytes32 _name) external view returns(address[] memory modules);


    function getModulesByType(uint8 _type) external view returns(address[] memory modules);


    function getTreasuryWallet() external view returns(address treasuryWallet);


    function totalSupplyAt(uint256 _checkpointId) external view returns(uint256 supply);


    function balanceOfAt(address _investor, uint256 _checkpointId) external view returns(uint256 balance);


    function createCheckpoint() external returns(uint256 checkpointId);


    function getCheckpointTimes() external view returns(uint256[] memory checkpointTimes);


    function getInvestors() external view returns(address[] memory investors);


    function getInvestorsAt(uint256 _checkpointId) external view returns(address[] memory investors);


    function getInvestorsSubsetAt(uint256 _checkpointId, uint256 _start, uint256 _end) external view returns(address[] memory investors);


    function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[] memory investors);


    function currentCheckpointId() external view returns(uint256 checkpointId);


    function isOperator(address _operator, address _tokenHolder) external view returns (bool isValid);


    function isOperatorForPartition(bytes32 _partition, address _operator, address _tokenHolder) external view returns (bool isValid);


    function partitionsOf(address _tokenHolder) external view returns (bytes32[] memory partitions);


    function dataStore() external view returns (address dataStoreAddress);


    function changeDataStore(address _dataStore) external;



    function changeTreasuryWallet(address _wallet) external;


    function withdrawERC20(address _tokenContract, uint256 _value) external;


    function changeModuleBudget(address _module, uint256 _change, bool _increase) external;


    function updateTokenDetails(string calldata _newTokenDetails) external;


    function changeName(string calldata _name) external;


    function changeGranularity(uint256 _granularity) external;


    function freezeTransfers() external;


    function unfreezeTransfers() external;


    function freezeIssuance(bytes calldata _signature) external;


    function addModuleWithLabel(
        address _moduleFactory,
        bytes calldata _data,
        uint256 _maxCost,
        uint256 _budget,
        bytes32 _label,
        bool _archived
    ) external;


    function addModule(address _moduleFactory, bytes calldata _data, uint256 _maxCost, uint256 _budget, bool _archived) external;


    function archiveModule(address _module) external;


    function unarchiveModule(address _module) external;


    function removeModule(address _module) external;


    function setController(address _controller) external;


    function controllerTransfer(address _from, address _to, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external;


    function controllerRedeem(address _tokenHolder, uint256 _value, bytes calldata _data, bytes calldata _operatorData) external;


    function disableController(bytes calldata _signature) external;


    function getVersion() external view returns(uint8[] memory version);


    function getInvestorCount() external view returns(uint256 investorCount);


    function holderCount() external view returns(uint256 count);


    function transferWithData(address _to, uint256 _value, bytes calldata _data) external;


    function transferFromWithData(address _from, address _to, uint256 _value, bytes calldata _data) external;


    function transferByPartition(bytes32 _partition, address _to, uint256 _value, bytes calldata _data) external returns (bytes32 partition);


    function balanceOfByPartition(bytes32 _partition, address _tokenHolder) external view returns(uint256 balance);


    function granularity() external view returns(uint256 granularityAmount);


    function polymathRegistry() external view returns(address registryAddress);


    function upgradeModule(address _module) external;


    function upgradeToken() external;


    function isIssuable() external view returns (bool issuable);


    function authorizeOperator(address _operator) external;


    function revokeOperator(address _operator) external;


    function authorizeOperatorByPartition(bytes32 _partition, address _operator) external;


    function revokeOperatorByPartition(bytes32 _partition, address _operator) external;


    function operatorTransferByPartition(
        bytes32 _partition,
        address _from,
        address _to,
        uint256 _value,
        bytes calldata _data,
        bytes calldata _operatorData
    )
        external
        returns (bytes32 partition);


    function transfersFrozen() external view returns (bool isFrozen);


    function transferOwnership(address newOwner) external;


    function isOwner() external view returns (bool);


    function owner() external view returns (address ownerAddress);


    function controller() external view returns(address controllerAddress);


    function moduleRegistry() external view returns(address moduleRegistryAddress);


    function securityTokenRegistry() external view returns(address securityTokenRegistryAddress);


    function polyToken() external view returns(address polyTokenAddress);


    function tokenFactory() external view returns(address tokenFactoryAddress);


    function getterDelegate() external view returns(address delegate);


    function controllerDisabled() external view returns(bool isDisabled);


    function initialized() external view returns(bool isInitialized);


    function tokenDetails() external view returns(string memory details);


    function updateFromRegistry() external;


}

interface ICheckPermission {

    function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns(bool hasPerm);

}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);


    function transferFrom(address from, address to, uint256 value) external returns (bool);


    function totalSupply() external view returns (uint256);


    function balanceOf(address who) external view returns (uint256);


    function allowance(address owner, address spender) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ModuleStorage {

    address public factory;

    ISecurityToken public securityToken;

    bytes32 public constant ADMIN = "ADMIN";
    bytes32 public constant OPERATOR = "OPERATOR";

    bytes32 internal constant TREASURY = 0xaae8817359f3dcb67d050f44f3e49f982e0359d90ca4b5f18569926304aaece6; // keccak256(abi.encodePacked("TREASURY_WALLET"))

    IERC20 public polyToken;

    constructor(address _securityToken, address _polyAddress) public {
        securityToken = ISecurityToken(_securityToken);
        factory = msg.sender;
        polyToken = IERC20(_polyAddress);
    }

}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract Module is IModule, ModuleStorage, Pausable {

    constructor (address _securityToken, address _polyAddress) public
    ModuleStorage(_securityToken, _polyAddress)
    {
    }

    modifier withPerm(bytes32 _perm) {

        require(_checkPerm(_perm, msg.sender), "Invalid permission");
        _;
    }

    function _checkPerm(bytes32 _perm, address _caller) internal view returns (bool) {

        bool isOwner = _caller == Ownable(address(securityToken)).owner();
        bool isFactory = _caller == factory;
        return isOwner || isFactory || ICheckPermission(address(securityToken)).checkPermission(_caller, address(this), _perm);
    }

    function _onlySecurityTokenOwner() internal view {

        require(msg.sender == Ownable(address(securityToken)).owner(), "Sender is not owner");
    }

    modifier onlyFactory() {

        require(msg.sender == factory, "Sender is not factory");
        _;
    }

    function pause() public {

        _onlySecurityTokenOwner();
        super._pause();
    }

    function unpause() public {

        _onlySecurityTokenOwner();
        super._unpause();
    }

    function getDataStore() public view returns(IDataStore) {

        return IDataStore(securityToken.dataStore());
    }

    function reclaimERC20(address _tokenContract) external {

        _onlySecurityTokenOwner();
        require(_tokenContract != address(0), "Invalid address");
        IERC20 token = IERC20(_tokenContract);
        uint256 balance = token.balanceOf(address(this));
        require(token.transfer(msg.sender, balance), "Transfer failed");
    }

    function reclaimETH() external {

        _onlySecurityTokenOwner();
        msg.sender.transfer(address(this).balance);
    }
}

interface ICheckpoint {


}

contract VotingCheckpointStorage {


    mapping(address => uint256) defaultExemptIndex;
    address[] defaultExemptedVoters;

}

contract VotingCheckpoint is VotingCheckpointStorage, ICheckpoint, IVoting, Module {


    event ChangedDefaultExemptedVotersList(address indexed _voter, bool _exempt);

    function changeDefaultExemptedVotersList(address _voter, bool _exempt) external withPerm(ADMIN) {

        _changeDefaultExemptedVotersList(_voter, _exempt);
    }

    function changeDefaultExemptedVotersListMulti(address[] calldata _voters, bool[] calldata _exempts) external withPerm(ADMIN) {

        require(_voters.length == _exempts.length, "Array length mismatch");
        for (uint256 i = 0; i < _voters.length; i++) {
            _changeDefaultExemptedVotersList(_voters[i], _exempts[i]);
        }
    }

    function _changeDefaultExemptedVotersList(address _voter, bool _exempt) internal {

        require(_voter != address(0), "Invalid address");
        require((defaultExemptIndex[_voter] == 0) == _exempt);
        if (_exempt) {
            defaultExemptedVoters.push(_voter);
            defaultExemptIndex[_voter] = defaultExemptedVoters.length;
        } else {
            if (defaultExemptedVoters.length != defaultExemptIndex[_voter]) {
                defaultExemptedVoters[defaultExemptIndex[_voter] - 1] = defaultExemptedVoters[defaultExemptedVoters.length - 1];
                defaultExemptIndex[defaultExemptedVoters[defaultExemptIndex[_voter] - 1]] = defaultExemptIndex[_voter];
            }
            delete defaultExemptIndex[_voter];
            defaultExemptedVoters.length --;
        }
        emit ChangedDefaultExemptedVotersList(_voter, _exempt);
    }

    function getDefaultExemptionVotersList() external view returns(address[] memory) {

        return defaultExemptedVoters;
    }
}

contract PLCRVotingCheckpointStorage {


    enum Stage { PREP, COMMIT, REVEAL, RESOLVED }

    struct Ballot {
        uint256 checkpointId; // Checkpoint At which ballot created
        uint256 quorum;       // Should be a multiple of 10 ** 16
        uint64 commitDuration; // no. of seconds the commit stage will live
        uint64 revealDuration; // no. of seconds the reveal stage will live
        uint64 startTime;       // Timestamp at which ballot will come into effect
        uint24 totalProposals;  // Count of proposals allowed for a given ballot
        uint32 totalVoters;     // Count of voters who vote for the given ballot
        bool isActive;          // flag used to turn off/on the ballot
        mapping(uint256 => uint256) proposalToVotes; // Mapping for proposal to total weight collected by the proposal
        mapping(address => Vote) investorToProposal; // mapping for storing vote details of a voter
        mapping(address => bool) exemptedVoters; // Mapping for blacklist voters
    }

    struct Vote {
        uint256 voteOption;
        bytes32 secretVote;
    }

    Ballot[] ballots;
}

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

        require(b > 0);
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

contract PLCRVotingCheckpoint is PLCRVotingCheckpointStorage, VotingCheckpoint {


    using SafeMath for uint256;

    event VoteCommit(address indexed _voter, uint256 _weight, uint256 indexed _ballotId, bytes32 _secretVote);
    event VoteRevealed(
        address indexed _voter,
        uint256 _weight,
        uint256 indexed _ballotId,
        uint256 _choiceOfProposal,
        uint256 _salt,
        bytes32 _secretVote
    );
    event BallotCreated(
        uint256 indexed _ballotId,
        uint256 indexed _checkpointId,
        uint256 _startTime,
        uint256 _commitDuration,
        uint256 _revealDuration,
        uint256 _noOfProposals,
        uint256 _quorumPercentage
    );
    event BallotStatusChanged(uint256 indexed _ballotId, bool _newStatus);
    event ChangedBallotExemptedVotersList(uint256 indexed _ballotId, address indexed _voter, bool _exempt);

    constructor(address _securityToken, address _polyAddress)
    public
    Module(_securityToken, _polyAddress)
    {

    }

    function createBallot(
        uint256 _commitDuration,
        uint256 _revealDuration,
        uint256 _noOfProposals,
        uint256 _quorumPercentage
    )   
        external
        withPerm(ADMIN)
    {

        uint256 startTime = now;
        uint256 checkpointId = securityToken.createCheckpoint();
        _createBallotWithCheckpoint(_commitDuration, _revealDuration, _noOfProposals, _quorumPercentage, checkpointId, startTime);
    }

    function createCustomBallot(
        uint256 _commitDuration,
        uint256 _revealDuration,
        uint256 _noOfProposals,
        uint256 _quorumPercentage,
        uint256 _checkpointId,
        uint256 _startTime
    )
        external
        withPerm(ADMIN)
    {

        require(_checkpointId <= securityToken.currentCheckpointId(), "Invalid checkpoint Id");
        _createBallotWithCheckpoint(_commitDuration, _revealDuration, _noOfProposals, _quorumPercentage, _checkpointId, _startTime);
    }

    function _createBallotWithCheckpoint(
        uint256 _commitDuration,
        uint256 _revealDuration,
        uint256 _noOfProposals,
        uint256 _quorumPercentage,
        uint256 _checkpointId,
        uint256 _startTime
    )
        internal
    {

        _isGreaterThanZero(_commitDuration);
        _isGreaterThanZero(_revealDuration);
        _isGreaterThanZero(_quorumPercentage);
        require(_quorumPercentage <= 100 * 10 ** 16, "Invalid quorum percentage"); // not more than 100 %
        require(
            uint64(_commitDuration) == _commitDuration &&
            uint64(_revealDuration) == _revealDuration &&
            uint64(_startTime) == _startTime &&
            uint24(_noOfProposals) == _noOfProposals,
            "Parameter values get overflowed"
        );
        require(_startTime >= now, "Invalid start time");
        require(_noOfProposals > 1, "Invalid number of proposals");
        uint256 _ballotId = ballots.length;
        ballots.push(Ballot(
            _checkpointId,
            _quorumPercentage,
            uint64(_commitDuration),
            uint64(_revealDuration),
            uint64(_startTime),
            uint24(_noOfProposals),
            uint32(0),
            true
        ));
        emit BallotCreated(_ballotId, _checkpointId, _startTime, _commitDuration, _revealDuration, _noOfProposals, _quorumPercentage);
    }

    function commitVote(uint256 _ballotId, bytes32 _secretVote) external {

        _checkIndexOutOfBound(_ballotId);
        require(_secretVote != bytes32(0), "Invalid vote");
        _checkValidStage(_ballotId, Stage.COMMIT);
        require(isVoterAllowed(_ballotId, msg.sender), "Invalid voter");
        Ballot storage ballot = ballots[_ballotId];
        require(ballot.investorToProposal[msg.sender].secretVote == bytes32(0), "Already voted");
        require(ballot.isActive, "Inactive ballot");
        uint256 weight = securityToken.balanceOfAt(msg.sender, ballot.checkpointId);
        require(weight > 0, "Zero weight is not allowed");
        ballot.investorToProposal[msg.sender] = Vote(0, _secretVote);
        emit VoteCommit(msg.sender, weight, _ballotId, _secretVote);
    }

    function revealVote(uint256 _ballotId, uint256 _choiceOfProposal, uint256 _salt) external {

        _checkIndexOutOfBound(_ballotId);
        _checkValidStage(_ballotId, Stage.REVEAL);
        Ballot storage ballot = ballots[_ballotId];
        require(ballot.isActive, "Inactive ballot");
        require(ballot.investorToProposal[msg.sender].secretVote != bytes32(0), "Secret vote not available");
        require(ballot.totalProposals >= _choiceOfProposal && _choiceOfProposal > 0, "Invalid proposal choice");

        require(
            bytes32(keccak256(abi.encodePacked(_choiceOfProposal, _salt))) == ballot.investorToProposal[msg.sender].secretVote,
            "Invalid vote"
        );
        uint256 weight = securityToken.balanceOfAt(msg.sender, ballot.checkpointId);
        bytes32 secretVote = ballot.investorToProposal[msg.sender].secretVote;
        ballot.proposalToVotes[_choiceOfProposal] = ballot.proposalToVotes[_choiceOfProposal].add(weight);
        ballot.totalVoters = ballot.totalVoters + 1;
        ballot.investorToProposal[msg.sender] = Vote(_choiceOfProposal, bytes32(0));
        emit VoteRevealed(msg.sender, weight, _ballotId, _choiceOfProposal, _salt, secretVote);
    }

    function changeBallotExemptedVotersList(uint256 _ballotId, address _voter, bool _exempt) external withPerm(ADMIN) {

        _changeBallotExemptedVotersList(_ballotId, _voter, _exempt);
    }

    function changeBallotExemptedVotersListMulti(uint256 _ballotId, address[] calldata _voters, bool[] calldata _exempts) external withPerm(ADMIN) {

        require(_voters.length == _exempts.length, "Array length mismatch");
        for (uint256 i = 0; i < _voters.length; i++) {
            _changeBallotExemptedVotersList(_ballotId, _voters[i], _exempts[i]);
        }
    }

    function _changeBallotExemptedVotersList(uint256 _ballotId, address _voter, bool _exempt) internal {

        _checkIndexOutOfBound(_ballotId);
        require(_voter != address(0), "Invalid address");
        require(ballots[_ballotId].exemptedVoters[_voter] != _exempt, "No change");
        ballots[_ballotId].exemptedVoters[_voter] = _exempt;
        emit ChangedBallotExemptedVotersList(_ballotId, _voter, _exempt);
    }

    function isVoterAllowed(uint256 _ballotId, address _voter) public view returns(bool) {

        bool allowed = (ballots[_ballotId].exemptedVoters[_voter] || (defaultExemptIndex[_voter] != 0));
        return !allowed;
    }

    function changeBallotStatus(uint256 _ballotId, bool _isActive) external withPerm(ADMIN) {

        _checkIndexOutOfBound(_ballotId);
        require(
            now <= uint256(ballots[_ballotId].startTime)
            .add(uint256(ballots[_ballotId].commitDuration)
            .add(uint256(ballots[_ballotId].revealDuration))),
            "Already ended"
        );
        require(ballots[_ballotId].isActive != _isActive, "Active state unchanged");
        ballots[_ballotId].isActive = _isActive;
        emit BallotStatusChanged(_ballotId, _isActive);
    }

    function getCurrentBallotStage(uint256 _ballotId) public view returns (Stage) {

        Ballot memory ballot = ballots[_ballotId];
        uint256 commitTimeEnd = uint256(ballot.startTime).add(uint256(ballot.commitDuration));
        uint256 revealTimeEnd = commitTimeEnd.add(uint256(ballot.revealDuration));

        if (now < ballot.startTime)
            return Stage.PREP;
        else if (now >= ballot.startTime && now <= commitTimeEnd) 
            return Stage.COMMIT;
        else if ( now > commitTimeEnd && now <= revealTimeEnd)
            return Stage.REVEAL;
        else if (now > revealTimeEnd)
            return Stage.RESOLVED;
    }

    function getBallotResults(uint256 _ballotId) external view returns(
        uint256[] memory voteWeighting,
        uint256[] memory tieWith,
        uint256 winningProposal,
        bool isVotingSucceed,
        uint256 totalVotes
    ) {

        if (_ballotId >= ballots.length)
            return (new uint256[](0), new uint256[](0), 0, false, 0);

        Ballot storage ballot = ballots[_ballotId];
        uint256 i = 0;
        uint256 counter = 0;
        uint256 maxWeight = 0;
        uint256 supplyAtCheckpoint = securityToken.totalSupplyAt(ballot.checkpointId);
        uint256 quorumWeight = (supplyAtCheckpoint.mul(ballot.quorum)).div(10 ** 18);
        voteWeighting = new uint256[](ballot.totalProposals);
        for (i = 0; i < ballot.totalProposals; i++) {
            voteWeighting[i] = ballot.proposalToVotes[i + 1];
            if (maxWeight < ballot.proposalToVotes[i + 1]) {
                maxWeight = ballot.proposalToVotes[i + 1];
                if (maxWeight >= quorumWeight)
                    winningProposal = i + 1;
            }
        }
        if (maxWeight >= quorumWeight) {
            isVotingSucceed = true;
            for (i = 0; i < ballot.totalProposals; i++) {
                if (maxWeight == ballot.proposalToVotes[i + 1] && (i + 1) != winningProposal)
                    counter ++;
            }
        }

        tieWith = new uint256[](counter);
        if (counter > 0) {
            counter = 0;
            for (i = 0; i < ballot.totalProposals; i++) {
                if (maxWeight == ballot.proposalToVotes[i + 1] && (i + 1) != winningProposal) {
                    tieWith[counter] = i + 1;
                    counter ++;
                }
            }
        }
        totalVotes = uint256(ballot.totalVoters);
    }

    function getSelectedProposal(uint256 _ballotId, address _voter) external view returns(uint256 proposalId) {

        if (_ballotId >= ballots.length)
            return 0;
        return (ballots[_ballotId].investorToProposal[_voter].voteOption);
    }

    function getBallotDetails(uint256 _ballotId) external view returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, bool) {

        Ballot memory ballot = ballots[_ballotId];
        return (
            ballot.quorum,
            securityToken.totalSupplyAt(ballot.checkpointId),
            ballot.checkpointId,
            ballot.startTime,
            (uint256(ballot.startTime).add(uint256(ballot.commitDuration))).add(uint256(ballot.revealDuration)),
            ballot.totalProposals,
            ballot.totalVoters,
            ballot.isActive
        );
    }

    function getBallotCommitRevealDuration(uint256 _ballotId) external view returns(uint256, uint256) {

        Ballot memory ballot = ballots[_ballotId];
        return (
            ballot.commitDuration,
            ballot.revealDuration
        );
    }

    function getInitFunction() external pure returns(bytes4) {

        return bytes4(0);
    }

    function getPermissions() external view returns(bytes32[] memory) {

        bytes32[] memory allPermissions = new bytes32[](1);
        allPermissions[0] = ADMIN;
        return allPermissions;
    }

    function _isGreaterThanZero(uint256 _value) internal pure {

        require(_value > 0, "Invalid value");
    }

    function _checkIndexOutOfBound(uint256 _ballotId) internal view {

        require(ballots.length > _ballotId, "Index out of bound");
    }

    function _checkValidStage(uint256 _ballotId, Stage _stage) internal view {

        require(getCurrentBallotStage(_ballotId) == _stage, "Not in a valid stage");
    }

}