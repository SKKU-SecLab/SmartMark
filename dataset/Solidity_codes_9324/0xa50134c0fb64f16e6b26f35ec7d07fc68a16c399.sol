
pragma solidity =0.8.9;


interface IUnifarmCohort {


    function stake(
        uint32 fid,
        uint256 tokenId,
        address account,
        address referralAddress
    ) external;



    function unStake(
        address user,
        uint256 tokenId,
        uint256 flag
    ) external;



    function collectPrematureRewards(address user, uint256 tokenId) external;



    function buyBooster(
        address user,
        uint256 bpid,
        uint256 tokenId
    ) external;



    function setPortionAmount(uint256 tokenId, uint256 stakedAmount) external;



    function disableBooster(uint256 tokenId) external;



    function safeWithdrawEth(address withdrawableAddress, uint256 amount) external returns (bool);



    function safeWithdrawAll(
        address withdrawableAddress,
        address[] memory tokens,
        uint256[] memory amounts
    ) external;



    function viewStakingDetails(uint256 tokenId)
        external
        view
        returns (
            uint32 fid,
            uint256 nftTokenId,
            uint256 stakedAmount,
            uint256 startBlock,
            uint256 endBlock,
            address originalOwner,
            address referralAddress,
            bool isBooster
        );



    event BoosterBuyHistory(uint256 indexed nftTokenId, address indexed user, uint256 bpid);


    event Claim(uint32 fid, uint256 indexed tokenId, address indexed userAddress, address indexed referralAddress, uint256 rValue);


    event ReferedBy(uint256 indexed tokenId, address indexed referralAddress, uint256 stakedAmount, uint32 fid);
}// GNU GPLv3

pragma solidity =0.8.9;

interface IUnifarmRewardRegistryUpgradeable {


    function distributeRewards(
        address cohortId,
        address userAddress,
        address influencerAddress,
        uint256 rValue,
        bool hasContainsWrappedToken
    ) external;



    function addInfluencers(address[] memory userAddresses, uint256[] memory referralPercentages) external;



    function updateMulticall(address newMultiCallAddress) external;



    function updateRefPercentage(uint256 newRefPercentage) external;



    function setRewardTokenDetails(address cohortId, bytes calldata rewards) external;



    function setRewardCap(
        address cohortId,
        address[] memory rewardTokenAddresses,
        uint256[] memory rewards
    ) external returns (bool);



    function safeWithdrawEth(address withdrawableAddress, uint256 amount) external returns (bool);



    function safeWithdrawAll(
        address withdrawableAddress,
        address[] memory tokens,
        uint256[] memory amounts
    ) external;



    function getRewardTokens(address cohortId) external view returns (address[] memory rewardTokens, uint256[] memory pbr);



    function getInfluencerReferralPercentage(address influencerAddress) external view returns (uint256 referralPercentage);


    event UpdatedRefPercentage(uint256 newRefPercentage);

    event SetRewardTokenDetails(address indexed cohortId, bytes rewards);
}// GNU GPLv3

pragma solidity =0.8.9;


library CheckPointReward {


    function getBlockDifference(uint256 from, uint256 to) internal pure returns (uint256) {

        return to - from;
    }


    function getCheckpoint(
        uint256 from,
        uint256 to,
        uint256 epochBlocks
    ) internal pure returns (uint256) {

        uint256 blockDifference = getBlockDifference(from, to);
        return uint256(blockDifference / epochBlocks);
    }


    function getCurrentCheckpoint(
        uint256 startBlock,
        uint256 endBlock,
        uint256 epochBlocks
    ) internal view returns (uint256 checkpoint) {

        uint256 yfEndBlock = block.number;
        if (yfEndBlock > endBlock) {
            yfEndBlock = endBlock;
        }
        checkpoint = getCheckpoint(startBlock, yfEndBlock, epochBlocks);
    }


    function getStartCheckpoint(
        uint256 startBlock,
        uint256 userStakedBlock,
        uint256 epochBlocks
    ) internal pure returns (uint256 checkpoint) {

        checkpoint = getCheckpoint(startBlock, userStakedBlock, epochBlocks);
    }
}// GNU GPLv3

pragma solidity =0.8.9;



