
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


contract TokenSplitter is Ownable, ReentrancyGuard {

    using SafeERC20 for IERC20;

    struct AccountInfo {
        uint256 shares;
        uint256 tokensDistributedToAccount;
    }

    uint256 public immutable TOTAL_SHARES;

    IERC20 public immutable x2y2Token;

    uint256 public totalTokensDistributed;

    mapping(address => AccountInfo) public accountInfo;

    event NewSharesOwner(address indexed oldRecipient, address indexed newRecipient);
    event TokensTransferred(address indexed account, uint256 amount);

    constructor(
        address[] memory _accounts,
        uint256[] memory _shares,
        address _x2y2Token
    ) {
        require(_accounts.length == _shares.length, 'Splitter: Length differ');
        require(_accounts.length > 0, 'Splitter: Length must be > 0');

        uint256 currentShares;

        for (uint256 i = 0; i < _accounts.length; i++) {
            require(_shares[i] > 0, 'Splitter: Shares are 0');

            currentShares += _shares[i];
            accountInfo[_accounts[i]].shares = _shares[i];
        }

        TOTAL_SHARES = currentShares;
        x2y2Token = IERC20(_x2y2Token);
    }

    function releaseTokens(address account) external nonReentrant {

        require(accountInfo[account].shares > 0, 'Splitter: Account has no share');

        uint256 totalTokensReceived = x2y2Token.balanceOf(address(this)) + totalTokensDistributed;
        uint256 pendingRewards = ((totalTokensReceived * accountInfo[account].shares) /
            TOTAL_SHARES) - accountInfo[account].tokensDistributedToAccount;

        require(pendingRewards != 0, 'Splitter: Nothing to transfer');

        accountInfo[account].tokensDistributedToAccount += pendingRewards;
        totalTokensDistributed += pendingRewards;

        x2y2Token.safeTransfer(account, pendingRewards);

        emit TokensTransferred(account, pendingRewards);
    }

    function updateSharesOwner(address _newRecipient, address _currentRecipient)
        external
        onlyOwner
    {

        require(
            accountInfo[_currentRecipient].shares > 0,
            'Owner: Current recipient has no shares'
        );
        require(accountInfo[_newRecipient].shares == 0, 'Owner: New recipient has existing shares');

        accountInfo[_newRecipient].shares = accountInfo[_currentRecipient].shares;
        accountInfo[_newRecipient].tokensDistributedToAccount = accountInfo[_currentRecipient]
            .tokensDistributedToAccount;

        accountInfo[_currentRecipient].shares = 0;
        accountInfo[_currentRecipient].tokensDistributedToAccount = 0;

        emit NewSharesOwner(_currentRecipient, _newRecipient);
    }

    function calculatePendingRewards(address account) external view returns (uint256) {

        if (accountInfo[account].shares == 0) {
            return 0;
        }

        uint256 totalTokensReceived = x2y2Token.balanceOf(address(this)) + totalTokensDistributed;
        uint256 pendingRewards = ((totalTokensReceived * accountInfo[account].shares) /
            TOTAL_SHARES) - accountInfo[account].tokensDistributedToAccount;

        return pendingRewards;
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


interface IMintableERC20 is IERC20 {

    function SUPPLY_CAP() external view returns (uint256);


    function mint(address account, uint256 amount) external returns (bool);

}// MIT
pragma solidity ^0.8.0;



contract TokenDistributor is ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeERC20 for IMintableERC20;

    struct StakingPeriod {
        uint256 rewardPerBlockForStaking;
        uint256 rewardPerBlockForOthers;
        uint256 periodLengthInBlock;
    }

    struct UserInfo {
        uint256 amount; // Amount of staked tokens provided by user
        uint256 rewardDebt; // Reward debt
    }

    uint256 public constant PRECISION_FACTOR = 10**12;

    IMintableERC20 public immutable x2y2Token;

    address public immutable tokenSplitter;

    uint256 public immutable NUMBER_PERIODS;

    uint256 public immutable START_BLOCK;

    uint256 public accTokenPerShare;

    uint256 public currentPhase;

    uint256 public endBlock;

    uint256 public lastRewardBlock;

    uint256 public rewardPerBlockForOthers;

    uint256 public rewardPerBlockForStaking;

    uint256 public totalAmountStaked;

    mapping(uint256 => StakingPeriod) public stakingPeriod;

    mapping(address => UserInfo) public userInfo;

    event Compound(address indexed user, uint256 harvestedAmount);
    event Deposit(address indexed user, uint256 amount, uint256 harvestedAmount);
    event NewRewardsPerBlock(
        uint256 indexed currentPhase,
        uint256 startBlock,
        uint256 rewardPerBlockForStaking,
        uint256 rewardPerBlockForOthers
    );
    event Withdraw(address indexed user, uint256 amount, uint256 harvestedAmount);

    constructor(
        address _x2y2Token,
        address _tokenSplitter,
        uint256 _startBlock,
        uint256[] memory _rewardsPerBlockForStaking,
        uint256[] memory _rewardsPerBlockForOthers,
        uint256[] memory _periodLengthesInBlocks,
        uint256 _numberPeriods
    ) {
        require(
            (_periodLengthesInBlocks.length == _numberPeriods) &&
                (_rewardsPerBlockForStaking.length == _numberPeriods) &&
                (_rewardsPerBlockForStaking.length == _numberPeriods),
            'Distributor: Lengthes must match numberPeriods'
        );

        uint256 nonCirculatingSupply = IMintableERC20(_x2y2Token).SUPPLY_CAP() -
            IMintableERC20(_x2y2Token).totalSupply();

        uint256 amountTokensToBeMinted;

        for (uint256 i = 0; i < _numberPeriods; i++) {
            amountTokensToBeMinted +=
                (_rewardsPerBlockForStaking[i] * _periodLengthesInBlocks[i]) +
                (_rewardsPerBlockForOthers[i] * _periodLengthesInBlocks[i]);

            stakingPeriod[i] = StakingPeriod({
                rewardPerBlockForStaking: _rewardsPerBlockForStaking[i],
                rewardPerBlockForOthers: _rewardsPerBlockForOthers[i],
                periodLengthInBlock: _periodLengthesInBlocks[i]
            });
        }

        require(
            amountTokensToBeMinted == nonCirculatingSupply,
            'Distributor: Wrong reward parameters'
        );

        x2y2Token = IMintableERC20(_x2y2Token);
        tokenSplitter = _tokenSplitter;
        rewardPerBlockForStaking = _rewardsPerBlockForStaking[0];
        rewardPerBlockForOthers = _rewardsPerBlockForOthers[0];

        START_BLOCK = _startBlock;
        endBlock = _startBlock + _periodLengthesInBlocks[0];

        NUMBER_PERIODS = _numberPeriods;

        lastRewardBlock = _startBlock;
    }

    function deposit(uint256 amount) external nonReentrant {

        require(amount > 0, 'Deposit: Amount must be > 0');
        require(block.number >= START_BLOCK, 'Deposit: Not started yet');

        _updatePool();

        x2y2Token.safeTransferFrom(msg.sender, address(this), amount);

        uint256 pendingRewards;

        if (userInfo[msg.sender].amount > 0) {
            pendingRewards =
                ((userInfo[msg.sender].amount * accTokenPerShare) / PRECISION_FACTOR) -
                userInfo[msg.sender].rewardDebt;
        }

        userInfo[msg.sender].amount += (amount + pendingRewards);
        userInfo[msg.sender].rewardDebt =
            (userInfo[msg.sender].amount * accTokenPerShare) /
            PRECISION_FACTOR;

        totalAmountStaked += (amount + pendingRewards);

        emit Deposit(msg.sender, amount, pendingRewards);
    }

    function harvestAndCompound() external nonReentrant {

        _updatePool();

        uint256 pendingRewards = ((userInfo[msg.sender].amount * accTokenPerShare) /
            PRECISION_FACTOR) - userInfo[msg.sender].rewardDebt;

        if (pendingRewards == 0) {
            return;
        }

        userInfo[msg.sender].amount += pendingRewards;

        totalAmountStaked += pendingRewards;

        userInfo[msg.sender].rewardDebt =
            (userInfo[msg.sender].amount * accTokenPerShare) /
            PRECISION_FACTOR;

        emit Compound(msg.sender, pendingRewards);
    }

    function updatePool() external nonReentrant {

        _updatePool();
    }

    function withdraw(uint256 amount) external nonReentrant {

        require(
            (userInfo[msg.sender].amount >= amount) && (amount > 0),
            'Withdraw: Amount must be > 0 or lower than user balance'
        );

        _updatePool();

        uint256 pendingRewards = ((userInfo[msg.sender].amount * accTokenPerShare) /
            PRECISION_FACTOR) - userInfo[msg.sender].rewardDebt;

        userInfo[msg.sender].amount = userInfo[msg.sender].amount + pendingRewards - amount;
        userInfo[msg.sender].rewardDebt =
            (userInfo[msg.sender].amount * accTokenPerShare) /
            PRECISION_FACTOR;

        totalAmountStaked = totalAmountStaked + pendingRewards - amount;

        x2y2Token.safeTransfer(msg.sender, amount);

        emit Withdraw(msg.sender, amount, pendingRewards);
    }

    function withdrawAll() external nonReentrant {

        require(userInfo[msg.sender].amount > 0, 'Withdraw: Amount must be > 0');

        _updatePool();

        uint256 pendingRewards = ((userInfo[msg.sender].amount * accTokenPerShare) /
            PRECISION_FACTOR) - userInfo[msg.sender].rewardDebt;

        uint256 amountToTransfer = userInfo[msg.sender].amount + pendingRewards;

        totalAmountStaked = totalAmountStaked - userInfo[msg.sender].amount;

        userInfo[msg.sender].amount = 0;
        userInfo[msg.sender].rewardDebt = 0;

        x2y2Token.safeTransfer(msg.sender, amountToTransfer);

        emit Withdraw(msg.sender, amountToTransfer, pendingRewards);
    }

    function calculatePendingRewards(address user) external view returns (uint256) {

        if ((block.number > lastRewardBlock) && (totalAmountStaked != 0)) {
            uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);

            uint256 tokenRewardForStaking = multiplier * rewardPerBlockForStaking;

            uint256 adjustedEndBlock = endBlock;
            uint256 adjustedCurrentPhase = currentPhase;

            while (
                (block.number > adjustedEndBlock) && (adjustedCurrentPhase < (NUMBER_PERIODS - 1))
            ) {
                adjustedCurrentPhase++;

                uint256 adjustedRewardPerBlockForStaking = stakingPeriod[adjustedCurrentPhase]
                    .rewardPerBlockForStaking;

                uint256 previousEndBlock = adjustedEndBlock;

                adjustedEndBlock =
                    previousEndBlock +
                    stakingPeriod[adjustedCurrentPhase].periodLengthInBlock;

                uint256 newMultiplier = (block.number <= adjustedEndBlock)
                    ? (block.number - previousEndBlock)
                    : stakingPeriod[adjustedCurrentPhase].periodLengthInBlock;

                tokenRewardForStaking += (newMultiplier * adjustedRewardPerBlockForStaking);
            }

            uint256 adjustedTokenPerShare = accTokenPerShare +
                (tokenRewardForStaking * PRECISION_FACTOR) /
                totalAmountStaked;

            return
                (userInfo[user].amount * adjustedTokenPerShare) /
                PRECISION_FACTOR -
                userInfo[user].rewardDebt;
        } else {
            return
                (userInfo[user].amount * accTokenPerShare) /
                PRECISION_FACTOR -
                userInfo[user].rewardDebt;
        }
    }

    function _updatePool() internal {

        if (block.number <= lastRewardBlock) {
            return;
        }

        if (totalAmountStaked == 0) {
            lastRewardBlock = block.number;
            return;
        }

        uint256 multiplier = _getMultiplier(lastRewardBlock, block.number);

        uint256 tokenRewardForStaking = multiplier * rewardPerBlockForStaking;
        uint256 tokenRewardForOthers = multiplier * rewardPerBlockForOthers;

        while ((block.number > endBlock) && (currentPhase < (NUMBER_PERIODS - 1))) {
            _updateRewardsPerBlock(endBlock);

            uint256 previousEndBlock = endBlock;

            endBlock += stakingPeriod[currentPhase].periodLengthInBlock;

            uint256 newMultiplier = _getMultiplier(previousEndBlock, block.number);

            tokenRewardForStaking += (newMultiplier * rewardPerBlockForStaking);
            tokenRewardForOthers += (newMultiplier * rewardPerBlockForOthers);
        }

        if (tokenRewardForStaking > 0) {
            bool mintStatus = x2y2Token.mint(address(this), tokenRewardForStaking);
            if (mintStatus) {
                accTokenPerShare =
                    accTokenPerShare +
                    ((tokenRewardForStaking * PRECISION_FACTOR) / totalAmountStaked);
            }

            x2y2Token.mint(tokenSplitter, tokenRewardForOthers);
        }

        if (lastRewardBlock <= endBlock) {
            lastRewardBlock = block.number;
        }
    }

    function _updateRewardsPerBlock(uint256 _newStartBlock) internal {

        currentPhase++;

        rewardPerBlockForStaking = stakingPeriod[currentPhase].rewardPerBlockForStaking;
        rewardPerBlockForOthers = stakingPeriod[currentPhase].rewardPerBlockForOthers;

        emit NewRewardsPerBlock(
            currentPhase,
            _newStartBlock,
            rewardPerBlockForStaking,
            rewardPerBlockForOthers
        );
    }

    function _getMultiplier(uint256 from, uint256 to) internal view returns (uint256) {

        if (to <= endBlock) {
            return to - from;
        } else if (from >= endBlock) {
            return 0;
        } else {
            return endBlock - from;
        }
    }
}// MIT
pragma solidity ^0.8.0;

