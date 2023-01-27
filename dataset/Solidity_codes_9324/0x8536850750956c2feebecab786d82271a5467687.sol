pragma solidity ^0.6.11;

contract GovernanceStorage {

    struct GovernanceInfoStruct {
        mapping(address => bool) effectiveGovernors;
        address candidateGovernor;
        bool initialized;
    }

    mapping(string => GovernanceInfoStruct) internal governanceInfo;
}
pragma solidity ^0.6.11;


contract ProxyStorage is GovernanceStorage {

    mapping(address => bytes32) internal initializationHash_DEPRECATED;

    mapping(bytes32 => uint256) internal enabledTime;

    mapping(bytes32 => bool) internal initialized;
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

    function validateContractId(address contractAddress, bytes32 expectedIdHash) internal {

        require(isContract(contractAddress), "ADDRESS_NOT_CONTRACT");
        (bool success, bytes memory returndata) = contractAddress.call( // NOLINT: low-level-calls.
            abi.encodeWithSignature("identify()")
        );
        require(success, "FAILED_TO_IDENTIFY_CONTRACT");
        string memory realContractId = abi.decode(returndata, (string));
        require(
            keccak256(abi.encodePacked(realContractId)) == expectedIdHash,
            "UNEXPECTED_CONTRACT_IDENTIFIER"
        );
    }
}

library StarkExTypes {

    struct ApprovalChainData {
        address[] list;
        mapping(address => uint256) unlockedForRemovalTime;
    }
}
pragma solidity ^0.6.11;


contract MainStorage is ProxyStorage {

    uint256 internal constant LAYOUT_LENGTH = 2**64;

    address escapeVerifierAddress; // NOLINT: constable-states.

    bool stateFrozen; // NOLINT: constable-states.

    uint256 unFreezeTime; // NOLINT: constable-states.

    mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) pendingDeposits;

    mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) cancellationRequests;

    mapping(uint256 => mapping(uint256 => uint256)) pendingWithdrawals;

    mapping(uint256 => bool) escapesUsed;

    uint256 escapesUsedCount; // NOLINT: constable-states.

    mapping(uint256 => mapping(uint256 => uint256)) fullWithdrawalRequests_DEPRECATED;

    uint256 sequenceNumber; // NOLINT: constable-states uninitialized-state.

    uint256 vaultRoot; // NOLINT: constable-states uninitialized-state.
    uint256 vaultTreeHeight; // NOLINT: constable-states uninitialized-state.

    uint256 orderRoot; // NOLINT: constable-states uninitialized-state.
    uint256 orderTreeHeight; // NOLINT: constable-states uninitialized-state.

    mapping(address => bool) tokenAdmins;

    mapping(address => bool) userAdmins_DEPRECATED; // NOLINT: naming-convention.

    mapping(address => bool) operators;

    mapping(uint256 => bytes) assetTypeToAssetInfo; // NOLINT: uninitialized-state.

    mapping(uint256 => bool) registeredAssetType; // NOLINT: uninitialized-state.

    mapping(uint256 => uint256) assetTypeToQuantum; // NOLINT: uninitialized-state.

    mapping(address => uint256) starkKeys_DEPRECATED; // NOLINT: naming-convention.

    mapping(uint256 => address) ethKeys; // NOLINT: uninitialized-state.

    StarkExTypes.ApprovalChainData verifiersChain;
    StarkExTypes.ApprovalChainData availabilityVerifiersChain;

    uint256 lastBatchId; // NOLINT: constable-states uninitialized-state.

    mapping(uint256 => address) subContracts; // NOLINT: uninitialized-state.

    mapping(uint256 => bool) permissiveAssetType_DEPRECATED; // NOLINT: naming-convention.

    uint256 onchainDataVersion; // NOLINT: constable-states uninitialized-state.

    mapping(uint256 => uint256) forcedRequestsInBlock;

    mapping(bytes32 => uint256) forcedActionRequests;

    mapping(bytes32 => uint256) actionsTimeLock;

    bytes32[] actionHashList;

    uint256[LAYOUT_LENGTH - 37] private __endGap; // __endGap complements layout to LAYOUT_LENGTH.
}
pragma solidity ^0.6.11;


contract StarkExStorage is MainStorage {

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) vaultsBalances;

    mapping(address => mapping(uint256 => mapping(uint256 => uint256))) vaultsWithdrawalLocks;

    bool strictVaultBalancePolicy; // NOLINT: constable-states, uninitialized-state.

    uint256 public defaultVaultWithdrawalLock; // NOLINT: constable-states.

    address public orderRegistryAddress; // NOLINT: constable-states.

    uint256[LAYOUT_LENGTH - 5] private __endGap; // __endGap complements layout to LAYOUT_LENGTH.
}
pragma solidity ^0.6.11;

abstract contract MStarkExForcedActionState {
    function fullWithdrawActionHash(uint256 starkKey, uint256 vaultId)
        internal
        pure
        virtual
        returns (bytes32);

    function clearFullWithdrawalRequest(uint256 starkKey, uint256 vaultId) internal virtual;

    function getFullWithdrawalRequest(uint256 starkKey, uint256 vaultId)
        public
        view
        virtual
        returns (uint256 res);

    function setFullWithdrawalRequest(uint256 starkKey, uint256 vaultId) internal virtual;
}
pragma solidity ^0.6.11;

contract LibConstants {


    uint256 public constant DEPOSIT_CANCEL_DELAY = 2 days;

    uint256 public constant FREEZE_GRACE_PERIOD = 7 days;

    uint256 public constant UNFREEZE_DELAY = 365 days;

    uint256 public constant MAX_VERIFIER_COUNT = uint256(64);

    uint256 public constant VERIFIER_REMOVAL_DELAY = FREEZE_GRACE_PERIOD + (21 days);

    address constant ZERO_ADDRESS = address(0x0);

    uint256 constant K_MODULUS = 0x800000000000011000000000000000000000000000000000000000000000001;

    uint256 constant K_BETA = 0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89;

    uint256 internal constant MASK_250 =
        0x03FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    uint256 internal constant MASK_240 =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    uint256 public constant MAX_FORCED_ACTIONS_REQS_PER_BLOCK = 10;

    uint256 constant QUANTUM_UPPER_BOUND = 2**128;
    uint256 internal constant MINTABLE_ASSET_ID_FLAG = 1 << 250;
}
pragma solidity ^0.6.11;


contract ActionHash is MainStorage, LibConstants {

    function getActionHash(string memory actionName, bytes memory packedActionParameters)
        internal
        pure
        returns (bytes32 actionHash)
    {

        actionHash = keccak256(abi.encodePacked(actionName, packedActionParameters));
    }

    function setActionHash(bytes32 actionHash, bool premiumCost) internal {

        if (premiumCost) {
            for (uint256 i = 0; i < 21129; i++) {}
        } else {
            require(
                forcedRequestsInBlock[block.number] < MAX_FORCED_ACTIONS_REQS_PER_BLOCK,
                "MAX_REQUESTS_PER_BLOCK_REACHED"
            );
            forcedRequestsInBlock[block.number] += 1;
        }
        forcedActionRequests[actionHash] = block.timestamp;
        actionHashList.push(actionHash);
    }

    function getActionCount() external view returns (uint256) {

        return actionHashList.length;
    }

    function getActionHashByIndex(uint256 actionIndex) external view returns (bytes32) {

        require(actionIndex < actionHashList.length, "ACTION_INDEX_TOO_HIGH");
        return actionHashList[actionIndex];
    }
}
pragma solidity ^0.6.11;