library TransferHelpers {


    function safeTransferFrom(
        address target,
        address sender,
        address recipient,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = target.call(abi.encodeWithSelector(0x23b872dd, sender, recipient, amount));
        require(success && data.length > 0, 'STFF');
    }


    function safeTransfer(
        address target,
        address to,
        uint256 amount
    ) internal {

        (bool success, bytes memory data) = target.call(abi.encodeWithSelector(0xa9059cbb, to, amount));
        require(success && data.length > 0, 'STF');
    }


    function safeTransferParentChainToken(address to, uint256 value) internal {

        (bool success, ) = to.call{value: uint128(value)}(new bytes(0));
        require(success, 'STPCF');
    }
}// GNU GPLv3

pragma solidity =0.8.9;

abstract contract CohortFactory {
    function owner() public view virtual returns (address);


    function getStorageContracts()
        public
        view
        virtual
        returns (
            address registry,
            address nftManager,
            address rewardRegistry
        );
}// GNU GPLv3


pragma solidity =0.8.9;


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
}// GNU GPLv3

pragma solidity =0.8.9;
pragma abicoder v2;


interface IUnifarmCohortRegistryUpgradeable {


    function setTokenMetaData(
        address cohortId,
        uint32 fid_,
        address farmToken_,
        uint256 userMinStake_,
        uint256 userMaxStake_,
        uint256 totalStakeLimit_,
        uint8 decimals_,
        bool skip_
    ) external;



    function setCohortDetails(
        address cohortId,
        string memory cohortVersion_,
        uint256 startBlock_,
        uint256 endBlock_,
        uint256 epochBlocks_,
        bool hasLiquidityMining_,
        bool hasContainsWrappedToken_,
        bool hasCohortLockinAvaliable_
    ) external;



    function addBoosterPackage(
        address cohortId_,
        address paymentToken_,
        address boosterVault_,
        uint256 bpid_,
        uint256 boosterPackAmount_
    ) external;



    function updateMulticall(address newMultiCallAddress) external;



    function setWholeCohortLock(address cohortId, bool status) external;



    function setCohortLockStatus(
        address cohortId,
        bytes4 actionToLock,
        bool status
    ) external;



    function setCohortTokenLockStatus(
        bytes32 cohortSalt,
        bytes4 actionToLock,
        bool status
    ) external;



    function validateStakeLock(address cohortId, uint32 farmId) external view;



    function validateUnStakeLock(address cohortId, uint32 farmId) external view;



    function getCohortToken(address cohortId, uint32 farmId)
        external
        view
        returns (
            uint32 fid,
            address farmToken,
            uint256 userMinStake,
            uint256 userMaxStake,
            uint256 totalStakeLimit,
            uint8 decimals,
            bool skip
        );



    function getCohort(address cohortId)
        external
        view
        returns (
            string memory cohortVersion,
            uint256 startBlock,
            uint256 endBlock,
            uint256 epochBlocks,
            bool hasLiquidityMining,
            bool hasContainsWrappedToken,
            bool hasCohortLockinAvaliable
        );



    function getBoosterPackDetails(address cohortId, uint256 bpid)
        external
        view
        returns (
            address cohortId_,
            address paymentToken_,
            address boosterVault,
            uint256 boosterPackAmount
        );



    event TokenMetaDataDetails(
        address indexed cohortId,
        address indexed farmToken,
        uint32 indexed fid,
        uint256 userMinStake,
        uint256 userMaxStake,
        uint256 totalStakeLimit,
        uint8 decimals,
        bool skip
    );


    event AddedCohortDetails(
        address indexed cohortId,
        string indexed cohortVersion,
        uint256 startBlock,
        uint256 endBlock,
        uint256 epochBlocks,
        bool indexed hasLiquidityMining,
        bool hasContainsWrappedToken,
        bool hasCohortLockinAvaliable
    );


    event BoosterDetails(address indexed cohortId, uint256 indexed bpid, address paymentToken, uint256 boosterPackAmount);
}// GNU GPLv3

pragma solidity =0.8.9;

interface IWETH {


    function deposit() external payable;


    function transfer(address to, uint256 value) external returns (bool);



    function withdraw(uint256) external;

}// GNU GPLv3

