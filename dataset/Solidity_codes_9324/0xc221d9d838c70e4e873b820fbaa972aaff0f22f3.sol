
pragma solidity 0.7.6;

contract KeeperBase {


  function preventExecution()
    internal
    view
  {

    require(tx.origin == address(0), "only for simulated backend");
  }

  modifier cannotExecute()
  {

    preventExecution();
    _;
  }

}// MIT
pragma solidity >=0.6.0;

interface AggregatorV3Interface {


  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);


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


}// MIT
pragma solidity ^0.7.0;

interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);

}// MIT
pragma solidity ^0.7.0;

library SafeMathChainlink {

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
}// MIT

pragma solidity ^0.7.0;

contract Owned {


  address public owner;
  address private pendingOwner;

  event OwnershipTransferRequested(
    address indexed from,
    address indexed to
  );
  event OwnershipTransferred(
    address indexed from,
    address indexed to
  );

  constructor() {
    owner = msg.sender;
  }

  function transferOwnership(address _to)
    external
    onlyOwner()
  {

    pendingOwner = _to;

    emit OwnershipTransferRequested(owner, _to);
  }

  function acceptOwnership()
    external
  {

    require(msg.sender == pendingOwner, "Must be proposed owner");

    address oldOwner = owner;
    owner = msg.sender;
    pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  modifier onlyOwner() {

    require(msg.sender == owner, "Only callable by owner");
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


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SignedSafeMath {

    int256 constant private _INT256_MIN = -2**255;

    function mul(int256 a, int256 b) internal pure returns (int256) {

        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == _INT256_MIN), "SignedSafeMath: multiplication overflow");

        int256 c = a * b;
        require(c / a == b, "SignedSafeMath: multiplication overflow");

        return c;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        require(b != 0, "SignedSafeMath: division by zero");
        require(!(b == -1 && a == _INT256_MIN), "SignedSafeMath: division overflow");

        int256 c = a / b;

        return c;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a), "SignedSafeMath: subtraction overflow");

        return c;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a), "SignedSafeMath: addition overflow");

        return c;
    }
}// MIT

pragma solidity ^0.7.0;

library SafeMath96 {

  function add(uint96 a, uint96 b) internal pure returns (uint96) {

    uint96 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint96 a, uint96 b) internal pure returns (uint96) {

    require(b <= a, "SafeMath: subtraction overflow");
    uint96 c = a - b;

    return c;
  }

  function mul(uint96 a, uint96 b) internal pure returns (uint96) {

    if (a == 0) {
      return 0;
    }

    uint96 c = a * b;
    require(c / a == b, "SafeMath: multiplication overflow");

    return c;
  }

  function div(uint96 a, uint96 b) internal pure returns (uint96) {

    require(b > 0, "SafeMath: division by zero");
    uint96 c = a / b;

    return c;
  }

  function mod(uint96 a, uint96 b) internal pure returns (uint96) {

    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}// MIT

pragma solidity 0.7.6;

interface KeeperCompatibleInterface {


  function checkUpkeep(
    bytes calldata checkData
  )
    external
    returns (
      bool upkeepNeeded,
      bytes memory performData
    );

  function performUpkeep(
    bytes calldata performData
  ) external;

}// MIT

pragma solidity 0.7.6;

interface KeeperRegistryBaseInterface {

  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData
  ) external returns (
      uint256 id
    );

  function performUpkeep(
    uint256 id,
    bytes calldata performData
  ) external returns (
      bool success
    );

  function cancelUpkeep(
    uint256 id
  ) external;

  function addFunds(
    uint256 id,
    uint96 amount
  ) external;


  function getUpkeep(uint256 id)
    external view returns (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint96 balance,
      address lastKeeper,
      address admin,
      uint64 maxValidBlocknumber
    );

  function getUpkeepCount()
    external view returns (uint256);

  function getCanceledUpkeepList()
    external view returns (uint256[] memory);

  function getKeeperList()
    external view returns (address[] memory);

  function getKeeperInfo(address query)
    external view returns (
      address payee,
      bool active,
      uint96 balance
    );

  function getConfig()
    external view returns (
      uint32 paymentPremiumPPB,
      uint24 checkFrequencyBlocks,
      uint32 checkGasLimit,
      uint24 stalenessSeconds,
      uint16 gasCeilingMultiplier,
      int256 fallbackGasPrice,
      int256 fallbackLinkPrice
    );

}

