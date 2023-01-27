pragma solidity ^0.6.11;

interface IFactRegistry {

    function isValid(bytes32 fact)
        external view
        returns(bool);

}
pragma solidity ^0.6.11;

contract GovernanceStorage {


    struct GovernanceInfoStruct {
        mapping (address => bool) effectiveGovernors;
        address candidateGovernor;
        bool initialized;
    }

    mapping (string => GovernanceInfoStruct) internal governanceInfo;
}
pragma solidity ^0.6.11;


contract ProxyStorage is GovernanceStorage {


    mapping (address => bytes32) internal initializationHash;

    mapping (address => uint256) internal enabledTime;

    mapping (bytes32 => bool) internal initialized;
}
pragma solidity ^0.6.11;

library Addresses {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function performEthTransfer(address recipient, uint256 amount) internal {

        (bool success, ) = recipient.call{value: amount}(""); // NOLINT: low-level-calls.
        require(success, "ETH_TRANSFER_FAILED");
    }

    function safeTokenContractCall(address tokenAddress, bytes memory callData) internal {

        require(isContract(tokenAddress), "BAD_TOKEN_ADDRESS");
        (bool success, bytes memory returndata) = tokenAddress.call(callData);
        require(success, string(returndata));

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "TOKEN_OPERATION_FAILED");
        }
    }

    function uncheckedTokenContractCall(address tokenAddress, bytes memory callData) internal {

        (bool success, bytes memory returndata) = tokenAddress.call(callData);
        require(success, string(returndata));
    }

}

library UintArray {

    function hashSubArray(uint256[] memory array, uint256 subArrayStart, uint256 subArraySize)
        internal pure
        returns(bytes32 subArrayHash)
    {

        require(array.length >= subArrayStart + subArraySize, "ILLEGAL_SUBARRAY_DIMENSIONS");
        uint256 startOffsetBytes = 0x20 * (1 + subArrayStart);
        uint256 dataSizeBytes = 0x20 * subArraySize;
        assembly {
            subArrayHash := keccak256(add(array, startOffsetBytes), dataSizeBytes)
        }
    }

    function extractSerializedUintArray(uint256[] memory programOutput, uint256 offset)
        internal pure
        returns (uint256[] memory addr)
    {

        uint256 memOffset = 0x20 * (offset + 1);
        assembly {
            addr := add(programOutput, memOffset)
        }
    }

}

library StarkExTypes {


    struct ApprovalChainData {
        address[] list;
        mapping (address => uint256) unlockedForRemovalTime;
    }
}
pragma solidity ^0.6.11;

contract MainStorage is ProxyStorage {


    uint256 constant internal LAYOUT_LENGTH = 2**64;

    IFactRegistry escapeVerifier_;

    bool stateFrozen;                               // NOLINT: constable-states.

    uint256 unFreezeTime;                           // NOLINT: constable-states.

    mapping (uint256 => mapping (uint256 => mapping (uint256 => uint256))) pendingDeposits;

    mapping (uint256 => mapping (uint256 => mapping (uint256 => uint256))) cancellationRequests;

    mapping (uint256 => mapping (uint256 => uint256)) pendingWithdrawals;

    mapping (uint256 => bool) escapesUsed;

    uint256 escapesUsedCount;                       // NOLINT: constable-states.

    mapping (uint256 => mapping (uint256 => uint256)) fullWithdrawalRequests_DEPRECATED;

    uint256 sequenceNumber;                         // NOLINT: constable-states uninitialized-state.

    uint256 vaultRoot;                              // NOLINT: constable-states uninitialized-state.
    uint256 vaultTreeHeight;                        // NOLINT: constable-states uninitialized-state.

    uint256 orderRoot;                              // NOLINT: constable-states uninitialized-state.
    uint256 orderTreeHeight;                        // NOLINT: constable-states uninitialized-state.

    mapping (address => bool) tokenAdmins;

    mapping (address => bool) userAdmins;

    mapping (address => bool) operators;

    mapping (uint256 => bytes) assetTypeToAssetInfo;    // NOLINT: uninitialized-state.

    mapping (uint256 => bool) registeredAssetType;      // NOLINT: uninitialized-state.

    mapping (uint256 => uint256) assetTypeToQuantum;    // NOLINT: uninitialized-state.

    mapping (address => uint256) starkKeys_DEPRECATED;  // NOLINT: naming-convention.

    mapping (uint256 => address) ethKeys;               // NOLINT: uninitialized-state.

    StarkExTypes.ApprovalChainData verifiersChain;
    StarkExTypes.ApprovalChainData availabilityVerifiersChain;

    uint256 lastBatchId;                            // NOLINT: constable-states uninitialized-state.

    mapping(uint256 => address) subContracts;       // NOLINT: uninitialized-state.

    mapping (uint256 => bool) permissiveAssetType_DEPRECATED; // NOLINT: naming-convention.

    uint256 onchainDataVersion;                     // NOLINT: constable-states uninitialized-state.

    mapping(uint256 => uint256) forcedRequestsInBlock;

    mapping(bytes32 => uint256) forcedActionRequests;

    mapping (bytes32 => uint256) actionsTimeLock;

    uint256[LAYOUT_LENGTH - 36] private __endGap;  // __endGap complements layout to LAYOUT_LENGTH.
}
pragma solidity ^0.6.11;

