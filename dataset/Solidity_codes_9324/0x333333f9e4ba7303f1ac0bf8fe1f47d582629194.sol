


pragma solidity ^0.8.10;

struct TransactionInfo {
    bool isBuy;
    bool isSell;
}

interface ICerbyBotDetection {


    function checkTransactionInfo(
        address _tokenAddr,
        address _sender,
        address _recipient,
        uint256 _recipientBalance,
        uint256 _transferAmount
    )
        external
        returns (TransactionInfo memory output);


    function isBotAddress(
        address _addr
    )
        external
        view
        returns (bool);


    function executeCronJobs()
        external;


    function detectBotTransaction(
        address _tokenAddr,
        address _addr
    )
        external
        returns (bool);


    function registerTransaction(
        address _tokenAddr,
        address _addr
    )
        external;

}




pragma solidity ^0.8.12;

struct AccessSettings {
    bool isMinter;
    bool isBurner;
    bool isTransferer;
    bool isModerator;
    bool isTaxer;
    address addr;
}

interface ICerbyToken {


    function allowance(
        address _owner,
        address _spender
    )
        external
        view
        returns (uint256);


    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) external returns (bool);


    function transfer(
        address _recipient,
        uint256 _amount
    )
        external
        returns (bool);


    function approve(
        address _spender,
        uint256 _value
    )
        external
        returns (bool success);


    function balanceOf(
        address _account
    )
        external
        view
        returns (uint256);


    function totalSupply()
        external
        view
        returns (uint256);


    function mintHumanAddress(
        address _to,
        uint256 _desiredAmountToMint
    )
        external;


    function burnHumanAddress(
        address _from,
        uint256 _desiredAmountToBurn
    )
        external;


    function mintByBridge(
        address _to,
        uint256 _realAmountToMint
    )
        external;


    function burnByBridge(
        address _from,
        uint256 _realAmountBurn
    )
        external;


    function getUtilsContractAtPos(
        uint256 _pos
    )
        external
        view
        returns (address);


    function updateUtilsContracts(
        AccessSettings[] calldata accessSettings
    )
        external;


    function transferCustom(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        external;

}




pragma solidity ^0.8.12;



abstract contract CerbyCronJobsExecution {

    uint256 constant CERBY_BOT_DETECTION_CONTRACT_ID = 3;

    ICerbyToken constant CERBY_TOKEN_INSTANCE = ICerbyToken(
        0xdef1fac7Bf08f173D286BbBDcBeeADe695129840
    );

    error CerbyCronJobsExecution_TransactionsAreTemporarilyDisabled();

    modifier detectBotTransactionThenRegisterTransactionAndExecuteCronJobsAfter(
        address _tokenIn,
        address _from,
        address _tokenOut,
        address _to
    ) {
        ICerbyBotDetection iCerbyBotDetection = ICerbyBotDetection(
            getUtilsContractAtPos(
                CERBY_BOT_DETECTION_CONTRACT_ID
            )
        );
        if (iCerbyBotDetection.detectBotTransaction(_tokenIn, _from)) {
            revert CerbyCronJobsExecution_TransactionsAreTemporarilyDisabled();
        }
        iCerbyBotDetection.registerTransaction(
            _tokenOut,
            _to
        );

        _;

        iCerbyBotDetection.executeCronJobs();
    }

    modifier checkForBotsAndExecuteCronJobsAfter(
        address _from
    ) {
        ICerbyBotDetection iCerbyBotDetection = ICerbyBotDetection(
            getUtilsContractAtPos(
                CERBY_BOT_DETECTION_CONTRACT_ID
            )
        );
        if (iCerbyBotDetection.isBotAddress(_from)) {
            revert CerbyCronJobsExecution_TransactionsAreTemporarilyDisabled();
        }

        _;

        iCerbyBotDetection.executeCronJobs();
    }

    function getUtilsContractAtPos(
        uint256 _pos
    )
        public
        view
        virtual
        returns (address)
    {
        return CERBY_TOKEN_INSTANCE.getUtilsContractAtPos(_pos);
    }
}




pragma solidity ^0.8.12;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
    }
}




pragma solidity ^0.8.12;

interface IERC20 {

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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}




