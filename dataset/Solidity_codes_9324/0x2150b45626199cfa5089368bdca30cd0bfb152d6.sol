
pragma solidity ^0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}// MIT
pragma solidity 0.8.4;

interface IGovernable {

  event PendingGovernorSet(address pendingGovernor);
  event GovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;

  function acceptGovernor() external;


  function governor() external view returns (address _governor);

  function pendingGovernor() external view returns (address _pendingGovernor);


  function isGovernor(address _account) external view returns (bool _isGovernor);

}// MIT

pragma solidity 0.8.4;


abstract
contract Governable is IGovernable {

  address public override governor;
  address public override pendingGovernor;

  constructor(address _governor) {
    require(_governor != address(0), 'governable/governor-should-not-be-zero-address');
    governor = _governor;
  }

  function _setPendingGovernor(address _pendingGovernor) internal {

    require(_pendingGovernor != address(0), 'governable/pending-governor-should-not-be-zero-addres');
    pendingGovernor = _pendingGovernor;
    emit PendingGovernorSet(_pendingGovernor);
  }

  function _acceptGovernor() internal {

    governor = pendingGovernor;
    pendingGovernor = address(0);
    emit GovernorAccepted();
  }

  function isGovernor(address _account) public view override returns (bool _isGovernor) {

    return _account == governor;
  }

  modifier onlyGovernor {

    require(isGovernor(msg.sender), 'governable/only-governor');
    _;
  }

  modifier onlyPendingGovernor {

    require(msg.sender == pendingGovernor, 'governable/only-pending-governor');
    _;
  }
}// MIT

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
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.8.4;

interface ICollectableDust {

  event DustSent(address _to, address token, uint256 amount);

  function sendDust(address _to, address _token, uint256 _amount) external;

}// MIT

pragma solidity 0.8.4;



abstract
contract CollectableDust is ICollectableDust {

  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  EnumerableSet.AddressSet internal protocolTokens;

  constructor() {}

  function _addProtocolToken(address _token) internal {

    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    protocolTokens.add(_token);
  }

  function _removeProtocolToken(address _token) internal {

    require(protocolTokens.contains(_token), 'collectable-dust/token-not-part-of-the-protocol');
    protocolTokens.remove(_token);
  }

  function _sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) internal {

    require(_to != address(0), 'collectable-dust/cant-send-dust-to-zero-address');
    require(!protocolTokens.contains(_token), 'collectable-dust/token-is-part-of-the-protocol');
    if (_token == ETH_ADDRESS) {
      payable(_to).transfer(_amount);
    } else {
      IERC20(_token).safeTransfer(_to, _amount);
    }
    emit DustSent(_to, _token, _amount);
  }
}// MIT
pragma solidity 0.8.4;

interface IPausable {

  event Paused(bool _paused);

  function pause(bool _paused) external;

}// MIT

pragma solidity 0.8.4;


abstract
contract Pausable is IPausable {

  bool public paused;

  constructor() {}
  
  modifier notPaused() {

    require(!paused, 'paused');
    _;
  }

  function _pause(bool _paused) internal {

    require(paused != _paused, 'no-change');
    paused = _paused;
    emit Paused(_paused);
  }

}// MIT

pragma solidity 0.8.4;


