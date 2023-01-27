
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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

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
}// MIT

pragma solidity ^0.8.0;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {

    function implementation() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


contract UpgradeableBeacon is IBeacon, Ownable {

    address private _implementation;

    event Upgraded(address indexed implementation);

    constructor(address implementation_) {
        _setImplementation(implementation_);
    }

    function implementation() public view virtual override returns (address) {

        return _implementation;
    }

    function upgradeTo(address newImplementation) public virtual onlyOwner {

        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _setImplementation(address newImplementation) private {

        require(Address.isContract(newImplementation), "UpgradeableBeacon: implementation is not a contract");
        _implementation = newImplementation;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
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

library StringsUpgradeable {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
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

    function toEthSignedMessageHash(bytes memory s) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", StringsUpgradeable.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}// MIT
pragma solidity ^0.8.0;


contract BNPLKYCStore is Initializable, ReentrancyGuardUpgradeable {

    using ECDSAUpgradeable for bytes32;

    mapping(uint32 => address) public publicKeys;
    mapping(uint256 => uint32) public domainPermissions;
    mapping(uint256 => uint32) public userKycStatuses;
    mapping(bytes32 => uint8) public proofUsed;
    mapping(uint32 => uint256) public domainKycMode;

    uint32 public constant PROOF_MAGIC = 0xfc203827;
    uint32 public constant DOMAIN_ADMIN_PERM = 0xffff;
    uint32 public domainCount;

    function encodeKYCUserDomainKey(uint32 domain, address user) internal pure returns (uint256) {

        return (uint256(uint160(user)) << 32) | uint256(domain);
    }

    modifier onlyDomainAdmin(uint32 domain) {

        require(
            domainPermissions[encodeKYCUserDomainKey(domain, msg.sender)] == DOMAIN_ADMIN_PERM,
            "User must be an admin for this domain to perform this action"
        );
        _;
    }

    function getDomainPermissions(uint32 domain, address user) external view returns (uint32) {

        return domainPermissions[encodeKYCUserDomainKey(domain, user)];
    }

    function _setDomainPermissions(
        uint32 domain,
        address user,
        uint32 permissions
    ) internal {

        domainPermissions[encodeKYCUserDomainKey(domain, user)] = permissions;
    }

    function getKYCStatusUser(uint32 domain, address user) public view returns (uint32) {

        return userKycStatuses[encodeKYCUserDomainKey(domain, user)];
    }

    function _verifyProof(
        uint32 domain,
        address user,
        uint32 status,
        uint256 nonce,
        bytes calldata signature
    ) internal {

        require(domain != 0 && domain <= domainCount, "invalid domain");
        require(publicKeys[domain] != address(0), "this domain is disabled");
        bytes32 proofHash = getKYCSignatureHash(domain, user, status, nonce);
        require(proofHash.toEthSignedMessageHash().recover(signature) == publicKeys[domain], "invalid signature");
        require(proofUsed[proofHash] == 0, "proof already used");
        proofUsed[proofHash] = 1;
    }

    function _setKYCStatusUser(
        uint32 domain,
        address user,
        uint32 status
    ) internal {

        userKycStatuses[encodeKYCUserDomainKey(domain, user)] = status;
    }

    function _orKYCStatusUser(
        uint32 domain,
        address user,
        uint32 status
    ) internal {

        userKycStatuses[encodeKYCUserDomainKey(domain, user)] |= status;
    }

    function createNewKYCDomain(
        address admin,
        address publicKey,
        uint256 kycMode
    ) external returns (uint32) {

        require(admin != address(0), "cannot create a kyc domain with an empty user");
        uint32 id = domainCount + 1;
        domainCount = id;
        _setDomainPermissions(id, admin, DOMAIN_ADMIN_PERM);
        publicKeys[id] = publicKey;
        domainKycMode[id] = kycMode;
        return id;
    }

    function setKYCDomainPublicKey(uint32 domain, address newPublicKey) external onlyDomainAdmin(domain) {

        publicKeys[domain] = newPublicKey;
    }

    function setKYCDomainMode(uint32 domain, uint256 mode) external onlyDomainAdmin(domain) {

        domainKycMode[domain] = mode;
    }

    function checkUserBasicBitwiseMode(
        uint32 domain,
        address user,
        uint256 mode
    ) external view returns (uint256) {

        require(domain != 0 && domain <= domainCount, "invalid domain");
        require(
            user != address(0) && ((domainKycMode[domain] & mode) == 0 || (mode & getKYCStatusUser(domain, user) != 0)),
            "invalid user permissions"
        );
        return 1;
    }

    function setKYCStatusUser(
        uint32 domain,
        address user,
        uint32 status
    ) external onlyDomainAdmin(domain) {

        _setKYCStatusUser(domain, user, status);
    }

    function getKYCSignaturePayload(
        uint32 domain,
        address user,
        uint32 status,
        uint256 nonce
    ) public pure returns (bytes memory) {

        return (
            abi.encode(
                ((uint256(PROOF_MAGIC) << 224) |
                    (uint256(uint160(user)) << 64) |
                    (uint256(domain) << 32) |
                    uint256(status)),
                nonce
            )
        );
    }

    function getKYCSignatureHash(
        uint32 domain,
        address user,
        uint32 status,
        uint256 nonce
    ) public pure returns (bytes32) {

        return keccak256(getKYCSignaturePayload(domain, user, status, nonce));
    }

    function orKYCStatusWithProof(
        uint32 domain,
        address user,
        uint32 status,
        uint256 nonce,
        bytes calldata signature
    ) external {

        _verifyProof(domain, user, status, nonce, signature);
        _orKYCStatusUser(domain, user, status);
    }

    function clearKYCStatusWithProof(
        uint32 domain,
        address user,
        uint256 nonce,
        bytes calldata signature
    ) external {

        _verifyProof(domain, user, 1, nonce, signature);
        _setKYCStatusUser(domain, user, 1);
    }

    function initialize() external initializer nonReentrant {

        __ReentrancyGuard_init_unchained();
    }
}// MIT
pragma solidity ^0.8.0;



interface IBNPLProtocolConfig {

    function networkId() external view returns (uint64);


    function networkName() external view returns (string memory);


    function bnplToken() external view returns (IERC20);


    function upBeaconBankNodeManager() external view returns (UpgradeableBeacon);


    function upBeaconBankNode() external view returns (UpgradeableBeacon);


    function upBeaconBankNodeLendingPoolToken() external view returns (UpgradeableBeacon);


    function upBeaconBankNodeStakingPool() external view returns (UpgradeableBeacon);


    function upBeaconBankNodeStakingPoolToken() external view returns (UpgradeableBeacon);


    function upBeaconBankNodeLendingRewards() external view returns (UpgradeableBeacon);


    function upBeaconBNPLKYCStore() external view returns (UpgradeableBeacon);


    function bankNodeManager() external view returns (IBankNodeManager);

}// MIT
pragma solidity ^0.8.0;




interface IBankNodeManager {

    struct LendableToken {
        address tokenContract;
        address swapMarket;
        uint24 swapMarketPoolFee;
        uint8 decimals;
        uint256 valueMultiplier; // USD_VALUE = amount * valueMultiplier / 10**18
        uint16 unusedFundsLendingMode;
        address unusedFundsLendingContract;
        address unusedFundsLendingToken;
        address unusedFundsIncentivesController;
        string symbol;
        string poolSymbol;
    }

    struct BankNode {
        address bankNodeContract;
        address bankNodeToken;
        address bnplStakingPoolContract;
        address bnplStakingPoolToken;
        address lendableToken;
        address creator;
        uint32 id;
        uint64 createdAt;
        uint256 createBlock;
        string nodeName;
        string website;
        string configUrl;
    }

    struct BankNodeDetail {
        uint256 totalAssetsValueBankNode;
        uint256 totalAssetsValueStakingPool;
        uint256 tokensCirculatingBankNode;
        uint256 tokensCirculatingStakingPool;
        uint256 totalLiquidAssetsValue;
        uint256 baseTokenBalanceBankNode;
        uint256 baseTokenBalanceStakingPool;
        uint256 accountsReceivableFromLoans;
        uint256 virtualPoolTokensCount;
        address baseLiquidityToken;
        address poolLiquidityToken;
        bool isNodeDecomissioning;
        uint256 nodeOperatorBalance;
        uint256 loanRequestIndex;
        uint256 loanIndex;
        uint256 valueOfUnusedFundsLendingDeposits;
        uint256 totalLossAllTime;
        uint256 onGoingLoanCount;
        uint256 totalTokensLocked;
        uint256 getUnstakeLockupPeriod;
        uint256 tokensBondedAllTime;
        uint256 poolTokenEffectiveSupply;
        uint256 nodeTotalStaked;
        uint256 nodeBondedBalance;
        uint256 nodeOwnerBNPLRewards;
        uint256 nodeOwnerPoolTokenRewards;
    }

    struct BankNodeData {
        BankNode data;
        BankNodeDetail detail;
    }

    struct CreateBankNodeContractsInput {
        uint32 bankNodeId;
        address operatorAdmin;
        address operator;
        address lendableTokenAddress;
    }
    struct CreateBankNodeContractsOutput {
        address bankNodeContract;
        address bankNodeToken;
        address bnplStakingPoolContract;
        address bnplStakingPoolToken;
    }

    function bankNodeIdExists(uint32 bankNodeId) external view returns (uint256);


    function getBankNodeContract(uint32 bankNodeId) external view returns (address);


    function getBankNodeToken(uint32 bankNodeId) external view returns (address);


    function getBankNodeStakingPoolContract(uint32 bankNodeId) external view returns (address);


    function getBankNodeStakingPoolToken(uint32 bankNodeId) external view returns (address);


    function getBankNodeLendableToken(uint32 bankNodeId) external view returns (address);


    function getBankNodeLoansStatistic()
        external
        view
        returns (uint256 totalAmountOfAllActiveLoans, uint256 totalAmountOfAllLoans);


    function bnplKYCStore() external view returns (BNPLKYCStore);


    function initialize(
        IBNPLProtocolConfig _protocolConfig,
        address _configurator,
        uint256 _minimumBankNodeBondedAmount,
        uint256 _loanOverdueGracePeriod,
        BankNodeLendingRewards _bankNodeLendingRewards,
        BNPLKYCStore _bnplKYCStore
    ) external;


    function enabledLendableTokens(address lendableTokenAddress) external view returns (uint8);


    function lendableTokens(address lendableTokenAddress)
        external
        view
        returns (
            address tokenContract,
            address swapMarket,
            uint24 swapMarketPoolFee,
            uint8 decimals,
            uint256 valueMultiplier, //USD_VALUE = amount * valueMultiplier / 10**18
            uint16 unusedFundsLendingMode,
            address unusedFundsLendingContract,
            address unusedFundsLendingToken,
            address unusedFundsIncentivesController,
            string calldata symbol,
            string calldata poolSymbol
        );


    function bankNodes(uint32 bankNodeId)
        external
        view
        returns (
            address bankNodeContract,
            address bankNodeToken,
            address bnplStakingPoolContract,
            address bnplStakingPoolToken,
            address lendableToken,
            address creator,
            uint32 id,
            uint64 createdAt,
            uint256 createBlock,
            string calldata nodeName,
            string calldata website,
            string calldata configUrl
        );


    function bankNodeAddressToId(address bankNodeAddressTo) external view returns (uint32);


    function minimumBankNodeBondedAmount() external view returns (uint256);


    function loanOverdueGracePeriod() external view returns (uint256);


    function bankNodeCount() external view returns (uint32);


    function bnplToken() external view returns (IERC20);


    function bankNodeLendingRewards() external view returns (BankNodeLendingRewards);


    function protocolConfig() external view returns (IBNPLProtocolConfig);


    function getBankNodeList(
        uint32 start,
        uint32 count,
        bool reverse
    ) external view returns (BankNodeData[] memory, uint32);


    function getBankNodeDetail(address bankNode) external view returns (BankNodeDetail memory);


    function addLendableToken(LendableToken calldata _lendableToken, uint8 enabled) external;


    function setLendableTokenStatus(address tokenContract, uint8 enabled) external;


    function setMinimumBankNodeBondedAmount(uint256 _minimumBankNodeBondedAmount) external;


    function setLoanOverdueGracePeriod(uint256 _loanOverdueGracePeriod) external;


    function createBondedBankNode(
        address operator,
        uint256 tokensToBond,
        address lendableTokenAddress,
        string calldata nodeName,
        string calldata website,
        string calldata configUrl,
        address nodePublicKey,
        uint32 kycMode
    ) external returns (uint32);

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal onlyInitializing {
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

interface IAccessControlUpgradeable {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal onlyInitializing {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal onlyInitializing {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal onlyInitializing {
    }
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlUpgradeable).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        StringsUpgradeable.toHexString(uint160(account), 20),
                        " is missing role ",
                        StringsUpgradeable.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;




contract BankNodeRewardSystem is
    Initializable,
    ReentrancyGuardUpgradeable,
    PausableUpgradeable,
    AccessControlUpgradeable
{

    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    bytes32 public constant REWARDS_DISTRIBUTOR_ROLE = keccak256("REWARDS_DISTRIBUTOR_ROLE");
    bytes32 public constant REWARDS_DISTRIBUTOR_ADMIN_ROLE = keccak256("REWARDS_DISTRIBUTOR_ADMIN_ROLE");

    bytes32 public constant REWARDS_MANAGER = keccak256("REWARDS_MANAGER_ROLE");
    bytes32 public constant REWARDS_MANAGER_ROLE_ADMIN = keccak256("REWARDS_MANAGER_ROLE_ADMIN");


    mapping(uint32 => uint256) public periodFinish;
    mapping(uint32 => uint256) public rewardRate;
    mapping(uint32 => uint256) public rewardsDuration;
    mapping(uint32 => uint256) public lastUpdateTime;
    mapping(uint32 => uint256) public rewardPerTokenStored;

    mapping(uint256 => uint256) public userRewardPerTokenPaid;
    mapping(uint256 => uint256) public rewards;
    mapping(uint32 => uint256) public _totalSupply;
    mapping(uint256 => uint256) private _balances;

    IBankNodeManager public bankNodeManager;
    IERC20 public rewardsToken;
    uint256 public defaultRewardsDuration;

    function encodeUserBankNodeKey(address user, uint32 bankNodeId) public pure returns (uint256) {

        return (uint256(uint160(user)) << 32) | uint256(bankNodeId);
    }

    function decodeUserBankNodeKey(uint256 stakingVaultKey) external pure returns (address user, uint32 bankNodeId) {

        bankNodeId = uint32(stakingVaultKey & 0xffffffff);
        user = address(uint160(stakingVaultKey >> 32));
    }

    function encodeVaultValue(uint256 amount, uint40 depositTime) external pure returns (uint256) {

        require(
            amount <= 0xffffffffffffffffffffffffffffffffffffffffffffffffffffff,
            "cannot encode amount larger than 2^216-1"
        );
        return (amount << 40) | uint256(depositTime);
    }

    function decodeVaultValue(uint256 vaultValue) external pure returns (uint256 amount, uint40 depositTime) {

        depositTime = uint40(vaultValue & 0xffffffffff);
        amount = vaultValue >> 40;
    }

    function _ensureAddressIERC20Not0(address tokenAddress) internal pure returns (IERC20) {

        require(tokenAddress != address(0), "invalid token address!");
        return IERC20(tokenAddress);
    }

    function _ensureContractAddressNot0(address contractAddress) internal pure returns (address) {

        require(contractAddress != address(0), "invalid token address!");
        return contractAddress;
    }

    function getStakingTokenForBankNode(uint32 bankNodeId) internal view returns (IERC20) {

        return _ensureAddressIERC20Not0(bankNodeManager.getBankNodeToken(bankNodeId));
    }

    function getPoolLiquidityTokensStakedInRewards(uint32 bankNodeId) public view returns (uint256) {

        return getStakingTokenForBankNode(bankNodeId).balanceOf(address(this));
    }

    function getInternalValueForStakedTokenAmount(uint256 amount) internal pure returns (uint256) {

        return amount;
    }

    function getStakedTokenAmountForInternalValue(uint256 amount) internal pure returns (uint256) {

        return amount;
    }


    function totalSupply(uint32 bankNodeId) external view returns (uint256) {

        return getStakedTokenAmountForInternalValue(_totalSupply[bankNodeId]);
    }

    function balanceOf(address account, uint32 bankNodeId) external view returns (uint256) {

        return getStakedTokenAmountForInternalValue(_balances[encodeUserBankNodeKey(account, bankNodeId)]);
    }

    function lastTimeRewardApplicable(uint32 bankNodeId) public view returns (uint256) {

        return block.timestamp < periodFinish[bankNodeId] ? block.timestamp : periodFinish[bankNodeId];
    }

    function rewardPerToken(uint32 bankNodeId) public view returns (uint256) {

        if (_totalSupply[bankNodeId] == 0) {
            return rewardPerTokenStored[bankNodeId];
        }
        return
            rewardPerTokenStored[bankNodeId].add(
                lastTimeRewardApplicable(bankNodeId)
                    .sub(lastUpdateTime[bankNodeId])
                    .mul(rewardRate[bankNodeId])
                    .mul(1e18)
                    .div(_totalSupply[bankNodeId])
            );

    }

    function earned(address account, uint32 bankNodeId) public view returns (uint256) {

        uint256 key = encodeUserBankNodeKey(account, bankNodeId);
        return
            ((_balances[key] * (rewardPerToken(bankNodeId) - (userRewardPerTokenPaid[key]))) / 1e18) + (rewards[key]);
    }

    function getRewardForDuration(uint32 bankNodeId) external view returns (uint256) {

        return rewardRate[bankNodeId] * rewardsDuration[bankNodeId];
    }


    function stake(uint32 bankNodeId, uint256 tokenAmount)
        external
        nonReentrant
        whenNotPaused
        updateReward(msg.sender, bankNodeId)
    {

        require(tokenAmount > 0, "Cannot stake 0");
        uint256 amount = getInternalValueForStakedTokenAmount(tokenAmount);
        require(amount > 0, "Cannot stake 0");
        require(getStakedTokenAmountForInternalValue(amount) == tokenAmount, "token amount too high!");
        _totalSupply[bankNodeId] += amount;
        _balances[encodeUserBankNodeKey(msg.sender, bankNodeId)] += amount;
        getStakingTokenForBankNode(bankNodeId).safeTransferFrom(msg.sender, address(this), tokenAmount);
        emit Staked(msg.sender, bankNodeId, tokenAmount);
    }

    function withdraw(uint32 bankNodeId, uint256 tokenAmount) public nonReentrant updateReward(msg.sender, bankNodeId) {

        require(tokenAmount > 0, "Cannot withdraw 0");
        uint256 amount = getInternalValueForStakedTokenAmount(tokenAmount);
        require(amount > 0, "Cannot withdraw 0");
        require(getStakedTokenAmountForInternalValue(amount) == tokenAmount, "token amount too high!");

        _totalSupply[bankNodeId] -= amount;
        _balances[encodeUserBankNodeKey(msg.sender, bankNodeId)] -= amount;
        getStakingTokenForBankNode(bankNodeId).safeTransfer(msg.sender, tokenAmount);
        emit Withdrawn(msg.sender, bankNodeId, tokenAmount);
    }

    function getReward(uint32 bankNodeId) public nonReentrant updateReward(msg.sender, bankNodeId) {

        uint256 reward = rewards[encodeUserBankNodeKey(msg.sender, bankNodeId)];

        if (reward > 0) {
            rewards[encodeUserBankNodeKey(msg.sender, bankNodeId)] = 0;
            rewardsToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, bankNodeId, reward);
        }
    }

    function exit(uint32 bankNodeId) external {

        withdraw(
            bankNodeId,
            getStakedTokenAmountForInternalValue(_balances[encodeUserBankNodeKey(msg.sender, bankNodeId)])
        );
        getReward(bankNodeId);
    }


    function _notifyRewardAmount(uint32 bankNodeId, uint256 reward) internal updateReward(address(0), bankNodeId) {

        if (rewardsDuration[bankNodeId] == 0) {
            rewardsDuration[bankNodeId] = defaultRewardsDuration;
        }
        if (block.timestamp >= periodFinish[bankNodeId]) {
            rewardRate[bankNodeId] = reward / (rewardsDuration[bankNodeId]);
        } else {
            uint256 remaining = periodFinish[bankNodeId] - (block.timestamp);
            uint256 leftover = remaining * (rewardRate[bankNodeId]);
            rewardRate[bankNodeId] = (reward + leftover) / (rewardsDuration[bankNodeId]);
        }

        uint256 balance = rewardsToken.balanceOf(address(this));
        require(rewardRate[bankNodeId] <= (balance / rewardsDuration[bankNodeId]), "Provided reward too high");

        lastUpdateTime[bankNodeId] = block.timestamp;
        periodFinish[bankNodeId] = block.timestamp + (rewardsDuration[bankNodeId]);
        emit RewardAdded(bankNodeId, reward);
    }

    function notifyRewardAmount(uint32 bankNodeId, uint256 reward) external onlyRole(REWARDS_DISTRIBUTOR_ROLE) {

        _notifyRewardAmount(bankNodeId, reward);
    }


    function setRewardsDuration(uint32 bankNodeId, uint256 _rewardsDuration) external onlyRole(REWARDS_MANAGER) {

        require(
            block.timestamp > periodFinish[bankNodeId],
            "Previous rewards period must be complete before changing the duration for the new period"
        );
        rewardsDuration[bankNodeId] = _rewardsDuration;
        emit RewardsDurationUpdated(bankNodeId, rewardsDuration[bankNodeId]);
    }


    modifier updateReward(address account, uint32 bankNodeId) {

        if (rewardsDuration[bankNodeId] == 0) {
            rewardsDuration[bankNodeId] = defaultRewardsDuration;
        }
        rewardPerTokenStored[bankNodeId] = rewardPerToken(bankNodeId);
        lastUpdateTime[bankNodeId] = lastTimeRewardApplicable(bankNodeId);
        if (account != address(0)) {
            uint256 key = encodeUserBankNodeKey(msg.sender, bankNodeId);
            rewards[key] = earned(msg.sender, bankNodeId);
            userRewardPerTokenPaid[key] = rewardPerTokenStored[bankNodeId];
        }
        _;
    }


    event RewardAdded(uint32 indexed bankNodeId, uint256 reward);
    event Staked(address indexed user, uint32 indexed bankNodeId, uint256 amount);
    event Withdrawn(address indexed user, uint32 indexed bankNodeId, uint256 amount);
    event RewardPaid(address indexed user, uint32 indexed bankNodeId, uint256 reward);
    event RewardsDurationUpdated(uint32 indexed bankNodeId, uint256 newDuration);
}// MIT

pragma solidity ^0.8.0;




contract BankNodeLendingRewards is Initializable, BankNodeRewardSystem {

    using SafeERC20 for IERC20;

    function initialize(
        uint256 _defaultRewardsDuration,
        address _rewardsToken,
        address _bankNodeManager,
        address distributorAdmin,
        address managerAdmin
    ) external initializer {

        __ReentrancyGuard_init_unchained();
        __Context_init_unchained();
        __Pausable_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
        rewardsToken = IERC20(_rewardsToken);
        bankNodeManager = IBankNodeManager(_bankNodeManager);
        defaultRewardsDuration = _defaultRewardsDuration;

        _setupRole(REWARDS_DISTRIBUTOR_ROLE, _bankNodeManager);
        _setupRole(REWARDS_DISTRIBUTOR_ROLE, distributorAdmin);
        _setupRole(REWARDS_DISTRIBUTOR_ADMIN_ROLE, distributorAdmin);
        _setRoleAdmin(REWARDS_DISTRIBUTOR_ROLE, REWARDS_DISTRIBUTOR_ADMIN_ROLE);

        _setupRole(REWARDS_MANAGER, _bankNodeManager);
        _setupRole(REWARDS_MANAGER, managerAdmin);
        _setupRole(REWARDS_MANAGER_ROLE_ADMIN, managerAdmin);
        _setRoleAdmin(REWARDS_MANAGER, REWARDS_MANAGER_ROLE_ADMIN);
    }

    function _bnplTokensStakedToBankNode(uint32 bankNodeId) internal view returns (uint256) {

        return
            rewardsToken.balanceOf(
                _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(bankNodeId))
            );
    }

    function getBNPLTokenDistribution(uint256 amount) external view returns (uint256[] memory) {

        uint32 nodeCount = bankNodeManager.bankNodeCount();
        uint256[] memory bnplTokensPerNode = new uint256[](nodeCount);
        uint32 i = 0;
        uint256 amt = 0;
        uint256 total = 0;
        while (i < nodeCount) {
            amt = rewardsToken.balanceOf(
                _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(i + 1))
            );
            bnplTokensPerNode[i] = amt;
            total += amt;
            i += 1;
        }
        i = 0;
        while (i < nodeCount) {
            bnplTokensPerNode[i] = (bnplTokensPerNode[i] * amount) / total;
            i += 1;
        }
        return bnplTokensPerNode;
    }

    function distributeBNPLTokensToBankNodes(uint256 amount)
        external
        onlyRole(REWARDS_DISTRIBUTOR_ROLE)
        returns (uint256)
    {

        require(amount > 0, "cannot send 0");
        rewardsToken.safeTransferFrom(msg.sender, address(this), amount);
        uint32 nodeCount = bankNodeManager.bankNodeCount();
        uint256[] memory bnplTokensPerNode = new uint256[](nodeCount);
        uint32 i = 0;
        uint256 amt = 0;
        uint256 total = 0;
        while (i < nodeCount) {
            if (getPoolLiquidityTokensStakedInRewards(i + 1) != 0) {
                amt = rewardsToken.balanceOf(
                    _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(i + 1))
                );
                bnplTokensPerNode[i] = amt;
                total += amt;
            }
            i += 1;
        }
        i = 0;
        while (i < nodeCount) {
            amt = (bnplTokensPerNode[i] * amount) / total;
            if (amt != 0) {
                _notifyRewardAmount(i + 1, amt);
            }
            i += 1;
        }
        return total;
    }

    function distributeBNPLTokensToBankNodes2(uint256 amount)
        external
        onlyRole(REWARDS_DISTRIBUTOR_ROLE)
        returns (uint256)
    {

        uint32 nodeCount = bankNodeManager.bankNodeCount();
        uint32 i = 0;
        uint256 amt = 0;
        uint256 total = 0;
        while (i < nodeCount) {
            total += rewardsToken.balanceOf(
                _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(i + 1))
            );
            i += 1;
        }
        i = 0;
        while (i < nodeCount) {
            amt =
                (rewardsToken.balanceOf(
                    _ensureContractAddressNot0(bankNodeManager.getBankNodeStakingPoolContract(i + 1))
                ) * amount) /
                total;
            if (amt != 0) {
                _notifyRewardAmount(i + 1, amt);
            }
            i += 1;
        }
        return total;
    }
}