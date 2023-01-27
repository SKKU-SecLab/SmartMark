pragma solidity ^0.5.2;

contract IFactRegistry {

    function isValid(bytes32 fact)
        external view
        returns(bool);

}
pragma solidity ^0.5.2;


contract IQueryableFactRegistry is IFactRegistry {


    function hasRegisteredFact()
        external view
        returns(bool);


}
pragma solidity ^0.5.2;

contract Identity {


    function identify()
        external pure
        returns(string memory);

}
pragma solidity ^0.5.2;

contract IECDSA {

    function verify(uint256 msgHash, uint256 r, uint256 s, uint256 pubX, uint256 pubY)
        external;

}
pragma solidity ^0.5.2;

contract GovernanceStorage {


    struct GovernanceInfoStruct {
        mapping (address => bool) effectiveGovernors;
        address candidateGovernor;
        bool initialized;
    }

    mapping (string => GovernanceInfoStruct) internal governanceInfo;
}
pragma solidity ^0.5.2;


contract ProxyStorage is GovernanceStorage {


    mapping (address => bytes32) internal initializationHash;

    mapping (address => uint256) internal enabledTime;

    mapping (bytes32 => bool) internal initialized;
}
pragma solidity ^0.5.2;


contract MainStorage is ProxyStorage {


    struct ApprovalChainData {
        address[] list;
        mapping (address => uint256) unlockedForRemovalTime;
    }

    IFactRegistry escapeVerifier_;

    IECDSA ecdsaContract_;

    bool stateFrozen;

    uint256 unFreezeTime;

    mapping (uint256 => mapping (uint256 => mapping (uint256 => uint256))) pendingDeposits;

    mapping (uint256 => mapping (uint256 => mapping (uint256 => uint256))) cancellationRequests;

    mapping (uint256 => mapping (uint256 => uint256)) pendingWithdrawals;

    mapping (uint256 => bool) escapesUsed;

    uint256 escapesUsedCount;

    mapping (uint256 => mapping (uint256 => uint256)) fullWithdrawalRequests;

    uint256 sequenceNumber;

    uint256 vaultRoot;
    uint256 vaultTreeHeight;

    uint256 orderRoot;
    uint256 orderTreeHeight;

    mapping (address => bool) tokenAdmins;

    mapping (address => bool) userAdmins;

    mapping (address => bool) operators;

    mapping (uint256 => bytes) tokenIdToAssetData;

    mapping (uint256 => bool) registeredTokenId;

    mapping (uint256 => uint256) tokenIdToQuantum;

    mapping (address => uint256) starkKeys;
    mapping (uint256 => address) etherKeys;

    ApprovalChainData verifiersChain;
    ApprovalChainData availabilityVerifiersChain;

    uint256 lastBatchId;
}
pragma solidity ^0.5.2;


contract MApprovalChain is MainStorage {

    uint256 constant ENTRY_NOT_FOUND = uint256(~0);

    function addEntry(
        ApprovalChainData storage chain, address entry, uint256 maxLength, string memory identifier)
        internal;


    function findEntry(address[] storage list, address entry)
        internal view returns (uint256);


    function safeFindEntry(address[] storage list, address entry)
        internal view returns (uint256 idx);


    function announceRemovalIntent(
        ApprovalChainData storage chain, address entry, uint256 removalDelay)
        internal;


    function removeEntry(ApprovalChainData storage chain, address entry)
        internal;


    function verifyFact(
        ApprovalChainData storage chain, bytes32 fact, string memory noVerifiersErrorMessage,
        string memory invalidFactErrorMessage)
        internal view;

}
pragma solidity ^0.5.2;

contract MFreezable {

    modifier notFrozen()
    {

        revert("UNIMPLEMENTED");
        _;
    }

    modifier onlyFrozen()
    {

        revert("UNIMPLEMENTED");
        _;
    }

    function freeze()
        internal;


    function isFrozen()
        external view
        returns (bool);


}
pragma solidity ^0.5.2;

contract MGovernance {

    modifier onlyGovernance()
    {

        revert("UNIMPLEMENTED");
        _;
    }
}
pragma solidity ^0.5.2;

library Addresses {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}

pragma solidity ^0.5.2;


contract ApprovalChain is MainStorage, MApprovalChain, MGovernance, MFreezable {


    using Addresses for address;

    function addEntry(
        ApprovalChainData storage chain, address entry, uint256 maxLength, string memory identifier)
        internal
        onlyGovernance()
        notFrozen()
    {

        address[] storage list = chain.list;
        require(entry.isContract(), "ADDRESS_NOT_CONTRACT");
        bytes32 hash_real = keccak256(abi.encodePacked(Identity(entry).identify()));
        bytes32 hash_identifier = keccak256(abi.encodePacked(identifier));
        require(hash_real == hash_identifier, "UNEXPECTED_CONTRACT_IDENTIFIER");
        require(list.length < maxLength, "CHAIN_AT_MAX_CAPACITY");
        require(findEntry(list, entry) == ENTRY_NOT_FOUND, "ENTRY_ALREADY_EXISTS");

        require(
            list.length == 0 || IQueryableFactRegistry(entry).hasRegisteredFact(),
            "ENTRY_NOT_ENABLED");
        chain.list.push(entry);
        chain.unlockedForRemovalTime[entry] = 0;
    }

    function findEntry(address[] storage list, address entry)
        internal view returns (uint256)
    {

        uint256 n_entries = list.length;
        for (uint256 i = 0; i < n_entries; i++) {
            if (list[i] == entry) {
                return i;
            }
        }

        return ENTRY_NOT_FOUND;
    }


    function safeFindEntry(address[] storage list, address entry)
        internal view returns (uint256 idx)
    {

        idx = findEntry(list, entry);

        require(idx != ENTRY_NOT_FOUND, "ENTRY_DOES_NOT_EXIST");
    }

    function announceRemovalIntent(
        ApprovalChainData storage chain, address entry, uint256 removalDelay)
        internal
        onlyGovernance()
        notFrozen()
    {

        safeFindEntry(chain.list, entry);
        require(now + removalDelay > now, "INVALID_REMOVAL_DELAY");
        chain.unlockedForRemovalTime[entry] = now + removalDelay;
    }


    function removeEntry(ApprovalChainData storage chain, address entry)
        internal
        onlyGovernance()
        notFrozen()
    {

        address[] storage list = chain.list;
        uint256 idx = safeFindEntry(list, entry);
        uint256 unlockedForRemovalTime = chain.unlockedForRemovalTime[entry];

        require(unlockedForRemovalTime > 0, "REMOVAL_NOT_ANNOUNCED");
        require(now >= unlockedForRemovalTime, "REMOVAL_NOT_ENABLED_YET");

        uint256 n_entries = list.length;

        require(n_entries > 1, "LAST_ENTRY_MAY_NOT_BE_REMOVED");

        if (idx != n_entries - 1) {
            list[idx] = list[n_entries - 1];
        }
        list.pop();
    }

    function verifyFact(
        ApprovalChainData storage chain, bytes32 fact, string memory noVerifiersErrorMessage,
        string memory invalidFactErrorMessage)
        internal view
    {

        address[] storage list = chain.list;
        uint256 n_entries = list.length;
        require(n_entries > 0, noVerifiersErrorMessage);
        for (uint256 i = 0; i < n_entries; i++) {
            require(IFactRegistry(list[i]).isValid(fact), invalidFactErrorMessage);
        }
    }
}
pragma solidity ^0.5.2;

