

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


contract IGovernance { 


    event Proposal(
        address indexed proposalOwner,
        uint256 indexed proposalId,
        uint256 dateAdd,
        string proposalTitle,
        string proposalSD,
        string proposalDescHash
    );

    event Solution(
        uint256 indexed proposalId,
        address indexed solutionOwner,
        uint256 indexed solutionId,
        string solutionDescHash,
        uint256 dateAdd
    );

    event Vote(
        address indexed from,
        uint256 indexed proposalId,
        uint256 indexed voteId,
        uint256 dateAdd,
        uint256 solutionChosen
    );

    event RewardClaimed(
        address indexed member,
        uint gbtReward
    );

    event VoteCast (uint256 proposalId);

    event ProposalAccepted (uint256 proposalId);

    event CloseProposalOnTime (
        uint256 indexed proposalId,
        uint256 time
    );

    event ActionSuccess (
        uint256 proposalId
    );

    function createProposal(
        string calldata _proposalTitle,
        string calldata _proposalSD,
        string calldata _proposalDescHash,
        uint _categoryId
    ) 
        external;


    function categorizeProposal(
        uint _proposalId, 
        uint _categoryId,
        uint _incentives
    ) 
        external;


    function submitProposalWithSolution(
        uint _proposalId, 
        string calldata _solutionHash, 
        bytes calldata _action
    ) 
        external;


    function createProposalwithSolution(
        string calldata _proposalTitle, 
        string calldata _proposalSD, 
        string calldata _proposalDescHash,
        uint _categoryId, 
        string calldata _solutionHash, 
        bytes calldata _action
    ) 
        external;


    function submitVote(uint _proposalId, uint _solutionChosen) external;


    function closeProposal(uint _proposalId) external;


    function claimReward(address _memberAddress, uint _maxRecords) external returns(uint pendingDAppReward); 


    function proposal(uint _proposalId)
        external
        view
        returns(
            uint proposalId,
            uint category,
            uint status,
            uint finalVerdict,
            uint totalReward
        );


    function canCloseProposal(uint _proposalId) public view returns(uint closeValue);


    function allowedToCatgorize() public view returns(uint roleId);


    function getProposalLength() external view returns(uint);


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

contract IMarketCreationRewards {


    function calculateMarketCreationIncentive(address _createdBy, uint256 _gasCosumed, uint64 _marketId) external;    


    function depositMarketRewardPoolShare(uint256 _marketId, uint256 _ethShare, uint256 _plotShare, uint64 _ethDeposit, uint64 _plotDeposit) external payable;


    function returnMarketRewardPoolShare(uint256 _marketId) external;


    function getMarketCreatorRPoolShareParams(uint256 _market, uint256 plotStaked, uint256 ethStaked) external view returns(uint16, bool);


    function transferAssets(address _asset, address _to, uint _amount) external;


}



pragma solidity 0.5.7;








contract IMaster {

    mapping(address => bool) public whitelistedSponsor;
    function dAppToken() public view returns(address);

    function getLatestAddress(bytes2 _module) public view returns(address);

}


contract Governed {


    address public masterAddress; // Name of the dApp, needs to be set by contracts inheriting this contract

    modifier onlyAuthorizedToGovern() {

        IMaster ms = IMaster(masterAddress);
        require(ms.getLatestAddress("GV") == msg.sender);
        _;
    }

}

contract AllMarkets is Governed {

    using SafeMath32 for uint32;
    using SafeMath64 for uint64;
    using SafeMath128 for uint128;
    using SafeMath for uint;

    enum PredictionStatus {
      Live,
      InSettlement,
      Cooling,
      InDispute,
      Settled
    }

    event Deposited(address indexed user, uint256 plot, uint256 eth, uint256 timeStamp);
    event Withdrawn(address indexed user, uint256 plot, uint256 eth, uint256 timeStamp);
    event MarketTypes(uint256 indexed index, uint32 predictionTime, uint32 optionRangePerc, bool status);
    event MarketCurrencies(uint256 indexed index, address feedAddress, bytes32 currencyName, bool status);
    event MarketQuestion(uint256 indexed marketIndex, bytes32 currencyName, uint256 indexed predictionType, uint256 startTime, uint256 predictionTime, uint256 neutralMinValue, uint256 neutralMaxValue);
    event SponsoredIncentive(uint256 indexed marketIndex, address incentiveTokenAddress, address sponsoredBy, uint256 amount);
    event MarketResult(uint256 indexed marketIndex, uint256[] totalReward, uint256 winningOption, uint256 closeValue, uint256 roundId);
    event ReturnClaimed(address indexed user, uint256 plotReward, uint256 ethReward);
    event ClaimedIncentive(address indexed user, uint256[] marketsClaimed, address incentiveTokenAddress, uint256 incentive);
    event PlacePrediction(address indexed user,uint256 value, uint256 predictionPoints, address predictionAsset,uint256 prediction,uint256 indexed marketIndex, uint256 commissionPercent);
    event DisputeRaised(uint256 indexed marketIndex, address raisedBy, uint256 proposalId, uint256 proposedValue);
    event DisputeResolved(uint256 indexed marketIndex, bool status);

    struct PredictionData {
      uint64 predictionPoints;
      uint64 ethStaked;
      uint64 plotStaked;
    }
    
    struct UserMarketData {
      bool claimedReward;
      bool predictedWithBlot;
      bool multiplierApplied;
      bool incentiveClaimed;
      mapping(uint => PredictionData) predictionData;
    }

    struct UserData {
      uint128 totalEthStaked;
      uint128 totalPlotStaked;
      uint128 lastClaimedIndex;
      uint[] marketsParticipated;
      mapping(address => uint) currencyUnusedBalance;
      mapping(uint => UserMarketData) userMarketData;
    }

    struct CommissionPercent {
     uint64 ethCommission; 
     uint64 plotCommission; 
    }

    struct MarketBasicData {
      uint32 Mtype;
      uint32 currency;
      uint32 startTime;
      uint32 predictionTime;
      uint64 neutralMinValue;
      uint64 neutralMaxValue;
    }

    struct MarketDataExtended {
      uint32 WinningOption;
      uint32 settleTime;
      address incentiveToken;
      address incentiveSponsoredBy;
      address disputeRaisedBy;
      uint64 disputeStakeAmount;
      uint64 ethCommission;
      uint64 plotCommission;
      uint incentiveToDistribute;
      uint[] rewardToDistribute;
      PredictionStatus predictionStatus;
    }

    struct MarketTypeData {
      uint32 predictionTime;
      uint32 optionRangePerc;
      bool paused;
    }

    struct MarketCurrency {
      bytes32 currencyName;
      address marketFeed;
      uint8 decimals;
      uint8 roundOfToNearest;
    }

    struct MarketCreationData {
      uint32 initialStartTime;
      uint64 latestMarket;
      uint64 penultimateMarket;
      bool paused;
    }

    address internal ETH_ADDRESS;
    address internal plotToken;

    ITokenController internal tokenController;
    IMarketUtility internal marketUtility;
    IGovernance internal governance;
    IMarketCreationRewards internal marketCreationRewards;

    uint internal totalOptions;
    uint internal predictionDecimalMultiplier;
    uint internal defaultMaxRecords;

    bool internal marketCreationPaused;
    MarketCurrency[] internal marketCurrencies;
    MarketTypeData[] internal marketTypeArray;
    CommissionPercent internal commissionPercGlobal; //with 2 decimals
    mapping(bytes32 => uint) internal marketCurrency;

    mapping(uint64 => uint32) internal marketType;
    mapping(uint256 => mapping(uint256 => MarketCreationData)) internal marketCreationData;

    MarketBasicData[] internal marketBasicData;

    mapping(uint256 => MarketDataExtended) internal marketDataExtended;
    mapping(address => UserData) internal userData;

    mapping(uint =>mapping(uint=>PredictionData)) internal marketOptionsAvailable;
    mapping(uint256 => uint256) internal disputeProposalId;

    function addMarketCurrency(bytes32 _currencyName, address _marketFeed, uint8 decimals, uint8 roundOfToNearest, uint32 _marketStartTime) external onlyAuthorizedToGovern {

      require((marketCurrencies[marketCurrency[_currencyName]].currencyName != _currencyName));
      require(decimals != 0);
      require(roundOfToNearest != 0);
      require(_marketFeed != address(0));
      _addMarketCurrency(_currencyName, _marketFeed, decimals, roundOfToNearest, _marketStartTime);
    }

    function _addMarketCurrency(bytes32 _currencyName, address _marketFeed, uint8 decimals, uint8 roundOfToNearest, uint32 _marketStartTime) internal {

      uint32 index = uint32(marketCurrencies.length);
      marketCurrency[_currencyName] = index;
      marketCurrencies.push(MarketCurrency(_currencyName, _marketFeed, decimals, roundOfToNearest));
      emit MarketCurrencies(index, _marketFeed, _currencyName, true);      
      for(uint32 i = 0;i < marketTypeArray.length; i++) {
          marketCreationData[i][index].initialStartTime = _marketStartTime;
      }
    }

    function addMarketType(uint32 _predictionTime, uint32 _optionRangePerc, uint32 _marketStartTime) external onlyAuthorizedToGovern {

      require(marketTypeArray[marketType[_predictionTime]].predictionTime != _predictionTime);
      require(_predictionTime > 0);
      require(_optionRangePerc > 0);
      uint32 index = uint32(marketTypeArray.length);
      _addMarketType(_predictionTime, _optionRangePerc);
      for(uint32 i = 0;i < marketCurrencies.length; i++) {
          marketCreationData[index][i].initialStartTime = _marketStartTime;
      }
    }

    function _addMarketType(uint32 _predictionTime, uint32 _optionRangePerc) internal {

      uint32 index = uint32(marketTypeArray.length);
      marketType[_predictionTime] = index;
      marketTypeArray.push(MarketTypeData(_predictionTime, _optionRangePerc, false));
      emit MarketTypes(index, _predictionTime, _optionRangePerc, true);
    }

    function setMasterAddress() public {

      OwnedUpgradeabilityProxy proxy =  OwnedUpgradeabilityProxy(address(uint160(address(this))));
      require(msg.sender == proxy.proxyOwner());
      IMaster ms = IMaster(msg.sender);
      masterAddress = msg.sender;
      plotToken = ms.dAppToken();
      governance = IGovernance(ms.getLatestAddress("GV"));
      tokenController = ITokenController(ms.getLatestAddress("TC"));
    }

    function addInitialMarketTypesAndStart(address _marketCreationRewards,address _ethAddress, address _marketUtility, uint32 _marketStartTime, address _ethFeed, address _btcFeed) external {

      require(marketTypeArray.length == 0);
      
      marketCreationRewards = IMarketCreationRewards(_marketCreationRewards);
      
      totalOptions = 3;
      predictionDecimalMultiplier = 10;
      defaultMaxRecords = 20;
      marketUtility = IMarketUtility(_marketUtility);
      ETH_ADDRESS = _ethAddress;

      commissionPercGlobal.ethCommission = 10;
      commissionPercGlobal.plotCommission = 5;
      
      _addMarketType(4 hours, 100);
      _addMarketType(24 hours, 200);
      _addMarketType(168 hours, 500);

      _addMarketCurrency("ETH/USD", _ethFeed, 8, 1, _marketStartTime);
      _addMarketCurrency("BTC/USD", _btcFeed, 8, 25, _marketStartTime);

      marketBasicData.push(MarketBasicData(0,0,0, 0,0,0));
      for(uint32 i = 0;i < marketTypeArray.length; i++) {
          createMarket(0, i);
          createMarket(1, i);
      }
    }

    function createMarket(uint32 _marketCurrencyIndex,uint32 _marketTypeIndex) public payable {

      uint256 gasProvided = gasleft();
      require(!marketCreationPaused && !marketTypeArray[_marketTypeIndex].paused);
      _closePreviousMarket( _marketTypeIndex, _marketCurrencyIndex);
      marketUtility.update();
      uint32 _startTime = calculateStartTimeForMarket(_marketCurrencyIndex, _marketTypeIndex);
      (uint64 _minValue, uint64 _maxValue) = marketUtility.calculateOptionRange(marketTypeArray[_marketTypeIndex].optionRangePerc, marketCurrencies[_marketCurrencyIndex].decimals, marketCurrencies[_marketCurrencyIndex].roundOfToNearest, marketCurrencies[_marketCurrencyIndex].marketFeed);
      uint64 _marketIndex = uint64(marketBasicData.length);
      marketBasicData.push(MarketBasicData(_marketTypeIndex,_marketCurrencyIndex,_startTime, marketTypeArray[_marketTypeIndex].predictionTime,_minValue,_maxValue));
      marketDataExtended[_marketIndex].ethCommission = commissionPercGlobal.ethCommission;
      marketDataExtended[_marketIndex].plotCommission = commissionPercGlobal.plotCommission;
      (marketCreationData[_marketTypeIndex][_marketCurrencyIndex].penultimateMarket, marketCreationData[_marketTypeIndex][_marketCurrencyIndex].latestMarket) =
       (marketCreationData[_marketTypeIndex][_marketCurrencyIndex].latestMarket, _marketIndex);
      emit MarketQuestion(_marketIndex, marketCurrencies[_marketCurrencyIndex].currencyName, _marketTypeIndex, _startTime, marketTypeArray[_marketTypeIndex].predictionTime, _minValue, _maxValue);
      marketCreationRewards.calculateMarketCreationIncentive(msg.sender, gasProvided - gasleft(), _marketIndex);
    }

    function calculateStartTimeForMarket(uint32 _marketCurrencyIndex, uint32 _marketType) public view returns(uint32 _marketStartTime) {

      _marketStartTime = marketCreationData[_marketType][_marketCurrencyIndex].initialStartTime;
      uint predictionTime = marketTypeArray[_marketType].predictionTime;
      if(now > (predictionTime) + (_marketStartTime)) {
        uint noOfMarketsCycles = ((now) - (_marketStartTime)) / (predictionTime);
       _marketStartTime = uint32((noOfMarketsCycles * (predictionTime)) + (_marketStartTime));
      }
    }

    function _transferAsset(address _asset, address _recipient, uint256 _amount) internal {

      if(_amount > 0) { 
        if(_asset == ETH_ADDRESS) {
          (address(uint160(_recipient))).transfer(_amount);
        } else {
          require(IToken(_asset).transfer(_recipient, _amount));
        }
      }
    }

    function _closePreviousMarket(uint64 _marketTypeIndex, uint64 _marketCurrencyIndex) internal {

      uint64 currentMarket = marketCreationData[_marketTypeIndex][_marketCurrencyIndex].latestMarket;
      if(currentMarket != 0) {
        require(marketStatus(currentMarket) >= PredictionStatus.InSettlement);
        uint64 penultimateMarket = marketCreationData[_marketTypeIndex][_marketCurrencyIndex].penultimateMarket;
        if(penultimateMarket > 0 && now >= marketSettleTime(penultimateMarket)) {
          settleMarket(penultimateMarket);
        }
      }
    }

    function marketSettleTime(uint256 _marketId) public view returns(uint32) {

      if(marketDataExtended[_marketId].settleTime > 0) {
        return marketDataExtended[_marketId].settleTime;
      }
      return marketBasicData[_marketId].startTime + (marketBasicData[_marketId].predictionTime * 2);
    }

    function marketStatus(uint256 _marketId) public view returns(PredictionStatus){

      if(marketDataExtended[_marketId].predictionStatus == PredictionStatus.Live && now >= marketExpireTime(_marketId)) {
        return PredictionStatus.InSettlement;
      } else if(marketDataExtended[_marketId].predictionStatus == PredictionStatus.Settled && now <= marketCoolDownTime(_marketId)) {
        return PredictionStatus.Cooling;
      }
      return marketDataExtended[_marketId].predictionStatus;
    }

    function marketCoolDownTime(uint256 _marketId) public view returns(uint256) {

      return marketDataExtended[_marketId].settleTime + (marketBasicData[_marketId].predictionTime / 4);
    }

    function pauseMarketCreation() external onlyAuthorizedToGovern {

      require(!marketCreationPaused);
      marketCreationPaused = true;
    }

    function resumeMarketCreation() external onlyAuthorizedToGovern {

      require(marketCreationPaused);
      marketCreationPaused = false;
    }

    function toggleMarketCreationType(uint64 _marketTypeIndex, bool _flag) external onlyAuthorizedToGovern {

      require(marketTypeArray[_marketTypeIndex].paused != _flag);
      marketTypeArray[_marketTypeIndex].paused = _flag;
    }

    function deposit(uint _amount) payable public {

      require(_amount > 0 || msg.value > 0);
      address _plotToken = plotToken;
      if(msg.value > 0) {
        userData[msg.sender].currencyUnusedBalance[ETH_ADDRESS] = userData[msg.sender].currencyUnusedBalance[ETH_ADDRESS].add(msg.value);
      }
      if(_amount > 0) {
        IToken(_plotToken).transferFrom (msg.sender,address(this), _amount);
        userData[msg.sender].currencyUnusedBalance[_plotToken] = userData[msg.sender].currencyUnusedBalance[_plotToken].add(_amount);
      }
      emit Deposited(msg.sender, _amount, msg.value, now);
    }

    function withdrawMax(uint _maxRecords) public {

      (uint _plotLeft, uint _plotReward, uint _ethLeft, uint _ethReward) = getUserUnusedBalance(msg.sender);
      _plotLeft = _plotLeft.add(_plotReward);
      _ethLeft = _ethLeft.add(_ethReward);
      _withdraw(_plotLeft, _ethLeft, _maxRecords, _plotLeft, _ethLeft);
    }

    function withdraw(uint _plot, uint256 _eth, uint _maxRecords) public {

      (uint _plotLeft, uint _plotReward, uint _ethLeft, uint _ethReward) = getUserUnusedBalance(msg.sender);
      _plotLeft = _plotLeft.add(_plotReward);
      _ethLeft = _ethLeft.add(_ethReward);
      _withdraw(_plot, _eth, _maxRecords, _plotLeft, _ethLeft);
    }

    function _withdraw(uint _plot, uint256 _eth, uint _maxRecords, uint _plotLeft, uint _ethLeft) internal {

      withdrawReward(_maxRecords);
      address _plotToken = plotToken;
      userData[msg.sender].currencyUnusedBalance[_plotToken] = _plotLeft.sub(_plot);
      userData[msg.sender].currencyUnusedBalance[ETH_ADDRESS] = _ethLeft.sub(_eth);
      require(_plot > 0 || _eth > 0);
      _transferAsset(_plotToken, msg.sender, _plot);
      _transferAsset(ETH_ADDRESS, msg.sender, _eth);
      emit Withdrawn(msg.sender, _plot, _eth, now);
    }

    function marketExpireTime(uint _marketId) internal view returns(uint256) {

      return marketBasicData[_marketId].startTime + (marketBasicData[_marketId].predictionTime);
    }

    function sponsorIncentives(uint256 _marketId, address _token, uint256 _value) external {

      require(IMaster(masterAddress).whitelistedSponsor(msg.sender));
      require(marketStatus(_marketId) <= PredictionStatus.InSettlement);
      require(marketDataExtended[_marketId].incentiveToken == address(0));
      marketDataExtended[_marketId].incentiveToken = _token;
      marketDataExtended[_marketId].incentiveToDistribute = _value;
      marketDataExtended[_marketId].incentiveSponsoredBy = msg.sender;
      IToken(_token).transferFrom(msg.sender, address(this), _value);
      emit SponsoredIncentive(_marketId, _token, msg.sender, _value);
    }

    function depositAndPlacePrediction(uint _plotDeposit, uint _marketId, address _asset, uint64 _predictionStake, uint256 _prediction) external payable {

      if(_asset == plotToken) {
        require(msg.value == 0);
      }
      deposit(_plotDeposit);
      placePrediction(_marketId, _asset, _predictionStake, _prediction);
    }

    function placePrediction(uint _marketId, address _asset, uint64 _predictionStake, uint256 _prediction) public {

      require(!marketCreationPaused && _prediction <= totalOptions && _prediction >0);
      require(now >= marketBasicData[_marketId].startTime && now <= marketExpireTime(_marketId));
      uint64 _commissionStake;
      uint64 _commissionPercent;
      if(_asset == ETH_ADDRESS) {
        _commissionPercent = marketDataExtended[_marketId].ethCommission;
      } else {
        _commissionPercent = marketDataExtended[_marketId].plotCommission;
      }
      uint decimalMultiplier = 10**predictionDecimalMultiplier;
      if(_asset == ETH_ADDRESS || _asset == plotToken) {
        uint256 unusedBalance = userData[msg.sender].currencyUnusedBalance[_asset];
        unusedBalance = unusedBalance.div(decimalMultiplier);
        if(_predictionStake > unusedBalance)
        {
          withdrawReward(defaultMaxRecords);
          unusedBalance = userData[msg.sender].currencyUnusedBalance[_asset];
          unusedBalance = unusedBalance.div(decimalMultiplier);
        }
        require(_predictionStake <= unusedBalance);
        _commissionStake = _calculateAmulBdivC(_commissionPercent, _predictionStake, 10000);
        userData[msg.sender].currencyUnusedBalance[_asset] = (unusedBalance.sub(_predictionStake)).mul(decimalMultiplier);
      } else {
        require(_asset == tokenController.bLOTToken());
        require(!userData[msg.sender].userMarketData[_marketId].predictedWithBlot);
        userData[msg.sender].userMarketData[_marketId].predictedWithBlot = true;
        tokenController.swapBLOT(msg.sender, address(this), (decimalMultiplier).mul(_predictionStake));
        _asset = plotToken;
        _commissionStake = _calculateAmulBdivC(_commissionPercent, _predictionStake, 10000);
      }
      _commissionStake = _predictionStake.sub(_commissionStake);
      
      uint64 predictionPoints = _calculatePredictionPointsAndMultiplier(msg.sender, _marketId, _prediction, _asset, _commissionStake);
      require(predictionPoints > 0);

      _storePredictionData(_marketId, _prediction, _commissionStake, _asset, predictionPoints);
      emit PlacePrediction(msg.sender, _predictionStake, predictionPoints, _asset, _prediction, _marketId, _commissionPercent);
    }

    function _calculatePredictionPointsAndMultiplier(address _user, uint256 _marketId, uint256 _prediction, address _asset, uint64 _stake) internal returns(uint64 predictionPoints){

      bool isMultiplierApplied;
      (predictionPoints, isMultiplierApplied) = marketUtility.calculatePredictionPoints(_user, userData[_user].userMarketData[_marketId].multiplierApplied, _stake, _asset, getTotalPredictionPoints(_marketId), marketOptionsAvailable[_marketId][_prediction].predictionPoints);
      if(isMultiplierApplied) {
        userData[_user].userMarketData[_marketId].multiplierApplied = true; 
      }
    }

    function settleMarket(uint256 _marketId) public {

      if(marketStatus(_marketId) == PredictionStatus.InSettlement) {
        (uint256 _value, uint256 _roundId) = marketUtility.getSettlemetPrice(marketCurrencies[marketBasicData[_marketId].currency].marketFeed, marketSettleTime(_marketId));
        _postResult(_value, _roundId, _marketId);
      }
    }

    function _postResult(uint256 _value, uint256 _roundId, uint256 _marketId) internal {

      require(now >= marketSettleTime(_marketId));
      require(_value > 0);
      if(marketDataExtended[_marketId].predictionStatus != PredictionStatus.InDispute) {
        marketDataExtended[_marketId].settleTime = uint32(now);
      } else {
        delete marketDataExtended[_marketId].settleTime;
      }
      _setMarketStatus(_marketId, PredictionStatus.Settled);
      uint32 _winningOption; 
      if(_value < marketBasicData[_marketId].neutralMinValue) {
        _winningOption = 1;
      } else if(_value > marketBasicData[_marketId].neutralMaxValue) {
        _winningOption = 3;
      } else {
        _winningOption = 2;
      }
      marketDataExtended[_marketId].WinningOption = _winningOption;
      uint64[] memory marketCreatorIncentive = new uint64[](2);
      (uint64[] memory totalReward, uint64 tokenParticipation, uint64 ethParticipation, uint64 plotCommission, uint64 ethCommission) = _calculateRewardTally(_marketId, _winningOption);
      (uint64 _rewardPoolShare, bool _thresholdReached) = marketCreationRewards.getMarketCreatorRPoolShareParams(_marketId, tokenParticipation, ethParticipation);
      if(_thresholdReached) {
        if(
          marketOptionsAvailable[_marketId][_winningOption].predictionPoints == 0
        ){
          marketCreatorIncentive[0] = _calculateAmulBdivC(_rewardPoolShare, tokenParticipation, 10000);
          marketCreatorIncentive[1] = _calculateAmulBdivC(_rewardPoolShare, ethParticipation, 10000);
          tokenParticipation = tokenParticipation.sub(marketCreatorIncentive[0]);
          ethParticipation = ethParticipation.sub(marketCreatorIncentive[1]);
        } else {
          marketCreatorIncentive[0] = _calculateAmulBdivC(_rewardPoolShare, totalReward[0], 10000);
          marketCreatorIncentive[1] = _calculateAmulBdivC(_rewardPoolShare, totalReward[1], 10000);
          totalReward[0] = totalReward[0].sub(marketCreatorIncentive[0]);
          totalReward[1] = totalReward[1].sub(marketCreatorIncentive[1]);
          tokenParticipation = 0;
          ethParticipation = 0;
        }
      } else {
        if(
          marketOptionsAvailable[_marketId][_winningOption].predictionPoints > 0
        ){
          tokenParticipation = 0;
          ethParticipation = 0;
        }
      }
      marketDataExtended[_marketId].rewardToDistribute = totalReward;
      tokenParticipation = tokenParticipation.add(plotCommission); 
      ethParticipation = ethParticipation.add(ethCommission);
      _transferAsset(plotToken, address(marketCreationRewards), (10**predictionDecimalMultiplier).mul(marketCreatorIncentive[0].add(tokenParticipation)));
      marketCreationRewards.depositMarketRewardPoolShare.value((10**predictionDecimalMultiplier).mul(marketCreatorIncentive[1].add(ethParticipation)))(_marketId, (10**predictionDecimalMultiplier).mul(marketCreatorIncentive[1]), (10**predictionDecimalMultiplier).mul(marketCreatorIncentive[0]), ethParticipation, tokenParticipation);
      emit MarketResult(_marketId, marketDataExtended[_marketId].rewardToDistribute, _winningOption, _value, _roundId);
    }

    function _calculateRewardTally(uint256 _marketId, uint256 _winningOption) internal view returns(uint64[] memory totalReward, uint64 tokenParticipation, uint64 ethParticipation, uint64 plotCommission, uint64 ethCommission){

      totalReward = new uint64[](2);
      for(uint i=1;i <= totalOptions;i++){
        uint64 _plotStakedOnOption = marketOptionsAvailable[_marketId][i].plotStaked;
        uint64 _ethStakedOnOption = marketOptionsAvailable[_marketId][i].ethStaked;
        tokenParticipation = tokenParticipation.add(_plotStakedOnOption);
        ethParticipation = ethParticipation.add(_ethStakedOnOption);
        if(i != _winningOption) {
          totalReward[0] = totalReward[0].add(_plotStakedOnOption);
          totalReward[1] = totalReward[1].add(_ethStakedOnOption);
        }
      }

      plotCommission = _calculateAmulBdivC(10000, tokenParticipation, 10000 - marketDataExtended[_marketId].plotCommission) - tokenParticipation;
      ethCommission = _calculateAmulBdivC(10000, ethParticipation, 10000 - marketDataExtended[_marketId].ethCommission) - ethParticipation;
    }

    function withdrawReward(uint256 maxRecords) public {

      uint256 i;
      uint len = userData[msg.sender].marketsParticipated.length;
      uint lastClaimed = len;
      uint count;
      uint ethReward = 0;
      uint plotReward =0 ;
      require(!marketCreationPaused);
      for(i = userData[msg.sender].lastClaimedIndex; i < len && count < maxRecords; i++) {
        (uint claimed, uint tempPlotReward, uint tempEthReward) = claimReturn(msg.sender, userData[msg.sender].marketsParticipated[i]);
        if(claimed > 0) {
          delete userData[msg.sender].marketsParticipated[i];
          ethReward = ethReward.add(tempEthReward);
          plotReward = plotReward.add(tempPlotReward);
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
      emit ReturnClaimed(msg.sender, plotReward, ethReward);
      userData[msg.sender].currencyUnusedBalance[plotToken] = userData[msg.sender].currencyUnusedBalance[plotToken].add(plotReward.mul(10**predictionDecimalMultiplier));
      userData[msg.sender].currencyUnusedBalance[ETH_ADDRESS] = userData[msg.sender].currencyUnusedBalance[ETH_ADDRESS].add(ethReward.mul(10**predictionDecimalMultiplier));
      userData[msg.sender].lastClaimedIndex = uint128(lastClaimed);
    }

    function getUserUnusedBalance(address _user) public view returns(uint256, uint256, uint256, uint256){

      uint ethReward;
      uint plotReward;
      uint decimalMultiplier = 10**predictionDecimalMultiplier;
      uint len = userData[_user].marketsParticipated.length;
      uint[] memory _returnAmount = new uint256[](2);
      for(uint i = userData[_user].lastClaimedIndex; i < len; i++) {
        (_returnAmount, , ) = getReturn(_user, userData[_user].marketsParticipated[i]);
        ethReward = ethReward.add(_returnAmount[1]);
        plotReward = plotReward.add(_returnAmount[0]);
      }
      return (userData[_user].currencyUnusedBalance[plotToken], plotReward.mul(decimalMultiplier), userData[_user].currencyUnusedBalance[ETH_ADDRESS], ethReward.mul(decimalMultiplier));
    }

    function getUserPredictionPoints(address _user, uint256 _marketId, uint256 _option) external view returns(uint64) {

      return userData[_user].userMarketData[_marketId].predictionData[_option].predictionPoints;
    }

    function getMarketData(uint256 _marketId) external view returns
       (bytes32 _marketCurrency,uint neutralMinValue,uint neutralMaxValue,
        uint[] memory _optionPrice, uint[] memory _ethStaked, uint[] memory _plotStaked,uint _predictionTime,uint _expireTime, PredictionStatus _predictionStatus){

        _marketCurrency = marketCurrencies[marketBasicData[_marketId].currency].currencyName;
        _predictionTime = marketBasicData[_marketId].predictionTime;
        _expireTime =marketExpireTime(_marketId);
        _predictionStatus = marketStatus(_marketId);
        neutralMinValue = marketBasicData[_marketId].neutralMinValue;
        neutralMaxValue = marketBasicData[_marketId].neutralMaxValue;
        
        _optionPrice = new uint[](totalOptions);
        _ethStaked = new uint[](totalOptions);
        _plotStaked = new uint[](totalOptions);
        uint64 totalPredictionPoints = getTotalPredictionPoints(_marketId);
        for (uint i = 0; i < totalOptions; i++) {
          _ethStaked[i] = marketOptionsAvailable[_marketId][i+1].ethStaked;
          _plotStaked[i] = marketOptionsAvailable[_marketId][i+1].plotStaked;
          uint64 predictionPointsOnOption = marketOptionsAvailable[_marketId][i+1].predictionPoints;
          _optionPrice[i] = marketUtility.getOptionPrice(totalPredictionPoints, predictionPointsOnOption);
       }
    }

    function withdrawSponsoredIncentives(uint256 _marketId) external {

      require(marketStatus(_marketId) == PredictionStatus.Settled);
      require(getTotalPredictionPoints(_marketId) == 0);
      _transferAsset(marketDataExtended[_marketId].incentiveToken, marketDataExtended[_marketId].incentiveSponsoredBy, marketDataExtended[_marketId].incentiveToDistribute);
    }

    function claimReturn(address payable _user, uint _marketId) internal returns(uint256, uint256, uint256) {


      if(marketStatus(_marketId) != PredictionStatus.Settled) {
        return (0, 0 ,0);
      }
      if(userData[_user].userMarketData[_marketId].claimedReward) {
        return (1, 0, 0);
      }
      userData[_user].userMarketData[_marketId].claimedReward = true;
      uint[] memory _returnAmount = new uint256[](2);
      (_returnAmount, , ) = getReturn(_user, _marketId);
      return (2, _returnAmount[0], _returnAmount[1]);
    }

    function claimIncentives(address payable _user, uint64[] calldata _markets, address _incentiveToken) external {

      uint totalIncentive;
      uint _index;
      uint[] memory _marketsClaimed = new uint[](_markets.length);
      for(uint64 i = 0; i < _markets.length; i++) {
        ( , uint incentive, address incentiveToken) = getReturn(_user, _markets[i]);
        if(incentive > 0 && incentiveToken == _incentiveToken && !userData[_user].userMarketData[_markets[i]].incentiveClaimed) {
          userData[_user].userMarketData[_markets[i]].incentiveClaimed = true;
          totalIncentive = totalIncentive.add(incentive);
          _marketsClaimed[_index] = i;
          _index++;
        }

      }
      require(totalIncentive > 0);
      _transferAsset(_incentiveToken, _user, totalIncentive);
      emit ClaimedIncentive(_user, _marketsClaimed, _incentiveToken, totalIncentive);
    }

    function getReturn(address _user, uint _marketId) public view returns (uint[] memory returnAmount, uint incentive, address _incentiveToken){

      uint256 _totalUserPredictionPoints = 0;
      uint256 _totalPredictionPoints = 0;
      returnAmount = new uint256[](2);
      (_totalUserPredictionPoints, _totalPredictionPoints) = _calculatePredictionPoints(_user, _marketId);
      if(marketStatus(_marketId) != PredictionStatus.Settled || _totalPredictionPoints == 0) {
       return (returnAmount, incentive, marketDataExtended[_marketId].incentiveToken);
      }
      uint256 _winningOption = marketDataExtended[_marketId].WinningOption;
      returnAmount = new uint256[](2);
      returnAmount[0] = userData[_user].userMarketData[_marketId].predictionData[_winningOption].plotStaked;
      returnAmount[1] = userData[_user].userMarketData[_marketId].predictionData[_winningOption].ethStaked;
      uint256 userPredictionPointsOnWinngOption = userData[_user].userMarketData[_marketId].predictionData[_winningOption].predictionPoints;
      if(userPredictionPointsOnWinngOption > 0) {
        returnAmount = _addUserReward(_marketId, returnAmount, _winningOption, userPredictionPointsOnWinngOption);
      }
      if(marketDataExtended[_marketId].incentiveToDistribute > 0) {
        incentive = _totalUserPredictionPoints.mul((marketDataExtended[_marketId].incentiveToDistribute).div(_totalPredictionPoints));
      }
      return (returnAmount, incentive, marketDataExtended[_marketId].incentiveToken);
    }

    function _addUserReward(uint256 _marketId, uint[] memory returnAmount, uint256 _winningOption, uint256 _userPredictionPointsOnWinngOption) internal view returns(uint[] memory){

      for(uint j = 0; j< returnAmount.length; j++) {
        returnAmount[j] = returnAmount[j].add(
            _userPredictionPointsOnWinngOption.mul(marketDataExtended[_marketId].rewardToDistribute[j]).div(marketOptionsAvailable[_marketId][_winningOption].predictionPoints)
          );
      }
      return returnAmount;
    }

    function _calculatePredictionPoints(address _user, uint _marketId) internal view returns(uint _totalUserPredictionPoints, uint _totalPredictionPoints){

      for(uint  i=1;i<=totalOptions;i++){
        _totalUserPredictionPoints = _totalUserPredictionPoints.add(userData[_user].userMarketData[_marketId].predictionData[i].predictionPoints);
        _totalPredictionPoints = _totalPredictionPoints.add(marketOptionsAvailable[_marketId][i].predictionPoints);
      }
    }

    function _calculateAmulBdivC(uint64 _a, uint64 _b, uint64 _c) internal pure returns(uint64) {

      return _a.mul(_b).div(_c);
    }

    function getTotalAssetsStaked(uint _marketId) public view returns(uint256 ethStaked, uint256 plotStaked) {

      for(uint256 i = 1; i<= totalOptions;i++) {
        ethStaked = ethStaked.add(marketOptionsAvailable[_marketId][i].ethStaked);
        plotStaked = plotStaked.add(marketOptionsAvailable[_marketId][i].plotStaked);
      }
    }

    function getTotalPredictionPoints(uint _marketId) public view returns(uint64 predictionPoints) {

      for(uint256 i = 1; i<= totalOptions;i++) {
        predictionPoints = predictionPoints.add(marketOptionsAvailable[_marketId][i].predictionPoints);
      }
    }

    function _storePredictionData(uint _marketId, uint _prediction, uint64 _predictionStake, address _asset, uint64 predictionPoints) internal {

      if(!_hasUserParticipated(_marketId, msg.sender)) {
        userData[msg.sender].marketsParticipated.push(_marketId);
      }
      userData[msg.sender].userMarketData[_marketId].predictionData[_prediction].predictionPoints = userData[msg.sender].userMarketData[_marketId].predictionData[_prediction].predictionPoints.add(predictionPoints);
      marketOptionsAvailable[_marketId][_prediction].predictionPoints = marketOptionsAvailable[_marketId][_prediction].predictionPoints.add(predictionPoints);
      if(_asset == ETH_ADDRESS) {
        userData[msg.sender].userMarketData[_marketId].predictionData[_prediction].ethStaked = userData[msg.sender].userMarketData[_marketId].predictionData[_prediction].ethStaked.add(_predictionStake);
        marketOptionsAvailable[_marketId][_prediction].ethStaked = marketOptionsAvailable[_marketId][_prediction].ethStaked.add(_predictionStake);
        userData[msg.sender].totalEthStaked = userData[msg.sender].totalEthStaked.add(_predictionStake);
      } else {
        userData[msg.sender].userMarketData[_marketId].predictionData[_prediction].plotStaked = userData[msg.sender].userMarketData[_marketId].predictionData[_prediction].plotStaked.add(_predictionStake);
        marketOptionsAvailable[_marketId][_prediction].plotStaked = marketOptionsAvailable[_marketId][_prediction].plotStaked.add(_predictionStake);
        userData[msg.sender].totalPlotStaked = userData[msg.sender].totalPlotStaked.add(_predictionStake);
      }
    }

    function _hasUserParticipated(uint256 _marketId, address _user) internal view returns(bool _hasParticipated) {

      for(uint i = 1;i <= totalOptions; i++) {
        if(userData[_user].userMarketData[_marketId].predictionData[i].predictionPoints > 0) {
          _hasParticipated = true;
          break;
        }
      }
    }

    function raiseDispute(uint256 _marketId, uint256 _proposedValue, string memory proposalTitle, string memory description, string memory solutionHash) public {

      require(getTotalPredictionPoints(_marketId) > 0);
      require(marketStatus(_marketId) == PredictionStatus.Cooling);
      uint _stakeForDispute =  marketUtility.getDisputeResolutionParams();
      IToken(plotToken).transferFrom(msg.sender, address(this), _stakeForDispute);
      uint proposalId = governance.getProposalLength();
      marketDataExtended[_marketId].disputeRaisedBy = msg.sender;
      marketDataExtended[_marketId].disputeStakeAmount = uint64(_stakeForDispute.div(10**predictionDecimalMultiplier));
      disputeProposalId[proposalId] = _marketId;
      governance.createProposalwithSolution(proposalTitle, proposalTitle, description, 10, solutionHash, abi.encode(_marketId, _proposedValue));
      emit DisputeRaised(_marketId, msg.sender, proposalId, _proposedValue);
      _setMarketStatus(_marketId, PredictionStatus.InDispute);
    }

    function resolveDispute(uint256 _marketId, uint256 _result) external onlyAuthorizedToGovern {

      _resolveDispute(_marketId, true, _result);
      emit DisputeResolved(_marketId, true);
      _transferAsset(plotToken, marketDataExtended[_marketId].disputeRaisedBy, (10**predictionDecimalMultiplier).mul(marketDataExtended[_marketId].disputeStakeAmount));
    }

    function _resolveDispute(uint256 _marketId, bool accepted, uint256 finalResult) internal {

      require(marketStatus(_marketId) == PredictionStatus.InDispute);
      if(accepted) {
        marketCreationRewards.returnMarketRewardPoolShare(_marketId);
        _postResult(finalResult, 0, _marketId);
      }
      _setMarketStatus(_marketId, PredictionStatus.Settled);
    }

    function burnDisputedProposalTokens(uint _proposalId) external onlyAuthorizedToGovern {

      uint256 _marketId = disputeProposalId[_proposalId];
      _resolveDispute(_marketId, false, 0);
      emit DisputeResolved(_marketId, false);
      IToken(plotToken).burn((10**predictionDecimalMultiplier).mul(marketDataExtended[_marketId].disputeStakeAmount));
    }

    function updateUintParameters(bytes8 code, uint256 value) external onlyAuthorizedToGovern {

      if(code == "ETHC") { // Commission percent for ETH based predictions(Raised be two decimals)
        commissionPercGlobal.ethCommission = uint64(value);
      } else if(code == "TKNC") { // Commission percent for PLOT based predictions(Raised be two decimals)
        commissionPercGlobal.plotCommission = uint64(value);
      }
    }

    function getUserFlags(uint256 _marketId, address _user) external view returns(bool, bool) {

      return (
              userData[_user].userMarketData[_marketId].predictedWithBlot,
              userData[_user].userMarketData[_marketId].multiplierApplied
      );
    }

    function getMarketResults(uint256 _marketId) external view returns(uint256 _winningOption, uint256, uint256[] memory, uint256, uint256) {

      _winningOption = marketDataExtended[_marketId].WinningOption;
      return (_winningOption, marketOptionsAvailable[_marketId][_winningOption].predictionPoints, marketDataExtended[_marketId].rewardToDistribute, marketOptionsAvailable[_marketId][_winningOption].ethStaked, marketOptionsAvailable[_marketId][_winningOption].plotStaked);
    }

    function getTotalStakedValueInPLOT(uint256 _marketId) public view returns(uint256) {

      (uint256 ethStaked, uint256 plotStaked) = getTotalAssetsStaked(_marketId);
      (, ethStaked) = marketUtility.getValueAndMultiplierParameters(ETH_ADDRESS, ethStaked);
      return plotStaked.add(ethStaked);
    }

    function _setMarketStatus(uint256 _marketId, PredictionStatus _status) internal {

      marketDataExtended[_marketId].predictionStatus = _status;
    }

    function () external payable {
    }

}