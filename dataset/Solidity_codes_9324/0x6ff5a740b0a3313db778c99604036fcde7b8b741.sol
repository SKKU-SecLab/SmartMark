

pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal virtual view returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal virtual view returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// Apache-2.0


pragma solidity ^0.6.0;

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
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract IERC20Internal {
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual;

    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual;

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual;

    function _increaseAllowance(
        address owner,
        address spender,
        uint256 increment
    ) internal virtual;

    function _decreaseAllowance(
        address owner,
        address spender,
        uint256 decrement
    ) internal virtual;

    function _mint(address account, uint256 amount) internal virtual;

    function _burn(address account, uint256 amount) internal virtual;
}// Apache-2.0


pragma solidity ^0.6.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// Apache-2.0


pragma solidity ^0.6.2;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{
            value: weiValue
        }(data);
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
}// Apache-2.0



pragma solidity 0.6.12;

contract ERC20 is Context, IERC20, IERC20Internal {

    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor(string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function _setName(string memory newName) internal {

        _name = newName;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function _setSymbol(string memory newSymbol) internal {

        _symbol = newSymbol;
    }

    function decimals() external view returns (uint8) {

        return _decimals;
    }

    function _setDecimals(uint8 newDecimals) internal {

        _decimals = newDecimals;
    }

    function totalSupply() external override view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account)
        external
        override
        view
        returns (uint256)
    {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        external
        virtual
        override
        view
        returns (uint256)
    {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        external
        virtual
        override
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external virtual override returns (bool) {

        _transferFrom(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        virtual
        returns (bool)
    {

        _increaseAllowance(_msgSender(), spender, addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        virtual
        returns (bool)
    {

        _decreaseAllowance(_msgSender(), spender, subtractedValue);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(
            amount,
            "ERC20: transfer amount exceeds balance"
        );
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual override {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual override {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(
            amount,
            "ERC20: burn amount exceeds balance"
        );
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual override {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {

        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
    }

    function _increaseAllowance(
        address owner,
        address spender,
        uint256 addedValue
    ) internal virtual override {

        _approve(owner, spender, _allowances[owner][spender].add(addedValue));
    }

    function _decreaseAllowance(
        address owner,
        address spender,
        uint256 subtractedValue
    ) internal virtual override {

        _approve(
            owner,
            spender,
            _allowances[owner][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
    }
}// Apache-2.0


pragma solidity ^0.6.0;

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


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return address(uint256(_at(set._inner, index)));
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
}// Apache-2.0


pragma solidity ^0.6.0;

abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

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

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index)
        public
        view
        returns (address)
    {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(
            hasRole(_roles[role].adminRole, _msgSender()),
            "AccessControl: sender must be an admin to grant"
        );

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(
            hasRole(_roles[role].adminRole, _msgSender()),
            "AccessControl: sender must be an admin to revoke"
        );

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(
            account == _msgSender(),
            "AccessControl: can only renounce roles for self"
        );

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// Apache-2.0


pragma solidity 0.6.12;

contract AccessControlMixin is AccessControl {

    string private _revertMsg;

    function _setupContractId(string memory contractId) internal {

        _revertMsg = string(
            abi.encodePacked(contractId, ": INSUFFICIENT_PERMISSIONS")
        );
    }

    modifier only(bytes32 role) {

        require(hasRole(role, _msgSender()), _revertMsg);
        _;
    }
}// Apache-2.0


pragma solidity 0.6.12;

interface IChildToken {

    function deposit(address user, bytes calldata depositData) external;

}// Apache-2.0


pragma solidity 0.6.12;

contract Initializable {

    bool private _initialized = false;

    modifier initializer() {

        require(!_initialized);
        _;
        _initialized = true;
    }

    function initialized() external view returns (bool) {

        return _initialized;
    }
}// Apache-2.0



pragma solidity 0.6.12;

library ECRecover {

    function recover(
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {

        if (
            uint256(s) >
            0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF5D576E7357A4501DDFE92F46681B20A0
        ) {
            revert("ECRecover: invalid signature 's' value");
        }

        if (v != 27 && v != 28) {
            revert("ECRecover: invalid signature 'v' value");
        }

        address signer = ecrecover(digest, v, r, s);
        require(signer != address(0), "ECRecover: invalid signature");

        return signer;
    }
}// Apache-2.0



pragma solidity 0.6.12;

library EIP712 {

    bytes32
        public constant EIP712_DOMAIN_TYPEHASH = 0x36c25de3e541d5d970f66e4210d728721220fff5c077cc6cd008b3a0c62adab7;

    function makeDomainSeparator(string memory name, string memory version)
        internal
        view
        returns (bytes32)
    {

        uint256 chainId;
        assembly {
            chainId := chainid()
        }

        return
            keccak256(
                abi.encode(
                    EIP712_DOMAIN_TYPEHASH,
                    keccak256(bytes(name)),
                    keccak256(bytes(version)),
                    address(this),
                    bytes32(chainId)
                )
            );
    }

    function recover(
        bytes32 domainSeparator,
        uint8 v,
        bytes32 r,
        bytes32 s,
        bytes memory typeHashAndData
    ) internal pure returns (address) {

        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(typeHashAndData)
            )
        );
        return ECRecover.recover(digest, v, r, s);
    }
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract EIP712Domain {
    bytes32 public DOMAIN_SEPARATOR;

    function _setDomainSeparator(string memory name, string memory version)
        internal
    {
        DOMAIN_SEPARATOR = EIP712.makeDomainSeparator(name, version);
    }
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract Nonces {
    mapping(address => uint256) internal _nonces;

    function nonces(address owner) external view returns (uint256) {
        return _nonces[owner];
    }
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract NativeMetaTransaction is EIP712Domain, Nonces {
    bytes32
        public constant META_TRANSACTION_TYPEHASH = 0x23d10def3caacba2e4042e0c75d44a42d2558aabcf5ce951d0642a8032e1e653;

    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );

    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external payable returns (bytes memory) {
        MetaTransaction memory metaTx = MetaTransaction({
            nonce: _nonces[userAddress]++,
            from: userAddress,
            functionSignature: functionSignature
        });

        require(
            _verify(userAddress, metaTx, sigR, sigS, sigV),
            "Signer and signature do not match"
        );

        emit MetaTransactionExecuted(
            userAddress,
            msg.sender,
            functionSignature
        );

        (bool success, bytes memory returnData) = address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call not successful");

        return returnData;
    }

    function _verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {
        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");

        bytes memory data = abi.encode(
            META_TRANSACTION_TYPEHASH,
            metaTx.nonce,
            metaTx.from,
            keccak256(metaTx.functionSignature)
        );

        return
            EIP712.recover(DOMAIN_SEPARATOR, sigV, sigR, sigS, data) == signer;
    }
}// Apache-2.0



pragma solidity 0.6.12;

abstract contract GasAbstraction is IERC20Internal, EIP712Domain {
    bytes32
        public constant TRANSFER_WITH_AUTHORIZATION_TYPEHASH = 0x7c7c6cdb67a18743f49ec6fa9b35f50d52ed05cbed4cc592e13b44501c1a2267;
    bytes32
        public constant APPROVE_WITH_AUTHORIZATION_TYPEHASH = 0x808c10407a796f3ef2c7ea38c0638ea9d2b8a1c63e3ca9e1f56ce84ae59df73c;
    bytes32
        public constant INCREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH = 0x424222bb050a1f7f14017232a5671f2680a2d3420f504bd565cf03035c53198a;
    bytes32
        public constant DECREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH = 0xb70559e94cbda91958ebec07f9b65b3b490097c8d25c8dacd71105df1015b6d8;
    bytes32
        public constant CANCEL_AUTHORIZATION_TYPEHASH = 0x158b0a9edf7a828aad02f63cd515c68ef2f50ba807396f6d12842833a1597429;

    enum AuthorizationState { Unused, Used, Canceled }

    mapping(address => mapping(bytes32 => AuthorizationState))
        private _authorizationStates;

    event AuthorizationUsed(address indexed authorizer, bytes32 indexed nonce);
    event AuthorizationCanceled(
        address indexed authorizer,
        bytes32 indexed nonce
    );

    function authorizationState(address authorizer, bytes32 nonce)
        external
        view
        returns (AuthorizationState)
    {
        return _authorizationStates[authorizer][nonce];
    }

    function _transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _requireValidAuthorization(from, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            TRANSFER_WITH_AUTHORIZATION_TYPEHASH,
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == from,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(from, nonce);
        _transfer(from, to, value);
    }

    function _increaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 increment,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            INCREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            increment,
            validAfter,
            validBefore,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(owner, nonce);
        _increaseAllowance(owner, spender, increment);
    }

    function _decreaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 decrement,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            DECREASE_ALLOWANCE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            decrement,
            validAfter,
            validBefore,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(owner, nonce);
        _decreaseAllowance(owner, spender, decrement);
    }

    function _approveWithAuthorization(
        address owner,
        address spender,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            APPROVE_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            spender,
            value,
            validAfter,
            validBefore,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(owner, nonce);
        _approve(owner, spender, value);
    }

    function _cancelAuthorization(
        address authorizer,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _requireUnusedAuthorization(authorizer, nonce);

        bytes memory data = abi.encode(
            CANCEL_AUTHORIZATION_TYPEHASH,
            authorizer,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == authorizer,
            "GasAbstraction: invalid signature"
        );

        _authorizationStates[authorizer][nonce] = AuthorizationState.Canceled;
        emit AuthorizationCanceled(authorizer, nonce);
    }

    function _requireUnusedAuthorization(address authorizer, bytes32 nonce)
        private
        view
    {
        require(
            _authorizationStates[authorizer][nonce] ==
                AuthorizationState.Unused,
            "GasAbstraction: authorization is used or canceled"
        );
    }

    function _requireValidAuthorization(
        address authorizer,
        bytes32 nonce,
        uint256 validAfter,
        uint256 validBefore
    ) internal view {
        require(
            now > validAfter,
            "GasAbstraction: authorization is not yet valid"
        );
        require(now < validBefore, "GasAbstraction: authorization is expired");
        _requireUnusedAuthorization(authorizer, nonce);
    }

    function _markAuthorizationAsUsed(address authorizer, bytes32 nonce)
        internal
    {
        _authorizationStates[authorizer][nonce] = AuthorizationState.Used;
        emit AuthorizationUsed(authorizer, nonce);
    }
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract MaticGasAbstraction is GasAbstraction {
    bytes32
        public constant WITHDRAW_WITH_AUTHORIZATION_TYPEHASH = 0x6c8f8f5f82f0c140edd12e80d10ff715a36d6e5f73e406394862b5f1eb44c4f9;

    function _withdrawWithAuthorization(
        address owner,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        _requireValidAuthorization(owner, nonce, validAfter, validBefore);

        bytes memory data = abi.encode(
            WITHDRAW_WITH_AUTHORIZATION_TYPEHASH,
            owner,
            value,
            validAfter,
            validBefore,
            nonce
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
            "GasAbstraction: invalid signature"
        );

        _markAuthorizationAsUsed(owner, nonce);
        _burn(owner, value);
    }
}// Apache-2.0



pragma solidity 0.6.12;

abstract contract Permit is IERC20Internal, EIP712Domain, Nonces {
    bytes32
        public constant PERMIT_TYPEHASH = 0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;

    function _permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        require(msg.sender != address(this), "Caller is this contract");
        require(deadline >= now, "Permit: permit is expired");

        bytes memory data = abi.encode(
            PERMIT_TYPEHASH,
            owner,
            spender,
            value,
            _nonces[owner]++,
            deadline
        );
        require(
            EIP712.recover(DOMAIN_SEPARATOR, v, r, s, data) == owner,
            "Permit: invalid signature"
        );

        _approve(owner, spender, value);
    }
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract ContextMixin {
    function msgSender() internal view returns (address payable sender) {
        if (msg.sender == address(this)) {
            bytes memory array = msg.data;
            uint256 index = msg.data.length;
            assembly {
                sender := and(
                    mload(add(array, index)),
                    0xffffffffffffffffffffffffffffffffffffffff
                )
            }
        } else {
            sender = msg.sender;
        }
        return sender;
    }
}// Apache-2.0


pragma solidity 0.6.12;



contract UChildERC20 is
    ERC20,
    IChildToken,
    AccessControlMixin,
    Initializable,
    NativeMetaTransaction,
    ContextMixin,
    Permit,
    MaticGasAbstraction
{

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");
    string public constant EIP712_VERSION = "1";

    constructor() public ERC20("", "") {}

    function initialize(
        string calldata newName,
        string calldata newSymbol,
        uint8 newDecimals,
        address childChainManager
    ) external initializer {

        _setName(newName);
        _setSymbol(newSymbol);
        _setDecimals(newDecimals);
        _setupContractId(string(abi.encodePacked("Child", newSymbol)));
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(DEPOSITOR_ROLE, childChainManager);
        _setDomainSeparator(newName, EIP712_VERSION);
    }

    function _msgSender()
        internal
        virtual
        override
        view
        returns (address payable sender)
    {

        return ContextMixin.msgSender();
    }

    function updateMetadata(string calldata newName, string calldata newSymbol)
        external
        only(DEFAULT_ADMIN_ROLE)
    {

        _setName(newName);
        _setSymbol(newSymbol);
        _setDomainSeparator(newName, EIP712_VERSION);
    }

    function deposit(address user, bytes calldata depositData)
        external
        override
        only(DEPOSITOR_ROLE)
    {

        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }

    function withdraw(uint256 amount) external virtual {

        _burn(_msgSender(), amount);
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {

        _permit(owner, spender, value, deadline, v, r, s);
    }

    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {

        _transferWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function approveWithAuthorization(
        address owner,
        address spender,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {

        _approveWithAuthorization(
            owner,
            spender,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function increaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 increment,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {

        _increaseAllowanceWithAuthorization(
            owner,
            spender,
            increment,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function decreaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 decrement,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {

        _decreaseAllowanceWithAuthorization(
            owner,
            spender,
            decrement,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function withdrawWithAuthorization(
        address owner,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {

        _withdrawWithAuthorization(
            owner,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function cancelAuthorization(
        address authorizer,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external virtual {

        _cancelAuthorization(authorizer, nonce, v, r, s);
    }

    function mint(address account, uint256 amount) public {

        require(hasRole(MINTER_ROLE, msg.sender));
        _mint(account, amount);
    }
    
    function burnFrom(address account, uint256 amount) public {

        uint256 currentAllowance = this.allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract Pausable is AccessControlMixin {
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event Pause();
    event Unpause();

    bool internal _paused = false;

    modifier whenNotPaused() {
        require(!_paused, "Pausable: paused");
        _;
    }

    function pausers() external view returns (address[] memory) {
        uint256 count = getRoleMemberCount(PAUSER_ROLE);
        address[] memory list = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            list[i] = getRoleMember(PAUSER_ROLE, i);
        }

        return list;
    }

    function paused() external view returns (bool) {
        return _paused;
    }

    function pause() external only(PAUSER_ROLE) {
        _paused = true;
        emit Pause();
    }

    function unpause() external only(PAUSER_ROLE) {
        _paused = false;
        emit Unpause();
    }
}// Apache-2.0


pragma solidity ^0.6.0;

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
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
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(
            value
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            "SafeERC20: decreased allowance below zero"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(
                token.approve.selector,
                spender,
                newAllowance
            )
        );
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(
            data,
            "SafeERC20: low-level call failed"
        );
        if (returndata.length > 0) {
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract Rescuable is AccessControlMixin {
    using SafeERC20 for IERC20;

    bytes32 public constant RESCUER_ROLE = keccak256("RESCUER_ROLE");

    event RescuerChanged(address indexed newRescuer);

    function rescuers() external view returns (address[] memory) {
        uint256 count = getRoleMemberCount(RESCUER_ROLE);
        address[] memory list = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            list[i] = getRoleMember(RESCUER_ROLE, i);
        }

        return list;
    }

    function rescueERC20(
        IERC20 tokenContract,
        address to,
        uint256 amount
    ) external only(RESCUER_ROLE) {
        tokenContract.safeTransfer(to, amount);
    }
}// Apache-2.0


pragma solidity 0.6.12;

abstract contract Blacklistable is AccessControlMixin {
    bytes32 public constant BLACKLISTER_ROLE = keccak256("BLACKLISTER_ROLE");

    mapping(address => bool) internal _blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);

    modifier notBlacklisted(address account) {
        require(
            !_blacklisted[account],
            "Blacklistable: account is blacklisted"
        );
        _;
    }

    function blacklisters() external view returns (address[] memory) {
        uint256 count = getRoleMemberCount(BLACKLISTER_ROLE);
        address[] memory list = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            list[i] = getRoleMember(BLACKLISTER_ROLE, i);
        }

        return list;
    }

    function isBlacklisted(address account) external view returns (bool) {
        return _blacklisted[account];
    }

    function blacklist(address account) external only(BLACKLISTER_ROLE) {
        _blacklisted[account] = true;
        emit Blacklisted(account);
    }

    function unBlacklist(address account) external only(BLACKLISTER_ROLE) {
        _blacklisted[account] = false;
        emit UnBlacklisted(account);
    }
}// Apache-2.0






pragma solidity 0.6.12;

contract UChildAdministrableERC20 is
    UChildERC20,
    Blacklistable,
    Pausable,
    Rescuable
{

    
    function _msgSender()
        internal
        override(Context, UChildERC20)
        view
        returns (address payable sender)
    {

        return ContextMixin.msgSender();
    }

    function withdraw(uint256 amount)
        external
        override
        notBlacklisted(_msgSender())
    {

        _burn(_msgSender(), amount);
    }

    function transfer(address recipient, uint256 amount)
        external
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(recipient)
        returns (bool)
    {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount)
        external
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(spender)
        returns (bool)
    {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        external
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(sender)
        notBlacklisted(recipient)
        returns (bool)
    {

        _transferFrom(sender, recipient, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        external
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(spender)
        returns (bool)
    {

        _increaseAllowance(_msgSender(), spender, addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        override
        whenNotPaused
        notBlacklisted(_msgSender())
        notBlacklisted(spender)
        returns (bool)
    {

        _decreaseAllowance(_msgSender(), spender, subtractedValue);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override
        whenNotPaused
        notBlacklisted(owner)
        notBlacklisted(spender)
    {

        _permit(owner, spender, value, deadline, v, r, s);
    }

    function transferWithAuthorization(
        address from,
        address to,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override whenNotPaused notBlacklisted(from) notBlacklisted(to) {

        _transferWithAuthorization(
            from,
            to,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function approveWithAuthorization(
        address owner,
        address spender,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override
        whenNotPaused
        notBlacklisted(owner)
        notBlacklisted(spender)
    {

        _approveWithAuthorization(
            owner,
            spender,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function increaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 increment,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override
        whenNotPaused
        notBlacklisted(owner)
        notBlacklisted(spender)
    {

        _increaseAllowanceWithAuthorization(
            owner,
            spender,
            increment,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function decreaseAllowanceWithAuthorization(
        address owner,
        address spender,
        uint256 decrement,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
        override
        whenNotPaused
        notBlacklisted(owner)
        notBlacklisted(spender)
    {

        _decreaseAllowanceWithAuthorization(
            owner,
            spender,
            decrement,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function withdrawWithAuthorization(
        address owner,
        uint256 value,
        uint256 validAfter,
        uint256 validBefore,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override whenNotPaused notBlacklisted(owner) {

        _withdrawWithAuthorization(
            owner,
            value,
            validAfter,
            validBefore,
            nonce,
            v,
            r,
            s
        );
    }

    function cancelAuthorization(
        address authorizer,
        bytes32 nonce,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external override whenNotPaused {

        _cancelAuthorization(authorizer, nonce, v, r, s);
    }
}