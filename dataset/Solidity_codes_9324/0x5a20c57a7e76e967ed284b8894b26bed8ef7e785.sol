
pragma solidity ^0.8.4;
interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);
    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );
    event ApprovalForAll(address indexed account, address indexed operator, bool approved);
    event URI(string value, uint256 indexed id);
    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);

    function setApprovalForAll(address operator, bool approved) external;

    function isApprovedForAll(address account, address operator) external view returns (bool);

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}

abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

interface IERC1155Receiver is IERC165 {

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

abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}

contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }
    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}

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

}
interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}

contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

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
}
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
}
contract Staking is ERC721Holder, ERC1155Holder, Ownable {

    address public whaleMakerAddress = 0xA87121eDa32661C0c178f06F8b44F12f80ae4E88;
    address public alphaPassAddress = 0xecF78fdB130f2504fd31F70b7470A87b283EA3f5;
    address public podAddress = 0x5B3E42382C3AaAd8Ff9e106664E362C308CBa3BC;
    address public stakeMasterAddress = 0xDBef1bbCb494fAcd6cD1BF426e25dA7A10d96eAa;
    address nullAddress = 0x0000000000000000000000000000000000000000;
    uint256 public maxWalletStaked = 10;
    uint256 public contractPublishedAt = block.timestamp;
    uint256 oneMonthSeconds = 2592000; // 30 days in seconds
    struct StakingInfo {
        uint256 whaleId;
        uint256 alphaId;
        uint256 stakedAt;
    }
    mapping(address => StakingInfo[]) private _stakers;
    struct RewardState {
        uint256 unstakedRewardsAmount;
        uint256 claimedAmount;
        uint256 lastClaimedAt;
    }
    mapping(address => RewardState) private _stakerRewards;
    uint256 public claimStartTime = 1672531200; // Jan 1 2023 00:00:00 AM

    uint256[] public rewardsStepsTimestamp = [1672531199, 1704067199, 1735689599, 1767225599, 1798761599, 1830297599, 1956527999]; 
    mapping(uint256 => uint256) public rewardsStepsMonthlyAmount;

    event Staked(address staker, uint256 whaleId, uint256 alphaId);
    event Unstaked(address staker, uint256 whaleId, uint256 alphaId);
    event Claimed(address staker, uint256 amount);

    constructor() {
        rewardsStepsMonthlyAmount[1672531199] = 4500; // Dec 31 2022 11:59:59 PM
        rewardsStepsMonthlyAmount[1704067199] = 3500; // Dec 31 2023 11:59:59 PM
        rewardsStepsMonthlyAmount[1735689599] = 2500; // Dec 31 2024 11:59:59 PM
        rewardsStepsMonthlyAmount[1767225599] = 1500; // Dec 31 2025 11:59:59 PM
        rewardsStepsMonthlyAmount[1798761599] = 1000; // Dec 31 2026 11:59:59 PM
        rewardsStepsMonthlyAmount[1830297599] = 500; // Dec 31 2027 11:59:59 PM
        rewardsStepsMonthlyAmount[1956527999] = 250; // Dec 31 2031 11:59:59 PM
    }
    function getTokensStaked(address staker) public view returns (StakingInfo[] memory) {

        return _stakers[staker];
    }
    function _remove(address staker, uint256 index) internal {

        if (index >= _stakers[staker].length) return;
        for (uint256 i=index; i<_stakers[staker].length-1; i++) {
            _stakers[staker][i] = _stakers[staker][i + 1];
        }
        _stakers[staker].pop();
    }
    function _calculateRewards(address staker, uint256 stakeId) internal view returns (uint256) {

        require(stakeId<_stakers[staker].length);
        uint256 rewards = 0;
        uint256 staked_secs; // The seconds of token staken in this step
        StakingInfo memory staking_info = _stakers[staker][stakeId];
        uint256 startTs = staking_info.stakedAt; // The timestamp that the step started
        for (uint256 i=0; i<rewardsStepsTimestamp.length; i++) {
            if (rewardsStepsTimestamp[i] < block.timestamp) {
                if (startTs < rewardsStepsTimestamp[i]) {
                    staked_secs = rewardsStepsTimestamp[i] - startTs + 1;
                    rewards = rewards + staked_secs * rewardsStepsMonthlyAmount[rewardsStepsTimestamp[i]] * 10 ** 18 / oneMonthSeconds;
                    startTs = rewardsStepsTimestamp[i] + 1;
                }
            } else { // the current step
                staked_secs = block.timestamp - startTs; 
                rewards = rewards + staked_secs * rewardsStepsMonthlyAmount[rewardsStepsTimestamp[i]] * 10 ** 18 / oneMonthSeconds;
                break; // Ignore the next steps
            }
        }
        return rewards;
    }
    function stakerRewardsState(address staker) public view returns (uint256 totalRewards, uint256 claimedAmount, uint256 lastClaimedAt) {

        StakingInfo[] memory staking_info = _stakers[staker];
        RewardState memory reward_state = _stakerRewards[staker];
        uint256 staked_rewards = 0;
        for (uint256 i = 0; i < staking_info.length; i++) {
            staked_rewards = staked_rewards + _calculateRewards(staker, i);
        }
        uint256 total_rewards = staked_rewards + reward_state.unstakedRewardsAmount;
        return (total_rewards, reward_state.claimedAmount, reward_state.lastClaimedAt);
    }
    function stake(uint256 whaleId, uint256 alphaId) public {

        require(_stakers[msg.sender].length+1<=maxWalletStaked, "EXCEED_MAX_WALLET_STAKED");
        require(
            IERC721(whaleMakerAddress).ownerOf(whaleId) == msg.sender && IERC1155(alphaPassAddress).balanceOf(msg.sender, alphaId) > 0,
            "NOT_BOTH_TOKEN_OWNER"
        );
        IERC721(whaleMakerAddress).safeTransferFrom(msg.sender, address(this), whaleId);
        IERC1155(alphaPassAddress).safeTransferFrom(msg.sender, address(this), alphaId, 1, "");
        _stakers[msg.sender].push(StakingInfo(whaleId, alphaId, block.timestamp));
        emit Staked(msg.sender, whaleId, alphaId);
    }
    function unstake(uint256 stakeId) public {

        require(claimStartTime < block.timestamp, "DISABLED_CLAIM");
        require(stakeId<_stakers[msg.sender].length, "WRONG_STAKE_ID");
        StakingInfo memory staking_info = _stakers[msg.sender][stakeId];
        IERC721(whaleMakerAddress).safeTransferFrom(address(this), msg.sender, staking_info.whaleId);
        IERC1155(alphaPassAddress).safeTransferFrom(address(this), msg.sender, staking_info.alphaId, 1, "");
        uint256 rewards_amount = _calculateRewards(msg.sender, stakeId);
        _stakerRewards[msg.sender].unstakedRewardsAmount = _stakerRewards[msg.sender].unstakedRewardsAmount + rewards_amount;
        _remove(msg.sender, stakeId);
        emit Unstaked(msg.sender, staking_info.whaleId, staking_info.alphaId);
    }
    function unstakeAll() public {

        require(claimStartTime < block.timestamp, "DISABLED_CLAIM");
        require(_stakers[msg.sender].length>0, "NO_TOKEN_STAKED");
        for (uint256 i = 0; i < _stakers[msg.sender].length; i++) {
            unstake(i);
        }
    }
    function claimableAmount(address staker) public view returns (uint256) {

        uint256 available_amount;
        uint256 total_rewards;
        uint256 claimed_amount;
        uint256 last_claimed_at;
        (total_rewards, claimed_amount, last_claimed_at) = stakerRewardsState(staker);
        if (last_claimed_at < claimStartTime) last_claimed_at = 1672531200;
        uint256 current_ts = block.timestamp;
        if (current_ts < claimStartTime) available_amount = uint256(0);
        else {
            if (current_ts >= 1704067200) { // after Jan 2024
                available_amount = total_rewards - claimed_amount;
            } else {
                if ((current_ts - last_claimed_at) < oneMonthSeconds) {
                    available_amount = uint256(0);
                } else {
                    if (1672531200 <= current_ts && current_ts < 1675209600) { // current date is in Jan 2023
                        available_amount = (total_rewards - claimed_amount) * 20 / 100; // 20%
                    } else {
                        uint256 month_counts = (current_ts - last_claimed_at) / oneMonthSeconds;
                        uint256 total_percent = month_counts * 727 / 100; // 7.27% per month
                        if (total_percent > 100) total_percent = 100;
                        available_amount = (total_rewards - claimed_amount) * total_percent / 100;
                    }
                }
            }
        }
        return available_amount;
    }
    function nextClaimInSeconds(address staker) public view returns (uint256) {

        uint256 next_claim_in;
        RewardState memory reward_state = _stakerRewards[staker];
        uint256 current_ts = block.timestamp;
        if (current_ts < claimStartTime) next_claim_in = claimStartTime - current_ts;
        else {
            if (current_ts >= 1704067200) { // after Jan 2024
                next_claim_in = uint256(0);
            } else {
                next_claim_in = reward_state.lastClaimedAt + oneMonthSeconds - current_ts;
            }
        }
        return next_claim_in;
    }
    function claim() public {

        uint256 amount = claimableAmount(msg.sender);
        require(amount > 0, "ZERO_AVAILABLE_AMOUNT");
        require(amount < IERC20(podAddress).balanceOf(stakeMasterAddress), "NOT_ENOUGH_POD_MASTER");
        IERC20(podAddress).transferFrom(stakeMasterAddress, msg.sender, amount);
        _stakerRewards[msg.sender].claimedAmount = _stakerRewards[msg.sender].claimedAmount + amount;
        _stakerRewards[msg.sender].lastClaimedAt = block.timestamp;
        emit Claimed(msg.sender, amount);
    }

    function currentMonthlyRewards() public view returns (uint256) {

        uint256 cur_rewards = uint256(0);
        for (uint256 i=0; i<=rewardsStepsTimestamp.length; i++) {
            if (block.timestamp <= rewardsStepsTimestamp[i]) {
                cur_rewards = rewardsStepsMonthlyAmount[rewardsStepsTimestamp[i]] * 10 ** 18;
                break;
            }
        }
        return cur_rewards;
    }
    function setWhaleMakerAddress(address newAddress) public onlyOwner {

        whaleMakerAddress = newAddress;
    }
    function setAlphaPassAddress(address newAddress) public onlyOwner {

        alphaPassAddress = newAddress;
    }
    function setPodAddress(address newAddress) public onlyOwner {

        podAddress = newAddress;
    }
    function setStakeMasterAddress(address newAddress) public onlyOwner {

        stakeMasterAddress = newAddress;
    }
    function setMaxWalletStaked(uint256 newValue) public onlyOwner {

        maxWalletStaked = newValue;
    }
    function setClaimStartTime(uint256 newClaimStartTime) public onlyOwner {

        claimStartTime = newClaimStartTime;
    }
    function withdrawETH() external onlyOwner {

        require(address(this).balance > 0, "NO_BALANCE");
        payable(msg.sender).transfer(address(this).balance);
    }
}