interface Identity {


    function identify()
        external pure
        returns(string memory);

}
pragma solidity ^0.6.11;


interface SubContractor is Identity {


    function initialize(bytes calldata data)
        external;


    function initializerSize()
        external view
        returns(uint256);

}
pragma solidity ^0.6.11;

abstract contract IDispatcherBase {

    function getSubContract(bytes4 selector) internal view virtual returns (address);

    function setSubContractAddress(uint256 index, address subContract) internal virtual;

    function getNumSubcontracts() internal pure virtual returns (uint256);

    function validateSubContractIndex(uint256 index, address subContract) internal pure virtual;

    function initializationSentinel() internal view virtual;
}
pragma solidity ^0.6.11;

contract StorageSlots {

    function implementation() public view returns(address _implementation) {

        bytes32 slot = IMPLEMENTATION_SLOT;
        assembly {
            _implementation := sload(slot)
        }
    }

    bytes32 internal constant IMPLEMENTATION_SLOT =
    0x177667240aeeea7e35eabe3a35e18306f336219e1386f7710a6bf8783f761b24;

    bytes32 internal constant CALL_PROXY_IMPL_SLOT =
    0x7184681641399eb4ad2fdb92114857ee6ff239f94ad635a1779978947b8843be;

    bytes32 internal constant FINALIZED_STATE_SLOT =
    0x7d433c6f837e8f93009937c466c82efbb5ba621fae36886d0cac433c5d0aa7d2;

    bytes32 public constant UPGRADE_DELAY_SLOT =
    0xc21dbb3089fcb2c4f4c6a67854ab4db2b0f233ea4b21b21f912d52d18fc5db1f;

    bytes32 public constant MAIN_DISPATCHER_SAFEGUARD_SLOT =
    0xf3afa5472f846c7817e22b15110d7b184f2d3d6417baee645a1e963b8fac7e24;
}
pragma solidity ^0.6.11;