interface KeeperRegistryInterface is KeeperRegistryBaseInterface {

  function checkUpkeep(
    uint256 upkeepId,
    address from
  )
    external
    view
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      int256 gasWei,
      int256 linkEth
    );

}

interface KeeperRegistryExecutableInterface is KeeperRegistryBaseInterface {

  function checkUpkeep(
    uint256 upkeepId,
    address from
  )
    external
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      int256 gasWei,
      int256 linkEth
    );

}// MIT

pragma solidity 0.7.6;


contract KeeperRegistry is
  Owned,
  KeeperBase,
  ReentrancyGuard,
  Pausable,
  KeeperRegistryExecutableInterface
{

  using Address for address;
  using SafeMathChainlink for uint256;
  using SafeMath96 for uint96;
  using SignedSafeMath for int256;

  address constant private ZERO_ADDRESS = address(0);
  address constant private IGNORE_ADDRESS = 0xFFfFfFffFFfffFFfFFfFFFFFffFFFffffFfFFFfF;
  bytes4 constant private CHECK_SELECTOR = KeeperCompatibleInterface.checkUpkeep.selector;
  bytes4 constant private PERFORM_SELECTOR = KeeperCompatibleInterface.performUpkeep.selector;
  uint256 constant private CALL_GAS_MAX = 2_500_000;
  uint256 constant private CALL_GAS_MIN = 2_300;
  uint256 constant private CANCELATION_DELAY = 50;
  uint256 constant private CUSHION = 5_000;
  uint256 constant private REGISTRY_GAS_OVERHEAD = 80_000;
  uint256 constant private PPB_BASE = 1_000_000_000;
  uint64 constant private UINT64_MAX = 2**64 - 1;
  uint96 constant private LINK_TOTAL_SUPPLY = 1e27;

  uint256 private s_upkeepCount;
  uint256[] private s_canceledUpkeepList;
  address[] private s_keeperList;
  mapping(uint256 => Upkeep) private s_upkeep;
  mapping(address => KeeperInfo) private s_keeperInfo;
  mapping(address => address) private s_proposedPayee;
  mapping(uint256 => bytes) private s_checkData;
  Config private s_config;
  int256 private s_fallbackGasPrice;  // not in config object for gas savings
  int256 private s_fallbackLinkPrice; // not in config object for gas savings

  LinkTokenInterface public immutable LINK;
  AggregatorV3Interface public immutable LINK_ETH_FEED;
  AggregatorV3Interface public immutable FAST_GAS_FEED;

  address private s_registrar;

  struct Upkeep {
    address target;
    uint32 executeGas;
    uint96 balance;
    address admin;
    uint64 maxValidBlocknumber;
    address lastKeeper;
  }

  struct KeeperInfo {
    address payee;
    uint96 balance;
    bool active;
  }

  struct Config {
    uint32 paymentPremiumPPB;
    uint24 blockCountPerTurn;
    uint32 checkGasLimit;
    uint24 stalenessSeconds;
    uint16 gasCeilingMultiplier;
  }

  struct PerformParams {
    address from;
    uint256 id;
    bytes performData;
  }

  event UpkeepRegistered(
    uint256 indexed id,
    uint32 executeGas,
    address admin
  );
  event UpkeepPerformed(
    uint256 indexed id,
    bool indexed success,
    address indexed from,
    uint96 payment,
    bytes performData
  );
  event UpkeepCanceled(
    uint256 indexed id,
    uint64 indexed atBlockHeight
  );
  event FundsAdded(
    uint256 indexed id,
    address indexed from,
    uint96 amount
  );
  event FundsWithdrawn(
    uint256 indexed id,
    uint256 amount,
    address to
  );
  event ConfigSet(
    uint32 paymentPremiumPPB,
    uint24 blockCountPerTurn,
    uint32 checkGasLimit,
    uint24 stalenessSeconds,
    uint16 gasCeilingMultiplier,
    int256 fallbackGasPrice,
    int256 fallbackLinkPrice
  );
  event KeepersUpdated(
    address[] keepers,
    address[] payees
  );
  event PaymentWithdrawn(
    address indexed keeper,
    uint256 indexed amount,
    address indexed to,
    address payee
  );
  event PayeeshipTransferRequested(
    address indexed keeper,
    address indexed from,
    address indexed to
  );
  event PayeeshipTransferred(
    address indexed keeper,
    address indexed from,
    address indexed to
  );
  event RegistrarChanged(
    address indexed from,
    address indexed to
  );
  constructor(
    address link,
    address linkEthFeed,
    address fastGasFeed,
    uint32 paymentPremiumPPB,
    uint24 blockCountPerTurn,
    uint32 checkGasLimit,
    uint24 stalenessSeconds,
    uint16 gasCeilingMultiplier,
    int256 fallbackGasPrice,
    int256 fallbackLinkPrice
  ) {
    LINK = LinkTokenInterface(link);
    LINK_ETH_FEED = AggregatorV3Interface(linkEthFeed);
    FAST_GAS_FEED = AggregatorV3Interface(fastGasFeed);

    setConfig(
      paymentPremiumPPB,
      blockCountPerTurn,
      checkGasLimit,
      stalenessSeconds,
      gasCeilingMultiplier,
      fallbackGasPrice,
      fallbackLinkPrice
    );
  }



  function registerUpkeep(
    address target,
    uint32 gasLimit,
    address admin,
    bytes calldata checkData
  )
    external
    override
    onlyOwnerOrRegistrar()
    returns (
      uint256 id
    )
  {

    require(target.isContract(), "target is not a contract");
    require(gasLimit >= CALL_GAS_MIN, "min gas is 2300");
    require(gasLimit <= CALL_GAS_MAX, "max gas is 2500000");

    id = s_upkeepCount;
    s_upkeep[id] = Upkeep({
      target: target,
      executeGas: gasLimit,
      balance: 0,
      admin: admin,
      maxValidBlocknumber: UINT64_MAX,
      lastKeeper: address(0)
    });
    s_checkData[id] = checkData;
    s_upkeepCount++;

    emit UpkeepRegistered(id, gasLimit, admin);

    return id;
  }

  function checkUpkeep(
    uint256 id,
    address from
  )
    external
    override
    whenNotPaused()
    cannotExecute()
    returns (
      bytes memory performData,
      uint256 maxLinkPayment,
      uint256 gasLimit,
      int256 gasWei,
      int256 linkEth
    )
  {

    Upkeep storage upkeep = s_upkeep[id];
    gasLimit = upkeep.executeGas;
    (gasWei, linkEth) = getFeedData();
    maxLinkPayment = calculatePaymentAmount(gasLimit, gasWei, linkEth);
    require(maxLinkPayment < upkeep.balance, "insufficient funds");

    bytes memory callData = abi.encodeWithSelector(CHECK_SELECTOR, s_checkData[id]);
    (
      bool success,
      bytes memory result
    ) = upkeep.target.call{gas: s_config.checkGasLimit}(callData);
    require(success, "call to check target failed");

    (
      success,
      performData
    ) = abi.decode(result, (bool, bytes));
    require(success, "upkeep not needed");

    success = performUpkeepWithParams(PerformParams({
      from: from,
      id: id,
      performData: performData
    }));
    require(success, "call to perform upkeep failed");

    return (performData, maxLinkPayment, gasLimit, gasWei, linkEth);
  }

  function performUpkeep(
    uint256 id,
    bytes calldata performData
  )
    external
    override
    returns (
      bool success
    )
  {

    return performUpkeepWithParams(PerformParams({
      from: msg.sender,
      id: id,
      performData: performData
    }));
  }

  function cancelUpkeep(
    uint256 id
  )
    external
    override
  {

    uint64 maxValid = s_upkeep[id].maxValidBlocknumber;
    bool notCanceled = maxValid == UINT64_MAX;
    bool isOwner = msg.sender == owner;
    require(notCanceled || (isOwner && maxValid > block.number), "too late to cancel upkeep");
    require(isOwner|| msg.sender == s_upkeep[id].admin, "only owner or admin");

    uint256 height = block.number;
    if (!isOwner) {
      height = height.add(CANCELATION_DELAY);
    }
    s_upkeep[id].maxValidBlocknumber = uint64(height);
    if (notCanceled) {
      s_canceledUpkeepList.push(id);
    }

    emit UpkeepCanceled(id, uint64(height));
  }

  function addFunds(
    uint256 id,
    uint96 amount
  )
    external
    override
    validUpkeep(id)
  {

    s_upkeep[id].balance = s_upkeep[id].balance.add(amount);
    LINK.transferFrom(msg.sender, address(this), amount);
    emit FundsAdded(id, msg.sender, amount);
  }

  function onTokenTransfer(
    address sender,
    uint256 amount,
    bytes calldata data
  )
    external
  {

    require(msg.sender == address(LINK), "only callable through LINK");
    require(data.length == 32, "data must be 32 bytes");
    uint256 id = abi.decode(data, (uint256));
    validateUpkeep(id);

    s_upkeep[id].balance = s_upkeep[id].balance.add(uint96(amount));

    emit FundsAdded(id, sender, uint96(amount));
  }

  function withdrawFunds(
    uint256 id,
    address to
  )
    external
    validateRecipient(to)
  {

    require(s_upkeep[id].admin == msg.sender, "only callable by admin");
    require(s_upkeep[id].maxValidBlocknumber <= block.number, "upkeep must be canceled");

    uint256 amount = s_upkeep[id].balance;
    s_upkeep[id].balance = 0;
    emit FundsWithdrawn(id, amount, to);

    LINK.transfer(to, amount);
  }

  function recoverFunds()
    external
    onlyOwner()
  {

    uint96 locked = 0;
    uint256 max = s_upkeepCount;
    for (uint256 i = 0; i < max; i++) {
      locked = s_upkeep[i].balance.add(locked);
    }
    max = s_keeperList.length;
    for (uint256 i = 0; i < max; i++) {
      address addr = s_keeperList[i];
      locked = s_keeperInfo[addr].balance.add(locked);
    }

    uint256 total = LINK.balanceOf(address(this));
    LINK.transfer(msg.sender, total.sub(locked));
  }

  function withdrawPayment(
    address from,
    address to
  )
    external
    validateRecipient(to)
  {

    KeeperInfo memory keeper = s_keeperInfo[from];
    require(keeper.payee == msg.sender, "only callable by payee");

    s_keeperInfo[from].balance = 0;
    emit PaymentWithdrawn(from, keeper.balance, to, msg.sender);

    LINK.transfer(to, keeper.balance);
  }

  function transferPayeeship(
    address keeper,
    address proposed
  )
    external
  {

    require(s_keeperInfo[keeper].payee == msg.sender, "only callable by payee");
    require(proposed != msg.sender, "cannot transfer to self");

    if (s_proposedPayee[keeper] != proposed) {
      s_proposedPayee[keeper] = proposed;
      emit PayeeshipTransferRequested(keeper, msg.sender, proposed);
    }
  }

  function acceptPayeeship(
    address keeper
  )
    external
  {

    require(s_proposedPayee[keeper] == msg.sender, "only callable by proposed payee");
    address past = s_keeperInfo[keeper].payee;
    s_keeperInfo[keeper].payee = msg.sender;
    s_proposedPayee[keeper] = ZERO_ADDRESS;

    emit PayeeshipTransferred(keeper, past, msg.sender);
  }

  function pause()
    external
    onlyOwner()
  {

    _pause();
  }

  function unpause()
    external
    onlyOwner()
  {

    _unpause();
  }



  function setConfig(
    uint32 paymentPremiumPPB,
    uint24 blockCountPerTurn,
    uint32 checkGasLimit,
    uint24 stalenessSeconds,
    uint16 gasCeilingMultiplier,
    int256 fallbackGasPrice,
    int256 fallbackLinkPrice
  )
    onlyOwner()
    public
  {

    s_config = Config({
      paymentPremiumPPB: paymentPremiumPPB,
      blockCountPerTurn: blockCountPerTurn,
      checkGasLimit: checkGasLimit,
      stalenessSeconds: stalenessSeconds,
      gasCeilingMultiplier: gasCeilingMultiplier
    });
    s_fallbackGasPrice = fallbackGasPrice;
    s_fallbackLinkPrice = fallbackLinkPrice;

    emit ConfigSet(
      paymentPremiumPPB,
      blockCountPerTurn,
      checkGasLimit,
      stalenessSeconds,
      gasCeilingMultiplier,
      fallbackGasPrice,
      fallbackLinkPrice
    );
  }

  function setKeepers(
    address[] calldata keepers,
    address[] calldata payees
  )
    external
    onlyOwner()
  {

    for (uint256 i = 0; i < s_keeperList.length; i++) {
      address keeper = s_keeperList[i];
      s_keeperInfo[keeper].active = false;
    }
    for (uint256 i = 0; i < keepers.length; i++) {
      address keeper = keepers[i];
      KeeperInfo storage s_keeper = s_keeperInfo[keeper];
      address oldPayee = s_keeper.payee;
      address newPayee = payees[i];
      require(oldPayee == ZERO_ADDRESS || oldPayee == newPayee || newPayee == IGNORE_ADDRESS, "cannot change payee");
      require(!s_keeper.active, "cannot add keeper twice");
      s_keeper.active = true;
      if (newPayee != IGNORE_ADDRESS) {
        s_keeper.payee = newPayee;
      }
    }
    s_keeperList = keepers;
    emit KeepersUpdated(keepers, payees);
  }

  function setRegistrar(
    address registrar
  )
    external
    onlyOwnerOrRegistrar()
  {

    address previous = s_registrar;
    require(registrar != previous, "Same registrar");
    s_registrar = registrar;
    emit RegistrarChanged(previous, registrar);
  }


  function getUpkeep(
    uint256 id
  )
    external
    view
    override
    returns (
      address target,
      uint32 executeGas,
      bytes memory checkData,
      uint96 balance,
      address lastKeeper,
      address admin,
      uint64 maxValidBlocknumber
    )
  {

    Upkeep memory reg = s_upkeep[id];
    return (
      reg.target,
      reg.executeGas,
      s_checkData[id],
      reg.balance,
      reg.lastKeeper,
      reg.admin,
      reg.maxValidBlocknumber
    );
  }

  function getUpkeepCount()
    external
    view
    override
    returns (
      uint256
    )
  {

    return s_upkeepCount;
  }

  function getCanceledUpkeepList()
    external
    view
    override
    returns (
      uint256[] memory
    )
  {

    return s_canceledUpkeepList;
  }

  function getKeeperList()
    external
    view
    override
    returns (
      address[] memory
    )
  {

    return s_keeperList;
  }

  function getRegistrar()
    external
    view
    returns (
      address
    )
  {

    return s_registrar;
  }

  function getKeeperInfo(
    address query
  )
    external
    view
    override
    returns (
      address payee,
      bool active,
      uint96 balance
    )
  {

    KeeperInfo memory keeper = s_keeperInfo[query];
    return (keeper.payee, keeper.active, keeper.balance);
  }

  function getConfig()
    external
    view
    override
    returns (
      uint32 paymentPremiumPPB,
      uint24 blockCountPerTurn,
      uint32 checkGasLimit,
      uint24 stalenessSeconds,
      uint16 gasCeilingMultiplier,
      int256 fallbackGasPrice,
      int256 fallbackLinkPrice
    )
  {

    Config memory config = s_config;
    return (
      config.paymentPremiumPPB,
      config.blockCountPerTurn,
      config.checkGasLimit,
      config.stalenessSeconds,
      config.gasCeilingMultiplier,
      s_fallbackGasPrice,
      s_fallbackLinkPrice
    );
  }



  function getFeedData()
    private
    view
    returns (
      int256 gasWei,
      int256 linkEth
    )
  {

    uint32 stalenessSeconds = s_config.stalenessSeconds;
    bool staleFallback = stalenessSeconds > 0;
    uint256 timestamp;
    (,gasWei,,timestamp,) = FAST_GAS_FEED.latestRoundData();
    if (staleFallback && stalenessSeconds < block.timestamp - timestamp) {
      gasWei = s_fallbackGasPrice;
    }
    (,linkEth,,timestamp,) = LINK_ETH_FEED.latestRoundData();
    if (staleFallback && stalenessSeconds < block.timestamp - timestamp) {
      linkEth = s_fallbackLinkPrice;
    }
    return (gasWei, linkEth);
  }

  function calculatePaymentAmount(
    uint256 gasLimit,
    int256 gasWei,
    int256 linkEth
  )
    private
    view
    returns (
      uint96 payment
    )
  {

    uint256 weiForGas = uint256(gasWei).mul(gasLimit.add(REGISTRY_GAS_OVERHEAD));
    uint256 premium = PPB_BASE.add(s_config.paymentPremiumPPB);
    uint256 total = weiForGas.mul(1e9).mul(premium).div(uint256(linkEth));
    require(total <= LINK_TOTAL_SUPPLY, "payment greater than all LINK");
    return uint96(total); // LINK_TOTAL_SUPPLY < UINT96_MAX
  }

  function callWithExactGas(
    uint256 gasAmount,
    address target,
    bytes memory data
  )
    private
    returns (
      bool success
    )
  {

    assembly{
      let g := gas()
      if lt(g, CUSHION) { revert(0, 0) }
      g := sub(g, CUSHION)
      if iszero(gt(sub(g, div(g, 64)), gasAmount)) { revert(0, 0) }
      if iszero(extcodesize(target)) { revert(0, 0) }
      success := call(gasAmount, target, 0, add(data, 0x20), mload(data), 0, 0)
    }
    return success;
  }

  function performUpkeepWithParams(
    PerformParams memory params
  )
    private
    nonReentrant()
    validUpkeep(params.id)
    returns (
      bool success
    )
  {

    require(s_keeperInfo[params.from].active, "only active keepers");
    Upkeep memory upkeep = s_upkeep[params.id];
    uint256 gasLimit = upkeep.executeGas;
    (int256 gasWei, int256 linkEth) = getFeedData();
    gasWei = adjustGasPrice(gasWei);
    uint96 payment = calculatePaymentAmount(gasLimit, gasWei, linkEth);
    require(upkeep.balance >= payment, "insufficient payment");
    require(upkeep.lastKeeper != params.from, "keepers must take turns");

    uint256  gasUsed = gasleft();
    bytes memory callData = abi.encodeWithSelector(PERFORM_SELECTOR, params.performData);
    success = callWithExactGas(gasLimit, upkeep.target, callData);
    gasUsed = gasUsed - gasleft();

    payment = calculatePaymentAmount(gasUsed, gasWei, linkEth);
    upkeep.balance = upkeep.balance.sub(payment);
    upkeep.lastKeeper = params.from;
    s_upkeep[params.id] = upkeep;
    uint96 newBalance = s_keeperInfo[params.from].balance.add(payment);
    s_keeperInfo[params.from].balance = newBalance;

    emit UpkeepPerformed(
      params.id,
      success,
      params.from,
      payment,
      params.performData
    );
    return success;
  }

  function validateUpkeep(
    uint256 id
  )
    private
    view
  {

    require(s_upkeep[id].maxValidBlocknumber > block.number, "invalid upkeep id");
  }

  function adjustGasPrice(
    int256 gasWei
  )
    private
    view
    returns(int256 adjustedPrice)
  {

    adjustedPrice = int256(tx.gasprice);
    int256 ceiling = gasWei.mul(s_config.gasCeilingMultiplier);
    if(adjustedPrice > ceiling) {
      adjustedPrice = ceiling;
    }
  }



  modifier validUpkeep(
    uint256 id
  ) {

    validateUpkeep(id);
    _;
  }

  modifier validateRecipient(
    address to
  ) {

    require(to != address(0), "cannot send to zero address");
    _;
  }

  modifier onlyOwnerOrRegistrar() {

    require(msg.sender == owner || msg.sender == s_registrar, "Only callable by owner or registrar");
    _;
  }

}// MIT

