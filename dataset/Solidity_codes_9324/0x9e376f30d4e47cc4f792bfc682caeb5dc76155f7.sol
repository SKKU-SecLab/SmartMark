

pragma solidity 0.5.7;


contract Proxy {

    function () external payable {
        address _impl = implementation();
        require(_impl != address(0));

        assembly {
            let ptr := mload(0x40)
            calldatacopy(ptr, 0, calldatasize)
            let result := delegatecall(gas, _impl, ptr, calldatasize, 0, 0)
            let size := returndatasize
            returndatacopy(ptr, 0, size)

            switch result
            case 0 { revert(ptr, size) }
            default { return(ptr, size) }
            }
    }

    function implementation() public view returns (address);

}


pragma solidity 0.5.7;



contract UpgradeabilityProxy is Proxy {

    event Upgraded(address indexed implementation);

    bytes32 private constant IMPLEMENTATION_POSITION = keccak256("org.govblocks.proxy.implementation");

    constructor() public {}

    function implementation() public view returns (address impl) {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
            impl := sload(position)
        }
    }

    function _setImplementation(address _newImplementation) internal {

        bytes32 position = IMPLEMENTATION_POSITION;
        assembly {
        sstore(position, _newImplementation)
        }
    }

    function _upgradeTo(address _newImplementation) internal {

        address currentImplementation = implementation();
        require(currentImplementation != _newImplementation);
        _setImplementation(_newImplementation);
        emit Upgraded(_newImplementation);
    }
}


pragma solidity 0.5.7;



contract OwnedUpgradeabilityProxy is UpgradeabilityProxy {

    event ProxyOwnershipTransferred(address previousOwner, address newOwner);

    bytes32 private constant PROXY_OWNER_POSITION = keccak256("org.govblocks.proxy.owner");

    constructor(address _implementation) public {
        _setUpgradeabilityOwner(msg.sender);
        _upgradeTo(_implementation);
    }

    modifier onlyProxyOwner() {

        require(msg.sender == proxyOwner());
        _;
    }

    function proxyOwner() public view returns (address owner) {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            owner := sload(position)
        }
    }

    function transferProxyOwnership(address _newOwner) public onlyProxyOwner {

        require(_newOwner != address(0));
        _setUpgradeabilityOwner(_newOwner);
        emit ProxyOwnershipTransferred(proxyOwner(), _newOwner);
    }

    function upgradeTo(address _implementation) public onlyProxyOwner {

        _upgradeTo(_implementation);
    }

    function _setUpgradeabilityOwner(address _newProxyOwner) internal {

        bytes32 position = PROXY_OWNER_POSITION;
        assembly {
            sstore(position, _newProxyOwner)
        }
    }
}


pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint128 c = a - b;

        return c;
    }

    function sub(uint128 a, uint128 b, string memory errorMessage) internal pure returns (uint128) {

        require(b <= a, errorMessage);
        uint128 c = a - b;

        return c;
    }

    function mul(uint128 a, uint128 b) internal pure returns (uint128) {

        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b > 0, "SafeMath: division by zero");
        uint128 c = a / b;

        return c;
    }

    function mod(uint128 a, uint128 b) internal pure returns (uint128) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath64 {

    function add(uint64 a, uint64 b) internal pure returns (uint64) {

        uint64 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint64 c = a - b;

        return c;
    }

    function sub(uint64 a, uint64 b, string memory errorMessage) internal pure returns (uint64) {

        require(b <= a, errorMessage);
        uint64 c = a - b;

        return c;
    }

    function mul(uint64 a, uint64 b) internal pure returns (uint64) {

        if (a == 0) {
            return 0;
        }

        uint64 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b > 0, "SafeMath: division by zero");
        uint64 c = a / b;

        return c;
    }

    function mod(uint64 a, uint64 b) internal pure returns (uint64) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library SafeMath32 {

    function add(uint32 a, uint32 b) internal pure returns (uint32) {

        uint32 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint32 c = a - b;

        return c;
    }

    function sub(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {

        require(b <= a, errorMessage);
        uint32 c = a - b;

        return c;
    }

    function mul(uint32 a, uint32 b) internal pure returns (uint32) {

        if (a == 0) {
            return 0;
        }

        uint32 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b > 0, "SafeMath: division by zero");
        uint32 c = a / b;

        return c;
    }

    function mod(uint32 a, uint32 b) internal pure returns (uint32) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}


pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}



pragma solidity 0.5.7;


contract IMaster {

    mapping(address => bool) public whitelistedSponsor;
    function dAppToken() public view returns(address);

    function isInternal(address _address) public view returns(bool);

    function getLatestAddress(bytes2 _module) public view returns(address);

    function isAuthorizedToGovern(address _toCheck) public view returns(bool);

}


contract Governed {


    address public masterAddress; // Name of the dApp, needs to be set by contracts inheriting this contract

    modifier onlyAuthorizedToGovern() {

        IMaster ms = IMaster(masterAddress);
        require(ms.getLatestAddress("GV") == msg.sender, "Not authorized");
        _;
    }

    function isAuthorizedToGovern(address _toCheck) public view returns(bool) {

        IMaster ms = IMaster(masterAddress);
        return (ms.getLatestAddress("GV") == _toCheck);
    } 

}


pragma solidity 0.5.7;

contract ITokenController {

	address public token;
    address public bLOTToken;

    function swapBLOT(address _of, address _to, uint256 amount) public;


    function totalBalanceOf(address _of)
        public
        view
        returns (uint256 amount);


    function transferFrom(address _token, address _of, address _to, uint256 amount) public;


    function tokensLockedAtTime(address _of, bytes32 _reason, uint256 _time)
        public
        view
        returns (uint256 amount);


    function burnCommissionTokens(uint256 amount) external returns(bool);

 
    function initiateVesting(address _vesting) external;


    function lockForGovernanceVote(address _of, uint _days) public;


    function totalSupply() public view returns (uint256);


    function mint(address _member, uint _amount) public;


}


pragma solidity 0.5.7;

interface IChainLinkOracle
{

	function latestAnswer() external view returns (int256);

	function decimals() external view returns (uint8);

	function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );


  	function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    ); 

}


pragma solidity 0.5.7;
contract IMarketUtility {


    function initialize(address payable[] calldata _addressParams, address _initiater) external;


    function setAuthorizedAddres() public;


    function updateUintParameters(bytes8 code, uint256 value) external;


    function updateAddressParameters(bytes8 code, address payable value) external;

 
    function getMarketInitialParams() public view returns(address[] memory, uint , uint, uint, uint);


    function getAssetPriceUSD(address _currencyAddress) external view returns(uint latestAnswer);


    function getAssetValueETH(address _currencyAddress, uint256 _amount)
        public
        view
        returns (uint256 tokenEthValue);

    
    function checkMultiplier(address _asset, address _user, uint _predictionStake, uint predictionPoints, uint _stakeValue) public view returns(uint, bool);

  
    function calculatePredictionPoints(address _user, bool multiplierApplied, uint _predictionStake, address _asset, uint64 totalPredictionPoints, uint64 predictionPointsOnOption) external view returns(uint64 predictionPoints, bool isMultiplierApplied);


    function calculateOptionRange(uint _optionRangePerc, uint64 _decimals, uint8 _roundOfToNearest, address _marketFeed) external view returns(uint64 _minValue, uint64 _maxValue);

    
    function getOptionPrice(uint64 totalPredictionPoints, uint64 predictionPointsOnOption) public view returns(uint64 _optionPrice);

    
    function getPriceFeedDecimals(address _priceFeed) public view returns(uint8);


    function getValueAndMultiplierParameters(address _asset, uint256 _amount)
        public
        view
        returns (uint256, uint256);


    function update() external;

    
    function calculatePredictionValue(uint[] memory params, address asset, address user, address marketFeedAddress, bool _checkMultiplier) public view returns(uint _predictionValue, bool _multiplierApplied);

    
    function getBasicMarketDetails()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function getDisputeResolutionParams() public view returns (uint256);

    function calculateOptionPrice(uint[] memory params, address marketFeedAddress) public view returns(uint _optionPrice);


    function getSettlemetPrice(
        address _currencyFeedAddress,
        uint256 _settleTime
    ) public view returns (uint256 latestAnswer, uint256 roundId);

}


pragma solidity 0.5.7;