contract StarkExForcedActionState is StarkExStorage, ActionHash, MStarkExForcedActionState {

    function fullWithdrawActionHash(uint256 starkKey, uint256 vaultId)
        internal
        pure
        override
        returns (bytes32)
    {

        return getActionHash("FULL_WITHDRAWAL", abi.encode(starkKey, vaultId));
    }

    function clearFullWithdrawalRequest(uint256 starkKey, uint256 vaultId)
        internal
        virtual
        override
    {

        delete forcedActionRequests[fullWithdrawActionHash(starkKey, vaultId)];
    }

    function getFullWithdrawalRequest(uint256 starkKey, uint256 vaultId)
        public
        view
        override
        returns (uint256 res)
    {

        res = forcedActionRequests[fullWithdrawActionHash(starkKey, vaultId)];
    }

    function setFullWithdrawalRequest(uint256 starkKey, uint256 vaultId) internal override {

        setActionHash(fullWithdrawActionHash(starkKey, vaultId), true);
    }
}
pragma solidity ^0.6.11;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) external returns (bytes4);

}
pragma solidity ^0.6.11;


contract ERC721Receiver is IERC721Receiver {

    function onERC721Received(
        address, // operator - The address which called `safeTransferFrom` function.
        address, // from - The address which previously owned the token.
        uint256, // tokenId -  The NFT identifier which is being transferred.
        bytes memory // data - Additional data with no specified format.
    ) external override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}
pragma solidity ^0.6.11;

abstract contract MFreezable {
    function isFrozen() public view virtual returns (bool); // NOLINT: external-function.

    modifier notFrozen() {
        require(!isFrozen(), "STATE_IS_FROZEN");
        _;
    }

    function validateFreezeRequest(uint256 requestTime) internal virtual;

    modifier onlyFrozen() {
        require(isFrozen(), "STATE_NOT_FROZEN");
        _;
    }

    function freeze() internal virtual;
}
pragma solidity ^0.6.11;

abstract contract MGovernance {
    function isGovernor(address testGovernor) internal view virtual returns (bool);

    modifier onlyGovernance() {
        require(isGovernor(msg.sender), "ONLY_GOVERNANCE");
        _;
    }
}
pragma solidity ^0.6.11;


abstract contract Freezable is MainStorage, LibConstants, MGovernance, MFreezable {
    event LogFrozen();
    event LogUnFrozen();

    function isFrozen() public view override returns (bool) {
        return stateFrozen;
    }

    function validateFreezeRequest(uint256 requestTime) internal override {
        require(requestTime != 0, "FORCED_ACTION_UNREQUESTED");
        uint256 freezeTime = requestTime + FREEZE_GRACE_PERIOD;

        assert(freezeTime >= FREEZE_GRACE_PERIOD);
        require(block.timestamp >= freezeTime, "FORCED_ACTION_PENDING"); // NOLINT: timestamp.

        require(freezeTime > unFreezeTime, "REFREEZE_ATTEMPT");
    }

    function freeze() internal override notFrozen {
        unFreezeTime = block.timestamp + UNFREEZE_DELAY;

        stateFrozen = true;

        emit LogFrozen();
    }

    function unFreeze() external onlyFrozen onlyGovernance {
        require(block.timestamp >= unFreezeTime, "UNFREEZE_NOT_ALLOWED_YET");

        stateFrozen = false;

        vaultRoot += 1;
        orderRoot += 1;

        emit LogUnFrozen();
    }
}
pragma solidity ^0.6.11;

abstract contract MKeyGetters {
    function getEthKey(uint256 ownerKey) public view virtual returns (address);

    function strictGetEthKey(uint256 ownerKey) internal view virtual returns (address);

    function isMsgSenderKeyOwner(uint256 ownerKey) internal view virtual returns (bool);

    modifier onlyKeyOwner(uint256 ownerKey) {
        require(msg.sender == strictGetEthKey(ownerKey), "MISMATCHING_STARK_ETH_KEYS");
        _;
    }
}
pragma solidity ^0.6.11;


contract KeyGetters is MainStorage, MKeyGetters {

    uint256 internal constant MASK_ADDRESS = (1 << 160) - 1;

    function getEthKey(uint256 ownerKey) public view override returns (address) {

        address registeredEth = ethKeys[ownerKey];

        if (registeredEth != address(0x0)) {
            return registeredEth;
        }

        return ownerKey == (ownerKey & MASK_ADDRESS) ? address(ownerKey) : address(0x0);
    }

    function strictGetEthKey(uint256 ownerKey) internal view override returns (address ethKey) {

        ethKey = getEthKey(ownerKey);
        require(ethKey != address(0x0), "USER_UNREGISTERED");
    }

    function isMsgSenderKeyOwner(uint256 ownerKey) internal view override returns (bool) {

        return msg.sender == getEthKey(ownerKey);
    }
}
pragma solidity ^0.6.11;

abstract contract MTokenAssetData {
    function getAssetInfo(uint256 assetType) public view virtual returns (bytes memory assetInfo);

    function extractTokenSelector(bytes memory assetInfo)
        internal
        pure
        virtual
        returns (bytes4 selector);

    function isEther(uint256 assetType) internal view virtual returns (bool);

    function isERC20(uint256 assetType) internal view virtual returns (bool);

    function isERC721(uint256 assetType) internal view virtual returns (bool);

    function isFungibleAssetType(uint256 assetType) internal view virtual returns (bool);

    function isMintableAssetType(uint256 assetType) internal view virtual returns (bool);

    function extractContractAddress(uint256 assetType) internal view virtual returns (address);

    function verifyAssetInfo(bytes memory assetInfo) internal view virtual;

    function isNonFungibleAssetInfo(bytes memory assetInfo) internal pure virtual returns (bool);

    function calculateNftAssetId(uint256 assetType, uint256 tokenId)
        internal
        pure
        virtual
        returns (uint256 assetId);

    function calculateMintableAssetId(uint256 assetType, bytes memory mintingBlob)
        internal
        pure
        virtual
        returns (uint256 assetId);
}
pragma solidity ^0.6.11;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
pragma solidity ^0.6.11;


