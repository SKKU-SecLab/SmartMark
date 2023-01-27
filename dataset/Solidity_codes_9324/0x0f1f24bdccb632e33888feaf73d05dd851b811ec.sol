

pragma solidity =0.6.6;

interface UniswapV2Pair {

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function getReserves() external view returns (uint112, uint112, uint32);

}

contract ReethPriceOracle {


    address public owner;
    bool private _firstCapture = true;
    uint256 private _reethDecimals = 18; // Same as YAM
    uint256 private _reethETHPrice = 0;
    uint256 private _reethPriceWindow = 0; // The time period this price was calculated over, determines its weight
    uint256 private _tokenIndex = 0;
    uint256 public lastREETHPriceUpdate; // The last time the price was updated
    uint256 public updateFrequency = 10 minutes; // Oracle can be updated at least every 10 minutes

    uint256 constant DIVISION_FACTOR = 100000;
    
    address public mainLiquidity;
    uint256 private lastTWAPCumulativePrice;
    uint32 private lastTWAPBlockTime;
    uint256 private lastTWAPPrice;
    
    event NoLiquidity();
    event FirstPriceCapture(); // First time price update is called, must wait til another time to update
    event FailedPriceCapture(); // Not quick enough price movement for a twap to be calculated
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyGovernance() {

        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function changeLiquidityToken(address _lp, uint256 _pos) internal {

        mainLiquidity = _lp;
        _tokenIndex = _pos;
        _reethETHPrice = 0;
        _reethPriceWindow = 0;
        lastTWAPBlockTime = 0;
        lastTWAPCumulativePrice = 0;
        lastREETHPriceUpdate = 0;
        _firstCapture = true;
    }
    
    function getLatestREETHPrice() external view returns (uint256) {

        return _reethETHPrice;
    }
    
    function updateREETHPrice() external {

        if(mainLiquidity == address(0)) { return; }
        if(now < lastREETHPriceUpdate + updateFrequency){ return; } // Do nothing if update is called too soon
        uint256 period = now - lastREETHPriceUpdate; // Get the time between the last update and now
        lastREETHPriceUpdate = now;
        UniswapV2Pair pair = UniswapV2Pair(mainLiquidity);
        (, uint112 reserve1, uint32 _blockTime) = pair.getReserves();
        if(reserve1 == 0){
            _reethETHPrice = 0;
            _reethPriceWindow = 0;
            lastTWAPBlockTime = 0;
            lastTWAPCumulativePrice = 0;
            _firstCapture = true;
            emit NoLiquidity();
            return;
        }
        if(lastTWAPBlockTime != _blockTime){
            if(_firstCapture == true){
                if(_tokenIndex == 0){
                    lastTWAPCumulativePrice = pair.price0CumulativeLast();
                }else{
                    lastTWAPCumulativePrice = pair.price1CumulativeLast();
                }
                lastTWAPBlockTime = _blockTime;
                _firstCapture = false;
                emit FirstPriceCapture();
                return;
            }else{
                uint256 cumuPrice = 0;
                if(_tokenIndex == 0){
                    cumuPrice = pair.price0CumulativeLast();
                }else{
                    cumuPrice = pair.price1CumulativeLast();
                }
                lastTWAPPrice = ((cumuPrice - lastTWAPCumulativePrice) / (_blockTime - lastTWAPBlockTime) * (10**_reethDecimals)) >> 112;
                lastTWAPCumulativePrice = cumuPrice;
                lastTWAPBlockTime = _blockTime;
            }
        }
        if(lastTWAPPrice == 0){
            emit FailedPriceCapture();
            return;
        }
        if(_reethPriceWindow == 0){
            _reethPriceWindow = updateFrequency;
            _reethETHPrice = lastTWAPPrice;
        }else{
            uint256 price = lastTWAPPrice;
            _reethETHPrice = (_reethETHPrice * (_reethPriceWindow * DIVISION_FACTOR / (_reethPriceWindow + period)) / DIVISION_FACTOR);
            _reethETHPrice += (price * (period * DIVISION_FACTOR / (_reethPriceWindow + period)) / DIVISION_FACTOR);
            _reethPriceWindow = period; // Set the window to the new period
        }
    }
    
    function governanceChangeFrequency(uint256 _freq) external onlyGovernance {

        updateFrequency = _freq;
    }
    
    
    uint256 private _timelockStart; // The start of the timelock to change governance variables
    uint256 private _timelockType; // The function that needs to be changed
    uint256 constant TIMELOCK_DURATION = 86400; // Timelock is 24 hours
    
    address private _timelock_address;
    uint256 private _timelock_data;
    
    modifier timelockConditionsMet(uint256 _type) {

        require(_timelockType == _type, "Timelock not acquired for this function");
        _timelockType = 0; // Reset the type once the timelock is used
        require(now >= _timelockStart + TIMELOCK_DURATION, "Timelock time not met");
        _;
    }
    
    function startGovernanceChange(address _address) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 1;
        _timelock_address = _address;       
    }
    
    function finishGovernanceChange() external onlyGovernance timelockConditionsMet(1) {

        owner = _timelock_address;
    }
    
    function startUpdateLiquidityToken(address _address, uint256 _index) external onlyGovernance {

        _timelockStart = now;
        _timelockType = 2;
        _timelock_address = _address;     
        _timelock_data = _index;
        if(mainLiquidity == address(0)){
            changeLiquidityToken(_address, _index);
            _timelockType = 0;
        }
    }
    
    function finishUpdateLiquidityToken() external onlyGovernance timelockConditionsMet(2) {

        changeLiquidityToken(_timelock_address, _timelock_data);
    }

}