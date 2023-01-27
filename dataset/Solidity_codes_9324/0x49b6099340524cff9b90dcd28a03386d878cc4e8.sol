





pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    
    function mint(address account, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


pragma solidity ^0.5.0;

interface ERC721 /* is ERC165 */ {

    event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

    event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    function balanceOf(address _owner) external view returns (uint256);


    function ownerOf(uint256 _tokenId) external view returns (address);



    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external;



    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external;



    function transferFrom(address _from, address _to, uint256 _tokenId) external;



    function approve(address _approved, uint256 _tokenId) external;


    function setApprovalForAll(address _operator, bool _approved) external;


    function getApproved(uint256 _tokenId) external view returns (address);


    function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}

interface IOneOAKGovernance {

    function getGovernanceContract(uint256 _type) external view returns (address);

}

interface INFTGovernance {

    function getListingActiveDelay() external view returns (uint256);

    function getBuyBonusResidual() external view returns (uint256);

    function getMarketFee() external view returns (uint256);

    function getAbsoluteMinPrice() external view returns (uint256);

    function getMinPrice() external view returns (uint256);

    function getMaxPrice() external view returns (uint256);

    function getTokensForPrice(uint256 price) external view returns (uint256);

    function getApproved(uint256 _tokenId) external view returns (address);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function getNftAddress(uint256 _tokenId) external view returns (address);

}

contract IRewardDistributionRecipient is Ownable {

    event RewardDistributionChanged(address indexed rewardDistribution);

    address public rewardDistribution;

    function notifyRewardAmount(uint256 reward) external;


    modifier onlyRewardDistribution() {

        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistribution(address _rewardDistribution)
        external
        onlyOwner
    {

        rewardDistribution = _rewardDistribution;

        emit RewardDistributionChanged(rewardDistribution);
    }
}

contract OneOAK721Pool is IRewardDistributionRecipient {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    
    IERC20 public rewardToken;
    IOneOAKGovernance public governanceContract;
    address public rewardsPoolAddress;
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;

    uint256 public constant DURATION      = 62500000; // ~723 days
    uint256 public constant LOCKUP_HURDLE = 31250000; // 365 days
    uint256 public constant LOCKUP_PERIOD = 31250000; // 365 days
    uint256 public constant LOCKUP_FACTOR = 10; // 10% ulocked immediately, 90% locked

    uint256 public starttime = 1616169600; // 2021-03-19 16:00:00 (UTC UTC +00:00)
    mapping(address => uint256) public unlockStart;

    uint256 public periodFinish = 0;
    mapping(address => uint256) public unlockEnd;

    uint256 public rewardRate = 0;
    mapping(address => uint256) public unlockedRewardRate;

    uint256 public lastUpdateTime;
    mapping(address => uint256) public lastUnlockedUpdateTime;

    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public unlockedRewardPerTokenStored;

    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public userUnlockedRewardPerTokenPaid;

    mapping(address => uint256) public rewards; 
    mapping(address => uint256) public unlockedRewards;
    
    mapping(address => uint256) public penalties;

    mapping(address => uint256) public allTimeLockedRewards;
    
    mapping(address => mapping(uint256 => mapping(uint256 => Listing))) public listings;
    
    struct Listing { 
       uint256 blockNumber;
       uint256 price;
       uint256 tokenId;
       uint256 tokensStaked;
       address seller;
       bool active;
    }
    
    event RewardLocked(address indexed user, uint256 reward, uint256 start, uint256 end);
    event RewardAdded(uint256 reward);
    event Staked(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    event NftSold(address indexed seller, address buyer, uint256 nftType, uint256 nftId, uint256 price);

    constructor(address _oakTokenAddress, address _governanceContract, address _rewardsPoolAddress) public {
        rewardToken = IERC20(_oakTokenAddress);
        governanceContract = IOneOAKGovernance(_governanceContract);
        rewardsPoolAddress = _rewardsPoolAddress;
    }

    modifier checkStart() {

        require(block.timestamp >= starttime,"not start");
        _;
    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }

    modifier updateUnlockedReward(address account) {

        unlockedRewardPerTokenStored[account] = unlockedRewardForAccount(account);
        lastUnlockedUpdateTime[account] = lastTimeUnlockedRewardApplicable(account);
        if (account != address(0)) {
            unlockedRewards[account] = unlockedEarned(account);
            userUnlockedRewardPerTokenPaid[account] = unlockedRewardPerTokenStored[account];
        }
        _;
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }
    
    function lastTimeUnlockedRewardApplicable(address account) public view returns (uint256) {

        return Math.min(block.timestamp, unlockEnd[account]);
    }

    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(totalSupply())
            );
    }    

    function unlockedRewardForAccount(address account) public view returns (uint256) {

        if (lastTimeUnlockedRewardApplicable(account) < lastUnlockedUpdateTime[account]) {
            return 0;
        } 
        return
            unlockedRewardPerTokenStored[account].add(
                lastTimeUnlockedRewardApplicable(account)
                    .sub(lastUnlockedUpdateTime[account])
                    .mul(unlockedRewardRate[account])
                    .mul(1e18)
            );
    }

    function earned(address account) public view returns (uint256) {

        if (penalties[account] >= balanceOf(account)) {
            return 0;
        } else {
            return
                (balanceOf(account).sub(penalties[account]))
                    .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                    .div(1e18)
                    .add(rewards[account]);
        }
    }

    function unlockedEarned(address account) public view returns (uint256) {

        if (block.timestamp <= unlockStart[account] 
            || penalties[account] >= unlockedRewardForAccount(account)
            || userUnlockedRewardPerTokenPaid[account] >= (unlockedRewardForAccount(account).sub(penalties[account]))
        ) {
            return 0;
        }
        return 
            (unlockedRewardForAccount(account).sub(penalties[account]))
                .sub(userUnlockedRewardPerTokenPaid[account])
                .div(1e18)
                .add(unlockedRewards[account]);
    }

    function addRewards(address account, uint256 amount) private updateReward(account) checkStart {

        require(amount > 0, "Cannot stake 0");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Staked(account, amount);
    }

    function removeRewards(address account, uint256 amount) private updateReward(account) checkStart {

        require(amount > 0, "Cannot withdraw 0");
        _totalSupply = _totalSupply.sub(amount);
        _balances[account] = _balances[account].sub(amount);
        emit Withdrawn(account, amount);
    }

    function exit() external {

        removeRewards(msg.sender, balanceOf(msg.sender));
        getReward();
    }
        
    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }

    function getReward() public updateReward(msg.sender) checkStart {

        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            
            rewardToken.mint(address(this), reward);

            uint256 availableReward = reward.div(LOCKUP_FACTOR);
            uint256 lockedReward = reward.sub(availableReward);
    

            updateLockedAmount(msg.sender, lockedReward);
            
            rewardToken.safeTransfer(msg.sender, availableReward);
            emit RewardPaid(msg.sender, availableReward);
        }
    }

    function getUnlockedReward() public updateUnlockedReward(msg.sender) checkStart {

        uint256 reward = unlockedEarned(msg.sender);
        if (reward > 0) {
            unlockedRewards[msg.sender] = 0;
            
            rewardToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }

    function notifyRewardAmount(uint256 reward)
        external
        onlyRewardDistribution
        updateReward(address(0))
    {

        if (block.timestamp > starttime) {
          if (block.timestamp >= periodFinish) {
              rewardRate = reward.div(DURATION);
          } else {
              uint256 remaining = periodFinish.sub(block.timestamp);
              uint256 leftover = remaining.mul(rewardRate);
              rewardRate = reward.add(leftover).div(DURATION);
          }
          lastUpdateTime = block.timestamp;
          periodFinish = block.timestamp.add(DURATION);
          emit RewardAdded(reward);
        } else {
          rewardRate = reward.div(DURATION);
          lastUpdateTime = starttime;
          periodFinish = starttime.add(DURATION);
          emit RewardAdded(reward);
        }
    }

    function updateLockedAmount(address account, uint256 reward)
        internal
    {   

        if (unlockStart[account] > 0) {
            uint256 remaining = unlockEnd[account].sub(block.timestamp);
            uint256 leftover = remaining.mul(unlockedRewardRate[account]);
            unlockedRewardRate[account] = reward.add(leftover).div(LOCKUP_PERIOD);

            if (block.timestamp >= unlockStart[account]) {
                unlockEnd[account] = block.timestamp.add(LOCKUP_PERIOD);
            }

            lastUnlockedUpdateTime[account] = block.timestamp;
        } else {
            unlockedRewardRate[account] = reward.div(LOCKUP_PERIOD);
            unlockStart[account] = block.timestamp.add(LOCKUP_HURDLE);
            unlockEnd[account] = unlockStart[account].add(LOCKUP_PERIOD);
            lastUnlockedUpdateTime[account] = unlockStart[account];
        }

        allTimeLockedRewards[account] = allTimeLockedRewards[account].add(reward);
        emit RewardLocked(account, reward, unlockStart[account], unlockEnd[account]);
    }

    function getOwner(uint256 _type, uint256 _tokenId) public view returns (address) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).ownerOf(_tokenId);
    }
        
    function getApproved(uint256 _type, uint256 _tokenId) public view returns (address) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).getApproved(_tokenId);
    }
    
    function getMinPrice(uint _type) public view returns (uint256) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).getMinPrice();
    }
    
    function getMaxPrice(uint _type) public view returns (uint256) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).getMaxPrice();
    }
    
    function getBuyBonusResidual(uint _type) public view returns (uint256) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).getBuyBonusResidual();
    }
    
    function getTokensForPrice(uint _type, uint price) public view returns (uint256) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).getTokensForPrice(price);
    }
    
    function getMarketFee(uint _type) public view returns (uint256) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).getMarketFee();
    }
    
    function getAbsoluteMinPrice(uint _type) public view returns (uint256) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).getAbsoluteMinPrice();
    }

    function getListingActiveDelay(uint _type) public view returns (uint256) {

        address _governanceContract = governanceContract.getGovernanceContract(_type);
        return INFTGovernance(_governanceContract).getListingActiveDelay();
    }

    function list(uint _type, uint256 _tokenId, uint256 _price) public {

        address user = msg.sender;
        address owner = getOwner(_type, _tokenId);
        address approved = getApproved(_type, _tokenId);
        
        require(address(this) == approved, "Approval required");
        require(user == owner, "Owner required");
        require(_price >= getAbsoluteMinPrice(_type), "Price too low");

        Listing storage previousListing = listings[owner][_type][_tokenId];
        if (previousListing.active) {
            uint256 tokensStaked = previousListing.tokensStaked;
            if (tokensStaked > 0) { 
                removeRewards(user, tokensStaked);
            }
        }
        
        uint256 tokensForPrice = getTokensForPrice(_type, _price);

        Listing memory listing = Listing({
            blockNumber: block.number,
            price: _price, 
            tokenId: _tokenId, 
            seller: user,
            tokensStaked: tokensForPrice,
            active: true
        });
        listings[user][_type][_tokenId] = listing;
        
        if (tokensForPrice > 0) {
            addRewards(user, tokensForPrice);
            emit Staked(user, tokensForPrice);
        }
    }
    
    function cancel(uint256 _type, uint256 _tokenId) external {

        address user = msg.sender;
        Listing storage listing = listings[user][_type][_tokenId];
        listing.active = false;
        
        uint256 tokensStaked = listing.tokensStaked;
        if (tokensStaked > 0) {
            removeRewards(user, tokensStaked);
        }
    }
    
    function staleListing(uint256 _type, address _owner, uint256 _tokenId) external payable {

        Listing storage listing = listings[_owner][_type][_tokenId];
        address seller = listing.seller;
        
        uint256 listingDelay = getListingActiveDelay(_type);
        require(block.number.sub(listing.blockNumber) > listingDelay, "Listing will be availale in a few blocks");
        require(listing.active, "Listing not active");
        require(listing.price > 0, "Listing not found");
        
        address approved = getApproved(_type, _tokenId);
        address owner = getOwner(_type, _tokenId);
        
        if ((owner != seller || address(this) != approved)) {
            listing.active = false;
            addPenalty(seller, listing.tokensStaked);
        } else {
            revert("Listing is OK");
        }
    }
    
    function addPenalty(address owner, uint256 tokensStaked) internal {

        penalties[owner] = penalties[owner].add(tokensStaked);
    }

    function purchase(uint256 _type, address _owner, uint256 _tokenId) external updateReward(_owner) payable {

        address buyer = msg.sender;

        Listing storage listing = listings[_owner][_type][_tokenId];
        address seller = listing.seller;
        uint256 price = listing.price;
        
        address owner = getOwner(_type, _tokenId);
        address approved = getApproved(_type, _tokenId);
        uint256 listingDelay = getListingActiveDelay(_type);

        require(price > 0, "Listing not found");
        require(listing.active, "Listing not active");
        require(owner == seller, "Seller must own the item");
        require(approved == address(this), "Approve required");
        require(block.number.sub(listing.blockNumber) > listingDelay, "Listing pending");
        require(msg.value >= listing.price, "ETH payed below listed price");
        
        listing.active = false;
        
        if (getBuyBonusResidual(_type) > 0) {
            uint256 residual = listing.tokensStaked.div(getBuyBonusResidual(_type));
            uint256 realizedRewards = listing.tokensStaked.sub(residual);

            if (realizedRewards > 0) {
                removeRewards(seller, realizedRewards);
            }
        } else {
            if (listing.tokensStaked > 0) {
                removeRewards(seller, listing.tokensStaked);
            }
        }

        transferNft(seller, buyer, _type, _tokenId);
        
        if (getMarketFee(_type) > 0) {
            uint256 taxes = price.div(getMarketFee(_type));
            uint256 taxedPrice = price.sub(taxes);
            
            address payable payableSeller = address(uint160(seller));
            payableSeller.send(taxedPrice);
            
            address payable payableRewardsPool = address(uint160(rewardsPoolAddress));
            if (!payableRewardsPool.send(taxes)) {
                revert("Error paying RewardsPool");
            }
            IRewardDistributionRecipient(rewardsPoolAddress).notifyRewardAmount(taxes);
        } else {
            address payable payableSeller = address(uint160(seller));
            payableSeller.send(price);
        }
        
        emit NftSold(seller, buyer, _type, _tokenId, price);
    }
    
    function transferNft(address from, address to, uint256 _type, uint256 _tokenId) internal {

        ERC721 nftToken = ERC721(INFTGovernance(governanceContract.getGovernanceContract(_type)).getNftAddress(_tokenId));
        nftToken.safeTransferFrom(from, to, _tokenId);
    }

    function getListing(address _owner, uint256 _type, uint256 _tokenId) public view returns (uint256, uint256, address, uint256, bool) {

        Listing storage listing = listings[_owner][_type][_tokenId];
        uint256 price = listing.price;
        uint256 tokenId = listing.tokenId;
        address seller = listing.seller;
        uint256 tokensStaked = listing.tokensStaked;
        bool active = listing.active;

        return (
            price,
            tokenId,
            seller,
            tokensStaked,
            active
        );
    }

}