abstract contract TokenRegister is MainStorage, LibConstants, MGovernance, MTokenAssetData {
    event LogTokenRegistered(uint256 assetType, bytes assetInfo, uint256 quantum);
    event LogTokenAdminAdded(address tokenAdmin);
    event LogTokenAdminRemoved(address tokenAdmin);

    modifier onlyTokensAdmin() {
        require(isTokenAdmin(msg.sender), "ONLY_TOKENS_ADMIN");
        _;
    }

    function isTokenAdmin(address testedAdmin) public view returns (bool) {
        return tokenAdmins[testedAdmin];
    }

    function registerTokenAdmin(address newAdmin) external onlyGovernance {
        tokenAdmins[newAdmin] = true;
        emit LogTokenAdminAdded(newAdmin);
    }

    function unregisterTokenAdmin(address oldAdmin) external onlyGovernance {
        tokenAdmins[oldAdmin] = false;
        emit LogTokenAdminRemoved(oldAdmin);
    }

    function isAssetRegistered(uint256 assetType) public view returns (bool) {
        return registeredAssetType[assetType];
    }

    function registerToken(
        uint256 assetType,
        bytes memory assetInfo,
        uint256 quantum
    ) public virtual onlyTokensAdmin {
        require(!isAssetRegistered(assetType), "ASSET_ALREADY_REGISTERED");
        require(assetType < K_MODULUS, "INVALID_ASSET_TYPE");
        require(quantum > 0, "INVALID_QUANTUM");
        require(quantum < QUANTUM_UPPER_BOUND, "INVALID_QUANTUM");

        uint256 enforcedId = uint256(keccak256(abi.encodePacked(assetInfo, quantum))) & MASK_250;
        require(assetType == enforcedId, "INVALID_ASSET_TYPE");

        verifyAssetInfo(assetInfo);
        if (isNonFungibleAssetInfo(assetInfo)) {
            require(quantum == 1, "INVALID_NFT_QUANTUM");
        }

        registeredAssetType[assetType] = true;
        assetTypeToAssetInfo[assetType] = assetInfo;
        assetTypeToQuantum[assetType] = quantum;

        emit LogTokenRegistered(assetType, assetInfo, quantum);
    }

    function registerToken(uint256 assetType, bytes calldata assetInfo) external virtual {
        registerToken(assetType, assetInfo, 1);
    }
}
pragma solidity ^0.6.11;

abstract contract MTokenTransfers {
    function transferIn(uint256 assetType, uint256 quantizedAmount) internal virtual;

    function transferInNft(uint256 assetType, uint256 tokenId) internal virtual;

    function transferOut(
        address payable recipient,
        uint256 assetType,
        uint256 quantizedAmount
    ) internal virtual;

    function transferOutNft(
        address recipient,
        uint256 assetType,
        uint256 tokenId
    ) internal virtual;

    function transferOutMint(
        uint256 assetType,
        uint256 quantizedAmount,
        address recipient,
        bytes memory mintingBlob
    ) internal virtual;
}
pragma solidity ^0.6.11;

abstract contract MTokenQuantization {
    function fromQuantized(uint256 presumedAssetType, uint256 quantizedAmount)
        internal
        view
        virtual
        returns (uint256 amount);

    function getQuantum(uint256 presumedAssetType) public view virtual returns (uint256 quantum);

    function toQuantized(uint256 presumedAssetType, uint256 amount)
        internal
        view
        virtual
        returns (uint256 quantizedAmount);
}
pragma solidity ^0.6.11;


abstract contract TokenTransfers is MTokenQuantization, MTokenAssetData, MTokenTransfers {
    using Addresses for address;
    using Addresses for address payable;

    function transferIn(uint256 assetType, uint256 quantizedAmount) internal override {
        uint256 amount = fromQuantized(assetType, quantizedAmount);
        if (isERC20(assetType)) {
            address tokenAddress = extractContractAddress(assetType);
            IERC20 token = IERC20(tokenAddress);
            uint256 exchangeBalanceBefore = token.balanceOf(address(this));
            bytes memory callData = abi.encodeWithSelector(
                token.transferFrom.selector,
                msg.sender,
                address(this),
                amount
            );
            tokenAddress.safeTokenContractCall(callData);
            uint256 exchangeBalanceAfter = token.balanceOf(address(this));
            require(exchangeBalanceAfter >= exchangeBalanceBefore, "OVERFLOW");
            require(
                exchangeBalanceAfter == exchangeBalanceBefore + amount,
                "INCORRECT_AMOUNT_TRANSFERRED"
            );
        } else if (isEther(assetType)) {
            require(msg.value == amount, "INCORRECT_DEPOSIT_AMOUNT");
        } else {
            revert("UNSUPPORTED_TOKEN_TYPE");
        }
    }

    function transferInNft(uint256 assetType, uint256 tokenId) internal override {
        require(isERC721(assetType), "NOT_ERC721_TOKEN");
        address tokenAddress = extractContractAddress(assetType);
        tokenAddress.safeTokenContractCall(
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                msg.sender,
                address(this),
                tokenId
            )
        );
    }

    function transferOut(
        address payable recipient,
        uint256 assetType,
        uint256 quantizedAmount
    ) internal override {
        require(recipient != address(0x0), "INVALID_RECIPIENT");
        uint256 amount = fromQuantized(assetType, quantizedAmount);
        if (isERC20(assetType)) {
            address tokenAddress = extractContractAddress(assetType);
            IERC20 token = IERC20(tokenAddress);
            uint256 exchangeBalanceBefore = token.balanceOf(address(this));
            bytes memory callData = abi.encodeWithSelector(
                token.transfer.selector,
                recipient,
                amount
            );
            tokenAddress.safeTokenContractCall(callData);
            uint256 exchangeBalanceAfter = token.balanceOf(address(this));
            require(exchangeBalanceAfter <= exchangeBalanceBefore, "UNDERFLOW");
            require(
                exchangeBalanceAfter == exchangeBalanceBefore - amount,
                "INCORRECT_AMOUNT_TRANSFERRED"
            );
        } else if (isEther(assetType)) {
            recipient.performEthTransfer(amount);
        } else {
            revert("UNSUPPORTED_TOKEN_TYPE");
        }
    }

    function transferOutNft(
        address recipient,
        uint256 assetType,
        uint256 tokenId
    ) internal override {
        require(recipient != address(0x0), "INVALID_RECIPIENT");
        require(isERC721(assetType), "NOT_ERC721_TOKEN");
        address tokenAddress = extractContractAddress(assetType);
        tokenAddress.safeTokenContractCall(
            abi.encodeWithSignature(
                "safeTransferFrom(address,address,uint256)",
                address(this),
                recipient,
                tokenId
            )
        );
    }

    function transferOutMint(
        uint256 assetType,
        uint256 quantizedAmount,
        address recipient,
        bytes memory mintingBlob
    ) internal override {
        require(recipient != address(0x0), "INVALID_RECIPIENT");
        require(isMintableAssetType(assetType), "NON_MINTABLE_ASSET_TYPE");
        uint256 amount = fromQuantized(assetType, quantizedAmount);
        address tokenAddress = extractContractAddress(assetType);
        tokenAddress.safeTokenContractCall(
            abi.encodeWithSignature(
                "mintFor(address,uint256,bytes)",
                recipient,
                amount,
                mintingBlob
            )
        );
    }
}
pragma solidity >=0.5.3 <0.7.0; // NOLINT pragma.

