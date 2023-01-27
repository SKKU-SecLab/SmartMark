
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity ^0.8.0;

interface IJoin {

    function asset() external view returns (address);


    function join(address user, uint128 wad) external returns (uint128);


    function exit(address user, uint128 wad) external returns (uint128);

}// MIT
pragma solidity ^0.8.0;

interface IFYToken is IERC20 {

    function underlying() external view returns (address);


    function join() external view returns (IJoin);


    function maturity() external view returns (uint256);


    function mature() external;


    function mintWithUnderlying(address to, uint256 amount) external;


    function redeem(address to, uint256 amount) external returns (uint256);


    function mint(address to, uint256 fyTokenAmount) external;


    function burn(address from, uint256 fyTokenAmount) external;

}// MIT
pragma solidity ^0.8.0;

interface IOracle {

    function peek(
        bytes32 base,
        bytes32 quote,
        uint256 amount
    ) external view returns (uint256 value, uint256 updateTime);


    function get(
        bytes32 base,
        bytes32 quote,
        uint256 amount
    ) external returns (uint256 value, uint256 updateTime);

}// MIT
pragma solidity ^0.8.0;

library DataTypes {

    struct Series {
        IFYToken fyToken; // Redeemable token for the series.
        bytes6 baseId; // Asset received on redemption.
        uint32 maturity; // Unix time at which redemption becomes possible.
    }

    struct Debt {
        uint96 max; // Maximum debt accepted for a given underlying, across all series
        uint24 min; // Minimum debt accepted for a given underlying, across all series
        uint8 dec; // Multiplying factor (10**dec) for max and min
        uint128 sum; // Current debt for a given underlying, across all series
    }

    struct SpotOracle {
        IOracle oracle; // Address for the spot price oracle
        uint32 ratio; // Collateralization ratio to multiply the price for
    }

    struct Vault {
        address owner;
        bytes6 seriesId; // Each vault is related to only one series, which also determines the underlying.
        bytes6 ilkId; // Asset accepted as collateral
    }

    struct Balances {
        uint128 art; // Debt amount
        uint128 ink; // Collateral amount
    }
}// MIT
pragma solidity ^0.8.0;

interface ICauldron {

    function lendingOracles(bytes6 baseId) external view returns (IOracle);


    function vaults(bytes12 vault)
        external
        view
        returns (DataTypes.Vault memory);


    function series(bytes6 seriesId)
        external
        view
        returns (DataTypes.Series memory);


    function assets(bytes6 assetsId) external view returns (address);


    function balances(bytes12 vault)
        external
        view
        returns (DataTypes.Balances memory);


    function debt(bytes6 baseId, bytes6 ilkId)
        external
        view
        returns (DataTypes.Debt memory);


    function spotOracles(bytes6 baseId, bytes6 ilkId)
        external
        returns (DataTypes.SpotOracle memory);


    function build(
        address owner,
        bytes12 vaultId,
        bytes6 seriesId,
        bytes6 ilkId
    ) external returns (DataTypes.Vault memory);


    function destroy(bytes12 vault) external;


    function tweak(
        bytes12 vaultId,
        bytes6 seriesId,
        bytes6 ilkId
    ) external returns (DataTypes.Vault memory);


    function give(bytes12 vaultId, address receiver)
        external
        returns (DataTypes.Vault memory);


    function stir(
        bytes12 from,
        bytes12 to,
        uint128 ink,
        uint128 art
    ) external returns (DataTypes.Balances memory, DataTypes.Balances memory);


    function pour(
        bytes12 vaultId,
        int128 ink,
        int128 art
    ) external returns (DataTypes.Balances memory);


    function roll(
        bytes12 vaultId,
        bytes6 seriesId,
        int128 art
    ) external returns (DataTypes.Vault memory, DataTypes.Balances memory);


    function slurp(
        bytes12 vaultId,
        uint128 ink,
        uint128 art
    ) external returns (DataTypes.Balances memory);



    function debtFromBase(bytes6 seriesId, uint128 base)
        external
        returns (uint128 art);


    function debtToBase(bytes6 seriesId, uint128 art)
        external
        returns (uint128 base);



    function mature(bytes6 seriesId) external;


    function accrual(bytes6 seriesId) external returns (uint256);


    function level(bytes12 vaultId) external returns (int256);

}// MIT

pragma solidity >=0.6.0;


library RevertMsgExtractor {

    function getRevertMsg(bytes memory returnData)
        internal pure
        returns (string memory)
    {

        if (returnData.length < 68) return "Transaction reverted silently";

        assembly {
            returnData := add(returnData, 0x04)
        }
        return abi.decode(returnData, (string)); // All that remains is the revert string
    }
}// MIT