pragma solidity =0.8.9;



library CohortHelper {


    function getBlockNumber() internal view returns (uint256) {

        return block.number;
    }


    function owner(address factory) internal view returns (address) {

        return CohortFactory(factory).owner();
    }


    function verifyCaller(address factory)
        internal
        view
        returns (
            address registry,
            address nftManager,
            address rewardRegistry
        )
    {

        (registry, nftManager, rewardRegistry) = getStorageContracts(factory);
        require(msg.sender == nftManager, 'ONM');
    }


    function getCohort(address registry, address cohortId)
        internal
        view
        returns (
            string memory cohortVersion,
            uint256 startBlock,
            uint256 endBlock,
            uint256 epochBlocks,
            bool hasLiquidityMining,
            bool hasContainsWrappedToken,
            bool hasCohortLockinAvaliable
        )
    {

        (
            cohortVersion,
            startBlock,
            endBlock,
            epochBlocks,
            hasLiquidityMining,
            hasContainsWrappedToken,
            hasCohortLockinAvaliable
        ) = IUnifarmCohortRegistryUpgradeable(registry).getCohort(cohortId);
    }


    function getCohortToken(
        address registry,
        address cohortId,
        uint32 farmId
    )
        internal
        view
        returns (
            uint32 fid,
            address farmToken,
            uint256 userMinStake,
            uint256 userMaxStake,
            uint256 totalStakeLimit,
            uint8 decimals,
            bool skip
        )
    {

        (fid, farmToken, userMinStake, userMaxStake, totalStakeLimit, decimals, skip) = IUnifarmCohortRegistryUpgradeable(registry).getCohortToken(
            cohortId,
            farmId
        );
    }


    function getBoosterPackDetails(
        address registry,
        address cohortId,
        uint256 bpid
    )
        internal
        view
        returns (
            address cohortId_,
            address paymentToken_,
            address boosterVault,
            uint256 boosterPackAmount
        )
    {

        (cohortId_, paymentToken_, boosterVault, boosterPackAmount) = IUnifarmCohortRegistryUpgradeable(registry).getBoosterPackDetails(
            cohortId,
            bpid
        );
    }


    function getCohortBalance(address token, uint256 totalStaking) internal view returns (uint256 cohortBalance) {

        uint256 contractBalance = IERC20(token).balanceOf(address(this));
        cohortBalance = contractBalance - totalStaking;
    }


    function getStorageContracts(address factory)
        internal
        view
        returns (
            address registry,
            address nftManager,
            address rewardRegistry
        )
    {

        (registry, nftManager, rewardRegistry) = CohortFactory(factory).getStorageContracts();
    }


    function depositWETH(address weth, uint256 amount) internal {

        IWETH(weth).deposit{value: amount}();
    }


    function validateStakeLock(
        address registry,
        address cohortId,
        uint32 farmId
    ) internal view {

        IUnifarmCohortRegistryUpgradeable(registry).validateStakeLock(cohortId, farmId);
    }


    function validateUnStakeLock(
        address registry,
        address cohortId,
        uint32 farmId
    ) internal view {

        IUnifarmCohortRegistryUpgradeable(registry).validateUnStakeLock(cohortId, farmId);
    }
}// GNU GPLv3

pragma solidity =0.8.9;




