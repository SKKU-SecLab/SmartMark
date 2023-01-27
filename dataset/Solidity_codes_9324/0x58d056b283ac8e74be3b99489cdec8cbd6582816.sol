
pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }
}// GPL-2.0
pragma solidity ^0.8.4;

enum Modules {
  Kernel, // 0
  UserPositions, // 1
  YieldManager, // 2
  IntegrationMap, // 3
  BiosRewards, // 4
  EtherRewards, // 5
  SushiSwapTrader, // 6
  UniswapTrader, // 7
  StrategyMap, // 8
  StrategyManager // 9
}

interface IModuleMap {

  function getModuleAddress(Modules key) external view returns (address);

}// GPL-2.0
pragma solidity ^0.8.4;


abstract contract ModuleMapConsumer is Initializable {
  IModuleMap public moduleMap;

  function __ModuleMapConsumer_init(address moduleMap_) internal initializer {
    moduleMap = IModuleMap(moduleMap_);
  }
}// GPL-2.0
pragma solidity ^0.8.4;

interface IKernel {

  function isManager(address account) external view returns (bool);


  function isOwner(address account) external view returns (bool);

}// GPL-2.0
pragma solidity ^0.8.4;


abstract contract Controlled is Initializable, ModuleMapConsumer {
  mapping(address => bool) internal _controllers;
  address[] public controllers;

  function __Controlled_init(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {
    for (uint256 i; i < controllers_.length; i++) {
      _controllers[controllers_[i]] = true;
    }
    controllers = controllers_;
    __ModuleMapConsumer_init(moduleMap_);
  }

  function addController(address controller) external onlyOwner {
    _controllers[controller] = true;
    bool added;
    for (uint256 i; i < controllers.length; i++) {
      if (controller == controllers[i]) {
        added = true;
      }
    }
    if (!added) {
      controllers.push(controller);
    }
  }

  modifier onlyOwner() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isOwner(msg.sender),
      "Controlled::onlyOwner: Caller is not owner"
    );
    _;
  }

  modifier onlyManager() {
    require(
      IKernel(moduleMap.getModuleAddress(Modules.Kernel)).isManager(msg.sender),
      "Controlled::onlyManager: Caller is not manager"
    );
    _;
  }

  modifier onlyController() {
    require(
      _controllers[msg.sender],
      "Controlled::onlyController: Caller is not controller"
    );
    _;
  }
}// GPL-2.0
pragma solidity ^0.8.4;

interface IIntegration {

  function deposit(address tokenAddress, uint256 amount) external;


  function withdraw(address tokenAddress, uint256 amount) external;


  function deploy() external;


  function harvestYield() external;


  function getBalance(address tokenAddress) external view returns (uint256);

}// GPL-2.0
pragma solidity ^0.8.4;

interface IStrategyMap {

  struct WeightedIntegration {
    address integration;
    uint256 weight;
  }

  struct Strategy {
    string name;
    uint256 totalStrategyWeight;
    mapping(address => bool) enabledTokens;
    address[] tokens;
    WeightedIntegration[] integrations;
  }

  struct StrategySummary {
    string name;
    uint256 totalStrategyWeight;
    address[] tokens;
    WeightedIntegration[] integrations;
  }

  struct StrategyTransaction {
    uint256 amount;
    address token;
  }

  event NewStrategy(
    uint256 indexed id,
    string name,
    WeightedIntegration[] integrations,
    address[] tokens
  );
  event UpdateName(uint256 indexed id, string name);
  event UpdateIntegrations(
    uint256 indexed id,
    WeightedIntegration[] integrations
  );
  event UpdateTokens(uint256 indexed id, address[] tokens);
  event DeleteStrategy(
    uint256 indexed id,
    string name,
    address[] tokens,
    WeightedIntegration[] integrations
  );

  event EnterStrategy(
    uint256 indexed id,
    address indexed user,
    address[] tokens,
    uint256[] amounts
  );
  event ExitStrategy(
    uint256 indexed id,
    address indexed user,
    address[] tokens,
    uint256[] amounts
  );

  function addStrategy(
    string calldata name,
    WeightedIntegration[] memory integrations,
    address[] calldata tokens
  ) external;


  function updateName(uint256 id, string calldata name) external;


  function updateTokens(uint256 id, address[] calldata tokens) external;


  function updateIntegrations(
    uint256 id,
    WeightedIntegration[] memory integrations
  ) external;


  function deleteStrategy(uint256 id) external;


  function enterStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external;