contract LibConstants {


    uint256 public constant DEPOSIT_CANCEL_DELAY = 1 days;

    uint256 public constant FREEZE_GRACE_PERIOD = 7 days;

    uint256 public constant UNFREEZE_DELAY = 365 days;

    uint256 public constant MAX_VERIFIER_COUNT = uint256(64);

    uint256 public constant VERIFIER_REMOVAL_DELAY = FREEZE_GRACE_PERIOD + (21 days);

    uint256 constant MAX_VAULT_ID = 2**31 - 1;
    uint256 constant MAX_QUANTUM = 2**128 - 1;

    address constant ZERO_ADDRESS = address(0x0);

    uint256 constant K_MODULUS =
    0x800000000000011000000000000000000000000000000000000000000000001;
    uint256 constant K_BETA =
    0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89;
}
pragma solidity ^0.5.2;


contract AvailabilityVerifiers is MainStorage, MApprovalChain, LibConstants {

    function getRegisteredAvailabilityVerifiers()
        external view
        returns (address[] memory _verifers)
    {

        return availabilityVerifiersChain.list;
    }

    function isAvailabilityVerifier(address verifierAddress)
        external view
        returns (bool)
    {

        return findEntry(availabilityVerifiersChain.list, verifierAddress) != ENTRY_NOT_FOUND;
    }

    function registerAvailabilityVerifier(address verifier, string calldata identifier)
        external
    {

        addEntry(availabilityVerifiersChain, verifier, MAX_VERIFIER_COUNT, identifier);
    }

    function announceAvailabilityVerifierRemovalIntent(address verifier)
        external
    {

        announceRemovalIntent(availabilityVerifiersChain, verifier, VERIFIER_REMOVAL_DELAY);
    }

    function removeAvailabilityVerifier(address verifier)
        external
    {

        removeEntry(availabilityVerifiersChain, verifier);
    }
}
pragma solidity ^0.5.2;


contract Freezable is MainStorage, LibConstants, MGovernance, MFreezable {

    event LogFrozen();
    event LogUnFrozen();

    modifier notFrozen()
    {

        require(!stateFrozen, "STATE_IS_FROZEN");
        _;
    }

    modifier onlyFrozen()
    {

        require(stateFrozen, "STATE_NOT_FROZEN");
        _;
    }

    function isFrozen()
        external view
        returns (bool frozen) {

        frozen = stateFrozen;
    }

    function freeze()
        internal
        notFrozen()
    {

        unFreezeTime = now + UNFREEZE_DELAY;

        stateFrozen = true;

        emit LogFrozen();
    }

    function unFreeze()
        external
        onlyFrozen()
        onlyGovernance()
    {

        require(now >= unFreezeTime, "UNFREEZE_NOT_ALLOWED_YET");

        stateFrozen = false;

        vaultRoot += 1;
        orderRoot += 1;

        emit LogUnFrozen();
    }

}
pragma solidity ^0.5.2;


contract Governance is GovernanceStorage, MGovernance {

    event LogNominatedGovernor(address nominatedGovernor);
    event LogNewGovernorAccepted(address acceptedGovernor);
    event LogRemovedGovernor(address removedGovernor);
    event LogNominationCancelled();

    address internal constant ZERO_ADDRESS = address(0x0);

    function getGovernanceTag()
        internal
        view
        returns (string memory);


    function contractGovernanceInfo()
        internal
        view
        returns (GovernanceInfoStruct storage) {

        string memory tag = getGovernanceTag();
        GovernanceInfoStruct storage gub = governanceInfo[tag];
        require(gub.initialized, "NOT_INITIALIZED");
        return gub;
    }

    function initGovernance()
        internal
    {

        string memory tag = getGovernanceTag();
        GovernanceInfoStruct storage gub = governanceInfo[tag];
        require(!gub.initialized, "ALREADY_INITIALIZED");
        gub.initialized = true;  // to ensure addGovernor() won't fail.
        addGovernor(msg.sender);
    }

    modifier onlyGovernance()
    {

        require(isGovernor(msg.sender), "ONLY_GOVERNANCE");
        _;
    }

    function isGovernor(address testGovernor)
        internal view
        returns (bool addressIsGovernor){

        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        addressIsGovernor = gub.effectiveGovernors[testGovernor];
    }

    function cancelNomination() internal onlyGovernance() {

        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        gub.candidateGovernor = ZERO_ADDRESS;
        emit LogNominationCancelled();
    }

    function nominateNewGovernor(address newGovernor) internal onlyGovernance() {

        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        require(!isGovernor(newGovernor), "ALREADY_GOVERNOR");
        gub.candidateGovernor = newGovernor;
        emit LogNominatedGovernor(newGovernor);
    }

    function addGovernor(address newGovernor) private {

        require(!isGovernor(newGovernor), "ALREADY_GOVERNOR");
        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        gub.effectiveGovernors[newGovernor] = true;
    }

    function acceptGovernance()
        internal
    {

        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        require(msg.sender == gub.candidateGovernor, "ONLY_CANDIDATE_GOVERNOR");

        addGovernor(gub.candidateGovernor);
        gub.candidateGovernor = ZERO_ADDRESS;

        emit LogNewGovernorAccepted(msg.sender);
    }

    function removeGovernor(address governorForRemoval) internal onlyGovernance() {

        require(msg.sender != governorForRemoval, "GOVERNOR_SELF_REMOVE");
        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        require (isGovernor(governorForRemoval), "NOT_GOVERNOR");
        gub.effectiveGovernors[governorForRemoval] = false;
        emit LogRemovedGovernor(governorForRemoval);
    }
}
pragma solidity ^0.5.2;