library EllipticCurve {


  uint256 constant private U255_MAX_PLUS_1 = 57896044618658097711785492504343953926634992332820282019728792003956564819968;

  function invMod(uint256 _x, uint256 _pp) internal pure returns (uint256) {

    require(_x != 0 && _x != _pp && _pp != 0, "Invalid number");
    uint256 q = 0;
    uint256 newT = 1;
    uint256 r = _pp;
    uint256 t;
    while (_x != 0) {
      t = r / _x;
      (q, newT) = (newT, addmod(q, (_pp - mulmod(t, newT, _pp)), _pp));
      (r, _x) = (_x, r - t * _x);
    }

    return q;
  }

  function expMod(uint256 _base, uint256 _exp, uint256 _pp) internal pure returns (uint256) {

    require(_pp!=0, "Modulus is zero");

    if (_base == 0)
      return 0;
    if (_exp == 0)
      return 1;

    uint256 r = 1;
    uint256 bit = U255_MAX_PLUS_1;
    assembly {
      for { } gt(bit, 0) { }{
        r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, bit)))), _pp)
        r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 2))))), _pp)
        r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 4))))), _pp)
        r := mulmod(mulmod(r, r, _pp), exp(_base, iszero(iszero(and(_exp, div(bit, 8))))), _pp)
        bit := div(bit, 16)
      }
    }

    return r;
  }

  function toAffine(
    uint256 _x,
    uint256 _y,
    uint256 _z,
    uint256 _pp)
  internal pure returns (uint256, uint256)
  {
    uint256 zInv = invMod(_z, _pp);
    uint256 zInv2 = mulmod(zInv, zInv, _pp);
    uint256 x2 = mulmod(_x, zInv2, _pp);
    uint256 y2 = mulmod(_y, mulmod(zInv, zInv2, _pp), _pp);

    return (x2, y2);
  }

  function deriveY(
    uint8 _prefix,
    uint256 _x,
    uint256 _aa,
    uint256 _bb,
    uint256 _pp)
  internal pure returns (uint256)
  {
    require(_prefix == 0x02 || _prefix == 0x03, "Invalid compressed EC point prefix");

    uint256 y2 = addmod(mulmod(_x, mulmod(_x, _x, _pp), _pp), addmod(mulmod(_x, _aa, _pp), _bb, _pp), _pp);
    y2 = expMod(y2, (_pp + 1) / 4, _pp);
    uint256 y = (y2 + _prefix) % 2 == 0 ? y2 : _pp - y2;

    return y;
  }

  function isOnCurve(
    uint _x,
    uint _y,
    uint _aa,
    uint _bb,
    uint _pp)
  internal pure returns (bool)
  {
    if (0 == _x || _x >= _pp || 0 == _y || _y >= _pp) {
      return false;
    }
    uint lhs = mulmod(_y, _y, _pp);
    uint rhs = mulmod(mulmod(_x, _x, _pp), _x, _pp);
    if (_aa != 0) {
      rhs = addmod(rhs, mulmod(_x, _aa, _pp), _pp);
    }
    if (_bb != 0) {
      rhs = addmod(rhs, _bb, _pp);
    }

    return lhs == rhs;
  }

  function ecInv(
    uint256 _x,
    uint256 _y,
    uint256 _pp)
  internal pure returns (uint256, uint256)
  {
    return (_x, (_pp - _y) % _pp);
  }

  function ecAdd(
    uint256 _x1,
    uint256 _y1,
    uint256 _x2,
    uint256 _y2,
    uint256 _aa,
    uint256 _pp)
    internal pure returns(uint256, uint256)
  {
    uint x = 0;
    uint y = 0;
    uint z = 0;

    if (_x1==_x2) {
      if (addmod(_y1, _y2, _pp) == 0) {
        return(0, 0);
      } else {
        (x, y, z) = jacDouble(
          _x1,
          _y1,
          1,
          _aa,
          _pp);
      }
    } else {
      (x, y, z) = jacAdd(
        _x1,
        _y1,
        1,
        _x2,
        _y2,
        1,
        _pp);
    }
    return toAffine(
      x,
      y,
      z,
      _pp);
  }

  function ecSub(
    uint256 _x1,
    uint256 _y1,
    uint256 _x2,
    uint256 _y2,
    uint256 _aa,
    uint256 _pp)
  internal pure returns(uint256, uint256)
  {
    (uint256 x, uint256 y) = ecInv(_x2, _y2, _pp);
    return ecAdd(
      _x1,
      _y1,
      x,
      y,
      _aa,
      _pp);
  }

  function ecMul(
    uint256 _k,
    uint256 _x,
    uint256 _y,
    uint256 _aa,
    uint256 _pp)
  internal pure returns(uint256, uint256)
  {
    (uint256 x1, uint256 y1, uint256 z1) = jacMul(
      _k,
      _x,
      _y,
      1,
      _aa,
      _pp);
    return toAffine(
      x1,
      y1,
      z1,
      _pp);
  }

  function jacAdd(
    uint256 _x1,
    uint256 _y1,
    uint256 _z1,
    uint256 _x2,
    uint256 _y2,
    uint256 _z2,
    uint256 _pp)
  internal pure returns (uint256, uint256, uint256)
  {
    if (_x1==0 && _y1==0)
      return (_x2, _y2, _z2);
    if (_x2==0 && _y2==0)
      return (_x1, _y1, _z1);

    uint[4] memory zs; // z1^2, z1^3, z2^2, z2^3
    zs[0] = mulmod(_z1, _z1, _pp);
    zs[1] = mulmod(_z1, zs[0], _pp);
    zs[2] = mulmod(_z2, _z2, _pp);
    zs[3] = mulmod(_z2, zs[2], _pp);

    zs = [
      mulmod(_x1, zs[2], _pp),
      mulmod(_y1, zs[3], _pp),
      mulmod(_x2, zs[0], _pp),
      mulmod(_y2, zs[1], _pp)
    ];

    require(zs[0] != zs[2] || zs[1] != zs[3], "Use jacDouble function instead");

    uint[4] memory hr;
    hr[0] = addmod(zs[2], _pp - zs[0], _pp);
    hr[1] = addmod(zs[3], _pp - zs[1], _pp);
    hr[2] = mulmod(hr[0], hr[0], _pp);
    hr[3] = mulmod(hr[2], hr[0], _pp);
    uint256 qx = addmod(mulmod(hr[1], hr[1], _pp), _pp - hr[3], _pp);
    qx = addmod(qx, _pp - mulmod(2, mulmod(zs[0], hr[2], _pp), _pp), _pp);
    uint256 qy = mulmod(hr[1], addmod(mulmod(zs[0], hr[2], _pp), _pp - qx, _pp), _pp);
    qy = addmod(qy, _pp - mulmod(zs[1], hr[3], _pp), _pp);
    uint256 qz = mulmod(hr[0], mulmod(_z1, _z2, _pp), _pp);
    return(qx, qy, qz);
  }

  function jacDouble(
    uint256 _x,
    uint256 _y,
    uint256 _z,
    uint256 _aa,
    uint256 _pp)
  internal pure returns (uint256, uint256, uint256)
  {
    if (_z == 0)
      return (_x, _y, _z);

    uint256 x = mulmod(_x, _x, _pp); //x1^2
    uint256 y = mulmod(_y, _y, _pp); //y1^2
    uint256 z = mulmod(_z, _z, _pp); //z1^2

    uint s = mulmod(4, mulmod(_x, y, _pp), _pp);
    uint m = addmod(mulmod(3, x, _pp), mulmod(_aa, mulmod(z, z, _pp), _pp), _pp);

    x = addmod(mulmod(m, m, _pp), _pp - addmod(s, s, _pp), _pp);
    y = addmod(mulmod(m, addmod(s, _pp - x, _pp), _pp), _pp - mulmod(8, mulmod(y, y, _pp), _pp), _pp);
    z = mulmod(2, mulmod(_y, _z, _pp), _pp);

    return (x, y, z);
  }

  function jacMul(
    uint256 _d,
    uint256 _x,
    uint256 _y,
    uint256 _z,
    uint256 _aa,
    uint256 _pp)
  internal pure returns (uint256, uint256, uint256)
  {
    if (_d == 0) {
      return (_x, _y, _z);
    }

    uint256 remaining = _d;
    uint256 qx = 0;
    uint256 qy = 0;
    uint256 qz = 1;

    while (remaining != 0) {
      if ((remaining & 1) != 0) {
        (qx, qy, qz) = jacAdd(
          qx,
          qy,
          qz,
          _x,
          _y,
          _z,
          _pp);
      }
      remaining = remaining / 2;
      (_x, _y, _z) = jacDouble(
        _x,
        _y,
        _z,
        _aa,
        _pp);
    }
    return (qx, qy, qz);
  }
}
pragma solidity ^0.6.11;


