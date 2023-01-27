
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library ECDSA {

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        if (signature.length != 65) {
            revert("ECDSA: invalid signature length");
        }

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(signature, 0x20))
            s := mload(add(signature, 0x40))
            v := byte(0, mload(add(signature, 0x60)))
        }

        return recover(hash, v, r, s);
    }

    function recover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) internal pure returns (address) {

        require(uint256(s) <= 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0, "ECDSA: invalid signature 's' value");
        require(v == 27 || v == 28, "ECDSA: invalid signature 'v' value");

        address signer = ecrecover(hash, v, r, s);
        require(signer != address(0), "ECDSA: invalid signature");

        return signer;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }
}// MIT

pragma solidity >=0.6.12 <0.8.0;

interface IController {

    function getGovernor() external view returns (address);



    function setContractProxy(bytes32 _id, address _contractAddress) external;


    function unsetContractProxy(bytes32 _id) external;


    function updateController(bytes32 _id, address _controller) external;


    function getContractProxy(bytes32 _id) external view returns (address);



    function setPartialPaused(bool _partialPaused) external;


    function setPaused(bool _paused) external;


    function setPauseGuardian(address _newPauseGuardian) external;


    function paused() external view returns (bool);


    function partialPaused() external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.7.3;


interface IGraphCurationToken is IERC20 {

    function burnFrom(address _account, uint256 _amount) external;


    function mint(address _to, uint256 _amount) external;

}// MIT

pragma solidity ^0.7.3;


interface ICuration {


    struct CurationPool {
        uint256 tokens; // GRT Tokens stored as reserves for the subgraph deployment
        uint32 reserveRatio; // Ratio for the bonding curve
        IGraphCurationToken gcs; // Curation token contract for this curation pool
    }


    function setDefaultReserveRatio(uint32 _defaultReserveRatio) external;


    function setMinimumCurationDeposit(uint256 _minimumCurationDeposit) external;


    function setCurationTaxPercentage(uint32 _percentage) external;



    function mint(
        bytes32 _subgraphDeploymentID,
        uint256 _tokensIn,
        uint256 _signalOutMin
    ) external returns (uint256, uint256);


    function burn(
        bytes32 _subgraphDeploymentID,
        uint256 _signalIn,
        uint256 _tokensOutMin
    ) external returns (uint256);


    function collect(bytes32 _subgraphDeploymentID, uint256 _tokens) external;



    function isCurated(bytes32 _subgraphDeploymentID) external view returns (bool);


    function getCuratorSignal(address _curator, bytes32 _subgraphDeploymentID)
        external
        view
        returns (uint256);


    function getCurationPoolSignal(bytes32 _subgraphDeploymentID) external view returns (uint256);


    function getCurationPoolTokens(bytes32 _subgraphDeploymentID) external view returns (uint256);


    function tokensToSignal(bytes32 _subgraphDeploymentID, uint256 _tokensIn)
        external
        view
        returns (uint256, uint256);


    function signalToTokens(bytes32 _subgraphDeploymentID, uint256 _signalIn)
        external
        view
        returns (uint256);


    function curationTaxPercentage() external view returns (uint32);

}// MIT

pragma solidity ^0.7.3;

interface IEpochManager {


    function setEpochLength(uint256 _epochLength) external;



    function runEpoch() external;



    function isCurrentEpochRun() external view returns (bool);


    function blockNum() external view returns (uint256);


    function blockHash(uint256 _block) external view returns (bytes32);


    function currentEpoch() external view returns (uint256);


    function currentEpochBlock() external view returns (uint256);


    function currentEpochBlockSinceStart() external view returns (uint256);


    function epochsSince(uint256 _epoch) external view returns (uint256);


    function epochsSinceUpdate() external view returns (uint256);

}// MIT

pragma solidity ^0.7.3;

interface IRewardsManager {

    struct Subgraph {
        uint256 accRewardsForSubgraph;
        uint256 accRewardsForSubgraphSnapshot;
        uint256 accRewardsPerSignalSnapshot;
        uint256 accRewardsPerAllocatedToken;
    }


    function setIssuanceRate(uint256 _issuanceRate) external;



    function setSubgraphAvailabilityOracle(address _subgraphAvailabilityOracle) external;