  function exitStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external;


  function getStrategy(uint256 id)
    external
    view
    returns (StrategySummary memory);


  function getExpectedBalance(address integration, address token)
    external
    view
    returns (uint256 balance);


  function getStrategyTokenBalance(uint256 id, address token)
    external
    view
    returns (uint256 amount);


  function getUserStrategyBalanceByToken(
    uint256 id,
    address token,
    address user
  ) external view returns (uint256 amount);


  function getUserInvestedAmountByToken(address token, address user)
    external
    view
    returns (uint256 amount);


  function getTokenTotalBalance(address token)
    external
    view
    returns (uint256 amount);


  function getIntegrationWeight(address integration)
    external
    view
    returns (uint256);


  function getIntegrationWeightSum() external view returns (uint256);


  function idCounter() external view returns(uint256);

}// GPL-2.0
pragma solidity ^0.8.4;

interface IIntegrationMap {

  struct Integration {
    bool added;
    string name;
  }

  struct Token {
    uint256 id;
    bool added;
    bool acceptingDeposits;
    bool acceptingWithdrawals;
    uint256 biosRewardWeight;
    uint256 reserveRatioNumerator;
  }

  function addIntegration(address contractAddress, string memory name) external;


  function addToken(
    address tokenAddress,
    bool acceptingDeposits,
    bool acceptingWithdrawals,
    uint256 biosRewardWeight,
    uint256 reserveRatioNumerator
  ) external;


  function enableTokenDeposits(address tokenAddress) external;


  function disableTokenDeposits(address tokenAddress) external;


  function enableTokenWithdrawals(address tokenAddress) external;


  function disableTokenWithdrawals(address tokenAddress) external;


  function updateTokenRewardWeight(address tokenAddress, uint256 rewardWeight)
    external;


  function updateTokenReserveRatioNumerator(
    address tokenAddress,
    uint256 reserveRatioNumerator
  ) external;


  function getIntegrationAddress(uint256 integrationId)
    external
    view
    returns (address);


  function getIntegrationName(address integrationAddress)
    external
    view
    returns (string memory);


  function getWethTokenAddress() external view returns (address);


  function getBiosTokenAddress() external view returns (address);


  function getTokenAddress(uint256 tokenId) external view returns (address);


  function getTokenId(address tokenAddress) external view returns (uint256);


  function getTokenBiosRewardWeight(address tokenAddress)
    external
    view
    returns (uint256);


  function getBiosRewardWeightSum()
    external
    view
    returns (uint256 rewardWeightSum);


  function getTokenAcceptingDeposits(address tokenAddress)
    external
    view
    returns (bool);


  function getTokenAcceptingWithdrawals(address tokenAddress)
    external
    view
    returns (bool);


  function getIsTokenAdded(address tokenAddress) external view returns (bool);


  function getIsIntegrationAdded(address tokenAddress)
    external
    view
    returns (bool);


  function getTokenAddressesLength() external view returns (uint256);


  function getIntegrationAddressesLength() external view returns (uint256);


  function getTokenReserveRatioNumerator(address tokenAddress)
    external
    view
    returns (uint256);


  function getReserveRatioDenominator() external view returns (uint32);

}// GPL-2.0
pragma solidity ^0.8.4;

interface IUserPositions {

  function setBiosRewardsDuration(uint32 biosRewardsDuration_) external;


  function seedBiosRewards(address sender, uint256 biosAmount) external;


  function increaseBiosRewards() external;


  function deposit(
    address depositor,
    address[] memory tokens,
    uint256[] memory amounts,
    uint256 ethAmount
  ) external;


  function withdraw(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts,
    bool withdrawWethAsEth
  ) external returns (uint256 ethWithdrawn);


  function withdrawAllAndClaim(
    address recipient,
    address[] memory tokens,
    bool withdrawWethAsEth
  )
    external
    returns (
      uint256[] memory tokenAmounts,
      uint256 ethWithdrawn,
      uint256 ethClaimed,
      uint256 biosClaimed
    );


  function claimEthRewards(address user) external returns (uint256 ethClaimed);


  function claimBiosRewards(address recipient)
    external
    returns (uint256 biosClaimed);


  function totalTokenBalance(address asset) external view returns (uint256);


  function userTokenBalance(address asset, address account)
    external
    view
    returns (uint256);


  function getBiosRewardsDuration() external view returns (uint32);


