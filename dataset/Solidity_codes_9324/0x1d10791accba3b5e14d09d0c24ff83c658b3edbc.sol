
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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.13;


error Address_InsufficientBalance(uint256 balance, uint256 amount);
error Address_UnableToSendValue(address recipient, uint256 amount);
error Address_CallToNonContract(address target);
error Address_StaticCallToNonContract(address target);

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        if (address(this).balance < amount) revert Address_InsufficientBalance(address(this).balance, amount);

        (bool success, ) = recipient.call{value: amount}("");
        if (!success) revert Address_UnableToSendValue(recipient, amount);
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

        if (address(this).balance < value) revert Address_InsufficientBalance(address(this).balance, value);
        if (!isContract(target)) revert Address_CallToNonContract(target);

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

        if (!isContract(target)) revert Address_StaticCallToNonContract(target);

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

pragma solidity ^0.8.13;



error Initializable_AlreadyInitialized();
error Initializable_NotInitializing();

abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        if(_initializing ? !_isConstructor() : _initialized) revert Initializable_AlreadyInitialized();

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
        if (!_initializing) revert Initializable_NotInitializing();
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.13;

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

pragma solidity ^0.8.13;



error ERC20_DecreasedAllowanceBelowZero();
error ERC20_TransferFromZeroAddress();
error ERC20_TransferToZeroAddress();
error ERC20_TransferAmountExceedsBalance(uint256 amount, uint256 balance);
error ERC20_MintToZeroAddress();
error ERC20_BurnFromZeroAddress();
error ERC20_BurnAmountExceedsBalance(uint256 amount, uint256 balance);
error ERC20_ApproveFromZeroAddress();
error ERC20_ApproveToZeroAddress();
error ERC20_InsufficientAllowance(uint256 amount, uint256 allowance);

contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

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
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        if (currentAllowance < subtractedValue) revert ERC20_DecreasedAllowanceBelowZero();
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

        if (from == address(0)) revert ERC20_TransferFromZeroAddress();
        if (to == address(0)) revert ERC20_TransferToZeroAddress();

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        if (fromBalance < amount) revert ERC20_TransferAmountExceedsBalance(amount, fromBalance);
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        if (account == address(0)) revert ERC20_MintToZeroAddress();

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        if (account == address(0)) revert ERC20_BurnFromZeroAddress();

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        if (accountBalance < amount) revert ERC20_BurnAmountExceedsBalance(amount, accountBalance);
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

        if (owner == address(0)) revert ERC20_ApproveFromZeroAddress();
        if (spender == address(0)) revert ERC20_ApproveToZeroAddress();

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
            if (currentAllowance < amount) revert ERC20_InsufficientAllowance(amount, currentAllowance);
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


    uint256[45] private __gap;
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

pragma solidity ^0.8.13;



error AccessControl_MissingRole(address account, bytes32 role);
error AccessControl_CanOnlyRenounceRolesForSelf(address account, address sender);

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
            revert AccessControl_MissingRole(account, role);
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
        if (account != _msgSender()) revert AccessControl_CanOnlyRenounceRolesForSelf(account, _msgSender());

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

pragma solidity ^0.8.13;