    function setDenied(bytes32 _subgraphDeploymentID, bool _deny) external;


    function setDeniedMany(bytes32[] calldata _subgraphDeploymentID, bool[] calldata _deny)
        external;


    function isDenied(bytes32 _subgraphDeploymentID) external view returns (bool);



    function getNewRewardsPerSignal() external view returns (uint256);


    function getAccRewardsPerSignal() external view returns (uint256);


    function getAccRewardsForSubgraph(bytes32 _subgraphDeploymentID)
        external
        view
        returns (uint256);


    function getAccRewardsPerAllocatedToken(bytes32 _subgraphDeploymentID)
        external
        view
        returns (uint256, uint256);


    function getRewards(address _allocationID) external view returns (uint256);



    function updateAccRewardsPerSignal() external returns (uint256);


    function takeRewards(address _allocationID) external returns (uint256);



    function onSubgraphSignalUpdate(bytes32 _subgraphDeploymentID) external returns (uint256);


    function onSubgraphAllocationUpdate(bytes32 _subgraphDeploymentID) external returns (uint256);

}// MIT

pragma solidity >=0.6.12 <0.8.0;

interface IStakingData {

    struct Allocation {
        address indexer;
        bytes32 subgraphDeploymentID;
        uint256 tokens; // Tokens allocated to a SubgraphDeployment
        uint256 createdAtEpoch; // Epoch when it was created
        uint256 closedAtEpoch; // Epoch when it was closed
        uint256 collectedFees; // Collected fees for the allocation
        uint256 effectiveAllocation; // Effective allocation when closed
        uint256 accRewardsPerAllocatedToken; // Snapshot used for reward calc
    }

    struct CloseAllocationRequest {
        address allocationID;
        bytes32 poi;
    }


    struct DelegationPool {
        uint32 cooldownBlocks; // Blocks to wait before updating parameters
        uint32 indexingRewardCut; // in PPM
        uint32 queryFeeCut; // in PPM
        uint256 updatedAtBlock; // Block when the pool was last updated
        uint256 tokens; // Total tokens as pool reserves
        uint256 shares; // Total shares minted in the pool
        mapping(address => Delegation) delegators; // Mapping of delegator => Delegation
    }

    struct Delegation {
        uint256 shares; // Shares owned by a delegator in the pool
        uint256 tokensLocked; // Tokens locked for undelegation
        uint256 tokensLockedUntil; // Block when locked tokens can be withdrawn
    }
}// MIT

pragma solidity >=0.6.12 <0.8.0;
pragma experimental ABIEncoderV2;


interface IStaking is IStakingData {


    enum AllocationState { Null, Active, Closed, Finalized, Claimed }


    function setMinimumIndexerStake(uint256 _minimumIndexerStake) external;


    function setThawingPeriod(uint32 _thawingPeriod) external;


    function setCurationPercentage(uint32 _percentage) external;


    function setProtocolPercentage(uint32 _percentage) external;


    function setChannelDisputeEpochs(uint32 _channelDisputeEpochs) external;


    function setMaxAllocationEpochs(uint32 _maxAllocationEpochs) external;


    function setRebateRatio(uint32 _alphaNumerator, uint32 _alphaDenominator) external;


    function setDelegationRatio(uint32 _delegationRatio) external;


    function setDelegationParameters(
        uint32 _indexingRewardCut,
        uint32 _queryFeeCut,
        uint32 _cooldownBlocks
    ) external;


    function setDelegationParametersCooldown(uint32 _blocks) external;


    function setDelegationUnbondingPeriod(uint32 _delegationUnbondingPeriod) external;


    function setDelegationTaxPercentage(uint32 _percentage) external;


    function setSlasher(address _slasher, bool _allowed) external;


    function setAssetHolder(address _assetHolder, bool _allowed) external;



    function setOperator(address _operator, bool _allowed) external;


    function isOperator(address _operator, address _indexer) external view returns (bool);



    function stake(uint256 _tokens) external;


    function stakeTo(address _indexer, uint256 _tokens) external;


    function unstake(uint256 _tokens) external;


    function slash(
        address _indexer,
        uint256 _tokens,
        uint256 _reward,
        address _beneficiary
    ) external;


    function withdraw() external;


    function setRewardsDestination(address _destination) external;



