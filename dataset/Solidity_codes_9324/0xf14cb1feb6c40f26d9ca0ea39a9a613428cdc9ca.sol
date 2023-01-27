
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


interface IKeep3rEscrowParameters {

  function keep3r() external returns (address);

}

abstract contract Keep3rEscrowParameters is UtilsReady, IKeep3rEscrowParameters {
  address public immutable override keep3r;

  constructor(address _keep3r) public UtilsReady() {
    require(address(_keep3r) != address(0), 'Keep3rEscrowParameters::constructor::keep3r-zero-address');
    keep3r = _keep3r;
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



interface IKeep3rEscrowLiquidityHandler {

  event LiquidityAddedToJob(address _liquidity, address _job, uint256 _amount);
  event AppliedCreditToJob(address _provider, address _liquidity, address _job);
  event LiquidityUnbondedFromJob(address _liquidity, address _job, uint256 _amount);
  event LiquidityRemovedFromJob(address _liquidity, address _job);

  function liquidityTotalAmount(address _liquidity) external returns (uint256 _amount);


  function liquidityProvidedAmount(address _liquidity) external returns (uint256 _amount);


  function deposit(address _liquidity, uint256 _amount) external;


  function withdraw(address _liquidity, uint256 _amount) external;


  function addLiquidityToJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;


  function applyCreditToJob(
    address _provider,
    address _liquidity,
    address _job
  ) external;


  function unbondLiquidityFromJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;


  function removeLiquidityFromJob(address _liquidity, address _job) external returns (uint256 _amount);

}

abstract contract Keep3rEscrowLiquidityHandler is Keep3rEscrowParameters, IKeep3rEscrowLiquidityHandler {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  mapping(address => uint256) public override liquidityTotalAmount;
  mapping(address => uint256) public override liquidityProvidedAmount;

  function _deposit(address _liquidity, uint256 _amount) internal {
    liquidityTotalAmount[_liquidity] = liquidityTotalAmount[_liquidity].add(_amount);
    IERC20(_liquidity).safeTransferFrom(governor, address(this), _amount);
  }

  function _withdraw(address _liquidity, uint256 _amount) internal {
    liquidityTotalAmount[_liquidity] = liquidityTotalAmount[_liquidity].sub(_amount);
    IERC20(_liquidity).safeTransfer(governor, _amount);
  }

  function _addLiquidityToJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) internal {
    IERC20(_liquidity).approve(keep3r, _amount);
    IKeep3rV1(keep3r).addLiquidityToJob(_liquidity, _job, _amount);
    liquidityProvidedAmount[_liquidity] = liquidityProvidedAmount[_liquidity].add(_amount);
  }

  function _applyCreditToJob(
    address _provider,
    address _liquidity,
    address _job
  ) internal {
    IKeep3rV1(keep3r).applyCreditToJob(_provider, _liquidity, _job);
    emit AppliedCreditToJob(_provider, _liquidity, _job);
  }

  function _unbondLiquidityFromJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) internal {
    IKeep3rV1(keep3r).unbondLiquidityFromJob(_liquidity, _job, _amount);
  }

  function _removeLiquidityFromJob(address _liquidity, address _job) internal returns (uint256 _amount) {
    uint256 _before = IERC20(_liquidity).balanceOf(address(this));
    IKeep3rV1(keep3r).removeLiquidityFromJob(_liquidity, _job);
    _amount = IERC20(_liquidity).balanceOf(address(this)).sub(_before);
    liquidityProvidedAmount[_liquidity] = liquidityProvidedAmount[_liquidity].sub(_amount);
  }

  function _safeSendDust(
    address _to,
    address _token,
    uint256 _amount
  ) internal {
    if (liquidityTotalAmount[_token] > 0) {
      uint256 _balance = IERC20(_token).balanceOf(address(this));
      uint256 _provided = liquidityProvidedAmount[_token];
      require(_amount <= _balance.add(_provided).sub(liquidityTotalAmount[_token]));
    }
    _sendDust(_to, _token, _amount);
  }
}// MIT

pragma solidity 0.6.12;


interface IKeep3rEscrow is IKeep3rEscrowParameters, IKeep3rEscrowLiquidityHandler {}


