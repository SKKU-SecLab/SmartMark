

pragma solidity 0.8.7;




abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


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

    function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32) {

        return keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
    }
}


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

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }

    function values(AddressSet storage set) internal view returns (address[] memory) {

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

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}


interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


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
}


library TransferHelper {

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}


interface IAccessControlEnumerable is IAccessControl {

    function getRoleMember(bytes32 role, uint256 index) external view returns (address);


    function getRoleMemberCount(bytes32 role) external view returns (uint256);

}


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
}


abstract contract AccessControlEnumerable is IAccessControlEnumerable, AccessControl {
    using EnumerableSet for EnumerableSet.AddressSet;

    mapping(bytes32 => EnumerableSet.AddressSet) private _roleMembers;

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControlEnumerable).interfaceId || super.supportsInterface(interfaceId);
    }

    function getRoleMember(bytes32 role, uint256 index) public view override returns (address) {
        return _roleMembers[role].at(index);
    }

    function getRoleMemberCount(bytes32 role) public view override returns (uint256) {
        return _roleMembers[role].length();
    }

    function grantRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.grantRole(role, account);
        _roleMembers[role].add(account);
    }

    function revokeRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.revokeRole(role, account);
        _roleMembers[role].remove(account);
    }

    function renounceRole(bytes32 role, address account) public virtual override(AccessControl, IAccessControl) {
        super.renounceRole(role, account);
        _roleMembers[role].remove(account);
    }

    function _setupRole(bytes32 role, address account) internal virtual override {
        super._setupRole(role, account);
        _roleMembers[role].add(account);
    }
}


