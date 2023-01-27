


pragma solidity 0.6.7;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

abstract contract TokenLike {
    function decimals() virtual public view returns (uint8);
    function totalSupply() virtual public view returns (uint256);
    function balanceOf(address) virtual public view returns (uint256);
    function mint(address, uint) virtual public;
    function burn(address, uint) virtual public;
    function approve(address, uint256) virtual external returns (bool);
    function transfer(address, uint256) virtual external returns (bool);
    function transferFrom(address,address,uint256) virtual external returns (bool);
}
abstract contract AuctionHouseLike {
    function activeStakedTokenAuctions() virtual public view returns (uint256);
    function startAuction(uint256, uint256) virtual external returns (uint256);
}
abstract contract AccountingEngineLike {
    function debtAuctionBidSize() virtual public view returns (uint256);
    function unqueuedUnauctionedDebt() virtual public view returns (uint256);
}
abstract contract SAFEEngineLike {
    function coinBalance(address) virtual public view returns (uint256);
    function debtBalance(address) virtual public view returns (uint256);
}
abstract contract RewardDripperLike {
    function dripReward() virtual external;
    function dripReward(address) virtual external;
    function rewardPerBlock() virtual external view returns (uint256);
    function rewardToken() virtual external view returns (TokenLike);
}
abstract contract StakingRewardsEscrowLike {
    function escrowRewards(address, uint256) virtual external;
}

contract TokenPool {

    TokenLike public token;
    address   public owner;

    constructor(address token_) public {
        token = TokenLike(token_);
        owner = msg.sender;
    }

    function transfer(address to, uint256 wad) public {

        require(msg.sender == owner, "unauthorized");
        require(token.transfer(to, wad), "TokenPool/failed-transfer");
    }

    function balance() public view returns (uint256) {

        return token.balanceOf(address(this));
    }
}

