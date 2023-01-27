
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


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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
}// GPL-3.0
pragma solidity ^0.8.11;

interface ITiny721 {


  function transferLocks (
    uint256 _id
  ) external returns (bool);

  function balanceOf (
    address _owner
  ) external returns ( uint256 );

  function ownerOf (
    uint256 _id
  ) external returns (address);

  function mint_Qgo (
    address _recipient,
    uint256 _amount
  ) external;

  function lockTransfer (
    uint256 _id,
    bool _locked
  ) external;
}// GPL-3.0-only
pragma solidity ^0.8.11;



error CannotAddPoolWithInvalidId();
error CannotStakeAfterDeadline();
error CannotStakeInactivePool();
error CannotStakeUnownedItem();
error CannotStakeTimeLockedItem();
error CannotWithdrawUnownedItem();
error CannotWithdrawTimeLockedItem();
error CannotWithdrawUnstakedItem();
error SweepingTransferFailed();
error EmptyTokenIdsArray();

contract ImpostorsStaker is
  Ownable, ReentrancyGuard
{

  using SafeERC20 for IERC20;

  string public name;

  address public immutable token;

  struct Pool {
    address item;
    uint256 lockedTokensPerSecond;
    uint256 unlockedTokensPerSecond;
    uint256 lockDuration;
    uint256 deadline;
  }

  mapping ( uint256 => Pool ) public pools;

  struct ItemStatus {
    uint256 stakedPool;
    uint256 stakedAt;
    uint256 tokenClaimed;
  }

  mapping ( address => mapping ( uint256 => ItemStatus )) public itemStatuses;

  struct Position {
    uint256[] stakedItems;
    uint256 tokenPaid;
  }

  mapping ( uint256 => mapping ( address => Position )) public positions;

  uint256 public totalTokenDisbursed;

  event Claim (
    uint256 timestamp,
    address indexed caller,
    uint256[] poolIds,
    uint256 amount
  );

  event Stake (
    uint256 timestamp,
    address indexed caller,
    uint256 poolId,
    address indexed item,
    uint256[] tokenIds
  );

  event Withdraw (
    uint256 timestamp,
    address indexed caller,
    uint256 poolId,
    address indexed item,
    uint256[] tokenIds
  );

  constructor (
    string memory _name,
    address _token
  ) {
    name = _name;
    token = _token;
  }

  function getPosition(uint256 _id, address _addr) public view returns (uint256[] memory, uint256){

    Position memory p = positions[_id][_addr];
    return (p.stakedItems, p.tokenPaid);
  }

  function getItemsPosition(uint256 _id, address _addr) public view returns (uint256[] memory){

    Position memory p = positions[_id][_addr];
    return p.stakedItems;
  }

  function setPool (
    uint256 _id,
    address _item,
    uint256 _lockedTokensPerSecond,
    uint256 _unlockedTokensPerSecond,
    uint256 _lockDuration,
    uint256 _deadline
  ) external onlyOwner {

    if (_id < 1) {
      revert CannotAddPoolWithInvalidId();
    }

    pools[_id].item = _item;
    pools[_id].lockedTokensPerSecond = _lockedTokensPerSecond;
    pools[_id].unlockedTokensPerSecond = _unlockedTokensPerSecond;
    pools[_id].lockDuration = _lockDuration;
    pools[_id].deadline = _deadline;
  }

  function claim (
    uint256[] memory _poolIds
  ) public nonReentrant {
    uint256 totalClaimAmount;
    for (uint256 poolIndex; poolIndex < _poolIds.length; ++poolIndex) {
      uint256 poolId = _poolIds[poolIndex];
      Pool storage pool = pools[poolId];
      Position storage position = positions[poolId][_msgSender()];

      for (uint256 i; i < position.stakedItems.length; ++i) {
        uint256 stakedItemId = position.stakedItems[i];

        ItemStatus storage status = itemStatuses[pool.item][stakedItemId];
        uint256 lockEnds = status.stakedAt + pool.lockDuration;
        uint256 totalEarnings;

        if (block.timestamp > lockEnds) {
          totalEarnings = pool.lockDuration * pool.lockedTokensPerSecond;
          totalEarnings += (block.timestamp - lockEnds) * pool.unlockedTokensPerSecond;

        } else {
          totalEarnings = (block.timestamp - status.stakedAt) * pool.lockedTokensPerSecond;
        }

        uint256 tokenClaimed = status.tokenClaimed;
        uint256 unclaimedReward = totalEarnings - tokenClaimed;

        status.tokenClaimed = totalEarnings;

        position.tokenPaid = position.tokenPaid + unclaimedReward;

        totalClaimAmount = totalClaimAmount + unclaimedReward;
      }
    }

    totalTokenDisbursed = totalTokenDisbursed + totalClaimAmount;
    IERC20(token).safeTransfer(
      _msgSender(),
      totalClaimAmount
    );

    emit Claim(block.timestamp, _msgSender(), _poolIds, totalClaimAmount);
  }

  function pendingClaims (
    uint256[] memory _poolIds,
    address _user
  ) external view returns (uint256 totalClaimAmount) {
    for (uint256 poolIndex; poolIndex < _poolIds.length; ++poolIndex) {
      uint256 poolId = _poolIds[poolIndex];
      Pool storage pool = pools[poolId];
      Position storage position = positions[poolId][_user];

      for (uint256 i = 0; i < position.stakedItems.length; ++i) {
        uint256 stakedItemId = position.stakedItems[i];

        ItemStatus storage status = itemStatuses[pool.item][stakedItemId];
        uint256 lockEnds = status.stakedAt + pool.lockDuration;
        bool itemUnlocked = block.timestamp > lockEnds;
        uint256 totalEarnings;

        if (itemUnlocked) {
          totalEarnings = pool.lockDuration * pool.lockedTokensPerSecond;
          uint256 flexibleDuration = block.timestamp - lockEnds;
          totalEarnings += flexibleDuration * pool.unlockedTokensPerSecond;

        } else {
          uint256 stakeDuration = block.timestamp - status.stakedAt;
          totalEarnings = stakeDuration * pool.lockedTokensPerSecond;
        }

        totalClaimAmount = totalClaimAmount + totalEarnings - status.tokenClaimed;
      }
    }
    return totalClaimAmount;
  }

  function _asSingletonArray (
    uint256 _element
  ) private pure returns (uint256[] memory) {
    uint256[] memory array = new uint256[](1);
    array[0] = _element;
    return array;
  }

  function stake (
    uint256 _poolId,
    uint256[] calldata _tokenIds
  ) external  {
    if (_tokenIds.length == 0) {
      revert EmptyTokenIdsArray();
    }

    Pool storage pool = pools[_poolId];

    if (pool.lockedTokensPerSecond < 1) {
      revert CannotStakeInactivePool();
    }

    if (block.timestamp > pool.deadline) {
      revert CannotStakeAfterDeadline();
    }

    claim(_asSingletonArray(_poolId));

    ITiny721 item = ITiny721(pool.item);
    for (uint256 i; i < _tokenIds.length; ++i) {
      uint256 tokenId = _tokenIds[i];

      if (item.ownerOf(tokenId) != _msgSender()) {
        revert CannotStakeUnownedItem();
      }

      ItemStatus storage status = itemStatuses[pool.item][tokenId];
      uint256 lockEnds = status.stakedAt + pool.lockDuration;
      bool itemUnlocked = block.timestamp > lockEnds;

      if (!itemUnlocked) {
        revert CannotStakeTimeLockedItem();
      }

      status.stakedPool = _poolId;
      status.stakedAt = block.timestamp;
      status.tokenClaimed = 0;

      Position storage position = positions[_poolId][_msgSender()];

      bool alreadyStaked = false;
      for (
        uint256 stakedIndex;
        stakedIndex < position.stakedItems.length;
        ++stakedIndex
      ) {
        uint256 stakedId = position.stakedItems[stakedIndex];
        if (tokenId == stakedId) {
          alreadyStaked = true;
          break;
        }
      }

      if (!alreadyStaked) {
        position.stakedItems.push(tokenId);
      }

      if (!item.transferLocks(tokenId)) {
        item.lockTransfer(tokenId, true);
      }
    }

    emit Stake(block.timestamp, _msgSender(), _poolId, pool.item, _tokenIds);
  }

  function withdraw (
    uint256 _poolId,
    uint256[] calldata _tokenIds
  ) external {
    Pool storage pool = pools[_poolId];
    Position storage position = positions[_poolId][_msgSender()];

    claim(_asSingletonArray(_poolId));

    ITiny721 item = ITiny721(pool.item);
    for (uint256 i = 0; i < _tokenIds.length; ++i ) {
      uint256 tokenId = _tokenIds[i];

      if (item.ownerOf(tokenId) != _msgSender()) {
        revert CannotWithdrawUnownedItem();
      }

      ItemStatus storage status = itemStatuses[pool.item][tokenId];
      uint256 lockEnds = status.stakedAt + pool.lockDuration;
      bool itemUnlocked = block.timestamp > lockEnds;
      if (!itemUnlocked) {
        revert CannotWithdrawTimeLockedItem();
      }

      if (_poolId != status.stakedPool) {
        revert CannotWithdrawUnstakedItem();
      }

      status.stakedPool = 0;
      status.stakedAt = 0;
      status.tokenClaimed = 0;

      for (
        uint256 stakedIndex;
        stakedIndex < position.stakedItems.length;
        ++stakedIndex
      ) {
        uint256 stakedId = position.stakedItems[stakedIndex];
        if (tokenId == stakedId) {

          for (
            uint256 r = stakedIndex;
            r < position.stakedItems.length - 1;
            ++r
          ) {
            position.stakedItems[r] = position.stakedItems[r + 1];
          }
          position.stakedItems.pop();
          break;
        }
      }

      item.lockTransfer(tokenId, false);
    }

    emit Withdraw(block.timestamp, _msgSender(), _poolId, pool.item, _tokenIds);
  }

  function sweep (
    address _token,
    address _destination,
    uint256 _amount
  ) external onlyOwner {

    if (_token == address(0)) {
      (bool success, ) = payable(_destination).call{ value: _amount }("");
      if (!success) { revert SweepingTransferFailed(); }

    } else {
      IERC20(_token).safeTransfer(_destination, _amount);
    }
  }
}