contract SwapContract is AccessControlEnumerable
{

    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");

    IERC20 public tokenAddress;
    uint256 public maxSwapAmountPerTx;
    uint256 public minSwapAmountPerTx;

    uint128 [3] public swapRatios;
    bool [3] public swapEnabled;

    mapping(address => bool) public swapLimitsSaved;
    mapping(address => uint256 [3]) swapLimits;

    event Deposit(address user, uint256 amount, uint256 amountToReceive, address newAddress);
    event TokensClaimed(address recipient, uint256 amount);

    modifier onlyOwner() {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "Caller is not in owner role"
        );
        _;
    }

    modifier onlyOwnerAndValidator() {

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) || hasRole(VALIDATOR_ROLE, _msgSender()),
            "Caller is not in owner or validator role"
        );
        _;
    }

    constructor(
        IERC20 _tokenAddress,
        address validatorAddress,
        uint128 [3] memory _swapRatios,
        bool [3] memory _swapEnabled,
        uint256 _minSwapAmountPerTx,
        uint256 _maxSwapAmountPerTx
    )
    {
        swapRatios = _swapRatios;
        swapEnabled = _swapEnabled;
        maxSwapAmountPerTx = _maxSwapAmountPerTx;
        minSwapAmountPerTx = _minSwapAmountPerTx;
        tokenAddress = _tokenAddress;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(VALIDATOR_ROLE, validatorAddress);
    }

    function depositWithSignature(
        uint256 amountToSend,
        address newAddress,
        address signedAddress,
        uint256 [3] memory signedSwapLimits,
        bytes memory signature
    ) external
    {

        address sender = _msgSender();
        uint256 senderBalance = tokenAddress.balanceOf(sender);
        require(senderBalance >= amountToSend, "swapContract: Insufficient balance");
        require(amountToSend >= minSwapAmountPerTx, "swapContract: Less than required minimum of tokens requested");
        require(amountToSend <= maxSwapAmountPerTx, "swapContract: Swap limit per transaction exceeded");
        require(sender == signedAddress, "swapContract: Signed and sender address does not match");
        require(!swapLimitsSaved[sender], "swapContract: Swap limits already saved");

        bytes32 hashedParams = keccak256(abi.encodePacked(signedAddress, signedSwapLimits));
        address validatorAddress = ECDSA.recover(ECDSA.toEthSignedMessageHash(hashedParams), signature);
        require(isValidator(validatorAddress), "swapContract: Invalid swap limits validator");

        (uint256[3] memory swapLimitsNew, uint256 amountToPay, uint256 amountToReceive) = calculateAmountsAfterSwap(
            signedSwapLimits, amountToSend, true
        );
        require(amountToPay > 0, "swapContract: Swap limit reached");
        require(amountToReceive > 0, "swapContract: Amount to receive is zero");

        swapLimits[sender] = swapLimitsNew;
        swapLimitsSaved[sender] = true;

        TransferHelper.safeTransferFrom(address(tokenAddress), sender, address(this), amountToPay);
        emit Deposit(sender, amountToPay, amountToReceive, newAddress);
    }

     function deposit(
        uint256 amountToSend,
        address newAddress
    ) external
    {

        address sender = _msgSender();
        uint256 senderBalance = tokenAddress.balanceOf(sender);
        require(senderBalance >= amountToSend, "swapContract: Not enough balance");
        require(amountToSend >= minSwapAmountPerTx, "swapContract: Less than required minimum of tokens requested");
        require(amountToSend <= maxSwapAmountPerTx, "swapContract: Swap limit per transaction exceeded");
        require(swapLimitsSaved[sender], "swapContract: Swap limits not saved");

        (uint256[3] memory swapLimitsNew, uint256 amountToPay, uint256 amountToReceive) = calculateAmountsAfterSwap(
            swapLimits[sender], amountToSend, true
        );

        require(amountToPay > 0, "swapContract: Swap limit reached");
        require(amountToReceive > 0, "swapContract: Amount to receive is zero");

        swapLimits[sender] = swapLimitsNew;

        TransferHelper.safeTransferFrom(address(tokenAddress), sender, address(this), amountToPay);
        emit Deposit(sender, amountToPay, amountToReceive, newAddress);
    }

    function calculateAmountsAfterSwap(
        uint256[3] memory _swapLimits,
        uint256 amountToSend,
        bool checkIfSwapEnabled
    ) public view returns (
        uint256[3] memory swapLimitsNew, uint256 amountToPay, uint256 amountToReceive)
    {

        amountToReceive = 0;
        uint256 remainder = amountToSend;
        for (uint256 i = 0; i < _swapLimits.length; i++) {
            if (checkIfSwapEnabled && !swapEnabled[i] || swapRatios[i] == 0) {
                continue;
            }
            uint256 swapLimit = _swapLimits[i];

            if (remainder <= swapLimit) {
                amountToReceive += remainder / swapRatios[i];
                _swapLimits[i] -= remainder;
                remainder = 0;
                break;
            } else {
                amountToReceive += swapLimit / swapRatios[i];
                remainder -= swapLimit;
                _swapLimits[i] = 0;
            }
        }
        amountToPay = amountToSend - remainder;
        swapLimitsNew = _swapLimits;
    }

    function claimTokens(address recipient, uint256 amount) external onlyOwner
    {

        uint256 balance = tokenAddress.balanceOf(address(this));
        require(balance > 0, "swapContract: Token balance is zero");
        require(balance >= amount, "swapContract: Not enough balance to claim");
        if (amount == 0) {
            amount = balance;
        }
        TransferHelper.safeTransfer(address(tokenAddress), recipient, amount);
        emit TokensClaimed(recipient, amount);
    }

    function setMinSwapAmountPerTx(uint256 _minSwapAmountPerTx) external onlyOwner {

        minSwapAmountPerTx = _minSwapAmountPerTx;
    }

    function setMaxSwapAmountPerTx(uint256 _maxSwapAmountPerTx) external onlyOwner {

        maxSwapAmountPerTx = _maxSwapAmountPerTx;
    }

    function setSwapRatio(uint128 index, uint128 ratio) external onlyOwner {

        swapRatios[index] = ratio;
    }

    function enableSwap(uint128 index) external onlyOwner {

        swapEnabled[index] = true;
    }

    function disableSwap(uint128 index) external onlyOwner {

        swapEnabled[index] = false;
    }

    function isOwner(address account) public view returns (bool) {

        return hasRole(DEFAULT_ADMIN_ROLE, account);
    }

    function isValidator(address account) public view returns (bool) {

        return hasRole(VALIDATOR_ROLE, account);
    }

    function swapLimitsArray(address account) external view returns (uint256[3] memory)
    {

        return swapLimits[account];
    }

    function swapEnabledArray() external view returns (bool[3] memory)
    {

        return swapEnabled;
    }

    function updateSwapLimits(address account, uint256[3] memory _swapLimits) external onlyOwnerAndValidator {

        swapLimits[account] = _swapLimits;
        swapLimitsSaved[account] = true;
    }
}