
pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
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

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}// MIT
pragma solidity 0.6.12;

interface IGovernable {

  event PendingGovernorSet(address pendingGovernor);
  event GovernorAccepted();

  function setPendingGovernor(address _pendingGovernor) external;

  function acceptGovernor() external;


  function governor() external view returns (address _governor);

  function pendingGovernor() external view returns (address _pendingGovernor);


  function isGovernor(address _account) external view returns (bool _isGovernor);

}// MIT

pragma solidity 0.6.12;


abstract
contract Governable is IGovernable {

  address public override governor;
  address public override pendingGovernor;

  constructor(address _governor) public {
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

pragma solidity >=0.6.2 <0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

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

        require(set._values.length > index, "EnumerableSet: index out of bounds");
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

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT
pragma solidity 0.6.12;

interface ICollectableDust {

  event DustSent(address _to, address token, uint256 amount);

  function sendDust(address _to, address _token, uint256 _amount) external;

}// MIT

pragma solidity 0.6.12;



abstract
contract CollectableDust is ICollectableDust {

  using SafeERC20 for IERC20;
  using EnumerableSet for EnumerableSet.AddressSet;

  address public constant ETH_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
  EnumerableSet.AddressSet internal protocolTokens;

  constructor() public {}

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
pragma solidity 0.6.12;

interface IPausable {

  event Paused(bool _paused);

  function pause(bool _paused) external;

}// MIT

pragma solidity 0.6.12;


abstract
contract Pausable is IPausable {

  bool public paused;

  constructor() public {}
  
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

pragma solidity 0.6.12;


abstract
contract UtilsReady is Governable, CollectableDust, Pausable {


  constructor() public Governable(msg.sender) {
  }

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
pragma solidity 0.6.12;

interface IMachinery {

    function mechanicsRegistry() external view returns (address _mechanicsRegistry);

    function isMechanic(address mechanic) external view returns (bool _isMechanic);


    function setMechanicsRegistry(address _mechanicsRegistry) external;


}// MIT
pragma solidity 0.6.12;

interface IMechanicsRegistry {

    event MechanicAdded(address _mechanic);
    event MechanicRemoved(address _mechanic);

    function addMechanic(address _mechanic) external;


    function removeMechanic(address _mechanic) external;


    function mechanics() external view returns (address[] memory _mechanicsList);


    function isMechanic(address mechanic) external view returns (bool _isMechanic);


}// MIT

pragma solidity 0.6.12;


abstract
contract Machinery is IMachinery {

  using EnumerableSet for EnumerableSet.AddressSet;

  IMechanicsRegistry internal MechanicsRegistry;

  constructor(address _mechanicsRegistry) public {
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

pragma solidity 0.6.12;


abstract
contract MachineryReady is UtilsReady, Machinery {


  constructor(address _mechanicsRegistry) public Machinery(_mechanicsRegistry) UtilsReady() {
  }

  function setMechanicsRegistry(address _mechanicsRegistry) external override onlyGovernor {

    _setMechanicsRegistry(_mechanicsRegistry);
  }

  modifier onlyGovernorOrMechanic() {

    require(isGovernor(msg.sender) || isMechanic(msg.sender), "Machinery::onlyGovernorOrMechanic:invalid-msg-sender");
    _;
  }

}// MIT
pragma solidity 0.6.12;

interface IKeep3rV1Helper {

    function quote(uint256 eth) external view returns (uint256);


    function getFastGas() external view returns (uint256);


    function bonds(address keeper) external view returns (uint256);


    function getQuoteLimit(uint256 gasUsed) external view returns (uint256);


    function getQuoteLimitFor(address origin, uint256 gasUsed) external view returns (uint256);

}// MIT
pragma solidity 0.6.12;

interface IKeep3rV1 is IERC20 {

    function name() external returns (string memory);

    function KPRH() external view returns (IKeep3rV1Helper);


    function isKeeper(address _keeper) external returns (bool);

    function isMinKeeper(address _keeper, uint256 _minBond, uint256 _earned, uint256 _age) external returns (bool);

    function isBondedKeeper(address _keeper, address bond, uint256 _minBond, uint256 _earned, uint256 _age) external returns (bool);

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
pragma solidity 0.6.12;
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

pragma solidity 0.6.12;



abstract
contract Keep3r is IKeep3r {

  using SafeMath for uint256;

  IKeep3rV1 internal _Keep3r;
  address public override bond;
  uint256 public override minBond;
  uint256 public override earned;
  uint256 public override age;
  bool public override onlyEOA;

  constructor(address _keep3r) public {
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

  modifier onlyKeeper() {

    _isKeeper();
    _;
  }

  function keep3r() external view override returns (address _keep3r) {

    return address(_Keep3r);
  }

  modifier paysKeeper() {

    _;
    _paysKeeper(msg.sender);
  }

  function _isKeeper() internal {

    if (onlyEOA) require(msg.sender == tx.origin, "keep3r::isKeeper:keeper-is-not-eoa");
    if (minBond == 0 && earned == 0 && age == 0) {
      require(_Keep3r.isKeeper(msg.sender), "keep3r::isKeeper:keeper-is-not-registered");
    } else {
      if (bond == address(0)) {
        require(_Keep3r.isMinKeeper(msg.sender, minBond, earned, age), "keep3r::isKeeper:keeper-not-min-requirements");
      } else {
        require(_Keep3r.isBondedKeeper(msg.sender, bond, minBond, earned, age), "keep3r::isKeeper:keeper-not-custom-min-requirements");
      }
    }
  }

  function _getQuoteLimitFor(address _for, uint256 _initialGas) internal view returns (uint256 _credits) {

    return _Keep3r.KPRH().getQuoteLimitFor(_for, _initialGas.sub(gasleft()));
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
pragma solidity 0.6.12;

interface IKeep3rJob {

    event SetRewardMultiplier(uint256 _rewardMultiplier);

    function rewardMultiplier() external view returns (uint256 _rewardMultiplier);


    function setRewardMultiplier(uint256 _rewardMultiplier) external;

}// MIT
pragma solidity 0.6.12;


interface ICrvStrategyKeep3rJob is IKeep3rJob {

    event StrategyAdded(address _strategy, uint256 _requiredHarvest, uint256 _requiredEarn);
    event StrategyModified(address _strategy, uint256 _requiredHarvest, uint256 _requiredEarn);
    event StrategyRemoved(address _strategy);

    event Worked(address _strategy, address _keeper, uint256 _credits, bool _workForTokens);

    event ForceWorked(address _strategy);

    function addStrategies(
        address[] calldata _strategies,
        uint256[] calldata _requiredHarvests,
        uint256[] calldata _requiredEarns
    ) external;


    function addStrategy(
        address _strategy,
        uint256 _requiredHarvest,
        uint256 _requiredEarn
    ) external;


    function updateStrategies(
        address[] calldata _strategies,
        uint256[] calldata _requiredHarvests,
        uint256[] calldata _requiredEarns
    ) external;


    function updateStrategy(
        address _strategy,
        uint256 _requiredHarvest,
        uint256 _requiredEarn
    ) external;


    function removeStrategy(address _strategy) external;


    function setMaxHarvestPeriod(uint256 _maxHarvestPeriod) external;


    function setHarvestCooldown(uint256 _harvestCooldown) external;


    function strategies() external view returns (address[] memory _strategies);


    function workable(address _strategy) external returns (bool);


    function requiredHarvest(address _strategy) external view returns (uint256 _requiredHarvest);


    function requiredEarn(address _strategy) external view returns (uint256 _requiredEarn);


    function lastWorkAt(address _strategy) external view returns (uint256 _lastWorkAt);


    function maxHarvestPeriod() external view returns (uint256 _maxHarvestPeriod);


    function lastHarvest() external view returns (uint256 _lastHarvest);


    function harvestCooldown() external view returns (uint256 _harvestCooldown);


    function calculateHarvest(address _strategy) external returns (uint256 _amount);


    function work(address _strategy) external returns (uint256 _credits);


    function workForBond(address _strategy) external returns (uint256 _credits);


    function workForTokens(address _strategy) external returns (uint256 _credits);


    function forceWork(address _strategy) external;

}// MIT
pragma solidity 0.6.12;

interface ICrvStrategyKeep3rJobV2 {

    function v2Keeper() external view returns (address _v2Keeper);


    function strategyIsV1(address _strategy) external view returns (bool);


    function setV2Keep3r(address _v2Keeper) external;

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
pragma solidity 0.6.12;

interface IUtilsReady is IGovernable, ICollectableDust, IPausable {

}// MIT
pragma solidity 0.6.12;


interface IKeep3rEscrow is IUtilsReady {

    function returnLPsToGovernance() external;


    function addLiquidityToJob(
        address liquidity,
        address job,
        uint256 amount
    ) external;


    function applyCreditToJob(
        address provider,
        address liquidity,
        address job
    ) external;


    function unbondLiquidityFromJob(
        address liquidity,
        address job,
        uint256 amount
    ) external;


    function removeLiquidityFromJob(address liquidity, address job) external;

}// MIT
pragma solidity 0.6.12;

interface IV1Controller {

    function stretegies(address _want) external view returns (address _strategy);


    function vaults(address _want) external view returns (address _vault);

}// MIT
pragma solidity 0.6.12;

interface IV1Vault {

    function token() external view returns (address);


    function underlying() external view returns (address);


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);


    function controller() external view returns (address);


    function governance() external view returns (address);


    function getPricePerFullShare() external view returns (uint256);


    function available() external view returns (uint256);


    function earn() external;

}// MIT
pragma solidity 0.6.12;

interface IBaseStrategy {

    function vault() external view returns (address _vault);


    function strategist() external view returns (address _strategist);


    function rewards() external view returns (address _rewards);


    function keeper() external view returns (address _keeper);


    function want() external view returns (address _want);


    function name() external view returns (string memory _name);


    function setStrategist(address _strategist) external;


    function setKeeper(address _keeper) external;


    function setRewards(address _rewards) external;


    function tendTrigger(uint256 callCost) external view returns (bool);


    function tend() external;


    function harvestTrigger(uint256 callCost) external view returns (bool);


    function harvest() external;

}// MIT
pragma solidity 0.6.12;

interface IHarvestableStrategy {

    function harvest() external;


    function controller() external view returns (address);


    function want() external view returns (address);

}// MIT
pragma solidity 0.6.12;

interface ICrvStrategy is IHarvestableStrategy {

    function gauge() external pure returns (address);


    function voter() external pure returns (address);

}// MIT
pragma solidity 0.6.12;

interface ICrvClaimable {

    function claimable_tokens(address _address) external returns (uint256 _amount);

}// MIT

pragma solidity 0.6.12;




contract CrvStrategyKeep3rJob2 is MachineryReady, Keep3r, ICrvStrategyKeep3rJob, ICrvStrategyKeep3rJobV2 {

    using SafeMath for uint256;

    uint256 public constant PRECISION = 1_000;
    uint256 public constant MAX_REWARD_MULTIPLIER = 1 * PRECISION; // 1x max reward multiplier
    uint256 public override rewardMultiplier = MAX_REWARD_MULTIPLIER;

    mapping(address => uint256) public override requiredHarvest;
    mapping(address => uint256) public override requiredEarn;
    mapping(address => uint256) public override lastWorkAt;
    mapping(address => bool) public override strategyIsV1;

    uint256 public override maxHarvestPeriod;
    uint256 public override lastHarvest;
    uint256 public override harvestCooldown;

    EnumerableSet.AddressSet internal _availableStrategies;

    address public override v2Keeper;

    constructor(
        address _mechanicsRegistry,
        address _keep3r,
        address _bond,
        uint256 _minBond,
        uint256 _earned,
        uint256 _age,
        bool _onlyEOA,
        uint256 _maxHarvestPeriod,
        uint256 _harvestCooldown,
        address _v2Keeper
    ) public MachineryReady(_mechanicsRegistry) Keep3r(_keep3r) {
        _setKeep3rRequirements(_bond, _minBond, _earned, _age, _onlyEOA);
        _setMaxHarvestPeriod(_maxHarvestPeriod);
        _setHarvestCooldown(_harvestCooldown);
        v2Keeper = _v2Keeper;
    }

    function setKeep3r(address _keep3r) external override onlyGovernor {

        _setKeep3r(_keep3r);
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

    function setV2Keep3r(address _v2Keeper) external override onlyGovernor {

        v2Keeper = _v2Keeper;
    }

    function setRewardMultiplier(uint256 _rewardMultiplier) external override onlyGovernorOrMechanic {

        _setRewardMultiplier(_rewardMultiplier);
        emit SetRewardMultiplier(_rewardMultiplier);
    }

    function _setRewardMultiplier(uint256 _rewardMultiplier) internal {

        require(_rewardMultiplier <= MAX_REWARD_MULTIPLIER, "CrvStrategyKeep3rJob::set-reward-multiplier:multiplier-exceeds-max");
        rewardMultiplier = _rewardMultiplier;
    }

    function addStrategies(
        address[] calldata _strategies,
        uint256[] calldata _requiredHarvests,
        uint256[] calldata _requiredEarns
    ) external override onlyGovernorOrMechanic {

        require(
            _strategies.length == _requiredHarvests.length && _strategies.length == _requiredEarns.length,
            "CrvStrategyKeep3rJob::add-strategies:strategies-required-harvests-and-earns-different-length"
        );
        for (uint256 i; i < _strategies.length; i++) {
            _addStrategy(_strategies[i], _requiredHarvests[i], _requiredEarns[i]);
        }
    }

    function addStrategy(
        address _strategy,
        uint256 _requiredHarvest,
        uint256 _requiredEarn
    ) external override onlyGovernorOrMechanic {

        _addStrategy(_strategy, _requiredHarvest, _requiredEarn);
    }

    function _addStrategy(
        address _strategy,
        uint256 _requiredHarvest,
        uint256 _requiredEarn
    ) internal {

        require(requiredHarvest[_strategy] == 0, "CrvStrategyKeep3rJob::add-strategy:strategy-already-added");
        _setRequiredHarvest(_strategy, _requiredHarvest);
        _setRequiredEarn(_strategy, _requiredEarn);
        _availableStrategies.add(_strategy);
        lastWorkAt[_strategy] = block.timestamp;
        emit StrategyAdded(_strategy, _requiredHarvest, _requiredEarn);
    }

    function updateStrategies(
        address[] calldata _strategies,
        uint256[] calldata _requiredHarvests,
        uint256[] calldata _requiredEarns
    ) external override onlyGovernorOrMechanic {

        require(
            _strategies.length == _requiredHarvests.length && _strategies.length == _requiredEarns.length,
            "CrvStrategyKeep3rJob::update-strategies:strategies-required-harvests-and-earns-different-length"
        );
        for (uint256 i; i < _strategies.length; i++) {
            _updateStrategy(_strategies[i], _requiredHarvests[i], _requiredEarns[i]);
        }
    }

    function updateStrategy(
        address _strategy,
        uint256 _requiredHarvest,
        uint256 _requiredEarn
    ) external override onlyGovernorOrMechanic {

        _updateStrategy(_strategy, _requiredHarvest, _requiredEarn);
    }

    function _updateStrategy(
        address _strategy,
        uint256 _requiredHarvest,
        uint256 _requiredEarn
    ) internal {

        require(requiredHarvest[_strategy] > 0, "CrvStrategyKeep3rJob::update-required-harvest:strategy-not-added");
        _setRequiredHarvest(_strategy, _requiredHarvest);
        _setRequiredEarn(_strategy, _requiredEarn);
        emit StrategyModified(_strategy, _requiredHarvest, _requiredEarn);
    }

    function removeStrategy(address _strategy) external override onlyGovernorOrMechanic {

        require(requiredHarvest[_strategy] > 0, "CrvStrategyKeep3rJob::remove-strategy:strategy-not-added");
        requiredHarvest[_strategy] = 0;
        _availableStrategies.remove(_strategy);
        emit StrategyRemoved(_strategy);
    }

    function _setRequiredHarvest(address _strategy, uint256 _requiredHarvest) internal {

        require(_requiredHarvest > 0, "CrvStrategyKeep3rJob::set-required-harvest:should-not-be-zero");
        requiredHarvest[_strategy] = _requiredHarvest;
    }

    function _setRequiredEarn(address _strategy, uint256 _requiredEarn) internal {

        require(_requiredEarn > 0, "CrvStrategyKeep3rJob::set-required-earn:should-not-be-zero");
        try ICrvStrategy(_strategy).controller() {
            strategyIsV1[_strategy] = true;
        } catch {}
        requiredEarn[_strategy] = _requiredEarn;
    }

    function setMaxHarvestPeriod(uint256 _maxHarvestPeriod) external override onlyGovernorOrMechanic {
        _setMaxHarvestPeriod(_maxHarvestPeriod);
    }

    function _setMaxHarvestPeriod(uint256 _maxHarvestPeriod) internal {
        require(_maxHarvestPeriod > 0, "CrvStrategyKeep3rJob::set-max-harvest-period:should-not-be-zero");
        maxHarvestPeriod = _maxHarvestPeriod;
    }

    function setHarvestCooldown(uint256 _harvestCooldown) external override onlyGovernorOrMechanic {
        _setHarvestCooldown(_harvestCooldown);
    }

    function _setHarvestCooldown(uint256 _harvestCooldown) internal {
        harvestCooldown = _harvestCooldown;
    }

    function strategies() public view override returns (address[] memory _strategies) {
        _strategies = new address[](_availableStrategies.length());
        for (uint256 i; i < _availableStrategies.length(); i++) {
            _strategies[i] = _availableStrategies.at(i);
        }
    }

    function calculateHarvest(address _strategy) public override returns (uint256 _amount) {
        require(requiredHarvest[_strategy] > 0, "CrvStrategyKeep3rJob::calculate-harvest:strategy-not-added");
        address _gauge = ICrvStrategy(_strategy).gauge();
        address _voter = ICrvStrategy(_strategy).voter();
        return ICrvClaimable(_gauge).claimable_tokens(_voter);
    }

    function workable(address _strategy) external override notPaused returns (bool) {
        return _workable(_strategy);
    }

    function _workable(address _strategy) internal returns (bool) {
        require(requiredHarvest[_strategy] > 0, "CrvStrategyKeep3rJob::workable:strategy-not-added");
        if (block.timestamp < lastHarvest.add(harvestCooldown)) return false;
        if (block.timestamp > lastWorkAt[_strategy].add(maxHarvestPeriod)) return true;
        if (!strategyIsV1[_strategy] && IBaseStrategy(_strategy).harvestTrigger(requiredEarn[_strategy])) return true;
        return calculateHarvest(_strategy) >= requiredHarvest[_strategy];
    }

    function _work(address _strategy, bool _workForTokens) internal returns (uint256 _credits) {
        uint256 _initialGas = gasleft();
        require(_workable(_strategy), "CrvStrategyKeep3rJob::harvest:not-workable");

        _workInternal(_strategy);

        _credits = _calculateCredits(_initialGas);

        emit Worked(_strategy, msg.sender, _credits, _workForTokens);
    }

    function _workInternal(address _strategy) internal {
        if (strategyIsV1[_strategy]) {
            _workV1(_strategy);
        } else {
            _workV2(_strategy);
        }
        _postWork(_strategy);
    }

    function _workV1(address _strategy) internal {
        address controller = ICrvStrategy(_strategy).controller();
        address want = ICrvStrategy(_strategy).want();
        address vault = IV1Controller(controller).vaults(want);
        uint256 available = IV1Vault(vault).available();
        if (available >= requiredEarn[_strategy]) {
            IV1Vault(vault).earn();
        }
        ICrvStrategy(_strategy).harvest();
    }

    function _workV2(address _strategy) internal {
        IV2Keeper(v2Keeper).harvest(_strategy);
    }

    function work(address _strategy) external override returns (uint256 _credits) {
        return workForBond(_strategy);
    }

    function workForBond(address _strategy) public override notPaused onlyKeeper returns (uint256 _credits) {
        _credits = _work(_strategy, false);
        _paysKeeperAmount(msg.sender, _credits);
    }

    function workForTokens(address _strategy) external override notPaused onlyKeeper returns (uint256 _credits) {
        _credits = _work(_strategy, true);
        _paysKeeperInTokens(msg.sender, _credits);
    }

    function _calculateCredits(uint256 _initialGas) internal view returns (uint256 _credits) {
        return _getQuoteLimitFor(msg.sender, _initialGas).mul(rewardMultiplier).div(PRECISION);
    }

    function forceWork(address _strategy) external override onlyGovernorOrMechanic {
        _workInternal(_strategy);
        emit ForceWorked(_strategy);
    }

    function _postWork(address _strategy) internal {
        lastWorkAt[_strategy] = block.timestamp;
        lastHarvest = block.timestamp;
    }
}