
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


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

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

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
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

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
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
}//Unlicense
pragma solidity ^0.8.0;

contract Accounts {

  mapping(address => address) public accounts;
  uint256 public size;
  address public constant HEAD = address(1);

  constructor() {
    accounts[HEAD] = HEAD;
  }

  function isStaking(address account) public view returns (bool) {

    return accounts[account] != address(0);
  }

  function add(address account) public {

    require(!isStaking(account), "Adding existing account");
    accounts[account] = accounts[HEAD];
    accounts[HEAD] = account;
    size += 1;
  }

  function remove(address account) public {

    require(isStaking(account), "Removing non-existing account");
    address previousAccount = getPrevious(account);
    accounts[previousAccount] = accounts[account];
    accounts[account] = address(0);
    size -= 1;
  }

  function getFirst() public view returns (address) {

    return accounts[HEAD];
  }

  function getNext(address account) public view returns (address) {

    return accounts[account];
  }

  function getPrevious(address account) internal view returns (address) {

    address currentAccount = HEAD;
    while (accounts[currentAccount] != HEAD) {
      if (accounts[currentAccount] == account) {
        return currentAccount;
      }
      currentAccount = accounts[currentAccount];
    }

    return address(0);
  }

  function getAll() public view returns (address[] memory) {

    address[] memory addresses = new address[](size);

    address currentAccount = HEAD;
    uint256 index;
    while (accounts[currentAccount] != HEAD) {
      addresses[index] = accounts[currentAccount];
      currentAccount = accounts[currentAccount];
      index += 1;
    }

    return addresses;
  }
}//Unlicense
pragma solidity ^0.8.0;


