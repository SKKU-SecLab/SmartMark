
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
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
}//MIT
pragma solidity ^0.8.0;



interface KeyIERC20 is IERC20 {

	function hasReachedCap() external view returns (bool);


	function mint(address to, uint256 amount) external payable returns (bool);


	function decimals() external view returns (uint8);

}

contract StakingPoolM1 is
	ReentrancyGuard,
	Pausable,
	AccessControl,
	IERC721Receiver
{

	// defensive as not required after pragma ^0.8
	using SafeMath for uint256;

	bytes32 public constant PAUSER_ROLE = keccak256('PAUSER_ROLE');
	bytes32 public constant MANAGER_ROLE = keccak256('MANGER_ROLE');

	KeyIERC20 public rewardsToken;
	IERC721 public stakingToken;
	uint256 public rewardForPeriod = 1 * (10**18);
	uint256 public stakePeriod = 28 days;
	uint256 public stakeRewardsPerSecond = rewardForPeriod / stakePeriod;

	uint256 private _minimumStakePeriod = 28 days;
	uint256 private _minimumRewardForPeriod = 5 * (10**17);

	struct Stake {
		uint256 tokenId; // tokenID of $1CLB NFT
		uint256 startTime; // timestamp of when NFT was staked
		uint256 lastClaim; // timestamp of when last claim was made
		bool isStake; // needs a manual check to distinguish a default from an explicitly "all 0" record
	}

	mapping(address => Stake[]) public stakeHolders;

	event Staked(uint256 tokenId);

	constructor(address _stakingToken, address _rewardsToken) {
		_grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
		_grantRole(MANAGER_ROLE, msg.sender);
		_grantRole(PAUSER_ROLE, msg.sender);
		setStakingToken(_stakingToken);
		setRewardToken(_rewardsToken);
	}

	function setStakeRewardForPeriod(uint256 reward)
		public
		onlyRole(MANAGER_ROLE)
	{

		rewardForPeriod = reward;
	}

	function setStakingToken(address _stakingToken)
		public
		onlyRole(MANAGER_ROLE)
	{

		stakingToken = IERC721(_stakingToken);
	}

	function setRewardToken(address _rewardsToken)
		public
		onlyRole(MANAGER_ROLE)
	{

		rewardsToken = KeyIERC20(_rewardsToken);
	}

	function pause() public onlyRole(PAUSER_ROLE) {

		_pause();
	}

	function unpause() public onlyRole(PAUSER_ROLE) {

		_unpause();
	}

	function calculateReward(address _owner, uint256 _tokenId)
		public
		view
		returns (uint256)
	{

		if (rewardsToken.hasReachedCap()) return 0;

		Stake memory currentStake = getStakeWithTokenId(_owner, _tokenId);

		uint256 stakeEndTime = calculateLockTime(currentStake.startTime);

		if (block.timestamp > stakeEndTime) {
			uint256 _timeElapsedSinceLastClaim = stakeEndTime -
				currentStake.lastClaim;
			uint256 timeElapsedSinceEndStake = block.timestamp - stakeEndTime;

			uint256 minStakeRewardPerMS = _minimumRewardForPeriod /
				_minimumStakePeriod;

			uint256 _rewardsForTimeElapsed = stakeRewardsPerSecond *
				_timeElapsedSinceLastClaim;
			uint256 rewardsForTimeElapsedAfterStake = minStakeRewardPerMS *
				timeElapsedSinceEndStake;

			return (_rewardsForTimeElapsed + rewardsForTimeElapsedAfterStake);
		}

		uint256 timeElapsedSinceLastClaim = block.timestamp -
			currentStake.lastClaim;
		uint256 rewardsForTimeElapsed = stakeRewardsPerSecond *
			timeElapsedSinceLastClaim;

		return rewardsForTimeElapsed;
	}

	function calculateLockTime(uint256 _startTime)
		public
		view
		returns (uint256)
	{

		return _startTime + stakePeriod;
	}

	function getStakes(address _owner) external view returns (Stake[] memory) {

		return stakeHolders[_owner];
	}

	function getStakeWithTokenId(address _owner, uint256 _tokenId)
		public
		view
		returns (Stake memory)
	{

		Stake[] memory currentStakes = this.getStakes(_owner);
		for (uint256 i = 0; i < currentStakes.length; i++) {
			if (currentStakes[i].tokenId == _tokenId) {
				return currentStakes[i];
			}
		}
		revert('Token is not staked by owner');
	}

	function goldStake(address _owner, uint256 _tokenId) external {

		require(
			msg.sender == address(stakingToken),
			'caller must be token contract'
		);

		stakeHolders[_owner].push(
			Stake(_tokenId, block.timestamp, block.timestamp, true)
		);

		emit Staked(_tokenId);
	}

	function stake(uint256 _tokenId) external whenNotPaused {

		stakingToken.transferFrom(msg.sender, address(this), _tokenId);

		Stake memory newStake = Stake({
			tokenId: _tokenId,
			startTime: block.timestamp,
			lastClaim: block.timestamp,
			isStake: true
		});

		stakeHolders[msg.sender].push(newStake);

		emit Staked(_tokenId);
	}

	function claimReward(uint256 _tokenId) public whenNotPaused {

		uint256 rewards = calculateReward(msg.sender, _tokenId);

		(bool success, bytes memory returnedData) = address(rewardsToken).call(
			abi.encodeWithSignature(
				'mint(address,uint256)',
				msg.sender,
				rewards
			)
		);

		require(success, string(returnedData));
		_updateStakeClaimTime(msg.sender, _tokenId);
	}

	function claimRewardAndWithdrawStake(uint256 _tokenId)
		external
		whenNotPaused
	{

		claimReward(_tokenId);
		withdrawStake(_tokenId);
	}

	function withdrawStake(uint256 _tokenId) public whenNotPaused {

		Stake memory currentStake = getStakeWithTokenId(msg.sender, _tokenId);
		require(
			calculateLockTime(currentStake.startTime) <= block.timestamp,
			'Lock up period has not expired yet'
		);

		for (uint256 i = 0; i < stakeHolders[msg.sender].length; i++) {
			if (stakeHolders[msg.sender][i].tokenId == _tokenId) {
				stakeHolders[msg.sender][i].isStake = false; // defensive
				delete stakeHolders[msg.sender];
			}
		}
		stakingToken.transferFrom(address(this), msg.sender, _tokenId);
	}

	function claimAndReStake(uint256 _tokenId) public whenNotPaused {

		Stake memory currentStake = getStakeWithTokenId(msg.sender, _tokenId);
		require(
			calculateLockTime(currentStake.startTime) <= block.timestamp,
			'Lock up period has not expired yet'
		);

		claimReward(_tokenId);

		Stake memory newStake = Stake({
			tokenId: _tokenId,
			startTime: block.timestamp,
			lastClaim: block.timestamp,
			isStake: true
		});

		for (uint256 i = 0; i < stakeHolders[msg.sender].length; i++) {
			if (stakeHolders[msg.sender][i].tokenId == _tokenId) {
				stakeHolders[msg.sender][i] = newStake;
			}
		}

		emit Staked(_tokenId);
	}

	function onERC721Received(
		address _operator,
		address _from,
		uint256 _tokenId,
		bytes memory _data
	) public pure override returns (bytes4) {

		return this.onERC721Received.selector;
	}

	function _updateStakeClaimTime(address _owner, uint256 _tokenId) private {

		for (uint256 i = 0; i < stakeHolders[_owner].length; i++) {
			if (stakeHolders[_owner][i].tokenId == _tokenId) {
				uint256 stakeExpiry = calculateLockTime(
					stakeHolders[_owner][i].startTime
				);
				if (stakeExpiry < block.timestamp) {
					stakeHolders[_owner][i].lastClaim = stakeExpiry;
				} else {
					stakeHolders[_owner][i].lastClaim = block.timestamp;
				}
			}
		}
	}
}