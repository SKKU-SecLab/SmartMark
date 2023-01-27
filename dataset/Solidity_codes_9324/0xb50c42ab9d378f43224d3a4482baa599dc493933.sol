

pragma solidity >=0.8.0 <0.9.0;

contract VestingVault {


    address public beneficiary;

    uint256 public initialVestedAmount;

    uint256 public vestingEndTimestamp;

    uint256 public constant priceInterval = 0.2e18;

    uint256 public constant priceBatches = 15;

    address public constant deri = 0xA487bF43cF3b10dffc97A9A744cbB7036965d3b9;

    address public constant sushiV2Pair = 0xA3DfbF2933FF3d96177bde4928D0F5840eE55600;

    uint256 public blockTimestampLast;

    uint256 public price0CumulativeLast;

    uint256 public prepareWithdrawTimestamp;

    constructor (address beneficiary_, uint256 initialVestedAmount_, uint256 vestingEndTimestamp_) {
        beneficiary = beneficiary_;
        initialVestedAmount = initialVestedAmount_;
        vestingEndTimestamp = vestingEndTimestamp_;
    }

    function prepareWithdraw() external {

        require(msg.sender == beneficiary, 'prepareWithdraw: only beneficiary');

        (, , uint256 timestamp) = IUniswapV2Pair(sushiV2Pair).getReserves();
        blockTimestampLast = timestamp;
        price0CumulativeLast = IUniswapV2Pair(sushiV2Pair).price0CumulativeLast();
        prepareWithdrawTimestamp = block.timestamp;
    }

    function estimateAvailableAmount() external view returns (uint256) {

        uint256 balance = IERC20(deri).balanceOf(address(this));
        uint256 available;

        if (block.timestamp >= vestingEndTimestamp) {
            available = balance;
        } else {
            (uint256 reserve0, uint256 reserve1,) = IUniswapV2Pair(sushiV2Pair).getReserves();
            uint256 price = reserve1 * 10**30 / reserve0;

            uint256 unlocked = price / priceInterval * initialVestedAmount / priceBatches;
            uint256 locked = unlocked >= initialVestedAmount ? 0 : initialVestedAmount - unlocked;
            available = balance > locked ? balance - locked : 0;
        }

        return available;
    }

    function getAvailableAmount() public view returns (uint256) {

        uint256 balance = IERC20(deri).balanceOf(address(this));
        uint256 available;

        if (block.timestamp >= vestingEndTimestamp) {
            available = balance;
        } else {
            require(
                prepareWithdrawTimestamp != 0 && block.timestamp >= prepareWithdrawTimestamp + 86400,
                'getAvailableAmount: not prepared, or wait at least 1 day after preparation'
            );

            (, , uint256 blockTimestampCurrent) = IUniswapV2Pair(sushiV2Pair).getReserves();
            uint256 price0CumulativeCurrent = IUniswapV2Pair(sushiV2Pair).price0CumulativeLast();

            require(blockTimestampLast != blockTimestampCurrent, 'getAvailableAmount: cannot calculate TWAP');

            uint256 price = (price0CumulativeCurrent - price0CumulativeLast) * 10**30 / (blockTimestampCurrent - blockTimestampLast) / 2**112;

            uint256 unlocked = price / priceInterval * initialVestedAmount / priceBatches;
            uint256 locked = unlocked >= initialVestedAmount ? 0 : initialVestedAmount - unlocked;
            available = balance > locked ? balance - locked : 0;
        }

        return available;
    }

    function withdraw() external {

        require(msg.sender == beneficiary, 'prepareWithdraw: only beneficiary');
        uint256 available = getAvailableAmount();

        prepareWithdrawTimestamp = 0;

        if (available > 0) {
            IERC20(deri).transfer(beneficiary, available);
        }
    }

}

interface IUniswapV2Pair {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint256);

}

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external;

}