abstract contract MainDispatcherBase is IDispatcherBase, StorageSlots {

    using Addresses for address;

    constructor( ) internal {
        bytes32 slot = MAIN_DISPATCHER_SAFEGUARD_SLOT;
        assembly {
            sstore(slot, 42)
        }
    }

    modifier notCalledDirectly() {
        { // Prevent too many local variables in stack.
            uint256 safeGuardValue;
            bytes32 slot = MAIN_DISPATCHER_SAFEGUARD_SLOT;
            assembly {
                safeGuardValue := sload(slot)
            }
            require(safeGuardValue == 0, "DIRECT_CALL_DISALLOWED");
        }
        _;
    }

    fallback() external payable { //NOLINT locked-ether.
        address subContractAddress = getSubContract(msg.sig);
        require(subContractAddress != address(0x0), "NO_CONTRACT_FOR_FUNCTION");

        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), subContractAddress, 0, calldatasize(), 0, 0)

            returndatacopy(0, 0, returndatasize())

            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    function initialize(bytes memory data) public virtual
        notCalledDirectly()
    {
        uint256 nSubContracts = getNumSubcontracts();

        require(nSubContracts <= 15, "TOO_MANY_SUB_CONTRACTS");

        require(data.length >= 32 * (nSubContracts + 1), "SUB_CONTRACTS_NOT_PROVIDED");

        require(implementation().isContract(), "INVALID_IMPLEMENTATION");

        uint256 additionalDataSize = data.length - 32 * (nSubContracts + 1);

        uint256 totalInitSizes = 0;

        uint256 initDataContractsOffset = 32 * (nSubContracts + 1);

        for (uint256 nContract = 1; nContract <= nSubContracts; nContract++) {
            address contractAddress;

            assembly {
                contractAddress := mload(add(data, mul(32, nContract)))
            }

            validateSubContractIndex(nContract, contractAddress);

            setSubContractAddress(nContract, contractAddress);
        }

        address externalInitializerAddr;

        assembly {
            externalInitializerAddr := mload(add(data, mul(32, add(nSubContracts, 1))))
        }

        if (externalInitializerAddr != address(0x0)) {
            callExternalInitializer(data, externalInitializerAddr, additionalDataSize);
            return;
        }

        if (additionalDataSize == 0) {
            return;
        }

        assert(externalInitializerAddr == address(0x0));

        initializationSentinel();

        for (uint256 nContract = 1; nContract <= nSubContracts; nContract++) {
            address contractAddress;

            assembly {
                contractAddress := mload(add(data, mul(32, nContract)))
            }

            (bool success, bytes memory returndata) = contractAddress.delegatecall(
                abi.encodeWithSelector(SubContractor(contractAddress).initializerSize.selector));
            require(success, string(returndata));
            uint256 initSize = abi.decode(returndata, (uint256));
            require(initSize <= additionalDataSize, "INVALID_INITIALIZER_SIZE");
            require(totalInitSizes + initSize <= additionalDataSize, "INVALID_INITIALIZER_SIZE");

            if (initSize == 0) {
                continue;
            }

            bytes memory subContractInitData = new bytes(initSize);
            for (uint256 trgOffset = 32; trgOffset <= initSize; trgOffset += 32) {
                assembly {
                    mstore(
                        add(subContractInitData, trgOffset),
                        mload(add(add(data, trgOffset), initDataContractsOffset))
                    )
                }
            }

            (success, returndata) = contractAddress.delegatecall(
                abi.encodeWithSelector(this.initialize.selector, subContractInitData)
            );
            require(success, string(returndata));
            totalInitSizes += initSize;
            initDataContractsOffset += initSize;
        }
        require(
            additionalDataSize == totalInitSizes,
            "MISMATCHING_INIT_DATA_SIZE");
    }

    function callExternalInitializer(
        bytes memory data,
        address externalInitializerAddr,
        uint256 dataSize)
        private {
        require(externalInitializerAddr.isContract(), "NOT_A_CONTRACT");
        require(dataSize <= data.length, "INVALID_DATA_SIZE");
        bytes memory extInitData = new bytes(dataSize);

        uint256 srcDataOffset = 32 + data.length - dataSize;
        uint256 srcData;
        uint256 trgData;

        assembly {
            srcData := add(data, srcDataOffset)
            trgData := add(extInitData, 32)
        }

        for (uint256 seek = 0; seek < dataSize; seek += 32) {
            assembly {
                mstore(
                    add(trgData, seek),
                    mload(add(srcData, seek))
                )
            }
        }

        (bool success, bytes memory returndata) = externalInitializerAddr.delegatecall(
            abi.encodeWithSelector(this.initialize.selector, extInitData)
        );
        require(success, string(returndata));
        require(returndata.length == 0, string(returndata));
    }
}
pragma solidity ^0.6.11;