interface IStakeFor {

    function depositFor(address user, uint256 amount) external returns (bool);

}// MIT
pragma solidity ^0.8.0;



contract FeeSharingSystem is ReentrancyGuard, AccessControl, IStakeFor {

    using SafeERC20 for IERC20;

    bytes32 public constant DEPOSIT_ROLE = keccak256('DEPOSIT_ROLE');

    bytes32 public constant REWARD_UPDATE_ROLE = keccak256('REWARD_UPDATE_ROLE');

    struct UserInfo {
        uint256 shares; // shares of token staked
        uint256 userRewardPerTokenPaid; // user reward per token paid
        uint256 rewards; // pending rewards
    }

    uint256 public constant PRECISION_FACTOR = 10**18;

    IERC20 public immutable x2y2Token;

    IERC20 public immutable rewardToken;

    TokenDistributor public immutable tokenDistributor;

    uint256 public currentRewardPerBlock;

    uint256 public lastRewardAdjustment;

    uint256 public lastUpdateBlock;

    uint256 public periodEndBlock;

    uint256 public rewardPerTokenStored;

    uint256 public totalShares;

    mapping(address => UserInfo) public userInfo;

    event Deposit(address indexed user, uint256 amount, uint256 harvestedAmount);
    event Harvest(address indexed user, uint256 harvestedAmount);
    event NewRewardPeriod(uint256 numberBlocks, uint256 rewardPerBlock, uint256 reward);
    event Withdraw(address indexed user, uint256 amount, uint256 harvestedAmount);

    constructor(
        address _x2y2Token,
        address _rewardToken,
        address _tokenDistributor
    ) {
        rewardToken = IERC20(_rewardToken);
        x2y2Token = IERC20(_x2y2Token);
        tokenDistributor = TokenDistributor(_tokenDistributor);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function depositFor(address user, uint256 amount)
        external
        override
        nonReentrant
        onlyRole(DEPOSIT_ROLE)
        returns (bool)
    {

        require(amount >= PRECISION_FACTOR, 'Deposit: Amount must be >= 1 X2Y2');

        tokenDistributor.harvestAndCompound();

        _updateReward(user);

        (uint256 totalAmountStaked, ) = tokenDistributor.userInfo(address(this));

        x2y2Token.safeTransferFrom(msg.sender, address(this), amount);

        uint256 currentShares;

        if (totalShares != 0) {
            currentShares = (amount * totalShares) / totalAmountStaked;
            require(currentShares != 0, 'Deposit: Fail');
        } else {
            currentShares = amount;
        }

        userInfo[user].shares += currentShares;
        totalShares += currentShares;

        _checkAndAdjustX2Y2TokenAllowanceIfRequired(amount, address(tokenDistributor));

        tokenDistributor.deposit(amount);

        emit Deposit(user, amount, 0);

        return true;
    }

    function deposit(uint256 amount, bool claimRewardToken) external nonReentrant {

        require(amount >= PRECISION_FACTOR, 'Deposit: Amount must be >= 1 X2Y2');

        tokenDistributor.harvestAndCompound();

        _updateReward(msg.sender);

        (uint256 totalAmountStaked, ) = tokenDistributor.userInfo(address(this));

        x2y2Token.safeTransferFrom(msg.sender, address(this), amount);

        uint256 currentShares;

        if (totalShares != 0) {
            currentShares = (amount * totalShares) / totalAmountStaked;
            require(currentShares != 0, 'Deposit: Fail');
        } else {
            currentShares = amount;
        }

        userInfo[msg.sender].shares += currentShares;
        totalShares += currentShares;

        uint256 pendingRewards;

        if (claimRewardToken) {
            pendingRewards = userInfo[msg.sender].rewards;

            if (pendingRewards > 0) {
                userInfo[msg.sender].rewards = 0;
                rewardToken.safeTransfer(msg.sender, pendingRewards);
            }
        }

        _checkAndAdjustX2Y2TokenAllowanceIfRequired(amount, address(tokenDistributor));

        tokenDistributor.deposit(amount);

        emit Deposit(msg.sender, amount, pendingRewards);
    }

    function harvest() external nonReentrant {

        tokenDistributor.harvestAndCompound();

        _updateReward(msg.sender);

        uint256 pendingRewards = userInfo[msg.sender].rewards;

        require(pendingRewards > 0, 'Harvest: Pending rewards must be > 0');

        userInfo[msg.sender].rewards = 0;

        rewardToken.safeTransfer(msg.sender, pendingRewards);

        emit Harvest(msg.sender, pendingRewards);
    }

    function withdraw(uint256 shares, bool claimRewardToken) external nonReentrant {

        require(
            (shares > 0) && (shares <= userInfo[msg.sender].shares),
            'Withdraw: Shares equal to 0 or larger than user shares'
        );

        _withdraw(shares, claimRewardToken);
    }

    function withdrawAll(bool claimRewardToken) external nonReentrant {

        _withdraw(userInfo[msg.sender].shares, claimRewardToken);
    }

    function updateRewards(uint256 reward, uint256 rewardDurationInBlocks)
        external
        onlyRole(REWARD_UPDATE_ROLE)
    {

        if (block.number >= periodEndBlock) {
            currentRewardPerBlock = reward / rewardDurationInBlocks;
        } else {
            currentRewardPerBlock =
                (reward + ((periodEndBlock - block.number) * currentRewardPerBlock)) /
                rewardDurationInBlocks;
        }

        lastUpdateBlock = block.number;
        periodEndBlock = block.number + rewardDurationInBlocks;

        emit NewRewardPeriod(rewardDurationInBlocks, currentRewardPerBlock, reward);
    }

    function calculatePendingRewards(address user) external view returns (uint256) {

        return _calculatePendingRewards(user);
    }

    function calculateSharesValueInX2Y2(address user) external view returns (uint256) {

        (uint256 totalAmountStaked, ) = tokenDistributor.userInfo(address(this));

        totalAmountStaked += tokenDistributor.calculatePendingRewards(address(this));

        return
            userInfo[user].shares == 0
                ? 0
                : (totalAmountStaked * userInfo[user].shares) / totalShares;
    }

    function calculateSharePriceInX2Y2() external view returns (uint256) {

        (uint256 totalAmountStaked, ) = tokenDistributor.userInfo(address(this));

        totalAmountStaked += tokenDistributor.calculatePendingRewards(address(this));

        return
            totalShares == 0
                ? PRECISION_FACTOR
                : (totalAmountStaked * PRECISION_FACTOR) / (totalShares);
    }

    function lastRewardBlock() external view returns (uint256) {

        return _lastRewardBlock();
    }

    function _calculatePendingRewards(address user) internal view returns (uint256) {

        return
            ((userInfo[user].shares *
                (_rewardPerToken() - (userInfo[user].userRewardPerTokenPaid))) / PRECISION_FACTOR) +
            userInfo[user].rewards;
    }

    function _checkAndAdjustX2Y2TokenAllowanceIfRequired(uint256 _amount, address _to) internal {

        if (x2y2Token.allowance(address(this), _to) < _amount) {
            x2y2Token.approve(_to, type(uint256).max);
        }
    }

    function _lastRewardBlock() internal view returns (uint256) {

        return block.number < periodEndBlock ? block.number : periodEndBlock;
    }

    function _rewardPerToken() internal view returns (uint256) {

        if (totalShares == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored +
            ((_lastRewardBlock() - lastUpdateBlock) * (currentRewardPerBlock * PRECISION_FACTOR)) /
            totalShares;
    }

    function _updateReward(address _user) internal {

        if (block.number != lastUpdateBlock) {
            rewardPerTokenStored = _rewardPerToken();
            lastUpdateBlock = _lastRewardBlock();
        }

        userInfo[_user].rewards = _calculatePendingRewards(_user);
        userInfo[_user].userRewardPerTokenPaid = rewardPerTokenStored;
    }

    function _withdraw(uint256 shares, bool claimRewardToken) internal {

        tokenDistributor.harvestAndCompound();

        _updateReward(msg.sender);

        (uint256 totalAmountStaked, ) = tokenDistributor.userInfo(address(this));
        uint256 currentAmount = (totalAmountStaked * shares) / totalShares;

        userInfo[msg.sender].shares -= shares;
        totalShares -= shares;

        tokenDistributor.withdraw(currentAmount);

        uint256 pendingRewards;

        if (claimRewardToken) {
            pendingRewards = userInfo[msg.sender].rewards;

            if (pendingRewards > 0) {
                userInfo[msg.sender].rewards = 0;
                rewardToken.safeTransfer(msg.sender, pendingRewards);
            }
        }

        x2y2Token.safeTransfer(msg.sender, currentAmount);

        emit Withdraw(msg.sender, currentAmount, pendingRewards);
    }
}// MIT
pragma solidity ^0.8.0;

interface IRewardConvertor {

    function convert(
        address tokenToSell,
        address tokenToBuy,
        uint256 amount,
        bytes calldata additionalData
    ) external returns (uint256);

}// MIT
pragma solidity ^0.8.0;

interface ITokenStaked {

    function getTotalStaked() external view returns (uint256);

}// MIT
pragma solidity ^0.8.0;





contract FeeSharingSetter is ReentrancyGuard, AccessControl {

    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    bytes32 public constant OPERATOR_ROLE = keccak256('OPERATOR_ROLE');

    uint256 public immutable MIN_REWARD_DURATION_IN_BLOCKS;

    uint256 public immutable MAX_REWARD_DURATION_IN_BLOCKS;

    IERC20 public immutable x2y2Token;

    IERC20 public immutable rewardToken;

    FeeSharingSystem public feeSharingSystem;

    TokenDistributor public immutable tokenDistributor;

    IRewardConvertor public rewardConvertor;

    uint256 public lastRewardDistributionBlock;

    uint256 public nextRewardDurationInBlocks;

    uint256 public rewardDurationInBlocks;

    EnumerableSet.AddressSet private _feeStakingAddresses;
    mapping(address => bool) public feeStakingAddressIStaked;

    event ConversionToRewardToken(
        address indexed token,
        uint256 amountConverted,
        uint256 amountReceived
    );
    event FeeStakingAddressesAdded(address[] feeStakingAddresses);
    event FeeStakingAddressesRemoved(address[] feeStakingAddresses);
    event NewRewardDurationInBlocks(uint256 rewardDurationInBlocks);
    event NewRewardConvertor(address rewardConvertor);

    constructor(
        address _feeSharingSystem,
        uint256 _minRewardDurationInBlocks,
        uint256 _maxRewardDurationInBlocks,
        uint256 _rewardDurationInBlocks
    ) {
        require(
            (_rewardDurationInBlocks <= _maxRewardDurationInBlocks) &&
                (_rewardDurationInBlocks >= _minRewardDurationInBlocks),
            'Owner: Reward duration in blocks outside of range'
        );

        MIN_REWARD_DURATION_IN_BLOCKS = _minRewardDurationInBlocks;
        MAX_REWARD_DURATION_IN_BLOCKS = _maxRewardDurationInBlocks;

        feeSharingSystem = FeeSharingSystem(_feeSharingSystem);

        rewardToken = feeSharingSystem.rewardToken();
        x2y2Token = feeSharingSystem.x2y2Token();
        tokenDistributor = feeSharingSystem.tokenDistributor();

        rewardDurationInBlocks = _rewardDurationInBlocks;
        nextRewardDurationInBlocks = _rewardDurationInBlocks;

        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function updateRewards() external onlyRole(OPERATOR_ROLE) {

        if (lastRewardDistributionBlock > 0) {
            require(
                block.number > (rewardDurationInBlocks + lastRewardDistributionBlock),
                'Reward: Too early to add'
            );
        }

        if (rewardDurationInBlocks != nextRewardDurationInBlocks) {
            rewardDurationInBlocks = nextRewardDurationInBlocks;
        }

        lastRewardDistributionBlock = block.number;

        uint256 reward = rewardToken.balanceOf(address(this));

        require(reward != 0, 'Reward: Nothing to distribute');

        uint256 numberAddressesForFeeStaking = _feeStakingAddresses.length();

        if (numberAddressesForFeeStaking > 0) {
            uint256[] memory x2y2Balances = new uint256[](numberAddressesForFeeStaking);
            (uint256 totalAmountStaked, ) = tokenDistributor.userInfo(address(feeSharingSystem));

            for (uint256 i = 0; i < numberAddressesForFeeStaking; i++) {
                address a = _feeStakingAddresses.at(i);
                uint256 balance = x2y2Token.balanceOf(a);
                if (feeStakingAddressIStaked[a]) {
                    balance = ITokenStaked(a).getTotalStaked();
                }
                totalAmountStaked += balance;
                x2y2Balances[i] = balance;
            }

            if (totalAmountStaked > 0) {
                uint256 adjustedReward = reward;

                for (uint256 i = 0; i < numberAddressesForFeeStaking; i++) {
                    uint256 amountToTransfer = (x2y2Balances[i] * reward) / totalAmountStaked;
                    if (amountToTransfer > 0) {
                        adjustedReward -= amountToTransfer;
                        rewardToken.safeTransfer(_feeStakingAddresses.at(i), amountToTransfer);
                    }
                }

                reward = adjustedReward;
            }
        }

        rewardToken.safeTransfer(address(feeSharingSystem), reward);

        feeSharingSystem.updateRewards(reward, rewardDurationInBlocks);
    }

    function convertCurrencyToRewardToken(address token, bytes calldata additionalData)
        external
        nonReentrant
        onlyRole(OPERATOR_ROLE)
    {

        require(address(rewardConvertor) != address(0), 'Convert: RewardConvertor not set');
        require(token != address(rewardToken), 'Convert: Cannot be reward token');

        uint256 amountToConvert = IERC20(token).balanceOf(address(this));
        require(amountToConvert != 0, 'Convert: Amount to convert must be > 0');

        IERC20(token).safeIncreaseAllowance(address(rewardConvertor), amountToConvert);

        uint256 amountReceived = rewardConvertor.convert(
            token,
            address(rewardToken),
            amountToConvert,
            additionalData
        );

        emit ConversionToRewardToken(token, amountToConvert, amountReceived);
    }

    function addFeeStakingAddresses(
        address[] calldata _stakingAddresses,
        bool[] calldata _addressIStaked
    ) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(_stakingAddresses.length == _addressIStaked.length, 'Owner: param length error');
        for (uint256 i = 0; i < _stakingAddresses.length; i++) {
            require(
                !_feeStakingAddresses.contains(_stakingAddresses[i]),
                'Owner: Address already registered'
            );
            _feeStakingAddresses.add(_stakingAddresses[i]);
            if (_addressIStaked[i]) {
                feeStakingAddressIStaked[_stakingAddresses[i]] = true;
            }
        }

        emit FeeStakingAddressesAdded(_stakingAddresses);
    }

    function removeFeeStakingAddresses(address[] calldata _stakingAddresses)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        for (uint256 i = 0; i < _stakingAddresses.length; i++) {
            require(
                _feeStakingAddresses.contains(_stakingAddresses[i]),
                'Owner: Address not registered'
            );
            _feeStakingAddresses.remove(_stakingAddresses[i]);
            if (feeStakingAddressIStaked[_stakingAddresses[i]]) {
                delete feeStakingAddressIStaked[_stakingAddresses[i]];
            }
        }

        emit FeeStakingAddressesRemoved(_stakingAddresses);
    }

    function setNewRewardDurationInBlocks(uint256 _newRewardDurationInBlocks)
        external
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(
            (_newRewardDurationInBlocks <= MAX_REWARD_DURATION_IN_BLOCKS) &&
                (_newRewardDurationInBlocks >= MIN_REWARD_DURATION_IN_BLOCKS),
            'Owner: New reward duration in blocks outside of range'
        );

        nextRewardDurationInBlocks = _newRewardDurationInBlocks;

        emit NewRewardDurationInBlocks(_newRewardDurationInBlocks);
    }

    function setRewardConvertor(address _rewardConvertor) external onlyRole(DEFAULT_ADMIN_ROLE) {

        rewardConvertor = IRewardConvertor(_rewardConvertor);

        emit NewRewardConvertor(_rewardConvertor);
    }

    function viewFeeStakingAddresses() external view returns (address[] memory) {

        uint256 length = _feeStakingAddresses.length();

        address[] memory feeStakingAddresses = new address[](length);

        for (uint256 i = 0; i < length; i++) {
            feeStakingAddresses[i] = _feeStakingAddresses.at(i);
        }

        return (feeStakingAddresses);
    }
}// Unlicensed