contract PogPunksStaking is
  Ownable,
  IERC721Receiver,
  ReentrancyGuard,
  Pausable
{

  using EnumerableSet for EnumerableSet.UintSet;

  address public stakingDestinationAddress;
  address public erc20Address;

  uint256 public expiration;
  uint256 public baseRate;
  uint256 public additionalRate;
  uint256 public totalTokensDeposited;
  uint256 public rewardLevel;
  uint256 public rewardLevelInterval;
  uint256 public supplyDenominator;
  Accounts public accounts;

  mapping(address => EnumerableSet.UintSet) private deposits;
  mapping(address => mapping(uint256 => uint256)) public depositBlocks;
  mapping(address => uint256) private balances;

  event RewardLevelChanged(uint256 oldRewardLevel, uint256 newRewardLevel);

  constructor(
    address _stakingDestinationAddress,
    address _erc20Address,
    uint256 _expiration,
    uint256 _rewardsPerDay,
    uint256 _additionalRewardsPerDay,
    uint256 _blocksPerDay,
    uint256 _supplyDenominator,
    uint256 _rewardLevelInterval
  ) {
    stakingDestinationAddress = _stakingDestinationAddress;
    expiration = block.number + _expiration;
    erc20Address = _erc20Address;
    accounts = new Accounts();
    setRate(_rewardsPerDay, _additionalRewardsPerDay, _blocksPerDay);
    supplyDenominator = _supplyDenominator;
    rewardLevelInterval = _rewardLevelInterval;
    _pause();
  }

  function pause() external onlyOwner {

    _pause();
  }

  function unpause() external onlyOwner {

    _unpause();
  }

  function setRate(
    uint256 rewardsPerDay,
    uint256 additionalRewardsPerDay,
    uint256 blocksPerDay
  ) public onlyOwner {

    baseRate = (rewardsPerDay * 1e18) / blocksPerDay;
    additionalRate = (additionalRewardsPerDay * 1e18) / blocksPerDay;
  }

  function setRewardLevelInterval(uint256 _rewardLevelInterval)
    external
    onlyOwner
  {

    rewardLevelInterval = _rewardLevelInterval;
  }

  function setSupplyDenominator(uint256 _supplyDenominator) external onlyOwner {

    supplyDenominator = _supplyDenominator;
  }

  function setExpiration(uint256 _expiration) external onlyOwner {

    expiration = block.number + _expiration;
  }

  function depositsOf(address account)
    external
    view
    returns (uint256[] memory)
  {

    EnumerableSet.UintSet storage depositSet = deposits[account];
    uint256[] memory tokenIds = new uint256[](depositSet.length());

    for (uint256 i; i < depositSet.length(); i++) {
      tokenIds[i] = depositSet.at(i);
    }

    return tokenIds;
  }

  function calculateTotalRate() public view returns (uint256) {

    return baseRate + ((rewardLevel * additionalRate) / 1e2);
  }

  function calculateTotalRewards(address account, uint256[] memory tokenIds)
    public
    view
    returns (uint256 rewards)
  {

    for (uint256 i; i < tokenIds.length; i++) {
      rewards += calculateReward(account, tokenIds[i]);
    }

    if (balances[account] > 0) {
      rewards += balances[account];
    }

    return rewards;
  }

  function calculateRewards(address account, uint256[] memory tokenIds)
    public
    view
    returns (uint256[] memory rewards)
  {

    rewards = new uint256[](tokenIds.length);

    for (uint256 i; i < tokenIds.length; i++) {
      rewards[i] = calculateReward(account, tokenIds[i]);
    }

    return rewards;
  }

  function calculateReward(address account, uint256 tokenId)
    private
    view
    returns (uint256)
  {

    require(
      Math.min(block.number, expiration) >= depositBlocks[account][tokenId],
      "Invalid blocks"
    );

    return
      calculateTotalRate() *
      (deposits[account].contains(tokenId) ? 1 : 0) *
      (Math.min(block.number, expiration) - depositBlocks[account][tokenId]);
  }

  function claimRewards(uint256[] calldata tokenIds) public whenNotPaused {

    uint256 reward;
    uint256 currentBlock = Math.min(block.number, expiration);

    for (uint256 i; i < tokenIds.length; i++) {
      reward += calculateReward(msg.sender, tokenIds[i]);
      depositBlocks[msg.sender][tokenIds[i]] = currentBlock;
    }

    if (reward > IERC20(erc20Address).balanceOf(address(this))) {
      revert("Insufficient balance");
    }

    if (balances[msg.sender] > 0) {
      reward += balances[msg.sender];
      balances[msg.sender] = 0;
    }

    if (reward > 0) {
      IERC20(erc20Address).transfer(msg.sender, reward);
    }
  }

  function rebalance() external nonReentrant whenNotPaused {

    uint256 currentBlock = Math.min(block.number, expiration);

    address currentAccount = accounts.getFirst();
    while (currentAccount != accounts.HEAD()) {
      uint256 reward;

      EnumerableSet.UintSet storage tokens = deposits[currentAccount];
      for (uint256 i; i < tokens.length(); i++) {
        uint256 depositBlock = depositBlocks[currentAccount][tokens.at(i)];
        if (currentBlock > depositBlock) {
          reward += calculateTotalRate() * (currentBlock - depositBlock);
        }
        depositBlocks[currentAccount][tokens.at(i)] = currentBlock;
      }

      balances[currentAccount] = reward;

      currentAccount = accounts.getNext(currentAccount);
    }

    setNewRewardLevel();
  }

  function setNewRewardLevel() private whenNotPaused {

    uint256 percentageDeposited = ((totalTokensDeposited * 1e2) /
      supplyDenominator);

    rewardLevel =
      percentageDeposited -
      (percentageDeposited % rewardLevelInterval);
  }

  function handleNewRewardLevel() private whenNotPaused {

    uint256 percentageDeposited = (totalTokensDeposited * 1e2) /
      supplyDenominator;

    uint256 newRewardLevel = percentageDeposited -
      (percentageDeposited % rewardLevelInterval);

    if (rewardLevel != newRewardLevel) {
      emit RewardLevelChanged(rewardLevel, newRewardLevel);
    }
  }

  function deposit(uint256[] calldata tokenIds) external whenNotPaused {

    require(msg.sender != stakingDestinationAddress, "Invalid address");

    uint256 currentBlock = Math.min(block.number, expiration);

    if (!accounts.isStaking(msg.sender)) {
      accounts.add(msg.sender);
    }

    for (uint256 i; i < tokenIds.length; i++) {
      IERC721(stakingDestinationAddress).safeTransferFrom(
        msg.sender,
        address(this),
        tokenIds[i],
        ""
      );
      deposits[msg.sender].add(tokenIds[i]);
      depositBlocks[msg.sender][tokenIds[i]] = currentBlock;
    }

    totalTokensDeposited += tokenIds.length;

    handleNewRewardLevel();
  }

  function withdraw(uint256[] calldata tokenIds)
    external
    whenNotPaused
    nonReentrant
  {

    claimRewards(tokenIds);

    for (uint256 i; i < tokenIds.length; i++) {
      require(
        deposits[msg.sender].contains(tokenIds[i]),
        "Staking: token not deposited"
      );

      deposits[msg.sender].remove(tokenIds[i]);

      IERC721(stakingDestinationAddress).safeTransferFrom(
        address(this),
        msg.sender,
        tokenIds[i],
        ""
      );
    }

    totalTokensDeposited -= tokenIds.length;

    if (deposits[msg.sender].length() == 0) {
      accounts.remove(msg.sender);
    }

    handleNewRewardLevel();
  }

  function getAllAccounts() external view returns (address[] memory) {

    return accounts.getAll();
  }

  function withdrawERC20() external onlyOwner {

    uint256 tokenSupply = IERC20(erc20Address).balanceOf(address(this));
    IERC20(erc20Address).transfer(msg.sender, tokenSupply);
  }

  function withdrawPogPunks() external onlyOwner {

    address currentAccount = accounts.getFirst();
    while (currentAccount != accounts.HEAD()) {
      EnumerableSet.UintSet storage tokens = deposits[currentAccount];
      for (uint256 i; i < tokens.length(); i++) {
        IERC721(stakingDestinationAddress).safeTransferFrom(
          address(this),
          msg.sender,
          tokens.at(i),
          ""
        );
      }
      currentAccount = accounts.getNext(currentAccount);
    }
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  ) external pure override returns (bytes4) {

    return IERC721Receiver.onERC721Received.selector;
  }
}