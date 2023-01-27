
pragma solidity ^0.8.0;

library Clones {

    function clone(address implementation) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, implementation))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address implementation, bytes32 salt)
        internal
        view
        returns (address predicted)
    {

        return predictDeterministicAddress(implementation, salt, address(this));
    }
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {
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
pragma solidity 0.8.9;

interface IUniswapV2Pair {

	function token0() external view returns (address);


	function token1() external view returns (address);

}// MIT
pragma solidity 0.8.9;

interface IUniswapV2Factory {

	function getPair(address tokenA, address tokenB) external view returns (address pair);

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

interface ITokenaFactory {

	function getFeeTaker() external view returns (address);


	function getFeePercentage() external view returns (uint256);


	function getDelta() external view returns (uint256);


	function whitelistAddress(address user) external view returns (bool);

}// MIT
pragma solidity 0.8.9;


contract TokenaFactory is ITokenaFactory, AccessControlUpgradeable, ReentrancyGuardUpgradeable {

	using SafeERC20Upgradeable for IERC20Upgradeable;

	uint256 public lastLMId;
	uint256 public lastStakingId;
	address public masterStaking;

	uint8 private feePercentage;
	uint8 private feeReferal;
	uint8 private counterStaking;
	uint8 private counterLM;
	address private feeTaker;
	uint256 private delta;

	address[] public dexFactory;
	address[] public stakings;
	address[] public liquidityMinings;
	mapping(address => uint256[]) public userStakings;
	mapping(address => uint256[]) public userLMs;
	mapping(address => bool) public promotedStakings;
	mapping(address => bool) public promotedLM;
	mapping(address => bool) public whitelistAddress;

	modifier onlyAdmin {

        address sender = _msgSender();
        require(
            hasRole(DEFAULT_ADMIN_ROLE, sender),
            "Access error"
        );
        _;
    }

	function initialize(
		address _feeTaker,
		uint8 _feePercentage,
		uint8 _feeReferal,
		uint256 _delta,
		address[] calldata _dexFactory
	) external initializer {

		require(_feeTaker != address(0), "Not valid feeTaker address");
		require(_feeReferal <= 100, "Invalid referal fee");
		require(_feePercentage <= 100, "Invalid referal fee");
		for (uint256 i = 0; i < _dexFactory.length; i++) {
			require(_dexFactory[i] != address(0), "Wrong dex address");
		}
		feeTaker = _feeTaker;
		dexFactory = _dexFactory;
		feePercentage = _feePercentage;
		feeReferal = _feeReferal;
		delta = _delta;
		__AccessControl_init();
		__ReentrancyGuard_init();
		_setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
	}

	function createStaking(
		bool isLM,
		address referalAddress,
		address stakedToken,
		address[] calldata rewardToken,
		uint256[] memory rewardTokenAmounts,
		uint256 startBlock,
		uint256 endBlock,
		IStaking.ProjectInfo calldata info
	) external {

		if (isLM) {
			require(checkValidLpAddress(stakedToken), "Is not valid LP token");
		}
		require(bytes(info.name).length != 0, "Must set name");
		require(info.themeId > 0 && info.themeId < 10, "Wrong theme id");
		require(startBlock >= block.number && endBlock > startBlock, "Is not valid time");
		require(rewardToken.length == rewardTokenAmounts.length, "Unvalid length of reward");
		require(stakedToken != address(0), "staked token 0x0");
		address newStaking = Clones.clone(masterStaking);
		for (uint256 i; i < rewardToken.length; i++) {
			if (!whitelistAddress[rewardToken[i]]) {
				uint256 feeAmount = (rewardTokenAmounts[i] * feePercentage) / 100;
				uint256 referalAmount;

				if (referalAddress != address(0)) {
					referalAmount = (rewardTokenAmounts[i] * feePercentage * feeReferal) / 10000;
					feeAmount = feeAmount - referalAmount;
					IERC20Upgradeable(rewardToken[i]).safeTransferFrom(msg.sender, referalAddress, referalAmount);
				}
				IERC20Upgradeable(rewardToken[i]).safeTransferFrom(msg.sender, feeTaker, feeAmount);
			}

			IERC20Upgradeable(rewardToken[i]).safeTransferFrom(msg.sender, newStaking, rewardTokenAmounts[i]);
			rewardTokenAmounts[i] = IERC20Upgradeable(rewardToken[i]).balanceOf(newStaking);
		}
		IStaking(address(newStaking)).initialize(stakedToken, rewardToken, rewardTokenAmounts, startBlock, endBlock, info, msg.sender);
		if (isLM) {
			liquidityMinings.push(newStaking);
			userLMs[msg.sender].push(lastLMId);
			lastLMId++;
		} else {
			stakings.push(newStaking);
			userStakings[msg.sender].push(lastStakingId);
			lastStakingId++;
		}
	}

	function setMasterStaking(address adr) external onlyAdmin {

		require(adr != address(0), "master staking wrong address");
		masterStaking = adr;
	}

	function setFeeTaker(address _feeTaker) external onlyAdmin {

		require(_feeTaker != address(0), "Cannot set zero address");
		feeTaker = _feeTaker;
	}

	function changeWhitelist(address token, bool flag) external onlyAdmin {

		require(token != address(0), "Cannot set zero address");
		require(whitelistAddress[token] != flag, "Already set");
		whitelistAddress[token] = flag;
	}

	function setFeePercentage(uint8 _feePercentage) external onlyAdmin {

		require(_feePercentage < 100, "Cannot set fee this high");
		feePercentage = _feePercentage;
	}

	function setFeeReferal(uint8 _feeReferal) external onlyAdmin {

		require(_feeReferal < 100, "Invalid fee referal");
		feeReferal = _feeReferal;
	}

	function setDelta(uint256 _delta) external onlyAdmin {

		delta = _delta;
	}

	function changePromotedStaking(address pool, bool flag) external onlyAdmin {

		require(pool != address(0), "Must be valid address");
		if (flag) {
			require(counterStaking < 5, "Already has 5 promoted");
			require(!promotedStakings[pool], "Already promoted");
			counterStaking++;
			promotedStakings[pool] = flag;
		} else {
			require(counterStaking != 0, "There are no promoted");
			require(promotedStakings[pool], "Already not promoted");
			counterStaking--;
			promotedStakings[pool] = flag;
		}
	}

	function changePromotedLM(address pool, bool flag) external onlyAdmin {

		require(pool != address(0), "Must be valid address");
		if (flag) {
			require(counterLM < 5, "Already has 5 promoted");
			require(!promotedLM[pool], "Already promoted");
			counterLM++;
			promotedLM[pool] = flag;
		} else {
			require(counterLM != 0, "There are no promoted");
			require(promotedLM[pool], "Already not promoted");
			counterLM--;
			promotedLM[pool] = flag;
		}
	}

	function getUserStakings(bool isLM, address user) external view returns (address[] memory) {

		if (isLM) {
			address[] memory temp = new address[](userLMs[user].length);
			for (uint256 i = 0; i < userLMs[user].length; i++) {
				temp[i] = liquidityMinings[userLMs[user][i]];
			}
			return temp;
		} else {
			address[] memory temp = new address[](userStakings[user].length);
			for (uint256 i = 0; i < userStakings[user].length; i++) {
				temp[i] = stakings[userStakings[user][i]];
			}
			return temp;
		}
	}

	function getAllStakings(bool isLM) external view returns (address[] memory) {

		if (isLM) {
			return liquidityMinings;
		} else {
			return stakings;
		}
	}

	function getFeeTaker() external view override returns (address) {

		return feeTaker;
	}

	function getFeePercentage() external view override returns (uint256) {

		return feePercentage;
	}

	function getDelta() external view override returns (uint256) {

		return delta;
	}

	function checkValidLpAddress(address token) public view returns (bool) {

		require(token != address(0), "lp token address 0x0");
		address token0;
		try IUniswapV2Pair(token).token0() returns (address _token0) {
			token0 = _token0;
		} catch (bytes memory) {
			return false;
		}

		address token1;
		try IUniswapV2Pair(token).token1() returns (address _token1) {
			token1 = _token1;
		} catch (bytes memory) {
			return false;
		}

		for (uint256 i = 0; i < dexFactory.length; i++) {
			address goodPair = IUniswapV2Factory(dexFactory[i]).getPair(token0, token1);
			if (goodPair == token) {
				return true;
			}
		}
		return false;
	}
}