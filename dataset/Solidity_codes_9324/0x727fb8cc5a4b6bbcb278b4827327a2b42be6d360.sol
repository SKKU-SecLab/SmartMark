
pragma solidity ^0.8.0;

library MathUpgradeable {

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

pragma solidity ^0.8.1;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

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

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


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
pragma solidity 0.8.11;


interface IERC20Burnable is IERC20 {

  function burn(address from, uint256 amount) external;


  function burnFrom(address account, uint256 amount) external;

}// MIT
pragma solidity 0.8.11;


abstract contract BasicRNGUpgradeable is Initializable {
  uint256 private _nonces;

  function randomBytes() internal returns (bytes32) {
    return keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender, _nonces++));
  }

  function random(uint256 mod) internal returns (uint256) {
    return uint256(randomBytes()) % mod;
  }

  function randomBoolArray(uint256 size) internal returns (bool[] memory output) {
    require(size <= 256, "Exceed max size : 256");
    output = new bool[](size);
    uint256 rand = uint256(randomBytes());
    for (uint256 i; i < size; i++) output[i] = (rand >> i) & 1 == 1;
  }

  function __BasicRNG_init() internal onlyInitializing {
    __BasicRNG_init_unchained();
  }

  function __BasicRNG_init_unchained() internal onlyInitializing {}
}// MIT


pragma solidity 0.8.11;