contract MainGovernance is Governance {


    string public constant MAIN_GOVERNANCE_INFO_TAG = "StarkEx.Main.2019.GovernorsInformation";

    function getGovernanceTag()
        internal
        view
        returns (string memory tag) {

        tag = MAIN_GOVERNANCE_INFO_TAG;
    }

    function mainIsGovernor(address testGovernor) external view returns (bool) {

        return isGovernor(testGovernor);
    }

    function mainNominateNewGovernor(address newGovernor) external {

        nominateNewGovernor(newGovernor);
    }

    function mainRemoveGovernor(address governorForRemoval) external {

        removeGovernor(governorForRemoval);
    }

    function mainAcceptGovernance()
        external
    {

        acceptGovernance();
    }

    function mainCancelNomination() external {

        cancelNomination();
    }

}
pragma solidity ^0.5.2;

contract MOperator {


    modifier onlyOperator()
    {

        revert("UNIMPLEMENTED");
        _;
    }

    function registerOperator(address newOperator)
        external;


    function unregisterOperator(address removedOperator)
        external;


}
pragma solidity ^0.5.2;


contract Operator is MainStorage, MGovernance, MOperator {

    event LogOperatorAdded(address operator);
    event LogOperatorRemoved(address operator);

    function initialize()
        internal
    {

        operators[msg.sender] = true;
        emit LogOperatorAdded(msg.sender);
    }

    modifier onlyOperator()
    {

        require(operators[msg.sender], "ONLY_OPERATOR");
        _;
    }

    function registerOperator(address newOperator)
        external
        onlyGovernance
    {

        operators[newOperator] = true;
        emit LogOperatorAdded(newOperator);
    }

    function unregisterOperator(address removedOperator)
        external
        onlyGovernance
    {

        operators[removedOperator] = false;
        emit LogOperatorRemoved(removedOperator);
    }

    function isOperator(address testedOperator) external view returns (bool) {

        return operators[testedOperator];
    }
}
pragma solidity ^0.5.2;