pragma solidity ^0.8.12;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




pragma solidity ^0.8.12;



contract ERC20 is IERC20, IERC20Metadata {

    mapping(address => uint256) erc20Balances;

    mapping(address => mapping(address => uint256)) erc20Allowances;

    uint256 erc20TotalSupply;

    string erc20Name;
    string erc20Symbol;

    constructor(
        string memory _name, 
        string memory _symbol
    ) {
        erc20Name = _name;
        erc20Symbol = _symbol;
    }

    function name() 
        public 
        view 
        virtual 
        override 
        returns (string memory) 
    {

        return erc20Name;
    }

    function symbol() 
        public 
        view 
        virtual 
        override 
        returns (string memory) 
    {

        return erc20Symbol;
    }

    function decimals() 
        public 
        view 
        virtual 
        override 
        returns (uint8) 
    {

        return 18;
    }

    function totalSupply() 
        public 
        view 
        virtual 
        override 
        returns (uint256) 
    {

        return erc20TotalSupply;
    }

    function balanceOf(address _account)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return erc20Balances[_account];
    }

    function transfer(address _recipient, uint256 _amount)
        public
        virtual
        override
        returns (bool)
    {

        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function allowance(address _owner, address _spender)
        public
        view
        virtual
        override
        returns (uint256)
    {

        return erc20Allowances[_owner][_spender];
    }

    function approve(address _spender, uint256 _amount)
        public
        virtual
        override
        returns (bool)
    {

        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    ) 
        public 
        virtual 
        override 
        returns (bool) 
    {

        if (erc20Allowances[_sender][msg.sender] != type(uint256).max) {
            erc20Allowances[_sender][msg.sender] -= _amount;
        }

        _transfer(_sender, _recipient, _amount);

        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue)
        public
        virtual
        returns (bool)
    {

        _approve(
            msg.sender,
            _spender,
            erc20Allowances[msg.sender][_spender] + _addedValue
        );

        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue)
        public
        virtual
        returns (bool)
    {        

        _approve(
            msg.sender, 
            _spender, 
            erc20Allowances[msg.sender][_spender] - _subtractedValue
        );

        return true;
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    ) 
        internal 
        virtual 
    {

        erc20Balances[_sender] -= _amount;
        unchecked {
            erc20Balances[_recipient] += _amount; // user can't posess _amount larger than total supply => can't overflow
        }

        emit Transfer(_sender, _recipient, _amount);
    }

    function _mint(
        address _account, 
        uint256 _amount
    ) 
        internal 
        virtual 
    {

        erc20TotalSupply += _amount; // will overflow earlier than erc20Balances[account]
        unchecked {
            erc20Balances[_account] += _amount;
        }
        emit Transfer(address(0), _account, _amount);
    }

    function _burn(
        address _account, 
        uint256 _amount
    ) 
        internal 
        virtual 
    {

        erc20Balances[_account] -= _amount;

        unchecked {
            erc20TotalSupply -= _amount; // erc20Balances[_account] is not overflown then erc20TotalSupply isn't either
        }

        emit Transfer(_account, address(0), _amount);
    }

    function _approve(
        address _owner,
        address _spender,
        uint256 _amount
    ) 
        internal 
        virtual 
    {

        erc20Allowances[_owner][_spender] = _amount;
        emit Approval(_owner, _spender, _amount);
    }
}




pragma solidity ^0.8.12;

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


    function nonces(address owner) external view returns (uint256);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

}




pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set)
        internal
        view
        returns (bytes32[] memory)
    {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set)
        internal
        view
        returns (address[] memory)
    {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set)
        internal
        view
        returns (uint256[] memory)
    {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}




pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}




pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return interfaceId == type(IERC165).interfaceId;
    }
}




pragma solidity ^0.8.12;

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

    function toHexString(uint256 value, uint256 length)
        internal
        pure
        returns (string memory)
    {

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
}




pragma solidity ^0.8.12;