pragma solidity >=0.6.0;



library TransferHelper {

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        if (!(success && (data.length == 0 || abi.decode(data, (bool))))) revert(RevertMsgExtractor.getRevertMsg(data));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        (bool success, bytes memory data) = address(token).call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        if (!(success && (data.length == 0 || abi.decode(data, (bool))))) revert(RevertMsgExtractor.getRevertMsg(data));
    }

    function safeTransferETH(address payable to, uint256 value) internal {

        (bool success, bytes memory data) = to.call{value: value}(new bytes(0));
        if (!success) revert(RevertMsgExtractor.getRevertMsg(data));
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


library CastU256U128 {

    function u128(uint256 x) internal pure returns (uint128 y) {

        require (x <= type(uint128).max, "Cast overflow");
        y = uint128(x);
    }
}// MIT
pragma solidity 0.8.6;

interface IRewardStaking {

    function stakeFor(address, uint256) external;

    function stake( uint256) external;

    function withdraw(uint256 amount, bool claim) external;

    function withdrawAndUnwrap(uint256 amount, bool claim) external;

    function earned(address account) external view returns (uint256);

    function getReward() external;

    function getReward(address _account, bool _claimExtras) external;

    function extraRewardsLength() external view returns (uint256);

    function extraRewards(uint256 _pid) external view returns (address);

    function rewardToken() external view returns (address);

    function balanceOf(address _account) external view returns (uint256);

}// MIT
pragma solidity 0.8.6;

interface ICvx {

    function reductionPerCliff() external view returns(uint256);

    function totalSupply() external view returns(uint256);

    function totalCliffs() external view returns(uint256);

    function maxSupply() external view returns(uint256);

}// MIT
pragma solidity 0.8.6;


library CvxMining {

    ICvx public constant cvx = ICvx(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);

    function ConvertCrvToCvx(uint256 _amount) internal view returns (uint256) {

        uint256 supply = cvx.totalSupply();
        uint256 reductionPerCliff = cvx.reductionPerCliff();
        uint256 totalCliffs = cvx.totalCliffs();
        uint256 maxSupply = cvx.maxSupply();

        uint256 cliff = supply / reductionPerCliff;
        if (cliff < totalCliffs) {
            uint256 reduction = totalCliffs - cliff;
            _amount = (_amount * reduction) / totalCliffs;

            uint256 amtTillMax = maxSupply - supply;
            if (_amount > amtTillMax) {
                _amount = amtTillMax;
            }

            return _amount;
        }
        return 0;
    }
}// MIT
pragma solidity >=0.6.0 <0.9.0;


interface IERC3156FlashBorrower {


    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);

}// MIT
pragma solidity >=0.6.0 <0.9.0;


interface IERC3156FlashLender {


    function maxFlashLoan(
        address token
    ) external view returns (uint256);


    function flashFee(
        address token,
        uint256 amount
    ) external view returns (uint256);


    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

}// MIT
pragma solidity ^0.8.0;

interface IJoinFactory {

    event JoinCreated(address indexed asset, address pool);

    function createJoin(address asset) external returns (address);

}// MIT

pragma solidity ^0.8.0;