contract IToken {


    function decimals() external view returns(uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function mint(address account, uint256 amount) external returns (bool);

    
    function burn(uint256 amount) external;


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


}


pragma solidity 0.5.7;

contract IAllMarkets {


	enum PredictionStatus {
      Live,
      InSettlement,
      Cooling,
      InDispute,
      Settled
    }

    function marketStatus(uint256 _marketId) public view returns(PredictionStatus);


    function burnDisputedProposalTokens(uint _proposaId) external;


    function getTotalStakedValueInPLOT(uint256 _marketId) public view returns(uint256);


}


pragma solidity 0.5.7;










contract MarketCreationRewards is Governed {


    using SafeMath for *;

	  event MarketCreatorRewardPoolShare(address indexed createdBy, uint256 indexed marketIndex, uint256 plotIncentive, uint256 ethIncentive);
    event MarketCreationReward(address indexed createdBy, uint256 marketIndex, uint256 plotIncentive, uint256 gasUsed, uint256 gasCost, uint256 gasPriceConsidered, uint256 gasPriceGiven, uint256 maxGasCap, uint256 rewardPoolSharePerc);
    event ClaimedMarketCreationReward(address indexed user, uint256 ethIncentive, uint256 plotIncentive);

    modifier onlyInternal() {

      IMaster(masterAddress).isInternal(msg.sender);
      _;
    }
    
    struct MarketCreationRewardData {
      uint ethIncentive;
      uint plotIncentive;
      uint64 ethDeposited;
      uint64 plotDeposited;
      uint16 rewardPoolSharePerc;
      address createdBy;
    }

    struct MarketCreationRewardUserData {
      uint incentives;
      uint128 lastClaimedIndex;
      uint64[] marketsCreated;
    }
	
	  uint16 internal maxRewardPoolPercForMC;
    uint16 internal minRewardPoolPercForMC;
    uint256 internal maxGasPrice;
    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal plotToken;
    uint256 internal plotStakeForRewardPoolShare;
    uint256 internal rewardPoolShareThreshold;
    uint internal predictionDecimalMultiplier;
    ITokenController internal tokenController;
    IChainLinkOracle internal clGasPriceAggregator;
    IMarketUtility internal marketUtility;
    IAllMarkets internal allMarkets;
    mapping(uint256 => MarketCreationRewardData) internal marketCreationRewardData; //Of market
    mapping(address => MarketCreationRewardUserData) internal marketCreationRewardUserData; //Of user

    function setMasterAddress() public {

      OwnedUpgradeabilityProxy proxy =  OwnedUpgradeabilityProxy(address(uint160(address(this))));
      require(msg.sender == proxy.proxyOwner(),"not owner.");
      IMaster ms = IMaster(msg.sender);
      masterAddress = msg.sender;
      plotToken = ms.dAppToken();
      tokenController = ITokenController(ms.getLatestAddress("TC"));
      allMarkets = IAllMarkets(ms.getLatestAddress("AM"));
    }

    function initialise(address _utility, address _clGasPriceAggregator) external {

      require(address(clGasPriceAggregator) == address(0));
      clGasPriceAggregator = IChainLinkOracle(_clGasPriceAggregator);
      marketUtility = IMarketUtility(_utility);
      maxGasPrice = 100 * 10**9;
      maxRewardPoolPercForMC = 500; // Raised by 2 decimals
      minRewardPoolPercForMC = 50; // Raised by 2 decimals
      plotStakeForRewardPoolShare = 25000 ether;
      rewardPoolShareThreshold = 1 ether;
      predictionDecimalMultiplier = 10;
    }

    function updateUintParameters(bytes8 code, uint256 value) external onlyAuthorizedToGovern {

      if(code == "MAXGAS") { // Maximum gas upto which is considered while calculating market creation incentives
        maxGasPrice = value;
      } else if(code == "MAXRPSP") { // Max Reward Pool percent for market creator
        maxRewardPoolPercForMC = uint16(value);
      } else if(code == "MINRPSP") { // Min Reward Pool percent for market creator
        minRewardPoolPercForMC = uint16(value);
      } else if(code == "PSFRPS") { // Reward Pool percent for market creator
        plotStakeForRewardPoolShare = value;
      } else if(code == "RPSTH") { // Reward Pool percent for market creator
        rewardPoolShareThreshold = value;
      }
    }

    function updateAddressParameters(bytes8 code, address payable value) external onlyAuthorizedToGovern {

      if(code == "GASAGG") { // Incentive to be distributed to user for market creation
        clGasPriceAggregator = IChainLinkOracle(value);
      }
    }

    function getUintParameters(bytes8 code) external view returns(bytes8 codeVal, uint256 value) {

      codeVal = code;
      if(code == "MAXGAS") { // Maximum gas upto which is considered while calculating market creation incentives
        value = maxGasPrice;
      } else if(code == "MAXRPSP") { // Max Reward Pool percent for market creator
        value = maxRewardPoolPercForMC;
      } else if(code == "MINRPSP") { // Min Reward Pool percent for market creator
        value = minRewardPoolPercForMC;
      } else if(code == "PSFRPS") { // Reward Pool percent for market creator
        value = plotStakeForRewardPoolShare;
      } else if(code == "RPSTH") { // Reward Pool percent for market creator
        value = rewardPoolShareThreshold;
      }
    }

    function getAddressParameters(bytes8 code) external view returns(bytes8 codeVal, address value) {

      codeVal = code;
      if(code == "GASAGG") { // Incentive to be distributed to user for market creation
        value = address(clGasPriceAggregator);
      }
    }

    function _checkIfCreatorStaked(address _createdBy, uint64 _marketId) internal {

      uint256 tokensLocked = ITokenController(tokenController).tokensLockedAtTime(_createdBy, "SM", now);
      marketCreationRewardData[_marketId].createdBy = _createdBy;
      marketCreationRewardData[_marketId].rewardPoolSharePerc
       = uint16(Math.min(
          maxRewardPoolPercForMC,
          minRewardPoolPercForMC + tokensLocked.div(plotStakeForRewardPoolShare).mul(minRewardPoolPercForMC)
        ));
    }

    function calculateMarketCreationIncentive(address _createdBy, uint256 _gasCosumed, uint64 _marketId) external onlyInternal {

      _checkIfCreatorStaked(_createdBy, _marketId);
      marketCreationRewardUserData[_createdBy].marketsCreated.push(_marketId);
      uint256 gasUsedTotal;
      gasUsedTotal = _gasCosumed + 84000;
      uint256 gasPrice = _checkGasPrice();
      uint256 gasCost = gasUsedTotal.mul(gasPrice);
      (, uint256 incentive) = marketUtility.getValueAndMultiplierParameters(ETH_ADDRESS, gasCost);
      marketCreationRewardUserData[_createdBy].incentives = marketCreationRewardUserData[_createdBy].incentives.add(incentive);
      emit MarketCreationReward(_createdBy, _marketId, incentive, gasUsedTotal, gasCost, gasPrice, tx.gasprice, maxGasPrice, marketCreationRewardData[_marketId].rewardPoolSharePerc);
    }

    function _checkGasPrice() internal view returns(uint256) {

      uint fastGas = uint(clGasPriceAggregator.latestAnswer());
      uint fastGasWithMaxDeviation = fastGas.mul(125).div(100);
      return Math.min(Math.min(tx.gasprice,fastGasWithMaxDeviation), maxGasPrice);
    }

    function depositMarketRewardPoolShare(uint256 _marketId, uint256 _ethShare, uint256 _plotShare, uint64 _ethDeposited, uint64 _plotDeposited) external payable onlyInternal {

    	marketCreationRewardData[_marketId].ethIncentive = _ethShare;
    	marketCreationRewardData[_marketId].plotIncentive = _plotShare;
      marketCreationRewardData[_marketId].ethDeposited = _ethDeposited;
      marketCreationRewardData[_marketId].plotDeposited = _plotDeposited;
     	emit MarketCreatorRewardPoolShare(marketCreationRewardData[_marketId].createdBy, _marketId, _plotShare, _ethShare);
    }

    function returnMarketRewardPoolShare(uint256 _marketId) external onlyInternal{

      uint256 plotToTransfer = marketCreationRewardData[_marketId].plotIncentive.add(marketCreationRewardData[_marketId].plotDeposited.mul(10**predictionDecimalMultiplier));
      uint256 ethToTransfer = marketCreationRewardData[_marketId].ethIncentive.add(marketCreationRewardData[_marketId].ethDeposited.mul(10**predictionDecimalMultiplier));
      delete marketCreationRewardData[_marketId].ethIncentive;
      delete marketCreationRewardData[_marketId].plotIncentive;
      delete marketCreationRewardData[_marketId].ethDeposited;
      delete marketCreationRewardData[_marketId].plotDeposited;
      _transferAsset(ETH_ADDRESS, msg.sender, ethToTransfer);
      _transferAsset(plotToken, msg.sender, plotToTransfer);
    }

    function claimCreationReward(uint256 _maxRecords) external {

      uint256 pendingPLOTReward = marketCreationRewardUserData[msg.sender].incentives;
      delete marketCreationRewardUserData[msg.sender].incentives;
      (uint256 ethIncentive, uint256 plotIncentive) = _getRewardPoolIncentives(_maxRecords);
      pendingPLOTReward = pendingPLOTReward.add(plotIncentive);
      require(pendingPLOTReward > 0 || ethIncentive > 0, "No pending");
      _transferAsset(address(plotToken), msg.sender, pendingPLOTReward);
      _transferAsset(ETH_ADDRESS, msg.sender, ethIncentive);
      emit ClaimedMarketCreationReward(msg.sender, ethIncentive, pendingPLOTReward);
    }

    function transferAssets(address _asset, address payable _to, uint _amount) external onlyAuthorizedToGovern {

      _transferAsset(_asset, _to, _amount);
    }

    function _getRewardPoolIncentives(uint256 _maxRecords) internal returns(uint256 ethIncentive, uint256 plotIncentive) {

      MarketCreationRewardUserData storage rewardData = marketCreationRewardUserData[msg.sender];
      uint256 len = rewardData.marketsCreated.length;
      uint256 lastClaimed = len;
      uint256 count;
      uint128 i;
      for(i = rewardData.lastClaimedIndex;i < len && count < _maxRecords; i++) {
        MarketCreationRewardData storage marketData = marketCreationRewardData[rewardData.marketsCreated[i]];
        if(allMarkets.marketStatus(rewardData.marketsCreated[i]) == IAllMarkets.PredictionStatus.Settled) {
          ethIncentive = ethIncentive.add(marketData.ethIncentive);
          plotIncentive = plotIncentive.add(marketData.plotIncentive);
          delete marketData.ethIncentive;
          delete marketData.plotIncentive;
          count++;
        } else {
          if(lastClaimed == len) {
            lastClaimed = i;
          }
        }
      }
      if(lastClaimed == len) {
        lastClaimed = i;
      }
      rewardData.lastClaimedIndex = uint128(lastClaimed);
    }

    function getPendingMarketCreationRewards(address _user) external view returns(uint256 plotIncentive, uint256 pendingPLOTReward, uint256 pendingETHReward){

      plotIncentive = marketCreationRewardUserData[_user].incentives;
      (pendingETHReward, pendingPLOTReward) = _getPendingRewardPoolIncentives(_user);
    }

    function getMarketCreatorRPoolShareParams(uint256 _market, uint256 plotStaked, uint256 ethStaked) external view returns(uint16, bool) {

      return (marketCreationRewardData[_market].rewardPoolSharePerc, _checkIfThresholdReachedForRPS(_market, plotStaked, ethStaked));
    }

    function _checkIfThresholdReachedForRPS(uint256 _marketId, uint256 plotStaked, uint256 ethStaked) internal view returns(bool) {

      uint256 _plotStaked;
      _plotStaked = marketUtility.getAssetValueETH(plotToken, plotStaked.mul(1e10));
      return (_plotStaked.add(ethStaked.mul(1e10)) > rewardPoolShareThreshold);
    }

    function _getPendingRewardPoolIncentives(address _user) internal view returns(uint256 ethIncentive, uint256 plotIncentive) {

      MarketCreationRewardUserData memory rewardData = marketCreationRewardUserData[_user];
      uint256 len = rewardData.marketsCreated.length;
      for(uint256 i = rewardData.lastClaimedIndex;i < len; i++) {
        MarketCreationRewardData memory marketData = marketCreationRewardData[rewardData.marketsCreated[i]];
        if(marketData.ethIncentive > 0 || marketData.plotIncentive > 0) {
          if(allMarkets.marketStatus(rewardData.marketsCreated[i]) == IAllMarkets.PredictionStatus.Settled) {
            ethIncentive = ethIncentive.add(marketData.ethIncentive);
            plotIncentive = plotIncentive.add(marketData.plotIncentive);
          }
        }
      }
    }

    function _transferAsset(address _asset, address payable _recipient, uint256 _amount) internal {

      if(_amount > 0) { 
        if(_asset == ETH_ADDRESS) {
          _recipient.transfer(_amount);
        } else {
          require(IToken(_asset).transfer(_recipient, _amount));
        }
      }
    }

    function () external payable {
    }

}