pragma solidity ^0.8.0;
pragma abicoder v2;


interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256 wad) external;

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


contract FeeManagement is AccessControl, Pausable, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;

    bytes32 public constant OPERATOR_ROLE = keccak256('OPERATOR_ROLE');

    TokenSplitter public immutable tokenSplitter;
    FeeSharingSetter public immutable feeSetter;
    IWETH public immutable weth;

    constructor(
        TokenSplitter tokenSplitter_,
        FeeSharingSetter feeSetter_,
        IWETH weth_,
        address operator_,
        address admin_
    ) {
        tokenSplitter = tokenSplitter_;
        feeSetter = feeSetter_;
        weth = weth_;

        if (admin_ == address(0)) {
            admin_ = msg.sender;
        }
        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(OPERATOR_ROLE, admin_);

        if (operator_ != address(0)) {
            _grantRole(OPERATOR_ROLE, operator_);
        }
    }

    receive() external payable {}

    function pause() external onlyRole(DEFAULT_ADMIN_ROLE) {

        _pause();
    }

    function unpause() external onlyRole(DEFAULT_ADMIN_ROLE) {

        _unpause();
    }

    function withdraw(address to, IERC20[] calldata tokens)
        external
        nonReentrant
        whenNotPaused
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        require(to != address(0), 'Withdraw: address(0) cannot be recipient');
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 currency = tokens[i];
            if (address(currency) == address(0)) {
                uint256 balance = address(this).balance;
                if (balance > 0) {
                    Address.sendValue(payable(to), balance);
                }
            } else {
                uint256 balance = currency.balanceOf(address(this));
                if (balance > 0) {
                    currency.safeTransfer(to, balance);
                }
            }
        }
    }

    function canRelease() external view returns (bool) {

        return
            block.number >
            feeSetter.rewardDurationInBlocks() + feeSetter.lastRewardDistributionBlock();
    }

    function releaseAndUpdateReward(IERC20[] memory tokens, address[] memory accounts)
        external
        nonReentrant
        whenNotPaused
        onlyRole(OPERATOR_ROLE)
    {

        _release(tokens);

        if (tokenSplitter.x2y2Token().balanceOf(address(tokenSplitter)) >= 1 ether) {
            for (uint256 i = 0; i < accounts.length; i++) {
                tokenSplitter.releaseTokens(accounts[i]);
            }
        }

        feeSetter.updateRewards();
    }

    function release(IERC20[] memory tokens)
        external
        nonReentrant
        whenNotPaused
        onlyRole(OPERATOR_ROLE)
    {

        _release(tokens);
    }

    function _release(IERC20[] memory tokens) internal {

        uint256 balance = address(this).balance;
        if (balance > 0) {
            weth.deposit{value: balance}();
        }
        balance = weth.balanceOf(address(this));
        if (balance > 0) {
            weth.safeTransfer(address(feeSetter), balance);
        }

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20 currency = tokens[i];
            balance = currency.balanceOf(address(this));
            if (balance > 0) {
                currency.safeTransfer(address(feeSetter), balance);
            }
        }
    }
}