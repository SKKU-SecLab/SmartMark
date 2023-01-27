
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

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

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


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165Upgradeable).interfaceId;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControlUpgradeable is Initializable, ContextUpgradeable, IAccessControlUpgradeable, ERC165Upgradeable {
    function __AccessControl_init() internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {
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
pragma solidity 0.8.7;

interface ICallProxy {


    function submissionChainIdFrom() external returns (uint256);

    function submissionNativeSender() external returns (bytes memory);


    function call(
        address _reserveAddress,
        address _receiver,
        bytes memory _data,
        uint256 _flags,
        bytes memory _nativeSender,
        uint256 _chainIdFrom
    ) external payable returns (bool);


    function callERC20(
        address _token,
        address _reserveAddress,
        address _receiver,
        bytes memory _data,
        uint256 _flags,
        bytes memory _nativeSender,
        uint256 _chainIdFrom
    ) external returns (bool);

}// MIT
pragma solidity 0.8.7;

interface IDeBridgeGate {


    struct TokenInfo {
        uint256 nativeChainId;
        bytes nativeAddress;
    }

    struct DebridgeInfo {
        uint256 chainId; // native chain id
        uint256 maxAmount; // maximum amount to transfer
        uint256 balance; // total locked assets
        uint256 lockedInStrategies; // total locked assets in strategy (AAVE, Compound, etc)
        address tokenAddress; // asset address on the current chain
        uint16 minReservesBps; // minimal hot reserves in basis points (1/10000)
        bool exist;
    }

    struct DebridgeFeeInfo {
        uint256 collectedFees; // total collected fees
        uint256 withdrawnFees; // fees that already withdrawn
        mapping(uint256 => uint256) getChainFee; // whether the chain for the asset is supported
    }

    struct ChainSupportInfo {
        uint256 fixedNativeFee; // transfer fixed fee
        bool isSupported; // whether the chain for the asset is supported
        uint16 transferFeeBps; // transfer fee rate nominated in basis points (1/10000) of transferred amount
    }

    struct DiscountInfo {
        uint16 discountFixBps; // fix discount in BPS
        uint16 discountTransferBps; // transfer % discount in BPS
    }

    struct SubmissionAutoParamsTo {
        uint256 executionFee;
        uint256 flags;
        bytes fallbackAddress;
        bytes data;
    }

    struct SubmissionAutoParamsFrom {
        uint256 executionFee;
        uint256 flags;
        address fallbackAddress;
        bytes data;
        bytes nativeSender;
    }

    struct FeeParams {
        uint256 receivedAmount;
        uint256 fixFee;
        uint256 transferFee;
        bool useAssetFee;
        bool isNativeToken;
    }


    function isSubmissionUsed(bytes32 submissionId) external returns (bool);


    function getNativeInfo(address token) external returns (
        uint256 nativeChainId,
        bytes memory nativeAddress);



    function send(
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bytes memory _receiver,
        bytes memory _permit,
        bool _useAssetFee,
        uint32 _referralCode,
        bytes calldata _autoParams
    ) external payable;


    function claim(
        bytes32 _debridgeId,
        uint256 _amount,
        uint256 _chainIdFrom,
        address _receiver,
        uint256 _nonce,
        bytes calldata _signatures,
        bytes calldata _autoParams
    ) external;


    function flash(
        address _tokenAddress,
        address _receiver,
        uint256 _amount,
        bytes memory _data
    ) external;


    function getDefiAvaliableReserves(address _tokenAddress) external view returns (uint256);


    function requestReserves(address _tokenAddress, uint256 _amount) external;


    function returnReserves(address _tokenAddress, uint256 _amount) external;


    function withdrawFee(bytes32 _debridgeId) external;


    function getDebridgeChainAssetFixedFee(
        bytes32 _debridgeId,
        uint256 _chainId
    ) external view returns (uint256);



    event Sent(
        bytes32 submissionId,
        bytes32 indexed debridgeId,
        uint256 amount,
        bytes receiver,
        uint256 nonce,
        uint256 indexed chainIdTo,
        uint32 referralCode,
        FeeParams feeParams,
        bytes autoParams,
        address nativeSender
    );

    event Claimed(
        bytes32 submissionId,
        bytes32 indexed debridgeId,
        uint256 amount,
        address indexed receiver,
        uint256 nonce,
        uint256 indexed chainIdFrom,
        bytes autoParams,
        bool isNativeToken
    );

    event PairAdded(
        bytes32 debridgeId,
        address tokenAddress,
        bytes nativeAddress,
        uint256 indexed nativeChainId,
        uint256 maxAmount,
        uint16 minReservesBps
    );

    event MonitoringSendEvent(
        bytes32 submissionId,
        uint256 nonce,
        uint256 lockedOrMintedAmount,
        uint256 totalSupply
    );

    event MonitoringClaimEvent(
        bytes32 submissionId,
        uint256 lockedOrMintedAmount,
        uint256 totalSupply
    );

    event ChainSupportUpdated(uint256 chainId, bool isSupported, bool isChainFrom);
    event ChainsSupportUpdated(
        uint256 chainIds,
        ChainSupportInfo chainSupportInfo,
        bool isChainFrom);

    event CallProxyUpdated(address callProxy);
    event AutoRequestExecuted(
        bytes32 submissionId,
        bool indexed success,
        address callProxy
    );

    event Blocked(bytes32 submissionId);
    event Unblocked(bytes32 submissionId);

    event Flash(
        address sender,
        address indexed tokenAddress,
        address indexed receiver,
        uint256 amount,
        uint256 paid
    );

    event WithdrawnFee(bytes32 debridgeId, uint256 fee);

    event FixedNativeFeeUpdated(
        uint256 globalFixedNativeFee,
        uint256 globalTransferFeeBps);

    event FixedNativeFeeAutoUpdated(uint256 globalFixedNativeFee);
}//MIT
pragma solidity ^0.8.7;

interface IERC4494 {

    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function nonces(uint256 tokenId) external view returns (uint256);


    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external;

}// MIT
pragma solidity 0.8.7;


interface IDeNFT is IERC721Upgradeable, IERC4494 {

    function mint(
        address _to,
        uint256 _tokenId,
        string memory _tokenUri
    ) external;


    function burn(uint256 _tokenId) external;

}// MIT
pragma solidity 0.8.7;

interface INFTBridge {


    struct ChainInfo {
        bool isSupported;
        bytes nftBridgeAddress;
    }

    struct BridgeNFTInfo {
        uint256 nativeChainId;
        address tokenAddress; // asset address on the current chain
        bool exist;
    }

    struct NativeNFTInfo {
        uint256 chainId; // native chainId
        bytes tokenAddress; //native token address
        uint256 tokenType;
        string name;
        string symbol;
    }


    error AdminBadRole();
    error CallProxyBadRole();
    error NativeSenderBadRole(bytes nativeSender, uint256 chainIdFrom);

    error WrongArgument();
    error ZeroAddress();
    error ChainToIsNotSupported();
    error AssetAlreadyExist();

    error DebridgeTokenInfoNotFound();
    error MessageValueDoesNotMatchRequiredFee();
    error TokenMustImplementIERC721Metadata();

    error NotReceivedERC721();


    event AddedChainSupport(bytes bridgeAddress, uint256 chainId);
    event RemovedChainSupport(uint256 chainId);

    event NFTContractAdded(
        bytes32 debridgeId,
        address tokenAddress,
        bytes nativeAddress,
        uint256 nativeChainId,
        string name,
        string sybmol,
        uint256 tokenType
    );

    event NFTSent(
        address tokenAddress, // token address in the current chain
        uint256 tokenId,
        bytes receiver,
        uint256 chainIdTo,
        uint256 nonce
    );

    event NFTClaimed(
        address tokenAddress, // native token address in the current chain
        uint256 tokenId,
        address receiver
    );

    event NFTMinted(
        address tokenAddress, // token address in the current chain
        uint256 tokenId,
        address receiver,
        string tokenUri
    );
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {
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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {
    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
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

pragma solidity 0.8.7;

interface IERC20Permit {
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}// MIT
pragma solidity 0.8.7;


interface IDeBridgeToken is IERC20Upgradeable, IERC20Permit {
    function mint(address _receiver, uint256 _amount) external;

    function burn(uint256 _amount) external;
}// MIT
pragma solidity 0.8.7;

interface IDeBridgeTokenDeployer {

    function deployAsset(
        bytes32 _debridgeId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) external returns (address deTokenAddress);

    event DeBridgeTokenDeployed(
        address asset,
        string name,
        string symbol,
        uint8 decimals
    );
}// MIT
pragma solidity 0.8.7;

interface ISignatureVerifier {


    event Confirmed(bytes32 submissionId, address operator);
    event DeployConfirmed(bytes32 deployId, address operator);


    function submit(
        bytes32 _submissionId,
        bytes memory _signatures,
        uint8 _excessConfirmations
    ) external;

}// MIT
pragma solidity 0.8.7;

interface IWETH {
    function deposit() external payable;

    function withdraw(uint256 wad) external;

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
}// MIT
pragma solidity 0.8.7;

interface IFlashCallback {
    function flashCallback(uint256 fee, bytes calldata data) external;
}// BUSL-1.1
pragma solidity 0.8.7;

library SignatureUtil {

    error WrongArgumentLength();
    error SignatureInvalidLength();
    error SignatureInvalidV();

    function getUnsignedMsg(bytes32 _submissionId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _submissionId));
    }

    function splitSignature(bytes memory _signature)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        if (_signature.length != 65) revert SignatureInvalidLength();
        return parseSignature(_signature, 0);
    }

    function parseSignature(bytes memory _signatures, uint256 offset)
        internal
        pure
        returns (
            bytes32 r,
            bytes32 s,
            uint8 v
        )
    {
        assembly {
            r := mload(add(_signatures, add(32, offset)))
            s := mload(add(_signatures, add(64, offset)))
            v := and(mload(add(_signatures, add(65, offset))), 0xff)
        }

        if (v < 27) v += 27;
        if (v != 27 && v != 28) revert SignatureInvalidV();
    }

    function toUint256(bytes memory _bytes, uint256 _offset)
        internal
        pure
        returns (uint256 result)
    {
        if (_bytes.length < _offset + 32) revert WrongArgumentLength();

        assembly {
            result := mload(add(add(_bytes, 0x20), _offset))
        }
    }
}// BUSL-1.1
pragma solidity 0.8.7;

library Flags {


    uint256 public constant UNWRAP_ETH = 0;
    uint256 public constant REVERT_IF_EXTERNAL_FAIL = 1;
    uint256 public constant PROXY_WITH_SENDER = 2;
    uint256 public constant SEND_HASHED_DATA = 3;
    uint256 public constant SEND_EXTERNAL_CALL_GAS_LIMIT = 4;

    function getFlag(
        uint256 _packedFlags,
        uint256 _flag
    ) internal pure returns (bool) {
        uint256 flag = (_packedFlags >> _flag) & uint256(1);
        return flag == 1;
    }
    
     function setFlag(
         uint256 _packedFlags,
         uint256 _flag,
         bool _value
     ) internal pure returns (uint256) {
         if (_value)
             return _packedFlags | uint256(1) << _flag;
         else
             return _packedFlags & ~(uint256(1) << _flag);
     }
}// BUSL-1.1
pragma solidity 0.8.7;

interface IWethGate {
    function withdraw(address receiver, uint wad) external;
}// BUSL-1.1
pragma solidity 0.8.7;


contract DeBridgeGate is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    IDeBridgeGate
{
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using SignatureUtil for bytes;
    using Flags for uint256;


    uint256 public constant BPS_DENOMINATOR = 10000;
    bytes32 public constant GOVMONITORING_ROLE = keccak256("GOVMONITORING_ROLE");

    uint256 public constant SUBMISSION_PREFIX = 1;
    uint256 public constant DEPLOY_PREFIX = 2;

    address public deBridgeTokenDeployer;
    address public signatureVerifier;
    uint8 public excessConfirmations;
    uint256 public flashFeeBps;
    uint256 public nonce;

    mapping(bytes32 => DebridgeInfo) public getDebridge;
    mapping(bytes32 => DebridgeFeeInfo) public getDebridgeFeeInfo;
    mapping(bytes32 => bool) public override isSubmissionUsed;
    mapping(bytes32 => bool) public isBlockedSubmission;
    mapping(bytes32 => uint256) public getAmountThreshold;
    mapping(uint256 => ChainSupportInfo) public getChainToConfig;
    mapping(uint256 => ChainSupportInfo) public getChainFromConfig;
    mapping(address => DiscountInfo) public feeDiscount;
    mapping(address => TokenInfo) public override getNativeInfo;

    address public defiController;
    address public feeProxy;
    address public callProxy;
    IWETH public weth;

    address public feeContractUpdater;

    uint256 public globalFixedNativeFee;
    uint16 public globalTransferFeeBps;

    IWethGate public wethGate;
    uint256 public lockedClaim;


    error FeeProxyBadRole();
    error DefiControllerBadRole();
    error FeeContractUpdaterBadRole();
    error AdminBadRole();
    error GovMonitoringBadRole();
    error DebridgeNotFound();

    error WrongChainTo();
    error WrongChainFrom();
    error WrongArgument();
    error WrongAutoArgument();

    error TransferAmountTooHigh();

    error NotSupportedFixedFee();
    error TransferAmountNotCoverFees();
    error InvalidTokenToSend();

    error SubmissionUsed();
    error SubmissionBlocked();

    error AssetAlreadyExist();
    error ZeroAddress();

    error ProposedFeeTooHigh();
    error FlashFeeNotPaid();

    error NotEnoughReserves();
    error EthTransferFailed();


    modifier onlyFeeProxy() {
        if (feeProxy != msg.sender) revert FeeProxyBadRole();
        _;
    }

    modifier onlyDefiController() {
        if (defiController != msg.sender) revert DefiControllerBadRole();
        _;
    }

    modifier onlyFeeContractUpdater() {
        if (feeContractUpdater != msg.sender) revert FeeContractUpdaterBadRole();
        _;
    }

    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    modifier onlyGovMonitoring() {
        if (!hasRole(GOVMONITORING_ROLE, msg.sender)) revert GovMonitoringBadRole();
        _;
    }


    function initialize(
        uint8 _excessConfirmations,
        IWETH _weth
    ) public initializer {
        excessConfirmations = _excessConfirmations;
        weth = _weth;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __ReentrancyGuard_init();
    }


    function send(
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bytes memory _receiver,
        bytes memory _permit,
        bool _useAssetFee,
        uint32 _referralCode,
        bytes calldata _autoParams
    ) external payable override nonReentrant whenNotPaused {
        bytes32 debridgeId;
        FeeParams memory feeParams;
        uint256 amountAfterFee;
        (amountAfterFee, debridgeId, feeParams) = _send(
            _permit,
            _tokenAddress,
            _amount,
            _chainIdTo,
            _useAssetFee
        );

        SubmissionAutoParamsTo memory autoParams;

        if (_autoParams.length > 0) {
            autoParams = abi.decode(_autoParams, (SubmissionAutoParamsTo));
            autoParams.executionFee = _normalizeTokenAmount(_tokenAddress, autoParams.executionFee);
            if (autoParams.executionFee > _amount) revert ProposedFeeTooHigh();
            if (autoParams.data.length > 0 && autoParams.fallbackAddress.length == 0 ) revert WrongAutoArgument();
        }

        amountAfterFee -= autoParams.executionFee;

        amountAfterFee = _normalizeTokenAmount(_tokenAddress, amountAfterFee);

        _publishSubmission(
            debridgeId,
            _chainIdTo,
            amountAfterFee,
            _receiver,
            feeParams,
            _referralCode,
            autoParams,
            _autoParams.length > 0
        );
    }

    function claim(
        bytes32 _debridgeId,
        uint256 _amount,
        uint256 _chainIdFrom,
        address _receiver,
        uint256 _nonce,
        bytes calldata _signatures,
        bytes calldata _autoParams
    ) external override whenNotPaused {
        if (!getChainFromConfig[_chainIdFrom].isSupported) revert WrongChainFrom();

        SubmissionAutoParamsFrom memory autoParams;
        if (_autoParams.length > 0) {
            autoParams = abi.decode(_autoParams, (SubmissionAutoParamsFrom));
        }

        bytes32 submissionId = getSubmissionIdFrom(
            _debridgeId,
            _chainIdFrom,
            _amount,
            _receiver,
            _nonce,
            autoParams,
            _autoParams.length > 0,
            msg.sender
        );

        if (isSubmissionUsed[submissionId]) revert SubmissionUsed();
        isSubmissionUsed[submissionId] = true;

        _checkConfirmations(submissionId, _debridgeId, _amount, _signatures);

        bool isNativeToken =_claim(
            submissionId,
            _debridgeId,
            _receiver,
            _amount,
            _chainIdFrom,
            autoParams
        );

        emit Claimed(
            submissionId,
            _debridgeId,
            _amount,
            _receiver,
            _nonce,
            _chainIdFrom,
            _autoParams,
            isNativeToken
        );
    }

    function flash(
        address _tokenAddress,
        address _receiver,
        uint256 _amount,
        bytes memory _data
    ) external override nonReentrant whenNotPaused
    {
        bytes32 debridgeId = getDebridgeId(getChainId(), _tokenAddress);
        if (!getDebridge[debridgeId].exist) revert DebridgeNotFound();
        uint256 currentFlashFee = (_amount * flashFeeBps) / BPS_DENOMINATOR;
        uint256 balanceBefore = IERC20Upgradeable(_tokenAddress).balanceOf(address(this));

        IERC20Upgradeable(_tokenAddress).safeTransfer(_receiver, _amount);
        IFlashCallback(msg.sender).flashCallback(currentFlashFee, _data);

        uint256 balanceAfter = IERC20Upgradeable(_tokenAddress).balanceOf(address(this));
        if (balanceBefore + currentFlashFee > balanceAfter) revert FlashFeeNotPaid();

        uint256 paid = balanceAfter - balanceBefore;
        getDebridgeFeeInfo[debridgeId].collectedFees += paid;
        emit Flash(msg.sender, _tokenAddress, _receiver, _amount, paid);
    }

    function deployNewAsset(
        bytes memory _nativeTokenAddress,
        uint256 _nativeChainId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        bytes memory _signatures
    ) external nonReentrant whenNotPaused{
        bytes32 debridgeId = getbDebridgeId(_nativeChainId, _nativeTokenAddress);

        if (getDebridge[debridgeId].exist) revert AssetAlreadyExist();

        bytes32 deployId = getDeployId(debridgeId, _name, _symbol, _decimals);

        ISignatureVerifier(signatureVerifier).submit(deployId, _signatures, excessConfirmations);

        address deBridgeTokenAddress = IDeBridgeTokenDeployer(deBridgeTokenDeployer)
            .deployAsset(debridgeId, _name, _symbol, _decimals);

        _addAsset(debridgeId, deBridgeTokenAddress, _nativeTokenAddress, _nativeChainId);
    }

    function autoUpdateFixedNativeFee(
        uint256 _globalFixedNativeFee
    ) external onlyFeeContractUpdater {
        globalFixedNativeFee = _globalFixedNativeFee;
        emit FixedNativeFeeAutoUpdated(_globalFixedNativeFee);
    }


    function updateChainSupport(
        uint256[] memory _chainIds,
        ChainSupportInfo[] memory _chainSupportInfo,
        bool _isChainFrom
    ) external onlyAdmin {
        if (_chainIds.length != _chainSupportInfo.length) revert WrongArgument();
        for (uint256 i = 0; i < _chainIds.length; i++) {
            if(_isChainFrom){
                getChainFromConfig[_chainIds[i]] = _chainSupportInfo[i];
            }
            else {
                getChainToConfig[_chainIds[i]] = _chainSupportInfo[i];
            }
            emit ChainsSupportUpdated(_chainIds[i], _chainSupportInfo[i], _isChainFrom);
        }
    }

    function updateGlobalFee(
        uint256 _globalFixedNativeFee,
        uint16 _globalTransferFeeBps
    ) external onlyAdmin {
        globalFixedNativeFee = _globalFixedNativeFee;
        globalTransferFeeBps = _globalTransferFeeBps;
        emit FixedNativeFeeUpdated(_globalFixedNativeFee, _globalTransferFeeBps);
    }

    function updateAssetFixedFees(
        bytes32 _debridgeId,
        uint256[] memory _supportedChainIds,
        uint256[] memory _assetFeesInfo
    ) external onlyAdmin {
        if (_supportedChainIds.length != _assetFeesInfo.length) revert WrongArgument();
        DebridgeFeeInfo storage debridgeFee = getDebridgeFeeInfo[_debridgeId];
        for (uint256 i = 0; i < _supportedChainIds.length; i++) {
            debridgeFee.getChainFee[_supportedChainIds[i]] = _assetFeesInfo[i];
        }
    }

    function updateExcessConfirmations(uint8 _excessConfirmations) external onlyAdmin {
        if (_excessConfirmations == 0) revert WrongArgument();
        excessConfirmations = _excessConfirmations;
    }

    function setChainSupport(uint256 _chainId, bool _isSupported, bool _isChainFrom) external onlyAdmin {
        if (_isChainFrom) {
            getChainFromConfig[_chainId].isSupported = _isSupported;
        }
        else {
            getChainToConfig[_chainId].isSupported = _isSupported;
        }
        emit ChainSupportUpdated(_chainId, _isSupported, _isChainFrom);
    }

    function setCallProxy(address _callProxy) external onlyAdmin {
        callProxy = _callProxy;
        emit CallProxyUpdated(_callProxy);
    }

    function updateAsset(
        bytes32 _debridgeId,
        uint256 _maxAmount,
        uint16 _minReservesBps,
        uint256 _amountThreshold
    ) external onlyAdmin {
        if (_minReservesBps > BPS_DENOMINATOR) revert WrongArgument();
        DebridgeInfo storage debridge = getDebridge[_debridgeId];
        debridge.maxAmount = _maxAmount;
        debridge.minReservesBps = _minReservesBps;
        getAmountThreshold[_debridgeId] = _amountThreshold;
    }


    function setSignatureVerifier(address _verifier) external onlyAdmin {
        signatureVerifier = _verifier;
    }

    function setDeBridgeTokenDeployer(address _deBridgeTokenDeployer) external onlyAdmin {
        deBridgeTokenDeployer = _deBridgeTokenDeployer;
    }

    function setDefiController(address _defiController) external onlyAdmin {
        defiController = _defiController;
    }

    function setFeeContractUpdater(address _value) external onlyAdmin {
        feeContractUpdater = _value;
    }

    function setWethGate(IWethGate _wethGate) external onlyAdmin {
        wethGate = _wethGate;
    }

    function pause() external onlyGovMonitoring {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }

    function withdrawFee(bytes32 _debridgeId) external override nonReentrant onlyFeeProxy {
        DebridgeFeeInfo storage debridgeFee = getDebridgeFeeInfo[_debridgeId];
        uint256 amount = debridgeFee.collectedFees - debridgeFee.withdrawnFees;

        if (amount == 0) revert NotEnoughReserves();

        debridgeFee.withdrawnFees += amount;

        if (_debridgeId == getDebridgeId(getChainId(), address(0))) {
            _safeTransferETH(feeProxy, amount);
        } else {
            IERC20Upgradeable(getDebridge[_debridgeId].tokenAddress).safeTransfer(feeProxy, amount);
        }
        emit WithdrawnFee(_debridgeId, amount);
    }

    function requestReserves(address _tokenAddress, uint256 _amount)
        external
        override
        onlyDefiController
        nonReentrant
    {
        bytes32 debridgeId = getDebridgeId(getChainId(), _tokenAddress);
        DebridgeInfo storage debridge = getDebridge[debridgeId];
        if (!debridge.exist) revert DebridgeNotFound();
        uint256 minReserves = (debridge.balance * debridge.minReservesBps) / BPS_DENOMINATOR;

        if (minReserves + _amount > IERC20Upgradeable(_tokenAddress).balanceOf(address(this)))
            revert NotEnoughReserves();

        debridge.lockedInStrategies += _amount;
        IERC20Upgradeable(_tokenAddress).safeTransfer(defiController, _amount);
    }

    function returnReserves(address _tokenAddress, uint256 _amount)
        external
        override
        onlyDefiController
        nonReentrant
    {
        bytes32 debridgeId = getDebridgeId(getChainId(), _tokenAddress);
        DebridgeInfo storage debridge = getDebridge[debridgeId];
        if (!debridge.exist) revert DebridgeNotFound();
        debridge.lockedInStrategies -= _amount;
        IERC20Upgradeable(debridge.tokenAddress).safeTransferFrom(
            defiController,
            address(this),
            _amount
        );
    }

    function setFeeProxy(address _feeProxy) external onlyAdmin {
        feeProxy = _feeProxy;
    }

    function blockSubmission(bytes32[] memory _submissionIds, bool isBlocked) external onlyAdmin {
        for (uint256 i = 0; i < _submissionIds.length; i++) {
            isBlockedSubmission[_submissionIds[i]] = isBlocked;
            if (isBlocked) {
                emit Blocked(_submissionIds[i]);
            } else {
                emit Unblocked(_submissionIds[i]);
            }
        }
    }

    function updateFlashFee(uint256 _flashFeeBps) external onlyAdmin {
        if (_flashFeeBps > BPS_DENOMINATOR) revert WrongArgument();
        flashFeeBps = _flashFeeBps;
    }

    function updateFeeDiscount(
        address _address,
        uint16 _discountFixBps,
        uint16 _discountTransferBps
    ) external onlyAdmin {
        if (_address == address(0) ||
            _discountFixBps > BPS_DENOMINATOR ||
            _discountTransferBps > BPS_DENOMINATOR
        ) revert WrongArgument();
        DiscountInfo storage discountInfo = feeDiscount[_address];
        discountInfo.discountFixBps = _discountFixBps;
        discountInfo.discountTransferBps = _discountTransferBps;
    }

    receive() external payable {
    }


    function _checkConfirmations(
        bytes32 _submissionId,
        bytes32 _debridgeId,
        uint256 _amount,
        bytes calldata _signatures
    ) internal {
        if (isBlockedSubmission[_submissionId]) revert SubmissionBlocked();
        ISignatureVerifier(signatureVerifier).submit(
            _submissionId,
            _signatures,
            _amount >= getAmountThreshold[_debridgeId] ? excessConfirmations : 0
        );
    }

    function _addAsset(
        bytes32 _debridgeId,
        address _tokenAddress,
        bytes memory _nativeAddress,
        uint256 _nativeChainId
    ) internal {
        DebridgeInfo storage debridge = getDebridge[_debridgeId];

        if (debridge.exist) revert AssetAlreadyExist();
        if (_tokenAddress == address(0)) revert ZeroAddress();

        debridge.exist = true;
        debridge.tokenAddress = _tokenAddress;
        debridge.chainId = _nativeChainId;
        if (debridge.maxAmount == 0) {
            debridge.maxAmount = type(uint256).max;
        }
        debridge.minReservesBps = uint16(BPS_DENOMINATOR);
        if (getAmountThreshold[_debridgeId] == 0) {
            getAmountThreshold[_debridgeId] = type(uint256).max;
        }

        TokenInfo storage tokenInfo = getNativeInfo[_tokenAddress];
        tokenInfo.nativeChainId = _nativeChainId;
        tokenInfo.nativeAddress = _nativeAddress;

        emit PairAdded(
            _debridgeId,
            _tokenAddress,
            _nativeAddress,
            _nativeChainId,
            debridge.maxAmount,
            debridge.minReservesBps
        );
    }

    function _send(
        bytes memory _permit,
        address _tokenAddress,
        uint256 _amount,
        uint256 _chainIdTo,
        bool _useAssetFee
    ) internal returns (
        uint256 amountAfterFee,
        bytes32 debridgeId,
        FeeParams memory feeParams
    ) {
        _validateToken(_tokenAddress);

        if (_permit.length > 0) {
            uint256 deadline = _permit.toUint256(0);
            (bytes32 r, bytes32 s, uint8 v) = _permit.parseSignature(32);
            IERC20Permit(_tokenAddress).permit(
                msg.sender,
                address(this),
                _amount,
                deadline,
                v,
                r,
                s);
        }

        TokenInfo memory nativeTokenInfo = getNativeInfo[_tokenAddress];
        bool isNativeToken = nativeTokenInfo.nativeChainId  == 0
            ? true // token not in mapping
            : nativeTokenInfo.nativeChainId == getChainId(); // token native chain id the same

        if (isNativeToken) {
            debridgeId = getDebridgeId(
                getChainId(),
                _tokenAddress == address(0) ? address(weth) : _tokenAddress
            );
        }
        else {
            debridgeId = getbDebridgeId(
                nativeTokenInfo.nativeChainId,
                nativeTokenInfo.nativeAddress
            );
        }

        DebridgeInfo storage debridge = getDebridge[debridgeId];
        if (!debridge.exist) {
            if (isNativeToken) {
                address assetAddress = _tokenAddress == address(0) ? address(weth) : _tokenAddress;
                _addAsset(
                    debridgeId,
                    assetAddress,
                    abi.encodePacked(assetAddress),
                    getChainId()
                );
            } else revert DebridgeNotFound();
        }

        ChainSupportInfo memory chainFees = getChainToConfig[_chainIdTo];
        if (!chainFees.isSupported) revert WrongChainTo();

        if (_tokenAddress == address(0)) {
            _amount = msg.value;
            weth.deposit{value: _amount}();
            _useAssetFee = true;
        } else {
            IERC20Upgradeable token = IERC20Upgradeable(_tokenAddress);
            uint256 balanceBefore = token.balanceOf(address(this));
            token.safeTransferFrom(msg.sender, address(this), _amount);
            _amount = token.balanceOf(address(this)) - balanceBefore;
        }

        if (_amount > debridge.maxAmount) revert TransferAmountTooHigh();

        {
            DiscountInfo memory discountInfo = feeDiscount[msg.sender];
            DebridgeFeeInfo storage debridgeFee = getDebridgeFeeInfo[debridgeId];

            uint256 assetsFixedFee;
            if (_useAssetFee) {
                if (_tokenAddress == address(0)) {
                    assetsFixedFee = chainFees.fixedNativeFee == 0 ? globalFixedNativeFee : chainFees.fixedNativeFee;
                } else {
                    assetsFixedFee = debridgeFee.getChainFee[_chainIdTo];
                    if (assetsFixedFee == 0) revert NotSupportedFixedFee();
                }
                assetsFixedFee = _applyDiscount(assetsFixedFee, discountInfo.discountFixBps);
                if (_amount < assetsFixedFee) revert TransferAmountNotCoverFees();
                feeParams.fixFee = assetsFixedFee;
            } else {

                uint256 nativeFee = chainFees.fixedNativeFee == 0 ? globalFixedNativeFee : chainFees.fixedNativeFee;
                nativeFee = _applyDiscount(nativeFee, discountInfo.discountFixBps);

                if (msg.value < nativeFee) revert TransferAmountNotCoverFees();
                else if (msg.value > nativeFee) {
                     _safeTransferETH(msg.sender, msg.value - nativeFee);
                }
                bytes32 nativeDebridgeId = getDebridgeId(getChainId(), address(0));
                getDebridgeFeeInfo[nativeDebridgeId].collectedFees += nativeFee;
                feeParams.fixFee = nativeFee;
            }

            uint256 transferFee = (chainFees.transferFeeBps == 0
                ? globalTransferFeeBps : chainFees.transferFeeBps)
                * (_amount - assetsFixedFee) / BPS_DENOMINATOR;
            transferFee = _applyDiscount(transferFee, discountInfo.discountTransferBps);

            uint256 totalFee = transferFee + assetsFixedFee;
            if (_amount < totalFee) revert TransferAmountNotCoverFees();
            debridgeFee.collectedFees += totalFee;
            amountAfterFee = _amount - totalFee;

            feeParams.transferFee = transferFee;
            feeParams.useAssetFee = _useAssetFee;
            feeParams.receivedAmount = _amount;
            feeParams.isNativeToken = isNativeToken;
        }

        if (isNativeToken) {
            debridge.balance += amountAfterFee;
        }
        else {
            debridge.balance -= amountAfterFee;
            IDeBridgeToken(debridge.tokenAddress).burn(amountAfterFee);
        }
        return (amountAfterFee, debridgeId, feeParams);
    }

    function _publishSubmission(
        bytes32 _debridgeId,
        uint256 _chainIdTo,
        uint256 _amount,
        bytes memory _receiver,
        FeeParams memory feeParams,
        uint32 _referralCode,
        SubmissionAutoParamsTo memory autoParams,
        bool hasAutoParams
    ) internal {
        bytes32 submissionId;
        bytes memory packedSubmission = abi.encodePacked(
            SUBMISSION_PREFIX,
            _debridgeId,
            getChainId(),
            _chainIdTo,
            _amount,
            _receiver,
            nonce
        );
        if (hasAutoParams) {
            bool isHashedData = autoParams.flags.getFlag(Flags.SEND_HASHED_DATA);
            if (isHashedData && autoParams.data.length != 32) revert WrongAutoArgument();
            submissionId = keccak256(
                abi.encodePacked(
                    packedSubmission,
                    autoParams.executionFee,
                    autoParams.flags,
                    keccak256(autoParams.fallbackAddress),
                    isHashedData ? autoParams.data : abi.encodePacked(keccak256(autoParams.data)),
                    keccak256(abi.encodePacked(msg.sender))
                )
            );
        }
        else {
            submissionId = keccak256(packedSubmission);
        }

        emit Sent(
            submissionId,
            _debridgeId,
            _amount,
            _receiver,
            nonce,
            _chainIdTo,
            _referralCode,
            feeParams,
            hasAutoParams ? abi.encode(autoParams): bytes(""),
            msg.sender
        );

        {
            emit MonitoringSendEvent(
                submissionId,
                nonce,
                getDebridge[_debridgeId].balance,
                IERC20Upgradeable(getDebridge[_debridgeId].tokenAddress).totalSupply()
            );
        }

        nonce++;
    }

    function _applyDiscount(
        uint256 amount,
        uint16 discountBps
    ) internal pure returns (uint256) {
        return amount - amount * discountBps / BPS_DENOMINATOR;
    }

    function _validateToken(address _token) internal {
        if (_token == address(0)) {
            return;
        }

        (bool success, ) = _token.call(abi.encodeWithSignature("decimals()"));
        if (!success) revert InvalidTokenToSend();

        (success, ) = _token.call(abi.encodeWithSignature("symbol()"));
        if (!success) revert InvalidTokenToSend();
    }


    function _claim(
        bytes32 _submissionId,
        bytes32 _debridgeId,
        address _receiver,
        uint256 _amount,
        uint256 _chainIdFrom,
        SubmissionAutoParamsFrom memory _autoParams
    ) internal returns (bool isNativeToken) {
        DebridgeInfo storage debridge = getDebridge[_debridgeId];
        if (!debridge.exist) revert DebridgeNotFound();
        isNativeToken = debridge.chainId == getChainId();

        if (isNativeToken) {
            debridge.balance -= _amount + _autoParams.executionFee;
        } else {
            debridge.balance += _amount + _autoParams.executionFee;
        }

        address _token = debridge.tokenAddress;
        bool unwrapETH = isNativeToken
            && _autoParams.flags.getFlag(Flags.UNWRAP_ETH)
            && _token == address(weth);

        if (_autoParams.executionFee > 0) {
            _mintOrTransfer(_token, msg.sender, _autoParams.executionFee, isNativeToken);
        }
        if (_autoParams.data.length > 0) {
            address _callProxy = callProxy;
            bool status;
            if (unwrapETH) {
                _withdrawWeth(_callProxy, _amount);
                status = ICallProxy(_callProxy).call(
                    _autoParams.fallbackAddress,
                    _receiver,
                    _autoParams.data,
                    _autoParams.flags,
                    _autoParams.nativeSender,
                    _chainIdFrom
                );
            }
            else {
                _mintOrTransfer(_token, _callProxy, _amount, isNativeToken);

                status = ICallProxy(_callProxy).callERC20(
                    _token,
                    _autoParams.fallbackAddress,
                    _receiver,
                    _autoParams.data,
                    _autoParams.flags,
                    _autoParams.nativeSender,
                    _chainIdFrom
                );
            }
            emit AutoRequestExecuted(_submissionId, status, _callProxy);
        } else if (unwrapETH) {
            _withdrawWeth(_receiver, _amount);
        } else {
            _mintOrTransfer(_token, _receiver, _amount, isNativeToken);
        }

        emit MonitoringClaimEvent(
            _submissionId,
            debridge.balance,
            IERC20Upgradeable(debridge.tokenAddress).totalSupply()
        );
    }

    function _mintOrTransfer(
        address _token,
        address _receiver,
        uint256 _amount,
        bool isNativeToken
    ) internal {
        if (_amount > 0) {
            if (isNativeToken) {
                IERC20Upgradeable(_token).safeTransfer(_receiver, _amount);
            } else {
                IDeBridgeToken(_token).mint(_receiver, _amount);
            }
        }
    }

    function _safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        if (!success) revert EthTransferFailed();
    }


    function _withdrawWeth(address _receiver, uint _amount) internal {
        if (address(wethGate) == address(0)) {
            weth.withdraw(_amount);
            _safeTransferETH(_receiver, _amount);
        }
        else {
            IERC20Upgradeable(address(weth)).safeTransfer(address(wethGate), _amount);
            wethGate.withdraw(_receiver, _amount);
        }
    }

    function _normalizeTokenAmount(
        address _token,
        uint256 _amount
    ) internal view returns (uint256) {
        uint256 decimals = _token == address(0)
            ? 18
            : IERC20Metadata(_token).decimals();
        uint256 maxDecimals = 8;
        if (decimals > maxDecimals) {
            uint256 multiplier = 10 ** (decimals - maxDecimals);
            _amount = _amount / multiplier * multiplier;
        }
        return _amount;
    }


    function getDefiAvaliableReserves(address _tokenAddress)
        external
        view
        override
        returns (uint256)
    {
        DebridgeInfo storage debridge = getDebridge[getDebridgeId(getChainId(), _tokenAddress)];
        return (debridge.balance * (BPS_DENOMINATOR - debridge.minReservesBps)) / BPS_DENOMINATOR;
    }

    function getDebridgeId(uint256 _chainId, address _tokenAddress) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_chainId, _tokenAddress));
    }

    function getbDebridgeId(uint256 _chainId, bytes memory _tokenAddress) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_chainId, _tokenAddress));
    }

    function getDebridgeChainAssetFixedFee(
        bytes32 _debridgeId,
        uint256 _chainId
    ) external view override returns (uint256) {
        return getDebridgeFeeInfo[_debridgeId].getChainFee[_chainId];
    }

    function getSubmissionIdFrom(
        bytes32 _debridgeId,
        uint256 _chainIdFrom,
        uint256 _amount,
        address _receiver,
        uint256 _nonce,
        SubmissionAutoParamsFrom memory _autoParams,
        bool _hasAutoParams,
        address _sender
    ) public view returns (bytes32) {
        bytes memory packedSubmission = abi.encodePacked(
            SUBMISSION_PREFIX,
            _debridgeId,
            _chainIdFrom,
            getChainId(),
            _amount,
            _receiver,
            _nonce
        );
        if (_hasAutoParams) {
            bool isHashedData = _autoParams.flags.getFlag(Flags.SEND_HASHED_DATA)
                             && _sender == _autoParams.fallbackAddress
                             && _autoParams.data.length == 32;

            return keccak256(
                abi.encodePacked(
                    packedSubmission,
                    _autoParams.executionFee,
                    _autoParams.flags,
                    keccak256(abi.encodePacked(_autoParams.fallbackAddress)),
                    isHashedData ? _autoParams.data : abi.encodePacked(keccak256(_autoParams.data)),
                    keccak256(_autoParams.nativeSender)
                )
            );
        }
        return keccak256(packedSubmission);
    }



    function getDeployId(
        bytes32 _debridgeId,
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            DEPLOY_PREFIX,
            _debridgeId,
            keccak256(abi.encodePacked(_name)),
            keccak256(abi.encodePacked(_symbol)),
            _decimals));
    }

    function getChainId() public view virtual returns (uint256 cid) {
        assembly {
            cid := chainid()
        }
    }

    function version() external pure returns (uint256) {
        return 410; // 4.1.0
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC721Upgradeable is Initializable, ContextUpgradeable, ERC165Upgradeable, IERC721Upgradeable, IERC721MetadataUpgradeable {
    using AddressUpgradeable for address;
    using StringsUpgradeable for uint256;

    string private _name;

    string private _symbol;

    mapping(uint256 => address) private _owners;

    mapping(address => uint256) private _balances;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function __ERC721_init(string memory name_, string memory symbol_) internal initializer {
        __Context_init_unchained();
        __ERC165_init_unchained();
        __ERC721_init_unchained(name_, symbol_);
    }

    function __ERC721_init_unchained(string memory name_, string memory symbol_) internal initializer {
        _name = name_;
        _symbol = symbol_;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165Upgradeable, IERC165Upgradeable) returns (bool) {
        return
            interfaceId == type(IERC721Upgradeable).interfaceId ||
            interfaceId == type(IERC721MetadataUpgradeable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function balanceOf(address owner) public view virtual override returns (uint256) {
        require(owner != address(0), "ERC721: balance query for the zero address");
        return _balances[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual override returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: owner query for nonexistent token");
        return owner;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }

    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString())) : "";
    }

    function _baseURI() internal view virtual returns (string memory) {
        return "";
    }

    function approve(address to, uint256 tokenId) public virtual override {
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            _msgSender() == owner || isApprovedForAll(owner, _msgSender()),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "ERC721: approved query for nonexistent token");

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {
        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual override returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public virtual override {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        _safeTransfer(from, to, tokenId, _data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721Upgradeable.ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal virtual {
        _mint(to, tokenId);
        require(
            _checkOnERC721Received(address(0), to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _beforeTokenTransfer(address(0), to, tokenId);

        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        address owner = ERC721Upgradeable.ownerOf(tokenId);

        _beforeTokenTransfer(owner, address(0), tokenId);

        _approve(address(0), tokenId);

        _balances[owner] -= 1;
        delete _owners[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {
        require(ERC721Upgradeable.ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
        require(to != address(0), "ERC721: transfer to the zero address");

        _beforeTokenTransfer(from, to, tokenId);

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        _tokenApprovals[tokenId] = to;
        emit Approval(ERC721Upgradeable.ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        require(owner != operator, "ERC721: approve to caller");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try IERC721ReceiverUpgradeable(to).onERC721Received(_msgSender(), from, tokenId, _data) returns (bytes4 retval) {
                return retval == IERC721ReceiverUpgradeable.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("ERC721: transfer to non ERC721Receiver implementer");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual {}
    uint256[44] private __gap;
}// MIT

pragma solidity ^0.8.0;

library Strings {
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


library ECDSA {
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
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n", Strings.toString(s.length), s));
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
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

interface IERC1271 {
    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue);
}// MIT

pragma solidity ^0.8.0;


library SignatureChecker {
    function isValidSignatureNow(
        address signer,
        bytes32 hash,
        bytes memory signature
    ) internal view returns (bool) {
        (address recovered, ECDSA.RecoverError error) = ECDSA.tryRecover(hash, signature);
        if (error == ECDSA.RecoverError.NoError && recovered == signer) {
            return true;
        }

        (bool success, bytes memory result) = signer.staticcall(
            abi.encodeWithSelector(IERC1271.isValidSignature.selector, hash, signature)
        );
        return (success && result.length == 32 && abi.decode(result, (bytes4)) == IERC1271.isValidSignature.selector);
    }
}//MIT
pragma solidity ^0.8.7;



abstract contract ERC721WithPermitUpgradable is ERC721Upgradeable, IERC4494 {
    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            'Permit(address spender,uint256 tokenId,uint256 nonce,uint256 deadline)'
        );

    mapping(uint256 => uint256) private _nonces;

    bytes32 private _domainSeparator;
    uint256 private _domainChainId;

    function __ERC721WithPermitUpgradable_init(string memory name_, string memory symbol_) internal initializer {
        __ERC721_init(name_, symbol_);
        __ERC721WithPermitUpgradable_init_unchained();
    }

    function __ERC721WithPermitUpgradable_init_unchained() internal initializer {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        _domainChainId = chainId;
        _domainSeparator = _calculateDomainSeparator(chainId);
    }

    function DOMAIN_SEPARATOR() public view override returns (bytes32) {
        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        return
            (chainId == _domainChainId)
                ? _domainSeparator
                : _calculateDomainSeparator(chainId);
    }

    function _calculateDomainSeparator(uint256 chainId)
        internal
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        'EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)'
                    ),
                    keccak256(bytes(name())),
                    keccak256(bytes('1')),
                    chainId,
                    address(this)
                )
            );
    }

    function nonces(uint256 tokenId) public view override returns (uint256) {
        require(_exists(tokenId), '!UNKNOWN_TOKEN!');
        return _nonces[tokenId];
    }

    function permit(
        address spender,
        uint256 tokenId,
        uint256 deadline,
        bytes memory signature
    ) external override {
        require(deadline >= block.timestamp, 'permit expired');

        bytes32 digest = _buildDigest(
            spender,
            tokenId,
            _nonces[tokenId],
            deadline
        );

        (address recoveredAddress, ) = ECDSA.tryRecover(digest, signature);
        require(
            (recoveredAddress != address(0) &&
                _isApprovedOrOwner(recoveredAddress, tokenId)) ||
                SignatureChecker.isValidSignatureNow(
                    ownerOf(tokenId),
                    digest,
                    signature
                ),
            'permit is invalid'
        );

        _approve(spender, tokenId);
    }

    function _buildDigest(
        address spender,
        uint256 tokenId,
        uint256 nonce,
        uint256 deadline
    ) public view returns (bytes32) {
        return
            ECDSA.toTypedDataHash(
                DOMAIN_SEPARATOR(),
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        spender,
                        tokenId,
                        nonce,
                        deadline
                    )
                )
            );
    }

    function _incrementNonce(uint256 tokenId) internal {
        _nonces[tokenId]++;
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override {
        _incrementNonce(tokenId);

        super._transfer(from, to, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IERC4494).interfaceId
            || super.supportsInterface(interfaceId);
    }

    uint256[47] private __gap;
}// MIT
pragma solidity 0.8.7;


contract DeNFT is ERC721WithPermitUpgradable, IDeNFT {
    using StringsUpgradeable for uint256;


    mapping(uint256 => string) private _tokenURIs;

    string private _baseURIValue;

    address minter;
    address deNFTBridge;


    error MinterBadRole();
    error ZeroAddress();
    error WrongLengthOfArguments();


    modifier onlyMinter() {
        if (minter != msg.sender) revert MinterBadRole();
        _;
    }


    event MinterTransferred(address indexed previousMinter, address indexed newMinter);


    function initialize(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        address minter_,
        address deNFTBridge_
    ) public initializer {
        if (deNFTBridge_ == address(0) || minter_ == address(0)) revert ZeroAddress();
        __DeNFT_init(name_, symbol_, baseURI_, minter_, deNFTBridge_);
    }

    function __DeNFT_init(
        string memory name_,
        string memory symbol_,
        string memory baseURI_,
        address minter_,
        address deNFTBridge_
    ) internal initializer {
        __ERC721WithPermitUpgradable_init(name_, symbol_);
        __ERC721WithPermitUpgradable_init_unchained(baseURI_, minter_, deNFTBridge_);
    }

    function __ERC721WithPermitUpgradable_init_unchained(
        string memory baseURI_,
        address minter_,
        address deNFTBridge_
    ) internal initializer {
        minter = minter_;
        _baseURIValue = baseURI_;
        deNFTBridge = deNFTBridge_;
    }


    function mint(
        address _to,
        uint256 _tokenId,
        string memory _tokenUri
    ) external override onlyMinter {
        _tokenURIs[_tokenId] = _tokenUri;
        _safeMint(_to, _tokenId);
    }

    function mintMany(
         uint[] memory _tokenIds, string[] memory _tokenUris
    ) external  onlyMinter {
        mintMany(msg.sender, _tokenIds, _tokenUris);
    }

    function mintMany(
        address _to,
        uint256[] memory _tokenIds,
        string[] memory _tokenUris
    ) public onlyMinter {
        if (_tokenIds.length != _tokenUris.length) revert WrongLengthOfArguments();

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            _tokenURIs[tokenId] = _tokenUris[i];
            _safeMint(_to, tokenId);
        }
    }

    function mintMany(
        address[] memory _to,
        uint256[] memory _tokenIds,
        string[] memory _tokenUris
    ) external onlyMinter {
        if (_tokenIds.length != _to.length || _tokenIds.length != _tokenUris.length)
            revert WrongLengthOfArguments();

        for (uint256 i = 0; i < _tokenIds.length; i++) {
            uint256 tokenId = _tokenIds[i];
            _tokenURIs[tokenId] = _tokenUris[i];
            _safeMint(_to[i], tokenId);
        }
    }

    function transferMinter(address nextMinter) external onlyMinter {
        emit MinterTransferred(minter, nextMinter);
        minter = nextMinter;
    }

    function giveawayToDeNFTBridge() external onlyMinter {
        emit MinterTransferred(minter, deNFTBridge);
        minter = deNFTBridge;
    }

    function burn(uint256 _tokenId) public virtual override {
        require(
            _isApprovedOrOwner(_msgSender(), _tokenId),
            "ERC721Burnable: caller is not owner nor approved"
        );

        _burn(_tokenId);

        if (bytes(_tokenURIs[_tokenId]).length != 0) {
            delete _tokenURIs[_tokenId];
        }
    }


    function _baseURI() internal view override returns (string memory) {
        return _baseURIValue;
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }
}// MIT

pragma solidity ^0.8.0;

interface IBeacon {
    function implementation() external view returns (address);
}// MIT

pragma solidity ^0.8.0;

abstract contract Proxy {
    function _delegate(address implementation) internal virtual {
        assembly {
            calldatacopy(0, 0, calldatasize())

            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

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

    function _implementation() internal view virtual returns (address);

    function _fallback() internal virtual {
        _beforeFallback();
        _delegate(_implementation());
    }

    fallback() external payable virtual {
        _fallback();
    }

    receive() external payable virtual {
        _fallback();
    }

    function _beforeFallback() internal virtual {}
}// MIT

pragma solidity ^0.8.0;

library StorageSlot {
    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {
        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {
        assembly {
            r.slot := slot
        }
    }
}// MIT

pragma solidity ^0.8.2;


abstract contract ERC1967Upgrade {
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(Address.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlot.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(newImplementation, data);
        }

        StorageSlot.BooleanSlot storage rollbackTesting = StorageSlot.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            Address.functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlot.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlot.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlot.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(Address.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            Address.isContract(IBeacon(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlot.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            Address.functionDelegateCall(IBeacon(newBeacon).implementation(), data);
        }
    }
}// MIT

pragma solidity ^0.8.0;


contract BeaconProxy is Proxy, ERC1967Upgrade {
    constructor(address beacon, bytes memory data) payable {
        assert(_BEACON_SLOT == bytes32(uint256(keccak256("eip1967.proxy.beacon")) - 1));
        _upgradeBeaconToAndCall(beacon, data, false);
    }

    function _beacon() internal view virtual returns (address) {
        return _getBeacon();
    }

    function _implementation() internal view virtual override returns (address) {
        return IBeacon(_getBeacon()).implementation();
    }

    function _setBeacon(address beacon, bytes memory data) internal virtual {
        _upgradeBeaconToAndCall(beacon, data, false);
    }
}// BUSL-1.1
pragma solidity 0.8.7;


contract DeBridgeTokenProxy is BeaconProxy {
    constructor(address beacon, bytes memory data) BeaconProxy(beacon, data) {

    }
}// MIT
pragma solidity 0.8.7;



contract DeBridgeNFTDeployer is Initializable, AccessControlUpgradeable {

    address public beacon;
    address public nftBridgeAddress;
    mapping(bytes32 => address) public deployedAssetAddresses;

    uint256 nonce;


    error WrongArgument();
    error DeployedAlready();

    error AdminBadRole();
    error NFTBridgeBadRole();
    error DuplicateDebrdigeId();

    error ZeroAddress();


    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    modifier onlyNFTBridge() {
        if (msg.sender != nftBridgeAddress) revert NFTBridgeBadRole();
        _;
    }


    event NFTDeployed(address asset, string name, string symbol, string baseUri, uint256 nonce);


    function initialize(address _beacon, address _nftBridgeAddress) public initializer {
        if (_beacon == address(0) || _nftBridgeAddress == address(0)) revert ZeroAddress();

        beacon = _beacon;
        nftBridgeAddress = _nftBridgeAddress;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function deployAsset(
        bytes32 _debridgeId,
        string memory _name,
        string memory _symbol
    ) external onlyNFTBridge returns (address deBridgeTokenAddress) {
        if (deployedAssetAddresses[_debridgeId] != address(0)) revert DeployedAlready();

        deBridgeTokenAddress = _createNewAssets(nftBridgeAddress, _name, _symbol, "", _debridgeId);

        deployedAssetAddresses[_debridgeId] = deBridgeTokenAddress;
    }

    function createNFT(address _minter, string memory _name, string memory _symbol, string memory _baseUri)
        external
        onlyNFTBridge
        returns (address deBridgeTokenAddress)
    {
        deBridgeTokenAddress = _createNewAssets(
            _minter,
            _name,
            _symbol,
            _baseUri,
            keccak256(abi.encodePacked(nonce))
        );
        bytes32 debridgeId = getDebridgeId(getChainId(), deBridgeTokenAddress);
        if (deployedAssetAddresses[debridgeId] != address(0)) revert DuplicateDebrdigeId();
        deployedAssetAddresses[debridgeId] = deBridgeTokenAddress;
    }


    function setNftBridgeAddress(address _nftBridgeAddress) external onlyAdmin {
        if (_nftBridgeAddress == address(0)) revert WrongArgument();
        nftBridgeAddress = _nftBridgeAddress;
    }


    function _createNewAssets(
        address minter,
        string memory _name,
        string memory _symbol,
        string memory _baseUri,
        bytes32 salt
    ) internal returns (address deBridgeTokenAddress) {
        bytes memory initializationArgs = abi.encodeWithSelector(
            DeNFT.initialize.selector,
            _name,
            _symbol,
            _baseUri,
            minter,
            nftBridgeAddress
        );

        bytes memory constructorArgs = abi.encode(beacon, initializationArgs);

        bytes memory bytecode = abi.encodePacked(
            type(DeBridgeTokenProxy).creationCode,
            constructorArgs
        );

        assembly {
            deBridgeTokenAddress := create2(0, add(bytecode, 0x20), mload(bytecode), salt)

            if iszero(extcodesize(deBridgeTokenAddress)) {
                revert(0, 0)
            }
        }

        emit NFTDeployed(deBridgeTokenAddress, _name, _symbol, _baseUri, nonce);
        nonce++;
    }


    function getDebridgeId(uint256 _chainId, address _tokenAddress) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_chainId, _tokenAddress));
    }

    function getChainId() public view virtual returns (uint256 cid) {
        assembly {
            cid := chainid()
        }
    }


    function version() external pure returns (uint256) {
        return 100; // 1.0.0
    }
}// MIT
pragma solidity 0.8.7;


contract NFTBridge is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    IERC721ReceiverUpgradeable,
    INFTBridge
{
    using AddressUpgradeable for address payable;
    using AddressUpgradeable for address;

    uint256 public constant TOKEN_BURNABLE_TYPE = 1;


    mapping(bytes32 => BridgeNFTInfo) public getBridgeNFTInfo;
    mapping(address => NativeNFTInfo) public getNativeInfo;
    mapping(uint256 => ChainInfo) public getChainInfo;

    DeBridgeGate public deBridgeGate;
    DeBridgeNFTDeployer public deBridgeNFTDeployer;

    uint256 public nonce;

    mapping(address => uint256) public createdTokens;


    modifier onlyAdmin() {
        if (!hasRole(DEFAULT_ADMIN_ROLE, msg.sender)) revert AdminBadRole();
        _;
    }

    modifier onlyCrossBridgeAddress() {
        ICallProxy callProxy = ICallProxy(deBridgeGate.callProxy());
        if (address(callProxy) != msg.sender) {
            revert CallProxyBadRole();
        }

        bytes memory nativeSender = callProxy.submissionNativeSender();
        uint256 chainIdFrom = callProxy.submissionChainIdFrom();

        if (keccak256(getChainInfo[chainIdFrom].nftBridgeAddress) != keccak256(nativeSender)) {
            revert NativeSenderBadRole(nativeSender, chainIdFrom);
        }
        _;
    }


    function initialize(DeBridgeGate _deBridgeGate) public initializer {
        deBridgeGate = _deBridgeGate;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }


    function send(
        address _tokenAddress,
        uint256 _tokenId,
        uint256 _permitDeadline,
        bytes memory _permitSignature,
        uint256 _chainIdTo,
        address _receiver,
        uint256 _executionFee,
        uint32 _referralCode
    ) external payable nonReentrant whenNotPaused {
        if (!getChainInfo[_chainIdTo].isSupported) {
            revert ChainToIsNotSupported();
        }

        if (_permitSignature.length > 0) {
            IERC4494(_tokenAddress).permit(
                address(this),
                _tokenId,
                _permitDeadline,
                _permitSignature
            );
        }

        bool isNativeToken;
        bytes memory targetData;
        {
            NativeNFTInfo storage nativeTokenInfo = getNativeInfo[_tokenAddress];
            isNativeToken = nativeTokenInfo.chainId == 0
                ? true // token not in mapping
                : nativeTokenInfo.chainId == getChainId(); // token native chain id the same

            string memory tokenURI = IERC721MetadataUpgradeable(_tokenAddress).tokenURI(_tokenId);
            if (isNativeToken) {
                if (createdTokens[_tokenAddress] == TOKEN_BURNABLE_TYPE) {
                    _checkAddAsset(_tokenAddress);
                    IDeNFT(_tokenAddress).burn(_tokenId);
                } else {
                    _receiveNativeNFT(_tokenAddress, _tokenId);
                }
            } else {
                IDeNFT(_tokenAddress).burn(_tokenId);
            }

            targetData = nativeTokenInfo.chainId == _chainIdTo &&
                nativeTokenInfo.tokenType != TOKEN_BURNABLE_TYPE // is sending to native chain
                ? _encodeClaim(
                    _decodeAddressFromBytes(nativeTokenInfo.tokenAddress), // _decodeAddressFromBytes support only emv tokens now
                    _tokenId,
                    _receiver
                )
                : _encodeMint(
                    _tokenAddress,
                    _tokenId,
                    _receiver,
                    tokenURI,
                    nativeTokenInfo.tokenType
                );
        }

        {
            deBridgeGate.send{value: msg.value}(
                address(0), // _tokenAddress
                msg.value, // _amount
                _chainIdTo, // _chainIdTo
                abi.encodePacked(getChainInfo[_chainIdTo].nftBridgeAddress), // _receiver
                "", // _permit
                false, // _useAssetFee
                _referralCode, // _referralCode
                _encodeAutoParamsTo(targetData, _executionFee) // _autoParams
            );
        }
        emit NFTSent(_tokenAddress, _tokenId, abi.encodePacked(_receiver), _chainIdTo, nonce);
        nonce++;
    }

    function claim(
        address _tokenAddress,
        uint256 _tokenId,
        address _receiver
    )
        external
        onlyCrossBridgeAddress
        whenNotPaused
    {
        _safeTransferFrom(_tokenAddress, address(this), _receiver, _tokenId);

        emit NFTClaimed(
            _tokenAddress,
            _tokenId,
            _receiver
        );
    }

    function mint(
        bytes memory _nativeTokenAddress,
        uint256 _nativeChainId,
        uint256 _tokenId,
        address _receiver,
        string memory _nativeName,
        string memory _nativeSymbol,
        string memory _tokenUri,
        uint256 _tokenType
    )
        external
        onlyCrossBridgeAddress
        whenNotPaused
    {
        bytes32 debridgeId = getDebridgeId(_nativeChainId, _nativeTokenAddress);

        if (!getBridgeNFTInfo[debridgeId].exist) {
            address currentNFTAddress = deBridgeNFTDeployer.deployAsset(
                debridgeId,
                _nativeName,
                _nativeSymbol
            );
            _addAsset(
                debridgeId,
                currentNFTAddress,
                _nativeTokenAddress,
                _nativeChainId,
                _nativeName,
                _nativeSymbol,
                _tokenType
            );
        }

        address tokenAddress = getBridgeNFTInfo[debridgeId].tokenAddress;
        IDeNFT(tokenAddress).mint(_receiver, _tokenId, _tokenUri);

        emit NFTMinted(
            tokenAddress,
            _tokenId,
            _receiver,
            _tokenUri
        );
    }

    function createNFT(
        address _minter,
        string memory _name,
        string memory _symbol,
        string memory _baseUri
    ) external whenNotPaused {
        address currentNFTAddress = deBridgeNFTDeployer.createNFT(
            _minter,
            _name,
            _symbol,
            _baseUri
        );
        createdTokens[currentNFTAddress] = TOKEN_BURNABLE_TYPE;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }


    function setNFTDeployer(DeBridgeNFTDeployer _deBridgeNFTDeployer) external onlyAdmin {
        deBridgeNFTDeployer = _deBridgeNFTDeployer;
    }

    function setDeBridgeGate(DeBridgeGate _deBridgeGate) external onlyAdmin {
        deBridgeGate = _deBridgeGate;
    }

    function addChainSupport(bytes calldata _bridgeAddress, uint256 _chainId) external onlyAdmin {
        if (_chainId == 0 || _chainId == getChainId()) {
            revert WrongArgument();
        }
        getChainInfo[_chainId].nftBridgeAddress = _bridgeAddress;
        getChainInfo[_chainId].isSupported = true;

        emit AddedChainSupport(_bridgeAddress, _chainId);
    }

    function removeChainSupport(uint256 _chainId) external onlyAdmin {
        delete getChainInfo[_chainId];
        emit RemovedChainSupport(_chainId);
    }

    function pause() external onlyAdmin {
        _pause();
    }

    function unpause() external onlyAdmin {
        _unpause();
    }


    function _addAsset(
        bytes32 _debridgeId,
        address _tokenAddress,
        bytes memory _nativeAddress,
        uint256 _nativeChainId,
        string memory _nativeName,
        string memory _nativeSymbol,
        uint256 _tokenType
    ) internal {
        BridgeNFTInfo storage bridgeInfo = getBridgeNFTInfo[_debridgeId];

        if (bridgeInfo.exist) revert AssetAlreadyExist();
        if (_tokenAddress == address(0)) revert ZeroAddress();

        bridgeInfo.exist = true;
        bridgeInfo.tokenAddress = _tokenAddress;
        bridgeInfo.nativeChainId = _nativeChainId;

        NativeNFTInfo storage nativeTokenInfo = getNativeInfo[_tokenAddress];
        nativeTokenInfo.chainId = _nativeChainId;
        nativeTokenInfo.tokenAddress = _nativeAddress;
        nativeTokenInfo.name = _nativeName;
        nativeTokenInfo.symbol = _nativeSymbol;
        nativeTokenInfo.tokenType = _tokenType;

        emit NFTContractAdded(
            _debridgeId,
            _tokenAddress,
            abi.encodePacked(_nativeAddress),
            _nativeChainId,
            _nativeName,
            _nativeSymbol,
            _tokenType
        );
    }

    function _decodeAddressFromBytes(bytes memory _bytes) internal pure returns (address addr) {
        assembly {
            addr := mload(add(_bytes, 20))
        }
    }

    function _receiveNativeNFT(address _tokenAddress, uint256 _tokenId)
        internal
    {
        _checkAddAsset(_tokenAddress);
        _safeTransferFrom(_tokenAddress, msg.sender, address(this), _tokenId);
    }

    function _checkAddAsset(address _tokenAddress) internal returns (bytes32 debridgeId) {
        debridgeId = getDebridgeId(getChainId(), _tokenAddress);
        if (!getBridgeNFTInfo[debridgeId].exist) {
            _addAsset(
                debridgeId,
                _tokenAddress,
                abi.encodePacked(_tokenAddress),
                getChainId(),
                IERC721MetadataUpgradeable(_tokenAddress).name(),
                IERC721MetadataUpgradeable(_tokenAddress).symbol(),
                createdTokens[_tokenAddress]
            );
        }
    }

    function _safeTransferFrom(
        address _tokenAddress,
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        IERC721Upgradeable(_tokenAddress).safeTransferFrom(_from, _to, _tokenId);
        if (IERC721Upgradeable(_tokenAddress).ownerOf(_tokenId) != _to) revert NotReceivedERC721();
    }

    function _encodeClaim(
        address _nativeTokenAddress,
        uint256 _tokenId,
        address _receiver
    ) internal pure returns (bytes memory) {
        return
            abi.encodeWithSelector(
                this.claim.selector,
                _nativeTokenAddress,
                _tokenId,
                _receiver
            );
    }

    function _encodeMint(
        address _tokenAddress,
        uint256 _tokenId,
        address _receiver,
        string memory _tokenURI,
        uint256 _tokenType
    ) internal view returns (bytes memory) {
        NativeNFTInfo memory nativeTokenInfo = getNativeInfo[_tokenAddress];

        return
            abi.encodeWithSelector(
                this.mint.selector,
                nativeTokenInfo.tokenAddress, //_nativeTokenAddress
                nativeTokenInfo.chainId, //_nativeChainId
                _tokenId,
                _receiver,
                nativeTokenInfo.name, //_nativeSymbol
                nativeTokenInfo.symbol, //_nativeSymbol
                _tokenURI,
                _tokenType
            );
    }

    function _encodeAutoParamsTo(bytes memory _data, uint256 _executionFee)
        internal
        view
        returns (bytes memory)
    {
        IDeBridgeGate.SubmissionAutoParamsTo memory autoParams;
        autoParams.flags = Flags.setFlag(autoParams.flags, Flags.REVERT_IF_EXTERNAL_FAIL, true);
        autoParams.flags = Flags.setFlag(autoParams.flags, Flags.PROXY_WITH_SENDER, true);

        autoParams.fallbackAddress = abi.encodePacked(msg.sender);
        autoParams.data = _data;
        autoParams.executionFee = _executionFee;
        return abi.encode(autoParams);
    }


    function getDebridgeId(uint256 _chainId, address _tokenAddress) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_chainId, _tokenAddress));
    }

    function getDebridgeId(uint256 _chainId, bytes memory _tokenAddress)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_chainId, _tokenAddress));
    }

    function getChainId() public view virtual returns (uint256 cid) {
        assembly {
            cid := chainid()
        }
    }

    function version() external pure returns (uint256) {
        return 100; // 1.0.0
    }
}