pragma solidity 0.8.10;

interface IFactory {


    struct PoolData {
        address poolToken;
        address poolAddress;
        uint256 weight;
        bool isFlashPool;
    }

    function FACTORY_UID() external view returns (uint256);


    function CART() external view returns (address);


    function cartPerBlock() external view returns (uint256);

    
    function totalWeight() external view returns (uint256);


    function endBlock() external view returns (uint256);


    function getPoolData(address _poolToken) external view returns (PoolData memory);


    function getPoolAddress(address poolToken) external view returns (address);


    function isPoolExists(address _pool) external view returns (bool);

    
    function mintYieldTo(address _to, uint256 _amount) external;

}// MIT
pragma solidity 0.8.10;

struct User {
    uint256 tokenAmount;
    uint256 rewardAmount;
    uint256 totalWeight;
    uint256 subYieldRewards;
    Deposit[] deposits;
}

struct Deposit {
    uint256 tokenAmount;
    uint256 weight;
    uint64 lockedFrom;
    uint64 lockedUntil;
    bool isYield;
}

interface IPool {

    
    function CART() external view returns (address);


    function poolToken() external view returns (address);


    function isFlashPool() external view returns (bool);


    function weight() external view returns (uint256);


    function lastYieldDistribution() external view returns (uint256);


    function yieldRewardsPerWeight() external view returns (uint256);


    function usersLockingWeight() external view returns (uint256);


    function weightMultiplier() external view returns (uint256);


    function balanceOf(address _user) external view returns (uint256);


    function getDepositsLength(address _user) external view returns (uint256);


    function getOriginDeposit(address _user, uint256 _depositId) external view returns (Deposit memory);


    function getUser(address _user) external view returns (User memory);


    function stake(
        uint256 _amount,
        uint64 _lockedUntil,
        address _nftAddress,
        uint256 _nftTokenId
    ) external;


    function unstake(
        uint256 _depositId,
        uint256 _amount
    ) external;


    function sync() external;


    function processRewards() external;


    function setWeight(uint256 _weight) external;


    function NFTWeightUpdated(address _nftAddress, uint256 _nftWeight) external;


    function setWeightMultiplierbyFactory(uint256 _newWeightMultiplier) external;


    function getNFTWeight(address _nftAddress) external view returns (uint256);


    function weightToReward(uint256 _weight, uint256 rewardPerWeight) external pure returns (uint256);


    function rewardToWeight(uint256 reward, uint256 rewardPerWeight) external pure returns (uint256);


    function supportNTF(address nftAddress) external view returns (uint256);

}pragma solidity 0.8.10;
interface IERC20 {


  function totalSupply() external view returns (uint256);

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);


  function allowance(address owner, address spender) external view returns (uint256);

  function approve(address spender, uint256 amount) external returns (bool);

  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity >=0.5.0;

interface IPair {

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(address owner, address spender) external view returns (uint);


    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(address from, address to, uint value) external returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);


    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;


    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);


    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;

    function skim(address to) external;

    function sync() external;


    function initialize(address, address) external;

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
pragma solidity 0.8.10;


