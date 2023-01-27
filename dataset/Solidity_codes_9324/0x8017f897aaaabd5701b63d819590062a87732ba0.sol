


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
    function balanceOf(address) virtual public view returns (uint256);
    function transfer(address, uint256) virtual external returns (bool);
}

contract StakingRewardsEscrow is ReentrancyGuard {

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

        require(authorizedAccounts[msg.sender] == 1, "StakingRewardsEscrow/account-not-authorized");
        _;
    }

    struct EscrowSlot {
        uint256 total;
        uint256 startDate;
        uint256 duration;
        uint256 claimedUntil;
        uint256 amountClaimed;
    }

    address   public escrowRequestor;
    uint256   public escrowDuration;
    uint256   public durationToStartEscrow;
    uint256   public slotsToClaim;
    TokenLike public token;

    uint256   public constant MAX_ESCROW_DURATION          = 365 days;
    uint256   public constant MAX_DURATION_TO_START_ESCROW = 30 days;
    uint256   public constant MAX_SLOTS_TO_CLAIM           = 25;

    mapping (address => uint256)                        public oldestEscrowSlot;
    mapping (address => uint256)                        public currentEscrowSlot;
    mapping (address => mapping(uint256 => EscrowSlot)) public escrows;

    event AddAuthorization(address account);
    event RemoveAuthorization(address account);
    event ModifyParameters(bytes32 indexed parameter, uint256 data);
    event ModifyParameters(bytes32 indexed parameter, address data);
    event EscrowRewards(address indexed who, uint256 amount, uint256 currentEscrowSlot);
    event ClaimRewards(address indexed who, uint256 amount);

    constructor(
      address escrowRequestor_,
      address token_,
      uint256 escrowDuration_,
      uint256 durationToStartEscrow_
    ) public {
      require(escrowRequestor_ != address(0), "StakingRewardsEscrow/null-requestor");
      require(token_ != address(0), "StakingRewardsEscrow/null-token");
      require(both(escrowDuration_ > 0, escrowDuration_ <= MAX_ESCROW_DURATION), "StakingRewardsEscrow/invalid-escrow-duration");
      require(both(durationToStartEscrow_ > 0, durationToStartEscrow_ < escrowDuration_), "StakingRewardsEscrow/invalid-duration-start-escrow");
      require(escrowDuration_ > durationToStartEscrow_, "StakingRewardsEscrow/");

      authorizedAccounts[msg.sender] = 1;

      escrowRequestor        = escrowRequestor_;
      token                  = TokenLike(token_);
      escrowDuration         = escrowDuration_;
      durationToStartEscrow  = durationToStartEscrow_;
      slotsToClaim           = MAX_SLOTS_TO_CLAIM;

      emit AddAuthorization(msg.sender);
    }

    function both(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := and(x, y)}
    }
    function either(bool x, bool y) internal pure returns (bool z) {

        assembly{ z := or(x, y)}
    }

    function addition(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x + y) >= x, "StakingRewardsEscrow/add-overflow");
    }
    function subtract(uint256 x, uint256 y) internal pure returns (uint256 z) {

        require((z = x - y) <= x, "StakingRewardsEscrow/sub-underflow");
    }
    function multiply(uint x, uint y) internal pure returns (uint z) {

        require(y == 0 || (z = x * y) / y == x, "StakingRewardsEscrow/mul-overflow");
    }
    function minimum(uint256 x, uint256 y) internal pure returns (uint256 z) {

        return x <= y ? x : y;
    }

    function modifyParameters(bytes32 parameter, uint256 data) external isAuthorized {

        if (parameter == "escrowDuration") {
          require(both(data > 0, data <= MAX_ESCROW_DURATION), "StakingRewardsEscrow/invalid-escrow-duration");
          require(data > durationToStartEscrow, "StakingRewardsEscrow/smaller-than-start-escrow-duration");
          escrowDuration = data;
        }
        else if (parameter == "durationToStartEscrow") {
          require(both(data > 1, data <= MAX_DURATION_TO_START_ESCROW), "StakingRewardsEscrow/duration-to-start-escrow");
          require(data < escrowDuration, "StakingRewardsEscrow/not-lower-than-escrow-duration");
          durationToStartEscrow = data;
        }
        else if (parameter == "slotsToClaim") {
          require(both(data >= 1, data <= MAX_SLOTS_TO_CLAIM), "StakingRewardsEscrow/invalid-slots-to-claim");
          slotsToClaim = data;
        }
        else revert("StakingRewardsEscrow/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }
    function modifyParameters(bytes32 parameter, address data) external isAuthorized {

        require(data != address(0), "StakingRewardsEscrow/null-data");

        if (parameter == "escrowRequestor") {
            escrowRequestor = data;
        }
        else revert("StakingRewardsEscrow/modify-unrecognized-param");
        emit ModifyParameters(parameter, data);
    }

    function escrowRewards(address who, uint256 amount) external nonReentrant {

        require(escrowRequestor == msg.sender, "StakingRewardsEscrow/not-requestor");
        require(who != address(0), "StakingRewardsEscrow/null-who");
        require(amount > 0, "StakingRewardsEscrow/null-amount");

        if (
          either(currentEscrowSlot[who] == 0,
          now > addition(escrows[who][currentEscrowSlot[who] - 1].startDate, durationToStartEscrow))
        ) {
          escrows[who][currentEscrowSlot[who]] = EscrowSlot(amount, now, escrowDuration, now, 0);
          currentEscrowSlot[who] = addition(currentEscrowSlot[who], 1);
        } else {
          escrows[who][currentEscrowSlot[who] - 1].total = addition(escrows[who][currentEscrowSlot[who] - 1].total, amount);
        }

        emit EscrowRewards(who, amount, currentEscrowSlot[who] - 1);
    }
    function getTokensBeingEscrowed(address who) public view returns (uint256) {

        if (oldestEscrowSlot[who] >= currentEscrowSlot[who]) return 0;

        EscrowSlot memory escrowReward;

        uint256 totalEscrowed;
        uint256 endDate;

        for (uint i = oldestEscrowSlot[who]; i <= currentEscrowSlot[who]; i++) {
            escrowReward = escrows[who][i];
            endDate      = addition(escrowReward.startDate, escrowReward.duration);

            if (escrowReward.amountClaimed >= escrowReward.total) {
              continue;
            }

            if (both(escrowReward.claimedUntil < endDate, now >= endDate)) {
              continue;
            }

            totalEscrowed = addition(totalEscrowed, subtract(escrowReward.total, escrowReward.amountClaimed));
        }

        return totalEscrowed;
    }
    function getClaimableTokens(address who) public view returns (uint256) {

        if (currentEscrowSlot[who] == 0) return 0;
        if (oldestEscrowSlot[who] >= currentEscrowSlot[who]) return 0;

        uint256 lastSlotToClaim = (subtract(currentEscrowSlot[who], oldestEscrowSlot[who]) > slotsToClaim) ?
          addition(oldestEscrowSlot[who], subtract(slotsToClaim, 1)) : subtract(currentEscrowSlot[who], 1);

        EscrowSlot memory escrowReward;

        uint256 totalToTransfer;
        uint256 endDate;
        uint256 reward;

        for (uint i = oldestEscrowSlot[who]; i <= lastSlotToClaim; i++) {
            escrowReward = escrows[who][i];
            endDate      = addition(escrowReward.startDate, escrowReward.duration);

            if (escrowReward.amountClaimed >= escrowReward.total) {
              continue;
            }

            if (both(escrowReward.claimedUntil < endDate, now >= endDate)) {
              totalToTransfer = addition(totalToTransfer, subtract(escrowReward.total, escrowReward.amountClaimed));
              continue;
            }

            if (escrowReward.claimedUntil == now) continue;

            reward = subtract(escrowReward.total, escrowReward.amountClaimed) / subtract(endDate, escrowReward.claimedUntil);
            reward = multiply(reward, subtract(now, escrowReward.claimedUntil));
            if (addition(escrowReward.amountClaimed, reward) > escrowReward.total) {
              reward = subtract(escrowReward.total, escrowReward.amountClaimed);
            }

            totalToTransfer = addition(totalToTransfer, reward);
        }

        return totalToTransfer;
    }
    function claimTokens(address who) public nonReentrant {

        require(currentEscrowSlot[who] > 0, "StakingRewardsEscrow/invalid-address");
        require(oldestEscrowSlot[who] < currentEscrowSlot[who], "StakingRewardsEscrow/no-slot-to-claim");

        uint256 lastSlotToClaim = (subtract(currentEscrowSlot[who], oldestEscrowSlot[who]) > slotsToClaim) ?
          addition(oldestEscrowSlot[who], subtract(slotsToClaim, 1)) : subtract(currentEscrowSlot[who], 1);

        EscrowSlot storage escrowReward;

        uint256 totalToTransfer;
        uint256 endDate;
        uint256 reward;

        for (uint i = oldestEscrowSlot[who]; i <= lastSlotToClaim; i++) {
            escrowReward = escrows[who][i];
            endDate      = addition(escrowReward.startDate, escrowReward.duration);

            if (escrowReward.amountClaimed >= escrowReward.total) {
              oldestEscrowSlot[who] = addition(oldestEscrowSlot[who], 1);
              continue;
            }

            if (both(escrowReward.claimedUntil < endDate, now >= endDate)) {
              totalToTransfer            = addition(totalToTransfer, subtract(escrowReward.total, escrowReward.amountClaimed));
              escrowReward.amountClaimed = escrowReward.total;
              escrowReward.claimedUntil  = now;
              oldestEscrowSlot[who]      = addition(oldestEscrowSlot[who], 1);
              continue;
            }

            if (escrowReward.claimedUntil == now) continue;

            reward = subtract(escrowReward.total, escrowReward.amountClaimed) / subtract(endDate, escrowReward.claimedUntil);
            reward = multiply(reward, subtract(now, escrowReward.claimedUntil));
            if (addition(escrowReward.amountClaimed, reward) > escrowReward.total) {
              reward = subtract(escrowReward.total, escrowReward.amountClaimed);
            }

            totalToTransfer            = addition(totalToTransfer, reward);
            escrowReward.amountClaimed = addition(escrowReward.amountClaimed, reward);
            escrowReward.claimedUntil  = now;
        }

        if (totalToTransfer > 0) {
            require(token.transfer(who, totalToTransfer), "StakingRewardsEscrow/cannot-transfer-rewards");
        }

        emit ClaimRewards(who, totalToTransfer);
    }
}