    function delegate(address _indexer, uint256 _tokens) external returns (uint256);


    function undelegate(address _indexer, uint256 _shares) external returns (uint256);


    function withdrawDelegated(address _indexer, address _newIndexer) external returns (uint256);



    function allocate(
        bytes32 _subgraphDeploymentID,
        uint256 _tokens,
        address _allocationID,
        bytes32 _metadata,
        bytes calldata _proof
    ) external;


    function allocateFrom(
        address _indexer,
        bytes32 _subgraphDeploymentID,
        uint256 _tokens,
        address _allocationID,
        bytes32 _metadata,
        bytes calldata _proof
    ) external;


    function closeAllocation(address _allocationID, bytes32 _poi) external;


    function closeAllocationMany(CloseAllocationRequest[] calldata _requests) external;


    function closeAndAllocate(
        address _oldAllocationID,
        bytes32 _poi,
        address _indexer,
        bytes32 _subgraphDeploymentID,
        uint256 _tokens,
        address _allocationID,
        bytes32 _metadata,
        bytes calldata _proof
    ) external;


    function collect(uint256 _tokens, address _allocationID) external;


    function claim(address _allocationID, bool _restake) external;


    function claimMany(address[] calldata _allocationID, bool _restake) external;



    function hasStake(address _indexer) external view returns (bool);


    function getIndexerStakedTokens(address _indexer) external view returns (uint256);


    function getIndexerCapacity(address _indexer) external view returns (uint256);


    function getAllocation(address _allocationID) external view returns (Allocation memory);


    function getAllocationState(address _allocationID) external view returns (AllocationState);


    function isAllocation(address _allocationID) external view returns (bool);


    function getSubgraphAllocatedTokens(bytes32 _subgraphDeploymentID)
        external
        view
        returns (uint256);


    function getDelegation(address _indexer, address _delegator)
        external
        view
        returns (Delegation memory);


    function isDelegator(address _indexer, address _delegator) external view returns (bool);

}// MIT

pragma solidity ^0.7.3;


interface IGraphToken is IERC20 {


    function burn(uint256 amount) external;


    function mint(address _to, uint256 _amount) external;



    function addMinter(address _account) external;


    function removeMinter(address _account) external;


    function renounceMinter() external;


    function isMinter(address _account) external view returns (bool);



    function permit(
        address _owner,
        address _spender,
        uint256 _value,
        uint256 _deadline,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) external;

}// MIT

pragma solidity ^0.7.3;



contract Managed {


    IController public controller;
    mapping(bytes32 => address) private addressCache;
    uint256[10] private __gap;


    event ParameterUpdated(string param);
    event SetController(address controller);

    event ContractSynced(bytes32 indexed nameHash, address contractAddress);


    function _notPartialPaused() internal view {

        require(!controller.paused(), "Paused");
        require(!controller.partialPaused(), "Partial-paused");
    }

    function _notPaused() internal view {

        require(!controller.paused(), "Paused");
    }

    function _onlyGovernor() internal view {

        require(msg.sender == controller.getGovernor(), "Caller must be Controller governor");
    }

    function _onlyController() internal view {

        require(msg.sender == address(controller), "Caller must be Controller");
    }

    modifier notPartialPaused {

        _notPartialPaused();
        _;
    }

    modifier notPaused {

        _notPaused();
        _;
    }

    modifier onlyController() {

        _onlyController();
        _;
    }

    modifier onlyGovernor() {

        _onlyGovernor();
        _;
    }


    function _initialize(address _controller) internal {

        _setController(_controller);
    }

    function setController(address _controller) external onlyController {

        _setController(_controller);
    }

    function _setController(address _controller) internal {

        require(_controller != address(0), "Controller must be set");
        controller = IController(_controller);
        emit SetController(_controller);
    }

    function curation() internal view returns (ICuration) {

        return ICuration(_resolveContract(keccak256("Curation")));
    }

    function epochManager() internal view returns (IEpochManager) {

        return IEpochManager(_resolveContract(keccak256("EpochManager")));
    }

    function rewardsManager() internal view returns (IRewardsManager) {

        return IRewardsManager(_resolveContract(keccak256("RewardsManager")));
    }

    function staking() internal view returns (IStaking) {

        return IStaking(_resolveContract(keccak256("Staking")));
    }

    function graphToken() internal view returns (IGraphToken) {

        return IGraphToken(_resolveContract(keccak256("GraphToken")));
    }

    function _resolveContract(bytes32 _nameHash) internal view returns (address) {

        address contractAddress = addressCache[_nameHash];
        if (contractAddress == address(0)) {
            contractAddress = controller.getContractProxy(_nameHash);
        }
        return contractAddress;
    }

    function _syncContract(string memory _name) internal {

        bytes32 nameHash = keccak256(abi.encodePacked(_name));
        address contractAddress = controller.getContractProxy(nameHash);
        if (addressCache[nameHash] != contractAddress) {
            addressCache[nameHash] = contractAddress;
            emit ContractSynced(nameHash, contractAddress);
        }
    }

    function syncAllContracts() external {

        _syncContract("Curation");
        _syncContract("EpochManager");
        _syncContract("RewardsManager");
        _syncContract("Staking");
        _syncContract("GraphToken");
    }
}// MIT

pragma solidity ^0.7.3;

interface IGraphProxy {

