
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
}// GPL-3.0
pragma solidity 0.8.7;

interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);

    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    function grantRole(bytes32 role, address account) external;

    function revokeRole(bytes32 role, address account) external;

    function renounceRole(bytes32 role, address account) external;
}// GPL-3.0

pragma solidity ^0.8.7;



abstract contract AccessControlUpgradeable is Initializable, IAccessControl {
    function __AccessControl_init() internal initializer {
        __AccessControl_init_unchained();
    }

    function __AccessControl_init_unchained() internal initializer {}

    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    modifier onlyRole(bytes32 role) {
        _checkRole(role, msg.sender);
        _;
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

    function grantRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) external override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) external override {
        require(account == msg.sender, "71");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal {
        emit RoleAdminChanged(role, getRoleAdmin(role), adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) internal {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes32 role, address account) internal {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }

    uint256[49] private __gap;
}// GPL-3.0
pragma solidity 0.8.7;

interface IGaugeController {
    function gauge_types(address addr) external view returns (int128);

    function gauge_relative_weight_write(address addr, uint256 timestamp) external returns (uint256);

    function gauge_relative_weight(address addr) external view returns (uint256);

    function gauge_relative_weight(address addr, uint256 timestamp) external view returns (uint256);

    function get_total_weight() external view returns (uint256);

    function get_gauge_weight(address addr) external view returns (uint256);
}// GPL-3.0
pragma solidity 0.8.7;

interface ILiquidityGauge {
	struct Reward {
		address token;
		address distributor;
		uint256 period_finish;
		uint256 rate;
		uint256 last_update;
		uint256 integral;
	}

	function deposit_reward_token(address _rewardToken, uint256 _amount) external;

	function claim_rewards_for(address _user, address _recipient) external;


	function deposit(uint256 _value, address _addr) external;

	function reward_tokens(uint256 _i) external view returns (address);

	function reward_data(address _tokenReward) external view returns (Reward memory);

	function balanceOf(address) external returns (uint256);

	function claimable_reward(address _user, address _reward_token) external view returns (uint256);

	function claimable_tokens(address _user) external returns (uint256);

	function user_checkpoint(address _user) external returns (bool);

	function commit_transfer_ownership(address) external;
}// MIT
pragma solidity 0.8.7;

interface IMasterchef {
	function deposit(uint256, uint256) external;

	function withdraw(uint256, uint256) external;

	function userInfo(uint256, address) external view returns (uint256, uint256);

	function poolInfo(uint256)
		external
		returns (
			address,
			uint256,
			uint256,
			uint256
		);

	function totalAllocPoint() external view returns (uint256);

	function sdtPerBlock() external view returns (uint256);

	function pendingSdt(uint256, address) external view returns (uint256);
}// GPL-3.0
pragma solidity ^0.8.7;

interface ISdtMiddlemanGauge {
	function notifyReward(address gauge, uint256 amount) external;
}// GPL-3.0
pragma solidity ^0.8.7;


interface IStakingRewardsFunctions {
    function notifyRewardAmount(uint256 reward) external;

    function recoverERC20(
        address tokenAddress,
        address to,
        uint256 tokenAmount
    ) external;

    function setNewRewardsDistribution(address newRewardsDistribution) external;
}

interface IStakingRewards is IStakingRewardsFunctions {
    function rewardToken() external view returns (IERC20);
}// MIT
pragma solidity 0.8.7;


contract MasterchefMasterToken is ERC20, Ownable {
	constructor() ERC20("Masterchef Master Token", "MMT") {
		_mint(msg.sender, 1e18);
	}
}// GPL-3.0

pragma solidity 0.8.7;





 abstract contract SdtDistributorEvents {
	event DelegateGaugeUpdated(address indexed _gaugeAddr, address indexed _delegateGauge);
	event DistributionsToggled(bool _distributionsOn);
	event GaugeControllerUpdated(address indexed _controller);
	event GaugeToggled(address indexed gaugeAddr, bool newStatus);
	event InterfaceKnownToggled(address indexed _delegateGauge, bool _isInterfaceKnown);
	event RateUpdated(uint256 _newRate);
	event Recovered(address indexed tokenAddress, address indexed to, uint256 amount);
	event RewardDistributed(address indexed gaugeAddr, uint256 sdtDistributed, uint256 lastMasterchefPull);
	event UpdateMiningParameters(uint256 time, uint256 rate, uint256 supply);
}// MIT

pragma solidity 0.8.7;


contract SdtDistributorV2 is ReentrancyGuardUpgradeable, AccessControlUpgradeable, SdtDistributorEvents {
	using SafeERC20 for IERC20;


	uint256 public constant BASE_UNIT = 10_000;

	IERC20 public constant rewardToken = IERC20(0x73968b9a57c6E53d41345FD57a6E6ae27d6CDB2F);

	IMasterchef public constant masterchef = IMasterchef(0xfEA5E213bbD81A8a94D0E1eDB09dBD7CEab61e1c);

	bytes32 public constant GOVERNOR_ROLE = keccak256("GOVERNOR_ROLE");
	bytes32 public constant GUARDIAN_ROLE = keccak256("GUARDIAN_ROLE");


	uint256 public timePeriod;

	IERC20 public masterchefToken;

	IGaugeController public controller;

	address public delegateGauge;

	bool public distributionsOn;

	mapping(address => address) public delegateGauges;

	mapping(address => bool) public killedGauges;

	mapping(address => bool) public isInterfaceKnown;

	uint256 public masterchefPID;

	uint256 public lastMasterchefPull;

	mapping(uint256 => uint256) public pulls; // day => SDT amount

	mapping(uint256 => mapping(address => bool)) public isGaugePaid;

	uint256 public claimerFee;

	uint256 public lookPastDays;


	function initialize(
		address _controller,
		address _governor,
		address _guardian,
		address _delegateGauge
	) external initializer {
		require(_controller != address(0) && _guardian != address(0) && _governor != address(0), "0");

		controller = IGaugeController(_controller);
		delegateGauge = _delegateGauge;

		masterchefToken = IERC20(address(new MasterchefMasterToken()));
		distributionsOn = false;

		timePeriod = 3600 * 24; // One day in seconds
		lookPastDays = 45; // for past 45 days check

		_setRoleAdmin(GOVERNOR_ROLE, GOVERNOR_ROLE);
		_setRoleAdmin(GUARDIAN_ROLE, GOVERNOR_ROLE);

		_setupRole(GUARDIAN_ROLE, _guardian);
		_setupRole(GOVERNOR_ROLE, _governor);
		_setupRole(GUARDIAN_ROLE, _governor);
	}

	constructor() initializer {}

	function initializeMasterchef(uint256 _pid) external onlyRole(GOVERNOR_ROLE) {
		masterchefPID = _pid;
		masterchefToken.approve(address(masterchef), 1e18);
		masterchef.deposit(_pid, 1e18);
	}


	function distribute(address gaugeAddr) external nonReentrant {
		_distribute(gaugeAddr);
	}

	function distributeMulti(address[] calldata gaugeAddr) public nonReentrant {
		uint256 length = gaugeAddr.length;
		for (uint256 i; i < length; i++) {
			_distribute(gaugeAddr[i]);
		}
	}

	function _distribute(address gaugeAddr) internal {
		require(distributionsOn, "not allowed");
		(bool success, bytes memory result) = address(controller).call(
			abi.encodeWithSignature("gauge_types(address)", gaugeAddr)
		);
		if (!success || killedGauges[gaugeAddr]) {
			return;
		}
		int128 gaugeType = abi.decode(result, (int128));

		uint256 roundedTimestamp = (block.timestamp / 1 days) * 1 days;

		uint256 totalDistribute;

		if (block.timestamp > lastMasterchefPull + timePeriod) {
			uint256 sdtBefore = rewardToken.balanceOf(address(this));
			_pullSDT();
			pulls[roundedTimestamp] = rewardToken.balanceOf(address(this)) - sdtBefore;
			lastMasterchefPull = roundedTimestamp;
		}
		for (uint256 i; i < lookPastDays; i++) {
			uint256 currentTimestamp = roundedTimestamp - (i * 86_400);

			if (pulls[currentTimestamp] > 0) {
				bool isPaid = isGaugePaid[currentTimestamp][gaugeAddr];
				if (isPaid) {
					break;
				}

				uint256 sdtBalance = pulls[currentTimestamp];
				uint256 gaugeRelativeWeight;

				if (i == 0) {
					gaugeRelativeWeight = controller.gauge_relative_weight_write(gaugeAddr, currentTimestamp);
				} else {
					gaugeRelativeWeight = controller.gauge_relative_weight(gaugeAddr, currentTimestamp);
				}

				uint256 sdtDistributed = (sdtBalance * gaugeRelativeWeight) / 1e18;
				totalDistribute += sdtDistributed;
				isGaugePaid[currentTimestamp][gaugeAddr] = true;
			}
		}
		if (totalDistribute > 0) {
			if (gaugeType == 1) {
				rewardToken.safeTransfer(gaugeAddr, totalDistribute);
				IStakingRewards(gaugeAddr).notifyRewardAmount(totalDistribute);
			} else if (gaugeType >= 2) {
				address delegate = delegateGauges[gaugeAddr];
				if (delegate == address(0)) {
					delegate = delegateGauge;
				}
				if (delegate != address(0)) {
					rewardToken.safeTransfer(delegate, totalDistribute);
					if (isInterfaceKnown[delegate]) {
						ISdtMiddlemanGauge(delegate).notifyReward(gaugeAddr, totalDistribute);
					}
				} else {
					rewardToken.safeTransfer(gaugeAddr, totalDistribute);
				}
			} else {
				ILiquidityGauge(gaugeAddr).deposit_reward_token(address(rewardToken), totalDistribute);
			}

			emit RewardDistributed(gaugeAddr, totalDistribute, lastMasterchefPull);
		}
	}

	function _pullSDT() internal {
		masterchef.withdraw(masterchefPID, 0);
	}


	function setDistribution(bool _state) external onlyRole(GOVERNOR_ROLE) {
		distributionsOn = _state;
	}

	function setGaugeController(address _controller) external onlyRole(GOVERNOR_ROLE) {
		require(_controller != address(0), "0");
		controller = IGaugeController(_controller);
		emit GaugeControllerUpdated(_controller);
	}

	function setDelegateGauge(
		address gaugeAddr,
		address _delegateGauge,
		bool toggleInterface
	) external onlyRole(GOVERNOR_ROLE) {
		if (gaugeAddr != address(0)) {
			delegateGauges[gaugeAddr] = _delegateGauge;
		} else {
			delegateGauge = _delegateGauge;
		}
		emit DelegateGaugeUpdated(gaugeAddr, _delegateGauge);

		if (toggleInterface) {
			_toggleInterfaceKnown(_delegateGauge);
		}
	}

	function toggleGauge(address gaugeAddr) external onlyRole(GOVERNOR_ROLE) {
		bool gaugeKilledMem = killedGauges[gaugeAddr];
		if (!gaugeKilledMem) {
			rewardToken.safeApprove(gaugeAddr, 0);
		}
		killedGauges[gaugeAddr] = !gaugeKilledMem;
		emit GaugeToggled(gaugeAddr, !gaugeKilledMem);
	}

	function toggleInterfaceKnown(address _delegateGauge) external onlyRole(GUARDIAN_ROLE) {
		_toggleInterfaceKnown(_delegateGauge);
	}

	function _toggleInterfaceKnown(address _delegateGauge) internal {
		bool isInterfaceKnownMem = isInterfaceKnown[_delegateGauge];
		isInterfaceKnown[_delegateGauge] = !isInterfaceKnownMem;
		emit InterfaceKnownToggled(_delegateGauge, !isInterfaceKnownMem);
	}

	function approveGauge(address gaugeAddr) external onlyRole(GOVERNOR_ROLE) {
		rewardToken.safeApprove(gaugeAddr, type(uint256).max);
	}

	function setTimePeriod(uint256 _timePeriod) external onlyRole(GOVERNOR_ROLE) {
		require(_timePeriod >= 1 days, "TOO_LOW");
		timePeriod = _timePeriod;
	}

	function setClaimerFee(uint256 _newFee) external onlyRole(GOVERNOR_ROLE) {
		require(_newFee <= BASE_UNIT, "TOO_HIGH");
		claimerFee = _newFee;
	}

	function setLookPastDays(uint256 _newLookPastDays) external onlyRole(GOVERNOR_ROLE) {
		lookPastDays = _newLookPastDays;
	}

	function recoverERC20(
		address tokenAddress,
		address to,
		uint256 amount
	) external onlyRole(GOVERNOR_ROLE) {
		IERC20(tokenAddress).safeTransfer(to, amount);
		emit Recovered(tokenAddress, to, amount);
	}
}