
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


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}/*

██████╗░██████╗░██╗███╗░░░███╗███████╗██████╗░░█████╗░░█████╗░
██╔══██╗██╔══██╗██║████╗░████║██╔════╝██╔══██╗██╔══██╗██╔══██╗
██████╔╝██████╔╝██║██╔████╔██║█████╗░░██║░░██║███████║██║░░██║
██╔═══╝░██╔══██╗██║██║╚██╔╝██║██╔══╝░░██║░░██║██╔══██║██║░░██║
██║░░░░░██║░░██║██║██║░╚═╝░██║███████╗██████╔╝██║░░██║╚█████╔╝
╚═╝░░░░░╚═╝░░╚═╝╚═╝╚═╝░░░░░╚═╝╚══════╝╚═════╝░╚═╝░░╚═╝░╚════╝░

*/

pragma solidity 0.8.6;



contract Seed {

    address public beneficiary;
    address public admin;
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public seedAmountRequired; // Amount of seed required for distribution
    uint256 public feeAmountRequired;  // Amount of seed required for fee
    uint256 public price;              // price of a SeedToken, expressed in fundingTokens, with precision of 10**18
    uint256 public startTime;
    uint256 public endTime;            // set by project admin, this is the last resort endTime to be applied when
    bool    public permissionedSeed;
    uint32  public vestingDuration;
    uint32  public vestingCliff;
    IERC20  public seedToken;
    IERC20  public fundingToken;
    uint256 public fee;                // Success fee expressed as a % (e.g. 10**18 = 100% fee, 10**16 = 1%)

    bytes   public metadata;           // IPFS Hash

    uint256 constant internal PRECISION = 10 ** 18; // used for precision e.g. 1 ETH = 10**18 wei; toWei("1") = 10**18

    bool    public closed;                 // is the distribution closed
    bool    public paused;                 // is the distribution paused
    bool    public isFunded;               // distribution can only start when required seed tokens have been funded
    bool    public initialized;            // is this contract initialized [not necessary that it is funded]
    bool    public minimumReached;         // if the softCap[minimum limit of funding token] is reached
    bool    public maximumReached;         // if the hardCap[maximum limit of funding token] is reached
    uint256 public vestingStartTime;       // timestamp for when vesting starts, by default == endTime,
    uint256 public totalFunderCount;       // Total funders that have contributed.
    uint256 public seedRemainder;          // Amount of seed tokens remaining to be distributed
    uint256 public seedClaimed;            // Amount of seed token claimed by the user.
    uint256 public feeRemainder;           // Amount of seed tokens remaining for the fee
    uint256 public fundingCollected;       // Amount of funding tokens collected by the seed contract.
    uint256 public fundingWithdrawn;       // Amount of funding token withdrawn from the seed contract.

    mapping (address => bool) public whitelisted;        // funders that are whitelisted and allowed to contribute
    mapping (address => FunderPortfolio) public funders; // funder address to funder portfolio

    event SeedsPurchased(address indexed recipient, uint256 amountPurchased);
    event TokensClaimed(address indexed recipient,uint256 amount,address indexed beneficiary,uint256 feeAmount);
    event FundingReclaimed(address indexed recipient, uint256 amountReclaimed);
    event MetadataUpdated(bytes indexed metadata);

    struct FunderPortfolio {
        uint256 totalClaimed;               // Total amount of seed tokens claimed
        uint256 fundingAmount;              // Total amount of funding tokens contributed
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "Seed: caller should be admin");
        _;
    }

    modifier isActive() {

        require(!closed, "Seed: should not be closed");
        require(!paused, "Seed: should not be paused");
        _;
    }

    function initialize(
        address _beneficiary,
        address _admin,
        address[] memory _tokens,
        uint256[] memory _softHardThresholds,
        uint256 _price,
        uint256 _startTime,
        uint256 _endTime,
        uint32  _vestingDuration,
        uint32  _vestingCliff,
        bool    _permissionedSeed,
        uint256   _fee
    ) external
    {

        require(!initialized, "Seed: contract already initialized");
        initialized = true;

        require(_tokens[0] != _tokens[1], "SeedFactory: seedToken cannot be fundingToken");
        require(_softHardThresholds[1] >= _softHardThresholds[0],"SeedFactory: hardCap cannot be less than softCap");
        require(_vestingDuration >= _vestingCliff, "SeedFactory: vestingDuration cannot be less than vestingCliff");
        require(_endTime > _startTime, "SeedFactory: endTime cannot be less than equal to startTime");

        beneficiary       = _beneficiary;
        admin             = _admin;
        softCap           = _softHardThresholds[0];
        hardCap           = _softHardThresholds[1];
        price             = _price;
        startTime         = _startTime;
        endTime           = _endTime;
        vestingStartTime  = endTime;
        vestingDuration   = _vestingDuration;
        vestingCliff      = _vestingCliff;
        permissionedSeed  = _permissionedSeed;
        seedToken         = IERC20(_tokens[0]);
        fundingToken      = IERC20(_tokens[1]);
        fee               = _fee;

        seedAmountRequired = (hardCap*PRECISION) / _price;
        feeAmountRequired  = (seedAmountRequired*fee) / PRECISION;
        seedRemainder      = seedAmountRequired;
        feeRemainder       = feeAmountRequired;
    }

    function buy(uint256 _fundingAmount) external isActive returns(uint256, uint256) {

        require(!maximumReached, "Seed: maximum funding reached");
        require(!permissionedSeed || whitelisted[msg.sender], "Seed: sender has no rights");
        require(endTime >= block.timestamp && startTime <= block.timestamp,
            "Seed: only allowed during distribution period");
        if (!isFunded) {
            require(seedToken.balanceOf(address(this)) >= seedAmountRequired + feeAmountRequired,
                "Seed: sufficient seeds not provided");
            isFunded = true;
        }
        uint256 seedAmount = (_fundingAmount*PRECISION)/price;

        uint256 feeAmount = (seedAmount*fee) / PRECISION;

        require(
            seedAmount >= vestingDuration,
            "Seed: amountVestedPerSecond > 0");

        require( fundingCollected + _fundingAmount <= hardCap,
            "Seed: amount exceeds contract sale hardCap");

        fundingCollected += _fundingAmount;

        seedRemainder -= seedAmount;
        feeRemainder  -= feeAmount;

        if (fundingCollected >= softCap) {
            minimumReached = true;
        }
        if (fundingCollected >= hardCap) {
            maximumReached = true;
            vestingStartTime = block.timestamp;
        }

        if (funders[msg.sender].fundingAmount==0) {
            totalFunderCount++;
        }
        funders[msg.sender].fundingAmount += _fundingAmount;

        require(
            fundingToken.transferFrom(msg.sender, address(this), _fundingAmount),
            "Seed: funding token transferFrom failed"
        );

        emit SeedsPurchased(msg.sender, seedAmount);

        return (seedAmount, feeAmount);
    }

    function claim(address _funder, uint256 _claimAmount) external returns(uint256) {

        require(minimumReached, "Seed: minimum funding amount not met");
        require(endTime < block.timestamp || maximumReached,"Seed: the distribution has not yet finished");
        uint256 amountClaimable;

        amountClaimable = calculateClaim(_funder);
        require(amountClaimable > 0, "Seed: amount claimable is 0");
        require(amountClaimable >= _claimAmount, "Seed: request is greater than claimable amount");
        uint256 feeAmountOnClaim = (_claimAmount * fee) / PRECISION;

        funders[_funder].totalClaimed    += _claimAmount;

        seedClaimed += _claimAmount;
        require(
            seedToken.transfer(beneficiary, feeAmountOnClaim) && seedToken.transfer(_funder, _claimAmount),
            "Seed: seed token transfer failed");

        emit TokensClaimed(_funder, _claimAmount, beneficiary, feeAmountOnClaim);

        return feeAmountOnClaim;
    }

    function retrieveFundingTokens() external returns(uint256) {

        require(startTime <= block.timestamp, "Seed: distribution haven't started");
        require(!minimumReached, "Seed: minimum funding amount met");
        FunderPortfolio storage tokenFunder = funders[msg.sender];
        uint256 fundingAmount = tokenFunder.fundingAmount;
        require(fundingAmount > 0, "Seed: zero funding amount");
        seedRemainder += seedAmountForFunder(msg.sender);
        feeRemainder += feeForFunder(msg.sender);
        totalFunderCount--;
        tokenFunder.fundingAmount = 0;
        fundingCollected -= fundingAmount;
        require(
            fundingToken.transfer(msg.sender, fundingAmount),
            "Seed: cannot return funding tokens to msg.sender"
        );
        emit FundingReclaimed(msg.sender, fundingAmount);

        return fundingAmount;
    }


    function pause() external onlyAdmin isActive {

        paused = true;
    }

    function unpause() external onlyAdmin {

        require(closed != true, "Seed: should not be closed");
        require(paused == true, "Seed: should be paused");

        paused = false;
    }

    function close() external onlyAdmin {

        require(!closed, "Seed: should not be closed");
        closed = true;
        paused = false;
    }

    function retrieveSeedTokens(address _refundReceiver) external onlyAdmin {

        require(
            closed ||
            maximumReached ||
            block.timestamp >= endTime,
            "Seed: The ability to buy seed tokens must have ended before remaining seed tokens can be withdrawn"
        );
        if (!minimumReached) {
            require(
                seedToken.transfer(_refundReceiver, seedToken.balanceOf(address(this))),
                "Seed: should transfer seed tokens to refund receiver"
            );
        } else {
            uint256 totalSeedDistributed = (seedAmountRequired+feeAmountRequired)-(seedRemainder+feeRemainder);
            uint256 amountToTransfer = seedToken.balanceOf(address(this))-totalSeedDistributed;
            require(
                seedToken.transfer(_refundReceiver, amountToTransfer),
                "Seed: should transfer seed tokens to refund receiver"
            );
        }
    }

    function whitelist(address _buyer) external onlyAdmin {

        require(!closed, "Seed: should not be closed");
        require(permissionedSeed == true, "Seed: seed is not whitelisted");

        whitelisted[_buyer] = true;
    }

    function whitelistBatch(address[] memory _buyers) external onlyAdmin {

        require(!closed, "Seed: should not be closed");
        require(permissionedSeed == true, "Seed: seed is not whitelisted");
        for (uint256 i = 0; i < _buyers.length; i++) {
            whitelisted[_buyers[i]] = true;
        }
    }

    function unwhitelist(address buyer) external onlyAdmin {

        require(!closed, "Seed: should not be closed");
        require(permissionedSeed == true, "Seed: seed is not whitelisted");

        whitelisted[buyer] = false;
    }

    function withdraw() external onlyAdmin {

        require(
            maximumReached ||
            (minimumReached && block.timestamp >= endTime),
            "Seed: cannot withdraw while funding tokens can still be withdrawn by contributors"
        );
        uint pendingFundingBalance = fundingCollected - fundingWithdrawn;
        fundingWithdrawn = fundingCollected;
        fundingToken.transfer(msg.sender, pendingFundingBalance);
    }

    function updateMetadata(bytes memory _metadata) external {

        require(
            initialized != true || msg.sender == admin,
            "Seed: contract should not be initialized or caller should be admin"
        );
        metadata = _metadata;
        emit MetadataUpdated(_metadata);
    }

    function calculateClaim(address _funder) public view returns(uint256) {

        FunderPortfolio storage tokenFunder = funders[_funder];

        if (block.timestamp < vestingStartTime) {
            return 0;
        }

        uint256 elapsedSeconds = block.timestamp - vestingStartTime;

        if (elapsedSeconds < vestingCliff) {
            return 0;
        }

        if (elapsedSeconds >= vestingDuration) {
            return seedAmountForFunder(_funder) - tokenFunder.totalClaimed;
        } else {
            uint256 amountVested = (elapsedSeconds*seedAmountForFunder(_funder)) / vestingDuration;
            return amountVested - tokenFunder.totalClaimed;
        }
    }

    function feeClaimed() public view returns(uint256) {

        return (seedClaimed*fee)/PRECISION;
    }

    function feeClaimedForFunder(address _funder) public view returns(uint256) {

        return (funders[_funder].totalClaimed*fee)/PRECISION;
    }

    function feeForFunder(address _funder) public view returns(uint256) {

        return (seedAmountForFunder(_funder)*fee)/PRECISION;
    }

    function seedAmountForFunder(address _funder) public view returns(uint256) {

        return (funders[_funder].fundingAmount*PRECISION)/price;
    }
}