contract AccessControl {

    struct RoleData {
        mapping (address => bool) members;
        bytes4 adminRole;
    }

    mapping (bytes4 => RoleData) private _roles;

    bytes4 public constant ROOT = 0x00000000;
    bytes4 public constant ROOT4146650865 = 0x00000000; // Collision protection for ROOT, test with ROOT12007226833()
    bytes4 public constant LOCK = 0xFFFFFFFF;           // Used to disable further permissioning of a function
    bytes4 public constant LOCK8605463013 = 0xFFFFFFFF; // Collision protection for LOCK, test with LOCK10462387368()

    event RoleAdminChanged(bytes4 indexed role, bytes4 indexed newAdminRole);

    event RoleGranted(bytes4 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes4 indexed role, address indexed account, address indexed sender);

    constructor () {
        _grantRole(ROOT, msg.sender);   // Grant ROOT to msg.sender
        _setRoleAdmin(LOCK, LOCK);      // Create the LOCK role by setting itself as its own admin, creating an independent role tree
    }

    modifier auth() {

        require (_hasRole(msg.sig, msg.sender), "Access denied");
        _;
    }

    modifier admin(bytes4 role) {

        require (_hasRole(_getRoleAdmin(role), msg.sender), "Only admin");
        _;
    }

    function hasRole(bytes4 role, address account) external view returns (bool) {

        return _hasRole(role, account);
    }

    function getRoleAdmin(bytes4 role) external view returns (bytes4) {

        return _getRoleAdmin(role);
    }

    function setRoleAdmin(bytes4 role, bytes4 adminRole) external virtual admin(role) {

        _setRoleAdmin(role, adminRole);
    }

    function grantRole(bytes4 role, address account) external virtual admin(role) {

        _grantRole(role, account);
    }

    
    function grantRoles(bytes4[] memory roles, address account) external virtual {

        for (uint256 i = 0; i < roles.length; i++) {
            require (_hasRole(_getRoleAdmin(roles[i]), msg.sender), "Only admin");
            _grantRole(roles[i], account);
        }
    }

    function lockRole(bytes4 role) external virtual admin(role) {

        _setRoleAdmin(role, LOCK);
    }

    function revokeRole(bytes4 role, address account) external virtual admin(role) {

        _revokeRole(role, account);
    }

    function revokeRoles(bytes4[] memory roles, address account) external virtual {

        for (uint256 i = 0; i < roles.length; i++) {
            require (_hasRole(_getRoleAdmin(roles[i]), msg.sender), "Only admin");
            _revokeRole(roles[i], account);
        }
    }

    function renounceRole(bytes4 role, address account) external virtual {

        require(account == msg.sender, "Renounce only for self");

        _revokeRole(role, account);
    }

    function _hasRole(bytes4 role, address account) internal view returns (bool) {

        return _roles[role].members[account];
    }

    function _getRoleAdmin(bytes4 role) internal view returns (bytes4) {

        return _roles[role].adminRole;
    }

    function _setRoleAdmin(bytes4 role, bytes4 adminRole) internal virtual {

        if (_getRoleAdmin(role) != adminRole) {
            _roles[role].adminRole = adminRole;
            emit RoleAdminChanged(role, adminRole);
        }
    }

    function _grantRole(bytes4 role, address account) internal {

        if (!_hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, msg.sender);
        }
    }

    function _revokeRole(bytes4 role, address account) internal {

        if (_hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, msg.sender);
        }
    }
}// BUSL-1.1
pragma solidity ^0.8.0;


library WMul {

    function wmul(uint256 x, uint256 y) internal pure returns (uint256 z) {

        z = x * y;
        unchecked { z /= 1e18; }
    }
}// BUSL-1.1
pragma solidity 0.8.6;


contract Join is IJoin, AccessControl {

    using TransferHelper for IERC20;
    using WMul for uint256;
    using CastU256U128 for uint256;

    address public immutable override asset;
    uint256 public storedBalance;

    constructor(address asset_) {
        asset = asset_;
    }

    function join(address user, uint128 amount) external virtual override auth returns (uint128) {

        return _join(user, amount);
    }

    function _join(address user, uint128 amount) internal returns (uint128) {

        IERC20 token = IERC20(asset);
        uint256 _storedBalance = storedBalance;
        uint256 available = token.balanceOf(address(this)) - _storedBalance; // Fine to panic if this underflows
        unchecked {
            storedBalance = _storedBalance + amount; // Unlikely that a uint128 added to the stored balance will make it overflow
            if (available < amount) token.safeTransferFrom(user, address(this), amount - available);
        }
        return amount;
    }

    function exit(address user, uint128 amount) external virtual override auth returns (uint128) {

        return _exit(user, amount);
    }

    function _exit(address user, uint128 amount) internal returns (uint128) {

        IERC20 token = IERC20(asset);
        storedBalance -= amount;
        token.safeTransfer(user, amount);
        return amount;
    }

    function retrieve(IERC20 token, address to) external auth {

        require(address(token) != address(asset), "Use exit for asset");
        token.safeTransfer(to, token.balanceOf(address(this)));
    }
}// MIT
pragma solidity 0.8.6;