contract MTokens {

    function toQuantized(
        uint256 tokenId,
        uint256 amount
    )
        internal view
        returns (uint256 quantizedAmount);


    function fromQuantized(
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal view
        returns (uint256 amount);


    function isEther(
        uint256 tokenId)
        internal view returns (bool);


    function transferIn(
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal;


    function transferOut(
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal;

}
pragma solidity ^0.5.2;

interface IERC20 {


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount)
     external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.5.2;


contract Tokens is MainStorage, LibConstants, MGovernance, MTokens {

    bytes4 constant internal ERC20_SELECTOR = bytes4(keccak256("ERC20Token(address)"));
    bytes4 constant internal ETH_SELECTOR = bytes4(keccak256("ETH()"));

    uint256 constant internal SELECTOR_OFFSET = 0x20;
    uint256 constant internal SELECTOR_SIZE = 4;
    uint256 constant internal ERC20_ADDRESS_OFFSET = SELECTOR_OFFSET + SELECTOR_SIZE;


    event LogTokenRegistered(uint256 tokenId, bytes assetData);
    event LogTokenAdminAdded(address tokenAdmin);
    event LogTokenAdminRemoved(address tokenAdmin);

    using Addresses for address;

    modifier onlyTokensAdmin()
    {

        require(tokenAdmins[msg.sender], "ONLY_TOKENS_ADMIN");
        _;
    }

    function registerTokenAdmin(address newAdmin)
        external
        onlyGovernance()
    {

        tokenAdmins[newAdmin] = true;
        emit LogTokenAdminAdded(newAdmin);
    }

    function unregisterTokenAdmin(address oldAdmin)
        external
        onlyGovernance()
    {

        tokenAdmins[oldAdmin] = false;
        emit LogTokenAdminRemoved(oldAdmin);
    }

    function isTokenAdmin(address testedAdmin) external view returns (bool) {

        return tokenAdmins[testedAdmin];
    }

    function safeERC20Call(address tokenAddress, bytes memory callData) internal {

        (bool success, bytes memory returndata) = address(tokenAddress).call(callData);
        require(success, string(returndata));

        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "ERC20_OPERATION_FAILED");
        }
    }


    function extractUint256(bytes memory assetData, uint256 offset)
        internal pure returns (uint256 res)
    {

        assembly {
           res := mload(add(assetData, offset))
        }
    }

    function extractSelector(bytes memory assetData)
        internal pure returns (bytes4 selector)
    {

        assembly {
           selector := and(0xffffffff00000000000000000000000000000000000000000000000000000000,
                           mload(add(assetData, 0x20)))
        }
    }

    function registerToken(
        uint256 tokenId,
        bytes calldata assetData,
        uint256 quantum
    )
        external
        onlyTokensAdmin()
    {

        require(!registeredTokenId[tokenId], "TOKEN_REGISTERED");
        require(tokenId < K_MODULUS, "INVALID_TOKEN_ID");
        require(quantum > 0, "INVALID_QUANTUM");
        require(quantum <= MAX_QUANTUM, "INVALID_QUANTUM");
        require(assetData.length >= SELECTOR_SIZE, "INVALID_ASSET_STRING");

        uint256 enforcedId = uint256(keccak256(abi.encodePacked(assetData, quantum))) &
            0x03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        require(tokenId == enforcedId, "INVALID_TOKEN_ID");

        registeredTokenId[tokenId] = true;
        tokenIdToAssetData[tokenId] = assetData;
        tokenIdToQuantum[tokenId] = quantum;

        bytes4 tokenSelector = extractSelector(assetData);
        if (tokenSelector == ERC20_SELECTOR) {
            require(assetData.length == 0x24, "INVALID_ASSET_STRING");
            address tokenAddress = address(extractUint256(assetData, ERC20_ADDRESS_OFFSET));
            require(tokenAddress.isContract(), "BAD_ERC20_ADDRESS");
        } else if (tokenSelector == ETH_SELECTOR) {
            require(assetData.length == 4, "INVALID_ASSET_STRING");
        } else {
            revert("UNSUPPORTED_TOKEN_TYPE");
        }

        emit LogTokenRegistered(tokenId, assetData);
    }

    function getQuantum(uint256 tokenId)
        public view
        returns (uint256 quantum)
    {

        require(registeredTokenId[tokenId], "TOKEN_UNREGISTERED");

        quantum = tokenIdToQuantum[tokenId];
    }

    function getAssetData(uint256 tokenId)
        public view
        returns (bytes memory assetData)
    {

        require(registeredTokenId[tokenId], "TOKEN_UNREGISTERED");

        assetData = tokenIdToAssetData[tokenId];
    }

    function toQuantized(
        uint256 tokenId,
        uint256 amount
    )
        internal view
        returns (uint256 quantizedAmount)
    {

        uint256 quantum = getQuantum(tokenId);
        require(amount % quantum == 0, "INVALID_AMOUNT");
        quantizedAmount = amount / quantum;
    }

    function fromQuantized(
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal view
        returns (uint256 amount)
    {

        uint256 quantum = getQuantum(tokenId);
        amount = quantizedAmount * quantum;
        require(amount / quantum == quantizedAmount, "DEQUANTIZATION_OVERFLOW");
    }

    function isEther(
        uint256 tokenId)
        internal view returns (bool)
    {

        bytes memory assetData = getAssetData(tokenId);
        bytes4 tokenSelector = extractSelector(assetData);

        return tokenSelector == ETH_SELECTOR;
    }

    function transferIn(
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal
    {

        bytes memory assetData = getAssetData(tokenId);
        uint256 amount = fromQuantized(tokenId, quantizedAmount);

        bytes4 tokenSelector = extractSelector(assetData);
        if (tokenSelector == ERC20_SELECTOR) {
            uint256 tokenAddress = extractUint256(assetData, ERC20_ADDRESS_OFFSET);
            safeERC20Call(
                address(tokenAddress),
                abi.encodeWithSelector(
                IERC20(0).transferFrom.selector, msg.sender, address(this), amount));
        } else if (tokenSelector == ETH_SELECTOR) {
            require(msg.value == amount, "INCORRECT_DEPOSIT_AMOUNT");
        } else {
            revert("UNSUPPORTED_TOKEN_TYPE");
        }
    }

    function transferOut(
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal
    {

        bytes memory assetData = getAssetData(tokenId);
        uint256 amount = fromQuantized(tokenId, quantizedAmount);

        bytes4 tokenSelector = extractSelector(assetData);
        if (tokenSelector == ERC20_SELECTOR) {
            uint256 tokenAddress = extractUint256(assetData, ERC20_ADDRESS_OFFSET);
            safeERC20Call(
                address(tokenAddress),
                abi.encodeWithSelector(IERC20(0).transfer.selector, msg.sender, amount));
        } else if (tokenSelector == ETH_SELECTOR) {
            msg.sender.transfer(amount);
        } else {
            revert("UNSUPPORTED_TOKEN_TYPE");
        }
    }
}
pragma solidity ^0.5.2;

contract MUsers {

    function getStarkKey(
        address etherKey
    )
        public view
        returns (uint256 starkKey);


    function getEtherKey(
        uint256 starkKey
    )
        external view
        returns (address etherKey);

}
pragma solidity ^0.5.2;


contract Users is MainStorage, LibConstants, MGovernance, MUsers {

    event LogUserRegistered(address etherKey, uint256 starkKey);
    event LogUserAdminAdded(address userAdmin);
    event LogUserAdminRemoved(address userAdmin);

    function initialize (
        IECDSA ecdsaContract
    ) internal
    {
        ecdsaContract_ = ecdsaContract;
    }

    function isOnCurve(uint256 starkKey) private view returns (bool) {

        uint256 xCubed = mulmod(mulmod(starkKey, starkKey, K_MODULUS), starkKey, K_MODULUS);
        return isQuadraticResidue(addmod(addmod(xCubed, starkKey, K_MODULUS), K_BETA, K_MODULUS));
    }

    function registerUserAdmin(address newAdmin) external onlyGovernance() {

        userAdmins[newAdmin] = true;
        emit LogUserAdminAdded(newAdmin);
    }

    function unregisterUserAdmin(address oldAdmin) external onlyGovernance() {

        userAdmins[oldAdmin] = false;
        emit LogUserAdminRemoved(oldAdmin);
    }

    function isUserAdmin(address testedAdmin) public view returns (bool) {

        return userAdmins[testedAdmin];
    }

    function register(
        uint256 starkKey, bytes calldata userAdminSignature,
        bytes calldata starkSignature) external {

        address etherKey = msg.sender;
        require(starkKey != 0, "INVALID_STARK_KEY");
        require(starkKeys[etherKey] == 0, "ETHER_KEY_UNAVAILABLE");
        require(etherKeys[starkKey] == ZERO_ADDRESS, "STARK_KEY_UNAVAILABLE");
        require(starkKey < K_MODULUS, "INVALID_STARK_KEY");
        require(isOnCurve(starkKey), "INVALID_STARK_KEY");
        require(userAdminSignature.length == 65, "INVALID_SIGNATURE");
        require(starkSignature.length == 32*3, "INVALID_STARK_SIGNATURE");

        bytes32 keyPairHash = keccak256(abi.encodePacked(etherKey, starkKey));

        {
            bytes memory sig = userAdminSignature;
            uint8 v = uint8(sig[64]);
            bytes32 r;
            bytes32 s;

            assembly {
                r := mload(add(sig, 32))
                s := mload(add(sig, 64))
            }

            address signer = ecrecover(keyPairHash, v, r, s);
            require(isUserAdmin(signer), "INVALID_SIGNATURE");
        }

        bytes32 hashed_message = keccak256(
            abi.encodePacked("\x10starkex_register", etherKey));

        uint256 y;
        uint256 r;
        uint256 s;

        {
            bytes memory sig = starkSignature;
            assembly {
                r := mload(add(sig, 32))
                s := mload(add(sig, 64))
                y := mload(add(sig, 96))
            }
        }

        ecdsaContract_.verify(uint256(hashed_message), r, s, starkKey, y);

        starkKeys[etherKey] = starkKey;
        etherKeys[starkKey] = etherKey;

        emit LogUserRegistered(etherKey, starkKey);
    }

    function getStarkKey(address etherKey) public view returns (uint256 starkKey) {

        starkKey = starkKeys[etherKey];
        require(starkKey != 0, "USER_UNREGISTERED");
    }

    function getEtherKey(uint256 starkKey) external view returns (address etherKey) {

        etherKey = etherKeys[starkKey];
        require(etherKey != ZERO_ADDRESS, "USER_UNREGISTERED");
    }

    function fieldPow(uint256 base, uint256 exponent) internal view returns (uint256) {

        (bool success, bytes memory returndata) = address(5).staticcall(
            abi.encode(0x20, 0x20, 0x20, base, exponent, K_MODULUS)
        );
        require(success, string(returndata));
        return abi.decode(returndata, (uint256));
    }

    function isQuadraticResidue(uint256 fieldElement) private view returns (bool) {

        return 1 == fieldPow(fieldElement, ((K_MODULUS - 1) / 2));
    }
}
pragma solidity ^0.5.2;


contract Verifiers is MainStorage, MApprovalChain, LibConstants {

    function getRegisteredVerifiers()
        external view
        returns (address[] memory _verifers)
    {

        return verifiersChain.list;
    }

    function isVerifier(address verifierAddress)
        external view
        returns (bool)
    {

        return findEntry(verifiersChain.list, verifierAddress) != ENTRY_NOT_FOUND;
    }

    function registerVerifier(address verifier, string calldata identifier)
        external
    {

        addEntry(verifiersChain, verifier, MAX_VERIFIER_COUNT, identifier);
    }

    function announceVerifierRemovalIntent(address verifier)
        external
    {

        announceRemovalIntent(verifiersChain, verifier, VERIFIER_REMOVAL_DELAY);
    }

    function removeVerifier(address verifier)
        external
    {

        removeEntry(verifiersChain, verifier);
    }
}
pragma solidity ^0.5.2;

contract IVerifierActions {


    function updateState(
        uint256[] calldata publicInput,
        uint256[] calldata applicationData
    )
        external;

    function rootUpdate(
        uint256 oldVaultRoot,
        uint256 newVaultRoot,
        uint256 oldOrderRoot,
        uint256 newOrderRoot,
        uint256 vaultTreeHeightSent,
        uint256 orderTreeHeightSent,
        uint256 batchId
    )
        internal;



    function acceptDeposit(
        uint256 starkKey,
        uint256 vaultId,
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal;


    function acceptWithdrawal(
        uint256 starkKey,
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal;


    function clearFullWithdrawalRequest(
        uint256 starkKey,
        uint256 vaultId
    )
        internal;

}
pragma solidity ^0.5.2;


contract Deposits is MainStorage, LibConstants, IVerifierActions, MFreezable, MOperator,
                     MUsers, MTokens {

    event LogDeposit(
        uint256 starkKey,
        uint256 vaultId,
        uint256 tokenId,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount
    );

    event LogDepositCancel(
        uint256 starkKey,
        uint256 vaultId,
        uint256 tokenId
    );

    event LogDepositCancelReclaimed(
        uint256 starkKey,
        uint256 vaultId,
        uint256 tokenId,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount
    );

    function getDepositBalance(
        uint256 starkKey,
        uint256 tokenId,
        uint256 vaultId
    )
        external view
        returns (uint256 balance)
    {

        balance = fromQuantized(tokenId, pendingDeposits[starkKey][tokenId][vaultId]);
    }

    function getQuantizedDepositBalance(
        uint256 starkKey,
        uint256 tokenId,
        uint256 vaultId
    )
        external view
        returns (uint256 balance)
    {

        balance = pendingDeposits[starkKey][tokenId][vaultId];
    }

    function getCancellationRequest(
        uint256 starkKey,
        uint256 tokenId,
        uint256 vaultId
    )
        external view
        returns (uint256 request)
    {

        request = cancellationRequests[starkKey][tokenId][vaultId];
    }

    function deposit(
        uint256 tokenId,
        uint256 vaultId,
        uint256 quantizedAmount
    )
        public
        notFrozen()
    {

        require(vaultId <= MAX_VAULT_ID, "OUT_OF_RANGE_VAULT_ID");

        address user = msg.sender;
        uint256 starkKey = getStarkKey(user);

        pendingDeposits[starkKey][tokenId][vaultId] += quantizedAmount;
        require(pendingDeposits[starkKey][tokenId][vaultId] >= quantizedAmount, "DEPOSIT_OVERFLOW");

        delete cancellationRequests[starkKey][tokenId][vaultId];

        transferIn(tokenId, quantizedAmount);

        emit LogDeposit(
            starkKey, vaultId, tokenId, fromQuantized(tokenId, quantizedAmount), quantizedAmount);
    }

    function deposit(
        uint256 tokenId,
        uint256 vaultId
    )
        external payable
    {

        require(isEther(tokenId), "INVALID_TOKEN_ID");
        deposit(tokenId, vaultId, toQuantized(tokenId, msg.value));
    }


    function depositCancel(uint256 tokenId, uint256 vaultId)
        external
    {

        require(vaultId <= MAX_VAULT_ID, "OUT_OF_RANGE_VAULT_ID");

        address user = msg.sender;
        uint256 starkKey = getStarkKey(user);

        cancellationRequests[starkKey][tokenId][vaultId] = now;

        emit LogDepositCancel(starkKey, vaultId, tokenId);
    }

    function depositReclaim(uint256 tokenId, uint256 vaultId)
        external
    {

        require(vaultId <= MAX_VAULT_ID, "OUT_OF_RANGE_VAULT_ID");

        address user = msg.sender;
        uint256 starkKey = getStarkKey(user);

        uint256 requestTime = cancellationRequests[starkKey][tokenId][vaultId];
        require(requestTime != 0, "DEPOSIT_NOT_CANCELED");
        uint256 freeTime = requestTime + DEPOSIT_CANCEL_DELAY;
        assert(freeTime >= DEPOSIT_CANCEL_DELAY);
        require(now >= freeTime, "DEPOSIT_LOCKED");

        uint256 quantizedAmount = pendingDeposits[starkKey][tokenId][vaultId];
        delete pendingDeposits[starkKey][tokenId][vaultId];
        delete cancellationRequests[starkKey][tokenId][vaultId];

        transferOut(tokenId, quantizedAmount);

        emit LogDepositCancelReclaimed(
            starkKey, vaultId, tokenId, fromQuantized(tokenId, quantizedAmount), quantizedAmount);
    }

    function acceptDeposit(
        uint256 starkKey,
        uint256 vaultId,
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal
    {

        require(
            pendingDeposits[starkKey][tokenId][vaultId] >= quantizedAmount,
            "DEPOSIT_INSUFFICIENT");

        pendingDeposits[starkKey][tokenId][vaultId] -= quantizedAmount;
    }
}
pragma solidity ^0.5.2;

contract MStateRoot {

    function getVaultRoot()
        public view
        returns (uint256 root);


    function getVaultTreeHeight()
        public view
        returns (uint256 height);

}
pragma solidity ^0.5.2;

contract MWithdrawal {

    function allowWithdrawal(
        uint256 starkKey,
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal;


}
pragma solidity ^0.5.2;


contract Escapes is MainStorage, MFreezable, MStateRoot, MWithdrawal {

    function initialize (
        IFactRegistry escapeVerifier
    ) internal
    {
        escapeVerifier_ = escapeVerifier;
    }

    function escape(
        uint256 starkKey,
        uint256 vaultId,
        uint256 tokenId,
        uint256 quantizedAmount
    )
        external
        onlyFrozen()
    {

        require(!escapesUsed[vaultId], "ESCAPE_ALREADY_USED");

        escapesUsed[vaultId] = true;
        escapesUsedCount += 1;

        bytes32 claimHash = keccak256(
            abi.encode(
        starkKey, tokenId, quantizedAmount, getVaultRoot(), getVaultTreeHeight(), vaultId));

        require(escapeVerifier_.isValid(claimHash), "ESCAPE_LACKS_PROOF");

        allowWithdrawal(starkKey, tokenId, quantizedAmount);
    }
}
pragma solidity ^0.5.2;


contract FullWithdrawals is MainStorage, LibConstants, IVerifierActions, MFreezable,
    MOperator, MUsers {


    event LogFullWithdrawalRequest(
        uint256 starkKey,
        uint256 vaultId
    );

    function fullWithdrawalRequest(
        uint256 vaultId
    )
        external
        notFrozen()
    {

        address user = msg.sender;
        uint256 starkKey = getStarkKey(user);

        require(vaultId <= MAX_VAULT_ID, "OUT_OF_RANGE_VAULT_ID");

        fullWithdrawalRequests[starkKey][vaultId] = now;

        emit LogFullWithdrawalRequest(starkKey, vaultId);

        for (uint256 i = 0; i < 22231; i++) {}
    }

    function getFullWithdrawalRequest(
        uint256 starkKey,
        uint256 vaultId
    )
        external view
        returns (uint256 res)
    {

        res = fullWithdrawalRequests[starkKey][vaultId];
    }

    function freezeRequest(
        uint256 vaultId
    )
        external
        notFrozen()
    {

        address user = msg.sender;
        uint256 starkKey = getStarkKey(user);

        require(vaultId <= MAX_VAULT_ID, "OUT_OF_RANGE_VAULT_ID");

        uint256 requestTime = fullWithdrawalRequests[starkKey][vaultId];
        require(requestTime != 0, "FULL_WITHDRAWAL_UNREQUESTED");

        uint256 freezeTime = requestTime + FREEZE_GRACE_PERIOD;
        assert(freezeTime >= FREEZE_GRACE_PERIOD);
        require(now >= freezeTime, "FULL_WITHDRAWAL_PENDING");

        freeze();
    }

    function clearFullWithdrawalRequest(
        uint256 starkKey,
        uint256 vaultId
    )
        internal
    {

        fullWithdrawalRequests[starkKey][vaultId] = 0;
    }
}
pragma solidity ^0.5.2;


contract StateRoot is MainStorage, MFreezable, MStateRoot
{

    event LogRootUpdate(
        uint256 sequenceNumber,
        uint256 batchId,
        uint256 vaultRoot,
        uint256 orderRoot
    );

    function initialize (
        uint256 initialSequenceNumber,
        uint256 initialVaultRoot,
        uint256 initialOrderRoot,
        uint256 initialVaultTreeHeight,
        uint256 initialOrderTreeHeight
    )
        internal
    {
        sequenceNumber = initialSequenceNumber;
        vaultRoot = initialVaultRoot;
        orderRoot = initialOrderRoot;
        vaultTreeHeight = initialVaultTreeHeight;
        orderTreeHeight = initialOrderTreeHeight;
    }

    function getVaultRoot()
        public view
        returns (uint256 root)
    {

        root = vaultRoot;
    }

    function getVaultTreeHeight()
        public view
        returns (uint256 height) {

        height = vaultTreeHeight;
    }

    function getOrderRoot()
        external view
        returns (uint256 root)
    {

        root = orderRoot;
    }

    function getOrderTreeHeight()
        external view
        returns (uint256 height) {

        height = orderTreeHeight;
    }

    function getSequenceNumber()
        external view
        returns (uint256 seq)
    {

        seq = sequenceNumber;
    }

    function getLastBatchId()
        external view
        returns (uint256 batchId)
    {

        batchId = lastBatchId;
    }

    function rootUpdate(
        uint256 oldVaultRoot,
        uint256 newVaultRoot,
        uint256 oldOrderRoot,
        uint256 newOrderRoot,
        uint256 vaultTreeHeightSent,
        uint256 orderTreeHeightSent,
        uint256 batchId
    )
        internal
        notFrozen()
    {

        require(oldVaultRoot == vaultRoot, "VAULT_ROOT_INCORRECT");
        require(oldOrderRoot == orderRoot, "ORDER_ROOT_INCORRECT");

        require(vaultTreeHeight == vaultTreeHeightSent, "VAULT_HEIGHT_INCORRECT");
        require(orderTreeHeight == orderTreeHeightSent, "ORDER_HEIGHT_INCORRECT");

        vaultRoot = newVaultRoot;
        orderRoot = newOrderRoot;
        sequenceNumber = sequenceNumber + 1;
        lastBatchId = batchId;

        emit LogRootUpdate(sequenceNumber, batchId, vaultRoot, orderRoot);
    }
}
pragma solidity ^0.5.2;


contract IDexStatementVerifier {


    function verifyProofAndRegister(
        uint256[] calldata proofParams,
        uint256[] calldata proof,
        uint256[] calldata publicInput
    )
        external;


    function isValid(bytes32 fact)
        external view
        returns(bool);

}
pragma solidity ^0.5.2;

contract PublicInputOffsets {

    uint256 internal constant OFFSET_LOG_BATCH_SIZE = 0;
    uint256 internal constant OFFSET_N_TRANSACTIONS = 1;
    uint256 internal constant OFFSET_GLOBAL_EXPIRATION_TIMESTAMP = 2;
    uint256 internal constant OFFSET_VAULT_INITIAL_ROOT = 3;
    uint256 internal constant OFFSET_VAULT_FINAL_ROOT = 4;
    uint256 internal constant OFFSET_ORDER_INITIAL_ROOT = 5;
    uint256 internal constant OFFSET_ORDER_FINAL_ROOT = 6;
    uint256 internal constant OFFSET_VAULT_TREE_HEIGHT = 7;
    uint256 internal constant OFFSET_ORDER_TREE_HEIGHT = 8;
    uint256 internal constant OFFSET_MODIFICATION_DATA = 9;
    uint256 internal constant APPLICATION_DATA_BATCH_ID_OFFSET = 0;
    uint256 internal constant APPLICATION_DATA_PREVIOUS_BATCH_ID_OFFSET = 1;
    uint256 internal constant APPLICATION_DATA_N_MODIFICATIONS_OFFSET = 2;
    uint256 internal constant APPLICATION_DATA_MODIFICATIONS_OFFSET = 3;

    uint256 internal constant N_WORDS_PER_MODIFICATION = 3;
}
pragma solidity ^0.5.2;


contract UpdateState is
    MApprovalChain,
    LibConstants,
    IVerifierActions,
    MFreezable,
    MOperator,
    PublicInputOffsets
{

    event VerifiedFact(bytes32 factHash);

    function updateState(
        uint256[] calldata publicInput,
        uint256[] calldata applicationData
    )
        external
        notFrozen()
        onlyOperator()
    {

        require(
            publicInput.length >= OFFSET_MODIFICATION_DATA,
            "publicInput does not contain all required fields.");
        require(publicInput[OFFSET_VAULT_FINAL_ROOT] < K_MODULUS, "New vault root >= PRIME.");
        require(publicInput[OFFSET_ORDER_FINAL_ROOT] < K_MODULUS, "New order root >= PRIME.");
        require(
            lastBatchId == 0 ||
            applicationData[APPLICATION_DATA_PREVIOUS_BATCH_ID_OFFSET] == lastBatchId,
            "WRONG_PREVIOUS_BATCH_ID");

        bytes32 publicInputFact = keccak256(abi.encodePacked(publicInput));
        verifyFact(
            verifiersChain, publicInputFact, "NO_STATE_TRANSITION_VERIFIERS",
            "NO_STATE_TRANSITION_PROOF");
        emit VerifiedFact(publicInputFact);

        bytes32 availabilityFact = keccak256(
            abi.encodePacked(
            publicInput[OFFSET_VAULT_FINAL_ROOT], publicInput[OFFSET_VAULT_TREE_HEIGHT],
            publicInput[OFFSET_ORDER_FINAL_ROOT], publicInput[OFFSET_ORDER_TREE_HEIGHT],
            sequenceNumber + 1));
        verifyFact(
            availabilityVerifiersChain, availabilityFact, "NO_AVAILABILITY_VERIFIERS",
            "NO_AVAILABILITY_PROOF");

        performUpdateState(publicInput, applicationData);
    }

    function performUpdateState(
        uint256[] memory publicInput,
        uint256[] memory applicationData
    )
        internal
    {

        rootUpdate(
            publicInput[OFFSET_VAULT_INITIAL_ROOT],
            publicInput[OFFSET_VAULT_FINAL_ROOT],
            publicInput[OFFSET_ORDER_INITIAL_ROOT],
            publicInput[OFFSET_ORDER_FINAL_ROOT],
            publicInput[OFFSET_VAULT_TREE_HEIGHT],
            publicInput[OFFSET_ORDER_TREE_HEIGHT],
            applicationData[APPLICATION_DATA_BATCH_ID_OFFSET]
        );
        sendModifications(publicInput, applicationData);
    }

    function sendModifications(
        uint256[] memory publicInput,
        uint256[] memory applicationData
    ) private {

        require(
            applicationData.length >= APPLICATION_DATA_MODIFICATIONS_OFFSET,
            "applicationData does not contain all required fields.");
        uint256 nModifications = applicationData[APPLICATION_DATA_N_MODIFICATIONS_OFFSET];
        require(
            nModifications == (publicInput.length - OFFSET_MODIFICATION_DATA) / N_WORDS_PER_MODIFICATION,
            "Inconsistent number of modifications.");
        require(
            applicationData.length == nModifications + APPLICATION_DATA_MODIFICATIONS_OFFSET,
            "Inconsistent number of modifications in applicationData and publicInput.");

        for (uint256 i = 0; i < nModifications; i++) {
            uint256 modificationOffset = OFFSET_MODIFICATION_DATA + i * N_WORDS_PER_MODIFICATION;
            uint256 starkKey = publicInput[modificationOffset];
            uint256 requestingKey = applicationData[i + APPLICATION_DATA_MODIFICATIONS_OFFSET];
            uint256 tokenId = publicInput[modificationOffset + 1];

            require(starkKey < K_MODULUS, "Stark key >= PRIME");
            require(requestingKey < K_MODULUS, "Requesting key >= PRIME");
            require(tokenId < K_MODULUS, "Token id >= PRIME");

            uint256 actionParams = publicInput[modificationOffset + 2];
            uint256 amountBefore = (actionParams >> 192) & ((1 << 63) - 1);
            uint256 amountAfter = (actionParams >> 128) & ((1 << 63) - 1);
            uint256 vaultId = (actionParams >> 96) & ((1 << 31) - 1);

            if (requestingKey != 0) {
                require(
                    starkKey != requestingKey,
                    "False full withdrawal requesting_key should differ from the vault owner key.");
                require(amountBefore == amountAfter, "Amounts differ in false full withdrawal.");
                clearFullWithdrawalRequest(requestingKey, vaultId);
                continue;
            }

            if (amountAfter > amountBefore) {
                uint256 quantizedAmount = amountAfter - amountBefore;
                acceptDeposit(starkKey, vaultId, tokenId, quantizedAmount);
            } else {
                if (amountBefore > amountAfter) {
                    uint256 quantizedAmount = amountBefore - amountAfter;
                    acceptWithdrawal(starkKey, tokenId, quantizedAmount);
                }
                if (amountAfter == 0) {
                    clearFullWithdrawalRequest(starkKey, vaultId);
                }
            }
        }
    }
}
pragma solidity ^0.5.2;


contract Withdrawals is MainStorage, IVerifierActions, MFreezable, MOperator,
                        MUsers, MTokens, MWithdrawal {

    event LogWithdrawal(
        uint256 starkKey,
        uint256 tokenId,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount
    );

    event LogUserWithdrawal(
        uint256 starkKey,
        uint256 tokenId,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount
    );

    function getWithdrawalBalance(
        uint256 starkKey,
        uint256 tokenId
    )
        external view
        returns (uint256 balance)
    {

        balance = fromQuantized(tokenId, pendingWithdrawals[starkKey][tokenId]);
    }

    function withdraw(
        uint256 tokenId
    )
        external
    {

        address etherKey = msg.sender;
        uint256 starkKey = getStarkKey(etherKey);

        uint256 quantizedAmount = pendingWithdrawals[starkKey][tokenId];
        pendingWithdrawals[starkKey][tokenId] = 0;

        transferOut(tokenId, quantizedAmount);
        emit LogUserWithdrawal(
            starkKey, tokenId, fromQuantized(tokenId, quantizedAmount), quantizedAmount);
    }

    function allowWithdrawal(
        uint256 starkKey,
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal
    {

        uint256 withdrawal = pendingWithdrawals[starkKey][tokenId];

        withdrawal += quantizedAmount;
        require(withdrawal >= quantizedAmount, "WITHDRAWAL_OVERFLOW");

        pendingWithdrawals[starkKey][tokenId] = withdrawal;

        emit LogWithdrawal(
            starkKey, tokenId, fromQuantized(tokenId, quantizedAmount), quantizedAmount);
    }


    function acceptWithdrawal(
        uint256 starkKey,
        uint256 tokenId,
        uint256 quantizedAmount
    )
        internal
    {

        allowWithdrawal(starkKey, tokenId, quantizedAmount);
    }
}
pragma solidity ^0.5.2;


contract StarkExchange is
    IVerifierActions,
    MainGovernance,
    ApprovalChain,
    AvailabilityVerifiers,
    Operator,
    Freezable,
    Tokens,
    Users,
    StateRoot,
    Deposits,
    Verifiers,
    Withdrawals,
    FullWithdrawals,
    Escapes,
    UpdateState
{

    string constant public VERSION = "1.0.1";
    string constant INIT_TAG = "INIT_TAG_Starkware.StarkExchange.2020";

    function initKey() internal pure returns(bytes32 key){

        key = keccak256(abi.encode(INIT_TAG, VERSION));
    }

    function internalInitialize(
        IFactRegistry escapeVerifier,
        IECDSA ecdsaContract,
        uint256 initialSequenceNumber,
        uint256 initialVaultRoot,
        uint256 initialOrderRoot,
        uint256 initialVaultTreeHeight,
        uint256 initialOrderTreeHeight
    )
    internal
    {

        initGovernance();
        Operator.initialize();
        StateRoot.initialize(initialSequenceNumber, initialVaultRoot,
            initialOrderRoot, initialVaultTreeHeight, initialOrderTreeHeight);
        Escapes.initialize(escapeVerifier);
        Users.initialize(ecdsaContract);
    }

    function initialize(bytes calldata data)
        external
    {

        bytes32 key = initKey();

        if (!initialized[key]){
            if (data.length > 0){
                require(data.length == 224, "INCORRECT_INIT_DATA_SIZE");
                IFactRegistry escapeVerifier;
                IECDSA ecdsaContract;
                uint256 initialSequenceNumber;
                uint256 initialVaultRoot;
                uint256 initialOrderRoot;
                uint256 initialVaultTreeHeight;
                uint256 initialOrderTreeHeight;
                (
                    escapeVerifier,
                    ecdsaContract,
                    initialSequenceNumber,
                    initialVaultRoot,
                    initialOrderRoot,
                    initialVaultTreeHeight,
                    initialOrderTreeHeight
                ) = abi.decode(data,
                    (IFactRegistry, IECDSA, uint256, uint256, uint256, uint256, uint256));

                internalInitialize(
                    escapeVerifier,
                    ecdsaContract,
                    initialSequenceNumber,
                    initialVaultRoot,
                    initialOrderRoot,
                    initialVaultTreeHeight,
                    initialOrderTreeHeight
                );
            }
            initialized[key] = true;
        }
    }
}