  function transferToStrategy(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;


  function transferFromStrategy(
    address recipient,
    address[] memory tokens,
    uint256[] memory amounts
  ) external;

}// GPL-2.0
pragma solidity ^0.8.4;

interface IYieldManager {

  function updateGasAccountTargetEthBalance(uint256 gasAccountTargetEthBalance_)
    external;


  function updateEthDistributionWeights(
    uint32 biosBuyBackEthWeight_,
    uint32 treasuryEthWeight_,
    uint32 protocolFeeEthWeight_,
    uint32 rewardsEthWeight_
  ) external;


  function updateGasAccount(address payable gasAccount_) external;


  function updateTreasuryAccount(address payable treasuryAccount_) external;


  function rebalance() external;


  function deploy() external;


  function harvestYield() external;


  function processYield() external;


  function distributeEth() external;


  function biosBuyBack() external;


  function getHarvestedTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);


  function getReserveTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);


  function getDesiredReserveTokenBalance(address tokenAddress)
    external
    view
    returns (uint256);


  function getEthWeightSum() external view returns (uint32 ethWeightSum);


  function getProcessedWethSum()
    external
    view
    returns (uint256 processedWethSum);


  function getProcessedWethByToken(address tokenAddress)
    external
    view
    returns (uint256);


  function getProcessedWethByTokenSum()
    external
    view
    returns (uint256 processedWethByTokenSum);


  function getTokenTotalIntegrationBalance(address tokenAddress)
    external
    view
    returns (uint256 tokenTotalIntegrationBalance);


  function getGasAccount() external view returns (address);


  function getTreasuryAccount() external view returns (address);


  function getLastEthRewardsAmount() external view returns (uint256);


  function getGasAccountTargetEthBalance() external view returns (uint256);


  function getEthDistributionWeights()
    external
    view
    returns (
      uint32,
      uint32,
      uint32,
      uint32
    );

}// GPL-2.0
pragma solidity ^0.8.4;