    function admin() external returns (address);


    function setAdmin(address _newAdmin) external;


    function implementation() external returns (address);


    function pendingImplementation() external returns (address);


    function upgradeTo(address _newImplementation) external;


    function acceptUpgrade() external;


    function acceptUpgradeAndCall(bytes calldata data) external;

}// MIT

pragma solidity ^0.7.3;


contract GraphUpgradeable {

    bytes32
        internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    modifier onlyProxyAdmin(IGraphProxy _proxy) {

        require(msg.sender == _proxy.admin(), "Caller must be the proxy admin");
        _;
    }

    modifier onlyImpl {

        require(msg.sender == _implementation(), "Caller must be the implementation");
        _;
    }

    function _implementation() internal view returns (address impl) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            impl := sload(slot)
        }
    }

    function acceptProxy(IGraphProxy _proxy) external onlyProxyAdmin(_proxy) {

        _proxy.acceptUpgrade();
    }

    function acceptProxyAndCall(IGraphProxy _proxy, bytes calldata _data)
        external
        onlyProxyAdmin(_proxy)
    {

        _proxy.acceptUpgradeAndCall(_data);
    }
}// MIT

pragma solidity ^0.7.3;


library TokenUtils {

    function pullTokens(
        IGraphToken _graphToken,
        address _from,
        uint256 _amount
    ) internal {

        if (_amount > 0) {
            require(_graphToken.transferFrom(_from, address(this), _amount), "!transfer");
        }
    }

    function pushTokens(
        IGraphToken _graphToken,
        address _to,
        uint256 _amount
    ) internal {

        if (_amount > 0) {
            require(_graphToken.transfer(_to, _amount), "!transfer");
        }
    }

    function burnTokens(IGraphToken _graphToken, uint256 _amount) internal {

        if (_amount > 0) {
            _graphToken.burn(_amount);
        }
    }
}// MIT

pragma solidity ^0.7.3;

interface IDisputeManager {


    enum DisputeType { Null, IndexingDispute, QueryDispute }

    struct Dispute {
        address indexer;
        address fisherman;
        uint256 deposit;
        bytes32 relatedDisputeID;
        DisputeType disputeType;
    }


    struct Receipt {
        bytes32 requestCID;
        bytes32 responseCID;
        bytes32 subgraphDeploymentID;
    }

    struct Attestation {
        bytes32 requestCID;
        bytes32 responseCID;
        bytes32 subgraphDeploymentID;
        bytes32 r;
        bytes32 s;
        uint8 v;
    }


    function setArbitrator(address _arbitrator) external;


    function setMinimumDeposit(uint256 _minimumDeposit) external;


    function setFishermanRewardPercentage(uint32 _percentage) external;


    function setSlashingPercentage(uint32 _qryPercentage, uint32 _idxPercentage) external;



    function isDisputeCreated(bytes32 _disputeID) external view returns (bool);


    function encodeHashReceipt(Receipt memory _receipt) external view returns (bytes32);


    function areConflictingAttestations(
        Attestation memory _attestation1,
        Attestation memory _attestation2
    ) external pure returns (bool);


    function getAttestationIndexer(Attestation memory _attestation) external view returns (address);



