pragma solidity ^0.8.0;

interface OwnableInterface {

  function owner() external returns (address);


  function transferOwnership(address recipient) external;


  function acceptOwnership() external;

}// MIT
pragma solidity ^0.8.0;


contract ConfirmedOwnerWithProposal is OwnableInterface {

  address private s_owner;
  address private s_pendingOwner;

  event OwnershipTransferRequested(address indexed from, address indexed to);
  event OwnershipTransferred(address indexed from, address indexed to);

  constructor(address newOwner, address pendingOwner) {
    require(newOwner != address(0), "Cannot set owner to zero");

    s_owner = newOwner;
    if (pendingOwner != address(0)) {
      _transferOwnership(pendingOwner);
    }
  }

  function transferOwnership(address to) public override onlyOwner {

    _transferOwnership(to);
  }

  function acceptOwnership() external override {

    require(msg.sender == s_pendingOwner, "Must be proposed owner");

    address oldOwner = s_owner;
    s_owner = msg.sender;
    s_pendingOwner = address(0);

    emit OwnershipTransferred(oldOwner, msg.sender);
  }

  function owner() public view override returns (address) {

    return s_owner;
  }

  function _transferOwnership(address to) private {

    require(to != msg.sender, "Cannot transfer to self");

    s_pendingOwner = to;

    emit OwnershipTransferRequested(s_owner, to);
  }

  function _validateOwnership() internal view {

    require(msg.sender == s_owner, "Only callable by owner");
  }

  modifier onlyOwner() {

    _validateOwnership();
    _;
  }
}// MIT
pragma solidity ^0.8.0;


contract ConfirmedOwner is ConfirmedOwnerWithProposal {

  constructor(address newOwner) ConfirmedOwnerWithProposal(newOwner, address(0)) {}
}// MIT
pragma solidity ^0.8.0;

interface KeeperCompatibleInterface {

  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);


  function performUpkeep(bytes calldata performData) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
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

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity ^0.8.1;