contract UnifarmCohort is IUnifarmCohort {

    receive() external payable {}

    struct Stakes {
        uint32 fid;
        uint256 nftTokenId;
        uint256 stakedAmount;
        uint256 startBlock;
        uint256 endBlock;
        address originalOwner;
        address referralAddress;
        bool isBooster;
    }

    address public immutable factory;

    mapping(uint32 => uint256) public totalStaking;

    mapping(uint32 => mapping(uint256 => uint256)) public priorEpochATVL;

    mapping(uint256 => Stakes) public stakes;

    mapping(address => mapping(uint256 => uint256)) public userTotalStaking;


    constructor(address factory_) {
        factory = factory_;
    }

    modifier onlyOwner() {

        _onlyOwner();
        _;
    }


    function _onlyOwner() internal view {

        require(msg.sender == CohortHelper.owner(factory), 'ONA');
    }


    function computeRValue(
        uint32 farmId,
        uint256 startEpoch,
        uint256 currentEpoch,
        uint256 stakedAmount,
        uint256 epochBlocks,
        uint256 userStakedBlock,
        uint256 totalStakeLimit,
        bool isBoosterBuyed
    ) internal view returns (uint256 r) {

        uint256 i = startEpoch;
        if (i == currentEpoch) {
            r = 0;
        }
        while (i < currentEpoch) {
            uint256 eligibleBlocks;
            if (userStakedBlock > (i * epochBlocks)) {
                eligibleBlocks = ((i + 1) * epochBlocks) - userStakedBlock;
            } else {
                eligibleBlocks = epochBlocks;
            }
            if (isBoosterBuyed == false) {
                r += (stakedAmount * 1e12 * eligibleBlocks) / totalStakeLimit;
            } else {
                uint256 priorTotalStaking = priorEpochATVL[farmId][i];
                uint256 priorEpochATotalStaking = priorTotalStaking > 0 ? priorTotalStaking : totalStaking[farmId];
                r += (stakedAmount * 1e12 * eligibleBlocks) / priorEpochATotalStaking;
            }
            i++;
        }
    }


    function buyBooster(
        address account,
        uint256 bpid,
        uint256 tokenId
    ) external override {

        (, address nftManager, ) = CohortHelper.getStorageContracts(factory);
        require(msg.sender == nftManager || msg.sender == CohortHelper.owner(factory), 'IS');
        require(stakes[tokenId].isBooster == false, 'AB');
        stakes[tokenId].isBooster = true;
        emit BoosterBuyHistory(tokenId, account, bpid);
    }


    function validateStake(address registry) internal view returns (uint256 epoch) {

        (, uint256 startBlock, uint256 endBlock, uint256 epochBlocks, , , ) = CohortHelper.getCohort(registry, address(this));
        require(block.number < endBlock, 'SC');
        epoch = CheckPointReward.getCurrentCheckpoint(startBlock, endBlock, epochBlocks);
    }


    function stake(
        uint32 fid,
        uint256 tokenId,
        address user,
        address referralAddress
    ) external override {

        (address registry, , ) = CohortHelper.verifyCaller(factory);

        require(user != referralAddress, 'SRNA');
        CohortHelper.validateStakeLock(registry, address(this), fid);

        uint256 epoch = validateStake(registry);

        (, address farmToken, uint256 userMinStake, uint256 userMaxStake, uint256 totalStakeLimit, , ) = CohortHelper.getCohortToken(
            registry,
            address(this),
            fid
        );

        require(farmToken != address(0), 'FTNE');
        uint256 stakeAmount = CohortHelper.getCohortBalance(farmToken, totalStaking[fid]);

        {
            userTotalStaking[user][fid] = userTotalStaking[user][fid] + stakeAmount;
            totalStaking[fid] = totalStaking[fid] + stakeAmount;
            require(stakeAmount >= userMinStake, 'UMF');
            require(userTotalStaking[user][fid] <= userMaxStake, 'UMSF');
            require(totalStaking[fid] <= totalStakeLimit, 'TSLF');
            priorEpochATVL[fid][epoch] = totalStaking[fid];
        }

        stakes[tokenId].fid = fid;
        stakes[tokenId].nftTokenId = tokenId;
        stakes[tokenId].stakedAmount = stakeAmount;
        stakes[tokenId].startBlock = block.number;
        stakes[tokenId].originalOwner = user;
        stakes[tokenId].referralAddress = referralAddress;

        emit ReferedBy(tokenId, referralAddress, stakeAmount, fid);
    }


    function validateUnstakeOrClaim(
        address registry,
        uint256 userStakedBlock,
        uint256 flag
    ) internal view returns (uint256[5] memory, bool) {

        uint256[5] memory blocksData;
        (, uint256 startBlock, uint256 endBlock, uint256 epochBlocks, , bool hasContainWrappedToken, bool hasCohortLockinAvaliable) = CohortHelper
            .getCohort(registry, address(this));

        if (hasCohortLockinAvaliable && flag == 0) {
            require(block.number > endBlock, 'CIL');
        }

        blocksData[0] = CheckPointReward.getStartCheckpoint(startBlock, userStakedBlock, epochBlocks);
        blocksData[1] = CheckPointReward.getCurrentCheckpoint(startBlock, endBlock, epochBlocks);
        blocksData[2] = endBlock;
        blocksData[3] = epochBlocks;
        blocksData[4] = startBlock;
        return (blocksData, hasContainWrappedToken);
    }


    function updateUserTotalStaking(
        address user,
        uint256 stakedAmount,
        uint32 fid
    ) internal {

        userTotalStaking[user][fid] = userTotalStaking[user][fid] - stakedAmount;
    }


    function unStake(
        address user,
        uint256 tokenId,
        uint256 flag
    ) external override {

        (address registry, , address rewardRegistry) = CohortHelper.verifyCaller(factory);

        Stakes memory staked = stakes[tokenId];

        if (flag == 0) {
            CohortHelper.validateUnStakeLock(registry, address(this), staked.fid);
        }

        stakes[tokenId].endBlock = block.number;

        (, address farmToken, , , uint256 totalStakeLimit, , bool skip) = CohortHelper.getCohortToken(registry, address(this), staked.fid);

        (uint256[5] memory blocksData, bool hasContainWrapToken) = validateUnstakeOrClaim(registry, staked.startBlock, flag);

        uint256 rValue = computeRValue(
            staked.fid,
            blocksData[0],
            blocksData[1],
            staked.stakedAmount,
            blocksData[3],
            (staked.startBlock - (blocksData[4])),
            totalStakeLimit,
            staked.isBooster
        );
        {
            totalStaking[staked.fid] = totalStaking[staked.fid] - staked.stakedAmount;

            updateUserTotalStaking(staked.originalOwner, staked.stakedAmount, staked.fid);

            if (CohortHelper.getBlockNumber() < blocksData[2]) {
                priorEpochATVL[staked.fid][blocksData[1]] = totalStaking[staked.fid];
            }
            if (skip == false) {
                TransferHelpers.safeTransfer(farmToken, user, staked.stakedAmount);
            }
        }

        if (rValue > 0) {
            IUnifarmRewardRegistryUpgradeable(rewardRegistry).distributeRewards(
                address(this),
                user,
                staked.referralAddress,
                rValue,
                hasContainWrapToken
            );
        }

        emit Claim(staked.fid, tokenId, user, staked.referralAddress, rValue);
    }


    function collectPrematureRewards(address user, uint256 tokenId) external override {

        (address registry, , address rewardRegistry) = CohortHelper.verifyCaller(factory);
        Stakes memory staked = stakes[tokenId];

        CohortHelper.validateUnStakeLock(registry, address(this), staked.fid);

        uint256 stakedAmount = staked.stakedAmount;

        (uint256[5] memory blocksData, bool hasContainWrapToken) = validateUnstakeOrClaim(registry, staked.startBlock, 1);
        require(blocksData[2] > block.number, 'FNA');

        (, , , uint256 totalStakeLimit, , , ) = CohortHelper.getCohortToken(registry, address(this), staked.fid);

        stakes[tokenId].startBlock = block.number;

        uint256 rValue = computeRValue(
            staked.fid,
            blocksData[0],
            blocksData[1],
            stakedAmount,
            blocksData[3],
            (staked.startBlock - blocksData[4]),
            totalStakeLimit,
            staked.isBooster
        );

        require(rValue > 0, 'NRM');

        IUnifarmRewardRegistryUpgradeable(rewardRegistry).distributeRewards(address(this), user, staked.referralAddress, rValue, hasContainWrapToken);

        emit Claim(staked.fid, tokenId, user, staked.referralAddress, rValue);
    }


    function setPortionAmount(uint256 tokenId, uint256 stakedAmount) external onlyOwner {

        stakes[tokenId].stakedAmount = stakedAmount;
    }


    function disableBooster(uint256 tokenId) external onlyOwner {

        stakes[tokenId].isBooster = false;
    }


    function safeWithdrawEth(address withdrawableAddress, uint256 amount) external onlyOwner returns (bool) {

        require(withdrawableAddress != address(0), 'IWA');
        TransferHelpers.safeTransferParentChainToken(withdrawableAddress, amount);
        return true;
    }


    function safeWithdrawAll(
        address withdrawableAddress,
        address[] memory tokens,
        uint256[] memory amounts
    ) external onlyOwner {

        require(withdrawableAddress != address(0), 'IWA');
        require(tokens.length == amounts.length, 'SF');
        uint8 numberOfTokens = uint8(tokens.length);
        uint8 i = 0;
        while (i < numberOfTokens) {
            TransferHelpers.safeTransfer(tokens[i], withdrawableAddress, amounts[i]);
            i++;
        }
    }


    function viewStakingDetails(uint256 tokenId)
        public
        view
        override
        returns (
            uint32 fid,
            uint256 nftTokenId,
            uint256 stakedAmount,
            uint256 startBlock,
            uint256 endBlock,
            address originalOwner,
            address referralAddress,
            bool isBooster
        )
    {

        Stakes memory userStake = stakes[tokenId];
        return (
            userStake.fid,
            userStake.nftTokenId,
            userStake.stakedAmount,
            userStake.startBlock,
            userStake.endBlock,
            userStake.originalOwner,
            userStake.referralAddress,
            userStake.isBooster
        );
    }
}// MIT

