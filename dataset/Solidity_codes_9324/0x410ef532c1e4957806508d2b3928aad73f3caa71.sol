




pragma solidity >=0.7.6 <0.8.0;

library AddressIsContract {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
}



pragma solidity >=0.7.6 <0.8.0;

library ERC20Wrapper {

    using AddressIsContract for address;

    function wrappedTransfer(
        IWrappedERC20 token,
        address to,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function wrappedTransferFrom(
        IWrappedERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function wrappedApprove(
        IWrappedERC20 token,
        address spender,
        uint256 value
    ) internal {

        _callWithOptionalReturnData(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function _callWithOptionalReturnData(IWrappedERC20 token, bytes memory callData) internal {

        address target = address(token);
        require(target.isContract(), "ERC20Wrapper: non-contract");

        (bool success, bytes memory data) = target.call(callData);
        if (success) {
            if (data.length != 0) {
                require(abi.decode(data, (bool)), "ERC20Wrapper: operation failed");
            }
        } else {
            if (data.length == 0) {
                revert("ERC20Wrapper: operation failed");
            }

            assembly {
                let size := mload(data)
                revert(add(32, data), size)
            }
        }
    }
}

interface IWrappedERC20 {

    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function approve(address spender, uint256 value) external returns (bool);

}



pragma solidity >=0.6.0 <0.8.0;


library SafeCast {


    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value < 2**128, "SafeCast: value doesn\'t fit in 128 bits");
        return uint128(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value < 2**64, "SafeCast: value doesn\'t fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value < 2**32, "SafeCast: value doesn\'t fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value < 2**16, "SafeCast: value doesn\'t fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value < 2**8, "SafeCast: value doesn\'t fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= -2**127 && value < 2**127, "SafeCast: value doesn\'t fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= -2**63 && value < 2**63, "SafeCast: value doesn\'t fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= -2**31 && value < 2**31, "SafeCast: value doesn\'t fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= -2**15 && value < 2**15, "SafeCast: value doesn\'t fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= -2**7 && value < 2**7, "SafeCast: value doesn\'t fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value < 2**255, "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}



pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}



pragma solidity >=0.6.0 <0.8.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}



pragma solidity >=0.7.6 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



pragma solidity >=0.7.6 <0.8.0;

interface IERC1155TokenReceiver {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}



pragma solidity >=0.7.6 <0.8.0;


abstract contract ERC1155TokenReceiver is IERC165, IERC1155TokenReceiver {
    bytes4 internal constant _ERC1155_RECEIVED = 0xf23a6e61;

    bytes4 internal constant _ERC1155_BATCH_RECEIVED = 0xbc197c81;

    bytes4 internal constant _ERC1155_REJECTED = 0xffffffff;


    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC1155TokenReceiver).interfaceId;
    }
}



pragma solidity >=0.7.6 <0.8.0;

abstract contract ManagedIdentity {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        return msg.data;
    }
}



pragma solidity >=0.7.6 <0.8.0;

interface IERC173 {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;

}



pragma solidity >=0.7.6 <0.8.0;


abstract contract Ownable is ManagedIdentity, IERC173 {
    address internal _owner;

    constructor(address owner_) {
        _owner = owner_;
        emit OwnershipTransferred(address(0), owner_);
    }

    function owner() public view virtual override returns (address) {
        return _owner;
    }

    function transferOwnership(address newOwner) public virtual override {
        _requireOwnership(_msgSender());
        _owner = newOwner;
        emit OwnershipTransferred(_owner, newOwner);
    }

    function _requireOwnership(address account) internal virtual {
        require(account == this.owner(), "Ownable: not the owner");
    }
}



pragma solidity >=0.7.6 <0.8.0;




