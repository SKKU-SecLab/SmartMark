

pragma solidity =0.6.11 >=0.6.0 <0.8.0;


interface IMapleGlobals {


    function pendingGovernor() external view returns (address);


    function governor() external view returns (address);


    function globalAdmin() external view returns (address);


    function mpl() external view returns (address);


    function mapleTreasury() external view returns (address);


    function isValidBalancerPool(address) external view returns (bool);


    function treasuryFee() external view returns (uint256);


    function investorFee() external view returns (uint256);


    function defaultGracePeriod() external view returns (uint256);


    function fundingPeriod() external view returns (uint256);


    function swapOutRequired() external view returns (uint256);


    function isValidLiquidityAsset(address) external view returns (bool);


    function isValidCollateralAsset(address) external view returns (bool);


    function isValidPoolDelegate(address) external view returns (bool);


    function validCalcs(address) external view returns (bool);


    function isValidCalc(address, uint8) external view returns (bool);


    function getLpCooldownParams() external view returns (uint256, uint256);


    function isValidLoanFactory(address) external view returns (bool);


    function isValidSubFactory(address, address, uint8) external view returns (bool);


    function isValidPoolFactory(address) external view returns (bool);

    
    function getLatestPrice(address) external view returns (uint256);

    
    function defaultUniswapPath(address, address) external view returns (address);


    function minLoanEquity() external view returns (uint256);

    
    function maxSwapSlippage() external view returns (uint256);


    function protocolPaused() external view returns (bool);


    function stakerCooldownPeriod() external view returns (uint256);


    function lpCooldownPeriod() external view returns (uint256);


    function stakerUnstakeWindow() external view returns (uint256);


    function lpWithdrawWindow() external view returns (uint256);


    function oracleFor(address) external view returns (address);


    function validSubFactories(address, address) external view returns (bool);


    function setStakerCooldownPeriod(uint256) external;


    function setLpCooldownPeriod(uint256) external;


    function setStakerUnstakeWindow(uint256) external;


    function setLpWithdrawWindow(uint256) external;


    function setMaxSwapSlippage(uint256) external;


    function setGlobalAdmin(address) external;


    function setValidBalancerPool(address, bool) external;


    function setProtocolPause(bool) external;


    function setValidPoolFactory(address, bool) external;


    function setValidLoanFactory(address, bool) external;


    function setValidSubFactory(address, address, bool) external;


    function setDefaultUniswapPath(address, address, address) external;


    function setPoolDelegateAllowlist(address, bool) external;


    function setCollateralAsset(address, bool) external;


    function setLiquidityAsset(address, bool) external;


    function setCalc(address, bool) external;


    function setInvestorFee(uint256) external;


    function setTreasuryFee(uint256) external;


    function setMapleTreasury(address) external;


    function setDefaultGracePeriod(uint256) external;


    function setMinLoanEquity(uint256) external;


    function setFundingPeriod(uint256) external;


    function setSwapOutRequired(uint256) external;


    function setPriceOracle(address, address) external;


    function setPendingGovernor(address) external;


    function acceptGovernor() external;


}


interface IChainlinkAggregatorV3 {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


  
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
        uint80  roundId,
        int256  answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80  answeredInRound
    );


  function latestRoundData()
    external
    view
    returns (
        uint80  roundId,
        int256  answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80  answeredInRound
    );


}


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}



contract ChainlinkOracle is Ownable {


    IChainlinkAggregatorV3 public priceFeed;
    IMapleGlobals public globals;

    address public immutable assetAddress;

    bool   public manualOverride;
    int256 public manualPrice;

    event ChangeAggregatorFeed(address _newMedianizer, address _oldMedianizer);
    event       SetManualPrice(int256 _oldPrice, int256 _newPrice);
    event    SetManualOverride(bool _override);

    constructor(address _aggregator, address _assetAddress, address _owner) public {
        require(_aggregator != address(0), "CO:ZERO_AGGREGATOR_ADDR");
        priceFeed       = IChainlinkAggregatorV3(_aggregator);
        assetAddress    = _assetAddress;
        transferOwnership(_owner);
    }

    function getLatestPrice() public view returns (int256) {

        if (manualOverride) return manualPrice;
        (uint80 roundID, int256 price,,uint256 timeStamp, uint80 answeredInRound) = priceFeed.latestRoundData();

        require(timeStamp != 0,             "CO:ROUND_NOT_COMPLETE");
        require(answeredInRound >= roundID,         "CO:STALE_DATA");
        require(price != int256(0),                 "CO:ZERO_PRICE");
        return price;
    }


    function changeAggregator(address aggregator) external onlyOwner {

        require(aggregator != address(0), "CO:ZERO_AGGREGATOR_ADDR");
        emit ChangeAggregatorFeed(aggregator, address(priceFeed));
        priceFeed = IChainlinkAggregatorV3(aggregator);
    }

    function getAssetAddress() external view returns (address) {

        return assetAddress;
    }

    function getDenomination() external pure returns (bytes32) {

        return bytes32("USD");
    }

    function setManualPrice(int256 _price) public onlyOwner {

        require(manualOverride, "CO:MANUAL_OVERRIDE_NOT_ACTIVE");
        emit SetManualPrice(manualPrice, _price);
        manualPrice = _price;
    }

    function setManualOverride(bool _override) public onlyOwner {

        manualOverride = _override;
        emit SetManualOverride(_override);
    }

}