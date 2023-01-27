
pragma solidity ^0.8.0;

library AddressUpgradeable {

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
        __Context_init_unchained();
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
        __Context_init_unchained();
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal onlyInitializing {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal onlyInitializing {

        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {

        return _name;
    }

    function symbol() public view virtual override returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {

        return 18;
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

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}


    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    uint256[45] private __gap;
}// MIT
pragma solidity ^0.8.10;

interface ITRAC {

  struct TokenTime { uint16 token; uint48 timestamp; }
  struct OwnerTime { address owner; uint48 timestamp; }
  function tokenTimesOf(address) external view returns (TokenTime[] memory);

  function ownerTimesOf(uint16[] calldata) external view returns (OwnerTime[] memory);

}// MIT
pragma solidity ^0.8.10;

interface ITRACAssets {

  struct Purchases { uint48[] backpacks; uint48[] lockers; }
  function balanceOf(address, uint256) external view returns (uint256);

  function getPurchases(address) external view returns (Purchases memory);

}//  _________  _________   _______  __________


pragma solidity ^0.8.10;



contract CREDIT is ERC20Upgradeable, OwnableUpgradeable, ReentrancyGuardUpgradeable {


  uint128 constant private DAY_SECONDS = uint128(60 * 60 * 24);
  uint128 constant private REWARD_PER_SECOND = 8 ether / DAY_SECONDS;
  uint128 constant private REWARD_BACKPACK_PER_SECOND = 10 ether / DAY_SECONDS;

  bool public claimPaused;
  uint128 public globalRewardsClaimed;

  struct RewardSummary {
    uint16[] tokens;
    uint128 claimableReward;
    uint128 dailyRewardRate;
    uint128 totalClaimed;
    uint48 lastClaimTimestamp;
    uint128 globalRewardsClaimed;
    uint256 balance;
  }

  struct OwnerRewards { uint128 totalClaimed; uint48 lastClaim; }
  mapping(address => OwnerRewards) public ownerRewards;
  ITRAC private _trac;
  ITRACAssets private _items;
  
  event ClaimReward(address owner, uint128 reward);

  function initialize(address trac, address community) public initializer {

    __ERC20_init_unchained("TRAC CREDIT", "CREDIT");
    __Ownable_init_unchained();
    __ReentrancyGuard_init_unchained();

    _mint(address(this), 355555556 ether);
    _mint(community, 88888888 ether);

    _trac = ITRAC(trac);
  }

  function toggleClaims() public onlyOwner {

    claimPaused = !claimPaused;
  }

  struct Seconds { uint128 base; uint128 locker; uint128 backpack; uint128 all; }

  function summaryOf(address account) external view returns (RewardSummary memory summary) {

    ITRAC.TokenTime[] memory tokenTimes = _trac.tokenTimesOf(account);
    uint16[] memory tokens = new uint16[](tokenTimes.length);
    uint48 blockTimestamp = uint48(block.timestamp);
    uint48 lastClaim = ownerRewards[account].lastClaim;
    ITRACAssets.Purchases memory purchases = _items.getPurchases(account);
    uint48 backpack; uint48 locker; uint48 trac;
    Seconds memory sec;

    for (uint16 i; i < tokenTimes.length; i++) {
      if (tokenTimes[i].token != 0) {
        tokens[i] = tokenTimes[i].token;

        trac = lastClaim > tokenTimes[i].timestamp ? lastClaim : tokenTimes[i].timestamp;
        backpack = i < purchases.backpacks.length ? purchases.backpacks[i] : blockTimestamp;
        locker = i < purchases.lockers.length * 8 ? purchases.lockers[i / 8] : blockTimestamp;

        if (trac <= backpack && backpack <= locker) {          // TRAC > BACKPACK > LOCKER
          sec.base += backpack - trac;
          sec.backpack += locker - backpack;
          sec.all += blockTimestamp - locker;
        } else if (trac <= locker && locker <= backpack) {     // TRAC > LOCKER > BACKPACK
          sec.base += locker - trac;
          sec.locker += backpack - locker;
          sec.all += blockTimestamp - backpack;
        } else if (backpack <= trac && trac <= locker) {       // BACKPACK > TRAC > LOCKER
          sec.backpack += locker - trac;
          sec.all += blockTimestamp - locker;
        } else if (locker <= trac && trac <= backpack) {       // LOCKER > TRAC > BACKPACK
          sec.locker += backpack - trac;
          sec.all += blockTimestamp - backpack;
        } else {                                               // * > TRAC
          sec.all += blockTimestamp - trac;
        }
      }
    }

    uint128 reward =
      (sec.base * REWARD_PER_SECOND) +
      (sec.locker * REWARD_PER_SECOND) + ((sec.locker * REWARD_PER_SECOND) / 2) +
      (sec.backpack * REWARD_BACKPACK_PER_SECOND) +
      (sec.all * REWARD_BACKPACK_PER_SECOND) + ((sec.all * REWARD_BACKPACK_PER_SECOND) / 2);

    summary = RewardSummary(
      tokens,
      reward,
      calculateDailyRewardRate(tokenTimes.length, purchases.backpacks.length, purchases.lockers.length),
      ownerRewards[account].totalClaimed,
      lastClaim,
      globalRewardsClaimed,
      balanceOf(account)
    );
  }

  function claimRewards(uint16[] calldata tokens) external nonReentrant {

    require(tx.origin == msg.sender, "eos only");
    require(!claimPaused, "claim paused");
    require(tokens.length > 0, "empty tokens");

    uint48 lastClaim = ownerRewards[msg.sender].lastClaim;
    ITRAC.OwnerTime[] memory ownerTimes = _trac.ownerTimesOf(tokens);
    uint48 blockTimestamp = uint48(block.timestamp);
    ITRACAssets.Purchases memory purchases = _items.getPurchases(msg.sender);
    uint48 backpack; uint48 locker; uint48 trac;
    Seconds memory sec;

    uint16 prevTokenId;
    for (uint16 i; i < ownerTimes.length; i++) {
      require(tokens[i] > prevTokenId, "out of order"); // prevent duplicates
      require(ownerTimes[i].owner == msg.sender, "not owner");

      trac = lastClaim > ownerTimes[i].timestamp ? lastClaim : ownerTimes[i].timestamp;
      backpack = i < purchases.backpacks.length ? purchases.backpacks[i] : blockTimestamp;
      locker = i < purchases.lockers.length * 8 ? purchases.lockers[i / 8] : blockTimestamp;

      if (trac <= backpack && backpack <= locker) {          // TRAC > BACKPACK > LOCKER
        sec.base += backpack - trac;
        sec.backpack += locker - backpack;
        sec.all += blockTimestamp - locker;
      } else if (trac <= locker && locker <= backpack) {     // TRAC > LOCKER > BACKPACK
        sec.base += locker - trac;
        sec.locker += backpack - locker;
        sec.all += blockTimestamp - backpack;
      } else if (backpack <= trac && trac <= locker) {       // BACKPACK > TRAC > LOCKER
        sec.backpack += locker - trac;
        sec.all += blockTimestamp - locker;
      } else if (locker <= trac && trac <= backpack) {       // LOCKER > TRAC > BACKPACK
        sec.locker += backpack - trac;
        sec.all += blockTimestamp - backpack;
      } else {                                               // * > TRAC
        sec.all += blockTimestamp - trac;
      }

      prevTokenId = tokens[i];
    }

    uint128 reward =
      (sec.base * REWARD_PER_SECOND) +
      (sec.locker * REWARD_PER_SECOND) + ((sec.locker * REWARD_PER_SECOND) / 2) +
      (sec.backpack * REWARD_BACKPACK_PER_SECOND) +
      (sec.all * REWARD_BACKPACK_PER_SECOND) + ((sec.all * REWARD_BACKPACK_PER_SECOND) / 2);

    ownerRewards[msg.sender] = OwnerRewards(
      ownerRewards[msg.sender].totalClaimed + reward,
      blockTimestamp
    );

    globalRewardsClaimed += reward;
    emit ClaimReward(msg.sender, reward);
    _transfer(address(this), msg.sender, reward);
  }

  function calculateDailyRewardRate(uint256 tracs, uint256 backpacks, uint256 lockers) public pure returns (uint128) {

    uint256 lockerBonus = lockers * 8;
    uint256 tracsWithBackpacks = tracs < backpacks ? tracs : backpacks;
    uint256 tracsWithoutBackpacks = tracs - tracsWithBackpacks;
    uint256 tracsWithBackpacksWithLockers = tracsWithBackpacks < lockerBonus ? tracsWithBackpacks : lockerBonus;
    uint256 tracsWithBackpacksWithoutLockers = tracsWithBackpacks - tracsWithBackpacksWithLockers;
    lockerBonus = lockerBonus > tracsWithBackpacksWithLockers ? lockerBonus - tracsWithBackpacksWithLockers : 0;
    uint256 tracsWithoutBackpacksWithLockers = tracsWithoutBackpacks < lockerBonus ? tracsWithoutBackpacks : lockerBonus;
    uint256 tracsWithoutBackpacksWithoutLockers = tracsWithoutBackpacks - tracsWithoutBackpacksWithLockers;
    return uint128((
      (tracsWithoutBackpacksWithoutLockers * REWARD_PER_SECOND) + 
      (tracsWithoutBackpacksWithLockers * REWARD_PER_SECOND) + ((tracsWithoutBackpacksWithLockers * REWARD_PER_SECOND) / 2) + 
      (tracsWithBackpacksWithoutLockers * REWARD_BACKPACK_PER_SECOND) + 
      (tracsWithBackpacksWithLockers * REWARD_BACKPACK_PER_SECOND) + ((tracsWithBackpacksWithLockers * REWARD_BACKPACK_PER_SECOND) / 2)
    ) * DAY_SECONDS);
  }

  function burn(address account, uint256 amount) external nonReentrant {

    require(msg.sender == address(_trac) || msg.sender == address(_items), "only trac");
    _burn(account, amount);
  }

  function setAssetsAddress(address assets) external onlyOwner {

    _items = ITRACAssets(assets);
  }
}