contract FastFoodFrensFryVault is Initializable, OwnableUpgradeable, PausableUpgradeable, BasicRNGUpgradeable {

  using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

  event HardWorkerTaxed(address indexed account, uint256 amount);
  event HardWorkerPaid(address indexed account, uint256 amount);

  event TaxTheftSuccessful(address indexed account, uint256 indexed id, uint256 total, uint256 tax);
  event TaxTheftFail(address indexed account, uint256 indexed id, uint256 total, uint256 tax);


  uint256 public endTime;

  uint256 public rate;

  IERC721 public stakingToken;

  IERC20Burnable public rewardToken;

  IERC721 public spookiesToken;

  IERC721 public dogesToken;

  mapping(address => EnumerableSetUpgradeable.UintSet) internal _depositedIds;

  mapping(uint256 => uint256) internal _depositedTimestamps;

  mapping(uint256 => uint256) internal _initialDepositedTimestamps;


  uint128 public earlyWithdrawPenalty;

  uint64 public minStakingPeriod;

  uint32 public hardworkerTax;

  uint32 public taxtheftTax;


  function initialize(
    address newStakingToken,
    address newRewardToken,
    address newSpookiesToken,
    address newDogesToken,
    uint256 newRate,
    uint256 newEndTime,
    uint128 newEarlyWithdrawPenalty,
    uint64 newMinStakingPeriod,
    uint32 newHardworkerTax,
    uint32 newTaxtheftTax
  ) external initializer {

    __Ownable_init();
    __Pausable_init();

    stakingToken = IERC721(newStakingToken); // FFF
    rewardToken = IERC20Burnable(newRewardToken); // FRY
    spookiesToken = IERC721(newSpookiesToken); // Spookies
    dogesToken = IERC721(newDogesToken); // FFD
    rate = newRate; // Daily emissions by token
    endTime = newEndTime; // End date timemstamp

    earlyWithdrawPenalty = newEarlyWithdrawPenalty; //169 ether
    minStakingPeriod = newMinStakingPeriod; //90 days
    hardworkerTax = newHardworkerTax; // 69
    taxtheftTax = newTaxtheftTax; //169

    rewardToken.approve(address(this), type(uint256).max);

    _pause();
  }


  function deposit(uint256[] memory ids) external whenNotPaused {

    for (uint256 i; i < ids.length; i++) {
      _depositedIds[msg.sender].add(ids[i]);
      _initialDepositedTimestamps[ids[i]] = block.timestamp;
      _depositedTimestamps[ids[i]] = block.timestamp;

      stakingToken.transferFrom(msg.sender, address(this), ids[i]);
    }
  }

  function withdraw(uint256[] memory ids) external whenNotPaused {

    uint256 penalty = getEarlyWithdrawPenalty(ids);
    if (penalty > 0) rewardToken.burnFrom(msg.sender, penalty);

    uint256 collectionBonus = getCollectionsBonus(msg.sender);
    uint256 totalRewards;

    for (uint256 i; i < ids.length; i++) {
      require(_depositedIds[msg.sender].contains(ids[i]), "Query for a token you don't own");
      uint256 timeBonus = getTimeBonus(ids[i]);

      totalRewards += (_rewards(_depositedTimestamps[ids[i]]) * (1000 + collectionBonus + timeBonus)) / 1000;
      _depositedIds[msg.sender].remove(ids[i]);
      delete _initialDepositedTimestamps[ids[i]];
      delete _depositedTimestamps[ids[i]];

      stakingToken.safeTransferFrom(address(this), msg.sender, ids[i]);
    }

    payHardworker(totalRewards);
  }

  function earned(address account) external view returns (uint256[] memory rewards) {

    uint256 length = _depositedIds[account].length();
    uint256 collectionBonus = getCollectionsBonus(account);

    rewards = new uint256[](length);

    for (uint256 i; i < length; i++) {
      uint256 tokenId = _depositedIds[account].at(i);
      uint256 timeBonus = getTimeBonus(tokenId);

      rewards[i] = (_rewards(_depositedTimestamps[tokenId]) * (1000 + collectionBonus + timeBonus)) / 1000;
    }
  }

  function _rewards(uint256 timestamp) internal view returns (uint256) {

    if (timestamp == 0) return 0;
    return ((MathUpgradeable.min(block.timestamp, endTime) - timestamp) * rate) / 1 days;
  }

  function initialDepositTimestampsOf(address account)
    external
    view
    returns (uint256[] memory initialDepositTimestamps)
  {

    uint256 length = _depositedIds[account].length();
    initialDepositTimestamps = new uint256[](length);
    for (uint256 i; i < length; i++)
      initialDepositTimestamps[i] = _initialDepositedTimestamps[_depositedIds[account].at(i)];
  }

  function depositsOf(address account) external view returns (uint256[] memory ids) {

    uint256 length = _depositedIds[account].length();
    ids = new uint256[](length);
    for (uint256 i; i < length; i++) ids[i] = _depositedIds[account].at(i);
  }

  function claimAll() external whenNotPaused {

    uint256 totalRewards = 0;
    uint256 collectionBonus = getCollectionsBonus(msg.sender);

    for (uint256 i; i < _depositedIds[msg.sender].length(); i++) {
      uint256 tokenId = _depositedIds[msg.sender].at(i);
      uint256 timestamp = _depositedTimestamps[tokenId];
      uint256 timeBonus = getTimeBonus(tokenId);

      _depositedTimestamps[tokenId] = block.timestamp;
      totalRewards += (_rewards(timestamp) * (1000 + collectionBonus + timeBonus)) / 1000;
    }

    payHardworker(totalRewards);
  }


  function claimHardWorker(uint256[] memory ids) external whenNotPaused {

    uint256 totalRewards = 0;
    uint256 collectionBonus = getCollectionsBonus(msg.sender);

    for (uint256 i; i < ids.length; i++) {
      require(_depositedIds[msg.sender].contains(ids[i]), "Query for a token you don't own");
      uint256 timestamp = _depositedTimestamps[ids[i]];
      uint256 timeBonus = getTimeBonus(ids[i]);

      _depositedTimestamps[ids[i]] = block.timestamp;
      totalRewards += (_rewards(timestamp) * (1000 + collectionBonus + timeBonus)) / 1000;
    }
    payHardworker(totalRewards);
  }

  function claimTaxTheft(uint256[] memory ids) external whenNotPaused {

    uint256 totalRewards = 0;
    uint256 collectionBonus = getCollectionsBonus(msg.sender);
    bool[] memory res = randomBoolArray(ids.length);

    for (uint256 i; i < ids.length; i++) {
      require(_depositedIds[msg.sender].contains(ids[i]), "Query for a token you don't own");
      uint256 timestamp = _depositedTimestamps[ids[i]];
      uint256 timeBonus = getTimeBonus(ids[i]);

      _depositedTimestamps[ids[i]] = block.timestamp;
      uint256 rewards = (_rewards(timestamp) * (1000 + collectionBonus + timeBonus)) / 1000;

      if (res[i]) {
        uint256 bonux = (rewards * hardworkerTax) / 1000;
        uint256 total = rewards + bonux;
        totalRewards += total;
        emit TaxTheftSuccessful(msg.sender, ids[i], total, bonux);
      } else {
        uint256 malux = (rewards * taxtheftTax) / 1000;
        uint256 total = rewards - malux;
        totalRewards += total;
        emit TaxTheftFail(msg.sender, ids[i], total, malux);
      }
    }

    rewardToken.transfer(msg.sender, totalRewards); //send rewards
  }

  function payHardworker(uint256 totalRewards) internal {

    uint256 taxed = (totalRewards * hardworkerTax) / 1000;
    uint256 pay = totalRewards - taxed;

    rewardToken.burnFrom(address(this), taxed); //burn taxed
    rewardToken.transfer(msg.sender, pay); //send rewards

    emit HardWorkerTaxed(msg.sender, taxed);
    emit HardWorkerPaid(msg.sender, pay);
  }


  function getTimeBonus(uint256 id) public view returns (uint256) {

    if (_initialDepositedTimestamps[id] == 0) return 0;
    uint256 stakingDuration = block.timestamp - _initialDepositedTimestamps[id];
    if (stakingDuration > 270 days) return 300;
    if (stakingDuration > 180 days) return 200;
    if (stakingDuration > 90 days) return 100;
    return 0;
  }

  function getCollectionsBonus(address account) public view returns (uint256) {

    uint256 spookiesBalance = spookiesToken.balanceOf(account);
    uint256 dogesBalance = dogesToken.balanceOf(account);

    return getSpookiesBonus(spookiesBalance) + getDogesBonus(dogesBalance);
  }

  function getSpookiesBonus(uint256 balance) public pure returns (uint256) {

    if (balance > 15) return 69;
    if (balance > 8) return 50;
    if (balance > 6) return 40;
    if (balance > 4) return 30;
    if (balance > 2) return 20;
    if (balance > 0) return 10;
    return 0;
  }

  function getDogesBonus(uint256 balance) public pure returns (uint256) {

    if (balance > 19) return 69;
    if (balance > 12) return 50;
    if (balance > 9) return 40;
    if (balance > 6) return 30;
    if (balance > 3) return 20;
    if (balance > 0) return 10;
    return 0;
  }


  function getEarlyWithdrawPenalty(uint256[] memory ids) public view returns (uint256) {

    uint256 totalPenality;
    for (uint256 i; i < ids.length; i++) {
      uint256 stakingDuration = block.timestamp - _initialDepositedTimestamps[ids[i]];
      if (stakingDuration < minStakingPeriod) totalPenality += earlyWithdrawPenalty;
    }
    return totalPenality;
  }


  function setEarlyWithdrawPenalty(uint128 newEarlyWithdrawPenalty) external onlyOwner {

    earlyWithdrawPenalty = newEarlyWithdrawPenalty;
  }

  function setMinStakingPeriod(uint64 newMinStakingPeriod) external onlyOwner {

    minStakingPeriod = newMinStakingPeriod;
  }

  function setHardworkerTax(uint32 newHardworkerTax) external onlyOwner {

    hardworkerTax = newHardworkerTax;
  }

  function setTaxtheftTax(uint32 newTaxtheftTax) external onlyOwner {

    taxtheftTax = newTaxtheftTax;
  }


  function setRate(uint256 newRate) external onlyOwner {

    rate = newRate;
  }

  function setEndTime(uint256 newEndTime) external onlyOwner {

    require(newEndTime > block.timestamp, "End time must be greater than now");
    endTime = newEndTime;
  }

  function setStakingToken(address newStakingToken) external onlyOwner {

    stakingToken = IERC721(newStakingToken);
  }

  function setRewardToken(address newRewardToken) external onlyOwner {

    rewardToken = IERC20Burnable(newRewardToken);
  }

  function setSpookiesToken(address newSpookiesToken) external onlyOwner {

    spookiesToken = IERC721(newSpookiesToken);
  }

  function setDogesToken(address newDogesToken) external onlyOwner {

    spookiesToken = IERC721(newDogesToken);
  }

  function withdrawRewardToken() external onlyOwner {

    uint256 balance = rewardToken.balanceOf(address(this));
    rewardToken.transferFrom(address(this), msg.sender, balance);
  }

  function togglePaused() external onlyOwner {

    if (paused()) _unpause();
    else _pause();
  }
}