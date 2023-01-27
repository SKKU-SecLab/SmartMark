
pragma solidity 0.7.6;

interface IOptimizerStrategy {

    function maxTotalSupply() external view returns (uint256);


    function twapDuration() external view returns (uint32);


    function maxTwapDeviation() external view returns (int24);


    function tickRangeMultiplier() external view returns (int24);


    function priceImpactPercentage() external view returns (uint24);

}

contract OptimizerStrategy is IOptimizerStrategy {


    uint256 public override maxTotalSupply;
    address public governance;
    address public pendingGovernance;

    uint32 public override twapDuration;
    int24 public override maxTwapDeviation;
    int24 public override tickRangeMultiplier;
    uint24 public override priceImpactPercentage;
    
    event TransferGovernance(address indexed previousGovernance, address indexed newGovernance);
    
    constructor(
        uint32 _twapDuration,
        int24 _maxTwapDeviation,
        int24 _tickRangeMultiplier,
        uint24 _priceImpactPercentage,
        uint256 _maxTotalSupply
    ) {
        twapDuration = _twapDuration;
        maxTwapDeviation = _maxTwapDeviation;
        tickRangeMultiplier = _tickRangeMultiplier;
        priceImpactPercentage = _priceImpactPercentage;
        maxTotalSupply = _maxTotalSupply;
        governance = msg.sender;

        require(_maxTwapDeviation >= 20, "maxTwapDeviation");
        require(_twapDuration >= 100, "twapDuration");
        require(_priceImpactPercentage < 1e6 && _priceImpactPercentage > 0, "PIP");
        require(maxTotalSupply > 0, "maxTotalSupply");
    }

    modifier onlyGovernance {

        require(msg.sender == governance, "NOT ALLOWED");
        _;
    }

    function setMaxTotalSupply(uint256 _maxTotalSupply) external onlyGovernance {

        require(_maxTotalSupply > 0, "maxTotalSupply");
        maxTotalSupply = _maxTotalSupply;
    }

    function setTwapDuration(uint32 _twapDuration) external onlyGovernance {

        require(_twapDuration >= 100, "twapDuration");
        twapDuration = _twapDuration;
    }

    function setMaxTwapDeviation(int24 _maxTwapDeviation) external onlyGovernance {

        require(_maxTwapDeviation >= 20, "PF");
        maxTwapDeviation = _maxTwapDeviation;
    }

    function setTickRange(int24 _tickRangeMultiplier) external onlyGovernance {

        tickRangeMultiplier = _tickRangeMultiplier;
    }

    function setPriceImpact(uint16 _priceImpactPercentage) external onlyGovernance {

        require(_priceImpactPercentage < 1e6 && _priceImpactPercentage > 0, "PIP");
        priceImpactPercentage = _priceImpactPercentage;
    }

    
    function setGovernance(address _governance) external onlyGovernance {

        pendingGovernance = _governance;
    }

    function acceptGovernance() external {

        require(msg.sender == pendingGovernance, "PG");
        emit TransferGovernance(governance, pendingGovernance);
        pendingGovernance = address(0);
        governance = msg.sender;
    }
}