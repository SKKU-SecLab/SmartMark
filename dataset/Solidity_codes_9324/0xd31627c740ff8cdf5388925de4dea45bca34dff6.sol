
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

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
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
pragma solidity =0.8.4;

interface WQBridgeTokenInterface {

    function mint(address account, uint256 amount) external;


    function burn(address account, uint256 amount) external;

}// MIT
pragma solidity ^0.8.0;


contract WQBridgePool is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable
{

    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address payable;

    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');
    bytes32 public constant BRIDGE_ROLE = keccak256('BRIDGE_ROLE');

    bool private initialized;

    mapping(address => bool) public isBlockListed;

    event AddedBlockList(address user);
    event RemovedBlockList(address user);
    event Transferred(address token, address recipient, uint256 amount);
    event TransferredNative(address sender, uint256 amount);

    function initialize() external initializer {

        __AccessControl_init();
        __Pausable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(BRIDGE_ROLE, ADMIN_ROLE);
    }

    function transfer(
        address payable recipient,
        uint256 amount,
        address token
    ) external onlyRole(BRIDGE_ROLE) whenNotPaused {

        require(
            isBlockListed[recipient] == false,
            'WQBridgePool: Recipient address is blocklisted'
        );
        if (token != address(0)) {
            IERC20Upgradeable(token).safeTransfer(recipient, amount);
        } else {
            recipient.sendValue(amount);
        }
        emit Transferred(token, recipient, amount);
    }

    receive() external payable {
        emit TransferredNative(msg.sender, msg.value);
    }

    function removeLiquidity(
        address payable recipient,
        uint256 amount,
        address token
    ) external onlyRole(ADMIN_ROLE) {

        require(recipient != payable(0), 'WQBridge: invalid recipient address');
        if (token != address(0)) {
            IERC20Upgradeable(token).safeTransfer(recipient, amount);
        } else {
            recipient.sendValue(amount);
        }
        emit Transferred(token, recipient, amount);
    }

    function pause() external onlyRole(ADMIN_ROLE) {

        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {

        _unpause();
    }

    function addBlockList(address user) external onlyRole(ADMIN_ROLE) {

        isBlockListed[user] = true;
        emit AddedBlockList(user);
    }

    function removeBlockList(address user) external onlyRole(ADMIN_ROLE) {

        isBlockListed[user] = false;
        emit RemovedBlockList(user);
    }
}// MIT
pragma solidity ^0.8.0;


contract WQBridge is
    Initializable,
    AccessControlUpgradeable,
    PausableUpgradeable
{

    using ECDSAUpgradeable for bytes32;
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using AddressUpgradeable for address payable;

    enum State {
        Empty,
        Initialized,
        Redeemed
    }

    struct SwapData {
        uint256 nonce;
        State state;
    }

    struct TokenSettings {
        address token;
        bool enabled;
        bool native;
        bool lockable;
    }

    bytes32 public constant ADMIN_ROLE = keccak256('ADMIN_ROLE');

    bytes32 public constant VALIDATOR_ROLE = keccak256('VALIDATOR_ROLE');

    uint256 public chainId;

    address payable public pool;

    mapping(uint256 => bool) public chains;

    mapping(string => TokenSettings) public tokens;

    mapping(bytes32 => SwapData) public swaps;

    event SwapInitialized(
        uint256 timestamp,
        address indexed sender,
        address recipient,
        uint256 amount,
        uint256 chainFrom,
        uint256 chainTo,
        uint256 nonce,
        string symbol
    );

    event SwapRedeemed(
        uint256 timestamp,
        address indexed sender,
        address recipient,
        uint256 amount,
        uint256 chainFrom,
        uint256 chainTo,
        uint256 nonce,
        string symbol
    );

    event Transferred(address token, address recipient, uint256 amount);

    function initialize(uint256 _chainId, address payable _pool)
        external
        initializer
    {

        __AccessControl_init();
        __Pausable_init();
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(VALIDATOR_ROLE, ADMIN_ROLE);
        chainId = _chainId; // 1 - WQ, 2 - ETH, 3 - BSC     // TO_ASK why not standart numbers for chains?
        require(_pool != payable(0), 'WQBridge: invalid pool address');
        pool = _pool;
    }

    function swap(
        uint256 nonce,
        uint256 chainTo,
        uint256 amount,
        address recipient,
        string memory symbol
    ) external payable whenNotPaused {

        require(chainTo != chainId, 'WorkQuest Bridge: Invalid chainTo id');
        require(chains[chainTo], 'WorkQuest Bridge: ChainTo ID is not allowed');
        TokenSettings storage token = tokens[symbol];
        require(
            token.enabled,
            'WorkQuest Bridge: This token not registered or disabled'
        );

        bytes32 message = keccak256(
            abi.encodePacked(nonce, amount, recipient, chainId, chainTo, symbol)
        );
        require(
            swaps[message].state == State.Empty,
            'WorkQuest Bridge: Swap is not empty state or duplicate transaction'
        );

        swaps[message] = SwapData({nonce: nonce, state: State.Initialized});
        if (token.lockable) {
            IERC20Upgradeable(token.token).safeTransferFrom(
                msg.sender,
                pool,
                amount
            );
        } else if (token.native) {
            require(
                msg.value == amount,
                'WorkQuest Bridge: Amount value is not equal to transfered funds'
            );
            pool.sendValue(amount);
        } else {
            WQBridgeTokenInterface(token.token).burn(msg.sender, amount);
        }
        emit SwapInitialized(
            block.timestamp,
            msg.sender,
            recipient,
            amount,
            chainId,
            chainTo,
            nonce,
            symbol
        );
    }

    function redeem(
        uint256 nonce,
        uint256 chainFrom,
        uint256 amount,
        address payable recipient,
        uint8 v,
        bytes32 r,
        bytes32 s,
        string memory symbol
    ) external whenNotPaused {

        require(chainFrom != chainId, 'WorkQuest Bridge: Invalid chainFrom ID');
        require(
            chains[chainFrom],
            'WorkQuest Bridge: chainFrom ID is not allowed'
        );
        require(
            tokens[symbol].enabled,
            'WorkQuest Bridge: This token not registered or disabled'
        );

        bytes32 message = keccak256(
            abi.encodePacked(
                nonce,
                amount,
                recipient,
                chainFrom,
                chainId,
                symbol
            )
        );
        require(
            swaps[message].state == State.Empty,
            'WorkQuest Bridge: Swap is not empty state or duplicate transaction'
        );

        require(
            hasRole(
                VALIDATOR_ROLE,
                message.toEthSignedMessageHash().recover(v, r, s)
            ),
            'WorkQuest Bridge: Validator address is invalid or signature is faked'
        );

        swaps[message] = SwapData({nonce: nonce, state: State.Redeemed});
        if (tokens[symbol].lockable) {
            WQBridgePool(pool).transfer(
                recipient,
                amount,
                tokens[symbol].token
            );
        } else if (tokens[symbol].native) {
            WQBridgePool(pool).transfer(recipient, amount, address(0));
        } else {
            WQBridgeTokenInterface(tokens[symbol].token).mint(
                recipient,
                amount
            );
        }

        emit SwapRedeemed(
            block.timestamp,
            msg.sender,
            recipient,
            amount,
            chainFrom,
            chainId,
            nonce,
            symbol
        );
    }

    function getSwapState(bytes32 message) external view returns (State state) {

        return swaps[message].state;
    }

    function updateChain(uint256 _chainId, bool enabled)
        external
        onlyRole(ADMIN_ROLE)
    {

        chains[_chainId] = enabled;
    }

    function updatePool(address payable _pool) external onlyRole(ADMIN_ROLE) {

        require(_pool != payable(0), 'WQBridge: invalid pool address');
        pool = _pool;
    }

    function updateToken(
        address token,
        bool enabled,
        bool native,
        bool lockable,
        string memory symbol
    ) public onlyRole(ADMIN_ROLE) {

        require(
            bytes(symbol).length > 0,
            'WorkQuest Bridge: Symbol length must be greater than 0'
        );
        tokens[symbol] = TokenSettings({
            token: token,
            enabled: enabled,
            native: native,
            lockable: lockable
        });
    }

    function pause() external onlyRole(ADMIN_ROLE) {

        _pause();
    }

    function unpause() external onlyRole(ADMIN_ROLE) {

        _unpause();
    }

    function removeLiquidity(
        address payable recipient,
        uint256 amount,
        address token
    ) external onlyRole(ADMIN_ROLE) {

        require(recipient != payable(0), 'WQBridge: invalid recipient address');
        if (token != address(0)) {
            IERC20Upgradeable(token).safeTransfer(recipient, amount);
        } else {
            recipient.transfer(amount);
        }
        emit Transferred(token, recipient, amount);
    }
}