    function createQueryDispute(bytes calldata _attestationData, uint256 _deposit)
        external
        returns (bytes32);


    function createQueryDisputeConflict(
        bytes calldata _attestationData1,
        bytes calldata _attestationData2
    ) external returns (bytes32, bytes32);


    function createIndexingDispute(address _allocationID, uint256 _deposit)
        external
        returns (bytes32);


    function acceptDispute(bytes32 _disputeID) external;


    function rejectDispute(bytes32 _disputeID) external;


    function drawDispute(bytes32 _disputeID) external;

}// MIT

pragma solidity ^0.7.3;



contract DisputeManagerV1Storage is Managed {


    bytes32 internal DOMAIN_SEPARATOR;

    address public arbitrator;

    uint256 public minimumDeposit;

    uint32 public fishermanRewardPercentage;

    uint32 public qrySlashingPercentage;
    uint32 public idxSlashingPercentage;

    mapping(bytes32 => IDisputeManager.Dispute) public disputes;
}// MIT

pragma solidity ^0.7.3;




contract DisputeManager is DisputeManagerV1Storage, GraphUpgradeable, IDisputeManager {

    using SafeMath for uint256;


    bytes32 private constant DOMAIN_TYPE_HASH =
        keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract,bytes32 salt)"
        );
    bytes32 private constant DOMAIN_NAME_HASH = keccak256("Graph Protocol");
    bytes32 private constant DOMAIN_VERSION_HASH = keccak256("0");
    bytes32 private constant DOMAIN_SALT =
        0xa070ffb1cd7409649bf77822cce74495468e06dbfaef09556838bf188679b9c2;
    bytes32 private constant RECEIPT_TYPE_HASH =
        keccak256("Receipt(bytes32 requestCID,bytes32 responseCID,bytes32 subgraphDeploymentID)");


    uint256 private constant ATTESTATION_SIZE_BYTES = RECEIPT_SIZE_BYTES + SIG_SIZE_BYTES;
    uint256 private constant RECEIPT_SIZE_BYTES = 96;

    uint256 private constant SIG_R_LENGTH = 32;
    uint256 private constant SIG_S_LENGTH = 32;
    uint256 private constant SIG_V_LENGTH = 1;
    uint256 private constant SIG_R_OFFSET = RECEIPT_SIZE_BYTES;
    uint256 private constant SIG_S_OFFSET = RECEIPT_SIZE_BYTES + SIG_R_LENGTH;
    uint256 private constant SIG_V_OFFSET = RECEIPT_SIZE_BYTES + SIG_R_LENGTH + SIG_S_LENGTH;
    uint256 private constant SIG_SIZE_BYTES = SIG_R_LENGTH + SIG_S_LENGTH + SIG_V_LENGTH;

    uint256 private constant UINT8_BYTE_LENGTH = 1;
    uint256 private constant BYTES32_BYTE_LENGTH = 32;

    uint256 private constant MAX_PPM = 1000000; // 100% in parts per million


    event QueryDisputeCreated(
        bytes32 indexed disputeID,
        address indexed indexer,
        address indexed fisherman,
        uint256 tokens,
        bytes32 subgraphDeploymentID,
        bytes attestation
    );

    event IndexingDisputeCreated(
        bytes32 indexed disputeID,
        address indexed indexer,
        address indexed fisherman,
        uint256 tokens,
        address allocationID
    );

    event DisputeAccepted(
        bytes32 indexed disputeID,
        address indexed indexer,
        address indexed fisherman,
        uint256 tokens
    );

    event DisputeRejected(
        bytes32 indexed disputeID,
        address indexed indexer,
        address indexed fisherman,
        uint256 tokens
    );

    event DisputeDrawn(
        bytes32 indexed disputeID,
        address indexed indexer,
        address indexed fisherman,
        uint256 tokens
    );

    event DisputeLinked(bytes32 indexed disputeID1, bytes32 indexed disputeID2);


    function _onlyArbitrator() internal view {

        require(msg.sender == arbitrator, "Caller is not the Arbitrator");
    }

    modifier onlyArbitrator {

        _onlyArbitrator();
        _;
    }


    function initialize(
        address _controller,
        address _arbitrator,
        uint256 _minimumDeposit,
        uint32 _fishermanRewardPercentage,
        uint32 _qrySlashingPercentage,
        uint32 _idxSlashingPercentage
    ) external onlyImpl {

        Managed._initialize(_controller);

        _setArbitrator(_arbitrator);
        _setMinimumDeposit(_minimumDeposit);
        _setFishermanRewardPercentage(_fishermanRewardPercentage);
        _setSlashingPercentage(_qrySlashingPercentage, _idxSlashingPercentage);

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                DOMAIN_TYPE_HASH,
                DOMAIN_NAME_HASH,
                DOMAIN_VERSION_HASH,
                _getChainID(),
                address(this),
                DOMAIN_SALT
            )
        );
    }

    function setArbitrator(address _arbitrator) external override onlyGovernor {

        _setArbitrator(_arbitrator);
    }

    function _setArbitrator(address _arbitrator) private {

        require(_arbitrator != address(0), "Arbitrator must be set");
        arbitrator = _arbitrator;
        emit ParameterUpdated("arbitrator");
    }

    function setMinimumDeposit(uint256 _minimumDeposit) external override onlyGovernor {

        _setMinimumDeposit(_minimumDeposit);
    }

    function _setMinimumDeposit(uint256 _minimumDeposit) private {

        require(_minimumDeposit > 0, "Minimum deposit must be set");
        minimumDeposit = _minimumDeposit;
        emit ParameterUpdated("minimumDeposit");
    }

    function setFishermanRewardPercentage(uint32 _percentage) external override onlyGovernor {

        _setFishermanRewardPercentage(_percentage);
    }

    function _setFishermanRewardPercentage(uint32 _percentage) private {

        require(_percentage <= MAX_PPM, "Reward percentage must be below or equal to MAX_PPM");
        fishermanRewardPercentage = _percentage;
        emit ParameterUpdated("fishermanRewardPercentage");
    }

    function setSlashingPercentage(uint32 _qryPercentage, uint32 _idxPercentage)
        external
        override
        onlyGovernor
    {

        _setSlashingPercentage(_qryPercentage, _idxPercentage);
    }

    function _setSlashingPercentage(uint32 _qryPercentage, uint32 _idxPercentage) private {

        require(
            _qryPercentage <= MAX_PPM && _idxPercentage <= MAX_PPM,
            "Slashing percentage must be below or equal to MAX_PPM"
        );
        qrySlashingPercentage = _qryPercentage;
        idxSlashingPercentage = _idxPercentage;
        emit ParameterUpdated("qrySlashingPercentage");
        emit ParameterUpdated("idxSlashingPercentage");
    }

    function isDisputeCreated(bytes32 _disputeID) public view override returns (bool) {

        return disputes[_disputeID].fisherman != address(0);
    }

    function encodeHashReceipt(Receipt memory _receipt) public view override returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01", // EIP-191 encoding pad, EIP-712 version 1
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            RECEIPT_TYPE_HASH,
                            _receipt.requestCID,
                            _receipt.responseCID,
                            _receipt.subgraphDeploymentID
                        ) // EIP 712-encoded message hash
                    )
                )
            );
    }

    function areConflictingAttestations(
        Attestation memory _attestation1,
        Attestation memory _attestation2
    ) public pure override returns (bool) {

        return (_attestation1.requestCID == _attestation2.requestCID &&
            _attestation1.subgraphDeploymentID == _attestation2.subgraphDeploymentID &&
            _attestation1.responseCID != _attestation2.responseCID);
    }

    function getAttestationIndexer(Attestation memory _attestation)
        public
        view
        override
        returns (address)
    {

        address allocationID = _recoverAttestationSigner(_attestation);

        IStaking.Allocation memory alloc = staking().getAllocation(allocationID);
        require(alloc.indexer != address(0), "Indexer cannot be found for the attestation");
        require(
            alloc.subgraphDeploymentID == _attestation.subgraphDeploymentID,
            "Allocation and attestation subgraphDeploymentID must match"
        );
        return alloc.indexer;
    }

    function createQueryDispute(bytes calldata _attestationData, uint256 _deposit)
        external
        override
        returns (bytes32)
    {

        _pullSubmitterDeposit(_deposit);

        return
            _createQueryDisputeWithAttestation(
                msg.sender,
                _deposit,
                _parseAttestation(_attestationData),
                _attestationData
            );
    }

    function createQueryDisputeConflict(
        bytes calldata _attestationData1,
        bytes calldata _attestationData2
    ) external override returns (bytes32, bytes32) {

        address fisherman = msg.sender;

        Attestation memory attestation1 = _parseAttestation(_attestationData1);
        Attestation memory attestation2 = _parseAttestation(_attestationData2);

        require(
            areConflictingAttestations(attestation1, attestation2),
            "Attestations must be in conflict"
        );

        bytes32 dID1 =
            _createQueryDisputeWithAttestation(fisherman, 0, attestation1, _attestationData1);
        bytes32 dID2 =
            _createQueryDisputeWithAttestation(fisherman, 0, attestation2, _attestationData2);

        disputes[dID1].relatedDisputeID = dID2;
        disputes[dID2].relatedDisputeID = dID1;

        emit DisputeLinked(dID1, dID2);

        return (dID1, dID2);
    }

    function _createQueryDisputeWithAttestation(
        address _fisherman,
        uint256 _deposit,
        Attestation memory _attestation,
        bytes memory _attestationData
    ) private returns (bytes32) {

        address indexer = getAttestationIndexer(_attestation);

        require(staking().getIndexerStakedTokens(indexer) > 0, "Dispute indexer has no stake");

        bytes32 disputeID =
            keccak256(
                abi.encodePacked(
                    _attestation.requestCID,
                    _attestation.responseCID,
                    _attestation.subgraphDeploymentID,
                    indexer,
                    _fisherman
                )
            );

        require(!isDisputeCreated(disputeID), "Dispute already created");

        disputes[disputeID] = Dispute(
            indexer,
            _fisherman,
            _deposit,
            0, // no related dispute,
            DisputeType.QueryDispute
        );

        emit QueryDisputeCreated(
            disputeID,
            indexer,
            _fisherman,
            _deposit,
            _attestation.subgraphDeploymentID,
            _attestationData
        );

        return disputeID;
    }

    function createIndexingDispute(address _allocationID, uint256 _deposit)
        external
        override
        returns (bytes32)
    {

        _pullSubmitterDeposit(_deposit);

        return _createIndexingDisputeWithAllocation(msg.sender, _deposit, _allocationID);
    }


    function _createIndexingDisputeWithAllocation(
        address _fisherman,
        uint256 _deposit,
        address _allocationID
    ) private returns (bytes32) {

        bytes32 disputeID = keccak256(abi.encodePacked(_allocationID));

        require(!isDisputeCreated(disputeID), "Dispute already created");

        IStaking staking = staking();
        IStaking.Allocation memory alloc = staking.getAllocation(_allocationID);
        require(alloc.indexer != address(0), "Dispute allocation must exist");

        require(staking.getIndexerStakedTokens(alloc.indexer) > 0, "Dispute indexer has no stake");

        disputes[disputeID] = Dispute(
            alloc.indexer,
            _fisherman,
            _deposit,
            0,
            DisputeType.IndexingDispute
        );

        emit IndexingDisputeCreated(disputeID, alloc.indexer, _fisherman, _deposit, _allocationID);

        return disputeID;
    }

    function acceptDispute(bytes32 _disputeID) external override onlyArbitrator {

        Dispute memory dispute = _resolveDispute(_disputeID);

        (, uint256 tokensToReward) =
            _slashIndexer(dispute.indexer, dispute.fisherman, dispute.disputeType);

        TokenUtils.pushTokens(graphToken(), dispute.fisherman, dispute.deposit);

        _resolveDisputeInConflict(dispute);

        emit DisputeAccepted(
            _disputeID,
            dispute.indexer,
            dispute.fisherman,
            dispute.deposit.add(tokensToReward)
        );
    }

    function rejectDispute(bytes32 _disputeID) external override onlyArbitrator {

        Dispute memory dispute = _resolveDispute(_disputeID);

        require(
            !_isDisputeInConflict(dispute),
            "Dispute for conflicting attestation, must accept the related ID to reject"
        );

        TokenUtils.burnTokens(graphToken(), dispute.deposit);

        emit DisputeRejected(_disputeID, dispute.indexer, dispute.fisherman, dispute.deposit);
    }

    function drawDispute(bytes32 _disputeID) external override onlyArbitrator {

        Dispute memory dispute = _resolveDispute(_disputeID);

        TokenUtils.pushTokens(graphToken(), dispute.fisherman, dispute.deposit);

        _resolveDisputeInConflict(dispute);

        emit DisputeDrawn(_disputeID, dispute.indexer, dispute.fisherman, dispute.deposit);
    }

    function _resolveDispute(bytes32 _disputeID) private returns (Dispute memory) {

        require(isDisputeCreated(_disputeID), "Dispute does not exist");

        Dispute memory dispute = disputes[_disputeID];

        delete disputes[_disputeID]; // Re-entrancy

        return dispute;
    }

    function _isDisputeInConflict(Dispute memory _dispute) private pure returns (bool) {

        return _dispute.relatedDisputeID != 0;
    }

    function _resolveDisputeInConflict(Dispute memory _dispute) private returns (bool) {

        if (_isDisputeInConflict(_dispute)) {
            bytes32 relatedDisputeID = _dispute.relatedDisputeID;
            delete disputes[relatedDisputeID];
            return true;
        }
        return false;
    }

    function _pullSubmitterDeposit(uint256 _deposit) private {

        require(_deposit >= minimumDeposit, "Dispute deposit is under minimum required");

        TokenUtils.pullTokens(graphToken(), msg.sender, _deposit);
    }

    function _slashIndexer(
        address _indexer,
        address _challenger,
        DisputeType _disputeType
    ) private returns (uint256 slashAmount, uint256 rewardsAmount) {

        IStaking staking = staking();

        uint256 slashableAmount = staking.getIndexerStakedTokens(_indexer); // slashable tokens

        slashAmount = _getSlashingPercentageForDisputeType(_disputeType).mul(slashableAmount).div(
            MAX_PPM
        );
        require(slashAmount > 0, "Dispute has zero tokens to slash");

        rewardsAmount = uint256(fishermanRewardPercentage).mul(slashAmount).div(MAX_PPM);

        staking.slash(_indexer, slashAmount, rewardsAmount, _challenger);
    }

    function _getSlashingPercentageForDisputeType(DisputeType _disputeType)
        private
        view
        returns (uint256)
    {

        if (_disputeType == DisputeType.QueryDispute) return uint256(qrySlashingPercentage);
        if (_disputeType == DisputeType.IndexingDispute) return uint256(idxSlashingPercentage);
        return 0;
    }

    function _recoverAttestationSigner(Attestation memory _attestation)
        private
        view
        returns (address)
    {

        Receipt memory receipt =
            Receipt(
                _attestation.requestCID,
                _attestation.responseCID,
                _attestation.subgraphDeploymentID
            );
        bytes32 messageHash = encodeHashReceipt(receipt);

        return
            ECDSA.recover(
                messageHash,
                abi.encodePacked(_attestation.r, _attestation.s, _attestation.v)
            );
    }

    function _getChainID() private pure returns (uint256) {

        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    function _parseAttestation(bytes memory _data) private pure returns (Attestation memory) {

        require(_data.length == ATTESTATION_SIZE_BYTES, "Attestation must be 161 bytes long");

        (bytes32 requestCID, bytes32 responseCID, bytes32 subgraphDeploymentID) =
            abi.decode(_data, (bytes32, bytes32, bytes32));

        bytes32 r = _toBytes32(_data, SIG_R_OFFSET);
        bytes32 s = _toBytes32(_data, SIG_S_OFFSET);
        uint8 v = _toUint8(_data, SIG_V_OFFSET);

        return Attestation(requestCID, responseCID, subgraphDeploymentID, r, s, v);
    }

    function _toUint8(bytes memory _bytes, uint256 _start) private pure returns (uint8) {

        require(_bytes.length >= (_start + UINT8_BYTE_LENGTH), "Bytes: out of bounds");
        uint8 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x1), _start))
        }

        return tempUint;
    }

    function _toBytes32(bytes memory _bytes, uint256 _start) private pure returns (bytes32) {

        require(_bytes.length >= (_start + BYTES32_BYTE_LENGTH), "Bytes: out of bounds");
        bytes32 tempBytes32;

        assembly {
            tempBytes32 := mload(add(add(_bytes, 0x20), _start))
        }

        return tempBytes32;
    }
}