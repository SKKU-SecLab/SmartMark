
pragma solidity ^0.5.16;


contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract StandardRewardCalculator is Ownable {

    uint224 internal constant SCALE = 1e18;

    uint224 public blocksPerDay;

    uint224 internal MAX_BLOCKS_PER_DAY = 24 * 3600 / 10;
    uint224 internal MIN_BLOCKS_PER_DAY = 24 * 3600 / 15;

    uint224 internal MAX_AVERAGE_QUALITY = 1e18;

    struct Checkpoint {
        uint32 fromBlock;
        uint224 value;
    }

    uint32 public numCheckpoints;

    mapping(uint32 => Checkpoint) public checkpoints;


    event BlocksPerDayChanged(uint blocksPerDay);

    address public poster;

    constructor(address poster_, uint blocksPerDay_) public {
        addCheckpoint(0);
        setPoster(poster_);
        setBlocksPerDay(blocksPerDay_);
    }

    function calculate(uint filstAmount, uint accrualBlockNumber) external view returns (uint) {


        uint accumulatedFactor;
        uint endBlock = block.number;
        uint32 nextCheckIndex = numCheckpoints - 1;
        while (endBlock > accrualBlockNumber) {
            Checkpoint memory checkpoint = checkpoints[nextCheckIndex];
            uint beginBlock = accrualBlockNumber > checkpoint.fromBlock ? accrualBlockNumber : checkpoint.fromBlock;
            uint blockDelta = sub(endBlock, beginBlock, "blockDelta");
            uint factor = mul(checkpoint.value, blockDelta, "factor");
            accumulatedFactor = add(accumulatedFactor, factor, "accumulatedFactor");
            nextCheckIndex = sub32(nextCheckIndex, uint32(1), "nextCheckIndex");
            endBlock = beginBlock;
        }

        uint rewardAccumulatedMinUnit = mul(filstAmount, accumulatedFactor, "rewardAccumulatedMinUnit") / SCALE;
        return rewardAccumulatedMinUnit / 10 ** 18; // FILST's decimals is 18
    }

    function getAverageQualityOfLast24Hours() public view returns(uint){

        uint224 scaledQualityPerDay = mul224(checkpoints[numCheckpoints - 1].value, blocksPerDay, "scaledQualityPerDay overflow");
        uint224 qualityPerDay = div224(scaledQualityPerDay, SCALE, "qualityPerDay");
        return qualityPerDay;
    }

    function setAverageQualityOfLast24Hours(uint quality) external {

        require(msg.sender == poster, "poster check");

        uint224 quality224 = safe224(quality, "quality exceeds 224 bits");
        require(quality224 > 0 && quality224 < MAX_AVERAGE_QUALITY, "Bad quality value");

        uint224 scaledQuality = mul224(quality224, SCALE, "scaledQuality");
        uint224 qualityPerBlock = div224(scaledQuality, blocksPerDay, "qualityPerBlock");

        addCheckpoint(qualityPerBlock);
    }

    function addCheckpoint(uint224 qualityPerBlock) internal {

        uint32 blockNumber = safe32(block.number, "block number exceeds 32 bits");
        checkpoints[numCheckpoints] = Checkpoint({fromBlock: blockNumber, value: qualityPerBlock});
        numCheckpoints = numCheckpoints + 1;
    }


    function setPoster(address newPoster) public onlyOwner {

        require(newPoster != address(0), "invalid new poster");
        poster = newPoster;
    }

    function setBlocksPerDay(uint newBlocksPerDay) public onlyOwner {

        uint224 newBlocksPerDay224 = safe224(newBlocksPerDay, "newBlocksPerDay exceeds 224 bits");
        require(newBlocksPerDay224 >= MIN_BLOCKS_PER_DAY, "exceeds min");
        require(newBlocksPerDay224 <= MAX_BLOCKS_PER_DAY, "exceeds max");

        blocksPerDay = newBlocksPerDay224;

        emit BlocksPerDayChanged(newBlocksPerDay);
    }


    function safe32(uint n, string memory errorMessage) internal pure returns (uint32) {

        require(n < 2**32, errorMessage);
        return uint32(n);
    }

    function safe224(uint n, string memory errorMessage) internal pure returns (uint224) {

        require(n < 2**224, errorMessage);
        return uint224(n);
    }

    function mul224(uint224 a, uint224 b, string memory errorMessage) internal pure returns (uint224) {

        if (a == 0 || b == 0) {
            return 0;
        }
        uint224 c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div224(uint224 a, uint224 b, string memory errorMessage) pure internal returns (uint224) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function add(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function sub32(uint32 a, uint32 b, string memory errorMessage) pure internal returns (uint32) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function mul(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }
}