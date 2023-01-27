
pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}// MIT

pragma solidity ^0.8.1;

library Address {

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

        bytes32 s = vs & bytes32(0x7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff);
        uint8 v = uint8((uint256(vs) >> 255) + 27);
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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

}pragma solidity ^0.8.0;

contract CosmosERC20 is ERC20 {
	uint256 MAX_UINT = type(uint256).max;

    uint8 private _decimals;

	constructor(
		address _gravityAddress,
		string memory _name,
		string memory _symbol,
		uint8 decimals_
	) public ERC20(_name, _symbol) {
		_decimals = decimals_;
		_mint(_gravityAddress, MAX_UINT);
	}

	function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

}// MIT

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
        _checkRole(role);
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role) internal view virtual {
        _checkRole(role, _msgSender());
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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
}// MIT

pragma solidity ^0.8.0;


contract CudosAccessControls is AccessControl {
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");
    bytes32 public constant SMART_CONTRACT_ROLE = keccak256("SMART_CONTRACT_ROLE");
    event AdminRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );
    event AdminRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );
    event WhitelistRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );
    event WhitelistRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );
    event SmartContractRoleGranted(
        address indexed beneficiary,
        address indexed caller
    );
    event SmartContractRoleRemoved(
        address indexed beneficiary,
        address indexed caller
    );
    modifier onlyAdminRole() {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "CudosAccessControls: sender must be an admin");
        _;
    }

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    }

    function hasAdminRole(address _address) external view returns (bool) {
        return hasRole(DEFAULT_ADMIN_ROLE, _address);
    }
    function hasWhitelistRole(address _address) external view returns (bool) {
        return hasRole(WHITELISTED_ROLE, _address);
    }
    function hasSmartContractRole(address _address) external view returns (bool) {
        return hasRole(SMART_CONTRACT_ROLE, _address);
    }
    function addAdminRole(address _address) external onlyAdminRole {
        _setupRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleGranted(_address, _msgSender());
    }
    function removeAdminRole(address _address) external onlyAdminRole {
        revokeRole(DEFAULT_ADMIN_ROLE, _address);
        emit AdminRoleRemoved(_address, _msgSender());
    }
    function addWhitelistRole(address _address) external onlyAdminRole {
        _setupRole(WHITELISTED_ROLE, _address);
        emit WhitelistRoleGranted(_address, _msgSender());
    }
    function removeWhitelistRole(address _address) external onlyAdminRole {
        revokeRole(WHITELISTED_ROLE, _address);
        emit WhitelistRoleRemoved(_address, _msgSender());
    }
    function addSmartContractRole(address _address) external onlyAdminRole {
        _setupRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleGranted(_address, _msgSender());
    }
    function removeSmartContractRole(address _address) external onlyAdminRole {
        revokeRole(SMART_CONTRACT_ROLE, _address);
        emit SmartContractRoleRemoved(_address, _msgSender());
    }
}pragma solidity ^0.8.0;


pragma experimental ABIEncoderV2;

struct ValsetArgs {
	address[] validators;
	uint256[] powers;
	uint256 valsetNonce;
	uint256 rewardAmount;
	address rewardToken;
}

