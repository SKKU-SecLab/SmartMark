
pragma solidity ^0.8.0;

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;

library ECDSAUpgradeable {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert("ECDSA: invalid signature");
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert("ECDSA: invalid signature length");
        } else if (error == RecoverError.InvalidSignatureS) {
            revert("ECDSA: invalid signature 's' value");
        } else if (error == RecoverError.InvalidSignatureV) {
            revert("ECDSA: invalid signature 'v' value");
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature) internal pure returns (address, RecoverError) {

        if (signature.length == 65) {
            bytes32 r;
            bytes32 s;
            uint8 v;
            assembly {
                r := mload(add(signature, 0x20))
                s := mload(add(signature, 0x40))
                v := byte(0, mload(add(signature, 0x60)))
            }
            return tryRecover(hash, v, r, s);
        } else if (signature.length == 64) {
            bytes32 r;
            bytes32 vs;
            assembly {
                r := mload(add(signature, 0x20))
                vs := mload(add(signature, 0x40))
            }
            return tryRecover(hash, r, vs);
        } else {
            return (address(0), RecoverError.InvalidSignatureLength);
        }
    }

    function recover(bytes32 hash, bytes memory signature) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, signature);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address, RecoverError) {

        bytes32 s;
        uint8 v;
        assembly {
            s := and(vs, 0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            v := add(shr(255, vs), 27)
        }
        return tryRecover(hash, v, r, s);
    }

    function recover(
        bytes32 hash,
        bytes32 r,
        bytes32 vs
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, r, vs);
        _throwError(error);
        return recovered;
    }

    function tryRecover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address, RecoverError) {

        if (uint256(s) > 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0) {
            return (address(0), RecoverError.InvalidSignatureS);
        }
        if (v != 27 && v != 28) {
            return (address(0), RecoverError.InvalidSignatureV);
        }

        address signer = ecrecover(hash, v, r, s);
        if (signer == address(0)) {
            return (address(0), RecoverError.InvalidSignature);
        }

        return (signer, RecoverError.NoError);
    }

    function recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        (address recovered, RecoverError error) = tryRecover(hash, v, r, s);
        _throwError(error);
        return recovered;
    }

    function toEthSignedMessageHash(bytes32 hash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;


interface IERC721KeyPassUAEUpgradeable is IERC721Upgradeable, IERC721MetadataUpgradeable, IERC721EnumerableUpgradeable {

    function owner() external view returns (address);

    function getOwner() external view returns (address);

    function paused() external view returns (bool);

    function exists(uint256 tokenId) external view returns (bool);

    function getMaxTotalSupply() external pure returns (uint256);

    function getTotalSupply() external view returns (uint256);

    function stats() external view returns (uint256 maxTotalSupply, uint256 totalSupply, uint256 supplyLeft);

    function isTrustedMinter(address account) external view returns (bool);

    function royaltyParams() external view returns (address royaltyAddress, uint256 royaltyPercent);

    function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount);


    function burn(uint256 tokenId) external;


    function mintTokenBatch(address recipient, uint256 tokenCount) external;

}// MIT

pragma solidity ^0.8.0;


