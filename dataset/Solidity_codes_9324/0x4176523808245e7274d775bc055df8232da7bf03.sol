
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


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

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
pragma solidity 0.8.8;

interface IJTranchesDeployer {

    function deployNewTrancheATokens(string memory _nameA, string memory _symbolA, uint256 _trNum) external returns (address);

    function deployNewTrancheBTokens(string memory _nameB, string memory _symbolB, uint256 _trNum) external returns (address);

}// MIT
pragma solidity 0.8.8;

interface IJAdminTools {

    function isAdmin(address account) external view returns (bool);

    function addAdmin(address account) external;

    function removeAdmin(address account) external;

    function renounceAdmin() external;


    event AdminAdded(address account);
    event AdminRemoved(address account);
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
pragma solidity 0.8.8;

interface IJTrancheTokens {
    function mint(address account, uint256 value) external;
    function burn(uint256 value) external;
}// MIT
pragma solidity 0.8.8;

interface IJAave {
    event TrancheAddedToProtocol(uint256 trancheNum, address trancheA, address trancheB);
    event TrancheATokenMinted(uint256 trancheNum, address buyer, uint256 amount, uint256 taAmount);
    event TrancheBTokenMinted(uint256 trancheNum, address buyer, uint256 amount, uint256 tbAmount);
    event TrancheATokenRedemption(uint256 trancheNum, address burner, uint256 amount, uint256 userAmount, uint256 feesAmount);
    event TrancheBTokenRedemption(uint256 trancheNum, address burner, uint256 amount, uint256 userAmount, uint256 feesAmount);

    function getSingleTrancheUserStakeCounterTrA(address _user, uint256 _trancheNum) external view returns (uint256);
    function getSingleTrancheUserStakeCounterTrB(address _user, uint256 _trancheNum) external view returns (uint256);
    function getSingleTrancheUserSingleStakeDetailsTrA(address _user, uint256 _trancheNum, uint256 _num) external view returns (uint256, uint256);
    function getSingleTrancheUserSingleStakeDetailsTrB(address _user, uint256 _trancheNum, uint256 _num) external view returns (uint256, uint256);
    function getIncentivesControllerAddress() external view returns (address);
    function setIncentivesControllerAddress(address _incentivesController) external;
    function setTrAStakingDetails(uint256 _trancheNum, address _account, uint256 _stkNum, uint256 _amount, uint256 _time) external;
    function setTrBStakingDetails(uint256 _trancheNum, address _account, uint256 _stkNum, uint256 _amount, uint256 _time) external;
}// MIT
pragma solidity 0.8.8;

interface IIncentivesController {
    function trancheANewEnter(address account, address trancheA) external;
    function trancheBNewEnter(address account, address trancheA) external;