contract ConvexJoin is Join {

    using CastU256U128 for uint256;

    struct EarnedData {
        address token;
        uint256 amount;
    }

    struct RewardType {
        address reward_token;
        address reward_pool;
        uint128 reward_integral;
        uint128 reward_remaining;
        mapping(address => uint256) reward_integral_for;
        mapping(address => uint256) claimable_reward;
    }

    uint256 public managed_assets;
    mapping(address => bytes12[]) public vaults; // Mapping to keep track of the user & their vaults


    address public immutable crv; // = address(0xD533a949740bb3306d119CC777fa900bA034cd52);
    address public immutable cvx; // = address(0x4e3FBD56CD56c3e72c1403e103b45Db9da5B9D2B);
    address public immutable convexToken;
    address public immutable convexPool;
    uint256 public immutable convexPoolId;
    ICauldron public immutable cauldron;

    RewardType[] public rewards;
    mapping(address => uint256) public registeredRewards;
    uint256 private constant CRV_INDEX = 0;
    uint256 private constant CVX_INDEX = 1;

    uint8 private _status = 1;

    uint8 private constant _NOT_ENTERED = 1;
    uint8 private constant _ENTERED = 2;

    event Deposited(address indexed _user, address indexed _account, uint256 _amount, bool _wrapped);
    event Withdrawn(address indexed _user, uint256 _amount, bool _unwrapped);

    event VaultAdded(address indexed account, bytes12 indexed vaultId);

    event VaultRemoved(address indexed account, bytes12 indexed vaultId);

    constructor(
        address _convexToken,
        address _convexPool,
        uint256 _poolId,
        ICauldron _cauldron,
        address _crv,
        address _cvx
    ) Join(_convexToken) {
        convexToken = _convexToken;
        convexPool = _convexPool;
        convexPoolId = _poolId;
        cauldron = _cauldron;
        crv = _crv;
        cvx = _cvx;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        _status = _ENTERED;
        _;
        _status = _NOT_ENTERED;
    }

    function setApprovals() public {

        IERC20(convexToken).approve(convexPool, type(uint256).max);
    }


    function addVault(bytes12 vaultId) external {

        address account = cauldron.vaults(vaultId).owner;
        require(cauldron.assets(cauldron.vaults(vaultId).ilkId) == convexToken, "Vault is for different ilk");
        require(account != address(0), "No owner for the vault");
        bytes12[] storage vaults_ = vaults[account];
        uint256 vaultsLength = vaults_.length;

        for (uint256 i; i < vaultsLength; ++i) {
            require(vaults_[i] != vaultId, "Vault already added");
        }
        vaults_.push(vaultId);
        emit VaultAdded(account, vaultId);
    }

    function removeVault(bytes12 vaultId, address account) public {

        address owner = cauldron.vaults(vaultId).owner;
        require(account != owner, "vault belongs to account");
        bytes12[] storage vaults_ = vaults[account];
        uint256 vaultsLength = vaults_.length;
        for (uint256 i; i < vaultsLength; ++i) {
            if (vaults_[i] == vaultId) {
                bool isLast = i == vaultsLength - 1;
                if (!isLast) {
                    vaults_[i] = vaults_[vaultsLength - 1];
                }
                vaults_.pop();
                emit VaultRemoved(account, vaultId);
                return;
            }
        }
        revert("Vault not found");
    }

    function aggregatedAssetsOf(address account) internal view returns (uint256) {

        bytes12[] memory userVault = vaults[account];

        uint256 collateral;
        DataTypes.Balances memory balance;
        uint256 userVaultLength = userVault.length;
        for (uint256 i; i < userVaultLength; ++i) {
            if (cauldron.vaults(userVault[i]).owner == account) {
                balance = cauldron.balances(userVault[i]);
                collateral = collateral + balance.ink;
            }
        }

        return collateral;
    }


    function addRewards() public {

        address mainPool = convexPool;

        if (rewards.length == 0) {
            RewardType storage reward = rewards.push();
            reward.reward_token = crv;
            reward.reward_pool = mainPool;

            reward = rewards.push();
            reward.reward_token = cvx;

            registeredRewards[crv] = CRV_INDEX + 1; //mark registered at index+1
            registeredRewards[cvx] = CVX_INDEX + 1; //mark registered at index+1
        }

        uint256 extraCount = IRewardStaking(mainPool).extraRewardsLength();
        for (uint256 i; i < extraCount; ++i) {
            address extraPool = IRewardStaking(mainPool).extraRewards(i);
            address extraToken = IRewardStaking(extraPool).rewardToken();
            if (extraToken == cvx) {
                if (rewards[CVX_INDEX].reward_pool == address(0)) {
                    rewards[CVX_INDEX].reward_pool = extraPool;
                }
            } else if (registeredRewards[extraToken] == 0) {
                RewardType storage reward = rewards.push();
                reward.reward_token = extraToken;
                reward.reward_pool = extraPool;

                registeredRewards[extraToken] = rewards.length; //mark registered at index+1
            }
        }
    }


    function join(address user, uint128 amount) external override auth returns (uint128) {

        require(amount > 0, "No convex token to wrap");

        _checkpoint(user, amount, false);
        managed_assets += amount;

        _join(user, amount);
        storedBalance -= amount; // _join would have increased the balance & we need to reduce it to reflect the stake in next line
        IRewardStaking(convexPool).stake(amount);
        emit Deposited(msg.sender, user, amount, false);

        return amount;
    }

    function exit(address user, uint128 amount) external override auth returns (uint128) {

        managed_assets -= amount;

        IRewardStaking(convexPool).withdraw(amount, false);
        storedBalance += amount; // _exit would have decreased the balance & we need to increase it to reflect the withdraw in the previous line
        _exit(user, amount);
        emit Withdrawn(user, amount, false);

        return amount;
    }


    function _calcRewardIntegral(
        uint256 index,
        address account,
        uint256 balance,
        bool claim
    ) internal {

        RewardType storage reward = rewards[index];

        uint256 rewardIntegral = reward.reward_integral;
        uint256 rewardRemaining = reward.reward_remaining;

        uint256 bal = IERC20(reward.reward_token).balanceOf(address(this));
        uint256 supply = managed_assets;
        if (supply > 0 && (bal - rewardRemaining) > 0) {
            unchecked {
                rewardIntegral = rewardIntegral + ((bal - rewardRemaining) * 1e20) / supply;
                reward.reward_integral = rewardIntegral.u128();
            }
        }

        if (account != address(this)) {
            uint256 userI = reward.reward_integral_for[account];
            if (claim || userI < rewardIntegral) {
                if (claim) {
                    uint256 receiveable = reward.claimable_reward[account] +
                        ((balance * (rewardIntegral - userI)) / 1e20);
                    if (receiveable > 0) {
                        reward.claimable_reward[account] = 0;
                        unchecked {
                            bal -= receiveable;
                        }
                        TransferHelper.safeTransfer(IERC20(reward.reward_token), account, receiveable);
                    }
                } else {
                    reward.claimable_reward[account] =
                        reward.claimable_reward[account] +
                        ((balance * (rewardIntegral - userI)) / 1e20);
                }
                reward.reward_integral_for[account] = rewardIntegral;
            }
        }

        if (bal != rewardRemaining) {
            reward.reward_remaining = bal.u128();
        }
    }


    function _checkpoint(
        address account,
        uint256 delta,
        bool claim
    ) internal {

        uint256 depositedBalance;
        depositedBalance = aggregatedAssetsOf(account) - delta;

        IRewardStaking(convexPool).getReward(address(this), true);

        uint256 rewardCount = rewards.length;
        rewardCount = rewardCount >= 40 ? 40 : rewardCount;
        for (uint256 i; i < rewardCount; ++i) {
            _calcRewardIntegral(i, account, depositedBalance, claim);
        }
    }

    function checkpoint(address account) external returns (bool) {

        _checkpoint(account, 0, false);
        return true;
    }

    function getReward(address account) external nonReentrant {

        _checkpoint(account, 0, true);
    }

    function earned(address account) external view returns (EarnedData[] memory claimable) {

        uint256 supply = managed_assets;
        uint256 depositedBalance = aggregatedAssetsOf(account);
        uint256 rewardCount = rewards.length;
        claimable = new EarnedData[](rewardCount);

        for (uint256 i; i < rewardCount; ++i) {
            RewardType storage reward = rewards[i];

            if (reward.reward_pool == address(0)) {
                claimable[i].amount += reward.claimable_reward[account];
                claimable[i].token = reward.reward_token;
                continue;
            }

            uint256 bal = IERC20(reward.reward_token).balanceOf(address(this));
            uint256 d_reward = bal - reward.reward_remaining;
            d_reward = d_reward + IRewardStaking(reward.reward_pool).earned(address(this));

            uint256 I = reward.reward_integral;
            if (supply > 0) {
                I = I + (d_reward * 1e20) / supply;
            }

            uint256 newlyClaimable = (depositedBalance * (I - (reward.reward_integral_for[account]))) / (1e20);
            claimable[i].amount += reward.claimable_reward[account] + newlyClaimable;
            claimable[i].token = reward.reward_token;

            if (i == CRV_INDEX) {
                I = reward.reward_integral;
                if (supply > 0) {
                    I = I + (IRewardStaking(reward.reward_pool).earned(address(this)) * 1e20) / supply;
                }
                newlyClaimable = (depositedBalance * (I - reward.reward_integral_for[account])) / 1e20;
                claimable[CVX_INDEX].amount = CvxMining.ConvertCrvToCvx(newlyClaimable);
                claimable[CVX_INDEX].token = cvx;
            }
        }
    }
}