library Address {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
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
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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

pragma solidity 0.8.6;


contract GasStationExact is ConfirmedOwner, Pausable, KeeperCompatibleInterface {

  uint256 private constant MIN_GAS_FOR_TRANSFER = 55_000;

  event FundsAdded(uint256 amountAdded, uint256 newBalance, address sender);
  event FundsWithdrawn(uint256 amountWithdrawn, address payee);
  event TopUpSucceeded(address indexed recipient);
  event TopUpFailed(address indexed recipient);
  event KeeperRegistryAddressUpdated(address oldAddress, address newAddress);
  event MinWaitPeriodUpdated(uint256 oldMinWaitPeriod, uint256 newMinWaitPeriod);
  event ERC20Swept(address indexed token, address payee, uint256 amount);

  error InvalidWatchList();
  error OnlyKeeperRegistry();
  error DuplicateAddress(address duplicate);
  error ZeroAddress();

  struct Target {
    bool isActive;
    uint96 minBalanceWei;
    uint96 minTopUpAmountWei;
    uint56 lastTopUpTimestamp; // enough space for 2 trillion years
  }

  address private s_keeperRegistryAddress;
  uint256 private s_minWaitPeriodSeconds;
  address[] private s_watchList;
  mapping(address => Target) internal s_targets;

  constructor(address keeperRegistryAddress, uint256 minWaitPeriodSeconds) ConfirmedOwner(msg.sender) {
    setKeeperRegistryAddress(keeperRegistryAddress);
    setMinWaitPeriodSeconds(minWaitPeriodSeconds);
  }

  function setWatchList(
    address[] calldata addresses,
    uint96[] calldata minBalancesWei,
    uint96[] calldata topUpAmountsWei
  ) external onlyOwner {

    if (addresses.length != minBalancesWei.length || addresses.length != topUpAmountsWei.length) {
      revert InvalidWatchList();
    }
    address[] memory oldWatchList = s_watchList;
    for (uint256 idx = 0; idx < oldWatchList.length; idx++) {
      s_targets[oldWatchList[idx]].isActive = false;
    }
    for (uint256 idx = 0; idx < addresses.length; idx++) {
      if (s_targets[addresses[idx]].isActive) {
        revert DuplicateAddress(addresses[idx]);
      }
      if (addresses[idx] == address(0)) {
        revert InvalidWatchList();
      }
      if (topUpAmountsWei[idx] == 0) {
        revert InvalidWatchList();
      }
      s_targets[addresses[idx]] = Target({
        isActive: true,
        minBalanceWei: minBalancesWei[idx],
        minTopUpAmountWei: topUpAmountsWei[idx],
        lastTopUpTimestamp: 0
      });
    }
    s_watchList = addresses;
  }

  function getUnderfundedAddresses() public view returns (address[] memory) {

    address[] memory watchList = s_watchList;
    address[] memory needsFunding = new address[](watchList.length);
    uint256 count = 0;
    uint256 minWaitPeriod = s_minWaitPeriodSeconds;
    uint256 balance = address(this).balance;
    Target memory target;
    for (uint256 idx = 0; idx < watchList.length; idx++) {
      target = s_targets[watchList[idx]];
      if (watchList[idx].balance < target.minBalanceWei) {
        uint256 delta = target.minBalanceWei - watchList[idx].balance;
        if (
          target.lastTopUpTimestamp + minWaitPeriod <= block.timestamp &&
          balance >= delta &&
          delta >= target.minTopUpAmountWei
        ) {
          needsFunding[count] = watchList[idx];
          count++;
          balance -= delta;
        }
      }
    }
    if (count != watchList.length) {
      assembly {
        mstore(needsFunding, count)
      }
    }
    return needsFunding;
  }

  function topUpExact(address[] memory needsFunding) public whenNotPaused {

    uint256 minWaitPeriodSeconds = s_minWaitPeriodSeconds;
    Target memory target;
    for (uint256 idx = 0; idx < needsFunding.length; idx++) {
      target = s_targets[needsFunding[idx]];
      uint256 delta = target.minBalanceWei - needsFunding[idx].balance;
      if (
        target.isActive &&
        target.lastTopUpTimestamp + minWaitPeriodSeconds <= block.timestamp &&
        delta >= target.minTopUpAmountWei
      ) {
        bool success = payable(needsFunding[idx]).send(delta);
        if (success) {
          s_targets[needsFunding[idx]].lastTopUpTimestamp = uint56(block.timestamp);
          emit TopUpSucceeded(needsFunding[idx]);
        } else {
          emit TopUpFailed(needsFunding[idx]);
        }
      }
      if (gasleft() < MIN_GAS_FOR_TRANSFER) {
        return;
      }
    }
  }

  function checkUpkeep(bytes calldata)
    external
    view
    override
    whenNotPaused
    returns (bool upkeepNeeded, bytes memory performData)
  {

    address[] memory needsFunding = getUnderfundedAddresses();
    upkeepNeeded = needsFunding.length > 0;
    performData = abi.encode(needsFunding);
    return (upkeepNeeded, performData);
  }

  function performUpkeep(bytes calldata performData) external override onlyKeeperRegistry whenNotPaused {

    address[] memory needsFunding = abi.decode(performData, (address[]));
    topUpExact(needsFunding);
  }

  function withdraw(uint256 amount, address payable payee) external onlyOwner {

    if (payee == address(0)) {
      revert ZeroAddress();
    }
    emit FundsWithdrawn(amount, payee);
    payee.transfer(amount);
  }

  function sweep(address token, address payee) external onlyOwner {

    uint256 balance = IERC20(token).balanceOf(address(this));
    emit ERC20Swept(token, payee, balance);
    SafeERC20.safeTransfer(IERC20(token), payee, balance);
  }

  receive() external payable {
    emit FundsAdded(msg.value, address(this).balance, msg.sender);
  }

  function setKeeperRegistryAddress(address keeperRegistryAddress) public onlyOwner {

    emit KeeperRegistryAddressUpdated(s_keeperRegistryAddress, keeperRegistryAddress);
    s_keeperRegistryAddress = keeperRegistryAddress;
  }

  function setMinWaitPeriodSeconds(uint256 period) public onlyOwner {

    emit MinWaitPeriodUpdated(s_minWaitPeriodSeconds, period);
    s_minWaitPeriodSeconds = period;
  }

  function getKeeperRegistryAddress() external view returns (address keeperRegistryAddress) {

    return s_keeperRegistryAddress;
  }

  function getMinWaitPeriodSeconds() external view returns (uint256) {

    return s_minWaitPeriodSeconds;
  }

  function getWatchList() external view returns (address[] memory) {

    return s_watchList;
  }

  function getAccountInfo(address targetAddress)
    external
    view
    returns (
      bool isActive,
      uint96 minBalanceWei,
      uint96 minTopUpAmountWei,
      uint56 lastTopUpTimestamp
    )
  {

    Target memory target = s_targets[targetAddress];
    return (target.isActive, target.minBalanceWei, target.minTopUpAmountWei, target.lastTopUpTimestamp);
  }

  function pause() external onlyOwner {

    _pause();
  }

  function unpause() external onlyOwner {

    _unpause();
  }

  modifier onlyKeeperRegistry() {

    if (msg.sender != s_keeperRegistryAddress) {
      revert OnlyKeeperRegistry();
    }
    _;
  }
}