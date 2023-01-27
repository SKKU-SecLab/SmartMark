
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
pragma solidity 0.8.9;

interface ITokenaFactory {
	function getFeeTaker() external view returns (address);

	function getFeePercentage() external view returns (uint256);

	function getDelta() external view returns (uint256);

	function whitelistAddress(address user) external view returns (bool);
}// MIT
pragma solidity 0.8.9;

interface IStaking {
	struct ProjectInfo {
		string name;
		string link;
		uint256 themeId;
	}

	function initialize(
		address stakedToken,
		address[] memory rewardToken,
		uint256[] memory rewardTokenAmounts,
		uint256 startBlock,
		uint256 endBlock,
		ProjectInfo calldata info,
		address admin
	) external;
}// MIT
pragma solidity 0.8.9;


contract Staking is IStaking, AccessControl, ReentrancyGuard {
	using SafeERC20 for ERC20;

	ITokenaFactory public immutable factory;

	bool private _isInitialized;
	uint8 public bonusMultiplier;

	uint256[] public accTokenPerShare;

	uint256 public stakers;
	uint256 public startBlock;
	uint256 public endBlock;
	uint256 public bonusStartBlock;
	uint256 public bonusEndBlock;
	uint256[] public rewardPerBlock;
	uint256[] public rewardTokenAmounts;
	uint256 public stakedTokenSupply;

	ERC20[] public rewardToken;
	ERC20 public stakedToken;
	ProjectInfo public info;

	uint128[] private _PRECISION_FACTOR;
	uint256 private _numOfRewardTokens;
	uint256 private _lastRewardBlock;

	mapping(address => UserInfo) public userInfo;

	struct UserInfo {
		uint256 amount; // How many staked tokens the user has provided
		uint256[] rewardDebt; // Reward debt
	}

	constructor(address adr) {
		factory = ITokenaFactory(adr);
	}

	function initialize(
		address _stakedToken,
		address[] calldata _rewardToken,
		uint256[] calldata _rewardTokenAmounts,
		uint256 _startBlock,
		uint256 _endBlock,
		ProjectInfo calldata _info,
		address admin
	) external override {
		require(!_isInitialized, "Already initialized");
		require(msg.sender == address(factory), "Initialize not from factory");
		_isInitialized = true;
		_setupRole(DEFAULT_ADMIN_ROLE, admin);
		stakedToken = ERC20(_stakedToken);
		uint256 i;
		for (i; i < _rewardToken.length; i++) {
			rewardToken.push(ERC20(_rewardToken[i]));
			accTokenPerShare.push(0);

			rewardPerBlock.push(_rewardTokenAmounts[i] / (_endBlock - _startBlock));

			uint8 decimalsRewardToken = (ERC20(_rewardToken[i]).decimals());
			require(decimalsRewardToken < 30, "Must be inferior to 30");
			_PRECISION_FACTOR.push(uint128(10**(30 - (decimalsRewardToken))));
		}
		info = _info;
		startBlock = _startBlock;
		_lastRewardBlock = _startBlock;
		bonusMultiplier = 1;
		endBlock = _endBlock;
		rewardTokenAmounts = _rewardTokenAmounts;
		_numOfRewardTokens = _rewardToken.length;
	}

	function deposit(uint256 amount) external nonReentrant {
		require(amount != 0, "Must deposit not 0");
		require(block.number < endBlock, "Pool already end");
		UserInfo storage user = userInfo[msg.sender];
		uint256 pending;
		uint256 i;
		if (user.rewardDebt.length == 0) {
			user.rewardDebt = new uint256[](_numOfRewardTokens);
			stakers++;
		}
		_updatePool();
		uint256 curAmount = user.amount;
		uint256 balanceBefore = stakedToken.balanceOf(address(this));
		stakedToken.safeTransferFrom(address(msg.sender), address(this), amount);
		uint256 balanceAfter = stakedToken.balanceOf(address(this));
		user.amount = user.amount + (balanceAfter - balanceBefore);
		stakedTokenSupply += (balanceAfter - balanceBefore);

		for (i = 0; i < _numOfRewardTokens; i++) {
			if (curAmount > 0) {
				pending = (curAmount * (accTokenPerShare[i])) / (_PRECISION_FACTOR[i]) - (user.rewardDebt[i]);

				if (pending > 0) {
					rewardToken[i].safeTransfer(address(msg.sender), pending);
				}
			}
			user.rewardDebt[i] = (user.amount * (accTokenPerShare[i])) / (_PRECISION_FACTOR[i]);
		}
	}

	function withdraw(uint256 amount) external nonReentrant {
		UserInfo storage user = userInfo[msg.sender];
		require(user.amount >= amount, "Amount to withdraw too high");
		bool flag;
		_updatePool();

		uint256 pending;
		uint256 i;
		uint256 curAmount = user.amount;
		if (amount > 0) {
			user.amount = user.amount - (amount);
			stakedToken.safeTransfer(address(msg.sender), amount);
			if (user.amount == 0) {
				flag = true;
			}
		}
		stakedTokenSupply -= amount;
		for (i = 0; i < _numOfRewardTokens; i++) {
			pending = ((curAmount * (accTokenPerShare[i])) / (_PRECISION_FACTOR[i]) - (user.rewardDebt[i]));
			if (pending > 0) {
				rewardToken[i].safeTransfer(address(msg.sender), pending);
			}

			user.rewardDebt[i] = (user.amount * (accTokenPerShare[i])) / (_PRECISION_FACTOR[i]);
		}

		if (flag) {
			delete (userInfo[msg.sender]);
			stakers--;
		}
	}

	function withdrawOnlyIndexWithoutUnstake(uint256 index) external nonReentrant {
		require(index < _numOfRewardTokens, "Wrong index");
		UserInfo storage user = userInfo[msg.sender];

		_updatePool();

		uint256 newRewardDebt = ((user.amount * (accTokenPerShare[index])) / (_PRECISION_FACTOR[index]));

		uint256 pending = (newRewardDebt - (user.rewardDebt[index]));

		if (pending > 0) {
			rewardToken[index].safeTransfer(address(msg.sender), pending);
		}

		user.rewardDebt[index] = newRewardDebt;
	}

	function emergencyWithdraw() external nonReentrant {
		UserInfo storage user = userInfo[msg.sender];
		uint256 amountToTransfer = user.amount;
		stakedTokenSupply -= amountToTransfer;
		delete (userInfo[msg.sender]);
		stakers--;
		if (amountToTransfer > 0) {
			stakedToken.safeTransfer(address(msg.sender), amountToTransfer);
		}
	}

	function updateProjectInfo(ProjectInfo calldata _info) external onlyRole(DEFAULT_ADMIN_ROLE) {
		require(bytes(info.name).length != 0, "Must set name");
		require(info.themeId > 0 && info.themeId < 10, "Wrong theme id");
		info = _info;
	}

	function getLeftovers(address toTransfer) external nonReentrant onlyRole(DEFAULT_ADMIN_ROLE) {
		require((endBlock + factory.getDelta()) >= block.number, "Too early");
		for (uint256 i; i < _numOfRewardTokens; i++) {
			ERC20 token = rewardToken[i];
			token.safeTransfer(toTransfer, token.balanceOf(address(this)));
		}
	}

	function startBonusTime(
		uint8 _bonusMultiplier,
		uint256 _bonusStartBlock,
		uint256 _bonusEndBlock
	) external onlyRole(DEFAULT_ADMIN_ROLE) {
		require(_bonusMultiplier > 1, "Multiplier must be > 1");
		require(_bonusStartBlock >= startBlock && _bonusStartBlock < endBlock, "Non valid start time");
		require(_bonusEndBlock > startBlock && _bonusEndBlock > _bonusStartBlock, "Non valid end time");
		_updatePool();
		require(bonusEndBlock == 0, "Can't start another Bonus Time");
		uint256 _endBlock = endBlock - ((_bonusEndBlock - _bonusStartBlock) * (_bonusMultiplier - 1));
		require(_endBlock > block.number && _endBlock > startBlock, "Not enough rewards for Bonus");
		if (_endBlock < _bonusEndBlock) {
			bonusEndBlock = _endBlock;
		} else {
			bonusEndBlock = _bonusEndBlock;
		}
		bonusMultiplier = _bonusMultiplier;
		bonusStartBlock = _bonusStartBlock;
		endBlock = _endBlock;
	}

	function updateEndBlock(uint256 _endBlock) external onlyRole(DEFAULT_ADMIN_ROLE) nonReentrant {
		require(endBlock > block.number, "Pool already finished");
		require(_endBlock > endBlock, "Cannot shorten");
		uint256 blocksAdded = _endBlock - endBlock;
		for (uint256 i; i < _numOfRewardTokens; i++) {
			uint256 toTransfer = blocksAdded * rewardPerBlock[i];
			require(toTransfer > 100, "Too short for increase");
			address taker = factory.getFeeTaker();
			uint256 percent = factory.getFeePercentage();
			uint256 balanceBefore = rewardToken[i].balanceOf(address(this));
			rewardToken[i].safeTransferFrom(msg.sender, address(this), toTransfer);
			uint256 balanceAfter = rewardToken[i].balanceOf(address(this));
			rewardTokenAmounts[i] += balanceAfter - balanceBefore;
			if (!factory.whitelistAddress(address(rewardToken[i]))) {
				rewardToken[i].safeTransferFrom(msg.sender, taker, (toTransfer * percent) / 100);
			}
		}
		endBlock = _endBlock;
	}

	function getRewardTokens() external view returns (ERC20[] memory) {
		return rewardToken;
	}

	function pendingReward(address _user) external view returns (uint256[] memory) {
		require(block.number > startBlock, "Pool is not started yet");
		UserInfo memory user = userInfo[_user];
		uint256[] memory toReturn = new uint256[](_numOfRewardTokens);

		for (uint256 i; i < _numOfRewardTokens; i++) {
			if (block.number > _lastRewardBlock && stakedTokenSupply != 0) {
				uint256 multiplier = _getMultiplier(_lastRewardBlock, block.number);
				uint256 reward = multiplier * (rewardPerBlock[i]);
				uint256 adjustedTokenPerShare = accTokenPerShare[i] + ((reward * (_PRECISION_FACTOR[i])) / (stakedTokenSupply));
				toReturn[i] = (user.amount * (adjustedTokenPerShare)) / (_PRECISION_FACTOR[i]) - (user.rewardDebt[i]);
			} else {
				toReturn[i] = (user.amount * (accTokenPerShare[i])) / (_PRECISION_FACTOR[i]) - (user.rewardDebt[i]);
			}
		}
		return toReturn;
	}

	function _updatePool() internal {
		if (block.number <= _lastRewardBlock) {
			return;
		}

		if (stakedTokenSupply == 0) {
			_lastRewardBlock = block.number;
			return;
		}

		uint256 multiplier = _getMultiplier(_lastRewardBlock, block.number);
		for (uint256 i; i < _numOfRewardTokens; i++) {
			uint256 reward = multiplier * (rewardPerBlock[i]);
			accTokenPerShare[i] = accTokenPerShare[i] + ((reward * (_PRECISION_FACTOR[i])) / (stakedTokenSupply));
		}
		if (endBlock > block.number) {
			_lastRewardBlock = block.number;
		} else {
			_lastRewardBlock = endBlock;
		}

		if (bonusEndBlock != 0 && block.number > bonusEndBlock) {
			bonusStartBlock = 0;
			bonusEndBlock = 0;
			bonusMultiplier = 1;
		}
	}

	function _getMultiplier(uint256 from, uint256 to) internal view returns (uint256) {
		from = from >= startBlock ? from : startBlock;
		to = endBlock > to ? to : endBlock;
		if (from < bonusStartBlock && to > bonusEndBlock) {
			return bonusStartBlock - from + to - bonusEndBlock + (bonusEndBlock - bonusStartBlock) * bonusMultiplier;
		} else if (from < bonusStartBlock && to > bonusStartBlock) {
			return bonusStartBlock - from + (to - bonusStartBlock) * bonusMultiplier;
		} else if (from < bonusEndBlock && to > bonusEndBlock) {
			return to - bonusEndBlock + (bonusEndBlock - from) * bonusMultiplier;
		} else if (from >= bonusStartBlock && to <= bonusEndBlock) {
			return (to - from) * bonusMultiplier;
		} else {
			return to - from;
		}
	}
}