pragma solidity 0.7.6;


contract UpkeepRegistrationRequests is Owned {

    bytes4 private constant REGISTER_REQUEST_SELECTOR = this.register.selector;

    uint256 private s_minLINKJuels;

    address public immutable LINK_ADDRESS;

    struct AutoApprovedConfig {
        bool enabled;
        uint16 allowedPerWindow;
        uint32 windowSizeInBlocks;
        uint64 windowStart;
        uint16 approvedInCurrentWindow;
    }

    AutoApprovedConfig private s_config;
    KeeperRegistryBaseInterface private s_keeperRegistry;

    event MinLINKChanged(uint256 from, uint256 to);

    event RegistrationRequested(
        bytes32 indexed hash,
        string name,
        bytes encryptedEmail,
        address indexed upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes checkData,
        uint8 indexed source
    );

    event RegistrationApproved(
        bytes32 indexed hash,
        string displayName,
        uint256 indexed upkeepId
    );

    constructor(
        address LINKAddress, 
        uint256 minimumLINKJuels
    ) 
    {
        LINK_ADDRESS = LINKAddress;
        s_minLINKJuels = minimumLINKJuels;
    }


    function register(
        string memory name,
        bytes calldata encryptedEmail,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        uint8 source
    ) 
      external 
      onlyLINK() 
    {

        bytes32 hash = keccak256(msg.data);

        emit RegistrationRequested(
            hash,
            name,
            encryptedEmail,
            upkeepContract,
            gasLimit,
            adminAddress,
            checkData,
            source
        );

        AutoApprovedConfig memory config = s_config;

        if (config.enabled) {
            _resetWindowIfRequired(config);
            if (config.approvedInCurrentWindow < config.allowedPerWindow) {
                config.approvedInCurrentWindow++;
                s_config = config;

                _approve(
                    name,
                    upkeepContract,
                    gasLimit,
                    adminAddress,
                    checkData,
                    hash
                );
            }
        }
    }

    function approve(
        string memory name,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        bytes32 hash
    ) 
      external 
      onlyOwner() 
    {

        _approve(
            name,
            upkeepContract,
            gasLimit,
            adminAddress,
            checkData,
            hash
        );    
    }

    function setMinLINKJuels(
        uint256 minimumLINKJuels
    ) 
      external 
      onlyOwner() 
    {

        emit MinLINKChanged(s_minLINKJuels, minimumLINKJuels);
        s_minLINKJuels = minimumLINKJuels;
    }

    function getMinLINKJuels() 
      external 
      view 
      returns (
          uint256
      )
    {

        return s_minLINKJuels;
    }

    function setRegistrationConfig(
        bool enabled,
        uint32 windowSizeInBlocks,
        uint16 allowedPerWindow,
        address keeperRegistry
    )
      external 
      onlyOwner() 
    {

        s_config = AutoApprovedConfig({
            enabled: enabled,
            allowedPerWindow: allowedPerWindow,
            windowSizeInBlocks: windowSizeInBlocks,
            windowStart: 0,
            approvedInCurrentWindow: 0
        });
        s_keeperRegistry = KeeperRegistryBaseInterface(keeperRegistry);
    }

    function getRegistrationConfig()
        external
        view
        returns (
            bool enabled,
            uint32 windowSizeInBlocks,
            uint16 allowedPerWindow,
            address keeperRegistry,
            uint64 windowStart,
            uint16 approvedInCurrentWindow
        )
    {

        AutoApprovedConfig memory config = s_config;
        return (
            config.enabled,
            config.windowSizeInBlocks,
            config.allowedPerWindow,
            address(s_keeperRegistry),
            config.windowStart,
            config.approvedInCurrentWindow
        );
    }

    function onTokenTransfer(
        address, /* sender */
        uint256 amount,
        bytes calldata data
    ) 
      external 
      onlyLINK() 
      permittedFunctionsForLINK(data) 
    {

        require(amount >= s_minLINKJuels, "Insufficient payment");
        (bool success, ) = address(this).delegatecall(data); // calls register
        require(success, "Unable to create request");
    }


    function _resetWindowIfRequired(
        AutoApprovedConfig memory config
    ) 
      private 
    {

        uint64 blocksPassed = uint64(block.number - config.windowStart);
        if (blocksPassed >= config.windowSizeInBlocks) {
            config.windowStart = uint64(block.number);
            config.approvedInCurrentWindow = 0;
            s_config = config;
        }
    }

    function _approve(
        string memory name,
        address upkeepContract,
        uint32 gasLimit,
        address adminAddress,
        bytes calldata checkData,
        bytes32 hash
    ) 
      private 
    {

        uint256 upkeepId =
            s_keeperRegistry.registerUpkeep(
                upkeepContract,
                gasLimit,
                adminAddress,
                checkData
            );

        emit RegistrationApproved(hash, name, upkeepId);
    }


    modifier onlyLINK() {

        require(msg.sender == LINK_ADDRESS, "Must use LINK token");
        _;
    }

    modifier permittedFunctionsForLINK(
        bytes memory _data
    ) 
    {

        bytes4 funcSelector;
        assembly {
            funcSelector := mload(add(_data, 32))
        }
        require(
            funcSelector == REGISTER_REQUEST_SELECTOR,
            "Must use whitelisted functions"
        );
        _;
    }
}// MIT

