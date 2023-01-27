
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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}// MIT
pragma solidity ^0.8.0;


contract NFTYToken is ERC20Upgradeable, OwnableUpgradeable {

    function initialize() public initializer {

        __ERC20_init("NFTY Token", "NFTY");
        __Ownable_init();
        _mint(owner(), 50000 * 10**uint256(decimals()));
    }

    function mint(address account, uint256 amount) external onlyOwner {

        _mint(account, amount);
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
pragma solidity ^0.8.0;


contract NFTYStakingUpgradeable is
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable
{

    NFTYToken nftyToken;
    address private _NFTYTokenAddress;
    uint256 private _totalStakedToken;
    uint256[6] private _rewardRate;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    event NewStake(address indexed staker, uint256 amount);

    event RewardReleased(address indexed staker, uint256 reward);

    event StakeUpgraded(
        address indexed staker,
        uint256 amount,
        uint256 totalStake
    );

    event StakeReleased(
        address indexed staker,
        uint256 amount,
        uint256 remainingStake
    );

    event RateChanged(
        address indexed admin,
        uint8 rank,
        uint256 oldRate,
        uint256 newRate
    );

    event TransferredAllTokens(address caller, uint256 amount);

    modifier isRealAddress(address account) {

        require(account != address(0), "NFTYStaking: address is zero address");
        _;
    }

    modifier isRealValue(uint256 value) {

        require(value > 0, "NFTYStaking: value must be greater than zero");
        _;
    }

    modifier isStaker(address account) {

        require(
            StakersData[account].amount > 0,
            "NFTYStaking: caller is not a staker"
        );
        _;
    }

    struct StakeData {
        uint256 amount;
        uint256 reward;
        uint256 stakingTime;
        uint256 lastClaimTime;
    }

    mapping(address => StakeData) public StakersData;

    function initialize(address NFTYTokenAddress)
        public
        isRealAddress(NFTYTokenAddress)
        isRealAddress(_msgSender())
        initializer
    {

        __ReentrancyGuard_init();
        __AccessControl_init();
        _setupRole(ADMIN_ROLE, _msgSender());
        _setRoleAdmin(ADMIN_ROLE, ADMIN_ROLE);
        _NFTYTokenAddress = NFTYTokenAddress;
        nftyToken = NFTYToken(NFTYTokenAddress);
        _rewardRate = [13579, 14579, 15079, 15579, 15829, 16079]; // 13.579%, 14.579%, 15.079%, 15.579%, 16.079%
    }

    function transferOwnership(address _newOwner)
        external
        onlyRole(ADMIN_ROLE)
    {

        nftyToken.transferOwnership(_newOwner);
    }

    function stakeTokens(uint256 amount)
        external
        isRealAddress(_msgSender())
        isRealValue(amount)
        returns (bool)
    {

        require(amount >= _getAmount(1), "NFTYStaking: min stake amount is 1");
        require(
            nftyToken.balanceOf(_msgSender()) >= amount,
            "NFTYStaking: insufficient balance"
        );

        StakeData storage stakeData = StakersData[_msgSender()];

        uint256 _amount = stakeData.amount;

        if (_amount > 0) {
            uint256 reward = _getReward(
                stakeData.stakingTime,
                stakeData.lastClaimTime,
                _amount
            );

            stakeData.reward += reward;
            stakeData.amount = _amount + amount;

            emit StakeUpgraded(_msgSender(), amount, stakeData.amount);
        } else {
            stakeData.amount = amount;
            stakeData.stakingTime = block.timestamp;

            emit NewStake(_msgSender(), amount);
        }

        stakeData.lastClaimTime = block.timestamp;

        _totalStakedToken += amount;

        bool result = nftyToken.transferFrom(
            _msgSender(),
            address(this),
            amount
        );
        return result;
    }

    function claimRewards()
        external
        isRealAddress(_msgSender())
        isStaker(_msgSender())
    {

        require(
            nftyToken.owner() == address(this),
            "Staking contract is not the owner."
        );

        StakeData storage stakeData = StakersData[_msgSender()];
        uint256 _amount = stakeData.amount;

        uint256 reward = _getReward(
            stakeData.stakingTime,
            stakeData.lastClaimTime,
            _amount
        );
        reward = stakeData.reward + reward;

        stakeData.reward = 0;
        stakeData.lastClaimTime = block.timestamp;

        emit RewardReleased(_msgSender(), reward);

        nftyToken.mint(_msgSender(), reward);
    }

    function showReward(address account)
        external
        view
        isRealAddress(_msgSender())
        isRealAddress(account)
        isStaker(account)
        returns (uint256)
    {

        StakeData storage stakeData = StakersData[account];
        uint256 _amount = stakeData.amount;

        uint256 reward = _getReward(
            stakeData.stakingTime,
            stakeData.lastClaimTime,
            _amount
        );
        reward = stakeData.reward + reward;

        return reward;
    }

    function unstakeAll() external {

        StakeData storage stakeData = StakersData[_msgSender()];
        uint256 amount = stakeData.amount;

        unstakeTokens(amount);
    }

    function changeRate(uint8 rank, uint256 rate)
        external
        onlyRole(ADMIN_ROLE)
    {

        require(rate > 0 && rate <= 100000, "NFTYStaking: invalid rate");
        require(rank < 6, "NFTYStaking: invalid rank");

        uint256 oldRate = _rewardRate[rank];
        _rewardRate[rank] = rate;

        emit RateChanged(_msgSender(), rank, oldRate, rate);
    }

    function getRewardRates() external view returns (uint256[6] memory) {

        return _rewardRate;
    }

    function getPool() external view returns (uint256) {

        return _totalStakedToken;
    }

    function getRewardRate(uint256 amount, uint256 stakingTime)
        public
        view
        returns (uint256 rewardRate)
    {

        uint256 rewardRate1;
        uint256 rewardRate2;
        stakingTime = block.timestamp - stakingTime;

        if (amount >= _getAmount(1) && amount < _getAmount(500)) {
            rewardRate1 = _rewardRate[0];
        } else if (amount >= _getAmount(500) && amount < _getAmount(10000)) {
            rewardRate1 = _rewardRate[1];
        } else if (amount >= _getAmount(10000) && amount < _getAmount(25000)) {
            rewardRate1 = _rewardRate[2];
        } else if (amount >= _getAmount(25000) && amount < _getAmount(50000)) {
            rewardRate1 = _rewardRate[3];
        } else if (amount >= _getAmount(50000) && amount < _getAmount(100000)) {
            rewardRate1 = _rewardRate[4];
        } else {
            rewardRate1 = _rewardRate[5];
        }

        if (stakingTime < 30 days) {
            rewardRate2 = _rewardRate[0];
        } else if (stakingTime >= 30 days && stakingTime < 45 days) {
            rewardRate2 = _rewardRate[1];
        } else if (stakingTime >= 45 days && stakingTime < 90 days) {
            rewardRate2 = _rewardRate[2];
        } else if (stakingTime >= 90 days && stakingTime < 180 days) {
            rewardRate2 = _rewardRate[3];
        } else if (stakingTime >= 180 days && stakingTime < 365 days) {
            rewardRate2 = _rewardRate[4];
        } else {
            rewardRate2 = _rewardRate[5];
        }

        rewardRate = rewardRate1 < rewardRate2 ? rewardRate1 : rewardRate2;
    }

    function unstakeTokens(uint256 amount)
        public
        isRealAddress(_msgSender())
        isRealValue(amount)
        isStaker(_msgSender())
    {

        require(
            nftyToken.owner() == address(this),
            "Staking contract is not the owner."
        );

        StakeData storage stakeData = StakersData[_msgSender()];
        uint256 _amount = stakeData.amount;

        require(_amount >= amount, "NFTYStaking: not enough staked token");

        uint256 reward = _getReward(
            stakeData.stakingTime,
            stakeData.lastClaimTime,
            _amount
        );

        if (stakeData.amount == amount) {
            uint256 totReward = reward + stakeData.reward;

            stakeData.reward = 0;
            stakeData.stakingTime = 0;

            emit RewardReleased(_msgSender(), totReward);

            nftyToken.mint(_msgSender(), totReward);
        } else {
            stakeData.reward += reward;
        }

        stakeData.amount -= amount;
        stakeData.lastClaimTime = block.timestamp;

        _totalStakedToken -= amount;

        emit StakeReleased(_msgSender(), amount, stakeData.amount);

        nftyToken.transfer(_msgSender(), amount);
    }

    function _getReward(
        uint256 stakingTime,
        uint256 lastClaimTime,
        uint256 amount
    ) internal view returns (uint256 reward) {

        uint256 rewardRate = getRewardRate(amount, stakingTime);
        uint256 rewardTime = block.timestamp - lastClaimTime;
        uint256 rateForSecond = (rewardRate * 10**18) / 365 days;

        reward = (amount * rateForSecond * rewardTime) / 10**23;

        return reward;
    }

    function _getAmount(uint256 value) internal view returns (uint256) {

        return value * 10**uint256(nftyToken.decimals());
    }
}