abstract contract MainDispatcher is MainStorage, MainDispatcherBase {

    uint256 constant SUBCONTRACT_BITS = 4;

    function magicSalt() internal pure virtual returns(uint256);
    function handlerMapSection(uint256 section) internal view virtual returns(uint256);
    function expectedIdByIndex(uint256 index) internal pure virtual returns (string memory id);

    function validateSubContractIndex(uint256 index, address subContract) internal pure override {
        string memory id = SubContractor(subContract).identify();
        bytes32 hashed_expected_id = keccak256(abi.encodePacked(expectedIdByIndex(index)));
        require(
            hashed_expected_id == keccak256(abi.encodePacked(id)),
            "MISPLACED_INDEX_OR_BAD_CONTRACT_ID"
        );
    }

    function getSubContract(bytes4 selector) internal view override returns (address) {
        uint256 location = 0xFF & uint256(keccak256(abi.encodePacked(selector, magicSalt())));
        uint256 subContractIdx;
        uint256 offset = (SUBCONTRACT_BITS * location) % 256;

        subContractIdx = (handlerMapSection(location >> 6) >> offset) & 0xF;
        return subContracts[subContractIdx];
    }

    function setSubContractAddress(uint256 index, address subContractAddress) internal override {
        subContracts[index] = subContractAddress;
    }
}
pragma solidity ^0.6.11;


contract PerpetualStorage is MainStorage {

    uint256 systemAssetType;                       // NOLINT: constable-states uninitialized-state.

    bytes32 public globalConfigurationHash;        // NOLINT: constable-states uninitialized-state.

    mapping(uint256 => bytes32) public configurationHash; // NOLINT: uninitialized-state.

    bytes32 sharedStateHash;                       // NOLINT: constable-states uninitialized-state.

    uint256 public configurationDelay;             // NOLINT: constable-states.

    uint256[LAYOUT_LENGTH - 5] private __endGap;  // __endGap complements layout to LAYOUT_LENGTH.
}
pragma solidity ^0.6.11;


contract StarkPerpetual is MainDispatcher, PerpetualStorage {

    string public constant VERSION = "1.0.0";

    uint256 constant MAGIC_SALT = 15691;
    uint256 constant IDX_MAP_0 = 0x3000000002000200000000000220022100000102300010000030103200010000;
    uint256 constant IDX_MAP_1 = 0x1410000000002200200000002003321010000210132000020000;
    uint256 constant IDX_MAP_2 = 0x3031200400000004003320020000000012022120020030000003000020;
    uint256 constant IDX_MAP_3 = 0x100200003000100000000000000320000410000003000030000101210000000;

    function getNumSubcontracts() internal pure override returns (uint256) {

        return 4;
    }

    function magicSalt() internal pure override returns(uint256) {

        return MAGIC_SALT;
    }

    function handlerMapSection(uint256 section) internal view override returns(uint256) {

        if(section == 0) {
            return IDX_MAP_0;
        }
        else if(section == 1) {
            return IDX_MAP_1;
        }
        else if(section == 2) {
            return IDX_MAP_2;
        }
        else if(section == 3) {
            return IDX_MAP_3;
        }
        revert("BAD_IDX_MAP_SECTION");
    }

    function expectedIdByIndex(uint256 index)
        internal pure override returns (string memory id) {

        if (index == 1){
            id = "StarkWare_AllVerifiers_2020_1";
        } else if (index == 2){
            id = "StarkWare_PerpetualTokensAndRamping_2020_1";
        } else if (index == 3){
            id = "StarkWare_PerpetualState_2020_1";
        } else if (index == 4){
            id = "StarkWare_PerpetualForcedActions_2020_1";
        } else {
            revert("UNEXPECTED_INDEX");
        }
    }

    function initializationSentinel() internal view override {

        string memory REVERT_MSG = "INITIALIZATION_BLOCKED";
        require(int(sharedStateHash) == 0, REVERT_MSG);
        require(int(globalConfigurationHash) == 0, REVERT_MSG);
        require(systemAssetType == 0, REVERT_MSG);
    }
}