pragma solidity =0.8.9;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, 'Address: insufficient balance');

        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, 'Address: low-level call failed');
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

        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, 'Address: insufficient balance for call');
        require(isContract(target), 'Address: call to non-contract');

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, 'Address: low-level static call failed');
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), 'Address: static call to non-contract');

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

pragma solidity =0.8.9;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, 'CIAI');

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

    modifier onlyInitializing() {
        require(_initializing, 'CINI');
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// GNU GPLv3

pragma solidity =0.8.9;

interface IUnifarmCohortFactoryUpgradeable {


    function setStorageContracts(
        address registry_,
        address nftManager_,
        address rewardRegistry_
    ) external;



    function createUnifarmCohort(bytes32 salt) external returns (address cohortId);



    function computeCohortAddress(bytes32 salt) external view returns (address);



    function getStorageContracts()
        external
        view
        returns (
            address registry,
            address nftManager,
            address rewardRegistry
        );



    function obtainNumberOfCohorts() external view returns (uint256);

}// GNU GPLv3

pragma solidity =0.8.9;



contract UnifarmCohortFactoryUpgradeable is IUnifarmCohortFactoryUpgradeable, Initializable {

    struct StorageContract {
        address registry;
        address nftManager;
        address rewardRegistry;
    }

    address private _owner;

    StorageContract internal storageContracts;

    address[] public cohorts;

    event CohortConstructed(address cohortId);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {

        require(owner() == msg.sender, 'ONA');
        _;
    }


    function __UnifarmCohortFactoryUpgradeable_init() external initializer {

        _transferOwnership(msg.sender);
    }


    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), 'NOIA');
        _transferOwnership(newOwner);
    }


    function _transferOwnership(address newOwner) internal virtual {

        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }


    function setStorageContracts(
        address registry_,
        address nftManager_,
        address rewardRegistry_
    ) external onlyOwner {

        storageContracts = StorageContract({registry: registry_, nftManager: nftManager_, rewardRegistry: rewardRegistry_});
    }


    function owner() public view returns (address) {

        return _owner;
    }


    function createUnifarmCohort(bytes32 salt) external override onlyOwner returns (address cohortId) {

        bytes memory bytecode = abi.encodePacked(type(UnifarmCohort).creationCode, abi.encode(address(this)));
        assembly {
            cohortId := create2(0, add(bytecode, 0x20), mload(bytecode), salt)
        }
        cohorts.push(cohortId);
        emit CohortConstructed(cohortId);
    }


    function computeCohortAddress(bytes32 salt) public view override returns (address) {

        bytes memory bytecode = abi.encodePacked(type(UnifarmCohort).creationCode, abi.encode(address(this)));
        bytes32 initCode = keccak256(bytecode);
        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, initCode)))));
    }


    function obtainNumberOfCohorts() public view override returns (uint256) {

        return cohorts.length;
    }


    function getStorageContracts()
        public
        view
        override
        returns (
            address,
            address,
            address
        )
    {

        return (storageContracts.registry, storageContracts.nftManager, storageContracts.rewardRegistry);
    }

    uint256[49] private __gap;
}