error Pausable_Paused();
error Pausable_NotPaused();

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
        if (paused()) revert Pausable_Paused();
        _;
    }

    modifier whenPaused() {
        if (!paused()) revert Pausable_NotPaused();
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
pragma solidity ^0.8.13;

error NoClaimAvailable(address _account);

interface IClaimable {

	function claim() external;

	function pendingClaim(address _account) external view returns (uint256);

	function initializeClaim(uint256 _tokenId) external;

	function updateClaim(address _account, uint256 _tokenId) external;


	event Claimed(address indexed _account, uint256 _amount);
	event Updated(address indexed _account, uint256 indexed _tokenId);
}// MIT
pragma solidity ^0.8.13;

interface ILabGame {

	function getToken(uint256 _tokenId) external view returns (uint256);

	function balanceOf(address _account) external view returns (uint256);

	function tokenOfOwnerByIndex(address _account, uint256 _index) external view returns (uint256);

	function ownerOf(uint256 _tokenId) external view returns (address);

}// MIT
pragma solidity ^0.8.13;



error NotReady();
error NotOwned(address _account, uint256 _tokenId);
error NotAuthorized(address _sender, address _expected);

contract Serum is ERC20Upgradeable, AccessControlUpgradeable, PausableUpgradeable, IClaimable {

	bytes32 public constant CONTROLLER_ROLE = keccak256("CONTROLLER_ROLE");
	
	uint256 constant GEN0_RATE = 1000 ether;
	uint256 constant GEN1_RATE = 1200 ether;
	uint256 constant GEN2_RATE = 1500 ether;
	uint256 constant GEN3_RATE = 2000 ether;

	uint256 constant GEN0_TAX = 100; // 10.0%
	uint256 constant GEN1_TAX = 125; // 12.5%
	uint256 constant GEN2_TAX = 150; // 15.0%
	uint256 constant GEN3_TAX = 200; // 20.0%

	uint256 constant CLAIM_PERIOD = 1 days;

	uint256 constant TOTAL_SUPPLY = 277750000 ether; // @since V2.0

	mapping(uint256 => uint256) public tokenClaims; // tokenId => value

	uint256[4] public mutantEarnings;
	uint256[4] public mutantCounts;

	mapping(address => uint256) public pendingClaims; 

	ILabGame public labGame;

	function initialize(
		string memory _name,
		string memory _symbol
	) public initializer {

		__ERC20_init(_name, _symbol);
		__AccessControl_init();
		__Pausable_init();
		_setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
	}


	function claim() external override whenNotPaused {

		uint256 totalSerum = totalSupply();
		if (totalSerum >= TOTAL_SUPPLY)
			revert NoClaimAvailable(_msgSender());

		uint256 count = labGame.balanceOf(_msgSender());
		uint256 amount;
		for (uint256 i; i < count; i++) {
			uint256 tokenId = labGame.tokenOfOwnerByIndex(_msgSender(), i);
			uint256 token = labGame.getToken(tokenId);
			if (token & 128 == 0)
				amount += _claimScientist(tokenId, token & 3);
		}
		amount = _payTax(amount);
		for (uint256 i; i < count; i++) {
			uint256 tokenId = labGame.tokenOfOwnerByIndex(_msgSender(), i);
			uint256 token = labGame.getToken(tokenId);
			if (token & 128 != 0)
				amount += _claimMutant(tokenId, token & 3);
		}
		amount += pendingClaims[_msgSender()];
		delete pendingClaims[_msgSender()];

		if (totalSerum + amount > TOTAL_SUPPLY) amount = TOTAL_SUPPLY - totalSerum;
		if (amount == 0) revert NoClaimAvailable(_msgSender());
		_mint(_msgSender(), amount);
		emit Claimed(_msgSender(), amount);
	}

	function pendingClaim(address _account) external view override returns (uint256 amount) {

		uint256 count = labGame.balanceOf(_account);
		uint256 untaxed;
		for (uint256 i; i < count; i++) {
			uint256 tokenId = labGame.tokenOfOwnerByIndex(_account, i);
			uint256 token = labGame.getToken(tokenId);
			if (token & 128 != 0)
				amount += mutantEarnings[token & 3] - tokenClaims[tokenId];
			else
				untaxed +=
					(block.timestamp - tokenClaims[tokenId]) * 
					[ GEN0_RATE, GEN1_RATE, GEN2_RATE, GEN3_RATE ][token & 3] / 
					CLAIM_PERIOD;
		}
		amount += _pendingTax(untaxed);
		amount += pendingClaims[_account];
	}


	modifier onlyLabGame {

		if (address(labGame) == address(0)) revert NotReady();
		if (_msgSender() != address(labGame)) revert NotAuthorized(_msgSender(), address(labGame));
		_;
	}

	function initializeClaim(uint256 _tokenId) external override onlyLabGame whenNotPaused {

		uint256 token = labGame.getToken(_tokenId);
		if (token & 128 != 0) {
			tokenClaims[_tokenId] = mutantEarnings[token & 3];
			mutantCounts[token & 3]++;
		} else {
			tokenClaims[_tokenId] = block.timestamp;
		}
	}

	function updateClaim(address _account, uint256 _tokenId) external override onlyLabGame whenNotPaused {

		if (_account != labGame.ownerOf(_tokenId)) revert NotOwned(_msgSender(), _tokenId);
		uint256 amount;
		uint256 token = labGame.getToken(_tokenId);
		if ((token & 128) != 0) {
			amount = _claimMutant(_tokenId, token & 3);
		} else {
			amount = _claimScientist(_tokenId, token & 3);
			amount = _payTax(amount);
		}
		pendingClaims[_account] += amount;
		emit Updated(_account, _tokenId);
	}


	function _claimScientist(uint256 _tokenId, uint256 _generation) internal returns (uint256 amount) {

		amount = (block.timestamp - tokenClaims[_tokenId]) * [ GEN0_RATE, GEN1_RATE, GEN2_RATE, GEN3_RATE ][_generation] / CLAIM_PERIOD;
		tokenClaims[_tokenId] = block.timestamp;
	}
	
	function _claimMutant(uint256 _tokenId, uint256 _generation) internal returns (uint256 amount) {

		amount = (mutantEarnings[_generation] - tokenClaims[_tokenId]);
		tokenClaims[_tokenId] = mutantEarnings[_generation];
	}

	function _payTax(uint256 _amount) internal returns (uint256) {

		uint256 amount = _amount;
		for (uint256 i; i < 4; i++) {
			uint256 mutantCount = mutantCounts[i];
			if (mutantCount == 0) continue;
			uint256 tax = _amount * [ GEN0_TAX, GEN1_TAX, GEN2_TAX, GEN3_TAX ][i] / 1000;
			mutantEarnings[i] += tax / mutantCount;
			amount -= tax;
		}
		return amount;
	}

	function _pendingTax(uint256 _amount) internal view returns (uint256) {

		for (uint256 i; i < 4; i++) {
			uint256 mutantCount = mutantCounts[i];
			if (mutantCount == 0) continue;
			uint256 tax = _amount * [ GEN0_TAX, GEN1_TAX, GEN2_TAX, GEN3_TAX ][i] / 1000;
			_amount -= tax;
		}
		return _amount;
	}


	function mint(address _to, uint256 _amount) external whenNotPaused onlyRole(CONTROLLER_ROLE) {

		_mint(_to, _amount);
	}

	function burn(address _from, uint256 _amount) external whenNotPaused onlyRole(CONTROLLER_ROLE) {

		_burn(_from, _amount);
	}
	

	function setLabGame(address _labGame) external onlyRole(DEFAULT_ADMIN_ROLE) {

		labGame = ILabGame(_labGame);
	}

	function addController(address _controller) external onlyRole(DEFAULT_ADMIN_ROLE) {

		grantRole(CONTROLLER_ROLE, _controller);
	}

	function removeController(address _controller) external onlyRole(DEFAULT_ADMIN_ROLE) {

		revokeRole(CONTROLLER_ROLE, _controller);
	}

	function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {

		_pause();
	}
	
	function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {

		_unpause();
	}
}