    function claimRewardsAllMarkets(address _account) external returns (bool);
    function claimRewardSingleMarketTrA(uint256 _idxMarket, uint256 _distCount, address _account) external;
    function claimRewardSingleMarketTrB(uint256 _idxMarket, uint256 _distCount, address _account) external;
}// MIT
pragma solidity 0.8.8;



contract JTrancheAToken is Ownable, ERC20, AccessControl, IJTrancheTokens {
	using SafeMath for uint256;

	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	address public jAaveAddress;
	uint256 public protTrancheNum;

	constructor(string memory name, string memory symbol, uint256 _trNum) ERC20(name, symbol) {
		protTrancheNum = _trNum;
        _setupRole(MINTER_ROLE, msg.sender);
	}

    function setJAaveMinter(address _jAave) external onlyOwner {
		jAaveAddress = _jAave;
        _setupRole(MINTER_ROLE, _jAave);
	}

	function _transfer(address from, address to, uint256 value) internal override {
		address incentivesControllerAddress = IJAave(jAaveAddress).getIncentivesControllerAddress();
        bool rewClaimCompleted = IIncentivesController(incentivesControllerAddress).claimRewardsAllMarkets(from);
        if (rewClaimCompleted && value > 0) {
			uint256 tempTime;
			uint256 tempAmount;
			uint256 tempValue = value;
			uint256 stkDetNum = IJAave(jAaveAddress).getSingleTrancheUserStakeCounterTrA(from, protTrancheNum);
			for (uint256 i = 1; i <= stkDetNum; i++){
				(tempTime, tempAmount) = IJAave(jAaveAddress).getSingleTrancheUserSingleStakeDetailsTrA(from, protTrancheNum, i);
				if (tempAmount > 0) {
					if (tempAmount <= tempValue) {
						IJAave(jAaveAddress).setTrAStakingDetails(protTrancheNum, from, i, 0, tempTime);
						IJAave(jAaveAddress).setTrAStakingDetails(protTrancheNum, to, i, tempAmount, block.timestamp);
						tempValue = tempValue.sub(tempAmount);
					} else {
						uint256 remainingAmount = tempAmount.sub(tempValue);
						IJAave(jAaveAddress).setTrAStakingDetails(protTrancheNum, from, i, remainingAmount, tempTime);
						IJAave(jAaveAddress).setTrAStakingDetails(protTrancheNum, to, i, tempValue, block.timestamp);
						tempValue = 0;
					}
				}
				if (tempValue == 0)
                break;
			}
		}
		super._transfer(from, to, value);
	}

	function mint(address account, uint256 value) external override {
		require(hasRole(MINTER_ROLE, msg.sender), "JTrancheA: caller is not a minter");
		require(value > 0, "JTrancheA: value is zero");
		super._mint(account, value);
    }

	function burn(uint256 value) external override {
		require(hasRole(MINTER_ROLE, msg.sender), "JTrancheA: caller cannot burn tokens");
		require(value > 0, "JTrancheA: value is zero");
		super._burn(msg.sender, value);
	}

}// MIT
pragma solidity 0.8.8;



contract JTrancheBToken is Ownable, ERC20, AccessControl, IJTrancheTokens {
	using SafeMath for uint256;

	bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
	address public jAaveAddress;
	uint256 public protTrancheNum;

	constructor(string memory name, string memory symbol, uint256 _trNum) ERC20(name, symbol) {
		protTrancheNum = _trNum;
        _setupRole(MINTER_ROLE, msg.sender);
	}

    function setJAaveMinter(address _jAave) external onlyOwner {
		jAaveAddress = _jAave;
        _setupRole(MINTER_ROLE, _jAave);
	}

	function _transfer(address from, address to, uint256 value) internal override {
		address incentivesControllerAddress = IJAave(jAaveAddress).getIncentivesControllerAddress();
        bool rewClaimCompleted = IIncentivesController(incentivesControllerAddress).claimRewardsAllMarkets(from);
        if (rewClaimCompleted && value > 0) {
			uint256 tempTime;
			uint256 tempAmount;
			uint256 tempValue = value;
			uint256 stkDetNum = IJAave(jAaveAddress).getSingleTrancheUserStakeCounterTrB(from, protTrancheNum);
			for (uint256 i = 1; i <= stkDetNum; i++){
				(tempTime, tempAmount) = IJAave(jAaveAddress).getSingleTrancheUserSingleStakeDetailsTrB(from, protTrancheNum, i);
				if (tempAmount > 0) {
					if (tempAmount <= tempValue) {
						IJAave(jAaveAddress).setTrBStakingDetails(protTrancheNum, from, i, 0, tempTime);
						IJAave(jAaveAddress).setTrBStakingDetails(protTrancheNum, to, i, tempAmount, block.timestamp);
						tempValue = tempValue.sub(tempAmount);
					} else {
						uint256 remainingAmount = tempAmount.sub(tempValue);
						IJAave(jAaveAddress).setTrBStakingDetails(protTrancheNum, from, i, remainingAmount, tempTime);
						IJAave(jAaveAddress).setTrBStakingDetails(protTrancheNum, to, i, tempValue, block.timestamp);
						tempValue = 0;
					}
				}
				if (tempValue == 0)
                break;
			}
		}
		super._transfer(from, to, value);
	}

	function mint(address account, uint256 value) external override {
		require(hasRole(MINTER_ROLE, msg.sender), "JTrancheB: Caller is not a minter");
		require(value > 0, "JTrancheB: value is zero");
        super._mint(account, value);
    }

	function burn(uint256 value) external override {
		require(hasRole(MINTER_ROLE, msg.sender), "JTrancheB: caller cannot burn tokens");
		require(value > 0, "JTrancheB: value is zero");
		super._burn(msg.sender, value);
	}

}// MIT
pragma solidity 0.8.8;


contract JTranchesDeployerStorage {

    address public jAaveAddress;
    address public jAdminToolsAddress;
}// MIT
pragma solidity 0.8.8;


contract JTranchesDeployer is OwnableUpgradeable, JTranchesDeployerStorage, IJTranchesDeployer {
    using SafeMathUpgradeable for uint256;

    function initialize() external initializer() {
        OwnableUpgradeable.__Ownable_init();
    }

    function setJAaveAddresses(address _jAaveAddress, address _jATAddress) external onlyOwner {
        jAaveAddress = _jAaveAddress;
        jAdminToolsAddress = _jATAddress;
    }

    modifier onlyProtocol() {
        require(msg.sender == jAaveAddress, "TrancheDeployer: caller is not JAave");
        _;
    }

    function deployNewTrancheATokens(string memory _nameA, 
            string memory _symbolA, 
            uint256 _trNum) external override onlyProtocol returns (address) {
        JTrancheAToken jTrancheA = new JTrancheAToken(_nameA, _symbolA, _trNum);
        jTrancheA.setJAaveMinter(msg.sender); 
        IJAdminTools(jAdminToolsAddress).addAdmin(address(jTrancheA));
        return address(jTrancheA);
    }

    function deployNewTrancheBTokens(string memory _nameB, 
            string memory _symbolB, 
            uint256 _trNum) external override onlyProtocol returns (address) {
        JTrancheBToken jTrancheB = new JTrancheBToken(_nameB, _symbolB, _trNum);
        jTrancheB.setJAaveMinter(msg.sender);
        IJAdminTools(jAdminToolsAddress).addAdmin(address(jTrancheB));
        return address(jTrancheB);
    }

    function setNewJAaveTokens(address _newJAave, address _trAToken, address _trBToken) external onlyOwner {
        require((_newJAave != address(0)) && (_trAToken != address(0)) && (_trBToken != address(0)), "TrancheDeployer: some address is not allowed");
        JTrancheAToken(_trAToken).setJAaveMinter(_newJAave);
        JTrancheAToken(_trBToken).setJAaveMinter(_newJAave);
    }

}