library ECDSA {

    enum RecoverError {
        NoError,
        InvalidSignature,
        InvalidSignatureLength,
        InvalidSignatureS,
        InvalidSignatureV
    }

    error ECDSA_InvalidSignature();
    error ECDSA_InvalidSignatureLength();
    error ECDSA_InvalidSignatureSValue();
    error ECDSA_InvalidSignatureVValue();

    function _throwError(RecoverError error) private pure {

        if (error == RecoverError.NoError) {
            return; // no error: do nothing
        } else if (error == RecoverError.InvalidSignature) {
            revert ECDSA_InvalidSignature();
        } else if (error == RecoverError.InvalidSignatureLength) {
            revert ECDSA_InvalidSignatureLength();
        } else if (error == RecoverError.InvalidSignatureS) {
            revert ECDSA_InvalidSignatureSValue();
        } else if (error == RecoverError.InvalidSignatureV) {
            revert ECDSA_InvalidSignatureVValue();
        }
    }

    function tryRecover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address, RecoverError)
    {

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

    function recover(bytes32 hash, bytes memory signature)
        internal
        pure
        returns (address)
    {

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
            s := and(
                vs,
                0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
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

        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
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

    function toEthSignedMessageHash(bytes32 hash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            );
    }

    function toEthSignedMessageHash(bytes memory s)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n",
                    Strings.toString(s.length),
                    s
                )
            );
    }

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash)
        internal
        pure
        returns (bytes32)
    {

        return
            keccak256(
                abi.encodePacked("\x19\x01", domainSeparator, structHash)
            );
    }
}




pragma solidity ^0.8.12;


abstract contract EIP712 {
    bytes32 private immutable _CACHED_DOMAIN_SEPARATOR;
    uint256 private immutable _CACHED_CHAIN_ID;
    address private immutable _CACHED_THIS;

    bytes32 private immutable _HASHED_NAME;
    bytes32 private immutable _HASHED_VERSION;
    bytes32 private immutable _TYPE_HASH;


    constructor(string memory name, string memory version) {
        bytes32 hashedName = keccak256(bytes(name));
        bytes32 hashedVersion = keccak256(bytes(version));
        bytes32 typeHash = keccak256(
            "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
        );
        _HASHED_NAME = hashedName;
        _HASHED_VERSION = hashedVersion;
        _CACHED_CHAIN_ID = block.chainid;
        _CACHED_DOMAIN_SEPARATOR = _buildDomainSeparator(
            typeHash,
            hashedName,
            hashedVersion
        );
        _CACHED_THIS = address(this);
        _TYPE_HASH = typeHash;
    }

    function _domainSeparatorV4() internal view returns (bytes32) {
        if (
            address(this) == _CACHED_THIS && block.chainid == _CACHED_CHAIN_ID
        ) {
            return _CACHED_DOMAIN_SEPARATOR;
        } else {
            return
                _buildDomainSeparator(
                    _TYPE_HASH,
                    _HASHED_NAME,
                    _HASHED_VERSION
                );
        }
    }

    function _buildDomainSeparator(
        bytes32 typeHash,
        bytes32 nameHash,
        bytes32 versionHash
    ) private view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    typeHash,
                    nameHash,
                    versionHash,
                    block.chainid,
                    address(this)
                )
            );
    }

    function _hashTypedDataV4(bytes32 structHash)
        internal
        view
        virtual
        returns (bytes32)
    {
        return ECDSA.toTypedDataHash(_domainSeparatorV4(), structHash);
    }
}




pragma solidity ^0.8.12;