contract Keep3rEscrow is Keep3rEscrowParameters, Keep3rEscrowLiquidityHandler, IKeep3rEscrow {

  constructor(address _keep3r) public Keep3rEscrowParameters(_keep3r) {}

  function deposit(address _liquidity, uint256 _amount) external override onlyGovernor {

    _deposit(_liquidity, _amount);
  }

  function withdraw(address _liquidity, uint256 _amount) external override onlyGovernor {

    _withdraw(_liquidity, _amount);
  }

  function addLiquidityToJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external override onlyGovernor {

    _addLiquidityToJob(_liquidity, _job, _amount);
  }

  function applyCreditToJob(
    address _provider,
    address _liquidity,
    address _job
  ) external override onlyGovernor {

    _applyCreditToJob(_provider, _liquidity, _job);
  }

  function unbondLiquidityFromJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external override onlyGovernor {

    _unbondLiquidityFromJob(_liquidity, _job, _amount);
  }

  function removeLiquidityFromJob(address _liquidity, address _job) external override onlyGovernor returns (uint256 _amount) {

    return _removeLiquidityFromJob(_liquidity, _job);
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {

    _safeSendDust(_to, _token, _amount);
  }
}// MIT

pragma solidity 0.6.12;



interface IKeep3rLiquidityManagerEscrowsHandler {

  event Escrow1Set(address _escrow1);

  event Escrow2Set(address _escrow2);

  function escrow1() external view returns (address _escrow1);


  function escrow2() external view returns (address _escrow2);


  function isValidEscrow(address _escrow) external view returns (bool);


  function addLiquidityToJob(
    address _escrow,
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;


  function applyCreditToJob(
    address _escrow,
    address _liquidity,
    address _job
  ) external;


  function unbondLiquidityFromJob(
    address _escrow,
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;


  function removeLiquidityFromJob(
    address _escrow,
    address _liquidity,
    address _job
  ) external returns (uint256 _amount);


  function setPendingGovernorOnEscrow(address _escrow, address _pendingGovernor) external;


  function acceptGovernorOnEscrow(address _escrow) external;


  function sendDustOnEscrow(
    address _escrow,
    address _to,
    address _token,
    uint256 _amount
  ) external;

}

abstract contract Keep3rLiquidityManagerEscrowsHandler is IKeep3rLiquidityManagerEscrowsHandler {
  address public immutable override escrow1;
  address public immutable override escrow2;

  constructor(address _escrow1, address _escrow2) public {
    require(_escrow1 != address(0), 'Keep3rLiquidityManager::zero-address');
    require(_escrow2 != address(0), 'Keep3rLiquidityManager::zero-address');
    escrow1 = _escrow1;
    escrow2 = _escrow2;
  }

  modifier _assertIsValidEscrow(address _escrow) {
    require(isValidEscrow(_escrow), 'Keep3rLiquidityManager::invalid-escrow');
    _;
  }

  function isValidEscrow(address _escrow) public view override returns (bool) {
    return _escrow == escrow1 || _escrow == escrow2;
  }

  function _addLiquidityToJob(
    address _escrow,
    address _liquidity,
    address _job,
    uint256 _amount
  ) internal _assertIsValidEscrow(_escrow) {
    IKeep3rEscrow(_escrow).addLiquidityToJob(_liquidity, _job, _amount);
  }

  function _applyCreditToJob(
    address _escrow,
    address _liquidity,
    address _job
  ) internal _assertIsValidEscrow(_escrow) {
    IKeep3rEscrow(_escrow).applyCreditToJob(address(_escrow), _liquidity, _job);
  }

  function _unbondLiquidityFromJob(
    address _escrow,
    address _liquidity,
    address _job,
    uint256 _amount
  ) internal _assertIsValidEscrow(_escrow) {
    IKeep3rEscrow(_escrow).unbondLiquidityFromJob(_liquidity, _job, _amount);
  }

  function _removeLiquidityFromJob(
    address _escrow,
    address _liquidity,
    address _job
  ) internal _assertIsValidEscrow(_escrow) returns (uint256 _amount) {
    return IKeep3rEscrow(_escrow).removeLiquidityFromJob(_liquidity, _job);
  }

  function _setPendingGovernorOnEscrow(address _escrow, address _pendingGovernor) internal _assertIsValidEscrow(_escrow) {
    IGovernable(_escrow).setPendingGovernor(_pendingGovernor);
  }

  function _acceptGovernorOnEscrow(address _escrow) internal _assertIsValidEscrow(_escrow) {
    IGovernable(_escrow).acceptGovernor();
  }

  function _sendDustOnEscrow(
    address _escrow,
    address _to,
    address _token,
    uint256 _amount
  ) internal _assertIsValidEscrow(_escrow) {
    ICollectableDust(_escrow).sendDust(_to, _token, _amount);
  }
}// MIT

pragma solidity 0.6.12;

interface IKeep3rLiquidityManagerJobHandler {

  function job() external view returns (address _job);


  function setJob(address _job) external;

}

abstract contract Keep3rLiquidityManagerJobHandler is IKeep3rLiquidityManagerJobHandler {
  address public override job;

  function _setJob(address _job) internal {
    job = _job;
  }

  modifier onlyJob() {
    require(msg.sender == job, 'Keep3rLiquidityManagerJobHandler::unauthorized-job');
    _;
  }
}// MIT

pragma solidity 0.6.12;


interface IKeep3rLiquidityManagerJobsLiquidityHandler {

  event JobAdded(address _job);

  event JobRemoved(address _job);

  function jobs() external view returns (address[] memory _jobsList);


  function jobLiquidities(address _job) external view returns (address[] memory _liquiditiesList);


  function jobLiquidityDesiredAmount(address _job, address _liquidity) external view returns (uint256 _amount);

}

abstract contract Keep3rLiquidityManagerJobsLiquidityHandler is IKeep3rLiquidityManagerJobsLiquidityHandler {
  using SafeMath for uint256;
  using EnumerableSet for EnumerableSet.AddressSet;

  EnumerableSet.AddressSet internal _jobs;
  mapping(address => EnumerableSet.AddressSet) internal _jobLiquidities;
  mapping(address => mapping(address => uint256)) public override jobLiquidityDesiredAmount;

  function jobs() public view override returns (address[] memory _jobsList) {
    _jobsList = new address[](_jobs.length());
    for (uint256 i; i < _jobs.length(); i++) {
      _jobsList[i] = _jobs.at(i);
    }
  }

  function jobLiquidities(address _job) public view override returns (address[] memory _liquiditiesList) {
    _liquiditiesList = new address[](_jobLiquidities[_job].length());
    for (uint256 i; i < _jobLiquidities[_job].length(); i++) {
      _liquiditiesList[i] = _jobLiquidities[_job].at(i);
    }
  }

  function _addJob(address _job) internal {
    if (_jobs.add(_job)) emit JobAdded(_job);
  }

  function _removeJob(address _job) internal {
    if (_jobs.remove(_job)) emit JobRemoved(_job);
  }

  function _addLPToJob(address _job, address _liquidity) internal {
    _jobLiquidities[_job].add(_liquidity);
    if (_jobLiquidities[_job].length() == 1) _addJob(_job);
  }

  function _removeLPFromJob(address _job, address _liquidity) internal {
    _jobLiquidities[_job].remove(_liquidity);
    if (_jobLiquidities[_job].length() == 0) _removeJob(_job);
  }
}// MIT

pragma solidity 0.6.12;


interface IKeep3rLiquidityManagerParameters {

  event Keep3rV1Set(address _keep3rV1);

  function keep3rV1() external view returns (address);

}

abstract contract Keep3rLiquidityManagerParameters is IKeep3rLiquidityManagerParameters {
  address public override keep3rV1;

  constructor(address _keep3rV1) public {
    _setKeep3rV1(_keep3rV1);
  }

  function _setKeep3rV1(address _keep3rV1) internal {
    require(_keep3rV1 != address(0), 'Keep3rLiquidityManager::zero-address');
    keep3rV1 = _keep3rV1;
    emit Keep3rV1Set(_keep3rV1);
  }
}// MIT

pragma solidity 0.6.12;



interface IKeep3rLiquidityManagerUserLiquidityHandler {

  event LiquidityFeeSet(uint256 _liquidityFee);

  event FeeReceiverSet(address _feeReceiver);

  event DepositedLiquidity(address indexed _depositor, address _recipient, address _lp, uint256 _amount, uint256 _fee);

  event WithdrewLiquidity(address indexed _withdrawer, address _recipient, address _lp, uint256 _amount);

  function liquidityFee() external view returns (uint256 _liquidityFee);


  function feeReceiver() external view returns (address _feeReceiver);


  function liquidityTotalAmount(address _liquidity) external view returns (uint256 _amount);


  function userLiquidityTotalAmount(address _user, address _lp) external view returns (uint256 _amount);


  function userLiquidityIdleAmount(address _user, address _lp) external view returns (uint256 _amount);


  function depositLiquidity(address _lp, uint256 _amount) external;


  function depositLiquidityTo(
    address _liquidityRecipient,
    address _lp,
    uint256 _amount
  ) external;


  function withdrawLiquidity(address _lp, uint256 _amount) external;


  function withdrawLiquidityTo(
    address _liquidityRecipient,
    address _lp,
    uint256 _amount
  ) external;


  function setLiquidityFee(uint256 _liquidityFee) external;


  function setFeeReceiver(address _feeReceiver) external;

}

abstract contract Keep3rLiquidityManagerUserLiquidityHandler is Keep3rLiquidityManagerParameters, IKeep3rLiquidityManagerUserLiquidityHandler {
  using SafeMath for uint256;
  using SafeERC20 for IERC20;

  uint256 public constant PRECISION = 1_000;
  uint256 public constant MAX_LIQUIDITY_FEE = PRECISION / 10; // 10%
  uint256 public override liquidityFee;
  address public override feeReceiver;
  mapping(address => uint256) public override liquidityTotalAmount;
  mapping(address => mapping(address => uint256)) public override userLiquidityTotalAmount;
  mapping(address => mapping(address => uint256)) public override userLiquidityIdleAmount;

  constructor() public {
    _setFeeReceiver(msg.sender);
  }

  function depositLiquidity(address _lp, uint256 _amount) public virtual override {
    depositLiquidityTo(msg.sender, _lp, _amount);
  }

  function depositLiquidityTo(
    address _liquidityRecipient,
    address _lp,
    uint256 _amount
  ) public virtual override {
    _depositLiquidity(msg.sender, _liquidityRecipient, _lp, _amount);
  }

  function withdrawLiquidity(address _lp, uint256 _amount) public virtual override {
    withdrawLiquidityTo(msg.sender, _lp, _amount);
  }

  function withdrawLiquidityTo(
    address _liquidityRecipient,
    address _lp,
    uint256 _amount
  ) public virtual override {
    _withdrawLiquidity(msg.sender, _liquidityRecipient, _lp, _amount);
  }

  function _depositLiquidity(
    address _liquidityDepositor,
    address _liquidityRecipient,
    address _lp,
    uint256 _amount
  ) internal {
    require(IKeep3rV1(keep3rV1).liquidityAccepted(_lp), 'Keep3rLiquidityManager::liquidity-not-accepted-on-keep3r');
    IERC20(_lp).safeTransferFrom(_liquidityDepositor, address(this), _amount);
    uint256 _fee = _amount.mul(liquidityFee).div(PRECISION);
    if (_fee > 0) IERC20(_lp).safeTransfer(feeReceiver, _fee);
    _addLiquidity(_liquidityRecipient, _lp, _amount.sub(_fee));
    emit DepositedLiquidity(_liquidityDepositor, _liquidityRecipient, _lp, _amount.sub(_fee), _fee);
  }

  function _withdrawLiquidity(
    address _liquidityWithdrawer,
    address _liquidityRecipient,
    address _lp,
    uint256 _amount
  ) internal {
    require(userLiquidityIdleAmount[_liquidityWithdrawer][_lp] >= _amount, 'Keep3rLiquidityManager::user-insufficient-idle-balance');
    _subLiquidity(_liquidityWithdrawer, _lp, _amount);
    IERC20(_lp).safeTransfer(_liquidityRecipient, _amount);
    emit WithdrewLiquidity(_liquidityWithdrawer, _liquidityRecipient, _lp, _amount);
  }

  function _addLiquidity(
    address _user,
    address _lp,
    uint256 _amount
  ) internal {
    require(_user != address(0), 'Keep3rLiquidityManager::zero-user');
    require(_amount > 0, 'Keep3rLiquidityManager::amount-bigger-than-zero');
    liquidityTotalAmount[_lp] = liquidityTotalAmount[_lp].add(_amount);
    userLiquidityTotalAmount[_user][_lp] = userLiquidityTotalAmount[_user][_lp].add(_amount);
    userLiquidityIdleAmount[_user][_lp] = userLiquidityIdleAmount[_user][_lp].add(_amount);
  }

  function _subLiquidity(
    address _user,
    address _lp,
    uint256 _amount
  ) internal {
    require(userLiquidityTotalAmount[_user][_lp] >= _amount, 'Keep3rLiquidityManager::amount-bigger-than-total');
    liquidityTotalAmount[_lp] = liquidityTotalAmount[_lp].sub(_amount);
    userLiquidityTotalAmount[_user][_lp] = userLiquidityTotalAmount[_user][_lp].sub(_amount);
    userLiquidityIdleAmount[_user][_lp] = userLiquidityIdleAmount[_user][_lp].sub(_amount);
  }

  function _setLiquidityFee(uint256 _liquidityFee) internal {
    require(_liquidityFee <= MAX_LIQUIDITY_FEE, 'Keep3rLiquidityManager::fee-exceeds-max-liquidity-fee');
    liquidityFee = _liquidityFee;
    emit LiquidityFeeSet(_liquidityFee);
  }

  function _setFeeReceiver(address _feeReceiver) internal {
    require(_feeReceiver != address(0), 'Keep3rLiquidityManager::zero-address');
    feeReceiver = _feeReceiver;
    emit FeeReceiverSet(_feeReceiver);
  }
}// MIT

pragma solidity 0.6.12;



interface IKeep3rLiquidityManagerUserJobsLiquidityHandler {

  event LiquidityMinSet(address _liquidity, uint256 _minAmount);
  event LiquidityOfJobSet(address indexed _user, address _liquidity, address _job, uint256 _amount);
  event IdleLiquidityRemovedFromJob(address indexed _user, address _liquidity, address _job, uint256 _amount);

  function liquidityMinAmount(address _liquidity) external view returns (uint256 _minAmount);


  function userJobLiquidityAmount(
    address _user,
    address _job,
    address _liquidity
  ) external view returns (uint256 _amount);


  function userJobLiquidityLockedAmount(
    address _user,
    address _job,
    address _liquidity
  ) external view returns (uint256 _amount);


  function userJobCycle(address _user, address _job) external view returns (uint256 _cycle);


  function jobCycle(address _job) external view returns (uint256 _cycle);


  function setMinAmount(address _liquidity, uint256 _minAmount) external;


  function setJobLiquidityAmount(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;


  function forceRemoveLiquidityOfUserFromJob(
    address _user,
    address _liquidity,
    address _job
  ) external;


  function removeIdleLiquidityFromJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external;

}

abstract contract Keep3rLiquidityManagerUserJobsLiquidityHandler is
  Keep3rLiquidityManagerEscrowsHandler,
  Keep3rLiquidityManagerUserLiquidityHandler,
  Keep3rLiquidityManagerJobsLiquidityHandler,
  IKeep3rLiquidityManagerUserJobsLiquidityHandler
{
  using SafeMath for uint256;

  mapping(address => uint256) public override liquidityMinAmount;
  mapping(address => mapping(address => mapping(address => uint256))) public override userJobLiquidityAmount;
  mapping(address => mapping(address => mapping(address => uint256))) public override userJobLiquidityLockedAmount;
  mapping(address => mapping(address => uint256)) public override userJobCycle;
  mapping(address => uint256) public override jobCycle;

  function _setMinAmount(address _liquidity, uint256 _minAmount) internal {
    liquidityMinAmount[_liquidity] = _minAmount;
    emit LiquidityMinSet(_liquidity, _minAmount);
  }

  function setJobLiquidityAmount(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external virtual override {
    _setLiquidityToJobOfUser(msg.sender, _liquidity, _job, _amount);
  }

  function removeIdleLiquidityFromJob(
    address _liquidity,
    address _job,
    uint256 _amount
  ) external virtual override {
    _removeIdleLiquidityOfUserFromJob(msg.sender, _liquidity, _job, _amount);
  }

  function _setLiquidityToJobOfUser(
    address _user,
    address _liquidity,
    address _job,
    uint256 _amount
  ) internal {
    _amount = _amount.div(2).mul(2); // removes potential decimal dust

    require(_amount != userJobLiquidityAmount[_user][_job][_liquidity], 'Keep3rLiquidityManager::same-liquidity-amount');

    userJobCycle[_user][_job] = jobCycle[_job];

    if (_amount > userJobLiquidityLockedAmount[_user][_job][_liquidity]) {
      _addLiquidityOfUserToJob(_user, _liquidity, _job, _amount.sub(userJobLiquidityAmount[_user][_job][_liquidity]));
    } else {
      _subLiquidityOfUserFromJob(_user, _liquidity, _job, userJobLiquidityAmount[_user][_job][_liquidity].sub(_amount));
    }
    emit LiquidityOfJobSet(_user, _liquidity, _job, _amount);
  }

  function _forceRemoveLiquidityOfUserFromJob(
    address _user,
    address _liquidity,
    address _job
  ) internal {
    require(!IKeep3rV1(keep3rV1).jobs(_job), 'Keep3rLiquidityManager::force-remove-liquidity:job-on-keep3r');
    _setLiquidityToJobOfUser(_user, _liquidity, _job, 0);
  }

  function _addLiquidityOfUserToJob(
    address _user,
    address _liquidity,
    address _job,
    uint256 _amount
  ) internal {
    require(IKeep3rV1(keep3rV1).jobs(_job), 'Keep3rLiquidityManager::job-not-on-keep3r');
    require(_amount > 0, 'Keep3rLiquidityManager::zero-amount');
    require(_amount <= userLiquidityIdleAmount[_user][_liquidity], 'Keep3rLiquidityManager::no-idle-liquidity-available');
    require(liquidityMinAmount[_liquidity] != 0, 'Keep3rLiquidityManager::liquidity-min-not-set');
    require(
      userJobLiquidityLockedAmount[_user][_job][_liquidity].add(_amount) >= liquidityMinAmount[_liquidity],
      'Keep3rLiquidityManager::locked-amount-not-enough'
    );
    userJobLiquidityAmount[_user][_job][_liquidity] = userJobLiquidityAmount[_user][_job][_liquidity].add(_amount);
    userJobLiquidityLockedAmount[_user][_job][_liquidity] = userJobLiquidityLockedAmount[_user][_job][_liquidity].add(_amount);
    userLiquidityIdleAmount[_user][_liquidity] = userLiquidityIdleAmount[_user][_liquidity].sub(_amount);
    if (jobLiquidityDesiredAmount[_job][_liquidity] == 0) _addLPToJob(_job, _liquidity);
    jobLiquidityDesiredAmount[_job][_liquidity] = jobLiquidityDesiredAmount[_job][_liquidity].add(_amount);
  }

  function _subLiquidityOfUserFromJob(
    address _user,
    address _liquidity,
    address _job,
    uint256 _amount
  ) internal {
    require(_amount <= userJobLiquidityAmount[_user][_job][_liquidity], 'Keep3rLiquidityManager::not-enough-lp-in-job');
    require(
      userJobLiquidityAmount[_user][_job][_liquidity].sub(_amount) == 0 ||
        userJobLiquidityAmount[_user][_job][_liquidity].sub(_amount) >= liquidityMinAmount[_liquidity],
      'Keep3rLiquidityManager::locked-amount-not-enough'
    );

    userJobLiquidityAmount[_user][_job][_liquidity] = userJobLiquidityAmount[_user][_job][_liquidity].sub(_amount);
    jobLiquidityDesiredAmount[_job][_liquidity] = jobLiquidityDesiredAmount[_job][_liquidity].sub(_amount);
  }

  function _removeIdleLiquidityOfUserFromJob(
    address _user,
    address _liquidity,
    address _job,
    uint256 _amount
  ) internal {
    require(_amount > 0, 'Keep3rLiquidityManager::zero-amount');
    require(
      jobCycle[_job] >= userJobCycle[_user][_job].add(2) || // wait for full cycle
        _jobLiquidities[_job].length() == 0, // or removes if 1 cycle was enough to remove all liquidity
      'Keep3rLiquidityManager::liquidity-still-locked'
    );

    _amount = _amount.div(2).mul(2);

    uint256 _unlockedIdleAvailable = userJobLiquidityLockedAmount[_user][_job][_liquidity].sub(userJobLiquidityAmount[_user][_job][_liquidity]);
    require(_amount <= _unlockedIdleAvailable, 'Keep3rLiquidityManager::amount-bigger-than-idle-available');

    userJobLiquidityLockedAmount[_user][_job][_liquidity] = userJobLiquidityLockedAmount[_user][_job][_liquidity].sub(_amount);
    userLiquidityIdleAmount[_user][_liquidity] = userLiquidityIdleAmount[_user][_liquidity].add(_amount);

    emit IdleLiquidityRemovedFromJob(_user, _liquidity, _job, _amount);
  }
}// MIT

pragma solidity 0.6.12;



interface IKeep3rLiquidityManagerWork {

  enum Actions { None, AddLiquidityToJob, ApplyCreditToJob, UnbondLiquidityFromJob, RemoveLiquidityFromJob }
  enum Steps { NotStarted, LiquidityAdded, CreditApplied, UnbondingLiquidity }

  event Worked(address indexed _job);
  event ForceWorked(address indexed _job);

  function getNextAction(address _job) external view returns (address _escrow, Actions _action);


  function workable(address _job) external view returns (bool);


  function jobEscrowStep(address _job, address _escrow) external view returns (Steps _step);


  function jobEscrowTimestamp(address _job, address _escrow) external view returns (uint256 _timestamp);


  function work(address _job) external;


  function forceWork(address _job) external;

}

abstract contract Keep3rLiquidityManagerWork is Keep3rLiquidityManagerUserJobsLiquidityHandler, IKeep3rLiquidityManagerWork {
  mapping(address => mapping(address => Steps)) public override jobEscrowStep;
  mapping(address => mapping(address => uint256)) public override jobEscrowTimestamp;

  function getNextAction(address _job) public view override returns (address _escrow, Actions _action) {
    require(_jobLiquidities[_job].length() > 0, 'Keep3rLiquidityManager::getNextAction:job-has-no-liquidity');

    Steps _escrow1Step = jobEscrowStep[_job][escrow1];
    Steps _escrow2Step = jobEscrowStep[_job][escrow2];

    if (_escrow1Step == Steps.NotStarted && _escrow2Step == Steps.NotStarted) {
      return (escrow1, Actions.AddLiquidityToJob);
    }

    if ((_escrow1Step == Steps.NotStarted || _escrow2Step == Steps.NotStarted) && _jobHasDesiredLiquidities(_job)) {
      _escrow = _escrow1Step == Steps.NotStarted ? escrow1 : escrow2;
      address _otherEscrow = _escrow == escrow1 ? escrow2 : escrow1;

      if (jobEscrowStep[_job][_otherEscrow] == Steps.CreditApplied) {
        if (block.timestamp > jobEscrowTimestamp[_job][_otherEscrow].add(14 days)) {
          return (_escrow, Actions.AddLiquidityToJob);
        }
      }

      if (jobEscrowStep[_job][_otherEscrow] == Steps.UnbondingLiquidity) {
        return (_escrow, Actions.AddLiquidityToJob);
      }
    }

    _action = _getNextActionOnStep(escrow1, _escrow1Step, _escrow2Step, _job);
    if (_action != Actions.None) return (escrow1, _action);


    _action = _getNextActionOnStep(escrow2, _escrow2Step, _escrow1Step, _job);
    if (_action != Actions.None) return (escrow2, _action);

    return (address(0), Actions.None);
  }

  function _jobHasDesiredLiquidities(address _job) internal view returns (bool) {
    for (uint256 i = 0; i < _jobLiquidities[_job].length(); i++) {
      if (jobLiquidityDesiredAmount[_job][_jobLiquidities[_job].at(i)] > 0) {
        return true;
      }
    }
    return false;
  }

  function _getNextActionOnStep(
    address _escrow,
    Steps _escrowStep,
    Steps _otherEscrowStep,
    address _job
  ) internal view returns (Actions) {
    if (_escrowStep == Steps.LiquidityAdded) {
      if (block.timestamp > jobEscrowTimestamp[_job][_escrow].add(3 days)) {
        return Actions.ApplyCreditToJob;
      }
      return Actions.None;
    }

    if (_escrowStep == Steps.CreditApplied) {
      if (_otherEscrowStep == Steps.NotStarted && block.timestamp > jobEscrowTimestamp[_job][_escrow].add(17 days)) {
        return Actions.UnbondLiquidityFromJob;
      }
      return Actions.None;
    }

    if (_escrowStep == Steps.UnbondingLiquidity) {
      if (block.timestamp > jobEscrowTimestamp[_job][_escrow].add(14 days)) {
        return Actions.RemoveLiquidityFromJob;
      }
      return Actions.None;
    }

    return Actions.None;
  }

  function workable(address _job) public view override returns (bool) {
    (, Actions _action) = getNextAction(_job);
    return _workable(_action);
  }

  function _workable(Actions _action) internal pure returns (bool) {
    return (_action != Actions.None);
  }

  function _work(
    address _escrow,
    Actions _action,
    address _job
  ) internal {
    if (_action == Actions.AddLiquidityToJob) {
      for (uint256 i = 0; i < _jobLiquidities[_job].length(); i++) {
        address _liquidity = _jobLiquidities[_job].at(i);
        uint256 _escrowAmount = jobLiquidityDesiredAmount[_job][_liquidity].div(2);
        IERC20(_liquidity).approve(_escrow, _escrowAmount);
        IKeep3rEscrow(_escrow).deposit(_liquidity, _escrowAmount);
        _addLiquidityToJob(_escrow, _liquidity, _job, _escrowAmount);
        jobEscrowStep[_job][_escrow] = Steps.LiquidityAdded;
        jobEscrowTimestamp[_job][_escrow] = block.timestamp;
      }

    } else if (_action == Actions.ApplyCreditToJob) {
      address _otherEscrow = _escrow == escrow1 ? escrow2 : escrow1;

      for (uint256 i = 0; i < _jobLiquidities[_job].length(); i++) {
        address _liquidity = _jobLiquidities[_job].at(i);
        uint256 _liquidityProvided = IKeep3rV1(keep3rV1).liquidityProvided(_otherEscrow, _liquidity, _job);
        if (_liquidityProvided > 0) {
          _unbondLiquidityFromJob(_otherEscrow, _liquidity, _job, _liquidityProvided);
          jobEscrowStep[_job][_otherEscrow] = Steps.UnbondingLiquidity;
          jobEscrowTimestamp[_job][_otherEscrow] = block.timestamp;
        }
      }
      for (uint256 i = 0; i < _jobLiquidities[_job].length(); i++) {
        _applyCreditToJob(_escrow, _jobLiquidities[_job].at(i), _job);
        jobEscrowStep[_job][_escrow] = Steps.CreditApplied;
        jobEscrowTimestamp[_job][_escrow] = block.timestamp;
      }

    } else if (_action == Actions.UnbondLiquidityFromJob) {
      for (uint256 i = 0; i < _jobLiquidities[_job].length(); i++) {
        address _liquidity = _jobLiquidities[_job].at(i);

        uint256 _liquidityProvided = IKeep3rV1(keep3rV1).liquidityProvided(_escrow, _liquidity, _job);
        if (_liquidityProvided > 0) {
          _unbondLiquidityFromJob(_escrow, _liquidity, _job, _liquidityProvided);
          jobEscrowStep[_job][_escrow] = Steps.UnbondingLiquidity;
          jobEscrowTimestamp[_job][_escrow] = block.timestamp;
        }
      }

    } else if (_action == Actions.RemoveLiquidityFromJob) {
      address[] memory _jobLiquiditiesClone = new address[](_jobLiquidities[_job].length());
      for (uint256 i = 0; i < _jobLiquidities[_job].length(); i++) {
        _jobLiquiditiesClone[i] = _jobLiquidities[_job].at(i);
      }

      for (uint256 i = 0; i < _jobLiquiditiesClone.length; i++) {
        address _liquidity = _jobLiquiditiesClone[i];
        uint256 _amount = _removeLiquidityFromJob(_escrow, _liquidity, _job);
        jobEscrowStep[_job][_escrow] = Steps.NotStarted;
        jobEscrowTimestamp[_job][_escrow] = block.timestamp;

        jobCycle[_job] = jobCycle[_job].add(1);

        uint256 _escrowAmount = jobLiquidityDesiredAmount[_job][_liquidity].div(2);
        if (_amount > _escrowAmount) {
          IKeep3rEscrow(_escrow).withdraw(_liquidity, _amount.sub(_escrowAmount));
        } else if (_amount < _escrowAmount) {
          IERC20(_liquidity).approve(_escrow, _escrowAmount.sub(_amount));
          IKeep3rEscrow(_escrow).deposit(_liquidity, _escrowAmount.sub(_amount));
        }

        if (_escrowAmount > 0) {
          _addLiquidityToJob(_escrow, _liquidity, _job, _escrowAmount);
          jobEscrowStep[_job][_escrow] = Steps.LiquidityAdded;
          jobEscrowTimestamp[_job][_escrow] = block.timestamp;
        }

        uint256 _liquidityInUse =
          IKeep3rEscrow(escrow1).liquidityTotalAmount(_liquidity).add(IKeep3rEscrow(escrow2).liquidityTotalAmount(_liquidity));
        if (_liquidityInUse == 0) _removeLPFromJob(_job, _liquidity);
      }
    }
  }
}// MIT

pragma solidity 0.6.12;



contract Keep3rLiquidityManager is UtilsReady, Keep3rLiquidityManagerWork, Keep3rLiquidityManagerJobHandler {

  constructor(
    address _keep3rV1,
    address _escrow1,
    address _escrow2
  ) public UtilsReady() Keep3rLiquidityManagerParameters(_keep3rV1) Keep3rLiquidityManagerEscrowsHandler(_escrow1, _escrow2) {}

  function setLiquidityFee(uint256 _liquidityFee) external override onlyGovernor {

    _setLiquidityFee(_liquidityFee);
  }

  function setFeeReceiver(address _feeReceiver) external override onlyGovernor {

    _setFeeReceiver(_feeReceiver);
  }

  function setMinAmount(address _liquidity, uint256 _minAmount) external override onlyGovernor {

    _setMinAmount(_liquidity, _minAmount);
  }

  function forceRemoveLiquidityOfUserFromJob(
    address _user,
    address _liquidity,
    address _job
  ) external override onlyGovernor {

    _forceRemoveLiquidityOfUserFromJob(_user, _liquidity, _job);
  }

  function work(address _job) external override onlyJob {

    (address _escrow, Actions _action) = getNextAction(_job);
    require(_workable(_action), 'Keep3rLiquidityManager::work:not-workable');

    _work(_escrow, _action, _job);

    emit Worked(_job);
  }

  function forceWork(address _job) external override onlyGovernor {

    (address _escrow, Actions _action) = getNextAction(_job);
    _work(_escrow, _action, _job);
    emit ForceWorked(_job);
  }

  function setJob(address _job) external override onlyGovernor {

    _setJob(_job);
  }

  function sendDust(
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {

    require(liquidityTotalAmount[_token] == 0, 'Keep3rLiquidityManager::sendDust:token-is-liquidity');
    _sendDust(_to, _token, _amount);
  }

  function addLiquidityToJob(
    address _escrow,
    address _liquidity,
    address _job,
    uint256 _amount
  ) external override onlyGovernor {

    _addLiquidityToJob(_escrow, _liquidity, _job, _amount);
  }

  function applyCreditToJob(
    address _escrow,
    address _liquidity,
    address _job
  ) external override onlyGovernor {

    _applyCreditToJob(_escrow, _liquidity, _job);
  }

  function unbondLiquidityFromJob(
    address _escrow,
    address _liquidity,
    address _job,
    uint256 _amount
  ) external override onlyGovernor {

    _unbondLiquidityFromJob(_escrow, _liquidity, _job, _amount);
  }

  function removeLiquidityFromJob(
    address _escrow,
    address _liquidity,
    address _job
  ) external override onlyGovernor returns (uint256 _amount) {

    return _removeLiquidityFromJob(_escrow, _liquidity, _job);
  }

  function setPendingGovernorOnEscrow(address _escrow, address _pendingGovernor) external override onlyGovernor {

    _setPendingGovernorOnEscrow(_escrow, _pendingGovernor);
  }

  function acceptGovernorOnEscrow(address _escrow) external override onlyGovernor {

    _acceptGovernorOnEscrow(_escrow);
  }

  function sendDustOnEscrow(
    address _escrow,
    address _to,
    address _token,
    uint256 _amount
  ) external override onlyGovernor {

    _sendDustOnEscrow(_escrow, _to, _token, _amount);
  }
}