

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

contract IMarket {


    enum PredictionStatus {
      Live,
      InSettlement,
      Cooling,
      InDispute,
      Settled
    }

    struct MarketData {
      uint64 startTime;
      uint64 predictionTime;
      uint64 neutralMinValue;
      uint64 neutralMaxValue;
    }

    struct MarketSettleData {
      uint64 WinningOption;
      uint64 settleTime;
    }

    MarketSettleData public marketSettleData;

    MarketData public marketData;

    function WinningOption() public view returns(uint256);


    function marketCurrency() public view returns(bytes32);


    function getMarketFeedData() public view returns(uint8, bytes32, address);


    function settleMarket() external;

    
    function getTotalStakedValueInPLOT() external view returns(uint256);


    function initiate(uint64 _startTime, uint64 _predictionTime, uint64 _minValue, uint64 _maxValue) public payable;


    function resolveDispute(bool accepted, uint256 finalResult) external payable;


    function getData() external view 
    	returns (
    		bytes32 _marketCurrency,uint[] memory minvalue,uint[] memory maxvalue,
        	uint[] memory _optionPrice, uint[] memory _ethStaked, uint[] memory _plotStaked,uint _predictionType,
        	uint _expireTime, uint _predictionStatus
        );



    function claimReturn(address payable _user) public returns(uint256);


}


pragma solidity 0.5.7;

contract Iupgradable {


    function setMasterAddress() public;

}


pragma solidity 0.5.7;
contract IMarketUtility {


    function initialize(address payable[] calldata _addressParams, address _initiater) external;


    function setAuthorizedAddres() public;


    function updateUintParameters(bytes8 code, uint256 value) external;


    function updateAddressParameters(bytes8 code, address payable value) external;

 
    function getMarketInitialParams() public view returns(address[] memory, uint , uint, uint, uint);


    function getAssetPriceUSD(address _currencyAddress) external view returns(uint latestAnswer);

    
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


    function getAssetValueETH(address _currencyAddress, uint256 _amount)
        public
        view
        returns (uint256 tokenEthValue);

}



pragma solidity 0.5.7;









