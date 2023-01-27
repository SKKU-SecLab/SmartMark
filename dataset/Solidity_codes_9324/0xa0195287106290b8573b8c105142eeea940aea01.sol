
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
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

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal onlyInitializing {
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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
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
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
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

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
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


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
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

pragma solidity ^0.8.4;

interface IWebacyProxyFactory {

    function createProxyContract(address _memberAddress) external;


    function deployedContractFromMember(address _memberAddress) external view returns (address);


    function setWebacyAddress(address _webacyAddress) external;


    function pauseContract() external;


    function unpauseContract() external;

}// MIT

pragma solidity ^0.8.4;

interface IWebacyProxy {

    function transferErc20TokensAllowed(
        address _contractAddress,
        address _ownerAddress,
        address _recipentAddress,
        uint256 _amount
    ) external;


    function transferErc721TokensAllowed(
        address _contractAddress,
        address _ownerAddress,
        address _recipentAddress,
        uint256 _tokenId
    ) external;


    function pauseContract() external;


    function unpauseContract() external;

}// MIT

pragma solidity ^0.8.4;


contract WebacyBusinessU is Initializable, AccessControlUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

    using SafeERC20Upgradeable for IERC20Upgradeable;
    IWebacyProxyFactory public proxyFactory;
    uint256 public transferFee;

    struct AssetBeneficiary {
        address desAddress;
        uint256 tokenId;
    }

    struct TokenBeneficiary {
        address desAddress;
        uint8 percent;
    }

    struct ERC20TokenStatus {
        address newOwner;
        uint256 amountTransferred;
        bool transferred;
    }

    struct ERC721TokenStatus {
        address newOwner;
        uint256 tokenIdTransferred;
        bool transferred;
    }

    struct ERC20Token {
        address scAddress;
        TokenBeneficiary[] tokenBeneficiaries;
        uint256 amount;
    }

    struct ERC721Token {
        address scAddress;
        AssetBeneficiary[] assetBeneficiaries;
    }

    struct TransferredERC20 {
        address scAddress;
        ERC20TokenStatus erc20TokenStatus;
    }

    struct TransferredERC721 {
        address scAddress;
        ERC721TokenStatus[] erc721TokenStatus;
    }

    struct Assets {
        ERC721Token[] erc721;
        address[] backupAddresses;
        ERC20Token[] erc20;
        TransferredERC20[] transferredErc20;
        TransferredERC721[] transferredErc721;
    }

    mapping(address => address) private beneficiaryToMember;

    mapping(address => address[]) private memberToERC721Contracts;
    mapping(address => mapping(address => AssetBeneficiary[])) private memberToContractToAssetBeneficiary;
    mapping(address => mapping(address => address)) private assetBeneficiaryToContractToMember;
    mapping(address => mapping(address => ERC721TokenStatus[])) private memberToContractToAssetStatus;

    mapping(address => address[]) private memberToERC20Contracts;
    mapping(address => mapping(address => uint256)) private memberToContractToAllowableAmount;
    mapping(address => mapping(address => TokenBeneficiary[])) private memberToContractToTokenBeneficiaries;
    mapping(address => mapping(address => address)) private tokenBeneficiaryToContractToMember;
    mapping(address => mapping(address => ERC20TokenStatus)) private memberToContractToTokenStatus;

    mapping(address => address[]) private memberToBackupWallets;
    mapping(address => address) private backupWalletToMember;

    address[] private contractBalances;
    mapping(address => bool) private hasBalance;


    bytes32 public constant MEMBERSHIP_ROLE = keccak256("MEMBERSHIP_ROLE");

    mapping(address => bool) public haveToPayUpdate;

    event FeesWithdrawed(address _value);
    event AmountUpdated(string _type, uint256 _value);
    event AddressUpdated(string _type, address _value);

    function initialize(address _proxyFactoryAddress) external initializer {

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        proxyFactory = IWebacyProxyFactory(_proxyFactoryAddress);
        transferFee = 1;
    }

    modifier hasPaidMembership(address _address) {

        address memberContract = address(proxyFactory.deployedContractFromMember(_address));
        require(memberContract != address(0x0), "Sender has no paid membership");
        _;
    }

    function _checkZeroAddress(address _address) internal pure {

        require(_address != address(0), "Zero address");
    }

    function getMemberFromBackup(address _address) external view returns (address) {

        return backupWalletToMember[_address];
    }

    function getMemberFromBeneficiary(address _address) external view returns (address) {

        return beneficiaryToMember[_address];
    }

    function storeERC20Data(
        address contractAddress,
        address[] memory destinationAddresses,
        uint8[] memory destinationPercents,
        uint256 amount,
        address[] memory backupAddresses
    ) external whenNotPaused hasPaidMembership(msg.sender) {

        if (!haveToPayUpdate[msg.sender]) {
            haveToPayUpdate[msg.sender] = true;
        }

        _checkZeroAddress(contractAddress);
        require(destinationAddresses.length == destinationPercents.length, "Equally size arrays required");
        require(amount > 0, "Invalid amount");

        _saveBackupWallet(backupAddresses);

        require(memberToContractToAllowableAmount[msg.sender][contractAddress] == 0, "ERC20 already stored for member");

        memberToERC20Contracts[msg.sender].push(contractAddress);
        memberToContractToAllowableAmount[msg.sender][contractAddress] = amount;

        for (uint256 i = 0; i < destinationAddresses.length; i++) {
            require(destinationPercents[i] >= 0 && destinationPercents[i] <= 100, "Percent must be in range 0-100");
            TokenBeneficiary memory tokenB = TokenBeneficiary(address(0), 0);
            tokenB.desAddress = destinationAddresses[i];
            tokenB.percent = destinationPercents[i];
            _isValidBeneficiary(tokenB.desAddress, contractAddress);
            tokenBeneficiaryToContractToMember[tokenB.desAddress][contractAddress] = msg.sender;
            beneficiaryToMember[tokenB.desAddress] = msg.sender;
            memberToContractToTokenBeneficiaries[msg.sender][contractAddress].push(tokenB);
        }
    }

    function storeERC721Data(
        address contractAddress,
        address[] memory destinationAddresses,
        uint256[] memory destinationTokenIds,
        address[] memory backupAddresses
    ) external whenNotPaused hasPaidMembership(msg.sender) {

        if (!haveToPayUpdate[msg.sender]) {
            haveToPayUpdate[msg.sender] = true;
        }

        require(destinationAddresses.length == destinationTokenIds.length, "Equally size arrays required");

        _saveBackupWallet(backupAddresses);

        AssetBeneficiary[] memory assetBeneficiaries = memberToContractToAssetBeneficiary[msg.sender][contractAddress];

        require(assetBeneficiaries.length == 0, "ERC721 already stored for member");

        memberToERC721Contracts[msg.sender].push(contractAddress);

        require(destinationTokenIds.length != 0, "No empty token ids allowed");

        for (uint256 i = 0; i < destinationAddresses.length; i++) {
            AssetBeneficiary memory assetB = AssetBeneficiary(address(0), 0);
            assetB.desAddress = destinationAddresses[i];
            assetB.tokenId = destinationTokenIds[i];
            _validateERC721CollectibleNotYetAssigned(contractAddress, assetB.tokenId);
            memberToContractToAssetBeneficiary[msg.sender][contractAddress].push(assetB);
            assetBeneficiaryToContractToMember[destinationAddresses[i]][contractAddress] = msg.sender;
            beneficiaryToMember[destinationAddresses[i]] = msg.sender;
        }
    }

    function getApprovedAssets(address owner) external view returns (Assets memory) {

        address[] memory erc20Contracts = memberToERC20Contracts[owner];

        address[] memory backupWallets = memberToBackupWallets[owner];

        address[] memory erc721Contracts = memberToERC721Contracts[owner];

        Assets memory assets = Assets(
            new ERC721Token[](erc721Contracts.length),
            new address[](backupWallets.length),
            new ERC20Token[](erc20Contracts.length),
            new TransferredERC20[](erc20Contracts.length),
            new TransferredERC721[](erc721Contracts.length)
        );

        for (uint256 i = 0; i < erc721Contracts.length; i++) {
            AssetBeneficiary[] memory assetBeneficiaries = memberToContractToAssetBeneficiary[owner][
                erc721Contracts[i]
            ];
            assets.erc721[i].assetBeneficiaries = assetBeneficiaries;
            assets.erc721[i].scAddress = erc721Contracts[i];

            ERC721TokenStatus[] memory assetsStatus = memberToContractToAssetStatus[owner][erc721Contracts[i]];
            assets.transferredErc721[i].scAddress = erc721Contracts[i];
            assets.transferredErc721[i].erc721TokenStatus = assetsStatus;
        }

        for (uint256 i = 0; i < backupWallets.length; i++) {
            assets.backupAddresses[i] = backupWallets[i];
        }

        for (uint256 i = 0; i < erc20Contracts.length; i++) {
            TokenBeneficiary[] memory tokenBeneficiaries = memberToContractToTokenBeneficiaries[owner][
                erc20Contracts[i]
            ];
            assets.erc20[i].tokenBeneficiaries = tokenBeneficiaries;
            assets.erc20[i].scAddress = erc20Contracts[i];
            assets.erc20[i].amount = memberToContractToAllowableAmount[owner][erc20Contracts[i]];
            ERC20TokenStatus memory tokenStatus = memberToContractToTokenStatus[owner][erc20Contracts[i]];
            if (tokenStatus.newOwner != address(0)) {
                assets.transferredErc20[i].scAddress = erc20Contracts[i];
                assets.transferredErc20[i].erc20TokenStatus = tokenStatus;
            }
        }

        return assets;
    }

    function _saveBackupWallet(address[] memory backupAddresses) private {

        if (memberToBackupWallets[msg.sender].length == 0) {
            for (uint256 i = 0; i < backupAddresses.length; i++) {
                _checkZeroAddress(backupAddresses[i]);
                require(backupWalletToMember[backupAddresses[i]] == address(0), "Backup already exists");
                backupWalletToMember[backupAddresses[i]] = msg.sender;
                memberToBackupWallets[msg.sender].push(backupAddresses[i]);
            }
        }
    }

    function _validateERC721CollectibleNotYetAssigned(address _contractAddress, uint256 _tokenId) private view {

        AssetBeneficiary[] memory assetBeneficiaries = memberToContractToAssetBeneficiary[msg.sender][_contractAddress];
        for (uint256 i = 0; i < assetBeneficiaries.length; i++) {
            if (assetBeneficiaries[i].tokenId == _tokenId) {
                require(!(assetBeneficiaries[i].tokenId == _tokenId), "TokenId exists on contract");
            }
        }
    }

    function _isValidBeneficiary(address _destinationAddress, address _contractAddress) private view {

        _checkZeroAddress(_destinationAddress);
        require(
            tokenBeneficiaryToContractToMember[_destinationAddress][_contractAddress] == address(0),
            "Beneficiary already exists"
        );
    }

    function _validateERC721SCExists(address _contractAddress, address _owner) private view {

        AssetBeneficiary[] memory assetBeneficiaries = memberToContractToAssetBeneficiary[_owner][_contractAddress];
        require(assetBeneficiaries.length > 0, "ERC721 address not exists");
    }

    function _validateERC721CollectibleExists(
        address _contractAddress,
        address _owner,
        uint256 _tokenId
    ) private view {

        AssetBeneficiary[] memory assetBeneficiaries = memberToContractToAssetBeneficiary[_owner][_contractAddress];
        bool exists = false;
        for (uint256 i = 0; i < assetBeneficiaries.length; i++) {
            if (assetBeneficiaries[i].tokenId == _tokenId) {
                exists = true;
                break;
            }
        }
        require(exists, "ERC721 tokenId not exists");
    }

    function _validateTokenOwnership(
        address _contractAddress,
        address _owner,
        uint256 _tokenId
    ) private view returns (bool) {

        bool isStillOwner = false;
        address newOwner = IERC721Upgradeable(_contractAddress).ownerOf(_tokenId);
        if (_owner == newOwner) {
            isStillOwner = true;
        }
        return isStillOwner;
    }

    function transferAssets(
        address[] memory _erc20contracts,
        address[] memory _erc721contracts,
        uint256[][] memory _erc721tokensId
    ) external whenNotPaused nonReentrant {

        require(backupWalletToMember[msg.sender] != address(0), "Associated member not found");
        address member = backupWalletToMember[msg.sender];
        address webacyProxyForMember = address(proxyFactory.deployedContractFromMember(member));
        if (_erc20contracts.length != 0) {
            for (uint256 i = 0; i < _erc20contracts.length; i++) {
                require(
                    memberToContractToAllowableAmount[member][_erc20contracts[i]] != 0,
                    "Contract address not exists"
                );

                uint256 amount = memberToContractToAllowableAmount[member][_erc20contracts[i]];

                uint256 currentAmount = IERC20Upgradeable(_erc20contracts[i]).balanceOf(member);

                if (currentAmount < amount) {
                    amount = currentAmount;
                }

                uint256 feeAmount = calculatePercentage(amount, transferFee);
                uint256 transferAmount = calculatePercentage(amount, 100 - transferFee);

                require(
                    !(memberToContractToTokenStatus[member][_erc20contracts[i]].transferred),
                    "Token already transferred"
                );

                if (!(hasBalance[_erc20contracts[i]])) {
                    hasBalance[_erc20contracts[i]] = true;
                    contractBalances.push(_erc20contracts[i]);
                }
                memberToContractToTokenStatus[member][_erc20contracts[i]] = ERC20TokenStatus(msg.sender, amount, true);

                try
                    IWebacyProxy(webacyProxyForMember).transferErc20TokensAllowed(
                        _erc20contracts[i],
                        member,
                        msg.sender,
                        transferAmount
                    )
                {
                    IWebacyProxy(webacyProxyForMember).transferErc20TokensAllowed(
                        _erc20contracts[i],
                        member,
                        address(this),
                        feeAmount
                    );
                } catch {
                    delete memberToContractToTokenStatus[msg.sender][_erc20contracts[i]];
                }
            }
        }

        if (_erc721contracts.length != 0) {
            require(_erc721contracts.length == _erc721tokensId.length, "ERC721 equally arrays required");
            for (uint256 iContracts = 0; iContracts < _erc721contracts.length; iContracts++) {
                _validateERC721SCExists(_erc721contracts[iContracts], member);
                for (uint256 iTokensId = 0; iTokensId < _erc721tokensId[iContracts].length; iTokensId++) {
                    _validateERC721CollectibleExists(
                        _erc721contracts[iContracts],
                        member,
                        _erc721tokensId[iContracts][iTokensId]
                    );
                    bool isOwner = _validateTokenOwnership(
                        _erc721contracts[iContracts],
                        member,
                        _erc721tokensId[iContracts][iTokensId]
                    );
                    if (isOwner) {
                        memberToContractToAssetStatus[member][_erc721contracts[iContracts]].push(
                            ERC721TokenStatus(msg.sender, _erc721tokensId[iContracts][iTokensId], true)
                        );

                        try
                            IWebacyProxy(webacyProxyForMember).transferErc721TokensAllowed(
                                _erc721contracts[iContracts],
                                member,
                                msg.sender,
                                _erc721tokensId[iContracts][iTokensId]
                            )
                        {
                            continue;
                        } catch {
                            memberToContractToAssetStatus[member][_erc721contracts[iContracts]].pop();
                        }
                    }
                }
            }
        }
    }

    function killswitchTransfer(address _backupWallet)
        external
        whenNotPaused
        hasPaidMembership(msg.sender)
        nonReentrant
    {

        require(backupWalletToMember[_backupWallet] == msg.sender, "Backup and member not match");

        address webacyProxyForMember = address(proxyFactory.deployedContractFromMember(msg.sender));

        for (uint256 i = 0; i < memberToERC20Contracts[msg.sender].length; i++) {
            address contractAddress = memberToERC20Contracts[msg.sender][i];
            uint256 amount = memberToContractToAllowableAmount[msg.sender][contractAddress];

            require(amount != 0, "Contract address not exists");

            uint256 currentAmount = IERC20Upgradeable(contractAddress).balanceOf(msg.sender);

            if (currentAmount < amount) {
                amount = currentAmount;
            }

            uint256 feeAmount = calculatePercentage(amount, transferFee);
            uint256 transferAmount = calculatePercentage(amount, 100 - transferFee);

            if (!(hasBalance[contractAddress])) {
                hasBalance[contractAddress] = true;
                contractBalances.push(contractAddress);
            }

            if (currentAmount == 0 || memberToContractToTokenStatus[msg.sender][contractAddress].transferred == true)
                continue;

            memberToContractToTokenStatus[msg.sender][contractAddress] = ERC20TokenStatus(_backupWallet, amount, true);

            try
                IWebacyProxy(webacyProxyForMember).transferErc20TokensAllowed(
                    contractAddress,
                    msg.sender,
                    _backupWallet,
                    transferAmount
                )
            {
                IWebacyProxy(webacyProxyForMember).transferErc20TokensAllowed(
                    contractAddress,
                    msg.sender,
                    address(this),
                    feeAmount
                );
            } catch {
                delete memberToContractToTokenStatus[msg.sender][contractAddress];
            }
        }

        for (uint256 i = 0; i < memberToERC721Contracts[msg.sender].length; i++) {
            address contractAddress = memberToERC721Contracts[msg.sender][i];

            AssetBeneficiary[] memory assetBeneficiaries = memberToContractToAssetBeneficiary[msg.sender][
                contractAddress
            ];

            for (uint256 iAssets = 0; iAssets < assetBeneficiaries.length; iAssets++) {
                bool isOwner = _validateTokenOwnership(
                    contractAddress,
                    msg.sender,
                    assetBeneficiaries[iAssets].tokenId
                );

                if (isOwner) {
                    memberToContractToAssetStatus[msg.sender][contractAddress].push(
                        ERC721TokenStatus(_backupWallet, assetBeneficiaries[iAssets].tokenId, true)
                    );

                    try
                        IWebacyProxy(webacyProxyForMember).transferErc721TokensAllowed(
                            contractAddress,
                            msg.sender,
                            _backupWallet,
                            assetBeneficiaries[iAssets].tokenId
                        )
                    {
                        continue;
                    } catch {
                        memberToContractToAssetStatus[msg.sender][contractAddress].pop();
                    }
                }
            }
        }
    }

    function setProxyFactory(address _address) external onlyRole(DEFAULT_ADMIN_ROLE) {

        emit AddressUpdated("proxyFactory", _address);
        proxyFactory = IWebacyProxyFactory(_address);
    }

    function calculatePercentage(uint256 _amount, uint256 _fee) private pure returns (uint256) {

        _validateBasisPoints(_fee);
        return (_amount * _fee) / 100;
    }

    function _validateBasisPoints(uint256 _transferFee) private pure {

        require((_transferFee >= 0 && _transferFee <= 100), "BasisP must be in range 0-100");
    }

    function setTransferFee(uint256 _transferFee) external onlyRole(DEFAULT_ADMIN_ROLE) {

        emit AmountUpdated("transferFee", _transferFee);
        require((_transferFee >= 0 && _transferFee <= 100), "BasisP must be in range 0-100");
        transferFee = _transferFee;
    }

    function withdrawAllBalances(address[] memory _contracts, address _recipient)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        address[] memory contractsToIterate;
        if (_contracts.length == 0) {
            contractsToIterate = contractBalances;
        } else {
            contractsToIterate = _contracts;
        }
        for (uint256 i = 0; i < contractsToIterate.length; i++) {
            address iContract = contractsToIterate[i];
            uint256 availableBalance = IERC20Upgradeable(iContract).balanceOf(address(this));
            if (availableBalance > 0) {
                IERC20Upgradeable(iContract).safeTransfer(_recipient, availableBalance);
            }
        }
        emit FeesWithdrawed(_recipient);
    }

    function pauseContract() external whenNotPaused onlyRole(DEFAULT_ADMIN_ROLE) {

        _pause();
    }

    function unpauseContract() external whenPaused onlyRole(DEFAULT_ADMIN_ROLE) {

        _unpause();
    }

    function deleteStoredData() external hasPaidMembership(msg.sender) {

        removeStoredData(msg.sender);
    }

    function updateStoredData(address _address) external onlyRole(MEMBERSHIP_ROLE) {

        haveToPayUpdate[_address] = false;
        removeStoredData(_address);
    }

    function removeStoredData(address _address) internal {

        address[] memory backupWallets = memberToBackupWallets[_address];
        for (uint256 i = 0; i < backupWallets.length; i++) {
            delete backupWalletToMember[backupWallets[i]];
        }
        delete memberToBackupWallets[_address];

        address[] memory erc20Contracts = memberToERC20Contracts[_address];
        for (uint256 i = 0; i < erc20Contracts.length; i++) {
            TokenBeneficiary[] memory tokenBeneficiaries = memberToContractToTokenBeneficiaries[_address][
                erc20Contracts[i]
            ];
            for (uint256 x = 0; x < tokenBeneficiaries.length; x++) {
                delete tokenBeneficiaryToContractToMember[tokenBeneficiaries[x].desAddress][erc20Contracts[i]];
                if (!(beneficiaryToMember[tokenBeneficiaries[x].desAddress] == address(0))) {
                    delete beneficiaryToMember[tokenBeneficiaries[x].desAddress];
                }
            }
            delete memberToContractToAllowableAmount[_address][erc20Contracts[i]];
            delete memberToContractToTokenBeneficiaries[_address][erc20Contracts[i]];
            delete memberToContractToTokenStatus[_address][erc20Contracts[i]];
        }
        delete memberToERC20Contracts[_address];

        address[] memory erc721Contracts = memberToERC721Contracts[_address];
        for (uint256 y = 0; y < erc721Contracts.length; y++) {
            AssetBeneficiary[] memory assetBeneficiaries = memberToContractToAssetBeneficiary[_address][
                erc721Contracts[y]
            ];

            for (uint256 z = 0; z < assetBeneficiaries.length; z++) {
                delete assetBeneficiaryToContractToMember[assetBeneficiaries[z].desAddress][erc721Contracts[y]];
                if (!(beneficiaryToMember[assetBeneficiaries[z].desAddress] == address(0))) {
                    delete beneficiaryToMember[assetBeneficiaries[z].desAddress];
                }
            }
            delete memberToContractToAssetBeneficiary[_address][erc721Contracts[y]];
            delete memberToContractToAssetStatus[_address][erc721Contracts[y]];
        }
        delete memberToERC721Contracts[_address];
    }
}