contract StrategyMap is
  Initializable,
  ModuleMapConsumer,
  Controlled,
  IStrategyMap
{

  mapping(uint256 => Strategy) internal strategies;

  mapping(uint256 => mapping(address => uint256)) internal strategyBalances;

  mapping(address => mapping(uint256 => mapping(address => uint256)))
    internal userStrategyBalances;

  mapping(address => mapping(address => uint256)) internal userInvestedBalances;

  mapping(address => uint256) internal totalBalances;

  mapping(address => mapping(address => uint256)) internal integrationBalances;

  mapping(address => uint256) internal integrationWeights;
  uint256 internal totalSystemWeight;

  uint256 public override idCounter;

  function initialize(address[] memory controllers_, address moduleMap_)
    public
    initializer
  {

    __Controlled_init(controllers_, moduleMap_);
  }

  function addStrategy(
    string calldata name,
    WeightedIntegration[] memory integrations,
    address[] calldata tokens
  ) external override onlyController {

    require(bytes(name).length > 0, "Must have a name");
    require(integrations.length > 0, "Must have >= 1 integration");
    require(tokens.length > 0, "Must have tokens");

    idCounter++;
    uint256 strategyID = idCounter;
    strategies[strategyID].name = name;
    

    for (uint256 i = 0; i < tokens.length; i++) {
      strategies[strategyID].enabledTokens[tokens[i]] = true;
      strategies[strategyID].tokens.push(tokens[i]);
    }

    uint256 totalStrategyWeight = 0;
    uint256 _systemWeight = totalSystemWeight;
    for (uint256 i = 0; i < integrations.length; i++) {
      if (integrations[i].weight > 0) {
        _systemWeight += integrations[i].weight;
        integrationWeights[integrations[i].integration] += integrations[i]
          .weight;
        strategies[strategyID].integrations.push(integrations[i]);
        totalStrategyWeight += integrations[i].weight;
      }
    }
    totalSystemWeight = _systemWeight;
    strategies[strategyID].totalStrategyWeight = totalStrategyWeight;

    emit NewStrategy(strategyID, name, integrations, tokens);
  }

  function updateName(uint256 id, string calldata name)
    external
    override
    onlyController
  {

    require(bytes(name).length > 0, "Must have a name");
    require(
      strategies[id].integrations.length > 0 &&
        bytes(strategies[id].name).length > 0,
      "Strategy must exist"
    );
    strategies[id].name = name;
    emit UpdateName(id, name);
  }

  function updateTokens(uint256 id, address[] calldata tokens)
    external
    override
    onlyController
  {

    address[] memory oldTokens = strategies[id].tokens;
    for (uint256 i; i < oldTokens.length; i++) {
      strategies[id].enabledTokens[oldTokens[i]] = false;
    }
    for (uint256 i; i < tokens.length; i++) {
      strategies[id].enabledTokens[tokens[i]] = true;
    }
    delete strategies[id].tokens;
    strategies[id].tokens = tokens;
    emit UpdateTokens(id, tokens);
  }

  function updateIntegrations(
    uint256 id,
    WeightedIntegration[] memory integrations
  ) external override onlyController {

    StrategySummary memory currentStrategy = _getStrategySummary(id);
    require(
      currentStrategy.integrations.length > 0 &&
        bytes(currentStrategy.name).length > 0,
      "Strategy must exist"
    );

    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    WeightedIntegration[] memory currentIntegrations = strategies[id]
      .integrations;

    uint256 tokenCount = integrationMap.getTokenAddressesLength();

    uint256 _systemWeight = totalSystemWeight;
    for (uint256 i = 0; i < currentIntegrations.length; i++) {
      _systemWeight -= currentIntegrations[i].weight;
      integrationWeights[
        currentIntegrations[i].integration
      ] -= currentIntegrations[i].weight;
    }
    delete strategies[id].integrations;

    uint256 newStrategyTotalWeight;
    for (uint256 i = 0; i < integrations.length; i++) {
      if (integrations[i].weight > 0) {
        newStrategyTotalWeight += integrations[i].weight;
        strategies[id].integrations.push(integrations[i]);
        _systemWeight += integrations[i].weight;
        integrationWeights[integrations[i].integration] += integrations[i]
          .weight;
      }
    }

    totalSystemWeight = _systemWeight;
    strategies[id].totalStrategyWeight = newStrategyTotalWeight;

    for (uint256 i = 0; i < tokenCount; i++) {
      address token = integrationMap.getTokenAddress(i);
      if (strategyBalances[id][token] > 0) {
        for (uint256 j = 0; j < currentIntegrations.length; j++) {

          integrationBalances[currentIntegrations[j].integration][
            token
          ] -= _calculateIntegrationAllocation(
            strategyBalances[id][token],
            currentIntegrations[j].weight,
            currentStrategy.totalStrategyWeight
          );
        }
        for (uint256 j = 0; j < integrations.length; j++) {
          if (integrations[j].weight > 0) {
            integrationBalances[integrations[j].integration][
              token
            ] += _calculateIntegrationAllocation(
              strategyBalances[id][token],
              integrations[j].weight,
              newStrategyTotalWeight
            );
          }
        }
      }
    }

    emit UpdateIntegrations(id, integrations);
  }

  function deleteStrategy(uint256 id) external override onlyController {

    StrategySummary memory currentStrategy = _getStrategySummary(id);
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );
    uint256 tokenCount = integrationMap.getTokenAddressesLength();

    for (uint256 i = 0; i < tokenCount; i++) {
      require(
        getStrategyTokenBalance(id, integrationMap.getTokenAddress(i)) == 0,
        "Strategy in use"
      );
    }
    uint256 _systemWeight = totalSystemWeight;
    for (uint256 i = 0; i < currentStrategy.integrations.length; i++) {
      _systemWeight -= currentStrategy.integrations[i].weight;
      integrationWeights[
        currentStrategy.integrations[i].integration
      ] -= currentStrategy.integrations[i].weight;
    }
    totalSystemWeight = _systemWeight;

    delete strategies[id];

    emit DeleteStrategy(
      id,
      currentStrategy.name,
      currentStrategy.tokens,
      currentStrategy.integrations
    );
  }

  function _deposit(
    uint256 id,
    address user,
    StrategyTransaction memory deposits
  ) internal {

    StrategySummary memory strategy = _getStrategySummary(id);
    require(strategy.integrations.length > 0, "Strategy doesn't exist");

    strategyBalances[id][deposits.token] += deposits.amount;
    userInvestedBalances[user][deposits.token] += deposits.amount;
    userStrategyBalances[user][id][deposits.token] += deposits.amount;
    totalBalances[deposits.token] += deposits.amount;

    for (uint256 j = 0; j < strategy.integrations.length; j++) {
      integrationBalances[strategy.integrations[j].integration][
        deposits.token
      ] += _calculateIntegrationAllocation(
        deposits.amount,
        strategy.integrations[j].weight,
        strategy.totalStrategyWeight
      );
    }
  }

  function _withdraw(
    uint256 id,
    address user,
    StrategyTransaction memory withdrawals
  ) internal {

    StrategySummary memory strategy = _getStrategySummary(id);
    require(strategy.integrations.length > 0, "Strategy doesn't exist");

    strategyBalances[id][withdrawals.token] -= withdrawals.amount;
    userInvestedBalances[user][withdrawals.token] -= withdrawals.amount;
    userStrategyBalances[user][id][withdrawals.token] -= withdrawals.amount;
    totalBalances[withdrawals.token] -= withdrawals.amount;

    for (uint256 j = 0; j < strategy.integrations.length; j++) {
      integrationBalances[strategy.integrations[j].integration][
        withdrawals.token
      ] -= _calculateIntegrationAllocation(
        withdrawals.amount,
        strategy.integrations[j].weight,
        strategy.totalStrategyWeight
      );
    }
  }

  function enterStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external override onlyController {

    require(amounts.length == tokens.length, "Length mismatch");
    require(strategies[id].integrations.length > 0, "Strategy must exist");
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );

    IUserPositions userPositions = IUserPositions(
      moduleMap.getModuleAddress(Modules.UserPositions)
    );
    for (uint256 i = 0; i < tokens.length; i++) {
      require(amounts[i] > 0, "Amount is 0");
      require(strategies[id].enabledTokens[tokens[i]], "Invalid token");
      require(
        integrationMap.getTokenAcceptingDeposits(tokens[i]),
        "Token unavailable"
      );

      require(
        userPositions.userTokenBalance(tokens[i], user) >= amounts[i],
        "User lacks funds"
      );
      _deposit(
        id,
        user,
        IStrategyMap.StrategyTransaction(amounts[i], tokens[i])
      );
    }

    emit EnterStrategy(id, user, tokens, amounts);
  }

  function exitStrategy(
    uint256 id,
    address user,
    address[] calldata tokens,
    uint256[] calldata amounts
  ) external override onlyController {

    require(amounts.length == tokens.length, "Length mismatch");
    IIntegrationMap integrationMap = IIntegrationMap(
      moduleMap.getModuleAddress(Modules.IntegrationMap)
    );

    for (uint256 i = 0; i < tokens.length; i++) {
      require(
        getUserInvestedAmountByToken(tokens[i], user) >= amounts[i],
        "Insufficient Funds"
      );

      require(
        integrationMap.getTokenAcceptingWithdrawals(tokens[i]),
        "Token unavailable"
      );
      require(amounts[i] > 0, "Amount is 0");

      _withdraw(
        id,
        user,
        IStrategyMap.StrategyTransaction(amounts[i], tokens[i])
      );
    }

    emit ExitStrategy(id, user, tokens, amounts);
  }

  function _calculateIntegrationAllocation(
    uint256 totalDepositedAmount,
    uint256 integrationWeight,
    uint256 strategyWeight
  ) internal pure returns (uint256 amount) {

    return (totalDepositedAmount * integrationWeight) / strategyWeight;
  }

  function _getStrategySummary(uint256 id)
    internal
    view
    returns (StrategySummary memory)
  {

    StrategySummary memory result;
    result.integrations = strategies[id].integrations;
    result.name = strategies[id].name;
    result.tokens = strategies[id].tokens;
    result.totalStrategyWeight = strategies[id].totalStrategyWeight;
    return result;
  }

  function getStrategyTokenBalance(uint256 id, address token)
    public
    view
    override
    returns (uint256 amount)
  {

    amount = strategyBalances[id][token];
  }

  function getUserStrategyBalanceByToken(
    uint256 id,
    address token,
    address user
  ) public view override returns (uint256 amount) {

    amount = userStrategyBalances[user][id][token];
  }

  function getUserInvestedAmountByToken(address token, address user)
    public
    view
    override
    returns (uint256 amount)
  {

    amount = userInvestedBalances[user][token];
  }

  function getTokenTotalBalance(address token)
    public
    view
    override
    returns (uint256 amount)
  {

    amount = totalBalances[token];
  }

  function getStrategy(uint256 id)
    external
    view
    override
    returns (StrategySummary memory)
  {

    return _getStrategySummary(id);
  }

  function getExpectedBalance(address integration, address token)
    external
    view
    override
    returns (uint256 balance)
  {

    return integrationBalances[integration][token];
  }

  function getIntegrationWeight(address integration)
    external
    view
    override
    returns (uint256)
  {

    return integrationWeights[integration];
  }

  function getIntegrationWeightSum() external view override returns (uint256) {

    return totalSystemWeight;
  }
}