abstract contract ERC20Permit is ERC20, IERC20Permit, EIP712 {
    using Counters for Counters.Counter;

    mapping(address => Counters.Counter) private _nonces;

    bytes32 private immutable _PERMIT_TYPEHASH =
        keccak256(
            "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
        );

    error ERC20Permit_ExpiredDeadline();
    error ERC20Permit_InvalidSignature();

    constructor(string memory name) EIP712(name, "1") {}

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual override {
        if (block.timestamp > deadline) {
            revert ERC20Permit_ExpiredDeadline();
        }

        bytes32 structHash = keccak256(
            abi.encode(
                _PERMIT_TYPEHASH,
                owner,
                spender,
                value,
                _useNonce(owner),
                deadline
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (
                signer == address(0) || 
                signer != owner
        ) {
            revert ERC20Permit_InvalidSignature();
        }

        _approve(owner, spender, value);
    }

    function nonces(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _nonces[owner].current();
    }

    function DOMAIN_SEPARATOR() external view override returns (bytes32) {
        return _domainSeparatorV4();
    }

    function _useNonce(address owner)
        internal
        virtual
        returns (uint256 current)
    {
        Counters.Counter storage nonce = _nonces[owner];
        current = nonce.current();
        nonce.increment();
    }
}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(
        bytes32 indexed role,
        bytes32 indexed previousAdminRole,
        bytes32 indexed newAdminRole
    );

    event RoleGranted(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    event RoleRevoked(
        bytes32 indexed role,
        address indexed account,
        address indexed sender
    );

    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}




pragma solidity ^0.8.0;





struct RoleAccess {
    bytes32 role;
    address addr;
}

abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant ROLE_ADMIN = 0x00;

    error AccountIsMissingRole(address account, bytes32 role);
    error CanOnlyRenounceRoleForSelf();

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function hasRole(bytes32 role, address account)
        public
        view
        override
        returns (bool)
    {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert AccountIsMissingRole(account, role);
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account)
        public
        virtual
        override
        onlyRole(getRoleAdmin(role))
    {
        _grantRole(role, account);
    }

    function grantRolesBulk(RoleAccess[] calldata roles)
        public
        onlyRole(ROLE_ADMIN)
    {
        for (uint256 i = 0; i < roles.length; i++) {
            _setupRole(roles[i].role, roles[i].addr);
        }
    }

    function revokeRole(bytes32 role, address account)
        public
        virtual
        override
        onlyRole(getRoleAdmin(role))
    {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account)
        public
        virtual
        override
    {
        if (account != _msgSender()) {
            revert CanOnlyRenounceRoleForSelf();
        }

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
}




pragma solidity ^0.8.0;


interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index)
        external
        view
        returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}




pragma solidity ^0.8.0;