contract Gravity is ReentrancyGuard, Pausable {
	using SafeMath for uint256;
	using SafeERC20 for IERC20;

	bytes32 public state_lastValsetCheckpoint;
	mapping(address => uint256) public state_lastBatchNonces;
	mapping(bytes32 => uint256) public state_invalidationMapping;
	uint256 public state_lastValsetNonce;

	uint256 public state_lastEventNonce = 1;


	bytes32 public immutable state_gravityId;
	uint256 public immutable state_powerThreshold;

	CudosAccessControls public immutable cudosAccessControls;

	mapping(address => bool) public supportedToCosmosTokens;
  
	event TransactionBatchExecutedEvent(
		uint256 indexed _batchNonce,
		address indexed _token,
		uint256 _eventNonce
	);

	event SendToCosmosEvent(
		address indexed _tokenContract,
		address indexed _sender,
		bytes32 indexed _destination,
		uint256 _amount,
		uint256 _eventNonce
	);

	event ERC20DeployedEvent(
		string _cosmosDenom,
		address indexed _tokenContract,
		string _name,
		string _symbol,
		uint8 _decimals,
		uint256 _eventNonce
	);

	event ValsetUpdatedEvent(
		uint256 indexed _newValsetNonce,
		uint256 _eventNonce,
		uint256 _rewardAmount,
		address _rewardToken,
		address[] _validators,
		uint256[] _powers
	);


	modifier onlyAdmin() {
		require(cudosAccessControls.hasAdminRole(msg.sender), "Recipient is not an admin");
		_;
	}


	function lastBatchNonce(address _erc20Address) external view returns (uint256) {
		return state_lastBatchNonces[_erc20Address];
	}
	
	function pause() external onlyAdmin {
		_pause();
	}

	function unpause() external onlyAdmin {
		_unpause();
	}

	function verifySig(
		address _signer,
		bytes32 _theHash,
		uint8 _v,
		bytes32 _r,
		bytes32 _s
	) private pure returns (bool) {
		bytes32 messageDigest = keccak256(
			abi.encodePacked("\x19Ethereum Signed Message:\n32", _theHash)
		);
		address recAddr = ECDSA.recover(messageDigest, _v, _r, _s);
		return _signer == recAddr;
	}

	function makeCheckpoint(ValsetArgs memory _valsetArgs, bytes32 _gravityId)
		private
		pure
		returns (bytes32)
	{
		bytes32 methodName = 0x636865636b706f696e7400000000000000000000000000000000000000000000;

		bytes32 checkpoint = keccak256(
			abi.encode(
				_gravityId,
				methodName,
				_valsetArgs.valsetNonce,
				_valsetArgs.validators,
				_valsetArgs.powers,
				_valsetArgs.rewardAmount,
				_valsetArgs.rewardToken
			)
		);

		return checkpoint;
	}


	function checkValidatorSignatures(
		address[] memory _currentValidators,
		uint256[] memory _currentPowers,
		uint8[] memory _v,
		bytes32[] memory _r,
		bytes32[] memory _s,
		bytes32 _theHash
	) private view {

		uint256 _powerThreshold = state_powerThreshold;
		uint256 cumulativePower;
		uint256 valLength = _currentValidators.length;
		for (uint256 i; i < valLength; ++i) {
			if (_v[i] != 0) {
				require(
					verifySig(_currentValidators[i], _theHash, _v[i], _r[i], _s[i]),
					"Validator signature does not match."
				);

				cumulativePower = cumulativePower + _currentPowers[i];

				if (cumulativePower > _powerThreshold) {
					break;
				}
			}
		}

		checkComulatedPower(cumulativePower, _powerThreshold);
	}

	function checkComulatedPower(uint256 _cumulativePower, uint256 _powerThreshold) internal pure {
		require(
			_cumulativePower > _powerThreshold,
			"given valset power < threshold"
		);
	}

	function checkValsetData(
		ValsetArgs memory _currentValset,
		uint8[] memory _v,
		bytes32[] memory _r,
		bytes32[] memory _s
	) internal pure {
		require(_currentValset.validators.length == _currentValset.powers.length, "Malformed current validator set");
		require(_currentValset.validators.length == _v.length, "Malformed current validator set");
		require(_currentValset.validators.length == _r.length, "Malformed current validator set");
		require(_currentValset.validators.length == _s.length, "Malformed current validator set");
	}

	function checkCheckpoint(ValsetArgs memory _currentValset, bytes32 _gravityId) private view {
		require(
			makeCheckpoint(_currentValset, _gravityId) == state_lastValsetCheckpoint,
			"given valset != checkpoint"
		);
	}
  
	function isOrchestrator(ValsetArgs memory _valset, address _sender) private pure {
		uint256 valLength = _valset.validators.length;
		for (uint256 i; i < valLength; ++i) {
			if(_valset.validators[i] == _sender) {
				return;
			}
		}
		
		revert("not validated orchestrator");
	}

	function addToCosmosToken(address _cosmosToken) external onlyAdmin {
		supportedToCosmosTokens[_cosmosToken] = true;
	}

	function removeToCosmosToken(address _cosmosToken) external onlyAdmin {
		supportedToCosmosTokens[_cosmosToken] = false;
	}

	function updateValset(
		ValsetArgs memory _newValset,
		ValsetArgs memory _currentValset,
		uint8[] memory _v,
		bytes32[] memory _r,
		bytes32[] memory _s
	) external nonReentrant whenNotPaused {

		require(
			_newValset.valsetNonce > _currentValset.valsetNonce,
			"newValset nonce <= current"
		);

		require(
			_newValset.validators.length == _newValset.powers.length,
			"Malformed new validator set"
		);

		checkValsetData(_currentValset, _v, _r, _s);

		bytes32 gravityId = state_gravityId;
		checkCheckpoint(_currentValset, gravityId);

		isOrchestrator(_currentValset, msg.sender);

		bytes32 newCheckpoint = makeCheckpoint(_newValset, gravityId);

		checkValidatorSignatures(
			_currentValset.validators,
			_currentValset.powers,
			_v,
			_r,
			_s,
			newCheckpoint
		);


		state_lastValsetCheckpoint = newCheckpoint;

		state_lastValsetNonce = _newValset.valsetNonce;

		if (_newValset.rewardToken != address(0) && _newValset.rewardAmount != 0) {
			IERC20(_newValset.rewardToken).safeTransfer(msg.sender, _newValset.rewardAmount);
		}

		uint256 lastEventNonce = state_lastEventNonce.add(1);
		state_lastEventNonce = lastEventNonce;
		emit ValsetUpdatedEvent(
			_newValset.valsetNonce,
			lastEventNonce,
			_newValset.rewardAmount,
			_newValset.rewardToken,
			_newValset.validators,
			_newValset.powers
		);
	}

	function submitBatch (
		ValsetArgs memory _currentValset,
		uint8[] memory _v,
		bytes32[] memory _r,
		bytes32[] memory _s,
		uint256[] memory _amounts,
		address[] memory _destinations,
		uint256[] memory _fees,
		uint256 _batchNonce,
		address _tokenContract,
		uint256 _batchTimeout
	) external nonReentrant whenNotPaused {
		{

			require(_amounts.length == _destinations.length, "Malformed batch of transactions");
			require(_amounts.length == _fees.length, "Malformed batch of transactions");
			
			require(
				state_lastBatchNonces[_tokenContract] < _batchNonce,
				"new batch nonce <= current"
			);

			require(
				block.number < _batchTimeout,
				"batch timeout <= block height"
			);

			checkValsetData(_currentValset, _v, _r, _s);

			bytes32 gravityId = state_gravityId;
			checkCheckpoint(_currentValset, gravityId);

			isOrchestrator(_currentValset, msg.sender);

			checkValidatorSignatures(
				_currentValset.validators,
				_currentValset.powers,
				_v,
				_r,
				_s,
				keccak256(
					abi.encode(
						gravityId,
						0x7472616e73616374696f6e426174636800000000000000000000000000000000,
						_amounts,
						_destinations,
						_fees,
						_batchNonce,
						_tokenContract,
						_batchTimeout
					)
				)
			);


			state_lastBatchNonces[_tokenContract] = _batchNonce;

			{
				uint256 totalFee;
				uint256 amountsLength = _amounts.length;
				for (uint256 i; i < amountsLength; ++i) {
					IERC20(_tokenContract).safeTransfer(_destinations[i], _amounts[i]);
					totalFee = totalFee.add(_fees[i]);
				}

				IERC20(_tokenContract).safeTransfer(msg.sender, totalFee);
			}
		}

		{
			uint256 lastEventNonce = state_lastEventNonce.add(1);
			state_lastEventNonce = lastEventNonce;
			emit TransactionBatchExecutedEvent(_batchNonce, _tokenContract, lastEventNonce);
		}
	}

	function sendToCosmos(
		address _tokenContract,
		bytes32 _destination,
		uint256 _amount
	)
		external 
		nonReentrant 
		whenNotPaused
	{
		require(supportedToCosmosTokens[_tokenContract], "token not supported");

		uint32 size;
		assembly {
			size := extcodesize(_tokenContract)
		}
		require(size != 0, "empty bytecode token");


		IERC20(_tokenContract).safeTransferFrom(msg.sender, address(this), _amount);
		
		uint256 lastEventNonce = state_lastEventNonce.add(1);
		state_lastEventNonce = lastEventNonce;
		emit SendToCosmosEvent(
			_tokenContract,
			msg.sender,
			_destination,
			_amount,
			lastEventNonce
		);
	}

	function deployERC20(
		string memory _cosmosDenom,
		string memory _name,
		string memory _symbol,
		uint8 _decimals
	) 	
		external 
		whenNotPaused 
	{
		uint256 lastEventNonce = state_lastEventNonce.add(1);
		state_lastEventNonce = lastEventNonce;
		CosmosERC20 erc20 = new CosmosERC20(address(this), _name, _symbol, _decimals);

		emit ERC20DeployedEvent(
			_cosmosDenom,
			address(erc20),
			_name,
			_symbol,
			_decimals,
			lastEventNonce
		);
	}

	function withdrawERC20(
		address _tokenAddress
	) 
		external 
		onlyAdmin
	{
		uint256 totalBalance = IERC20(_tokenAddress).balanceOf(address(this));
		IERC20(_tokenAddress).safeTransfer(msg.sender , totalBalance);
	}

	constructor(
		bytes32 _gravityId,
		uint256 _powerThreshold,
		address[] memory _validators,
    	uint256[] memory _powers,
		CudosAccessControls _cudosAccessControls,
		address _mainToken
	) {


		uint256 powersLength = _powers.length;
		require(_validators.length == powersLength, "Malformed current validator set");
		require(address(_cudosAccessControls) != address(0), "AccessControl address wrong");

		uint256 cumulativePower;
		for (uint256 i; i < powersLength; ++i) {
			cumulativePower = cumulativePower + _powers[i];
			if (cumulativePower > _powerThreshold) {
				break;
			}
		}

		checkComulatedPower(cumulativePower, _powerThreshold);

		ValsetArgs memory _valset;
		_valset = ValsetArgs(_validators, _powers, 0, 0, address(0));

		bytes32 newCheckpoint = makeCheckpoint(_valset, _gravityId);


		state_gravityId = _gravityId;
		state_powerThreshold = _powerThreshold;
		state_lastValsetCheckpoint = newCheckpoint;

		cudosAccessControls = _cudosAccessControls;

		supportedToCosmosTokens[_mainToken] = true;

		emit ValsetUpdatedEvent(
			state_lastValsetNonce,
			state_lastEventNonce,
			0,
			address(0),
			_validators,
			_powers
		);
	}
}