contract Helper {


    constructor(){}

    function getDeposit(address pool, address staker, uint256 depositId) public view returns (Deposit memory) {

        Deposit memory deposit = IPool(pool).getOriginDeposit(staker, depositId);
        if(deposit.tokenAmount != 0){
            deposit.weight = deposit.weight / deposit.tokenAmount;
        }
        return deposit;
    }

    function getAllDeposit(address pool, address staker) public view returns (Deposit[] memory) {

        uint256 depositsLength = IPool(pool).getDepositsLength(staker);
        if(depositsLength == 0) {
            return new Deposit[](0);
        }
        Deposit[] memory deposits = new Deposit[](depositsLength);
        for(uint256 i = 0; i < depositsLength; i++) {
            deposits[i] = IPool(pool).getOriginDeposit(staker, i);
            if(deposits[i].tokenAmount != 0){
                deposits[i].weight = deposits[i].weight / deposits[i].tokenAmount;
            }
        }
        return deposits;
    }

    function getDepositsByIsYield(address pool, address staker, bool isYield) public view returns (uint[] memory, Deposit[] memory) {

        uint256 depositsLength = IPool(pool).getDepositsLength(staker);
        if(depositsLength == 0) {
            return (new uint[](0), new Deposit[](0));
        }
        uint256 lengthIsYield = 0;
        for(uint256 i = 0; i < depositsLength; i++) {
            if((IPool(pool).getOriginDeposit(staker, i)).isYield == isYield) {
                lengthIsYield++;
            }
        }
        uint [] memory depositsID = new uint[](lengthIsYield);
        Deposit[] memory deposits = new Deposit[](lengthIsYield);
        uint j = 0;
        for(uint256 i = 0; i < depositsLength; i++) {
            if((IPool(pool).getOriginDeposit(staker, i)).isYield == isYield) {
                deposits[j] = IPool(pool).getOriginDeposit(staker, i);
                depositsID[j] = i;
                if(deposits[j].tokenAmount != 0){
                    deposits[j].weight = deposits[j].weight / deposits[j].tokenAmount;
                }
                j++;
            }
        }
        return (depositsID, deposits);
    }

    function getLockingWeight(address pool, uint64 lockPeriod) public view returns (uint256) {

        uint256 weightMultiplier = IPool(pool).weightMultiplier();
        uint256 stakeWeight =
            ((lockPeriod * weightMultiplier) / 365 days + weightMultiplier);
        return stakeWeight;
    }

    function getPredictedRewards(
        address factory,
        address pool,
        uint256 amount, 
        uint256 lockPeriod, 
        uint256 forecastTime, 
        uint256 yieldTime,
        address staker,
        address nftAddress,
        uint256 nftTokenId
    ) external view returns (uint256) {

        if(amount == 0){
            return 0;
        }
        require(lockPeriod == 0 || lockPeriod <= 365 days, "invalid lock interval");
        address poolToken = IPool(pool).poolToken();
        uint256 weightMultiplier = IPool(pool).weightMultiplier();
        uint256 poolWeight = (IFactory(factory).getPoolData(poolToken)).weight;
        uint256 stakeWeight = 0;
        if(lockPeriod == 0) {
            uint nft_weight = 0;
            if (nftTokenId != 0 && nftAddress != address(0) ) {
                require(IERC721(nftAddress).ownerOf(nftTokenId) == staker, "the NFT tokenId doesn't match the user");
                nft_weight = IPool(pool).supportNTF(nftAddress);
            }
            stakeWeight =  nft_weight * weightMultiplier + amount * weightMultiplier;
        }else {
            stakeWeight =
                ((lockPeriod * weightMultiplier) / 365 days + weightMultiplier) * amount;
        }
        
        require(stakeWeight > 0, "invalid input");    
        uint256 cartRewards = ((forecastTime / yieldTime) * poolWeight * IFactory(factory).cartPerBlock()) / IFactory(factory).totalWeight();
        uint256 newUsersLockingWeight = IPool(pool).usersLockingWeight() + stakeWeight;
        uint256 rewardsPerWeight = IPool(pool).rewardToWeight(cartRewards, newUsersLockingWeight);
        return IPool(pool).weightToReward(stakeWeight, rewardsPerWeight);
    }

    function pendingYieldRewards(address factory, address pool, address staker) public view returns (uint256) {

        uint256 yieldRewardsPerWeight = IPool(pool).yieldRewardsPerWeight();
        uint256 newYieldRewardsPerWeight;
        uint256 blockNumber = block.number;
        uint256 lastYieldDistribution = IPool(pool).lastYieldDistribution();
        uint256 usersLockingWeight = IPool(pool).usersLockingWeight();
        address poolToken = IPool(pool).poolToken();
        uint256 poolWeight = (IFactory(factory).getPoolData(poolToken)).weight;
        if (blockNumber > lastYieldDistribution && usersLockingWeight != 0) {
            uint256 endBlock = IFactory(factory).endBlock();
            uint256 multiplier =
                blockNumber > endBlock ? endBlock - lastYieldDistribution : blockNumber - lastYieldDistribution;
            uint256 cartRewards = (multiplier * poolWeight * IFactory(factory).cartPerBlock()) / IFactory(factory).totalWeight();
            newYieldRewardsPerWeight = IPool(pool).rewardToWeight(cartRewards, usersLockingWeight) + yieldRewardsPerWeight;
        } else {
            newYieldRewardsPerWeight = yieldRewardsPerWeight;
        }
        User memory user = IPool(pool).getUser(staker);
        uint256 pending = IPool(pool).weightToReward(user.totalWeight, newYieldRewardsPerWeight) - user.subYieldRewards;
        return pending;
    }

    function lptoTokenAmount(address lpAddress, uint256 lpAmount) external view returns(uint256 amount0, uint256 amount1){

        uint lpSupply = IERC20(lpAddress).totalSupply();
        (uint112 reserve0, uint112 reserve1, ) = IPair(lpAddress).getReserves();
        uint amount0 = uint(reserve0) * lpAmount / lpSupply;
        uint amount1 = uint(reserve1) * lpAmount/ lpSupply;
        return (amount0, amount1);
    }

    
}