contract MarketRegistry is Governed, Iupgradable {


    using SafeMath for *; 

    enum MarketType {
      HourlyMarket,
      DailyMarket,
      WeeklyMarket
    }

    struct MarketTypeData {
      uint64 predictionTime;
      uint64 optionRangePerc;
    }

    struct MarketCurrency {
      address marketImplementation;
      uint8 decimals;
    }

    struct MarketCreationData {
      uint64 initialStartTime;
      address marketAddress;
      address penultimateMarket;
    }

    struct DisputeStake {
      uint64 proposalId;
      address staker;
      uint256 stakeAmount;
      uint256 ethDeposited;
      uint256 tokenDeposited;
    }

    struct MarketData {
      bool isMarket;
      DisputeStake disputeStakes;
    }

    struct UserData {
      uint256 lastClaimedIndex;
      uint256 marketsCreated;
      uint256 totalEthStaked;
      uint256 totalPlotStaked;
      address[] marketsParticipated;
      mapping(address => bool) marketsParticipatedFlag;
    }

    uint internal marketCreationIncentive;
    
    mapping(address => MarketData) marketData;
    mapping(address => UserData) userData;
    mapping(uint256 => mapping(uint256 => MarketCreationData)) public marketCreationData;
    mapping(uint64 => address) disputeProposalId;

    address constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal marketInitiater;
    address public tokenController;

    MarketCurrency[] marketCurrencies;
    MarketTypeData[] marketTypes;

    bool public marketCreationPaused;

    IToken public plotToken;
    IMarketUtility public marketUtility;
    IGovernance internal governance;
    IMaster ms;


    event MarketQuestion(address indexed marketAdd, bytes32 stockName, uint256 indexed predictionType, uint256 startTime);
    event PlacePrediction(address indexed user,uint256 value, uint256 predictionPoints, address predictionAsset,uint256 prediction,address indexed marketAdd,uint256 _leverage);
    event MarketResult(address indexed marketAdd, uint256[] totalReward, uint256 winningOption, uint256 closeValue, uint256 roundId);
    event Claimed(address indexed marketAdd, address indexed user, uint256[] reward, address[] _predictionAssets, uint256 incentive, address incentiveToken);
    event MarketTypes(uint256 indexed index, uint64 predictionTime, uint64 optionRangePerc);
    event MarketCurrencies(uint256 indexed index, address marketImplementation,  address feedAddress, bytes32 currencyName);
    event DisputeRaised(address indexed marketAdd, address raisedBy, uint64 proposalId, uint256 proposedValue);
    event DisputeResolved(address indexed marketAdd, bool status);

    function isMarket(address _address) public view returns(bool) {

      return marketData[_address].isMarket;
    }

    function isWhitelistedSponsor(address _address) public view returns(bool) {

      return ms.whitelistedSponsor(_address);
    }

    function initiate(address _defaultAddress, address _marketUtility, address _plotToken, address payable[] memory _configParams) public {

      require(address(ms) == msg.sender);
      marketCreationIncentive = 50 ether;
      plotToken = IToken(_plotToken);
      address tcAddress = ms.getLatestAddress("TC");
      tokenController = tcAddress;
      marketUtility = IMarketUtility(_generateProxy(_marketUtility));
      marketUtility.initialize(_configParams, _defaultAddress);
      marketInitiater = _defaultAddress;
    }

    function addInitialMarketTypesAndStart(uint64 _marketStartTime, address _ethMarketImplementation, address _btcMarketImplementation) external {

      require(marketInitiater == msg.sender);
      require(marketTypes.length == 0);
      _addNewMarketCurrency(_ethMarketImplementation);
      _addNewMarketCurrency(_btcMarketImplementation);
      _addMarket(1 hours, 50);
      _addMarket(24 hours, 200);
      _addMarket(7 days, 500);

      for(uint256 i = 0;i < marketTypes.length; i++) {
          marketCreationData[i][0].initialStartTime = _marketStartTime;
          marketCreationData[i][1].initialStartTime = _marketStartTime;
          createMarket(i, 0);
          createMarket(i, 1);
      }
    }

    function addNewMarketType(uint64 _predictionTime, uint64 _marketStartTime, uint64 _optionRangePerc) external onlyAuthorizedToGovern {

      require(_marketStartTime > now);
      uint256 _marketType = marketTypes.length;
      _addMarket(_predictionTime, _optionRangePerc);
      for(uint256 j = 0;j < marketCurrencies.length; j++) {
        marketCreationData[_marketType][j].initialStartTime = _marketStartTime;
        createMarket(_marketType, j);
      }
    }

    function _addMarket(uint64 _predictionTime, uint64 _optionRangePerc) internal {

      uint256 _marketType = marketTypes.length;
      marketTypes.push(MarketTypeData(_predictionTime, _optionRangePerc));
      emit MarketTypes(_marketType, _predictionTime, _optionRangePerc);
    }

    function addNewMarketCurrency(address _marketImplementation, uint64 _marketStartTime) external onlyAuthorizedToGovern {

      uint256 _marketCurrencyIndex = marketCurrencies.length;
      _addNewMarketCurrency(_marketImplementation);
      for(uint256 j = 0;j < marketTypes.length; j++) {
        marketCreationData[j][_marketCurrencyIndex].initialStartTime = _marketStartTime;
        createMarket(j, _marketCurrencyIndex);
      }
    }

    function _addNewMarketCurrency(address _marketImplementation) internal {

      uint256 _marketCurrencyIndex = marketCurrencies.length;
      (, bytes32 _currencyName, address _priceFeed) = IMarket(_marketImplementation).getMarketFeedData();
      uint8 _decimals = marketUtility.getPriceFeedDecimals(_priceFeed);
      marketCurrencies.push(MarketCurrency(_marketImplementation, _decimals));
      emit MarketCurrencies(_marketCurrencyIndex, _marketImplementation, _priceFeed, _currencyName);
    }

    function updateMarketImplementations(uint256[] calldata _currencyIndexes, address[] calldata _marketImplementations) external onlyAuthorizedToGovern {

      require(_currencyIndexes.length == _marketImplementations.length);
      for(uint256 i = 0;i< _currencyIndexes.length; i++) {
        (, , address _priceFeed) = IMarket(_marketImplementations[i]).getMarketFeedData();
        uint8 _decimals = marketUtility.getPriceFeedDecimals(_priceFeed);
        marketCurrencies[_currencyIndexes[i]] = MarketCurrency(_marketImplementations[i], _decimals);
      }
    }

    function upgradeContractImplementation(address payable _proxyAddress, address _newImplementation) 
        external onlyAuthorizedToGovern
    {

      require(_newImplementation != address(0));
      OwnedUpgradeabilityProxy tempInstance 
          = OwnedUpgradeabilityProxy(_proxyAddress);
      tempInstance.upgradeTo(_newImplementation);
    }

    function setMasterAddress() public {

      OwnedUpgradeabilityProxy proxy =  OwnedUpgradeabilityProxy(address(uint160(address(this))));
      require(msg.sender == proxy.proxyOwner(),"Sender is not proxy owner.");
      ms = IMaster(msg.sender);
      masterAddress = msg.sender;
      governance = IGovernance(ms.getLatestAddress("GV"));
    }

    function _createMarket(uint256 _marketType, uint256 _marketCurrencyIndex, uint64 _minValue, uint64 _maxValue, uint64 _marketStartTime, bytes32 _currencyName) internal {

      require(!marketCreationPaused);
      MarketTypeData memory _marketTypeData = marketTypes[_marketType];
      address payable _market = _generateProxy(marketCurrencies[_marketCurrencyIndex].marketImplementation);
      marketData[_market].isMarket = true;
      IMarket(_market).initiate(_marketStartTime, _marketTypeData.predictionTime, _minValue, _maxValue);
      emit MarketQuestion(_market, _currencyName, _marketType, _marketStartTime);
      (marketCreationData[_marketType][_marketCurrencyIndex].penultimateMarket, marketCreationData[_marketType][_marketCurrencyIndex].marketAddress) =
       (marketCreationData[_marketType][_marketCurrencyIndex].marketAddress, _market);
    }

    function createMarket(uint256 _marketType, uint256 _marketCurrencyIndex) public payable{

      address penultimateMarket = marketCreationData[_marketType][_marketCurrencyIndex].penultimateMarket;
      if(penultimateMarket != address(0)) {
        IMarket(penultimateMarket).settleMarket();
      }
      if(marketCreationData[_marketType][_marketCurrencyIndex].marketAddress != address(0)) {
        (,,,,,,,, uint _status) = getMarketDetails(marketCreationData[_marketType][_marketCurrencyIndex].marketAddress);
        require(_status >= uint(IMarket.PredictionStatus.InSettlement));
      }
      (uint8 _roundOfToNearest, bytes32 _currencyName, address _priceFeed) = IMarket(marketCurrencies[_marketCurrencyIndex].marketImplementation).getMarketFeedData();
      marketUtility.update();
      uint64 _marketStartTime = calculateStartTimeForMarket(_marketType, _marketCurrencyIndex);
      uint64 _optionRangePerc = marketTypes[_marketType].optionRangePerc;
      uint currentPrice = marketUtility.getAssetPriceUSD(_priceFeed);
      _optionRangePerc = uint64(currentPrice.mul(_optionRangePerc.div(2)).div(10000));
      uint64 _decimals = marketCurrencies[_marketCurrencyIndex].decimals;
      uint64 _minValue = uint64((ceil(currentPrice.sub(_optionRangePerc).div(_roundOfToNearest), 10**_decimals)).mul(_roundOfToNearest));
      uint64 _maxValue = uint64((ceil(currentPrice.add(_optionRangePerc).div(_roundOfToNearest), 10**_decimals)).mul(_roundOfToNearest));
      _createMarket(_marketType, _marketCurrencyIndex, _minValue, _maxValue, _marketStartTime, _currencyName);
      userData[msg.sender].marketsCreated++;
    }

    function claimCreationReward() external {

      require(userData[msg.sender].marketsCreated > 0);
      uint256 pendingReward = marketCreationIncentive.mul(userData[msg.sender].marketsCreated);
      require(plotToken.balanceOf(address(this)) > pendingReward);
      delete userData[msg.sender].marketsCreated;
      _transferAsset(address(plotToken), msg.sender, pendingReward);
    }

    function calculateStartTimeForMarket(uint256 _marketType, uint256 _marketCurrencyIndex) public view returns(uint64 _marketStartTime) {

      address previousMarket = marketCreationData[_marketType][_marketCurrencyIndex].marketAddress;
      if(previousMarket != address(0)) {
        (_marketStartTime, , , ) = IMarket(previousMarket).marketData();
      } else {
        _marketStartTime = marketCreationData[_marketType][_marketCurrencyIndex].initialStartTime;
      }
      uint predictionTime = marketTypes[_marketType].predictionTime;
      if(now > _marketStartTime.add(predictionTime)) {
        uint noOfMarketsSkipped = ((now).sub(_marketStartTime)).div(predictionTime);
       _marketStartTime = uint64(_marketStartTime.add(noOfMarketsSkipped.mul(predictionTime)));
      }
    }

    function pauseMarketCreation() external onlyAuthorizedToGovern {

      require(!marketCreationPaused);
        marketCreationPaused = true;
    }

    function resumeMarketCreation() external onlyAuthorizedToGovern {

      require(marketCreationPaused);
        marketCreationPaused = false;
    }

    function createGovernanceProposal(string memory proposalTitle, string memory description, string memory solutionHash, bytes memory action, uint256 _stakeForDispute, address _user, uint256 _ethSentToPool, uint256 _tokenSentToPool, uint256 _proposedValue) public {

      require(isMarket(msg.sender));
      uint64 proposalId = uint64(governance.getProposalLength());
      marketData[msg.sender].disputeStakes = DisputeStake(proposalId, _user, _stakeForDispute, _ethSentToPool, _tokenSentToPool);
      disputeProposalId[proposalId] = msg.sender;
      governance.createProposalwithSolution(proposalTitle, proposalTitle, description, 10, solutionHash, action);
      emit DisputeRaised(msg.sender, _user, proposalId, _proposedValue);
    }

    function resolveDispute(address payable _marketAddress, uint256 _result) external onlyAuthorizedToGovern {

      uint256 ethDepositedInPool = marketData[_marketAddress].disputeStakes.ethDeposited;
      uint256 plotDepositedInPool = marketData[_marketAddress].disputeStakes.tokenDeposited;
      uint256 stakedAmount = marketData[_marketAddress].disputeStakes.stakeAmount;
      address payable staker = address(uint160(marketData[_marketAddress].disputeStakes.staker));
      address plotTokenAddress = address(plotToken);
      _transferAsset(plotTokenAddress, _marketAddress, plotDepositedInPool);
      IMarket(_marketAddress).resolveDispute.value(ethDepositedInPool)(true, _result);
      emit DisputeResolved(_marketAddress, true);
      _transferAsset(plotTokenAddress, staker, stakedAmount);
    }

    function burnDisputedProposalTokens(uint _proposalId) external onlyAuthorizedToGovern {

      address disputedMarket = disputeProposalId[uint64(_proposalId)];
      IMarket(disputedMarket).resolveDispute(false, 0);
      emit DisputeResolved(disputedMarket, false);
      uint _stakedAmount = marketData[disputedMarket].disputeStakes.stakeAmount;
      plotToken.burn(_stakedAmount);
    }

    function claimPendingReturn(uint256 maxRecords) external {

      uint256 i;
      uint len = userData[msg.sender].marketsParticipated.length;
      uint lastClaimed = len;
      uint count;
      for(i = userData[msg.sender].lastClaimedIndex; i < len && count < maxRecords; i++) {
        if(IMarket(userData[msg.sender].marketsParticipated[i]).claimReturn(msg.sender) > 0) {
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
      userData[msg.sender].lastClaimedIndex = lastClaimed;
    }

    function () external payable {
    }


    function transferAssets(address _asset, address payable _to, uint _amount) external onlyAuthorizedToGovern {

      _transferAsset(_asset, _to, _amount);
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

    function updateUintParameters(bytes8 code, uint256 value) external onlyAuthorizedToGovern {

      if(code == "MCRINC") { // Incentive to be distributed to user for market creation
        marketCreationIncentive = value;
      } else {
        marketUtility.updateUintParameters(code, value);
      }
    }

    function updateConfigAddressParameters(bytes8 code, address payable value) external onlyAuthorizedToGovern {

      marketUtility.updateAddressParameters(code, value);
    }

    function _generateProxy(address _contractAddress) internal returns(address payable) {

        OwnedUpgradeabilityProxy tempInstance = new OwnedUpgradeabilityProxy(_contractAddress);
        return address(tempInstance);
    }

    function callMarketResultEvent(uint256[] calldata _totalReward, uint256 winningOption, uint256 closeValue, uint _roundId) external {

      require(isMarket(msg.sender));
      emit MarketResult(msg.sender, _totalReward, winningOption, closeValue, _roundId);
    }
    
    function setUserGlobalPredictionData(address _user,uint256 _value, uint256 _predictionPoints, address _predictionAsset, uint256 _prediction, uint256 _leverage) external {

      require(isMarket(msg.sender));
      if(_predictionAsset == ETH_ADDRESS) {
        userData[_user].totalEthStaked = userData[_user].totalEthStaked.add(_value);
      } else {
        userData[_user].totalPlotStaked = userData[_user].totalPlotStaked.add(_value);
      }
      if(!userData[_user].marketsParticipatedFlag[msg.sender]) {
        userData[_user].marketsParticipated.push(msg.sender);
        userData[_user].marketsParticipatedFlag[msg.sender] = true;
      }
      emit PlacePrediction(_user, _value, _predictionPoints, _predictionAsset, _prediction, msg.sender,_leverage);
    }

    function callClaimedEvent(address _user ,uint[] calldata _reward, address[] calldata predictionAssets, uint incentives, address incentiveToken) external {

      require(isMarket(msg.sender));
      emit Claimed(msg.sender, _user, _reward, predictionAssets, incentives, incentiveToken);
    }

    function getUintParameters(bytes8 code) external view returns(bytes8 codeVal, uint256 value) {

      if(code == "MCRINC") {
        codeVal = code;
        value = marketCreationIncentive;
      }
    }

    function getMarketDetails(address _marketAdd)public view returns
    (bytes32 _feedsource,uint256[] memory minvalue,uint256[] memory maxvalue,
      uint256[] memory optionprice,uint256[] memory _ethStaked, uint256[] memory _plotStaked,uint256 _predictionType,uint256 _expireTime, uint256 _predictionStatus){

      return IMarket(_marketAdd).getData();
    }

    function getTotalAssetStakedByUser(address _user) external view returns(uint256 _plotStaked, uint256 _ethStaked) {

      return (userData[_user].totalPlotStaked, userData[_user].totalEthStaked);
    }

    function getMarketDetailsUser(address user, uint256 fromIndex, uint256 toIndex) external view returns
    (address[] memory _market, uint256[] memory _winnigOption){

      uint256 totalMarketParticipated = userData[user].marketsParticipated.length;
      if(totalMarketParticipated > 0 && fromIndex < totalMarketParticipated) {
        uint256 _toIndex = toIndex;
        if(_toIndex >= totalMarketParticipated) {
          _toIndex = totalMarketParticipated - 1;
        }
        _market = new address[](_toIndex.sub(fromIndex).add(1));
        _winnigOption = new uint256[](_toIndex.sub(fromIndex).add(1));
        for(uint256 i = fromIndex; i <= _toIndex; i++) {
          _market[i] = userData[user].marketsParticipated[i];
          (_winnigOption[i], ) = IMarket(_market[i]).marketSettleData();
        }
      }
    }

    function getOpenMarkets() external view returns(address[] memory _openMarkets, uint256[] memory _marketTypes, bytes32[] memory _marketCurrencies) {

      uint256  count = 0;
      uint256 marketTypeLength = marketTypes.length;
      uint256 marketCurrencyLength = marketCurrencies.length;
      _openMarkets = new address[]((marketTypeLength).mul(marketCurrencyLength));
      _marketTypes = new uint256[]((marketTypeLength).mul(marketCurrencyLength));
      _marketCurrencies = new bytes32[]((marketTypeLength).mul(marketCurrencyLength));
      for(uint256 i = 0; i< marketTypeLength; i++) {
        for(uint256 j = 0; j< marketCurrencyLength; j++) {
          _openMarkets[count] = marketCreationData[i][j].marketAddress;
          _marketTypes[count] = i;
          _marketCurrencies[count] = IMarket(marketCurrencies[j].marketImplementation).marketCurrency();
          count++;
        }
      }
    }

    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {

        return ((a + m - 1) / m) * m;
    }


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





contract MarketRegistryNew is MarketRegistry {


    uint256 internal maxGasPrice;
    IChainLinkOracle public clGasPriceAggregator;
    struct MarketCreationRewardUserData {
      uint incentives;
      uint lastClaimedIndex;
      address[] marketsCreated;
    }

    struct MarketCreationRewardData {
      uint ethIncentive;
      uint plotIncentive;
      uint rewardPoolSharePerc;
      address createdBy;
    }

    uint256 maxRewardPoolPercForMC;
    uint256 minRewardPoolPercForMC;
    uint256 plotStakeForRewardPoolShare;
    uint256 rewardPoolShareThreshold;

    mapping(address => MarketCreationRewardUserData) internal marketCreationRewardUserData; //Of user
    mapping(address => MarketCreationRewardData) internal marketCreationRewardData; //Of user
    mapping(uint256 => bool) internal marketCreationPausedOfType;
    event MarketCreatorRewardPoolShare(address indexed createdBy, address indexed marketAddress, uint256 plotIncentive, uint256 ethIncentive);
    event MarketCreationReward(address indexed createdBy, address marketAddress, uint256 plotIncentive, uint256 gasUsed, uint256 gasCost, uint256 gasPriceConsidered, uint256 gasPriceGiven, uint256 maxGasCap, uint256 rewardPoolSharePerc);
    event ClaimedMarketCreationReward(address indexed user, uint256 ethIncentive, uint256 plotIncentive);

    function setGasPriceAggAndMaxGas(address _clGasPriceAggregator) external {

      require(address(clGasPriceAggregator) == address(0));
      require(msg.sender == marketInitiater);
      clGasPriceAggregator = IChainLinkOracle(_clGasPriceAggregator);
      maxGasPrice = 100 * 10**9;
      maxRewardPoolPercForMC = 500; // Raised by 2 decimals
      minRewardPoolPercForMC = 50; // Raised by 2 decimals
      plotStakeForRewardPoolShare = 25000 ether;
      rewardPoolShareThreshold = 1 ether;
    }

    function createMarket(uint256 _marketType, uint256 _marketCurrencyIndex) public payable{

      require(!marketCreationPausedOfType[_marketType]);
      uint256 gasProvided = gasleft();
      address penultimateMarket = marketCreationData[_marketType][_marketCurrencyIndex].penultimateMarket;
      if(penultimateMarket != address(0)) {
        IMarket(penultimateMarket).settleMarket();
      }
      if(marketCreationData[_marketType][_marketCurrencyIndex].marketAddress != address(0)) {
        (,,,,,,,, uint _status) = getMarketDetails(marketCreationData[_marketType][_marketCurrencyIndex].marketAddress);
        require(_status >= uint(IMarket.PredictionStatus.InSettlement));
      }
      (uint8 _roundOfToNearest, bytes32 _currencyName, address _priceFeed) = IMarket(marketCurrencies[_marketCurrencyIndex].marketImplementation).getMarketFeedData();
      marketUtility.update();
      uint64 _marketStartTime = calculateStartTimeForMarket(_marketType, _marketCurrencyIndex);
      uint64 _optionRangePerc = marketTypes[_marketType].optionRangePerc;
      uint currentPrice = marketUtility.getAssetPriceUSD(_priceFeed);
      _optionRangePerc = uint64(currentPrice.mul(_optionRangePerc.div(2)).div(10000));
      uint64 _decimals = marketCurrencies[_marketCurrencyIndex].decimals;
      uint64 _minValue = uint64((ceil(currentPrice.sub(_optionRangePerc).div(_roundOfToNearest), 10**_decimals)).mul(_roundOfToNearest));
      uint64 _maxValue = uint64((ceil(currentPrice.add(_optionRangePerc).div(_roundOfToNearest), 10**_decimals)).mul(_roundOfToNearest));
      _createMarket(_marketType, _marketCurrencyIndex, _minValue, _maxValue, _marketStartTime, _currencyName);
      _checkIfCreatorStaked(marketCreationData[_marketType][_marketCurrencyIndex].marketAddress);
      marketCreationRewardUserData[msg.sender].marketsCreated.push(marketCreationData[_marketType][_marketCurrencyIndex].marketAddress);
      uint256 gasUsed = gasProvided - gasleft();
      _calculateIncentive(gasUsed, _marketType, _marketCurrencyIndex);
    }

    function _calculateIncentive(uint256 gasUsed, uint256 _marketType, uint256 _marketCurrencyIndex) internal{

      address _marketAddress = marketCreationData[_marketType][_marketCurrencyIndex].marketAddress;
      gasUsed = gasUsed + 38500;
      uint256 gasPrice = _checkGasPrice();
      uint256 gasCost = gasUsed.mul(gasPrice);
      (, uint256 incentive) = marketUtility.getValueAndMultiplierParameters(ETH_ADDRESS, gasCost);
      marketCreationRewardUserData[msg.sender].incentives = marketCreationRewardUserData[msg.sender].incentives.add(incentive);
      emit MarketCreationReward(msg.sender, _marketAddress, incentive, gasUsed, gasCost, gasPrice, tx.gasprice, maxGasPrice, marketCreationRewardData[_marketAddress].rewardPoolSharePerc);
    }

    function _checkIfCreatorStaked(address _market) internal {

      uint256 tokensLocked = ITokenController(tokenController).tokensLockedAtTime(msg.sender, "SM", now);
      marketCreationRewardData[_market].createdBy = msg.sender;
      marketCreationRewardData[_market].rewardPoolSharePerc
       = Math.min(
          maxRewardPoolPercForMC,
          minRewardPoolPercForMC + tokensLocked.div(plotStakeForRewardPoolShare).mul(minRewardPoolPercForMC)
        );
    }

    function toggleMarketCreationType(uint256 _marketType, bool _flag) external onlyAuthorizedToGovern {

      require(marketCreationPausedOfType[_marketType] != _flag);
      marketCreationPausedOfType[_marketType] = _flag;
    }

    function getMarketCreatorRPoolShareParams(address _market) external view returns(uint256, uint256) {

      return (marketCreationRewardData[_market].rewardPoolSharePerc, rewardPoolShareThreshold);
    }

    function _checkGasPrice() internal view returns(uint256) {

      uint fastGas = uint(clGasPriceAggregator.latestAnswer());
      uint fastGasWithMaxDeviation = fastGas.mul(125).div(100);
      return Math.min(Math.min(tx.gasprice,fastGasWithMaxDeviation), maxGasPrice);
    }

    function resolveDispute(address payable _marketAddress, uint256 _result) external onlyAuthorizedToGovern {

      uint256 ethDepositedInPool = marketData[_marketAddress].disputeStakes.ethDeposited;
      uint256 plotDepositedInPool = marketData[_marketAddress].disputeStakes.tokenDeposited;
      uint256 stakedAmount = marketData[_marketAddress].disputeStakes.stakeAmount;
      address payable staker = address(uint160(marketData[_marketAddress].disputeStakes.staker));
      address plotTokenAddress = address(plotToken);
      plotDepositedInPool = plotDepositedInPool.add(marketCreationRewardData[_marketAddress].plotIncentive);
      ethDepositedInPool = ethDepositedInPool.add(marketCreationRewardData[_marketAddress].ethIncentive);
      delete marketCreationRewardData[_marketAddress].plotIncentive;
      delete marketCreationRewardData[_marketAddress].ethIncentive;
      _transferAsset(plotTokenAddress, _marketAddress, plotDepositedInPool);
      IMarket(_marketAddress).resolveDispute.value(ethDepositedInPool)(true, _result);
      emit DisputeResolved(_marketAddress, true);
      _transferAsset(plotTokenAddress, staker, stakedAmount);
    }

    function claimCreationRewardV2(uint256 _maxRecords) external {

      uint256 pendingPLOTReward = marketCreationRewardUserData[msg.sender].incentives;
      delete marketCreationRewardUserData[msg.sender].incentives;
      (uint256 ethIncentive, uint256 plotIncentive) = _getRewardPoolIncentives(_maxRecords);
      pendingPLOTReward = pendingPLOTReward.add(plotIncentive);
      require(pendingPLOTReward > 0 || ethIncentive > 0, "No pending");
      _transferAsset(address(plotToken), msg.sender, pendingPLOTReward);
      _transferAsset(ETH_ADDRESS, msg.sender, ethIncentive);
      emit ClaimedMarketCreationReward(msg.sender, ethIncentive, pendingPLOTReward);
    }

    function _getRewardPoolIncentives(uint256 _maxRecords) internal returns(uint256 ethIncentive, uint256 plotIncentive) {

      MarketCreationRewardUserData storage rewardData = marketCreationRewardUserData[msg.sender];
      uint256 len = rewardData.marketsCreated.length;
      uint lastClaimed = len;
      uint256 count;
      uint256 i;
      for(i = rewardData.lastClaimedIndex;i < len && count < _maxRecords; i++) {
        MarketCreationRewardData storage marketData = marketCreationRewardData[rewardData.marketsCreated[i]];
        ( , , , , , , , , uint _predictionStatus) = IMarket(rewardData.marketsCreated[i]).getData();
        if(_predictionStatus == uint(IMarket.PredictionStatus.Settled)) {
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
      rewardData.lastClaimedIndex = lastClaimed;
    }

    function getPendingMarketCreationRewards(address _user) external view returns(uint256 plotIncentive, uint256 pendingPLOTReward, uint256 pendingETHReward){

      plotIncentive = marketCreationRewardUserData[_user].incentives;
      (pendingETHReward, pendingPLOTReward) = _getPendingRewardPoolIncentives(_user);
    }

    function _getPendingRewardPoolIncentives(address _user) internal view returns(uint256 ethIncentive, uint256 plotIncentive) {

      MarketCreationRewardUserData memory rewardData = marketCreationRewardUserData[_user];
      uint256 len = rewardData.marketsCreated.length;
      for(uint256 i = rewardData.lastClaimedIndex;i < len; i++) {
        MarketCreationRewardData memory marketData = marketCreationRewardData[rewardData.marketsCreated[i]];
        if(marketData.ethIncentive > 0 || marketData.plotIncentive > 0) {
          ( , , , , , , , , uint _predictionStatus) = IMarket(rewardData.marketsCreated[i]).getData();
          if(_predictionStatus == uint(IMarket.PredictionStatus.Settled)) {
            ethIncentive = ethIncentive.add(marketData.ethIncentive);
            plotIncentive = plotIncentive.add(marketData.plotIncentive);
          }
        }
      }
    }

    function callMarketResultEventAndSetIncentives(uint256[] calldata _totalReward, uint256[] calldata marketCreatorIncentive, uint256 winningOption, uint256 closeValue, uint _roundId) external {

      require(isMarket(msg.sender));
      marketCreationRewardData[msg.sender].plotIncentive = marketCreatorIncentive[0];
      marketCreationRewardData[msg.sender].ethIncentive = marketCreatorIncentive[1];
      emit MarketCreatorRewardPoolShare(marketCreationRewardData[msg.sender].createdBy, msg.sender, marketCreatorIncentive[0], marketCreatorIncentive[1]);
      emit MarketResult(msg.sender, _totalReward, winningOption, closeValue, _roundId);
    }
    

    function updateConfigAddressParameters(bytes8 code, address payable value) external onlyAuthorizedToGovern {

      if(code == "GASAGG") { // Incentive to be distributed to user for market creation
        clGasPriceAggregator = IChainLinkOracle(value);
      } else {
        marketUtility.updateAddressParameters(code, value);
      }
    }

    function updateUintParameters(bytes8 code, uint256 value) external onlyAuthorizedToGovern {

      if(code == "MCRINC") { // Incentive to be distributed to user for market creation
        marketCreationIncentive = value;
      } else if(code == "MAXGAS") { // Maximum gas upto which is considered while calculating market creation incentives
        maxGasPrice = value;
      } else if(code == "MAXRPSP") { // Max Reward Pool percent for market creator
        maxRewardPoolPercForMC = value;
      } else if(code == "MINRPSP") { // Min Reward Pool percent for market creator
        minRewardPoolPercForMC = value;
      } else if(code == "PSFRPS") { // Reward Pool percent for market creator
        plotStakeForRewardPoolShare = value;
      } else if(code == "RPSTH") { // Reward Pool percent for market creator
        rewardPoolShareThreshold = value;
      } else {
        marketUtility.updateUintParameters(code, value);
      }
    }

    function getUintParameters(bytes8 code) external view returns(bytes8 codeVal, uint256 value) {

      codeVal = code;
      if(code == "MCRINC") {
        value = marketCreationIncentive;
      } else if(code == "MAXGAS") {
        value = maxGasPrice;
      } else if(code == "MAXRPSP") {
        value = maxRewardPoolPercForMC;
      } else if(code == "MINRPSP") {
        value = minRewardPoolPercForMC;
      } else if(code == "PSFRPS") {
        value = plotStakeForRewardPoolShare;
      } else if(code == "RPSTH") {
        value = rewardPoolShareThreshold;
      }
    }

    function addInitialMarketTypesAndStart(uint64 _marketStartTime, address _ethMarketImplementation, address _btcMarketImplementation) external {

      revert("Deprecated");
    }
}