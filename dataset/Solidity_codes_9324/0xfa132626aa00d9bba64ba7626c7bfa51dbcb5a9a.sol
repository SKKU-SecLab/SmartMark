
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


    function mint(address to, uint256 amount) external;


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}
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

}

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}
pragma solidity ^0.8.0;


contract LDCStakingRewards is IERC721Receiver {


    uint256 public constant ONE_DAY_IN_SECONDS = 86400;
    uint256 public LDCTokensPerDayStaked = 3e18;
    mapping(uint256 => stakingInfo) public nftStakes;
    mapping(address => uint256[]) public stakedNftsByAddress;
    address private owner;
    IERC20 public immutable LDCToken;
    IERC721 public immutable LDCNFT;
    bool public stakingEnabled;

    struct stakingInfo {
        address nftOwner;
        uint64 initTimestamp;
        uint128 rewardsClaimed;
    }

    event Staked(address user, uint256 NFTid);
    event Unstaked(address user, uint256 NFTid);
    event Claimed(address user, uint256 rewardAmount);

    constructor(address _LDCToken, address _LDCNFT) {
        owner = msg.sender;
        LDCToken = IERC20(_LDCToken);
        LDCNFT = IERC721(_LDCNFT); // https://etherscan.io/address/0xacc908bbcd7f50f2e07afaec5455b73aea1d4f7d#code
        stakingEnabled = true; // Staking will be enabled as soon as the contract is deployed
    }

    modifier onlyOwner() {

        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    function transferOwnership(address newOwner) external onlyOwner {

        require(newOwner != address(0), "New owner is the zero address");
        owner = newOwner;
    }

    function toggleStaking() external onlyOwner {

        stakingEnabled = !stakingEnabled;
    }

    function updateRewardsPerDay(uint256 newRewardsPerDay) external onlyOwner {

        LDCTokensPerDayStaked = newRewardsPerDay;
    }


    function stakeLDC(uint256 NFTid) external {

        require(stakingEnabled, "Staking is currently disabled");

        nftStakes[NFTid] = stakingInfo({
            nftOwner: msg.sender,
            initTimestamp: uint64(block.timestamp),
            rewardsClaimed: 0
        });

        stakedNftsByAddress[msg.sender].push(NFTid);

        LDCNFT.safeTransferFrom(
            msg.sender,
            address(this),
            NFTid,
            bytes("stake")
        );

        emit Staked(msg.sender, NFTid);
    }

    function stakeMultipleLDC(uint256[] calldata NFTid) external {

        require(stakingEnabled, "Staking is currently disabled");
        
        uint256 len = NFTid.length;
        for (uint256 i; i < len; ++i) {
            nftStakes[NFTid[i]] = stakingInfo({
                nftOwner: msg.sender,
                initTimestamp: uint64(block.timestamp),
                rewardsClaimed: 0
            });

            stakedNftsByAddress[msg.sender].push(NFTid[i]);

            LDCNFT.safeTransferFrom(
                msg.sender,
                address(this),
                NFTid[i],
                bytes("stake")
            );
            emit Staked(msg.sender, NFTid[i]);
        }
    }

    function unstakeLDC(uint256 NFTid) external {

        require(nftStakes[NFTid].nftOwner == msg.sender, "You do not own this NFT");
        
        uint256 totalDaysStaked = (block.timestamp - nftStakes[NFTid].initTimestamp) / ONE_DAY_IN_SECONDS;
        uint256 tokensToMintAndSend = uint128(totalDaysStaked * LDCTokensPerDayStaked);
        uint256 tokensAlreadyRewarded = uint128(nftStakes[NFTid].rewardsClaimed);
        uint256 finalReward = tokensToMintAndSend - tokensAlreadyRewarded;

        uint256 indexToRemove;
        uint256 arrayLength = stakedNftsByAddress[msg.sender].length;
        for (uint256 i; i < arrayLength; ++i) {
            if (stakedNftsByAddress[msg.sender][i] == NFTid){
                indexToRemove = i;
                break;
            }
        }
        
        if (indexToRemove != arrayLength - 1){
            stakedNftsByAddress[msg.sender][indexToRemove] = stakedNftsByAddress[msg.sender][arrayLength - 1];
        }
        stakedNftsByAddress[msg.sender].pop();

        delete nftStakes[NFTid];

        if (finalReward > 0){
            LDCToken.mint(msg.sender, finalReward);
        }

        LDCNFT.safeTransferFrom(
            address(this),
            msg.sender,
            NFTid,
            bytes("unstake")
        );

        emit Unstaked(msg.sender, NFTid);
    }

    function unstakeMultipleLDC(uint256[] calldata NFTid) external {

        uint256 len = NFTid.length;
        uint256 totalDaysStaked;
        uint256 tokensToMintAndSend;
        uint256 tokensAlreadyRewarded;
        uint256 indexToRemove;
        uint256 arrayLength;
        for (uint256 i; i < len; ++i) {
            require(nftStakes[NFTid[i]].nftOwner == msg.sender, "You do not own this NFT");
            totalDaysStaked = (block.timestamp - nftStakes[NFTid[i]].initTimestamp) / ONE_DAY_IN_SECONDS;
            tokensToMintAndSend += uint128(totalDaysStaked * LDCTokensPerDayStaked);
            tokensAlreadyRewarded += uint128(nftStakes[NFTid[i]].rewardsClaimed);
            delete nftStakes[NFTid[i]];

            arrayLength = stakedNftsByAddress[msg.sender].length;
            for (uint256 j; j < arrayLength; ++j) {
                if (stakedNftsByAddress[msg.sender][j] == NFTid[i]){
                    indexToRemove = j;
                    break;
                }
            }
            if (indexToRemove != arrayLength - 1){
                stakedNftsByAddress[msg.sender][indexToRemove] = stakedNftsByAddress[msg.sender][arrayLength - 1];
            }
            stakedNftsByAddress[msg.sender].pop();
        }

        uint256 finalReward = tokensToMintAndSend - tokensAlreadyRewarded;
        if(finalReward > 0){
            LDCToken.mint(msg.sender, finalReward);
        }

        for (uint256 i; i < len; ++i) {
            LDCNFT.safeTransferFrom(
                address(this),
                msg.sender,
                NFTid[i],
                bytes("unstake")
            );
            emit Unstaked(msg.sender, NFTid[i]);
        }
    }

    function claimRewards() external {

        uint256[] memory allStakedTokens = getCurrentStakedTokensByUser(msg.sender);
        uint256 len = allStakedTokens.length;
        require(len > 0, "No NFTs currently staked");
        uint128 tokensToMintAndSend;
        uint128 tokensAlreadyRewarded;
        uint256 totalDaysStaked;
        for (uint256 i; i < len; ++i) {
            totalDaysStaked = (block.timestamp - nftStakes[allStakedTokens[i]].initTimestamp) / ONE_DAY_IN_SECONDS;
            tokensToMintAndSend += uint128(totalDaysStaked * LDCTokensPerDayStaked);
            tokensAlreadyRewarded += uint128(nftStakes[allStakedTokens[i]].rewardsClaimed);
            nftStakes[allStakedTokens[i]].rewardsClaimed = uint128(totalDaysStaked * LDCTokensPerDayStaked);
        }

        uint256 finalReward = tokensToMintAndSend - tokensAlreadyRewarded;
        require(finalReward > 0, "No rewards available yet");
        LDCToken.mint(msg.sender, finalReward);
        emit Claimed(msg.sender, finalReward);
    }

    function getCurrentTotalStakedTokens() public view returns (uint256)
    {

        return LDCNFT.balanceOf(address(this));
    }

    function getCurrentStakedTokensByUser(address user) public view returns (uint256[] memory)
    {

        return stakedNftsByAddress[user];
    }

    function getPendingRewards(address user) public view returns (uint256)
    {

        uint256[] memory allStakedTokens = getCurrentStakedTokensByUser(user);
        uint256 len = allStakedTokens.length;
        require(len > 0, "No NFTs currently staked");
        uint128 tokensToMintAndSend;
        uint128 tokensAlreadyRewarded;
        uint256 totalDaysStaked;
        for (uint256 i; i < len; ++i) {
            totalDaysStaked = (block.timestamp - nftStakes[allStakedTokens[i]].initTimestamp) / ONE_DAY_IN_SECONDS;
            tokensToMintAndSend += uint128(totalDaysStaked * LDCTokensPerDayStaked);
            tokensAlreadyRewarded += uint128(nftStakes[allStakedTokens[i]].rewardsClaimed);
        }
        uint256 finalReward = tokensToMintAndSend - tokensAlreadyRewarded;
        return finalReward;
    }

    function getPendingRewardsByNFT(uint256 NFTid) public view returns (uint256)
    {

        uint256 totalDaysStaked = (block.timestamp - nftStakes[NFTid].initTimestamp) / ONE_DAY_IN_SECONDS;
        uint256 tokensToMintAndSend = uint128(totalDaysStaked * LDCTokensPerDayStaked);
        uint256 tokensAlreadyRewarded = uint128(nftStakes[NFTid].rewardsClaimed);
        return tokensToMintAndSend - tokensAlreadyRewarded;
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}