contract SwapERC721KeyPassUAEUpgradeable is Initializable, ContextUpgradeable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using ECDSAUpgradeable for bytes32;

    address private _erc721KeyPassAddress;
    address private _trustedSignerAddress;

    struct PlanData {
        uint256 tokenAmount;
        uint256 tokenAmountLimit;
        uint256 tokenPrice;
        uint256 tokenPerClaimLimit;
        uint256 ethAmount;
    }
    PlanData private _freePlan;
    PlanData private _paidPlan;

    struct StageData {
        bool mintingEnabled;
        bool whitelistRequired;
        bool firstClaimFree;
        uint256 ethAmount;
        uint256 totalClaimedFreeTokens;
        uint256 totalClaimedPaidTokens;
    }
    mapping(uint256 => StageData) private _stages;
    uint256 private _currentStageId;

    mapping(address => uint256) private _claimedFreeTokens;
    mapping(address => uint256) private _claimedPaidTokens;

    event TrustedSignerAddressUpdated(address trustedSignerAddress);

    event StageUpdated(uint256 stageId, bool mintingEnabled, bool whitelistRequired, bool firstMintFree);
    event CurrentStageUpdated(uint256 stageId);
    event PlanConfigUpdated(uint256 freeTokenAmountLimit, uint256 paidTokenAmountLimit, uint256 paidTokenPrice);

    event TokenClaimed(uint256 stageId, address indexed account, uint256 tokenAmount, uint256 ethAmount);

    event EthWithdrawal(address account, uint256 ethAmount);

    function initialize(
        address erc721KeyPassAddress_,
        address trustedSignerAddress_,
        uint256 freeTokenAmountLimit_,
        uint256 paidTokenAmountLimit_,
        uint256 paidTokenPrice_
    ) public virtual initializer {

        __SwapERC721KeyPassUAE_init(
            erc721KeyPassAddress_,
            trustedSignerAddress_,
            freeTokenAmountLimit_,
            paidTokenAmountLimit_,
            paidTokenPrice_
        );
    }

    function __SwapERC721KeyPassUAE_init(
        address erc721KeyPassAddress_,
        address trustedSignerAddress_,
        uint256 freeTokenAmountLimit_,
        uint256 paidTokenAmountLimit_,
        uint256 paidTokenPrice_
    ) internal initializer {

        __Context_init_unchained();
        __Ownable_init_unchained();
        __Pausable_init_unchained();
        __ReentrancyGuard_init_unchained();
        __SwapERC721KeyPassUAE_init_unchained(
            erc721KeyPassAddress_,
            trustedSignerAddress_,
            freeTokenAmountLimit_,
            paidTokenAmountLimit_,
            paidTokenPrice_
        );
    }

    function __SwapERC721KeyPassUAE_init_unchained(
        address erc721KeyPassAddress_,
        address trustedSignerAddress_,
        uint256 freeTokenAmountLimit_,
        uint256 paidTokenAmountLimit_,
        uint256 paidTokenPrice_
    ) internal initializer {

        require(erc721KeyPassAddress_ != address(0), "SwapERC721KeyPassUAE: invalid address");
        require(trustedSignerAddress_ != address(0), "SwapERC721KeyPassUAE: invalid address");
        require(freeTokenAmountLimit_ != 0, "SwapERC721KeyPassUAE: invalid token amount limit");
        require(paidTokenAmountLimit_ != 0, "SwapERC721KeyPassUAE: invalid token amount limit");
        require(paidTokenPrice_ != 0, "SwapERC721KeyPassUAE: invalid token price");

        _erc721KeyPassAddress = erc721KeyPassAddress_;
        _trustedSignerAddress = trustedSignerAddress_;

        _freePlan = PlanData(0, freeTokenAmountLimit_, 0, 0, 0);
        _paidPlan = PlanData(0, paidTokenAmountLimit_, paidTokenPrice_, 1, 0);
    }

    function erc721KeyPassAddress() external view virtual returns (address) {

        return _erc721KeyPassAddress;
    }

    function trustedSignerAddress() external view virtual returns (address) {

        return _trustedSignerAddress;
    }

    function freePlanInfo() external view virtual returns (
        uint256 tokenAmount,
        uint256 tokenAmountLimit,
        uint256 tokenPrice,
        uint256 tokenPerClaimLimit,
        uint256 ethAmount
    ) {

        return (
            _freePlan.tokenAmount,
            _freePlan.tokenAmountLimit,
            _freePlan.tokenPrice,
            _freePlan.tokenPerClaimLimit,
            _freePlan.ethAmount
        );
    }

    function paidPlanInfo() external view virtual returns (
        uint256 tokenAmount,
        uint256 tokenAmountLimit,
        uint256 tokenPrice,
        uint256 tokenPerClaimLimit,
        uint256 ethAmount
    ) {

        return (
            _paidPlan.tokenAmount,
            _paidPlan.tokenAmountLimit,
            _paidPlan.tokenPrice,
            _paidPlan.tokenPerClaimLimit,
            _paidPlan.ethAmount
        );
    }

    function currentStageId() external view virtual returns (uint256) {

        return _currentStageId;
    }

    function getStageInfo(uint256 stageId_)
        external
        view
        virtual
        returns (
            bool mintingEnabled,
            bool whitelistRequired,
            bool firstClaimFree,
            uint256 ethAmount,
            uint256 totalClaimedFreeTokens,
            uint256 totalClaimedPaidTokens
        )
    {

        StageData storage stage = _stages[stageId_];
        return (
            stage.mintingEnabled,
            stage.whitelistRequired,
            stage.firstClaimFree,
            stage.ethAmount,
            stage.totalClaimedFreeTokens,
            stage.totalClaimedPaidTokens
        );
    }

    function getAddressClaimInfo(address address_) external view virtual returns (uint256 freeTokens, uint256 paidTokens) {

        return (
            _claimedFreeTokens[address_],
            _claimedPaidTokens[address_]
        );
    }

    function checkBeforeClaim(address address_, bool isWhitelisted_) public view virtual returns (bool shouldBeFreeClaim, uint256 tokenPerClaimLimit, uint256 tokenPrice) {

        require(address_ != address(0), "SwapERC721KeyPassUAE: invalid address");
        require(!paused(), "SwapERC721KeyPassUAE: contract is paused");
        require(!IERC721KeyPassUAEUpgradeable(_erc721KeyPassAddress).paused(), "SwapERC721KeyPassUAE: erc721 is paused");
        require(IERC721KeyPassUAEUpgradeable(_erc721KeyPassAddress).isTrustedMinter(address(this)), "SwapERC721KeyPassUAE: erc721 wrong trusted minter");
        StageData storage stage = _stages[_currentStageId];
        require(stage.mintingEnabled, "SwapERC721KeyPassUAE: stage minting disabled");
        require(!stage.whitelistRequired || (stage.whitelistRequired && isWhitelisted_), "SwapERC721KeyPassUAE: address is not whitelisted");
        shouldBeFreeClaim = stage.firstClaimFree && _claimedFreeTokens[address_] == 0;
        if (shouldBeFreeClaim) {
            tokenPerClaimLimit = _freePlan.tokenPerClaimLimit;
            tokenPrice = _freePlan.tokenPrice;
        } else {
            tokenPerClaimLimit = _paidPlan.tokenPerClaimLimit;
            tokenPrice = _paidPlan.tokenPrice;
        }
        return (
            shouldBeFreeClaim,
            tokenPerClaimLimit,
            tokenPrice
        );
    }

    function claimToken(
        bool isWhitelisted_,
        bool isFreeClaim_,
        uint256 ethAmount_,
        uint256 tokenAmount_,
        uint256 nonce_,
        uint256 salt_,
        uint256 maxBlockNumber_,
        bytes memory signature_
    ) external virtual payable nonReentrant whenNotPaused {

        bytes32 hash = keccak256(abi.encodePacked(_msgSender(), isWhitelisted_, isFreeClaim_, ethAmount_, tokenAmount_, nonce_, salt_, maxBlockNumber_));
        address signer = hash.toEthSignedMessageHash().recover(signature_);
        require(signer == _trustedSignerAddress, "SwapERC721KeyPassUAE: invalid signature");
        require(block.number <= maxBlockNumber_, "SwapERC721KeyPassUAE: failed max block check");
        (bool shouldBeFreeClaim, uint256 tokenPerClaimLimit, uint256 tokenPrice) = checkBeforeClaim(_msgSender(), isWhitelisted_);
        require(shouldBeFreeClaim == isFreeClaim_, "SwapERC721KeyPassUAE: invalid isFreeClaim flag");
        require((tokenPerClaimLimit == 0) || (tokenPerClaimLimit == tokenAmount_), "SwapERC721KeyPassUAE: invalid token amount");
        require(ethAmount_ == tokenAmount_ * tokenPrice, "SwapERC721KeyPassUAE: invalid ETH amount");
        if (isFreeClaim_) {
            _freePlanClaim(_msgSender(), tokenAmount_, ethAmount_);
        } else {
            _paidPlanClaim(_msgSender(), tokenAmount_, ethAmount_);
        }
    }

    function pause() external virtual onlyOwner {

        _pause();
    }

    function unpause() external virtual onlyOwner {

        _unpause();
    }

    function updateTrustedSignerAddress(address trustedSignerAddress_) external virtual onlyOwner {

        require(trustedSignerAddress_ != address(0), "SwapERC721KeyPassUAE: invalid address");
        _trustedSignerAddress = trustedSignerAddress_;
        emit TrustedSignerAddressUpdated(trustedSignerAddress_);
    }

    function updateCurrentStageId(uint256 stageId_) external virtual onlyOwner {

        _currentStageId = stageId_;
        emit CurrentStageUpdated(stageId_);
    }

    function updatePlanConfig(
        uint256 freeTokenAmountLimit_,
        uint256 paidTokenAmountLimit_,
        uint256 paidTokenPrice_
    ) external virtual onlyOwner {

        require(freeTokenAmountLimit_ != 0 && _freePlan.tokenAmount <= freeTokenAmountLimit_, "SwapERC721KeyPassUAE: invalid token amount limit");
        require(paidTokenAmountLimit_ != 0 && _paidPlan.tokenAmount <= paidTokenAmountLimit_, "SwapERC721KeyPassUAE: invalid token amount limit");
        require(paidTokenPrice_ != 0, "SwapERC721KeyPassUAE: invalid token price");
        _freePlan.tokenAmountLimit = freeTokenAmountLimit_;
        _paidPlan.tokenAmountLimit = paidTokenAmountLimit_;
        _paidPlan.tokenPrice = paidTokenPrice_;
        emit PlanConfigUpdated(freeTokenAmountLimit_, paidTokenAmountLimit_, paidTokenPrice_);
    }

    function updateStage(uint256 stageId_, bool mintingEnabled_, bool whitelistRequired_, bool firstMintFree_) external virtual onlyOwner {

        require(stageId_ != 0, "SwapERC721KeyPassUAE: invalid stageId");
        StageData storage stage = _stages[stageId_];
        stage.mintingEnabled = mintingEnabled_;
        stage.whitelistRequired = whitelistRequired_;
        stage.firstClaimFree = firstMintFree_;
        emit StageUpdated(stageId_, mintingEnabled_, whitelistRequired_, firstMintFree_);
    }

    function ethWithdrawal(address payable recipient_) external virtual onlyOwner {

        require(recipient_ != address(0), "SwapERC721KeyPassUAE: invalid address");
        uint256 ethAmount = address(this).balance;
        AddressUpgradeable.sendValue(recipient_, ethAmount);
        emit EthWithdrawal(recipient_, ethAmount);
    }

    function _freePlanClaim(address recipient_, uint256 tokenAmount_, uint256 ethAmount_) internal virtual {

        require(recipient_ != address(0), "SwapERC721KeyPassUAE: invalid address");
        require(tokenAmount_ != 0, "SwapERC721KeyPassUAE: invalid token amount");
        require((ethAmount_ == 0) && (ethAmount_ == msg.value), "SwapERC721KeyPassUAE: invalid ETH amount");
        require((_freePlan.tokenAmount + tokenAmount_) <= _freePlan.tokenAmountLimit, "SwapERC721KeyPassUAE: total amount limit reached");
        StageData storage stage = _stages[_currentStageId];
        require(stage.mintingEnabled, "SwapERC721KeyPassUAE: stage minting disabled");
        _claimedFreeTokens[recipient_] += tokenAmount_;
        _freePlan.tokenAmount += tokenAmount_;
        stage.totalClaimedFreeTokens += tokenAmount_;
        IERC721KeyPassUAEUpgradeable(_erc721KeyPassAddress).mintTokenBatch(recipient_, tokenAmount_);
        emit TokenClaimed(_currentStageId, recipient_, tokenAmount_, ethAmount_);
    }

    function _paidPlanClaim(address recipient_, uint256 tokenAmount_, uint256 ethAmount_) internal virtual {

        require(recipient_ != address(0), "SwapERC721KeyPassUAE: invalid address");
        require(tokenAmount_ != 0, "SwapERC721KeyPassUAE: invalid token amount");
        require((ethAmount_ > 0) && (ethAmount_ == msg.value), "SwapERC721KeyPassUAE: invalid ETH amount");
        require((_paidPlan.tokenAmount + tokenAmount_) <= _paidPlan.tokenAmountLimit, "SwapERC721KeyPassUAE: total amount limit reached");
        StageData storage stage = _stages[_currentStageId];
        require(stage.mintingEnabled, "SwapERC721KeyPassUAE: stage minting disabled");
        _claimedPaidTokens[recipient_] += tokenAmount_;
        _paidPlan.ethAmount += ethAmount_;
        _paidPlan.tokenAmount += tokenAmount_;
        stage.ethAmount += ethAmount_;
        stage.totalClaimedPaidTokens += tokenAmount_;
        IERC721KeyPassUAEUpgradeable(_erc721KeyPassAddress).mintTokenBatch(recipient_, tokenAmount_);
        emit TokenClaimed(_currentStageId, recipient_, tokenAmount_, ethAmount_);
    }
}