contract GebLenderFirstResortRewardsVested is ReentrancyGuard {

    mapping (address => uint) public authorizedAccounts;
    function addAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 1;
        emit AddAuthorization(account);
    }
    function removeAuthorization(address account) virtual external isAuthorized {

        authorizedAccounts[account] = 0;
        emit RemoveAuthorization(account);
    }
    modifier isAuthorized {

        require(authorizedAccounts[msg.sender] == 1, "GebLenderFirstResortRewardsVested/account-not-authorized");
        _;
    }

    struct ExitRequest {
        uint256 deadline;
        uint256 lockedAmount;
    }

    bool      public canJoin;
    bool      public bypassAuctions;
    bool      public forcedExit;
    uint256   public lastRewardBlock;
    uint256   public exitDelay;
    uint256   public minStakedTokensToKeep;
    uint256   public maxConcurrentAuctions;
    uint256   public tokensToAuction;
    uint256   public systemCoinsToRequest;
    uint256   public accTokensPerShare;
    uint256   public rewardsBalance;
    uint256   public stakedSupply;
    uint256   public percentageVested;
    uint256   public escrowPaused;

    mapping(address => uint256)    public descendantBalanceOf;
    mapping(address => ExitRequest) public exitRequests;
    mapping(address => uint256)    internal rewardDebt;

    TokenPool                public ancestorPool;
    TokenPool                public rewardPool;
    TokenLike                public descendant;
    AuctionHouseLike         public auctionHouse;
    AccountingEngineLike     public accountingEngine;
    SAFEEngineLike           public safeEngine;
    RewardDripperLike        public rewardDripper;
    StakingRewardsEscrowLike public escrow;

    uint256 public immutable MAX_DELAY;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 indexed parameter, uint256 data);
    event ModifyParameters(bytes32 indexed parameter, address data);
    event ToggleJoin(bool canJoin);
    event ToggleBypassAuctions(bool bypassAuctions);
    event ToggleForcedExit(bool forcedExit);
    event AuctionAncestorTokens(address auctionHouse, uint256 amountAuctioned, uint256 amountRequested);
    event RequestExit(address indexed account, uint256 deadline, uint256 amount);
    event Join(address indexed account, uint256 price, uint256 amount);
    event Exit(address indexed account, uint256 price, uint256 amount);
    event RewardsPaid(address account, uint256 amount);
    event EscrowRewards(address escrow, address who, uint256 amount);
    event PoolUpdated(uint256 accTokensPerShare, uint256 stakedSupply);
    event FailEscrowRewards(bytes revertReason);

    constructor(
      address ancestor_,
      address descendant_,
      address rewardToken_,
      address auctionHouse_,
      address accountingEngine_,
      address safeEngine_,
      address rewardDripper_,
      address escrow_,
      uint256 maxDelay_,
      uint256 exitDelay_,
      uint256 minStakedTokensToKeep_,
      uint256 tokensToAuction_,
      uint256 systemCoinsToRequest_,
      uint256 percentageVested_
    ) public {
        require(maxDelay_ > 0, "GebLenderFirstResortRewardsVested/null-max-delay");
        require(exitDelay_ <= maxDelay_, "GebLenderFirstResortRewardsVested/invalid-exit-delay");
        require(minStakedTokensToKeep_ > 0, "GebLenderFirstResortRewardsVested/null-min-staked-tokens");
        require(tokensToAuction_ > 0, "GebLenderFirstResortRewardsVested/null-tokens-to-auction");
        require(systemCoinsToRequest_ > 0, "GebLenderFirstResortRewardsVested/null-sys-coins-to-request");
        require(auctionHouse_ != address(0), "GebLenderFirstResortRewardsVested/null-auction-house");
        require(accountingEngine_ != address(0), "GebLenderFirstResortRewardsVested/null-accounting-engine");
        require(safeEngine_ != address(0), "GebLenderFirstResortRewardsVested/null-safe-engine");
        require(rewardDripper_ != address(0), "GebLenderFirstResortRewardsVested/null-reward-dripper");
        require(escrow_ != address(0), "GebLenderFirstResortRewardsVested/null-escrow");
        require(percentageVested_ < 100, "GebLenderFirstResortRewardsVested/invalid-percentage-vested");
        require(descendant_ != address(0), "GebLenderFirstResortRewardsVested/null-descendant");

        authorizedAccounts[msg.sender] = 1;
        canJoin                        = true;
        maxConcurrentAuctions          = uint(-1);

        MAX_DELAY                      = maxDelay_;

        exitDelay                      = exitDelay_;

        minStakedTokensToKeep          = minStakedTokensToKeep_;
        tokensToAuction                = tokensToAuction_;
        systemCoinsToRequest           = systemCoinsToRequest_;
        percentageVested               = percentageVested_;

        auctionHouse                   = AuctionHouseLike(auctionHouse_);
        accountingEngine               = AccountingEngineLike(accountingEngine_);
        safeEngine                     = SAFEEngineLike(safeEngine_);
        rewardDripper                  = RewardDripperLike(rewardDripper_);
        escrow                         = StakingRewardsEscrowLike(escrow_);
        descendant                     = TokenLike(descendant_);

        ancestorPool                   = new TokenPool(ancestor_);
        rewardPool                     = new TokenPool(rewardToken_);

        lastRewardBlock                = block.number;

        require(ancestorPool.token().decimals() == 18, "GebLenderFirstResortRewardsVested/ancestor-decimal-mismatch");
        require(descendant.decimals() == 18, "GebLenderFirstResortRewardsVested/descendant-decimal-mismatch");

        emit AddAuthorization(msg.sender);
    }

    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }
    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    uint256 public constant WAD = 10 ** 18;
    uint256 public constant RAY = 10 ** 27;

    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "GebLenderFirstResortRewardsVested/add-overflow");
    }
    function subtract(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "GebLenderFirstResortRewardsVested/sub-underflow");
    }
    function multiply(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "GebLenderFirstResortRewardsVested/mul-overflow");
    }
    function wdivide(uint x, uint y) internal pure returns (uint z) {

        require(y > 0, "GebLenderFirstResortRewardsVested/wdiv-by-zero");
        z = multiply(x, WAD) / y;
    }
    function wmultiply(uint x, uint y) internal pure returns (uint z) {

        z = multiply(x, y) / WAD;
    }

    function toggleJoin() external isAuthorized {

        canJoin = !canJoin;
        emit ToggleJoin(canJoin);
    }
    function toggleBypassAuctions() external isAuthorized {

        bypassAuctions = !bypassAuctions;
        emit ToggleBypassAuctions(bypassAuctions);
    }
    function toggleForcedExit() external isAuthorized {

        forcedExit = !forcedExit;
        emit ToggleForcedExit(forcedExit);
    }
    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {

        if (parameter == "exitDelay") {
          require(data <= MAX_DELAY, "GebLenderFirstResortRewardsVested/invalid-exit-delay");
          exitDelay = data;
        }
        else if (parameter == "minStakedTokensToKeep") {
          require(data > 0, "GebLenderFirstResortRewardsVested/null-min-staked-tokens");
          minStakedTokensToKeep = data;
        }
        else if (parameter == "tokensToAuction") {
          require(data > 0, "GebLenderFirstResortRewardsVested/invalid-tokens-to-auction");
          tokensToAuction = data;
        }
        else if (parameter == "systemCoinsToRequest") {
          require(data > 0, "GebLenderFirstResortRewardsVested/invalid-sys-coins-to-request");
          systemCoinsToRequest = data;
        }
        else if (parameter == "maxConcurrentAuctions") {
          require(data > 1, "GebLenderFirstResortRewardsVested/invalid-max-concurrent-auctions");
          maxConcurrentAuctions = data;
        }
        else if (parameter == "escrowPaused") {
          require(data <= 1, "GebLenderFirstResortRewardsVested/invalid-escrow-paused");
          escrowPaused = data;
        }
        else if (parameter == "percentageVested") {
          require(data < 100, "GebLenderFirstResortRewardsVested/invalid-percentage-vested");
          percentageVested = data;
        }
        else revert("GebLenderFirstResortRewardsVested/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }
    function modifyParameters(bytes32 parameter, address data) external isAuthorized {

        require(data != address(0), "GebLenderFirstResortRewardsVested/null-data");

        if (parameter == "auctionHouse") {
          auctionHouse = AuctionHouseLike(data);
        }
        else if (parameter == "accountingEngine") {
          accountingEngine = AccountingEngineLike(data);
        }
        else if (parameter == "rewardDripper") {
          rewardDripper = RewardDripperLike(data);
        }
        else if (parameter == "escrow") {
          escrow = StakingRewardsEscrowLike(data);
        }
        else revert("GebLenderFirstResortRewardsVested/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    function depositedAncestor() public view returns (uint256) {

        return ancestorPool.balance();
    }
    function ancestorPerDescendant() public view returns (uint256) {

        return stakedSupply == 0 ? WAD : wdivide(depositedAncestor(), stakedSupply);
    }
    function descendantPerAncestor() public view returns (uint256) {

        return stakedSupply == 0 ? WAD : wdivide(stakedSupply, depositedAncestor());
    }
    function joinPrice(uint256 wad) public view returns (uint256) {

        return wmultiply(wad, descendantPerAncestor());
    }
    function exitPrice(uint256 wad) public view returns (uint256) {

        return wmultiply(wad, ancestorPerDescendant());
    }

    function protocolUnderwater() public view returns (bool) {

        uint256 unqueuedUnauctionedDebt = accountingEngine.unqueuedUnauctionedDebt();

        return both(
          accountingEngine.debtAuctionBidSize() <= unqueuedUnauctionedDebt,
          safeEngine.coinBalance(address(accountingEngine)) < unqueuedUnauctionedDebt
        );
    }

    function canAuctionTokens() public view returns (bool) {

        return both(
          both(protocolUnderwater(), addition(minStakedTokensToKeep, tokensToAuction) <= depositedAncestor()),
          auctionHouse.activeStakedTokenAuctions() < maxConcurrentAuctions
        );
    }

    function canPrintProtocolTokens() public view returns (bool) {

        return both(
          !canAuctionTokens(),
          either(auctionHouse.activeStakedTokenAuctions() == 0, bypassAuctions)
        );
    }

    function pendingRewards(address user) public view returns (uint256) {

        uint accTokensPerShare_ = accTokensPerShare;
        if (block.number > lastRewardBlock && stakedSupply != 0) {
            uint increaseInBalance = (block.number - lastRewardBlock) * rewardDripper.rewardPerBlock();
            accTokensPerShare_ = addition(accTokensPerShare_, multiply(increaseInBalance, RAY) / stakedSupply);
        }
        return subtract(multiply(descendantBalanceOf[user], accTokensPerShare_) / RAY, rewardDebt[user]);
    }

    function rewardRate() public view returns (uint256) {

        if (stakedSupply == 0) return 0;
        return (rewardDripper.rewardPerBlock() * WAD) / stakedSupply;
    }

    modifier payRewards() {

        updatePool();

        if (descendantBalanceOf[msg.sender] > 0 && rewardPool.balance() > 0) {
            uint256 pending = subtract(multiply(descendantBalanceOf[msg.sender], accTokensPerShare) / RAY, rewardDebt[msg.sender]);

            uint256 vested;
            if (both(address(escrow) != address(0), escrowPaused == 0)) {
              vested = multiply(pending, percentageVested) / 100;

              try escrow.escrowRewards(msg.sender, vested) {
                rewardPool.transfer(address(escrow), vested);
                emit EscrowRewards(address(escrow), msg.sender, vested);
              } catch(bytes memory revertReason) {
                emit FailEscrowRewards(revertReason);
              }
            }

            rewardPool.transfer(msg.sender, subtract(pending, vested));
            rewardsBalance = rewardPool.balance();

            emit RewardsPaid(msg.sender, pending);
        }
        _;

        rewardDebt[msg.sender] = multiply(descendantBalanceOf[msg.sender], accTokensPerShare) / RAY;
    }

    function getRewards() external nonReentrant payRewards {}


    function pullFunds() public {

        rewardDripper.dripReward(address(rewardPool));
    }

    function updatePool() public {

        if (block.number <= lastRewardBlock) return;
        lastRewardBlock = block.number;
        if (stakedSupply == 0) return;

        pullFunds();
        uint256 increaseInBalance = subtract(rewardPool.balance(), rewardsBalance);
        rewardsBalance = addition(rewardsBalance, increaseInBalance);

        accTokensPerShare = addition(accTokensPerShare, multiply(increaseInBalance, RAY) / stakedSupply);
        emit PoolUpdated(accTokensPerShare, stakedSupply);
    }

    function auctionAncestorTokens() external nonReentrant {

        require(canAuctionTokens(), "GebLenderFirstResortRewardsVested/cannot-auction-tokens");

        ancestorPool.transfer(address(this), tokensToAuction);
        ancestorPool.token().approve(address(auctionHouse), tokensToAuction);
        auctionHouse.startAuction(tokensToAuction, systemCoinsToRequest);
        updatePool();

        emit AuctionAncestorTokens(address(auctionHouse), tokensToAuction, systemCoinsToRequest);
    }

    function join(uint256 wad) external nonReentrant payRewards {

        require(both(canJoin, !protocolUnderwater()), "GebLenderFirstResortRewardsVested/join-not-allowed");
        require(wad > 0, "GebLenderFirstResortRewardsVested/null-ancestor-to-join");
        uint256 price = joinPrice(wad);
        require(price > 0, "GebLenderFirstResortRewardsVested/null-join-price");

        require(ancestorPool.token().transferFrom(msg.sender, address(ancestorPool), wad), "GebLenderFirstResortRewardsVested/could-not-transfer-ancestor");
        descendant.mint(msg.sender, price);

        descendantBalanceOf[msg.sender] = addition(descendantBalanceOf[msg.sender], price);
        stakedSupply = addition(stakedSupply, price);

        emit Join(msg.sender, price, wad);
    }
    function requestExit(uint wad) external nonReentrant payRewards {

        require(wad > 0, "GebLenderFirstResortRewardsVested/null-amount-to-exit");

        exitRequests[msg.sender].deadline      = addition(now, exitDelay);
        exitRequests[msg.sender].lockedAmount  = addition(exitRequests[msg.sender].lockedAmount, wad);

        descendantBalanceOf[msg.sender] = subtract(descendantBalanceOf[msg.sender], wad);
        descendant.burn(msg.sender, wad);

        emit RequestExit(msg.sender, exitRequests[msg.sender].deadline, wad);
    }
    function exit() external nonReentrant {

        require(both(now >= exitRequests[msg.sender].deadline, exitRequests[msg.sender].lockedAmount > 0), "GebLenderFirstResortRewardsVested/wait-more");
        require(either(!protocolUnderwater(), forcedExit), "GebLenderFirstResortRewardsVested/exit-not-allowed");

        uint256 price = exitPrice(exitRequests[msg.sender].lockedAmount);
        stakedSupply  = subtract(stakedSupply, exitRequests[msg.sender].lockedAmount);
        ancestorPool.transfer(msg.sender, price);
        emit Exit(msg.sender, price, exitRequests[msg.sender].lockedAmount);
        delete exitRequests[msg.sender];
    }
}