abstract
contract UtilsReady is Governable, CollectableDust, Pausable {


  constructor() Governable(msg.sender) { }

  function setPendingGovernor(address _pendingGovernor) external override onlyGovernor {

    _setPendingGovernor(_pendingGovernor);
  }

  function acceptGovernor() external override onlyPendingGovernor {

    _acceptGovernor();
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override virtual onlyGovernor {

    _sendDust(_to, _token, _amount);
  }

  function pause(bool _paused) external override onlyGovernor {

    _pause(_paused);
  }

}// MIT
pragma solidity 0.8.4;

interface IMachinery {

    function mechanicsRegistry() external view returns (address _mechanicsRegistry);

    function isMechanic(address mechanic) external view returns (bool _isMechanic);


    function setMechanicsRegistry(address _mechanicsRegistry) external;


}// MIT
pragma solidity 0.8.4;

interface IMechanicsRegistry {

    event MechanicAdded(address _mechanic);
    event MechanicRemoved(address _mechanic);

    function addMechanic(address _mechanic) external;


    function removeMechanic(address _mechanic) external;


    function mechanics() external view returns (address[] memory _mechanicsList);


    function isMechanic(address mechanic) external view returns (bool _isMechanic);


}// MIT

pragma solidity 0.8.4;


abstract
contract Machinery is IMachinery {

  using EnumerableSet for EnumerableSet.AddressSet;

  IMechanicsRegistry internal MechanicsRegistry;

  constructor(address _mechanicsRegistry) {
    _setMechanicsRegistry(_mechanicsRegistry);
  }

  function _setMechanicsRegistry(address _mechanicsRegistry) internal {

    MechanicsRegistry = IMechanicsRegistry(_mechanicsRegistry);
  }

  function mechanicsRegistry() external view override returns (address _mechanicRegistry) {

    return address(MechanicsRegistry);
  }
  function isMechanic(address _mechanic) public view override returns (bool _isMechanic) {

    return MechanicsRegistry.isMechanic(_mechanic);
  }

}// MIT

pragma solidity 0.8.4;


abstract
contract MachineryReady is UtilsReady, Machinery {


  constructor(address _mechanicsRegistry) Machinery(_mechanicsRegistry) UtilsReady() {
  }

  function setMechanicsRegistry(address _mechanicsRegistry) external override onlyGovernor {

    _setMechanicsRegistry(_mechanicsRegistry);
  }

  modifier onlyGovernorOrMechanic() {

    require(isGovernor(msg.sender) || isMechanic(msg.sender), "Machinery::onlyGovernorOrMechanic:invalid-msg-sender");
    _;
  }

}// MIT
pragma solidity 0.8.4;

interface IKeep3rV1Helper {

    function quote(uint256 eth) external view returns (uint256);


    function getFastGas() external view returns (uint256);


    function bonds(address keeper) external view returns (uint256);


    function getQuoteLimit(uint256 gasUsed) external view returns (uint256);


    function getQuoteLimitFor(address origin, uint256 gasUsed) external view returns (uint256);

}// MIT
pragma solidity 0.8.4;

interface IKeep3rV1 is IERC20 {

    function name() external returns (string memory);

    function KPRH() external view returns (IKeep3rV1Helper);


    function isKeeper(address _keeper) external returns (bool);

    function isMinKeeper(address _keeper, uint256 _minBond, uint256 _earned, uint256 _age) external returns (bool);

    function isBondedKeeper(address _keeper, address _bond, uint256 _minBond, uint256 _earned, uint256 _age) external returns (bool);

    function addKPRCredit(address _job, uint256 _amount) external;

    function addJob(address _job) external;

    function removeJob(address _job) external;

    function addVotes(address voter, uint256 amount) external;

    function removeVotes(address voter, uint256 amount) external;

    function revoke(address keeper) external;


    function worked(address _keeper) external;

    function workReceipt(address _keeper, uint256 _amount) external;

    function receipt(address credit, address _keeper, uint256 _amount) external;

    function receiptETH(address _keeper, uint256 _amount) external;


    function addLiquidityToJob(address liquidity, address job, uint amount) external;

    function applyCreditToJob(address provider, address liquidity, address job) external;

    function unbondLiquidityFromJob(address liquidity, address job, uint amount) external;

    function removeLiquidityFromJob(address liquidity, address job) external;


    function jobs(address _job) external view returns (bool);

    function jobList(uint256 _index) external view returns (address _job);

    function credits(address _job, address _credit) external view returns (uint256 _amount);


    function liquidityAccepted(address _liquidity) external view returns (bool);


    function liquidityProvided(address _provider, address _liquidity, address _job) external view returns (uint256 _amount);

    function liquidityApplied(address _provider, address _liquidity, address _job) external view returns (uint256 _amount);

    function liquidityAmount(address _provider, address _liquidity, address _job) external view returns (uint256 _amount);

    
    function liquidityUnbonding(address _provider, address _liquidity, address _job) external view returns (uint256 _amount);

    function liquidityAmountsUnbonding(address _provider, address _liquidity, address _job) external view returns (uint256 _amount);


    function bond(address bonding, uint256 amount) external;

    function activate(address bonding) external;

    function unbond(address bonding, uint256 amount) external;

    function withdraw(address bonding) external;

}// MIT
pragma solidity 0.8.4;
interface IKeep3r {

    event Keep3rSet(address _keep3r);
    event Keep3rRequirementsSet(address _bond, uint256 _minBond, uint256 _earned, uint256 _age, bool _onlyEOA);
    
    function keep3r() external view returns (address _keep3r);

    function bond() external view returns (address _bond);

    function minBond() external view returns (uint256 _minBond);

    function earned() external view returns (uint256 _earned);

    function age() external view returns (uint256 _age);

    function onlyEOA() external view returns (bool _onlyEOA);


    function setKeep3r(address _keep3r) external;

    function setKeep3rRequirements(address _bond, uint256 _minBond, uint256 _earned, uint256 _age, bool _onlyEOA) external;

}// MIT

pragma solidity 0.8.4;


abstract
contract Keep3r is IKeep3r {


  IKeep3rV1 internal _Keep3r;
  address public override bond;
  uint256 public override minBond;
  uint256 public override earned;
  uint256 public override age;
  bool public override onlyEOA;

  constructor(address _keep3r) {
    _setKeep3r(_keep3r);
  }

  function _setKeep3r(address _keep3r) internal {

    _Keep3r = IKeep3rV1(_keep3r);
    emit Keep3rSet(_keep3r);
  }

  function _setKeep3rRequirements(address _bond, uint256 _minBond, uint256 _earned, uint256 _age, bool _onlyEOA) internal {

    bond = _bond;
    minBond = _minBond;
    earned = _earned;
    age = _age;
    onlyEOA = _onlyEOA;
    emit Keep3rRequirementsSet(_bond, _minBond, _earned, _age, _onlyEOA);
  }

  modifier onlyKeeper(address _keeper) {

    _isKeeper(_keeper);
    _;
  }

  function keep3r() external view override returns (address _keep3r) {

    return address(_Keep3r);
  }

  modifier paysKeeper(address _keeper) {

    _;
    _paysKeeper(_keeper);
  }

  function _isKeeper(address _keeper) internal {

    if (onlyEOA) require(_keeper == tx.origin, "keep3r::isKeeper:keeper-is-not-eoa");
    if (minBond == 0 && earned == 0 && age == 0) {
      require(_Keep3r.isKeeper(_keeper), "keep3r::isKeeper:keeper-is-not-registered");
    } else {
      if (bond == address(0)) {
        require(_Keep3r.isMinKeeper(_keeper, minBond, earned, age), "keep3r::isKeeper:keeper-not-min-requirements");
      } else {
        require(_Keep3r.isBondedKeeper(_keeper, bond, minBond, earned, age), "keep3r::isKeeper:keeper-not-custom-min-requirements");
      }
    }
  }

  function _getQuoteLimitFor(address _for, uint256 _initialGas) internal view returns (uint256 _credits) {

    return _Keep3r.KPRH().getQuoteLimitFor(_for, _initialGas - gasleft());
  }

  function _paysKeeper(address _keeper) internal {

    _Keep3r.worked(_keeper);
  }
  function _paysKeeperInTokens(address _keeper, uint256 _amount) internal {

    _Keep3r.receipt(address(_Keep3r), _keeper, _amount);
  }
  function _paysKeeperAmount(address _keeper, uint256 _amount) internal {

    _Keep3r.workReceipt(_keeper, _amount);
  }
  function _paysKeeperCredit(address _credit, address _keeper, uint256 _amount) internal {

    _Keep3r.receipt(_credit, _keeper, _amount);
  }
  function _paysKeeperEth(address _keeper, uint256 _amount) internal {

    _Keep3r.receiptETH(_keeper, _amount);
  }
}// MIT
pragma solidity >=0.6.8;

interface IV2Keeper {

    function jobs() external view returns (address[] memory);


    event JobAdded(address _job);
    event JobRemoved(address _job);

    function addJobs(address[] calldata _jobs) external;


    function addJob(address _job) external;


    function removeJob(address _job) external;


    function tend(address _strategy) external;


    function harvest(address _strategy) external;

}// MIT
pragma solidity 0.8.4;

interface IKeep3rJob {

    event SetRewardMultiplier(uint256 _rewardMultiplier);

    function rewardMultiplier() external view returns (uint256 _rewardMultiplier);


    function setRewardMultiplier(uint256 _rewardMultiplier) external;

}// MIT
pragma solidity >=0.6.8;

interface IV2Keep3rJob is IKeep3rJob {

    event Keep3rHelperSet(address keep3rHelper);
    event SlidingOracleSet(address slidingOracle);

    event StrategyAdded(address _strategy, uint256 _requiredAmount);
    event StrategyModified(address _strategy, uint256 _requiredAmount);
    event StrategyRemoved(address _strategy);

    event Worked(address _strategy, address _keeper, uint256 _credits);

    event ForceWorked(address _strategy);

    function fastGasOracle() external view returns (address _fastGasOracle);


    function strategies() external view returns (address[] memory);


    function workable(address _strategy) external view returns (bool);


    function setV2Keep3r(address _v2Keeper) external;


    function setYOracle(address _v2Keeper) external;


    function setFastGasOracle(address _fastGasOracle) external;


    function setWorkCooldown(uint256 _workCooldown) external;


    function addStrategies(
        address[] calldata _strategy,
        uint256[] calldata _requiredAmount,
        address[] calldata _costTokens,
        address[] calldata _costPairs
    ) external;


    function addStrategy(
        address _strategy,
        uint256 _requiredAmount,
        address _costToken,
        address _costPair
    ) external;


    function updateRequiredAmounts(address[] calldata _strategies, uint256[] calldata _requiredAmounts) external;


    function updateRequiredAmount(address _strategy, uint256 _requiredAmount) external;


    function updateCostTokenAndPair(
        address _strategy,
        address _costToken,
        address _costPair
    ) external;


    function removeStrategy(address _strategy) external;


    function work(address _strategy) external returns (uint256 _credits);


    function forceWork(address _strategy) external;

}// MIT
pragma solidity 0.8.4;

interface IBaseStrategy {

    function vault() external view returns (address _vault);


    function strategist() external view returns (address _strategist);


    function rewards() external view returns (address _rewards);


    function keeper() external view returns (address _keeper);


    function want() external view returns (address _want);


    function name() external view returns (string memory _name);


    function profitFactor() external view returns (uint256 _profitFactor);


    function maxReportDelay() external view returns (uint256 _maxReportDelay);


    function crv() external view returns (address _crv);


    function setStrategist(address _strategist) external;


    function setKeeper(address _keeper) external;


    function setRewards(address _rewards) external;


    function tendTrigger(uint256 callCost) external view returns (bool);


    function tend() external;


    function harvestTrigger(uint256 callCost) external view returns (bool);


    function harvest() external;


    function setBorrowCollateralizationRatio(uint256 _c) external;

}// MIT

pragma solidity 0.8.4;

interface IYOracle {

    function defaultOracle() external view returns (address _defaultOracle);


    function pairOracle(address _pair) external view returns (address _oracle);


    function setPairOracle(address _pair, address _oracle) external;


    function setDefaultOracle(address _oracle) external;


    function getAmountOut(
        address _pair,
        address _tokenIn,
        uint256 _amountIn,
        address _tokenOut
    ) external view returns (uint256 _amountOut);

}// MIT
pragma solidity 0.8.4;

interface IChainLinkFeed {

    function latestAnswer() external view returns (int256);

}// MIT

pragma solidity 0.8.4;




abstract contract V2Keep3rJob is MachineryReady, Keep3r, IV2Keep3rJob {
    using EnumerableSet for EnumerableSet.AddressSet;

    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public override fastGasOracle = 0x169E633A2D1E6c10dD91238Ba11c4A708dfEF37C;

    uint256 public constant PRECISION = 1_000;
    uint256 public constant MAX_REWARD_MULTIPLIER = 1 * PRECISION; // 1x max reward multiplier
    uint256 public override rewardMultiplier = 850;

    IV2Keeper public V2Keeper;

    address public yOracle;

    EnumerableSet.AddressSet internal _availableStrategies;

    mapping(address => uint256) public requiredAmount;
    mapping(address => uint256) public lastWorkAt;

    mapping(address => address) public costToken;
    mapping(address => address) public costPair;

    uint256 public workCooldown;

    constructor(
        address _mechanicsRegistry,
        address _yOracle,
        address _keep3r,
        address _bond,
        uint256 _minBond,
        uint256 _earned,
        uint256 _age,
        bool _onlyEOA,
        address _v2Keeper,
        uint256 _workCooldown
    ) MachineryReady(_mechanicsRegistry) Keep3r(_keep3r) {
        _setYOracle(_yOracle);
        _setKeep3rRequirements(_bond, _minBond, _earned, _age, _onlyEOA);
        V2Keeper = IV2Keeper(_v2Keeper);
        if (_workCooldown > 0) _setWorkCooldown(_workCooldown);
    }

    function setKeep3r(address _keep3r) external override onlyGovernor {
        _setKeep3r(_keep3r);
    }

    function setV2Keep3r(address _v2Keeper) external override onlyGovernor {
        V2Keeper = IV2Keeper(_v2Keeper);
    }

    function setYOracle(address _yOracle) external override onlyGovernor {
        _setYOracle(_yOracle);
    }

    function _setYOracle(address _yOracle) internal {
        yOracle = _yOracle;
    }

    function setFastGasOracle(address _fastGasOracle) external override onlyGovernor {
        require(_fastGasOracle != address(0), "V2Keep3rJob::set-fas-gas-oracle:not-zero-address");
        fastGasOracle = _fastGasOracle;
    }

    function setKeep3rRequirements(
        address _bond,
        uint256 _minBond,
        uint256 _earned,
        uint256 _age,
        bool _onlyEOA
    ) external override onlyGovernor {
        _setKeep3rRequirements(_bond, _minBond, _earned, _age, _onlyEOA);
    }

    function setRewardMultiplier(uint256 _rewardMultiplier) external override onlyGovernorOrMechanic {
        _setRewardMultiplier(_rewardMultiplier);
        emit SetRewardMultiplier(_rewardMultiplier);
    }

    function _setRewardMultiplier(uint256 _rewardMultiplier) internal {
        require(_rewardMultiplier <= MAX_REWARD_MULTIPLIER, "V2Keep3rJob::set-reward-multiplier:multiplier-exceeds-max");
        rewardMultiplier = _rewardMultiplier;
    }

    function setWorkCooldown(uint256 _workCooldown) external override onlyGovernorOrMechanic {
        _setWorkCooldown(_workCooldown);
    }

    function _setWorkCooldown(uint256 _workCooldown) internal {
        require(_workCooldown > 0, "V2Keep3rJob::set-work-cooldown:should-not-be-zero");
        workCooldown = _workCooldown;
    }

    function addStrategies(
        address[] calldata _strategies,
        uint256[] calldata _requiredAmounts,
        address[] calldata _costTokens,
        address[] calldata _costPairs
    ) external override onlyGovernorOrMechanic {
        require(_strategies.length == _requiredAmounts.length, "V2Keep3rJob::add-strategies:strategies-required-amounts-different-length");
        for (uint256 i; i < _strategies.length; i++) {
            _addStrategy(_strategies[i], _requiredAmounts[i], _costTokens[i], _costPairs[i]);
        }
    }

    function addStrategy(
        address _strategy,
        uint256 _requiredAmount,
        address _costToken,
        address _costPair
    ) external override onlyGovernorOrMechanic {
        _addStrategy(_strategy, _requiredAmount, _costToken, _costPair);
    }

    function _addStrategy(
        address _strategy,
        uint256 _requiredAmount,
        address _costToken,
        address _costPair
    ) internal {
        require(!_availableStrategies.contains(_strategy), "V2Keep3rJob::add-strategy:strategy-already-added");
        _setRequiredAmount(_strategy, _requiredAmount);
        _setCostTokenAndPair(_strategy, _costToken, _costPair);
        emit StrategyAdded(_strategy, _requiredAmount);
        _availableStrategies.add(_strategy);
    }

    function updateRequiredAmounts(address[] calldata _strategies, uint256[] calldata _requiredAmounts)
        external
        override
        onlyGovernorOrMechanic
    {
        require(_strategies.length == _requiredAmounts.length, "V2Keep3rJob::update-strategies:strategies-required-amounts-different-length");
        for (uint256 i; i < _strategies.length; i++) {
            _updateRequiredAmount(_strategies[i], _requiredAmounts[i]);
        }
    }

    function updateRequiredAmount(address _strategy, uint256 _requiredAmount) external override onlyGovernorOrMechanic {
        _updateRequiredAmount(_strategy, _requiredAmount);
    }

    function _updateRequiredAmount(address _strategy, uint256 _requiredAmount) internal {
        require(_availableStrategies.contains(_strategy), "V2Keep3rJob::update-required-amount:strategy-not-added");
        _setRequiredAmount(_strategy, _requiredAmount);
        emit StrategyModified(_strategy, _requiredAmount);
    }

    function updateCostTokenAndPair(
        address _strategy,
        address _costToken,
        address _costPair
    ) external override onlyGovernorOrMechanic {
        _updateCostTokenAndPair(_strategy, _costToken, _costPair);
    }

    function _updateCostTokenAndPair(
        address _strategy,
        address _costToken,
        address _costPair
    ) internal {
        require(_availableStrategies.contains(_strategy), "V2Keep3rJob::update-required-amount:strategy-not-added");
        _setCostTokenAndPair(_strategy, _costToken, _costPair);
    }

    function removeStrategy(address _strategy) external override onlyGovernorOrMechanic {
        require(_availableStrategies.contains(_strategy), "V2Keep3rJob::remove-strategy:strategy-not-added");
        delete requiredAmount[_strategy];
        _availableStrategies.remove(_strategy);
        emit StrategyRemoved(_strategy);
    }

    function _setRequiredAmount(address _strategy, uint256 _requiredAmount) internal {
        requiredAmount[_strategy] = _requiredAmount;
    }

    function _setCostTokenAndPair(
        address _strategy,
        address _costToken,
        address _costPair
    ) internal {
        costToken[_strategy] = _costToken;
        costPair[_strategy] = _costPair;
    }

    function strategies() public view override returns (address[] memory _strategies) {
        _strategies = new address[](_availableStrategies.length());
        for (uint256 i; i < _availableStrategies.length(); i++) {
            _strategies[i] = _availableStrategies.at(i);
        }
    }

    function _workable(address _strategy) internal view virtual returns (bool) {
        require(_availableStrategies.contains(_strategy), "V2Keep3rJob::workable:strategy-not-added");
        if (workCooldown == 0 || block.timestamp > lastWorkAt[_strategy] + workCooldown) return true;
        return false;
    }

    function _getCallCosts(address _strategy) internal view returns (uint256 _callCost) {
        if (requiredAmount[_strategy] == 0) return 0;
        uint256 _ethCost = requiredAmount[_strategy] * uint256(IChainLinkFeed(fastGasOracle).latestAnswer());
        if (costToken[_strategy] == address(0)) return _ethCost;
        return IYOracle(yOracle).getAmountOut(costPair[_strategy], WETH, _ethCost, costToken[_strategy]);
    }

    function _workInternal(address _strategy) internal returns (uint256 _credits) {
        uint256 _initialGas = gasleft();
        require(_workable(_strategy), "V2Keep3rJob::work:not-workable");

        _work(_strategy);

        _credits = _calculateCredits(_initialGas);

        emit Worked(_strategy, msg.sender, _credits);
    }

    function _calculateCredits(uint256 _initialGas) internal view returns (uint256 _credits) {
        return (_getQuoteLimitFor(msg.sender, _initialGas) * rewardMultiplier) / PRECISION;
    }

    function _forceWork(address _strategy) internal {
        _work(_strategy);
        emit ForceWorked(_strategy);
    }

    function _work(address _strategy) internal virtual {}
}// MIT

pragma solidity 0.8.4;

interface IOnlyStealthRelayer {

  event StealthRelayerSet(address _stealthRelayer);

  function stealthRelayer() external view returns (address _stealthRelayer);


  function setStealthRelayer(address _stealthRelayer) external;

}

abstract contract OnlyStealthRelayer is IOnlyStealthRelayer {
  address public override stealthRelayer;

  constructor(address _stealthRelayer) {
    _setStealthRelayer(_stealthRelayer);
  }

  modifier onlyStealthRelayer() {
    require(stealthRelayer == address(0) || msg.sender == stealthRelayer, 'OnlyStealthRelayer::not-relayer');
    _;
  }

  function _setStealthRelayer(address _stealthRelayer) internal {
    stealthRelayer = _stealthRelayer;
    emit StealthRelayerSet(_stealthRelayer);
  }
}// MIT
pragma solidity >=0.6.8;

interface IV2Keep3rStealthJob {

    function forceWorkUnsafe(address _strategy) external;

}// MIT

pragma solidity 0.8.4;

interface IStealthTx {

    event StealthVaultSet(address _stealthVault);
    event PenaltySet(uint256 _penalty);
    event MigratedStealthVault(address _migratedTo);

    function stealthVault() external view returns (address);


    function penalty() external view returns (uint256);


    function setStealthVault(address _stealthVault) external;


    function setPenalty(uint256 _penalty) external;

}// MIT
pragma solidity 0.8.4;

interface IStealthRelayer is IStealthTx {

    function caller() external view returns (address _caller);


    function forceBlockProtection() external view returns (bool _forceBlockProtection);


    function jobs() external view returns (address[] memory _jobsList);


    function setForceBlockProtection(bool _forceBlockProtection) external;


    function addJobs(address[] calldata _jobsList) external;


    function addJob(address _job) external;


    function removeJobs(address[] calldata _jobsList) external;


    function removeJob(address _job) external;


    function execute(
        address _address,
        bytes memory _callData,
        bytes32 _stealthHash,
        uint256 _blockNumber
    ) external payable returns (bytes memory _returnData);


    function executeAndPay(
        address _address,
        bytes memory _callData,
        bytes32 _stealthHash,
        uint256 _blockNumber,
        uint256 _payment
    ) external payable returns (bytes memory _returnData);


    function executeWithoutBlockProtection(
        address _address,
        bytes memory _callData,
        bytes32 _stealthHash
    ) external payable returns (bytes memory _returnData);


    function executeWithoutBlockProtectionAndPay(
        address _job,
        bytes memory _callData,
        bytes32 _stealthHash,
        uint256 _payment
    ) external payable returns (bytes memory _returnData);

}// MIT

pragma solidity 0.8.4;




abstract contract V2Keep3rStealthJob is V2Keep3rJob, OnlyStealthRelayer, IV2Keep3rStealthJob {
    constructor(
        address _mechanicsRegistry,
        address _stealthRelayer,
        address _yOracle,
        address _keep3r,
        address _bond,
        uint256 _minBond,
        uint256 _earned,
        uint256 _age,
        bool _onlyEOA,
        address _v2Keeper,
        uint256 _workCooldown
    )
        V2Keep3rJob(_mechanicsRegistry, _yOracle, _keep3r, _bond, _minBond, _earned, _age, _onlyEOA, _v2Keeper, _workCooldown)
        OnlyStealthRelayer(_stealthRelayer)
    {

    }

    function setStealthRelayer(address _stealthRelayer) external override onlyGovernor {
        _setStealthRelayer(_stealthRelayer);
    }

    function forceWork(address _strategy) external override onlyStealthRelayer {
        address _caller = IStealthRelayer(stealthRelayer).caller();
        require(isGovernor(_caller) || isMechanic(_caller), "V2Keep3rStealthJob::forceWork:invalid-stealth-caller");
        _forceWork(_strategy);
    }

    function forceWorkUnsafe(address _strategy) external override onlyGovernorOrMechanic {
        _forceWork(_strategy);
    }
}// MIT

pragma solidity 0.8.4;


contract HarvestV2Keep3rStealthJob is V2Keep3rStealthJob {

    constructor(
        address _mechanicsRegistry,
        address _stealthRelayer,
        address _yOracle,
        address _keep3r,
        address _bond,
        uint256 _minBond,
        uint256 _earned,
        uint256 _age,
        bool _onlyEOA,
        address _v2Keeper,
        uint256 _workCooldown
    )
        V2Keep3rStealthJob(
            _mechanicsRegistry,
            _stealthRelayer,
            _yOracle,
            _keep3r,
            _bond,
            _minBond,
            _earned,
            _age,
            _onlyEOA,
            _v2Keeper,
            _workCooldown
        )
    {

    }

    function workable(address _strategy) external view override returns (bool) {

        return _workable(_strategy);
    }

    function _workable(address _strategy) internal view override returns (bool) {

        if (!super._workable(_strategy)) return false;
        return IBaseStrategy(_strategy).harvestTrigger(_getCallCosts(_strategy));
    }

    function _work(address _strategy) internal override {

        lastWorkAt[_strategy] = block.timestamp;
        V2Keeper.harvest(_strategy);
    }

    function work(address _strategy) external override notPaused onlyStealthRelayer returns (uint256 _credits) {

        address _keeper = IStealthRelayer(stealthRelayer).caller();
        _isKeeper(_keeper);
        _credits = _workInternal(_strategy);
        _paysKeeperAmount(_keeper, _credits);
    }
}