
pragma solidity >=0.6.0 <0.8.0;

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
}// MIT

pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
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

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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
}pragma solidity 0.7.3;


contract BaseUpgradeableStrategyStorage {


  bytes32 internal constant _UNDERLYING_SLOT = 0xa1709211eeccf8f4ad5b6700d52a1a9525b5f5ae1e9e5f9e5a0c2fc23c86e530;
  bytes32 internal constant _VAULT_SLOT = 0xefd7c7d9ef1040fc87e7ad11fe15f86e1d11e1df03c6d7c87f7e1f4041f08d41;

  bytes32 internal constant _SLP_REWARD_TOKEN_SLOT = 0x39f6508fa78bf0f8811208dd5eeef269668a89d1dc64bfffde1f9147d9071963;
  bytes32 internal constant _SLP_REWARD_POOL_SLOT = 0x38a0c4d4bce281b7791c697a1359747b8fbd89f22fbe5557828bf15a023175da;
  bytes32 internal constant _ONX_FARM_REWARD_POOL_SLOT = 0x24f4d5cb1e6d05c6fb88a551e1e1659fba608459340d9f45cc3171803a2b8552;
  bytes32 internal constant _ONX_STAKING_REWARD_POOL_SLOT = 0x9cb98b534f7a03048b0fe6d7d318ae0a1818bcdf1b23f010350af3399659d8cf;
  bytes32 internal constant _SELL_FLOOR_SLOT = 0xc403216a7704d160f6a3b5c3b149a1226a6080f0a5dd27b27d9ba9c022fa0afc;
  bytes32 internal constant _SELL_SLOT = 0x656de32df98753b07482576beb0d00a6b949ebf84c066c765f54f26725221bb6;
  bytes32 internal constant _PAUSED_INVESTING_SLOT = 0xa07a20a2d463a602c2b891eb35f244624d9068572811f63d0e094072fb54591a;


  bytes32 internal constant _NEXT_IMPLEMENTATION_SLOT = 0x29f7fcd4fe2517c1963807a1ec27b0e45e67c60a874d5eeac7a0b1ab1bb84447;
  bytes32 internal constant _NEXT_IMPLEMENTATION_TIMESTAMP_SLOT = 0x414c5263b05428f1be1bfa98e25407cc78dd031d0d3cd2a2e3d63b488804f22e;
  bytes32 internal constant _NEXT_IMPLEMENTATION_DELAY_SLOT = 0x82b330ca72bcd6db11a26f10ce47ebcfe574a9c646bccbc6f1cd4478eae16b31;

  constructor() public {
    assert(_UNDERLYING_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.underlying")) - 1));
    assert(_VAULT_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.vault")) - 1));
    assert(_SLP_REWARD_TOKEN_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.slpRewardToken")) - 1));
    assert(_SLP_REWARD_POOL_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.slpRewardPool")) - 1));
    assert(_ONX_FARM_REWARD_POOL_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.onxXSushiFarmRewardPool")) - 1));
    assert(_ONX_STAKING_REWARD_POOL_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.onxStakingRewardPool")) - 1));
    assert(_SELL_FLOOR_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.sellFloor")) - 1));
    assert(_SELL_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.sell")) - 1));
    assert(_PAUSED_INVESTING_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.pausedInvesting")) - 1));

    assert(_NEXT_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementation")) - 1));
    assert(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementationTimestamp")) - 1));
    assert(_NEXT_IMPLEMENTATION_DELAY_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.nextImplementationDelay")) - 1));
  }

  function _setUnderlying(address _address) internal {

    setAddress(_UNDERLYING_SLOT, _address);
  }

  function underlying() public view returns (address) {

    return getAddress(_UNDERLYING_SLOT);
  }


  function _setSLPRewardPool(address _address) internal {

    setAddress(_SLP_REWARD_POOL_SLOT, _address);
  }

  function slpRewardPool() public view returns (address) {

    return getAddress(_SLP_REWARD_POOL_SLOT);
  }

  function _setSLPRewardToken(address _address) internal {

    setAddress(_SLP_REWARD_TOKEN_SLOT, _address);
  }

  function slpRewardToken() public view returns (address) {

    return getAddress(_SLP_REWARD_TOKEN_SLOT);
  }


  function _setOnxFarmRewardPool(address _address) internal {

    setAddress(_ONX_FARM_REWARD_POOL_SLOT, _address);
  }

  function onxFarmRewardPool() public view returns (address) {

    return getAddress(_ONX_FARM_REWARD_POOL_SLOT);
  }


  function _setOnxStakingRewardPool(address _address) internal {

    setAddress(_ONX_STAKING_REWARD_POOL_SLOT, _address);
  }

  function onxStakingRewardPool() public view returns (address) {

    return getAddress(_ONX_STAKING_REWARD_POOL_SLOT);
  }


  function _setVault(address _address) internal {

    setAddress(_VAULT_SLOT, _address);
  }

  function vault() public view returns (address) {

    return getAddress(_VAULT_SLOT);
  }

  function _setSell(bool _value) internal {

    setBoolean(_SELL_SLOT, _value);
  }

  function sell() public view returns (bool) {

    return getBoolean(_SELL_SLOT);
  }

  function _setPausedInvesting(bool _value) internal {

    setBoolean(_PAUSED_INVESTING_SLOT, _value);
  }

  function pausedInvesting() public view returns (bool) {

    return getBoolean(_PAUSED_INVESTING_SLOT);
  }

  function _setSellFloor(uint256 _value) internal {

    setUint256(_SELL_FLOOR_SLOT, _value);
  }

  function sellFloor() public view returns (uint256) {

    return getUint256(_SELL_FLOOR_SLOT);
  }


  function _setNextImplementation(address _address) internal {

    setAddress(_NEXT_IMPLEMENTATION_SLOT, _address);
  }

  function nextImplementation() public view returns (address) {

    return getAddress(_NEXT_IMPLEMENTATION_SLOT);
  }

  function _setNextImplementationTimestamp(uint256 _value) internal {

    setUint256(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT, _value);
  }

  function nextImplementationTimestamp() public view returns (uint256) {

    return getUint256(_NEXT_IMPLEMENTATION_TIMESTAMP_SLOT);
  }

  function _setNextImplementationDelay(uint256 _value) internal {

    setUint256(_NEXT_IMPLEMENTATION_DELAY_SLOT, _value);
  }

  function nextImplementationDelay() public view returns (uint256) {

    return getUint256(_NEXT_IMPLEMENTATION_DELAY_SLOT);
  }

  function setBoolean(bytes32 slot, bool _value) internal {

    setUint256(slot, _value ? 1 : 0);
  }

  function getBoolean(bytes32 slot) internal view returns (bool) {

    return (getUint256(slot) == 1);
  }

  function setAddress(bytes32 slot, address _address) internal {

    assembly {
      sstore(slot, _address)
    }
  }

  function setUint256(bytes32 slot, uint256 _value) internal {

    assembly {
      sstore(slot, _value)
    }
  }

  function getAddress(bytes32 slot) internal view returns (address str) {

    assembly {
      str := sload(slot)
    }
  }

  function getUint256(bytes32 slot) internal view returns (uint256 str) {

    assembly {
      str := sload(slot)
    }
  }
}pragma solidity 0.7.3;

contract Storage {


  address public governance;
  address public controller;

  constructor() public {
    governance = msg.sender;
  }

  modifier onlyGovernance() {

    require(isGovernance(msg.sender), "Not governance");
    _;
  }

  function setGovernance(address _governance) public onlyGovernance {

    require(_governance != address(0), "new governance shouldn't be empty");
    governance = _governance;
  }

  function setController(address _controller) public onlyGovernance {

    require(_controller != address(0), "new controller shouldn't be empty");
    controller = _controller;
  }

  function isGovernance(address account) public view returns (bool) {

    return account == governance;
  }

  function isController(address account) public view returns (bool) {

    return account == controller;
  }
}pragma solidity 0.7.3;


contract GovernableInit is Initializable {


  bytes32 internal constant _STORAGE_SLOT = 0xa7ec62784904ff31cbcc32d09932a58e7f1e4476e1d041995b37c917990b16dc;

  modifier onlyGovernance() {

    require(Storage(_storage()).isGovernance(msg.sender), "Not governance");
    _;
  }

  constructor() public {
    assert(_STORAGE_SLOT == bytes32(uint256(keccak256("eip1967.governableInit.storage")) - 1));
  }

  function initialize(address _store) public virtual initializer {

    _setStorage(_store);
  }

  function _setStorage(address newStorage) private {

    bytes32 slot = _STORAGE_SLOT;
    assembly {
      sstore(slot, newStorage)
    }
  }

  function setStorage(address _store) public onlyGovernance {

    require(_store != address(0), "new storage shouldn't be empty");
    _setStorage(_store);
  }

  function _storage() internal view returns (address str) {

    bytes32 slot = _STORAGE_SLOT;
    assembly {
      str := sload(slot)
    }
  }

  function governance() public view returns (address) {

    return Storage(_storage()).governance();
  }
}pragma solidity 0.7.3;


contract ControllableInit is GovernableInit {


  constructor() public {
  }

  function initialize(address _storage) public override initializer {

    GovernableInit.initialize(_storage);
  }

  modifier onlyController() {

    require(Storage(_storage()).isController(msg.sender), "Not a controller");
    _;
  }

  modifier onlyControllerOrGovernance(){

    require((Storage(_storage()).isController(msg.sender) || Storage(_storage()).isGovernance(msg.sender)),
      "The caller must be controller or governance");
    _;
  }

  function controller() public view returns (address) {

    return Storage(_storage()).controller();
  }
}pragma solidity 0.7.3;

interface IController {

    function greyList(address _target) external view returns(bool);


    function addVaultAndStrategy(address _vault, address _strategy) external;

    function stakeOnsenFarm(address _vault) external;

    function stakeSushiBar(address _vault) external;

    function stakeOnxFarm(address _vault) external;

    function stakeOnx(address _vault) external;

    
    function hasVault(address _vault) external returns(bool);


    function salvage(address _token, uint256 amount) external;

    function salvageStrategy(address _strategy, address _token, uint256 amount) external;

}pragma solidity 0.7.3;


contract BaseUpgradeableStrategy is Initializable, ControllableInit, BaseUpgradeableStrategyStorage {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  modifier restricted() {

    require(msg.sender == vault() || msg.sender == controller()
      || msg.sender == governance(),
      "The sender has to be the controller, governance, or vault");
    _;
  }

  modifier onlyNotPausedInvesting() {

    require(!pausedInvesting(), "Action blocked as the strategy is in emergency state");
    _;
  }

  constructor() public BaseUpgradeableStrategyStorage() {
  }

  function initialize(
    address _storage,
    address _underlying,
    address _vault,
    address _slpRewardPool,
    address _slpRewardToken,
    address _onxOnxFarmRewardPool,
    address _onxStakingRewardPool,
    bool _sell,
    uint256 _sellFloor,
    uint256 _implementationChangeDelay
  ) public initializer {

    ControllableInit.initialize(
      _storage
    );
    _setUnderlying(_underlying);
    _setVault(_vault);
    _setSLPRewardPool(_slpRewardPool);
    _setSLPRewardToken(_slpRewardToken);
    _setOnxFarmRewardPool(_onxOnxFarmRewardPool);
    _setOnxStakingRewardPool(_onxStakingRewardPool);

    _setSell(_sell);
    _setSellFloor(_sellFloor);
    _setNextImplementationDelay(_implementationChangeDelay);
    _setPausedInvesting(false);
  }

  function scheduleUpgrade(address impl) public onlyGovernance {

    _setNextImplementation(impl);
    _setNextImplementationTimestamp(block.timestamp.add(nextImplementationDelay()));
  }

  function _finalizeUpgrade() internal {

    _setNextImplementation(address(0));
    _setNextImplementationTimestamp(0);
  }

  function shouldUpgrade() external view returns (bool, address) {

    return (
      nextImplementationTimestamp() != 0
        && block.timestamp > nextImplementationTimestamp()
        && nextImplementation() != address(0),
      nextImplementation()
    );
  }
}pragma solidity 0.7.3;

interface SushiBar {

  function enter(uint256 _amount) external;

  function leave(uint256 _share) external;

}pragma solidity 0.7.3;

interface IMasterChef {

    function deposit(uint256 _pid, uint256 _amount) external;

    function withdraw(uint256 _pid, uint256 _amount) external;

    function emergencyWithdraw(uint256 _pid) external;

    function userInfo(uint256 _pid, address _user) external view returns (uint256 amount, uint256 rewardDebt);

    function poolInfo(uint256 _pid) external view returns (address lpToken, uint256, uint256, uint256);

    function massUpdatePools() external;

    function add(uint256, address, bool) external;

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name_, string memory symbol_) public {
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view virtual override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {

        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal virtual {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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
}// MIT

pragma solidity 0.7.3;


contract TAlphaToken is ERC20("TAlphaToken", "TALPHA"), Ownable {
  function mint(address _to, uint256 _amount) public onlyOwner {
    _mint(_to, _amount);
  }

  function burn(address _from, uint256 _amount) public onlyOwner {
    _burn(_from, _amount);
  }
}//Unlicense

pragma solidity 0.7.3;

interface IVault {
    function underlyingBalanceInVault() external view returns (uint256);
    function underlyingBalanceWithInvestment() external view returns (uint256);

    function underlying() external view returns (address);
    function strategy() external view returns (address);

    function setStrategy(address _strategy) external;

    function deposit(uint256 amountWei) external;
    function depositFor(uint256 amountWei, address holder) external;

    function withdrawAll() external;
    function withdraw(uint256 numberOfShares) external;

    function underlyingBalanceWithInvestmentForHolder(address holder) view external returns (uint256);

    function stakeOnsenFarm() external;
    function stakeSushiBar() external;
    function stakeOnxFarm() external;
    function stakeOnx() external;

    function withdrawPendingTeamFund() external;
    function withdrawPendingTreasuryFund() external;
}pragma solidity 0.7.3;


contract AlphaStrategy is BaseUpgradeableStrategy {

  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  bytes32 internal constant _SLP_POOLID_SLOT = 0x8956ecb40f9dfb494a392437d28a65bb0ddc57b20a9b6274df098a6daa528a72;
  bytes32 internal constant _ONX_FARM_POOLID_SLOT = 0x1da1707f101f5a1bf84020973bd9ccafa38ae6f35fcff3e0f1f3590f13f665c0;

  address public onx;
  address public stakedOnx;
  address public sushi;
  address public xSushi;

  address private onxTeamVault = address(0xD25C0aDddD858EB291E162CD4CC984f83C8ff26f);
  address private onxTreasuryVault = address(0xe1825EAbBe12F0DF15972C2fDE0297C8053293aA);
  address private strategicWallet = address(0xe1825EAbBe12F0DF15972C2fDE0297C8053293aA);


  uint256 private pendingTeamFund;
  uint256 private pendingTreasuryFund;

  mapping(address => uint256) public userRewardDebt;

  uint256 public accRewardPerShare;
  uint256 public lastPendingReward;
  uint256 public curPendingReward;

  mapping(address => uint256) public userXSushiDebt;

  uint256 public accXSushiPerShare;
  uint256 public lastPendingXSushi;
  uint256 public curPendingXSushi;

  TAlphaToken public tAlpha;

  constructor() public BaseUpgradeableStrategy() {
    assert(_SLP_POOLID_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.slpPoolId")) - 1));
    assert(_ONX_FARM_POOLID_SLOT == bytes32(uint256(keccak256("eip1967.strategyStorage.onxFarmRewardPoolId")) - 1));
  }

  function initializeAlphaStrategy(
    address _storage,
    address _underlying,
    address _vault,
    address _slpRewardPool,
    uint256 _slpPoolID,
    address _onxFarmRewardPool,
    uint256 _onxFarmRewardPoolId,
    address _onx,
    address _stakedOnx,
    address _sushi,
    address _xSushi
  ) public initializer {

    BaseUpgradeableStrategy.initialize(
      _storage,
      _underlying,
      _vault,
      _slpRewardPool,
      _sushi,
      _onxFarmRewardPool,
      _stakedOnx,
      true, // sell
      0, // sell floor
      12 hours // implementation change delay
    );

    address _lpt;
    (_lpt,,,) = IMasterChef(slpRewardPool()).poolInfo(_slpPoolID);
    require(_lpt == underlying(), "Pool Info does not match underlying");
    _setSLPPoolId(_slpPoolID);
    _setOnxFarmPoolId(_onxFarmRewardPoolId);

    onx = _onx;
    sushi = _sushi;
    xSushi = _xSushi;
    stakedOnx = _stakedOnx;

    tAlpha = new TAlphaToken();
  }

  function unsalvagableTokens(address token) public view returns (bool) {
    return (token == onx || token == stakedOnx || token == sushi || token == underlying());
  }

  function salvage(address recipient, address token, uint256 amount) public onlyGovernance {
    require(!unsalvagableTokens(token), "token is defined as not salvagable");
    IERC20(token).safeTransfer(recipient, amount);
  }


  modifier onlyVault() {
    require(msg.sender == vault(), "Not a vault");
    _;
  }

  function updateAccPerShare(address user) public onlyVault {
    curPendingReward = pendingReward();
    uint256 totalSupply = IERC20(vault()).totalSupply();

    if (lastPendingReward > 0 && curPendingReward < lastPendingReward) {
      curPendingReward = 0;
      lastPendingReward = 0;
      accRewardPerShare = 0;
      userRewardDebt[user] = 0;
      return;
    }

    if (totalSupply == 0) {
      accRewardPerShare = 0;
      return;
    }

    uint256 addedReward = curPendingReward.sub(lastPendingReward);
    accRewardPerShare = accRewardPerShare.add(
      (addedReward.mul(1e36)).div(totalSupply)
    );


    curPendingXSushi = pendingXSushi();

    if (lastPendingXSushi > 0 && curPendingXSushi < lastPendingXSushi) {
      curPendingXSushi = 0;
      lastPendingXSushi = 0;
      accXSushiPerShare = 0;
      userXSushiDebt[user] = 0;
      return;
    }

    if (totalSupply == 0) {
      accXSushiPerShare = 0;
      return;
    }

    addedReward = curPendingXSushi.sub(lastPendingXSushi);
    accXSushiPerShare = accXSushiPerShare.add(
      (addedReward.mul(1e36)).div(totalSupply)
    );
  }

  function pendingReward() public view returns (uint256) {
    return IERC20(stakedOnx).balanceOf(address(this));
  }

  function pendingXSushi() public view returns (uint256) {
    return IERC20(xSushi).balanceOf(address(this));
  }

  function pendingRewardOfUser(address user) external view returns (uint256, uint256) {
    uint256 totalSupply = IERC20(vault()).totalSupply();
    uint256 userBalance = IERC20(vault()).balanceOf(user);
    if (totalSupply == 0) return (0, 0);

    uint256 allPendingReward = pendingReward();
    if (allPendingReward < lastPendingReward) return (0, 0);
    uint256 addedReward = allPendingReward.sub(lastPendingReward);
    uint256 newAccRewardPerShare = accRewardPerShare.add(
        (addedReward.mul(1e36)).div(totalSupply)
    );

    uint256 allPendingXSushi = pendingXSushi();
    if (allPendingXSushi < lastPendingXSushi) return (0, 0);
    addedReward = allPendingXSushi.sub(lastPendingXSushi);
    uint256 newAccXSushiPerShare = accXSushiPerShare.add(
        (addedReward.mul(1e36)).div(totalSupply)
    );

    return (
      userBalance.mul(newAccRewardPerShare).div(1e36).sub(
          userRewardDebt[user]
      ), userBalance.mul(newAccXSushiPerShare).div(1e36).sub(
          userXSushiDebt[user]
      )
    );
  }

  function withdrawReward(address user) public onlyVault {
    uint256 _pending = IERC20(vault()).balanceOf(user)
    .mul(accRewardPerShare)
    .div(1e36)
    .sub(userRewardDebt[user]);
    uint256 _balance = IERC20(stakedOnx).balanceOf(address(this));
    if (_balance < _pending) {
      _pending = _balance;
    }
    IERC20(stakedOnx).safeTransfer(user, _pending);
    lastPendingReward = curPendingReward.sub(_pending);

    uint256 _pendingXSushi = IERC20(vault()).balanceOf(user)
    .mul(accXSushiPerShare)
    .div(1e36)
    .sub(userXSushiDebt[user]);
    uint256 _xSushiBalance = IERC20(xSushi).balanceOf(address(this));
    if (_xSushiBalance < _pendingXSushi) {
      _pendingXSushi = _xSushiBalance;
    }
    IERC20(xSushi).safeTransfer(user, _pendingXSushi);
    lastPendingXSushi = curPendingXSushi.sub(_pendingXSushi);
  }


  function slpRewardPoolBalance() internal view returns (uint256 bal) {
      (bal,) = IMasterChef(slpRewardPool()).userInfo(slpPoolId(), address(this));
  }

  function exitSLPRewardPool() internal {
      uint256 bal = slpRewardPoolBalance();
      if (bal != 0) {
          IMasterChef(slpRewardPool()).withdraw(slpPoolId(), bal);
      }
  }

  function claimSLPRewardPool() internal {
      uint256 bal = slpRewardPoolBalance();
      if (bal != 0) {
          IMasterChef(slpRewardPool()).withdraw(slpPoolId(), 0);
      }
  }

  function emergencyExitSLPRewardPool() internal {
      uint256 bal = slpRewardPoolBalance();
      if (bal != 0) {
          IMasterChef(slpRewardPool()).emergencyWithdraw(slpPoolId());
      }
  }

  function enterSLPRewardPool() internal {
    uint256 entireBalance = IERC20(underlying()).balanceOf(address(this));
    if (entireBalance > 0) {
      IERC20(underlying()).safeApprove(slpRewardPool(), 0);
      IERC20(underlying()).safeApprove(slpRewardPool(), entireBalance);
      IMasterChef(slpRewardPool()).deposit(slpPoolId(), entireBalance);
    }
  }

  function emergencyExit() public onlyGovernance {
    emergencyExitSLPRewardPool();
    _setPausedInvesting(true);
  }


  function continueInvesting() public onlyGovernance {
    _setPausedInvesting(false);
  }

  function withdrawAllToVault() public restricted {
    if (address(slpRewardPool()) != address(0)) {
      exitSLPRewardPool();
    }
    IERC20(underlying()).safeTransfer(vault(), IERC20(underlying()).balanceOf(address(this)));
  }

  function withdrawToVault(uint256 amount) public restricted {
    uint256 entireBalance = IERC20(underlying()).balanceOf(address(this));

    if(amount > entireBalance){
      uint256 needToWithdraw = amount.sub(entireBalance);
      uint256 toWithdraw = Math.min(slpRewardPoolBalance(), needToWithdraw);
      IMasterChef(slpRewardPool()).withdraw(slpPoolId(), toWithdraw);
    }

    IERC20(underlying()).safeTransfer(vault(), amount);
  }

  function investedUnderlyingBalance() external view returns (uint256) {
    if (slpRewardPool() == address(0)) {
      return IERC20(underlying()).balanceOf(address(this));
    }
    return slpRewardPoolBalance().add(IERC20(underlying()).balanceOf(address(this)));
  }


  function stakeOnsenFarm() external onlyNotPausedInvesting restricted {
    enterSLPRewardPool();
  }


  function stakeSushiBar() external onlyNotPausedInvesting restricted {
    claimSLPRewardPool();

    uint256 sushiRewardBalance = IERC20(sushi).balanceOf(address(this));
    if (!sell() || sushiRewardBalance < sellFloor()) {
      return;
    }

    if (sushiRewardBalance == 0) {
      return;
    }

    IERC20(sushi).safeApprove(xSushi, 0);
    IERC20(sushi).safeApprove(xSushi, sushiRewardBalance);

    SushiBar(xSushi).enter(sushiRewardBalance);
  }


  function _enterOnxFarmRewardPool() internal {
    uint256 entireBalance = IERC20(xSushi).balanceOf(address(this));
    tAlpha.mint(address(this), entireBalance);
    IERC20(tAlpha).safeApprove(onxFarmRewardPool(), 0);
    IERC20(tAlpha).safeApprove(onxFarmRewardPool(), entireBalance);
    IMasterChef(onxFarmRewardPool()).deposit(onxFarmRewardPoolId(), entireBalance);
  }

  function _onxFarmRewardPoolBalance() internal view returns (uint256 bal) {
      (bal,) = IMasterChef(onxFarmRewardPool()).userInfo(onxFarmRewardPoolId(), address(this));
  }

  function _exitOnxFarmRewardPool() internal {
      uint256 bal = _onxFarmRewardPoolBalance();
      if (bal != 0) {
          IMasterChef(onxFarmRewardPool()).withdraw(onxFarmRewardPoolId(), bal);
          tAlpha.burn(address(this), bal);
      }
  }

  function _claimXSushiRewardPool() internal {
      uint256 bal = _onxFarmRewardPoolBalance();
      if (bal != 0) {
          IMasterChef(onxFarmRewardPool()).withdraw(onxFarmRewardPoolId(), 0);
      }
  }

  function stakeOnxFarm() external onlyNotPausedInvesting restricted {
    _enterOnxFarmRewardPool();
  }


  function stakeOnx() external onlyNotPausedInvesting restricted {
    _claimXSushiRewardPool();

    uint256 onxRewardBalance = IERC20(onx).balanceOf(address(this));

    uint256 stakedOnxRewardBalance = IERC20(onxStakingRewardPool()).balanceOf(address(this));
    
    if (!sell() || onxRewardBalance < sellFloor()) {
      return;
    }

    if (onxRewardBalance == 0) {
      return;
    }

    IERC20(onx).safeApprove(onxStakingRewardPool(), 0);
    IERC20(onx).safeApprove(onxStakingRewardPool(), onxRewardBalance);

    SushiBar(onxStakingRewardPool()).enter(onxRewardBalance);
  }

  function withdrawPendingTeamFund() external restricted {
    if (pendingTeamFund > 0) {
      uint256 balance = IERC20(stakedOnx).balanceOf(address(this));

      if (pendingTeamFund > balance) {
        pendingTeamFund = balance;
      }

      IERC20(stakedOnx).safeApprove(onxTeamVault, 0);
      IERC20(stakedOnx).safeApprove(onxTeamVault, pendingTeamFund);
      IERC20(stakedOnx).safeTransfer(onxTeamVault, pendingTeamFund);

      pendingTeamFund = 0;
    }
  }

  function withdrawPendingTreasuryFund() external restricted {
    if (pendingTreasuryFund > 0) {
      uint256 balance = IERC20(stakedOnx).balanceOf(address(this));

      if (pendingTreasuryFund > balance) {
        pendingTreasuryFund = balance;
      }

      IERC20(stakedOnx).safeApprove(onxTreasuryVault, 0);
      IERC20(stakedOnx).safeApprove(onxTreasuryVault, pendingTreasuryFund);
      IERC20(stakedOnx).safeTransfer(onxTreasuryVault, pendingTreasuryFund);

      pendingTreasuryFund = 0;
    }
  }

  function setSell(bool s) public onlyGovernance {
    _setSell(s);
  }

  function setSellFloor(uint256 floor) public onlyGovernance {
    _setSellFloor(floor);
  }

  function _setSLPPoolId(uint256 _value) internal {
    setUint256(_SLP_POOLID_SLOT, _value);
  }

  function _setOnxFarmPoolId(uint256 _value) internal {
    setUint256(_ONX_FARM_POOLID_SLOT, _value);
  }

  function slpPoolId() public view returns (uint256) {
    return getUint256(_SLP_POOLID_SLOT);
  }

  function onxFarmRewardPoolId() public view returns (uint256) {
    return getUint256(_ONX_FARM_POOLID_SLOT);
  }

  function setOnxTeamFundAddress(address _address) public onlyGovernance {
    onxTeamVault = _address;
  }

  function setOnxTreasuryFundAddress(address _address) public onlyGovernance {
    onxTreasuryVault = _address;
  }

  function setStrategicWalletAddress(address _address) public onlyGovernance {
    strategicWallet = _address;
  }

  function finalizeUpgrade() external onlyGovernance {
    _finalizeUpgrade();
  }
}pragma solidity 0.7.3;


contract Strategy is AlphaStrategy {

  constructor() public {}

  function initializeStrategy(
    address _storage,
    address _vault
  ) public initializer {
    address underlying = address(0xCEfF51756c56CeFFCA006cD410B03FFC46dd3a58);
    address slpRewardPool = address(0xc2EdaD668740f1aA35E4D8f227fB8E17dcA888Cd);
    address onxFarmRewardPool = address(0x168F8469Ac17dd39cd9a2c2eAD647f814a488ce9);
    address stakedOnx = address(0xa99F0aD2a539b2867fcfea47F7E71F240940B47c);
    address onx = address(0xE0aD1806Fd3E7edF6FF52Fdb822432e847411033);
    address xSushi = address(0x8798249c2E607446EfB7Ad49eC89dD1865Ff4272);
    address sushi = address(0x6B3595068778DD592e39A122f4f5a5cF09C90fE2);
    AlphaStrategy.initializeAlphaStrategy(
      _storage,
      underlying,
      _vault,
      slpRewardPool, // master chef contract
      21,  // SLP Pool id
      onxFarmRewardPool,
      11,
      onx,
      stakedOnx,
      sushi,
      xSushi
    );
  }
}