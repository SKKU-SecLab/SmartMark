




pragma solidity 0.8.11;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

}

abstract contract Auth {
    address internal owner;
    constructor(address _owner) { owner = _owner; }
    modifier onlyOwner() { require(msg.sender == owner, "Only contract owner can call this function"); _; }
    function transferOwnership(address payable newOwner) external onlyOwner { owner = newOwner; emit OwnershipTransferred(newOwner); }
    event OwnershipTransferred(address owner);
}


contract ArcadeVesting is Auth {

    address public vestedTokenContract;
    IERC20 private _tokenContract;

    uint256 public vestingStartTimestamp;
    uint256 public vestingFinishTimestamp;
    uint8 public initialReleasePercent;

    bool vestingSettingsLocked;
    bool vestingActive;

    mapping (address => uint256) public tokensAllocated;
    mapping (address => uint256) public tokensWithdrawn;
    mapping (address => bool) public isBlacklisted;
    mapping (address => string) public blacklistReason;

    uint256 public totalTokensAllocated;
    uint256 public totalTokensWithdrawn;
    uint256 public vestedWalletsCount;
    
    event VestingStart(uint256 startTimestamp, uint256 endTimestamp, uint8 initialPercentRelease);
    event Claim(address indexed claimer, uint256 value);
    event AllTokensClaimed(address indexed wallet);
    event TokenRecovery(address indexed claimer, uint256 value);
    event BlacklistAdded(address indexed wallet, string reason);
    event BlacklistRemoved(address indexed wallet, string reason);

    constructor () Auth(msg.sender) {}

    function setupVesting(address tokenContractAddress, uint256 startTimestamp, uint256 endTimestamp, uint8 initialReleasePct) external onlyOwner {

        require(!vestingSettingsLocked, "Vesting settings already locked");
        vestedTokenContract = tokenContractAddress;
        _tokenContract = IERC20(vestedTokenContract);
        require(initialReleasePct<100, "Initial release percentage must be lower than 100");

        if (startTimestamp < block.timestamp) { vestingStartTimestamp = block.timestamp; }
        else { vestingStartTimestamp = startTimestamp; }

        require(endTimestamp > vestingStartTimestamp, "End timestamp must be after start timestamp");
        require(endTimestamp < (vestingStartTimestamp + 365 days), "Vesting time cannot be longer than 1 year");

        vestingFinishTimestamp = endTimestamp;

        initialReleasePercent = initialReleasePct;
    }

    function settingsLock() external onlyOwner {

        require(!vestingSettingsLocked, "Vesting settings already locked");
        vestingSettingsLocked = true;
    }

    function settingsUnlock() external onlyOwner {

        require(vestingSettingsLocked, "Vesting settings not locked");
        require(!vestingActive, "Vesting is already active");
        vestingSettingsLocked = false;
    }


    function blacklistAdd(address wallet, string memory reason) external onlyOwner {

        require(!isBlacklisted[wallet], "Wallet already blacklisted");
        isBlacklisted[wallet] = true;
        blacklistReason[wallet] = reason;
        emit BlacklistAdded(wallet, reason);
    }

    function blacklistRemove(address wallet, string memory reason) external onlyOwner {

        require(isBlacklisted[wallet], "Wallet is not blacklisted");
        isBlacklisted[wallet] = false;
        blacklistReason[wallet] = reason;
        emit BlacklistRemoved(wallet, reason);
    }

    function activateVesting() external onlyOwner {

        require(vestingSettingsLocked, "Vesting settings must be locked first");
        require(block.timestamp < vestingFinishTimestamp, "Vesting period has already passed");
        require(!vestingActive, "Vesting currently active, wait till end time");
        require(vestedWalletsCount > 0, "Cannot activate with no vested wallets");
        
        uint256 tokenBalance = _tokenContract.balanceOf( address(this) );
        require(tokenBalance == totalTokensAllocated, "Non-allocated tokens present");
        
        vestingActive = true;
        emit VestingStart(vestingStartTimestamp, vestingFinishTimestamp, initialReleasePercent); 
    }

    function tokensRemaining(address wallet) external view returns (uint256) {

        return tokensAllocated[wallet] - tokensWithdrawn[wallet];
    }

    function _tokensClaimable(address wallet) internal view returns (uint256) {

        uint256 claimableTokens = 0;
        uint256 vestingLength = vestingFinishTimestamp - vestingStartTimestamp;
        if ( !isBlacklisted[msg.sender] && vestingActive && block.timestamp > vestingStartTimestamp ) {
            uint256 timePassed = block.timestamp - vestingStartTimestamp;
            if (timePassed >= vestingLength) { 
                claimableTokens = tokensAllocated[wallet] - tokensWithdrawn[wallet];
            } else {
                uint256 initialRelease = tokensAllocated[wallet] * initialReleasePercent / 100;
                uint256 unlockedTimeTokens = (tokensAllocated[wallet] - initialRelease) * timePassed / vestingLength;
                claimableTokens = initialRelease + unlockedTimeTokens - tokensWithdrawn[wallet];
            }
        }
        return claimableTokens;
    }

    function tokensClaimable(address wallet) external view returns (uint256) {

        return _tokensClaimable(wallet);
    }

    function getTokenBalance() external view returns (uint256) {

        uint256 tokenBalance = _tokenContract.balanceOf(address(this));
        return tokenBalance;
    }

    function getTokenDecimals() external view returns (uint8) {

        uint8 tokenDecimals = _tokenContract.decimals();
        return tokenDecimals;
    }

    function addRecipient(address[] calldata recipients, uint256 tokenAmountWithoutDecimals) external onlyOwner {

        require(!vestingActive, "Vesting is already active, wait till finished");
        require(recipients.length <= 500,"Cannot set more than 500 recipients at a time");

        uint256 tokenBalance = _tokenContract.balanceOf( address(this) );
        uint8 _decimals = _tokenContract.decimals();

        for(uint i=0; i < recipients.length; i++){
            require(tokensAllocated[ recipients[i] ] == 0, "Recipient already has tokens allocated");
            uint256 _thisTokenAmount = tokenAmountWithoutDecimals * (10 ** _decimals);
            require(_thisTokenAmount <= (tokenBalance - totalTokensAllocated), "Not enough tokens available to allocate");
            totalTokensAllocated += _thisTokenAmount;
            vestedWalletsCount += 1;
            tokensAllocated[ recipients[i] ] = _thisTokenAmount;
        }
    }

    function claimTokens() external {

        require(!isBlacklisted[msg.sender], "Wallet is blacklisted");
        _sendClaimedTokens(msg.sender);
    }

    function _sendClaimedTokens(address wallet) internal {

        require(vestingActive && block.timestamp > vestingStartTimestamp, "Claiming is not yet available");
        require(tokensAllocated[wallet] > tokensWithdrawn[wallet], "No claimable tokens for this wallet");

        uint256 unlockedTokens = _tokensClaimable(wallet);
        tokensWithdrawn[wallet] += unlockedTokens;
        totalTokensWithdrawn += unlockedTokens;
        _tokenContract.transfer(wallet, unlockedTokens);
        emit Claim(wallet, unlockedTokens);

        if (tokensWithdrawn[wallet] >= tokensAllocated[wallet]) {
            vestedWalletsCount -= 1;
            emit AllTokensClaimed(wallet);
        }
    }   
}