abstract contract AccessControlEnumerable is
    IAccessControlEnumerable,
    AccessControl
{
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override
        returns (bool)
    {
        return
            interfaceId == type(IAccessControlEnumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index)
        public
        view
        override
        returns (address)
    {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role)
        public
        view
        override
        returns (uint256)
    {
        return _roleMembers[role].length();
    }

    function _grantRole(bytes32 role, address account)
        internal
        virtual
        override
    {
        super._grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function _revokeRole(bytes32 role, address account)
        internal
        virtual
        override
    {
        super._revokeRole(role, account);
        _roleMembers[role].remove(account);
    }
}




pragma solidity ^0.8.12;




contract CerbyBasedToken is
    AccessControlEnumerable,
    ERC20,
    ERC20Permit,
    CerbyCronJobsExecution
{

    bytes32 public constant ROLE_MINTER = keccak256("ROLE_MINTER");
    bytes32 public constant ROLE_BURNER = keccak256("ROLE_BURNER");
    bytes32 public constant ROLE_TRANSFERER = keccak256("ROLE_TRANSFERER");
    bytes32 public constant ROLE_MODERATOR = keccak256("ROLE_MODERATOR");

    bool public isPaused;

    event TransferCustom(
        address _sender, 
        address _recipient, 
        uint256 _amount
    );
    event MintHumanAddress(
        address _recipient, 
        uint256 _amount
    );
    event BurnHumanAddress(
        address _sender, 
        uint256 _amount
    );

    error CerbyBasedToken_AlreadyInitialized();
    error CerbyBasedToken_ContractIsPaused();
    error CerbyBasedToken_ContractIsNotPaused();

    constructor(
        string memory _name, 
        string memory _symbol
    )
        ERC20(_name, _symbol)
        ERC20Permit(_name)
    {
        _setupRole(ROLE_ADMIN, msg.sender);
        _setupRole(ROLE_MINTER, msg.sender);
        _setupRole(ROLE_BURNER, msg.sender);
        _setupRole(ROLE_TRANSFERER, msg.sender);
        _setupRole(ROLE_MODERATOR, msg.sender);
    }

    modifier checkTransaction(
        address _from,
        address _to,
        uint256 _amount
    ) {

        ICerbyBotDetection iCerbyBotDetection = ICerbyBotDetection(
            getUtilsContractAtPos(CERBY_BOT_DETECTION_CONTRACT_ID)
        );
        iCerbyBotDetection.checkTransactionInfo(
            address(this),
            _from,
            _to,
            erc20Balances[_to],
            _amount
        );
        _;
    }

    modifier notPausedContract() {

        if (isPaused) {
            revert CerbyBasedToken_ContractIsPaused();
        }
        _;
    }

    modifier pausedContract() {

        if (!isPaused) {
            revert CerbyBasedToken_ContractIsNotPaused();
        }
        _;
    }

    function updateNameAndSymbol(
        string calldata _name,
        string calldata _symbol
    ) 
        external 
        onlyRole(ROLE_ADMIN) 
    {

        erc20Name = _name;
        erc20Symbol = _symbol;
    }

    function pauseContract() 
        external 
        notPausedContract 
        onlyRole(ROLE_ADMIN) 
    {

        isPaused = true;
    }

    function resumeContract() 
        external 
        pausedContract 
        onlyRole(ROLE_ADMIN)
    {

        isPaused = false;
    }

    function approve(
        address _spender, 
        uint256 _amount
    )
        public
        virtual
        override
        notPausedContract
        checkForBotsAndExecuteCronJobsAfter(msg.sender)
        returns (bool)
    {

        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function increaseAllowance(
        address _spender, 
        uint256 _addedValue
    )
        public
        virtual
        override
        notPausedContract
        checkForBotsAndExecuteCronJobsAfter(msg.sender)
        returns (bool)
    {

        _approve(
            msg.sender,
            _spender,
            erc20Allowances[msg.sender][_spender] + _addedValue
        );
        return true;
    }

    function decreaseAllowance(
        address _spender, 
        uint256 _subtractedValue
    )
        public
        virtual
        override
        notPausedContract
        checkForBotsAndExecuteCronJobsAfter(msg.sender)
        returns (bool)
    {  

        _approve(
            msg.sender, 
            _spender, 
            erc20Allowances[msg.sender][_spender] - _subtractedValue
        );

        return true;
    }

    function transfer(
        address _recipient, 
        uint256 _amount
    )
        public
        virtual
        override
        notPausedContract
        returns (bool)
    {

        _transfer(msg.sender, _recipient, _amount);
        return true;
    }

    function transferFrom(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        public
        virtual
        override
        notPausedContract
        returns (bool)
    {

        if (erc20Allowances[_sender][msg.sender] != type(uint256).max) {
            erc20Allowances[_sender][msg.sender] -= _amount;
        }

        _transfer(_sender, _recipient, _amount);

        return true;
    }

    function moderatorTransferFromWhilePaused(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        external
        pausedContract
        onlyRole(ROLE_MODERATOR)
        returns (bool)
    {

        _transfer(_sender, _recipient, _amount);

        return true;
    }

    function transferCustom(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        external
        notPausedContract
        onlyRole(ROLE_TRANSFERER)
    {

        _transfer(_sender, _recipient, _amount);

        emit TransferCustom(_sender, _recipient, _amount);
    }

    function _transfer(
        address _sender,
        address _recipient,
        uint256 _amount
    )
        internal
        virtual
        override
        checkTransaction(_sender, _recipient, _amount)
    {

        erc20Balances[_sender] -= _amount;
        unchecked {
            erc20Balances[_recipient] += _amount; // user can't posess _amount larger than total supply => can't overflow
        }

        emit Transfer(_sender, _recipient, _amount);
    }

    function mintHumanAddress(
        address _to, 
        uint256 _amount
    )
        external
        notPausedContract
        onlyRole(ROLE_MINTER)
    {

        _mint(_to, _amount);
        emit MintHumanAddress(_to, _amount);
    }

    function burnHumanAddress(
        address _from, 
        uint256 _amount
    )
        external
        notPausedContract
        onlyRole(ROLE_BURNER)
    {

        _burn(_from, _amount);
        emit BurnHumanAddress(_from, _amount);
    }
}




pragma solidity ^0.8.12;


contract CerbyUsdToken is CerbyBasedToken {


    constructor() 
        CerbyBasedToken("Cerby USD Token", "cerUSD") 
    {
    }
}