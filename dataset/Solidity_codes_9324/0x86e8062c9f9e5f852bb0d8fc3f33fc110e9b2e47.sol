



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
        uint256 tokenId,
        bytes calldata data
    ) external;


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


    function setApprovalForAll(address operator, bool _approved) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function isApprovedForAll(address owner, address operator) external view returns (bool);

}




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
}




pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}




pragma solidity ^0.8.0;

interface IERC20 {

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

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

}




pragma solidity ^0.8.0;





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
}



pragma solidity ^0.8.13;






abstract contract Owned {
    address public owner;
    address public nominatedOwner;

    constructor(address _owner) {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    function nominateNewOwner(address _owner) external onlyOwner {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    function acceptOwnership() external {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner {
        _onlyOwner();
        _;
    }

    function _onlyOwner() private view {
        require(msg.sender == owner, "Only the contract owner may perform this action");
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}

abstract contract Pausable is Owned {
    uint public lastPauseTime;
    bool public paused;

    constructor() {
        require(owner != address(0), "Owner must be set");
    }

    function setPaused(bool _paused) external onlyOwner {
        if (_paused == paused) {
            return;
        }

        paused = _paused;

        if (paused) {
            lastPauseTime = block.timestamp;
        }

        emit PauseChanged(paused);
    }

    event PauseChanged(bool isPaused);

    modifier notPaused {
        require(!paused, "This action cannot be performed while the contract is paused");
        _;
    }
}


abstract contract RewardsDistributionRecipient is Owned {
    address public rewardsDistribution;

    function notifyRewardAmount(uint256 reward) virtual external;

    modifier onlyRewardsDistribution() {
        require(msg.sender == rewardsDistribution, "Caller is not RewardsDistribution contract");
        _;
    }

    function setRewardsDistribution(address _rewardsDistribution) external onlyOwner {
        rewardsDistribution = _rewardsDistribution;
    }
}

interface IUniswapV2Pair {

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

}


interface IERC4626 is IERC20 {

    function asset() external view returns(address assetTokenAddress);


    function totalAssets() external view returns(uint256 totalManagedAssets);


    function convertToShares(uint256 assets) external view returns(uint256 shares); 


    function convertToAssets(uint256 shares) external view returns(uint256 assets);

 
    function maxDeposit(address receiver) external view returns(uint256 maxAssets);


    function previewDeposit(uint256 assets) external view returns(uint256 shares);


    function deposit(uint256 assets, address receiver) external returns(uint256 shares);


    function maxMint(address receiver) external view returns(uint256 maxShares); 


    function previewMint(uint256 shares) external view returns(uint256 assets);


    function mint(uint256 shares, address receiver) external returns(uint256 assets);


    function maxWithdraw(address owner) external view returns(uint256 maxAssets);


    function previewWithdraw(uint256 assets) external view returns(uint256 shares);


    function withdraw(uint256 assets, address receiver, address owner) external returns(uint256 shares);


    function maxRedeem(address owner) external view returns(uint256 maxShares);


    function previewRedeem(uint256 shares) external view returns(uint256 assets);


    function redeem(uint256 shares, address receiver, address owner) external returns(uint256 assets);


    event Deposit(address indexed caller, address indexed owner, uint256 assets, uint256 shares);
    event Withdraw(address indexed caller, address indexed receiver, address indexed owner, uint256 assets, uint256 shares);
}
interface IVeVault is IERC4626 {

    function asset() external view  returns (address assetTokenAddress);

    function totalAssets() external view  returns (uint256 totalManagedAssets);

    function totalSupply() external view  returns (uint256);

    function balanceOf(address account) external view  returns (uint256);

    function convertToShares(uint256 assets, uint256 lockTime) external view returns (uint256 shares);

    function convertToShares(uint256 assets)  external view returns (uint256 shares);

    function convertToAssets(uint256 shares, uint256 lockTime) external view returns (uint256 assets);

    function convertToAssets(uint256 shares)  external view returns (uint256 assets);

    function maxDeposit(address)  external pure returns (uint256 maxAssets);

    function previewDeposit(uint256 assets, uint256 lockTime) external view returns (uint256 shares);

    function previewDeposit(uint256 assets)  external view returns (uint256 shares);

    function maxMint(address)  external pure returns (uint256 maxShares);

    function previewMint(uint256 shares, uint256 lockTime) external view returns (uint256 assets);

    function previewMint(uint256 shares)  external view returns (uint256 assets);

    function maxWithdraw(address owner)  external view returns (uint256 maxAssets);

    function previewWithdraw(uint256 assets, uint256 lockTime) external view returns (uint256 shares);

    function previewWithdraw(uint256 assets)  external view returns (uint256 shares);

    function maxRedeem(address owner)  external view returns (uint256 maxShares);

    function previewRedeem(uint256 shares, uint256 lockTime) external view returns (uint256 assets);

    function previewRedeem(uint256 shares)  external view returns (uint256 assets);

    function allowance(address, address)  external view returns (uint256);

    function assetBalanceOf(address account) external view returns (uint256);

    function unlockDate(address account) external view returns (uint256);

    function gracePeriod() external view returns (uint256);

    function penaltyPercentage() external view returns (uint256);

    function minLockTime() external view returns (uint256);

    function maxLockTime() external view returns (uint256);

    function transfer(address, uint256) external  returns (bool);

    function approve(address, uint256) external  returns (bool);

    function transferFrom(address, address, uint256) external  returns (bool);

    function veMult(address owner) external view returns (uint256);

    function deposit(uint256 assets, address receiver, uint256 lockTime) external returns (uint256 shares);

    function deposit(uint256 assets, address receiver)  external returns (uint256 shares);

    function mint(uint256 shares, address receiver, uint256 lockTime) external returns (uint256 assets);

    function mint(uint256 shares, address receiver)  external returns (uint256 assets);

    function withdraw(uint256 assets, address receiver, address owner)  external returns (uint256 shares);

    function redeem(uint256 shares, address receiver, address owner)  external returns (uint256 assets);

    function exit() external returns (uint256 shares);

    function changeUnlockRule(bool flag) external;

    function changeGracePeriod(uint256 newGracePeriod) external;

    function changeEpoch(uint256 newEpoch) external;

    function changeMinPenalty(uint256 newMinPenalty) external;

    function changeMaxPenalty(uint256 newMaxPenalty) external;

    function changeWhitelistRecoverERC20(address tokenAddress, bool flag) external;

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external;

    function recoverERC721(address tokenAddress, uint256 tokenId) external;


    event PayPenalty(address indexed caller, address indexed owner, uint256 assets);
    event Burn(address indexed user, uint256 shares);
    event Mint(address indexed user, uint256 shares);
    event Recovered(address token, uint256 amount);
    event RecoveredNFT(address tokenAddress, uint256 tokenId);
    event ChangeWhitelistERC20(address indexed tokenAddress, bool whitelistState);
}


error Unauthorized();
error UnauthorizedClaim();
error NotImplemented();
error RewardTooHigh(uint256 allowed, uint256 reward);
error NotWhitelisted();
error InsufficientBalance();

abstract contract LpRewards is ReentrancyGuard, Pausable, RewardsDistributionRecipient, IERC4626 {
    using SafeERC20 for IERC20;

    struct Account {
        uint256 rewards;
        uint256 assets;
        uint256 shares;
        uint256 sharesBoost;
        uint256 rewardPerTokenPaid;
    }

    struct Total {
        uint256 managedAssets;
        uint256 supply;
    }
    

    address public veVault;
    address public rewardsToken;
    address public assetToken;

    Total public total;
    mapping(address => Account) internal accounts;

    uint256 public rewardPerTokenStored;
    uint256 public rewardRate = 0;

    uint256 public periodFinish = 0;
    uint256 public rewardsDuration = 7 days;
    uint256 public lastUpdateTime;

    uint256 internal constant PRECISION = 1e18; 
    
    string public _name;
    string public _symbol;

    mapping(address => bool) public whitelistRecoverERC20;


    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    
    function asset() override external view returns (address assetTokenAddress) {
        return assetToken;
    }
    
    function totalAssets() override external view returns (uint256 totalManagedAssets) {
        return total.managedAssets;
    }

    function totalSupply() override external view returns (uint256) {
        return total.supply;
    }

    function balanceOf(address owner) override external view returns (uint256) {
        return accounts[owner].shares;
    }

    function assetBalanceOf(address owner) external view returns (uint256) {
        return accounts[owner].assets;
    }

    function maxDeposit(address) override external pure returns (uint256 maxAssets) {
        return 2 ** 256 - 1;
    }

    function maxMint(address) override external pure returns (uint256 maxShares) {
        return 2 ** 256 - 1;
    }

    function maxWithdraw(address owner) override external view returns (uint256 maxAssets) {
        if (paused) {
            return 0;
        }
        return accounts[owner].assets;
    }

    function maxRedeem(address owner) override external view returns (uint256 maxShares) {
        if (paused) {
            return 0;
        }
        return accounts[owner].assets;
    }

    function convertToShares(uint256 assets) override external view returns (uint256 shares) {
        return assets * getMultiplier(msg.sender) / PRECISION;
    }

    function convertToAssets(uint256 shares) override external view returns (uint256 assets) {
        return shares * PRECISION / getMultiplier(msg.sender);
    }

    function previewDeposit(uint256 assets) override external view returns (uint256 shares) {
        return assets * getMultiplier(msg.sender) / PRECISION;
    }

    function previewMint(uint256 shares) override external view returns (uint256 assets) {
         return shares * PRECISION / getMultiplier(msg.sender);
    }

    function previewWithdraw(uint256 assets) override external view returns (uint256 shares) {
        return assets * getMultiplier(msg.sender) / PRECISION;
    }

    function previewRedeem(uint256 shares) override external view returns (uint256 assets) {
        return shares * PRECISION / getMultiplier(msg.sender);
    }

    function allowance(address, address) override external pure returns (uint256) {
        return 0;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }


    function transfer(address, uint256) external pure override returns (bool) {
        revert Unauthorized();
    }

    function approve(address, uint256) external pure override returns (bool) {
        revert Unauthorized();
    }

    function transferFrom(address, address, uint256) external pure override returns (bool) {
        revert Unauthorized();
    }


    function notifyDeposit() public updateReward(msg.sender) updateBoost(msg.sender) returns(Account memory) {
        emit NotifyDeposit(msg.sender, accounts[owner].assets, accounts[owner].shares);
        return accounts[owner];
    }

    function lastTimeRewardApplicable() public view returns (uint256) {
        return block.timestamp < periodFinish ? block.timestamp : periodFinish;
    }

    function rewardPerToken() public view returns (uint256) {
        if (total.supply == 0) {
            return rewardPerTokenStored;
        }
        return
            rewardPerTokenStored
            + ((lastTimeRewardApplicable() - lastUpdateTime)
                * rewardRate
                * PRECISION 
                / total.supply
            );
    }
    
    function earned(address owner) public view returns (uint256) {
        return accounts[owner].rewards
                + (accounts[owner].shares
                    * (rewardPerToken() - accounts[owner].rewardPerTokenPaid)
                    / PRECISION);
    }

    function getRewardForDuration() external view returns (uint256) {
        return rewardRate * rewardsDuration;
    }

    function getReward() public updateReward(msg.sender) returns (uint256 reward) {
        reward = accounts[msg.sender].rewards;
        if(reward <= 0)
            revert UnauthorizedClaim();
        accounts[msg.sender].rewards = 0;
        IERC20(rewardsToken).safeTransfer(msg.sender, reward);
        emit RewardPaid(msg.sender, reward);
        return reward;
    }

    function notifyRewardAmount(uint256 reward)
            override
            external
            onlyRewardsDistribution
            updateReward(address(0)) {
        if (block.timestamp >= periodFinish)
            rewardRate = reward / rewardsDuration;
        else {
            uint256 remaining = periodFinish - block.timestamp;
            uint256 leftover = remaining * rewardRate;
            rewardRate = (reward + leftover) / rewardsDuration;
        }

        uint balance = IERC20(rewardsToken).balanceOf(address(this));
        if(rewardRate > balance / rewardsDuration)
            revert RewardTooHigh({
                allowed: balance,
                reward: reward
            });
        lastUpdateTime = block.timestamp;
        periodFinish = block.timestamp + rewardsDuration;
        emit RewardAdded(reward);
    }

    function setRewardsDuration(uint256 _rewardsDuration) external onlyOwner {
        if (block.timestamp <= periodFinish)
            revert Unauthorized();
        rewardsDuration = _rewardsDuration;
        emit RewardsDurationUpdated(rewardsDuration);
    }


    function getNewoShare(address owner) public view returns (uint256) {
        uint112 reserve0; uint112 reserve1; uint32 timestamp;

        (reserve0, reserve1, timestamp) = IUniswapV2Pair(assetToken).getReserves();
        return accounts[owner].assets * reserve0
                / IUniswapV2Pair(assetToken).totalSupply();
    }

    function getMultiplier(address owner) public view returns (uint256) {
        IVeVault veToken = IVeVault(veVault);
        uint256 assetBalance = veToken.assetBalanceOf(owner);
        
        if (assetBalance == 0)
            return 1;
        return veToken.balanceOf(owner) * PRECISION / assetBalance;   
    }

    function getNewoLocked(address owner) public view returns (uint256) {
        return IVeVault(veVault).assetBalanceOf(owner);
    }

    
    function deposit(uint256 assets, address receiver)
            override
            external
            nonReentrant
            notPaused
            updateReward(receiver)
            updateBoost(receiver)
            returns (uint256 shares) {
        shares = assets;
        _deposit(assets, shares, receiver);
        return shares;
    }

    function mint(uint256, address)
            override
            external
            pure
            returns (uint256) {
        revert NotImplemented();
    }

    function withdraw(uint256 assets, address receiver, address owner)
            override
            external
            nonReentrant
            updateReward(owner)
            updateBoost(owner)
            returns(uint256 shares) {
        shares = assets;
        _withdraw(assets, shares, receiver, owner);
        return shares; 
    }

    function redeem(uint256, address, address)
            override
            external 
            pure
            returns (uint256) {
        revert NotImplemented();
    }

    function exit() external
            nonReentrant 
            updateReward(msg.sender)
            updateBoost(msg.sender)
            returns (uint256 reward) {
        _withdraw(accounts[msg.sender].assets, accounts[msg.sender].shares - accounts[msg.sender].sharesBoost, msg.sender, msg.sender);
        reward = getReward();
        return reward;
    }

    
    function _withdraw(uint256 assets, uint256 shares, address receiver, address owner) internal {
        if(assets <= 0 || owner != msg.sender 
            || accounts[owner].assets < assets
            || (accounts[owner].shares - accounts[owner].sharesBoost) < shares)
            revert Unauthorized();
    
        total.managedAssets -= assets;
        accounts[owner].assets -= assets;
        
        total.supply -= shares;
        accounts[owner].shares -= shares;

        IERC20(assetToken).safeTransfer(receiver, assets);

        emit Withdraw(msg.sender, receiver, owner, assets, shares);
    }
    
    function _deposit(uint256 assets, uint256 shares, address receiver) internal {
        if(assets <= 0 || receiver != msg.sender)
            revert Unauthorized();
        total.managedAssets += assets;
        accounts[receiver].assets += assets;

        total.supply += shares;
        accounts[receiver].shares += shares;

        IERC20(assetToken).safeTransferFrom(msg.sender, address(this), assets);
        emit Deposit(msg.sender, address(this), assets, shares);
    }

    function changeWhitelistRecoverERC20(address tokenAddress, bool flag) external onlyOwner {
        whitelistRecoverERC20[tokenAddress] = flag;
        emit ChangeWhitelistERC20(tokenAddress, flag);
    }

    function recoverERC20(address tokenAddress, uint256 tokenAmount) external onlyOwner {
        if (whitelistRecoverERC20[tokenAddress] == false) revert NotWhitelisted();
        
        uint balance = IERC20(tokenAddress).balanceOf(address(this));
        if (balance < tokenAmount) revert InsufficientBalance(); 

        IERC20(tokenAddress).safeTransfer(owner, tokenAmount);
        emit Recovered(tokenAddress, tokenAmount);
    }

    function recoverERC721(address tokenAddress, uint256 tokenId) external onlyOwner {
        IERC721(tokenAddress).safeTransferFrom(address(this), owner, tokenId);
        emit RecoveredNFT(tokenAddress, tokenId);
    }
    

    modifier updateReward(address owner) {
        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (owner != address(0)) {
            accounts[owner].rewards = earned(owner);
            accounts[owner].rewardPerTokenPaid = rewardPerTokenStored;
        }
        _;
    }

    modifier updateBoost(address owner) {
        _;
        uint256 oldShares = accounts[owner].shares;
        uint256 newShares = oldShares;
        if (getNewoShare(owner) <= getNewoLocked(owner)){
            newShares = accounts[owner].assets * getMultiplier(owner) / PRECISION;
        }
        if (newShares > oldShares) {
            uint256 diff = newShares - oldShares;
            total.supply += diff;
            accounts[owner].sharesBoost = diff;
            accounts[owner].shares = newShares;
            emit BoostUpdated(owner, accounts[owner].shares, accounts[owner].sharesBoost);
        } else if (newShares < oldShares) {
            uint256 diff = oldShares - newShares;
            total.supply -= diff;
            accounts[owner].sharesBoost = diff;
            accounts[owner].shares = newShares;
            emit BoostUpdated(owner, accounts[owner].shares, accounts[owner].sharesBoost);
        }
    }


    event RewardAdded(uint256 reward);
    event RewardPaid(address indexed user, uint256 reward);
    event RewardsDurationUpdated(uint256 newDuration);
    event Recovered(address token, uint256 amount);
    event RecoveredNFT(address tokenAddress, uint256 tokenId);
    event ChangeWhitelistERC20(address indexed tokenAddress, bool whitelistState);
    event NotifyDeposit(address indexed user, uint256 assetBalance, uint256 sharesBalance);
    event BoostUpdated(address indexed owner, uint256 totalShares, uint256 boostShares);
}


contract XNewO is LpRewards("staked NEWO LP", "stNEWOlp") {

    constructor(
        address _owner,
        address _lp,
        address _rewardsToken,
        address _veTokenVault,
        address _rewardsDistribution
    ) Owned (_owner) {
        assetToken = _lp;
        rewardsToken = _rewardsToken;
        veVault = _veTokenVault;
        rewardsDistribution = _rewardsDistribution;
    }
}