library ECDSA {

    using EllipticCurve for uint256;
    uint256 constant FIELD_PRIME =
        0x800000000000011000000000000000000000000000000000000000000000001;
    uint256 constant ALPHA = 1;
    uint256 constant BETA =
        3141592653589793238462643383279502884197169399375105820974944592307816406665;
    uint256 constant EC_ORDER =
        3618502788666131213697322783095070105526743751716087489154079457884512865583;
    uint256 constant N_ELEMENT_BITS_ECDSA = 251;
    uint256 constant EC_GEN_X = 0x1ef15c18599971b7beced415a40f0c7deacfd9b0d1819e03d723d8bc943cfca;
    uint256 constant EC_GEN_Y = 0x5668060aa49730b7be4801df46ec62de53ecd11abe43a32873000c36e8dc1f;

    function verify(
        uint256 msgHash,
        uint256 r,
        uint256 s,
        uint256 pubX,
        uint256 pubY
    ) internal pure {

        require(msgHash % EC_ORDER == msgHash, "msgHash out of range");
        require((1 <= s) && (s < EC_ORDER), "s out of range");
        uint256 w = s.invMod(EC_ORDER);
        require((1 <= r) && (r < (1 << N_ELEMENT_BITS_ECDSA)), "r out of range");
        require((1 <= w) && (w < (1 << N_ELEMENT_BITS_ECDSA)), "w out of range");

        {
            uint256 x3 = mulmod(mulmod(pubX, pubX, FIELD_PRIME), pubX, FIELD_PRIME);
            uint256 y2 = mulmod(pubY, pubY, FIELD_PRIME);
            require(
                y2 == addmod(addmod(x3, pubX, FIELD_PRIME), BETA, FIELD_PRIME),
                "INVALID_STARK_KEY"
            );
        }

        uint256 b_x;
        uint256 b_y;
        {
            (uint256 zG_x, uint256 zG_y) = msgHash.ecMul(EC_GEN_X, EC_GEN_Y, ALPHA, FIELD_PRIME);

            (uint256 rQ_x, uint256 rQ_y) = r.ecMul(pubX, pubY, ALPHA, FIELD_PRIME);

            (b_x, b_y) = zG_x.ecAdd(zG_y, rQ_x, rQ_y, ALPHA, FIELD_PRIME);
        }
        (uint256 res_x, ) = w.ecMul(b_x, b_y, ALPHA, FIELD_PRIME);

        require(res_x == r, "INVALID_STARK_SIGNATURE");
    }
}
pragma solidity ^0.6.11;


