
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}/*
IEvents

https://github.com/gysr-io/core

MIT
 */

pragma solidity 0.8.4;

interface IEvents {

    event Staked(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event Unstaked(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event Claimed(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );

    event RewardsDistributed(
        address indexed user,
        address indexed token,
        uint256 amount,
        uint256 shares
    );
    event RewardsFunded(
        address indexed token,
        uint256 amount,
        uint256 shares,
        uint256 timestamp
    );
    event RewardsUnlocked(address indexed token, uint256 shares);
    event RewardsExpired(
        address indexed token,
        uint256 amount,
        uint256 shares,
        uint256 timestamp
    );

    event GysrSpent(address indexed user, uint256 amount);
    event GysrVested(address indexed user, uint256 amount);
    event GysrWithdrawn(uint256 amount);
}/*
OwnerController

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;

contract OwnerController {

    address private _owner;
    address private _controller;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event ControlTransferred(
        address indexed previousController,
        address indexed newController
    );

    constructor() {
        _owner = msg.sender;
        _controller = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
        emit ControlTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function controller() public view returns (address) {

        return _controller;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "oc1");
        _;
    }

    modifier onlyController() {

        require(_controller == msg.sender, "oc2");
        _;
    }

    function requireOwner() internal view {

        require(_owner == msg.sender, "oc1");
    }

    function requireController() internal view {

        require(_controller == msg.sender, "oc2");
    }

    function transferOwnership(address newOwner) public virtual {

        requireOwner();
        require(newOwner != address(0), "oc3");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function transferControl(address newController) public virtual {

        requireOwner();
        require(newController != address(0), "oc4");
        emit ControlTransferred(_controller, newController);
        _controller = newController;
    }
}/*
IRewardModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;




abstract contract IRewardModule is OwnerController, IEvents {
    uint256 public constant DECIMALS = 18;

    function tokens() external view virtual returns (address[] memory);

    function balances() external view virtual returns (uint256[] memory);

    function usage() external view virtual returns (uint256);

    function factory() external view virtual returns (address);

    function stake(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function unstake(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function claim(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external virtual returns (uint256, uint256);

    function update(address user) external virtual;

    function clean() external virtual;
}/*
ERC20BaseRewardModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;



abstract contract ERC20BaseRewardModule is IRewardModule {
    using SafeERC20 for IERC20;

    struct Funding {
        uint256 amount;
        uint256 shares;
        uint256 locked;
        uint256 updated;
        uint256 start;
        uint256 duration;
    }

    uint256 public constant INITIAL_SHARES_PER_TOKEN = 10**6;
    uint256 public constant MAX_ACTIVE_FUNDINGS = 16;

    mapping(address => Funding[]) private _fundings;
    mapping(address => uint256) private _shares;
    mapping(address => uint256) private _locked;

    function totalShares(address token) public view returns (uint256) {
        return _shares[token];
    }

    function lockedShares(address token) public view returns (uint256) {
        return _locked[token];
    }

    function fundings(address token, uint256 index)
        public
        view
        returns (
            uint256 amount,
            uint256 shares,
            uint256 locked,
            uint256 updated,
            uint256 start,
            uint256 duration
        )
    {
        Funding storage f = _fundings[token][index];
        return (f.amount, f.shares, f.locked, f.updated, f.start, f.duration);
    }

    function fundingCount(address token) public view returns (uint256) {
        return _fundings[token].length;
    }

    function unlockable(address token, uint256 idx)
        public
        view
        returns (uint256)
    {
        Funding storage funding = _fundings[token][idx];

        if (block.timestamp < funding.start) {
            return 0;
        }
        if (funding.locked == 0) {
            return 0;
        }
        if (block.timestamp >= funding.start + funding.duration) {
            return funding.locked;
        }

        return
            ((block.timestamp - funding.updated) * funding.shares) /
            funding.duration;
    }

    function _fund(
        address token,
        uint256 amount,
        uint256 duration,
        uint256 start
    ) internal {
        requireController();
        require(amount > 0, "rm1");
        require(start >= block.timestamp, "rm2");
        require(_fundings[token].length < MAX_ACTIVE_FUNDINGS, "rm3");

        IERC20 rewardToken = IERC20(token);

        uint256 total = rewardToken.balanceOf(address(this));
        rewardToken.safeTransferFrom(msg.sender, address(this), amount);
        uint256 actual = rewardToken.balanceOf(address(this)) - total;

        uint256 minted =
            (total > 0)
                ? (_shares[token] * actual) / total
                : actual * INITIAL_SHARES_PER_TOKEN;

        _locked[token] += minted;
        _shares[token] += minted;

        _fundings[token].push(
            Funding({
                amount: amount,
                shares: minted,
                locked: minted,
                updated: start,
                start: start,
                duration: duration
            })
        );

        emit RewardsFunded(token, amount, minted, start);
    }

    function _clean(address token) internal {
        uint256 removed = 0;
        uint256 originalSize = _fundings[token].length;
        for (uint256 i = 0; i < originalSize; i++) {
            Funding storage funding = _fundings[token][i - removed];
            uint256 idx = i - removed;

            if (
                unlockable(token, idx) == 0 &&
                block.timestamp >= funding.start + funding.duration
            ) {
                emit RewardsExpired(
                    token,
                    funding.amount,
                    funding.shares,
                    funding.start
                );

                _fundings[token][idx] = _fundings[token][
                    _fundings[token].length - 1
                ];
                _fundings[token].pop();
                removed++;
            }
        }
    }

    function _unlockTokens(address token) internal returns (uint256 shares) {
        for (uint256 i = 0; i < _fundings[token].length; i++) {
            uint256 s = unlockable(token, i);
            Funding storage funding = _fundings[token][i];
            if (s > 0) {
                funding.locked -= s;
                funding.updated = block.timestamp;
                shares += s;
            }
        }

        if (shares > 0) {
            _locked[token] -= shares;
            emit RewardsUnlocked(token, shares);
        }
    }

    function _distribute(
        address user,
        address token,
        uint256 shares
    ) internal returns (uint256 amount) {
        IERC20 rewardToken = IERC20(token);
        amount =
            (rewardToken.balanceOf(address(this)) * shares) /
            _shares[token];

        _shares[token] -= shares;

        rewardToken.safeTransfer(user, amount);
        emit RewardsDistributed(user, token, amount, shares);
    }
}/*
MathUtils

https://github.com/gysr-io/core

BSD-4-Clause
*/

pragma solidity 0.8.4;

library MathUtils {

    function logbase2(int128 x) internal pure returns (int128) {

        unchecked {
            require(x > 0);

            int256 msb = 0;
            int256 xc = x;
            if (xc >= 0x10000000000000000) {
                xc >>= 64;
                msb += 64;
            }
            if (xc >= 0x100000000) {
                xc >>= 32;
                msb += 32;
            }
            if (xc >= 0x10000) {
                xc >>= 16;
                msb += 16;
            }
            if (xc >= 0x100) {
                xc >>= 8;
                msb += 8;
            }
            if (xc >= 0x10) {
                xc >>= 4;
                msb += 4;
            }
            if (xc >= 0x4) {
                xc >>= 2;
                msb += 2;
            }
            if (xc >= 0x2) msb += 1; // No need to shift xc anymore

            int256 result = (msb - 64) << 64;
            uint256 ux = uint256(int256(x)) << uint256(127 - msb);
            for (int256 bit = 0x8000000000000000; bit > 0; bit >>= 1) {
                ux *= ux;
                uint256 b = ux >> 255;
                ux >>= 127 + b;
                result += bit * int256(b);
            }

            return int128(result);
        }
    }

    function ln(int128 x) internal pure returns (int128) {

        unchecked {
            require(x > 0);

            return
                int128(
                    int256(
                        (uint256(int256(logbase2(x))) *
                            0xB17217F7D1CF79ABC9E3B39803F2F6AF) >> 128
                    )
                );
        }
    }

    function logbase10(int128 x) internal pure returns (int128) {

        require(x > 0);

        return
            int128(
                int256(
                    (uint256(int256(logbase2(x))) *
                        0x4d104d427de7fce20a6e420e02236748) >> 128
                )
            );
    }

    function testlogbase2(int128 x) public pure returns (int128) {

        return logbase2(x);
    }

    function testlogbase10(int128 x) public pure returns (int128) {

        return logbase10(x);
    }
}/*
GysrUtils

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;


library GysrUtils {

    using MathUtils for int128;

    uint256 public constant DECIMALS = 18;
    uint256 public constant GYSR_PROPORTION = 10**(DECIMALS - 2); // 1%

    function gysrBonus(
        uint256 gysr,
        uint256 amount,
        uint256 total,
        uint256 ratio
    ) internal pure returns (uint256) {

        if (amount == 0) {
            return 0;
        }
        if (total == 0) {
            return 0;
        }
        if (gysr == 0) {
            return 10**DECIMALS;
        }

        uint256 portion = (GYSR_PROPORTION * total) / 10**DECIMALS;
        if (amount > portion) {
            gysr = (gysr * portion) / amount;
        }

        uint256 x = 2**64 + (2**64 * gysr) / (10**(DECIMALS - 2) + ratio);

        return
            10**DECIMALS +
            (uint256(int256(int128(uint128(x)).logbase10())) * 10**DECIMALS) /
            2**64;
    }
}/*
ERC20FriendlyRewardModule

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;


contract ERC20FriendlyRewardModule is ERC20BaseRewardModule {

    using GysrUtils for uint256;

    uint256 public constant FULL_VESTING = 10**DECIMALS;

    struct Stake {
        uint256 shares;
        uint256 gysr;
        uint256 bonus;
        uint256 rewardTally;
        uint256 timestamp;
    }

    mapping(address => Stake[]) public stakes;

    uint256 public totalRawStakingShares;
    uint256 public totalStakingShares;
    uint256 public rewardsPerStakedShare;
    uint256 public rewardDust;
    uint256 public lastUpdated;

    uint256 public immutable vestingStart;
    uint256 public immutable vestingPeriod;

    IERC20 private immutable _token;
    address private immutable _factory;

    constructor(
        address token_,
        uint256 vestingStart_,
        uint256 vestingPeriod_,
        address factory_
    ) {
        require(vestingStart_ <= FULL_VESTING, "frm1");

        _token = IERC20(token_);
        _factory = factory_;

        vestingStart = vestingStart_;
        vestingPeriod = vestingPeriod_;

        lastUpdated = block.timestamp;
    }

    function tokens()
        external
        view
        override
        returns (address[] memory tokens_)
    {

        tokens_ = new address[](1);
        tokens_[0] = address(_token);
    }

    function factory() external view override returns (address) {

        return _factory;
    }

    function balances()
        external
        view
        override
        returns (uint256[] memory balances_)
    {

        balances_ = new uint256[](1);
        balances_[0] = totalLocked();
    }

    function usage() external view override returns (uint256) {

        return _usage();
    }

    function stake(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external override onlyOwner returns (uint256, uint256) {

        _update();
        return _stake(account, user, shares, data);
    }

    function _stake(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) internal returns (uint256, uint256) {

        require(data.length == 0 || data.length == 32, "frm2");

        uint256 gysr;
        if (data.length == 32) {
            assembly {
                gysr := calldataload(164)
            }
        }

        uint256 bonus =
            gysr.gysrBonus(shares, totalRawStakingShares + shares, _usage());

        if (gysr > 0) {
            emit GysrSpent(user, gysr);
        }

        stakes[account].push(
            Stake(shares, gysr, bonus, rewardsPerStakedShare, block.timestamp)
        );

        totalRawStakingShares += shares;
        totalStakingShares += (shares * bonus) / 10**DECIMALS;

        return (gysr, 0);
    }

    function unstake(
        address account,
        address user,
        uint256 shares,
        bytes calldata
    ) external override onlyOwner returns (uint256, uint256) {

        _update();
        return _unstake(account, user, shares);
    }

    function _unstake(
        address account,
        address user,
        uint256 shares
    ) internal returns (uint256, uint256) {

        uint256 sharesLeftToBurn = shares;
        Stake[] storage userStakes = stakes[account];
        uint256 rewardAmount;
        uint256 gysrVested;
        uint256 preVestingRewards;
        uint256 timeVestingCoeff;
        while (sharesLeftToBurn > 0) {
            Stake storage lastStake = userStakes[userStakes.length - 1];
            require(lastStake.timestamp < block.timestamp, "frm3");

            if (lastStake.shares <= sharesLeftToBurn) {

                preVestingRewards = _rewardForStakedShares(
                    lastStake.shares,
                    lastStake.bonus,
                    lastStake.rewardTally
                );

                timeVestingCoeff = timeVestingCoefficient(lastStake.timestamp);
                rewardAmount +=
                    (preVestingRewards * timeVestingCoeff) /
                    10**DECIMALS;

                rewardDust +=
                    (preVestingRewards * (FULL_VESTING - timeVestingCoeff)) /
                    10**DECIMALS;

                totalStakingShares -=
                    (lastStake.shares * lastStake.bonus) /
                    10**DECIMALS;
                sharesLeftToBurn -= lastStake.shares;
                gysrVested += lastStake.gysr;
                userStakes.pop();
            } else {

                preVestingRewards = _rewardForStakedShares(
                    sharesLeftToBurn,
                    lastStake.bonus,
                    lastStake.rewardTally
                );

                timeVestingCoeff = timeVestingCoefficient(lastStake.timestamp);
                rewardAmount +=
                    (preVestingRewards * timeVestingCoeff) /
                    10**DECIMALS;

                rewardDust +=
                    (preVestingRewards * (FULL_VESTING - timeVestingCoeff)) /
                    10**DECIMALS;

                totalStakingShares -=
                    (sharesLeftToBurn * lastStake.bonus) /
                    10**DECIMALS;

                uint256 partialVested =
                    (sharesLeftToBurn * lastStake.gysr) / lastStake.shares;
                gysrVested += partialVested;
                lastStake.shares -= sharesLeftToBurn;
                lastStake.gysr -= partialVested;
                sharesLeftToBurn = 0;
            }
        }

        totalRawStakingShares -= shares;

        if (rewardAmount > 0) {
            _distribute(user, address(_token), rewardAmount);
        }

        if (gysrVested > 0) {
            emit GysrVested(user, gysrVested);
        }

        return (0, gysrVested);
    }

    function claim(
        address account,
        address user,
        uint256 shares,
        bytes calldata data
    ) external override onlyOwner returns (uint256 spent, uint256 vested) {

        _update();
        (, vested) = _unstake(account, user, shares);
        (spent, ) = _stake(account, user, shares, data);
    }

    function _rewardForStakedShares(
        uint256 shares,
        uint256 bonus,
        uint256 rewardTally
    ) internal view returns (uint256) {

        return
            ((((rewardsPerStakedShare - rewardTally) * shares) / 10**DECIMALS) * // counteract rewardsPerStakedShare coefficient
                bonus) / 10**DECIMALS; // counteract bonus coefficient
    }

    function timeVestingCoefficient(uint256 time)
        public
        view
        returns (uint256)
    {

        if (vestingPeriod == 0) return FULL_VESTING;
        uint256 stakeTime = block.timestamp - time;
        if (stakeTime > vestingPeriod) return FULL_VESTING;
        return
            vestingStart +
            (stakeTime * (FULL_VESTING - vestingStart)) /
            vestingPeriod;
    }

    function update(address) external override {

        requireOwner();
        _update();
    }

    function clean() external override {

        requireOwner();
        _update();
        _clean(address(_token));
    }

    function fund(uint256 amount, uint256 duration) external {

        _update();
        _fund(address(_token), amount, duration, block.timestamp);
    }

    function fund(
        uint256 amount,
        uint256 duration,
        uint256 start
    ) external {

        _update();
        _fund(address(_token), amount, duration, start);
    }

    function _update() private {

        lastUpdated = block.timestamp;

        if (totalStakingShares == 0) {
            rewardsPerStakedShare = 0;
            return;
        }

        uint256 rewardsToUnlock = _unlockTokens(address(_token)) + rewardDust;
        rewardDust = 0;

        rewardsPerStakedShare +=
            (rewardsToUnlock * 10**DECIMALS) /
            totalStakingShares;
    }

    function totalLocked() public view returns (uint256) {

        if (lockedShares(address(_token)) == 0) {
            return 0;
        }
        return
            (_token.balanceOf(address(this)) * lockedShares(address(_token))) /
            totalShares(address(_token));
    }

    function totalUnlocked() public view returns (uint256) {

        uint256 unlockedShares =
            totalShares(address(_token)) - lockedShares(address(_token));

        if (unlockedShares == 0) {
            return 0;
        }
        return
            (_token.balanceOf(address(this)) * unlockedShares) /
            totalShares(address(_token));
    }

    function _usage() private view returns (uint256) {

        if (totalStakingShares == 0) {
            return 0;
        }
        return
            ((totalStakingShares - totalRawStakingShares) * 10**DECIMALS) /
            totalStakingShares;
    }

    function stakeCount(address addr) public view returns (uint256) {

        return stakes[addr].length;
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}/*
ERC20FriendlyRewardModuleInfo

https://github.com/gysr-io/core

MIT
*/

pragma solidity 0.8.4;



library ERC20FriendlyRewardModuleInfo {

    using GysrUtils for uint256;

    function tokens(address module)
        external
        view
        returns (
            address[] memory addresses_,
            string[] memory names_,
            string[] memory symbols_,
            uint8[] memory decimals_
        )
    {

        addresses_ = new address[](1);
        names_ = new string[](1);
        symbols_ = new string[](1);
        decimals_ = new uint8[](1);
        (addresses_[0], names_[0], symbols_[0], decimals_[0]) = token(module);
    }

    function token(address module)
        public
        view
        returns (
            address,
            string memory,
            string memory,
            uint8
        )
    {

        IRewardModule m = IRewardModule(module);
        IERC20Metadata tkn = IERC20Metadata(m.tokens()[0]);
        return (address(tkn), tkn.name(), tkn.symbol(), tkn.decimals());
    }

    function rewards(
        address module,
        address addr,
        uint256 shares
    ) public view returns (uint256[] memory rewards_) {

        rewards_ = new uint256[](1);
        (rewards_[0], , ) = preview(module, addr, shares);
    }

    function preview(
        address module,
        address addr,
        uint256 shares
    )
        public
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        require(shares > 0, "frmi1");
        ERC20FriendlyRewardModule m = ERC20FriendlyRewardModule(module);

        uint256 reward;
        uint256 rawSum;
        uint256 bonusSum;

        uint256 i = m.stakeCount(addr);

        while (shares > 0) {
            require(i > 0, "frmi2");
            i -= 1;

            (uint256 s, , , , ) = m.stakes(addr, i);

            s = s <= shares ? s : shares;

            uint256 r;
            {
                r = rewardsPerStakedShare(module);
            }

            {
                (, , , uint256 tally, ) = m.stakes(addr, i);
                r = ((r - tally) * s) / 1e18;
                rawSum += r;
            }

            {
                (, , uint256 bonus, , ) = m.stakes(addr, i);
                r = (r * bonus) / 1e18;
                bonusSum += r;
            }

            {
                (, , , , uint256 time) = m.stakes(addr, i);
                r = (r * m.timeVestingCoefficient(time)) / 1e18;
            }
            reward += r;
            shares -= s;
        }

        return (
            reward / 1e6,
            reward > 0 ? (reward * 1e18) / bonusSum : 0,
            reward > 0 ? (bonusSum * 1e18) / rawSum : 0
        );
    }

    function unlockable(address module) public view returns (uint256) {

        ERC20FriendlyRewardModule m = ERC20FriendlyRewardModule(module);
        address tkn = m.tokens()[0];
        if (m.lockedShares(tkn) == 0) {
            return 0;
        }
        uint256 sharesToUnlock = 0;
        for (uint256 i = 0; i < m.fundingCount(tkn); i++) {
            sharesToUnlock = sharesToUnlock + m.unlockable(tkn, i);
        }
        return sharesToUnlock;
    }

    function unlocked(address module) public view returns (uint256) {

        ERC20FriendlyRewardModule m = ERC20FriendlyRewardModule(module);
        IERC20Metadata tkn = IERC20Metadata(m.tokens()[0]);
        uint256 totalShares = m.totalShares(address(tkn));
        if (totalShares == 0) {
            return 0;
        }
        uint256 shares = unlockable(module);
        uint256 amount = (shares * tkn.balanceOf(module)) / totalShares;
        return m.totalUnlocked() + amount;
    }

    function rewardsPerStakedShare(address module)
        public
        view
        returns (uint256)
    {

        ERC20FriendlyRewardModule m = ERC20FriendlyRewardModule(module);
        if (m.totalStakingShares() == 0) {
            return 0;
        }
        uint256 rewardsToUnlock = unlockable(module) + m.rewardDust();
        return
            m.rewardsPerStakedShare() +
            (rewardsToUnlock * 1e18) /
            m.totalStakingShares();
    }

    function gysrBonus(
        address module,
        uint256 shares,
        uint256 gysr
    ) public view returns (uint256) {

        ERC20FriendlyRewardModule m = ERC20FriendlyRewardModule(module);
        return
            gysr.gysrBonus(
                shares,
                m.totalRawStakingShares() + shares,
                m.usage()
            );
    }
}