pragma solidity 0.7.6;


abstract contract KeeperCompatible is KeeperBase, KeeperCompatibleInterface {}// MIT

pragma solidity 0.7.6;


contract UpkeepReverter is KeeperCompatible {


  function checkUpkeep(bytes calldata data)
    public
    view
    override
    cannotExecute()
    returns (
      bool callable,
      bytes calldata executedata
    )
  {

    require(false, "!working");
    return (true, data);
  }

  function performUpkeep(
    bytes calldata
  )
    external
    pure
    override
  {

    require(false, "!working");
  }

}// MIT

pragma solidity 0.7.6;


contract UpkeepMock is KeeperCompatible {

  bool public canCheck;
  bool public canPerform;

  event UpkeepPerformedWith(bytes upkeepData);

  function setCanCheck(bool value)
    public
  {

    canCheck = value;
  }

  function setCanPerform(bool value)
    public
  {

    canPerform = value;
  }

  function checkUpkeep(bytes calldata data)
    external
    override
    cannotExecute()
    returns (
      bool callable,
      bytes calldata executedata
    )
  {

    bool couldCheck = canCheck;

    setCanCheck(false); // test that state modifcations don't stick

    return (couldCheck, data);
  }

  function performUpkeep(
    bytes calldata data
  )
    external
    override
  {

    require(canPerform, "Cannot perform");

    setCanPerform(false);

    emit UpkeepPerformedWith(data);
  }

}