abstract contract Users is MainStorage, LibConstants {
    event LogUserRegistered(address ethKey, uint256 starkKey, address sender);

    function isOnCurve(uint256 starkKey) private view returns (bool) {
        uint256 xCubed = mulmod(mulmod(starkKey, starkKey, K_MODULUS), starkKey, K_MODULUS);
        return isQuadraticResidue(addmod(addmod(xCubed, starkKey, K_MODULUS), K_BETA, K_MODULUS));
    }

    function registerSender(uint256 starkKey, bytes calldata starkSignature) external {
        registerEthAddress(msg.sender, starkKey, starkSignature);
    }

    function registerEthAddress(
        address ethKey,
        uint256 starkKey,
        bytes calldata starkSignature
    ) public {
        require(starkKey != 0, "INVALID_STARK_KEY");
        require(starkKey < K_MODULUS, "INVALID_STARK_KEY");
        require(ethKey != ZERO_ADDRESS, "INVALID_ETH_ADDRESS");
        require(ethKeys[starkKey] == ZERO_ADDRESS, "STARK_KEY_UNAVAILABLE");
        require(isOnCurve(starkKey), "INVALID_STARK_KEY");
        require(starkSignature.length == 32 * 3, "INVALID_STARK_SIGNATURE_LENGTH");

        bytes memory sig = starkSignature;
        (uint256 r, uint256 s, uint256 StarkKeyY) = abi.decode(sig, (uint256, uint256, uint256));

        uint256 msgHash = uint256(
            keccak256(abi.encodePacked("UserRegistration:", ethKey, starkKey))
        ) % ECDSA.EC_ORDER;

        ECDSA.verify(msgHash, r, s, starkKey, StarkKeyY);

        ethKeys[starkKey] = ethKey;

        emit LogUserRegistered(ethKey, starkKey, msg.sender);
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
pragma solidity ^0.6.11;


abstract contract Governance is GovernanceStorage, MGovernance {
    event LogNominatedGovernor(address nominatedGovernor);
    event LogNewGovernorAccepted(address acceptedGovernor);
    event LogRemovedGovernor(address removedGovernor);
    event LogNominationCancelled();

    function getGovernanceTag() internal pure virtual returns (string memory);

    function contractGovernanceInfo() internal view returns (GovernanceInfoStruct storage) {
        string memory tag = getGovernanceTag();
        GovernanceInfoStruct storage gub = governanceInfo[tag];
        require(gub.initialized, "NOT_INITIALIZED");
        return gub;
    }

    function initGovernance() internal {
        string memory tag = getGovernanceTag();
        GovernanceInfoStruct storage gub = governanceInfo[tag];
        require(!gub.initialized, "ALREADY_INITIALIZED");
        gub.initialized = true; // to ensure addGovernor() won't fail.
        addGovernor(msg.sender);
    }

    function isGovernor(address testGovernor) internal view override returns (bool) {
        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        return gub.effectiveGovernors[testGovernor];
    }

    function cancelNomination() internal onlyGovernance {
        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        gub.candidateGovernor = address(0x0);
        emit LogNominationCancelled();
    }

    function nominateNewGovernor(address newGovernor) internal onlyGovernance {
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

    function acceptGovernance() internal {
        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        require(msg.sender == gub.candidateGovernor, "ONLY_CANDIDATE_GOVERNOR");

        addGovernor(gub.candidateGovernor);
        gub.candidateGovernor = address(0x0);

        emit LogNewGovernorAccepted(msg.sender);
    }

    function removeGovernor(address governorForRemoval) internal onlyGovernance {
        require(msg.sender != governorForRemoval, "GOVERNOR_SELF_REMOVE");
        GovernanceInfoStruct storage gub = contractGovernanceInfo();
        require(isGovernor(governorForRemoval), "NOT_GOVERNOR");
        gub.effectiveGovernors[governorForRemoval] = false;
        emit LogRemovedGovernor(governorForRemoval);
    }
}
pragma solidity ^0.6.11;


contract MainGovernance is Governance {

    string public constant MAIN_GOVERNANCE_INFO_TAG = "StarkEx.Main.2019.GovernorsInformation";

    function getGovernanceTag() internal pure override returns (string memory tag) {

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

    function mainAcceptGovernance() external {

        acceptGovernance();
    }

    function mainCancelNomination() external {

        cancelNomination();
    }
}
pragma solidity ^0.6.11;

abstract contract MAcceptModifications {
    function acceptDeposit(
        uint256 ownerKey,
        uint256 vaultId,
        uint256 assetId,
        uint256 quantizedAmount
    ) internal virtual;

    function allowWithdrawal(
        uint256 ownerKey,
        uint256 assetId,
        uint256 quantizedAmount
    ) internal virtual;

    function acceptWithdrawal(
        uint256 ownerKey,
        uint256 assetId,
        uint256 quantizedAmount
    ) internal virtual;
}
pragma solidity ^0.6.11;


abstract contract AcceptModifications is
    MainStorage,
    LibConstants,
    MAcceptModifications,
    MTokenQuantization
{
    event LogWithdrawalAllowed(
        uint256 ownerKey,
        uint256 assetType,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount
    );

    event LogNftWithdrawalAllowed(uint256 ownerKey, uint256 assetId);

    event LogMintableWithdrawalAllowed(uint256 ownerKey, uint256 assetId, uint256 quantizedAmount);

    function acceptDeposit(
        uint256 ownerKey,
        uint256 vaultId,
        uint256 assetId,
        uint256 quantizedAmount
    ) internal virtual override {
        require(
            pendingDeposits[ownerKey][assetId][vaultId] >= quantizedAmount,
            "DEPOSIT_INSUFFICIENT"
        );

        pendingDeposits[ownerKey][assetId][vaultId] -= quantizedAmount;
    }

    function allowWithdrawal(
        uint256 ownerKey,
        uint256 assetId,
        uint256 quantizedAmount
    ) internal override {
        uint256 withdrawal = pendingWithdrawals[ownerKey][assetId];

        withdrawal += quantizedAmount;
        require(withdrawal >= quantizedAmount, "WITHDRAWAL_OVERFLOW");

        pendingWithdrawals[ownerKey][assetId] = withdrawal;

        uint256 presumedAssetType = assetId;
        if (registeredAssetType[presumedAssetType]) {
            emit LogWithdrawalAllowed(
                ownerKey,
                presumedAssetType,
                fromQuantized(presumedAssetType, quantizedAmount),
                quantizedAmount
            );
        } else if (assetId == ((assetId & MASK_240) | MINTABLE_ASSET_ID_FLAG)) {
            emit LogMintableWithdrawalAllowed(ownerKey, assetId, quantizedAmount);
        } else {
            require(assetId == assetId & MASK_250, "INVALID_NFT_ASSET_ID");
            require(withdrawal <= 1, "INVALID_NFT_AMOUNT");
            emit LogNftWithdrawalAllowed(ownerKey, assetId);
        }
    }

    function acceptWithdrawal(
        uint256 ownerKey,
        uint256 assetId,
        uint256 quantizedAmount
    ) internal virtual override {
        allowWithdrawal(ownerKey, assetId, quantizedAmount);
    }
}
pragma solidity ^0.6.11;

abstract contract MDeposits {
    function depositERC20( // NOLINT external-function.
        uint256 starkKey,
        uint256 assetType,
        uint256 vaultId,
        uint256 quantizedAmount
    ) public virtual;

    function depositEth( // NOLINT external-function.
        uint256 starkKey,
        uint256 assetType,
        uint256 vaultId
    ) public payable virtual;
}
pragma solidity ^0.6.11;


abstract contract CompositeActions is MDeposits {
    function registerAndDepositERC20(
        address ethKey,
        uint256 starkKey,
        bytes calldata signature,
        uint256 assetType,
        uint256 vaultId,
        uint256 quantizedAmount
    ) external {
        depositERC20(starkKey, assetType, vaultId, quantizedAmount);
    }

    function registerAndDepositEth(
        address ethKey,
        uint256 starkKey,
        bytes calldata signature,
        uint256 assetType,
        uint256 vaultId
    ) external payable {
        depositEth(starkKey, assetType, vaultId);
    }
}
pragma solidity ^0.6.11;


abstract contract Deposits is
    MainStorage,
    LibConstants,
    MAcceptModifications,
    MDeposits,
    MTokenQuantization,
    MTokenAssetData,
    MFreezable,
    MKeyGetters,
    MTokenTransfers
{
    event LogDeposit(
        address depositorEthKey,
        uint256 starkKey,
        uint256 vaultId,
        uint256 assetType,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount
    );

    event LogNftDeposit(
        address depositorEthKey,
        uint256 starkKey,
        uint256 vaultId,
        uint256 assetType,
        uint256 tokenId,
        uint256 assetId
    );

    event LogDepositCancel(uint256 starkKey, uint256 vaultId, uint256 assetId);

    event LogDepositCancelReclaimed(
        uint256 starkKey,
        uint256 vaultId,
        uint256 assetType,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount
    );

    event LogDepositNftCancelReclaimed(
        uint256 starkKey,
        uint256 vaultId,
        uint256 assetType,
        uint256 tokenId,
        uint256 assetId
    );

    function getDepositBalance(
        uint256 starkKey,
        uint256 assetId,
        uint256 vaultId
    ) external view returns (uint256 balance) {
        uint256 presumedAssetType = assetId;
        balance = fromQuantized(presumedAssetType, pendingDeposits[starkKey][assetId][vaultId]);
    }

    function getQuantizedDepositBalance(
        uint256 starkKey,
        uint256 assetId,
        uint256 vaultId
    ) external view returns (uint256 balance) {
        balance = pendingDeposits[starkKey][assetId][vaultId];
    }

    function depositNft(
        uint256 starkKey,
        uint256 assetType,
        uint256 vaultId,
        uint256 tokenId
    ) external notFrozen {

        require(!isMintableAssetType(assetType), "MINTABLE_ASSET_TYPE");
        require(!isFungibleAssetType(assetType), "FUNGIBLE_ASSET_TYPE");
        uint256 assetId = calculateNftAssetId(assetType, tokenId);

        pendingDeposits[starkKey][assetId][vaultId] = 1;

        if (
            isMsgSenderKeyOwner(starkKey) && cancellationRequests[starkKey][assetId][vaultId] != 0
        ) {
            delete cancellationRequests[starkKey][assetId][vaultId];
        }

        transferInNft(assetType, tokenId);

        emit LogNftDeposit(msg.sender, starkKey, vaultId, assetType, tokenId, assetId);
    }

    function getCancellationRequest(
        uint256 starkKey,
        uint256 assetId,
        uint256 vaultId
    ) external view returns (uint256 request) {
        request = cancellationRequests[starkKey][assetId][vaultId];
    }

    function depositERC20(
        uint256 starkKey,
        uint256 assetType,
        uint256 vaultId,
        uint256 quantizedAmount
    ) public override {
        deposit(starkKey, assetType, vaultId, quantizedAmount);
    }

    function depositEth(
        uint256 starkKey,
        uint256 assetType,
        uint256 vaultId
    ) public payable override {
        require(isEther(assetType), "INVALID_ASSET_TYPE");
        deposit(starkKey, assetType, vaultId, toQuantized(assetType, msg.value));
    }

    function deposit(
        uint256 starkKey,
        uint256 assetType,
        uint256 vaultId,
        uint256 quantizedAmount
    ) public notFrozen {

        require(!isMintableAssetType(assetType), "MINTABLE_ASSET_TYPE");
        require(isFungibleAssetType(assetType), "NON_FUNGIBLE_ASSET_TYPE");
        uint256 assetId = assetType;

        pendingDeposits[starkKey][assetId][vaultId] += quantizedAmount;
        require(pendingDeposits[starkKey][assetId][vaultId] >= quantizedAmount, "DEPOSIT_OVERFLOW");

        if (
            isMsgSenderKeyOwner(starkKey) && cancellationRequests[starkKey][assetId][vaultId] != 0
        ) {
            delete cancellationRequests[starkKey][assetId][vaultId];
        }

        transferIn(assetType, quantizedAmount);

        emit LogDeposit(
            msg.sender,
            starkKey,
            vaultId,
            assetType,
            fromQuantized(assetType, quantizedAmount),
            quantizedAmount
        );
    }

    function deposit(
        uint256 starkKey,
        uint256 assetType,
        uint256 vaultId
    ) external payable {
        require(isEther(assetType), "INVALID_ASSET_TYPE");
        deposit(starkKey, assetType, vaultId, toQuantized(assetType, msg.value));
    }

    function depositCancel(
        uint256 starkKey,
        uint256 assetId,
        uint256 vaultId
    )
        external
        onlyKeyOwner(starkKey)
    {
        cancellationRequests[starkKey][assetId][vaultId] = block.timestamp;

        emit LogDepositCancel(starkKey, vaultId, assetId);
    }

    function depositReclaim(
        uint256 starkKey,
        uint256 assetId,
        uint256 vaultId
    )
        external
        onlyKeyOwner(starkKey)
    {
        uint256 assetType = assetId;

        uint256 requestTime = cancellationRequests[starkKey][assetId][vaultId];
        require(requestTime != 0, "DEPOSIT_NOT_CANCELED");
        uint256 freeTime = requestTime + DEPOSIT_CANCEL_DELAY;
        assert(freeTime >= DEPOSIT_CANCEL_DELAY);
        require(block.timestamp >= freeTime, "DEPOSIT_LOCKED"); // NOLINT: timestamp.

        uint256 quantizedAmount = pendingDeposits[starkKey][assetId][vaultId];
        delete pendingDeposits[starkKey][assetId][vaultId];
        delete cancellationRequests[starkKey][assetId][vaultId];

        transferOut(msg.sender, assetType, quantizedAmount);

        emit LogDepositCancelReclaimed(
            starkKey,
            vaultId,
            assetType,
            fromQuantized(assetType, quantizedAmount),
            quantizedAmount
        );
    }

    function depositNftReclaim(
        uint256 starkKey,
        uint256 assetType,
        uint256 vaultId,
        uint256 tokenId
    )
        external
        onlyKeyOwner(starkKey)
    {
        uint256 assetId = calculateNftAssetId(assetType, tokenId);

        uint256 requestTime = cancellationRequests[starkKey][assetId][vaultId];
        require(requestTime != 0, "DEPOSIT_NOT_CANCELED");
        uint256 freeTime = requestTime + DEPOSIT_CANCEL_DELAY;
        assert(freeTime >= DEPOSIT_CANCEL_DELAY);
        require(block.timestamp >= freeTime, "DEPOSIT_LOCKED");

        uint256 amount = pendingDeposits[starkKey][assetId][vaultId];
        delete pendingDeposits[starkKey][assetId][vaultId];
        delete cancellationRequests[starkKey][assetId][vaultId];

        if (amount > 0) {
            transferOutNft(msg.sender, assetType, tokenId);

            emit LogDepositNftCancelReclaimed(starkKey, vaultId, assetType, tokenId, assetId);
        }
    }
}
pragma solidity ^0.6.11;


contract TokenAssetData is MainStorage, LibConstants, MTokenAssetData {

    bytes4 internal constant ERC20_SELECTOR = bytes4(keccak256("ERC20Token(address)"));
    bytes4 internal constant ETH_SELECTOR = bytes4(keccak256("ETH()"));
    bytes4 internal constant ERC721_SELECTOR = bytes4(keccak256("ERC721Token(address,uint256)"));
    bytes4 internal constant MINTABLE_ERC20_SELECTOR =
        bytes4(keccak256("MintableERC20Token(address)"));
    bytes4 internal constant MINTABLE_ERC721_SELECTOR =
        bytes4(keccak256("MintableERC721Token(address,uint256)"));

    uint256 internal constant SELECTOR_OFFSET = 0x20;
    uint256 internal constant SELECTOR_SIZE = 4;
    uint256 internal constant TOKEN_CONTRACT_ADDRESS_OFFSET = SELECTOR_OFFSET + SELECTOR_SIZE;
    string internal constant NFT_ASSET_ID_PREFIX = "NFT:";
    string internal constant MINTABLE_PREFIX = "MINTABLE:";

    using Addresses for address;

    function extractTokenSelector(bytes memory assetInfo)
        internal
        pure
        override
        returns (bytes4 selector)
    {

        assembly {
            selector := and(
                0xffffffff00000000000000000000000000000000000000000000000000000000,
                mload(add(assetInfo, SELECTOR_OFFSET))
            )
        }
    }

    function getAssetInfo(uint256 assetType) public view override returns (bytes memory assetInfo) {

        require(registeredAssetType[assetType], "ASSET_TYPE_NOT_REGISTERED");

        assetInfo = assetTypeToAssetInfo[assetType];
    }

    function isEther(uint256 assetType) internal view override returns (bool) {

        return extractTokenSelector(getAssetInfo(assetType)) == ETH_SELECTOR;
    }

    function isERC20(uint256 assetType) internal view override returns (bool) {

        return extractTokenSelector(getAssetInfo(assetType)) == ERC20_SELECTOR;
    }

    function isERC721(uint256 assetType) internal view override returns (bool) {

        return extractTokenSelector(getAssetInfo(assetType)) == ERC721_SELECTOR;
    }

    function isFungibleAssetType(uint256 assetType) internal view override returns (bool) {

        bytes4 tokenSelector = extractTokenSelector(getAssetInfo(assetType));
        return
            tokenSelector == ETH_SELECTOR ||
            tokenSelector == ERC20_SELECTOR ||
            tokenSelector == MINTABLE_ERC20_SELECTOR;
    }

    function isMintableAssetType(uint256 assetType) internal view override returns (bool) {

        bytes4 tokenSelector = extractTokenSelector(getAssetInfo(assetType));
        return
            tokenSelector == MINTABLE_ERC20_SELECTOR || tokenSelector == MINTABLE_ERC721_SELECTOR;
    }

    function isTokenSupported(bytes4 tokenSelector) private pure returns (bool) {

        return
            tokenSelector == ETH_SELECTOR ||
            tokenSelector == ERC20_SELECTOR ||
            tokenSelector == ERC721_SELECTOR ||
            tokenSelector == MINTABLE_ERC20_SELECTOR ||
            tokenSelector == MINTABLE_ERC721_SELECTOR;
    }

    function extractContractAddressFromAssetInfo(bytes memory assetInfo)
        private
        pure
        returns (address)
    {

        uint256 offset = TOKEN_CONTRACT_ADDRESS_OFFSET;
        uint256 res;
        assembly {
            res := mload(add(assetInfo, offset))
        }
        return address(res);
    }

    function extractContractAddress(uint256 assetType) internal view override returns (address) {

        return extractContractAddressFromAssetInfo(getAssetInfo(assetType));
    }

    function verifyAssetInfo(bytes memory assetInfo) internal view override {

        bytes4 tokenSelector = extractTokenSelector(assetInfo);

        require(isTokenSupported(tokenSelector), "UNSUPPORTED_TOKEN_TYPE");

        if (tokenSelector == ETH_SELECTOR) {
            require(assetInfo.length == 4, "INVALID_ASSET_STRING");
        } else {
            require(assetInfo.length == 0x24, "INVALID_ASSET_STRING");
            address tokenAddress = extractContractAddressFromAssetInfo(assetInfo);
            require(tokenAddress.isContract(), "BAD_TOKEN_ADDRESS");
        }
    }

    function isNonFungibleAssetInfo(bytes memory assetInfo) internal pure override returns (bool) {

        bytes4 tokenSelector = extractTokenSelector(assetInfo);
        return tokenSelector == ERC721_SELECTOR || tokenSelector == MINTABLE_ERC721_SELECTOR;
    }

    function calculateNftAssetId(uint256 assetType, uint256 tokenId)
        internal
        pure
        override
        returns (uint256 assetId)
    {

        assetId =
            uint256(keccak256(abi.encodePacked(NFT_ASSET_ID_PREFIX, assetType, tokenId))) &
            MASK_250;
    }

    function calculateMintableAssetId(uint256 assetType, bytes memory mintingBlob)
        internal
        pure
        override
        returns (uint256 assetId)
    {

        uint256 blobHash = uint256(keccak256(mintingBlob));
        assetId =
            (uint256(keccak256(abi.encodePacked(MINTABLE_PREFIX, assetType, blobHash))) &
                MASK_240) |
            MINTABLE_ASSET_ID_FLAG;
    }
}
pragma solidity ^0.6.11;


contract TokenQuantization is MainStorage, MTokenQuantization {

    function fromQuantized(uint256 presumedAssetType, uint256 quantizedAmount)
        internal
        view
        override
        returns (uint256 amount)
    {

        uint256 quantum = getQuantum(presumedAssetType);
        amount = quantizedAmount * quantum;
        require(amount / quantum == quantizedAmount, "DEQUANTIZATION_OVERFLOW");
    }

    function getQuantum(uint256 presumedAssetType) public view override returns (uint256 quantum) {

        if (!registeredAssetType[presumedAssetType]) {
            quantum = 1;
        } else {
            quantum = assetTypeToQuantum[presumedAssetType];
        }
    }

    function toQuantized(uint256 presumedAssetType, uint256 amount)
        internal
        view
        override
        returns (uint256 quantizedAmount)
    {

        uint256 quantum = getQuantum(presumedAssetType);
        require(amount % quantum == 0, "INVALID_AMOUNT");
        quantizedAmount = amount / quantum;
    }
}
pragma solidity ^0.6.11;


abstract contract Withdrawals is
    MainStorage,
    MAcceptModifications,
    MTokenQuantization,
    MTokenAssetData,
    MFreezable,
    MKeyGetters,
    MTokenTransfers
{
    event LogWithdrawalPerformed(
        uint256 ownerKey,
        uint256 assetType,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount,
        address recipient
    );

    event LogNftWithdrawalPerformed(
        uint256 ownerKey,
        uint256 assetType,
        uint256 tokenId,
        uint256 assetId,
        address recipient
    );

    event LogMintWithdrawalPerformed(
        uint256 ownerKey,
        uint256 assetType,
        uint256 nonQuantizedAmount,
        uint256 quantizedAmount,
        uint256 assetId
    );

    function getWithdrawalBalance(uint256 ownerKey, uint256 assetId)
        external
        view
        returns (uint256 balance)
    {
        uint256 presumedAssetType = assetId;
        balance = fromQuantized(presumedAssetType, pendingWithdrawals[ownerKey][assetId]);
    }

    function withdraw(uint256 ownerKey, uint256 assetType) external {
        address payable recipient = payable(strictGetEthKey(ownerKey));
        require(!isMintableAssetType(assetType), "MINTABLE_ASSET_TYPE");
        require(isFungibleAssetType(assetType), "NON_FUNGIBLE_ASSET_TYPE");
        uint256 assetId = assetType;
        uint256 quantizedAmount = pendingWithdrawals[ownerKey][assetId];
        pendingWithdrawals[ownerKey][assetId] = 0;

        transferOut(recipient, assetType, quantizedAmount);
        emit LogWithdrawalPerformed(
            ownerKey,
            assetType,
            fromQuantized(assetType, quantizedAmount),
            quantizedAmount,
            recipient
        );
    }

    function withdrawNft(
        uint256 ownerKey,
        uint256 assetType,
        uint256 tokenId // No notFrozen modifier: This function can always be used, even when frozen.
    ) external {
        address recipient = strictGetEthKey(ownerKey);
        uint256 assetId = calculateNftAssetId(assetType, tokenId);
        require(!isMintableAssetType(assetType), "MINTABLE_ASSET_TYPE");
        require(!isFungibleAssetType(assetType), "FUNGIBLE_ASSET_TYPE");
        require(pendingWithdrawals[ownerKey][assetId] == 1, "ILLEGAL_NFT_BALANCE");
        pendingWithdrawals[ownerKey][assetId] = 0;

        transferOutNft(recipient, assetType, tokenId);
        emit LogNftWithdrawalPerformed(ownerKey, assetType, tokenId, assetId, recipient);
    }

    function withdrawAndMint(
        uint256 ownerKey,
        uint256 assetType,
        bytes calldata mintingBlob
    ) external {
        address recipient = strictGetEthKey(ownerKey);
        require(registeredAssetType[assetType], "INVALID_ASSET_TYPE");
        require(isMintableAssetType(assetType), "NON_MINTABLE_ASSET_TYPE");
        uint256 assetId = calculateMintableAssetId(assetType, mintingBlob);
        require(pendingWithdrawals[ownerKey][assetId] > 0, "NO_PENDING_WITHDRAWAL_BALANCE");
        uint256 quantizedAmount = pendingWithdrawals[ownerKey][assetId];
        pendingWithdrawals[ownerKey][assetId] = 0;
        transferOutMint(assetType, quantizedAmount, recipient, mintingBlob);
        emit LogMintWithdrawalPerformed(
            ownerKey,
            assetType,
            fromQuantized(assetType, quantizedAmount),
            quantizedAmount,
            assetId
        );
    }
}
pragma solidity ^0.6.11;

interface Identity {

    function identify() external pure returns (string memory);

}
pragma solidity ^0.6.11;


interface SubContractor is Identity {

    function initialize(bytes calldata data) external;


    function initializerSize() external view returns (uint256);

}
pragma solidity ^0.6.11;


contract TokensAndRamping is
    ERC721Receiver,
    SubContractor,
    Freezable,
    MainGovernance,
    AcceptModifications,
    StarkExForcedActionState,
    TokenAssetData,
    TokenQuantization,
    TokenRegister,
    TokenTransfers,
    KeyGetters,
    Users,
    Deposits,
    CompositeActions,
    Withdrawals
{

    function initialize(
        bytes calldata /* data */
    ) external override {

        revert("NOT_IMPLEMENTED");
    }

    function initializerSize() external view override returns (uint256) {

        return 0;
    }

    function identify() external pure override returns (string memory) {

        return "StarkWare_TokensAndRamping_2020_1";
    }
}