contract DeltaTimeStaking2021 is ERC1155TokenReceiver, Ownable {

    using ERC20Wrapper for IWrappedERC20;
    using SafeCast for uint256;
    using SafeMath for uint256;
    using SignedSafeMath for int256;

    event RewardsAdded(uint256 startPeriod, uint256 endPeriod, uint256 rewardsPerCycle);

    event Started();

    event NftStaked(address staker, uint256 cycle, uint256 tokenId, uint256 weight);

    event NftUnstaked(address staker, uint256 cycle, uint256 tokenId, uint256 weight);

    event RewardsClaimed(address staker, uint256 cycle, uint256 startPeriod, uint256 periods, uint256 amount);

    event HistoriesUpdated(address staker, uint256 startCycle, uint256 stakerStake, uint256 globalStake);

    event Disabled();

    struct TokenInfo {
        address owner;
        uint64 weight;
        uint16 depositCycle;
        uint16 withdrawCycle;
    }

    struct Snapshot {
        uint128 stake;
        uint128 startCycle;
    }

    struct NextClaim {
        uint16 period;
        uint64 globalSnapshotIndex;
        uint64 stakerSnapshotIndex;
    }

    struct ComputedClaim {
        uint16 startPeriod;
        uint16 periods;
        uint256 amount;
    }

    bool public enabled = true;

    uint256 public totalRewardsPool;

    uint256 public startTimestamp;

    IWrappedERC20 public immutable rewardsTokenContract;
    IWhitelistedNftContract public immutable whitelistedNftContract;

    uint32 public immutable cycleLengthInSeconds;
    uint16 public immutable periodLengthInCycles;

    Snapshot[] public globalHistory;

    mapping(uint256 => uint64) public weightsByRarity;

    mapping(address => Snapshot[]) public stakerHistories;

    mapping(address => NextClaim) public nextClaims;

    mapping(uint256 => TokenInfo) public tokenInfos;

    mapping(uint256 => uint256) public rewardsSchedule;

    modifier hasStarted() {

        require(startTimestamp != 0, "NftStaking: staking not started");
        _;
    }

    modifier hasNotStarted() {

        require(startTimestamp == 0, "NftStaking: staking has started");
        _;
    }

    modifier isEnabled() {

        require(enabled, "NftStaking: contract is not enabled");
        _;
    }

    modifier isNotEnabled() {

        require(!enabled, "NftStaking: contract is enabled");
        _;
    }

    constructor(
        uint32 cycleLengthInSeconds_,
        uint16 periodLengthInCycles_,
        IWhitelistedNftContract whitelistedNftContract_,
        IWrappedERC20 rewardsTokenContract_,
        uint256[] memory rarities,
        uint64[] memory weights
    ) Ownable(msg.sender) {
        require(rarities.length == weights.length, "NftStaking: wrong arguments");

        require(cycleLengthInSeconds_ >= 1 minutes, "NftStaking: invalid cycle length");
        require(periodLengthInCycles_ >= 2, "NftStaking: invalid period length");

        cycleLengthInSeconds = cycleLengthInSeconds_;
        periodLengthInCycles = periodLengthInCycles_;
        whitelistedNftContract = whitelistedNftContract_;
        rewardsTokenContract = rewardsTokenContract_;

        for (uint256 i = 0; i < rarities.length; ++i) {
            weightsByRarity[rarities[i]] = weights[i];
        }
    }


    function addRewardsForPeriods(
        uint16 startPeriod,
        uint16 endPeriod,
        uint256 rewardsPerCycle
    ) external {

        _requireOwnership(msg.sender);
        require(startPeriod != 0 && startPeriod <= endPeriod, "NftStaking: wrong period range");

        uint16 periodLengthInCycles_ = periodLengthInCycles;

        if (startTimestamp != 0) {
            require(startPeriod >= _getCurrentPeriod(periodLengthInCycles_), "NftStaking: already committed reward schedule");
        }

        for (uint256 period = startPeriod; period <= endPeriod; ++period) {
            rewardsSchedule[period] = rewardsSchedule[period].add(rewardsPerCycle);
        }

        uint256 addedRewards = rewardsPerCycle.mul(periodLengthInCycles_).mul(endPeriod - startPeriod + 1);

        totalRewardsPool = totalRewardsPool.add(addedRewards);

        rewardsTokenContract.wrappedTransferFrom(msg.sender, address(this), addedRewards);

        emit RewardsAdded(startPeriod, endPeriod, rewardsPerCycle);
    }

    function start() public hasNotStarted {

        _requireOwnership(msg.sender);
        startTimestamp = block.timestamp;
        emit Started();
    }

    function disable() public {

        _requireOwnership(msg.sender);
        enabled = false;
        emit Disabled();
    }

    function withdrawRewardsPool(uint256 amount) public isNotEnabled {

        _requireOwnership(msg.sender);
        rewardsTokenContract.wrappedTransfer(msg.sender, amount);
    }


    function onERC1155Received(
        address, /*operator*/
        address from,
        uint256 id,
        uint256, /*value*/
        bytes calldata /*data*/
    ) external virtual override returns (bytes4) {

        _stakeNft(id, from);
        return _ERC1155_RECEIVED;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address from,
        uint256[] calldata ids,
        uint256[] calldata, /*values*/
        bytes calldata /*data*/
    ) external virtual override returns (bytes4) {

        for (uint256 i = 0; i < ids.length; ++i) {
            _stakeNft(ids[i], from);
        }
        return _ERC1155_BATCH_RECEIVED;
    }


    function unstakeNft(uint256 tokenId) external {

        TokenInfo memory tokenInfo = tokenInfos[tokenId];

        require(tokenInfo.owner == msg.sender, "NftStaking: token not staked or incorrect token owner");

        uint16 currentCycle = _getCycle(block.timestamp);

        if (enabled) {
            require(currentCycle - tokenInfo.depositCycle >= 2, "NftStaking: token still frozen");

            _updateHistories(msg.sender, -int128(tokenInfo.weight), currentCycle);

            tokenInfo.owner = address(0);

            tokenInfo.withdrawCycle = currentCycle;

            tokenInfos[tokenId] = tokenInfo;
        }

        whitelistedNftContract.transferFrom(address(this), msg.sender, tokenId);

        emit NftUnstaked(msg.sender, currentCycle, tokenId, tokenInfo.weight);
    }

    function estimateRewards(uint16 maxPeriods)
        external
        view
        isEnabled
        hasStarted
        returns (
            uint16 startPeriod,
            uint16 periods,
            uint256 amount
        )
    {

        (ComputedClaim memory claim, ) = _computeRewards(msg.sender, maxPeriods);
        startPeriod = claim.startPeriod;
        periods = claim.periods;
        amount = claim.amount;
    }

    function claimRewards(uint16 maxPeriods) external isEnabled hasStarted {

        NextClaim memory nextClaim = nextClaims[msg.sender];

        (ComputedClaim memory claim, NextClaim memory newNextClaim) = _computeRewards(msg.sender, maxPeriods);

        Snapshot[] storage stakerHistory = stakerHistories[msg.sender];
        while (nextClaim.stakerSnapshotIndex < newNextClaim.stakerSnapshotIndex) {
            delete stakerHistory[nextClaim.stakerSnapshotIndex++];
        }

        if (claim.periods == 0) {
            return;
        }

        if (nextClaims[msg.sender].period == 0) {
            return;
        }

        Snapshot memory lastStakerSnapshot = stakerHistory[stakerHistory.length - 1];

        uint256 lastClaimedCycle = (claim.startPeriod + claim.periods - 1) * periodLengthInCycles;
        if (
            lastClaimedCycle >= lastStakerSnapshot.startCycle && // the claim reached the last staker snapshot
            lastStakerSnapshot.stake == 0 // and nothing is staked in the last staker snapshot
        ) {
            delete nextClaims[msg.sender];
        } else {
            nextClaims[msg.sender] = newNextClaim;
        }

        if (claim.amount != 0) {
            rewardsTokenContract.wrappedTransfer(msg.sender, claim.amount);
        }

        emit RewardsClaimed(msg.sender, _getCycle(block.timestamp), claim.startPeriod, claim.periods, claim.amount);
    }


    function getCurrentCycle() external view returns (uint16) {

        return _getCycle(block.timestamp);
    }

    function getCurrentPeriod() external view returns (uint16) {

        return _getCurrentPeriod(periodLengthInCycles);
    }

    function lastGlobalSnapshotIndex() external view returns (uint256) {

        uint256 length = globalHistory.length;
        require(length != 0, "NftStaking: empty global history");
        return length - 1;
    }

    function lastStakerSnapshotIndex(address staker) external view returns (uint256) {

        uint256 length = stakerHistories[staker].length;
        require(length != 0, "NftStaking: empty staker history");
        return length - 1;
    }


    function _stakeNft(uint256 tokenId, address tokenOwner) internal isEnabled hasStarted {

        require(address(whitelistedNftContract) == msg.sender, "NftStaking: contract not whitelisted");

        uint64 weight = _validateAndGetNftWeight(tokenId);

        uint16 periodLengthInCycles_ = periodLengthInCycles;
        uint16 currentCycle = _getCycle(block.timestamp);

        _updateHistories(tokenOwner, int128(weight), currentCycle);

        if (nextClaims[tokenOwner].period == 0) {
            uint16 currentPeriod = _getPeriod(currentCycle, periodLengthInCycles_);
            nextClaims[tokenOwner] = NextClaim(currentPeriod, uint64(globalHistory.length - 1), 0);
        }

        uint16 withdrawCycle = tokenInfos[tokenId].withdrawCycle;
        require(currentCycle != withdrawCycle, "NftStaking: unstaked token cooldown");

        tokenInfos[tokenId] = TokenInfo(tokenOwner, weight, currentCycle, 0);

        emit NftStaked(tokenOwner, currentCycle, tokenId, weight);
    }

    function _computeRewards(address staker, uint16 maxPeriods) internal view returns (ComputedClaim memory claim, NextClaim memory nextClaim) {

        if (maxPeriods == 0) {
            return (claim, nextClaim);
        }

        if (globalHistory.length == 0) {
            return (claim, nextClaim);
        }

        nextClaim = nextClaims[staker];
        claim.startPeriod = nextClaim.period;

        if (claim.startPeriod == 0) {
            return (claim, nextClaim);
        }

        uint16 periodLengthInCycles_ = periodLengthInCycles;
        uint16 endClaimPeriod = _getCurrentPeriod(periodLengthInCycles_);

        if (nextClaim.period == endClaimPeriod) {
            return (claim, nextClaim);
        }

        Snapshot[] memory stakerHistory = stakerHistories[staker];

        Snapshot memory globalSnapshot = globalHistory[nextClaim.globalSnapshotIndex];
        Snapshot memory stakerSnapshot = stakerHistory[nextClaim.stakerSnapshotIndex];
        Snapshot memory nextGlobalSnapshot;
        Snapshot memory nextStakerSnapshot;

        if (nextClaim.globalSnapshotIndex != globalHistory.length - 1) {
            nextGlobalSnapshot = globalHistory[nextClaim.globalSnapshotIndex + 1];
        }
        if (nextClaim.stakerSnapshotIndex != stakerHistory.length - 1) {
            nextStakerSnapshot = stakerHistory[nextClaim.stakerSnapshotIndex + 1];
        }

        claim.periods = endClaimPeriod - nextClaim.period;

        if (maxPeriods < claim.periods) {
            claim.periods = maxPeriods;
        }

        endClaimPeriod = nextClaim.period + claim.periods;

        while (nextClaim.period != endClaimPeriod) {
            uint16 nextPeriodStartCycle = nextClaim.period * periodLengthInCycles_ + 1;
            uint256 rewardPerCycle = rewardsSchedule[nextClaim.period];
            uint256 startCycle = nextPeriodStartCycle - periodLengthInCycles_;
            uint256 endCycle = 0;

            while (endCycle != nextPeriodStartCycle) {
                if (globalSnapshot.startCycle > startCycle) {
                    startCycle = globalSnapshot.startCycle;
                }
                if (stakerSnapshot.startCycle > startCycle) {
                    startCycle = stakerSnapshot.startCycle;
                }

                endCycle = nextPeriodStartCycle;
                if ((nextGlobalSnapshot.startCycle != 0) && (nextGlobalSnapshot.startCycle < endCycle)) {
                    endCycle = nextGlobalSnapshot.startCycle;
                }

                if ((globalSnapshot.stake != 0) && (stakerSnapshot.stake != 0) && (rewardPerCycle != 0)) {
                    uint256 snapshotReward = (endCycle - startCycle).mul(rewardPerCycle).mul(stakerSnapshot.stake);
                    snapshotReward /= globalSnapshot.stake;

                    claim.amount = claim.amount.add(snapshotReward);
                }

                if (nextGlobalSnapshot.startCycle == endCycle) {
                    globalSnapshot = nextGlobalSnapshot;
                    ++nextClaim.globalSnapshotIndex;

                    if (nextClaim.globalSnapshotIndex != globalHistory.length - 1) {
                        nextGlobalSnapshot = globalHistory[nextClaim.globalSnapshotIndex + 1];
                    } else {
                        nextGlobalSnapshot = Snapshot(0, 0);
                    }
                }

                if (nextStakerSnapshot.startCycle == endCycle) {
                    stakerSnapshot = nextStakerSnapshot;
                    ++nextClaim.stakerSnapshotIndex;

                    if (nextClaim.stakerSnapshotIndex != stakerHistory.length - 1) {
                        nextStakerSnapshot = stakerHistory[nextClaim.stakerSnapshotIndex + 1];
                    } else {
                        nextStakerSnapshot = Snapshot(0, 0);
                    }
                }
            }

            ++nextClaim.period;
        }

        return (claim, nextClaim);
    }

    function _updateHistories(
        address staker,
        int128 stakeDelta,
        uint16 currentCycle
    ) internal {

        uint256 stakerSnapshotIndex = _updateHistory(stakerHistories[staker], stakeDelta, currentCycle);
        uint256 globalSnapshotIndex = _updateHistory(globalHistory, stakeDelta, currentCycle);

        emit HistoriesUpdated(staker, currentCycle, stakerHistories[staker][stakerSnapshotIndex].stake, globalHistory[globalSnapshotIndex].stake);
    }

    function _updateHistory(
        Snapshot[] storage history,
        int128 stakeDelta,
        uint16 currentCycle
    ) internal returns (uint256 snapshotIndex) {

        uint256 historyLength = history.length;
        uint128 snapshotStake;

        if (historyLength != 0) {
            snapshotIndex = historyLength - 1;
            Snapshot storage sSnapshot = history[snapshotIndex];
            snapshotStake = uint256(int256(sSnapshot.stake).add(stakeDelta)).toUint128();

            if (sSnapshot.startCycle == currentCycle) {
                sSnapshot.stake = snapshotStake;
                return snapshotIndex;
            }

            snapshotIndex += 1;
        } else {

            snapshotStake = uint128(stakeDelta);
        }

        Snapshot memory mSnapshot;
        mSnapshot.stake = snapshotStake;
        mSnapshot.startCycle = currentCycle;

        history.push(mSnapshot);
    }


    function _getCycle(uint256 timestamp) internal view returns (uint16) {

        uint256 startTimestamp_ = startTimestamp;
        if (startTimestamp_ == 0) return 0;
        return (((timestamp - startTimestamp_) / uint256(cycleLengthInSeconds)) + 1).toUint16();
    }

    function _getPeriod(uint16 cycle, uint16 periodLengthInCycles_) internal pure returns (uint16) {

        if (cycle == 0) {
            return 0;
        }
        return (cycle - 1) / periodLengthInCycles_ + 1;
    }

    function _getCurrentPeriod(uint16 periodLengthInCycles_) internal view returns (uint16) {

        return _getPeriod(_getCycle(block.timestamp), periodLengthInCycles_);
    }


    function _validateAndGetNftWeight(uint256 nftId) internal view returns (uint64) {

        uint256 nonFungible = (nftId >> 255) & 1;
        uint256 tokenType = (nftId >> 240) & 0xFF;
        uint256 tokenSeason = (nftId >> 224) & 0xFF;
        uint256 tokenRarity = (nftId >> 176) & 0xFF;

        require(nonFungible == 1 && tokenType == 1 && (tokenSeason == 2 || tokenSeason == 3), "NftStaking: wrong token");

        return weightsByRarity[tokenRarity];
    }
}

interface IWhitelistedNftContract {

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

}