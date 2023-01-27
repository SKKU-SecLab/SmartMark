
pragma solidity ^0.8.0;

interface IAccessControl {

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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
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
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
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
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
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

interface ITokenERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function mint(address account, uint256 amount) external;


    function burn(address account, uint256 amount) external;

}// UNLICENSED
pragma solidity ^0.8.6;


contract Bridge is AccessControl {

    using ECDSA for bytes32;

    enum SwapState {
        EMPTY,
        SWAPPED,
        REDEEMED
    }

    struct Swap {
        uint256 nonce;
        SwapState state;
    }

    struct TokenInfo {
        address tokenAddress;
        string symbol;
    }

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");

    mapping(string => TokenInfo) public tokenBySymbol;

    mapping(uint256 => bool) public isChainActiveById;

    mapping(bytes32 => Swap) public swapByHash;

    string[] public tokenSymbols;

    event SwapInitialized(
        address indexed initiator,
        address recipient,
        uint256 initTimestamp,
        uint256 amount,
        uint256 chainFrom,
        uint256 chainTo,
        uint256 nonce,
        string symbol
    );

    event SwapRedeemed(
        address indexed initiator,
        address recipient,
        uint256 initTimestamp,
        uint256 amount,
        uint256 chainFrom,
        uint256 chainTo,
        uint256 nonce,
        string symbol
    );

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(ADMIN_ROLE, msg.sender);
        _setRoleAdmin(ADMIN_ROLE, DEFAULT_ADMIN_ROLE);
    }

    function updateChainById(uint256 _chainId, bool _isActive)
        external
        onlyRole(ADMIN_ROLE)
    {

        isChainActiveById[_chainId] = _isActive;
    }

    function includeToken(string memory _symbol, address _tokenAddress)
        external
        onlyRole(ADMIN_ROLE)
    {

        tokenBySymbol[_symbol] = TokenInfo({
            tokenAddress: _tokenAddress,
            symbol: _symbol
        });
        tokenSymbols.push(_symbol);
    }

    function excludeToken(string memory _symbol) external onlyRole(ADMIN_ROLE) {

        delete tokenBySymbol[_symbol];
        bytes32 symbol = keccak256(abi.encodePacked(_symbol));
        for (uint256 i; i < tokenSymbols.length; i++) {
            if (keccak256(abi.encodePacked(tokenSymbols[i])) == symbol) {
                tokenSymbols[i] = tokenSymbols[tokenSymbols.length - 1];
                tokenSymbols.pop();
            }
        }
    }

    function swap(
        address _recipient,
        uint256 _amount,
        uint256 _chainTo,
        uint256 _nonce,
        string memory _symbol
    ) external {

        uint256 chainFrom_ = getChainID();
        require(
            _chainTo != chainFrom_,
            "Bridge: Invalid chainTo is same with current bridge chain"
        );

        require(
            isChainActiveById[_chainTo],
            "Bridge: Destination chain is not active"
        );

        bytes32 hash_ = keccak256(
            abi.encodePacked(
                _recipient,
                _amount,
                chainFrom_,
                _chainTo,
                _nonce,
                _symbol
            )
        );
        require(
            swapByHash[hash_].state == SwapState.EMPTY,
            "Bridge: Swap with given params already exists"
        );

        TokenInfo memory token = tokenBySymbol[_symbol];
        require(
            token.tokenAddress != address(0),
            "Bridge: Token does not exist"
        );

        ITokenERC20(token.tokenAddress).burn(msg.sender, _amount);

        swapByHash[hash_] = Swap({nonce: _nonce, state: SwapState.SWAPPED});

        emit SwapInitialized(
            msg.sender,
            _recipient,
            block.timestamp,
            _amount,
            chainFrom_,
            _chainTo,
            _nonce,
            _symbol
        );
    }

    function redeem(
        address _recipient,
        uint256 _amount,
        uint256 _chainFrom,
        uint256 _nonce,
        string memory _symbol,
        bytes calldata _signature
    ) external {

        uint256 chainTo_ = getChainID();

        require(
            _chainFrom != chainTo_,
            "Bridge: Invalid chainFrom is same with current bridge chain"
        );

        require(
            isChainActiveById[_chainFrom],
            "Bridge: Initial chain is not active"
        );

        bytes32 hash_ = keccak256(
            abi.encodePacked(
                _recipient,
                _amount,
                _chainFrom,
                chainTo_,
                _nonce,
                _symbol
            )
        ).toEthSignedMessageHash();
        require(
            swapByHash[hash_].state == SwapState.EMPTY,
            "Bridge: Redeem with given params already exists"
        );

        address validatorAddress_ = hash_.recover(_signature);
        require(
            hasRole(VALIDATOR_ROLE, validatorAddress_),
            "Bridge: Validator address isn't correct"
        );

        TokenInfo memory token = tokenBySymbol[_symbol];
        require(
            token.tokenAddress != address(0),
            "Bridge: Token does not exist"
        );

        ITokenERC20(token.tokenAddress).mint(_recipient, _amount);

        swapByHash[hash_] = Swap({nonce: _nonce, state: SwapState.REDEEMED});

        emit SwapRedeemed(
            msg.sender,
            _recipient,
            block.timestamp,
            _amount,
            _chainFrom,
            chainTo_,
            _nonce,
            _symbol
        );
    }

    function withdrawToken(address token, uint256 amount)
        external
        onlyRole(ADMIN_ROLE)
    {

        ITokenERC20(token).transfer(msg.sender, amount);
    }

    function getSwapState(bytes32 _txHash) external view returns (uint256) {

        return uint256(swapByHash[_txHash].state);
    }

    function getTokenList() external view returns (TokenInfo[] memory) {

        TokenInfo[] memory tokens = new TokenInfo[](tokenSymbols.length);
        for (uint256 i = 0; i < tokenSymbols.length; i++) {
            tokens[i] = tokenBySymbol[tokenSymbols[i]];
        }
        return tokens;
    }

    function getChainID() public view returns (uint256 id) {

        assembly {
            id := chainid()
        }
    }
}