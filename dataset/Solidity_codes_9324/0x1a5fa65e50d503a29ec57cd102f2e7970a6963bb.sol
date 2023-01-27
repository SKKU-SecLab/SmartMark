
pragma solidity ^0.8.3;

contract Verifier {


  function verifyWithPrefix(bytes32 hash, bytes calldata sig, address signer) public pure returns (bool) {

    return verify(addPrefix(hash), sig, signer);
  }

  function recoverWithPrefix(bytes32 hash, bytes calldata sig) public pure returns (address) {

    return recover(addPrefix(hash), sig);
  }

  function verify(bytes32 hash, bytes calldata sig, address signer) internal pure returns (bool) {

    return recover(hash, sig) == signer;
  }

  function recover(bytes32 hash, bytes calldata _sig) internal pure returns (address) {

    bytes memory sig = _sig;
    bytes32 r;
    bytes32 s;
    uint8 v;

    if (sig.length != 65) {
      return address(0);
    }

    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := and(mload(add(sig, 65)), 255)
    }

    if (v < 27) {
      v += 27;
    }

    if (v != 27 && v != 28) {
      return address(0);
    }

    return ecrecover(hash, v, r, s);
  }

  function addPrefix(bytes32 hash) private pure returns (bytes32) {

    bytes memory prefix = "\x19Ethereum Signed Message:\n32";

    return keccak256(abi.encodePacked(prefix, hash));
  }
}// MIT

pragma solidity ^0.8.3;


interface IClaimsRegistryVerifier {

  function verifyClaim(address subject, address attester, bytes calldata sig) external view returns (bool);

}

contract ClaimsRegistry is IClaimsRegistryVerifier, Verifier {

  mapping(bytes32 => Claim) public registry;

  struct Claim {
    address subject; // Subject the claim refers to
    bool revoked;    // Whether the claim is revoked or not
  }

  event ClaimStored(
    bytes sig
  );

  event ClaimRevoked(
    bytes sig
  );

  function setClaimWithSignature(
    address subject,
    address attester,
    bytes32 claimHash,
    bytes calldata sig
  ) public {

    bytes32 signable = computeSignableKey(subject, claimHash);

    require(verifyWithPrefix(signable, sig, attester), "ClaimsRegistry: Claim signature does not match attester");

    bytes32 key = computeKey(attester, sig);

    registry[key] = Claim(subject, false);

    emit ClaimStored(sig);
  }

  function getClaim(
    address attester,
    bytes calldata sig
  ) public view returns (address) {

    bytes32 key = keccak256(abi.encodePacked(attester, sig));

    if (registry[key].revoked) {
      return address(0);
    } else {
      return registry[key].subject;
    }

  }

  function verifyClaim(
    address subject,
    address attester,
    bytes calldata sig
  ) override external view returns (bool) {

    return getClaim(attester, sig) == subject;
  }

  function revokeClaim(
    bytes calldata sig
  ) public {

    bytes32 key = computeKey(msg.sender, sig);

    require(registry[key].subject != address(0), "ClaimsRegistry: Claim not found");

    registry[key].revoked = true;

    emit ClaimRevoked(sig);
  }

  function computeSignableKey(address subject, bytes32 claimHash) public pure returns (bytes32) {

    return keccak256(abi.encodePacked(subject, claimHash));
  }

  function computeKey(address attester, bytes calldata sig) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked(attester, sig));
  }
}// MIT

pragma solidity ^0.8.3;


contract FakeClaimsRegistry is IClaimsRegistryVerifier {

  bool result;

  constructor() {
    result = true;
  }

  function setResult(bool _r) public {

    result = _r;
  }

  function verifyClaim(address, address, bytes calldata) external override view returns (bool) {

    return result;
  }
}// MIT

pragma solidity ^0.8.0;

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

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20 {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {

        return _name;
    }

    function symbol() public view virtual returns (string memory) {

        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {

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

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {

        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}// MIT

pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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

pragma solidity ^0.8.3;

contract CappedRewardCalculator {
  uint public immutable startDate;
  uint public immutable endDate;
  uint public immutable cap;

  uint constant private year = 365 days;
  uint constant private day = 1 days;
  uint private constant mul = 1000000;

  constructor(
    uint _start,
    uint _end,
    uint _cap
  ) {
    require(block.timestamp <= _start, "CappedRewardCalculator: start date must be in the future");
    require(
      _start < _end,
      "CappedRewardCalculator: end date must be after start date"
    );

    require(_cap > 0, "CappedRewardCalculator: curve cap cannot be 0");

    startDate = _start;
    endDate = _end;
    cap = _cap;
  }

  function calculateReward(
    uint _start,
    uint _end,
    uint _amount
  ) public view returns (uint) {
    (uint start, uint end) = truncatePeriod(_start, _end);
    (uint startPercent, uint endPercent) = toPeriodPercents(start, end);

    uint percentage = curvePercentage(startPercent, endPercent);

    uint reward = _amount * cap * percentage / (mul * 100);

    return reward;
  }

  function currentAPY() public view returns (uint) {
    uint amount = 100 ether;
    uint today = block.timestamp;

    if (today < startDate) {
      today = startDate;
    }

    uint todayReward = calculateReward(startDate, today, amount);

    uint tomorrow = today + day;
    uint tomorrowReward = calculateReward(startDate, tomorrow, amount);

    uint delta = tomorrowReward - todayReward;
    uint apy = delta * 365 * 100 / amount;

    return apy;
  }

  function toPeriodPercents(
    uint _start,
    uint _end
  ) internal view returns (uint, uint) {
    uint totalDuration = endDate - startDate;

    if (totalDuration == 0) {
      return (0, mul);
    }

    uint startPercent = (_start - startDate) * mul / totalDuration;
    uint endPercent = (_end - startDate) * mul / totalDuration;

    return (startPercent, endPercent);
  }

  function truncatePeriod(
    uint _start,
    uint _end
  ) internal view returns (uint, uint) {
    if (_end <= startDate || _start >= endDate) {
      return (startDate, startDate);
    }

    uint start = _start < startDate ? startDate : _start;
    uint end = _end > endDate ? endDate : _end;

    return (start, end);
  }

  function curvePercentage(uint _start, uint _end) internal pure returns (uint) {
    int maxArea = integralAtPoint(mul) - integralAtPoint(0);
    int actualArea = integralAtPoint(_end) - integralAtPoint(_start);

    uint ratio = uint(actualArea * int(mul) / maxArea);

    return ratio;
  }


  function integralAtPoint(uint _x) internal pure returns (int) {
    int x = int(_x);
    int p1 = ((x - int(mul)) ** 3) / (3 * int(mul));

    return p1;
  }
}// MIT

pragma solidity ^0.8.3;



contract Staking is CappedRewardCalculator, Ownable {
  ERC20 public immutable erc20;

  IClaimsRegistryVerifier public immutable registry;

  address public immutable claimAttester;

  uint public immutable minAmount;

  uint public immutable maxAmount;

  uint public lockedReward = 0;

  uint public distributedReward = 0;

  uint public stakedAmount = 0;

  mapping(address => Subscription) public subscriptions;

  event Subscribed(
    address subscriber,
    uint date,
    uint stakedAmount,
    uint maxReward
  );

  event Withdrawn(
    address subscriber,
    uint date,
    uint withdrawAmount
  );

  struct Subscription {
    bool active;
    address subscriberAddress; // addres the subscriptions refers to
    uint startDate;      // Block timestamp at which the subscription was made
    uint stakedAmount;   // How much was staked
    uint maxReward;      // Maximum reward given if user stays until the end of the staking period
    uint withdrawAmount; // Total amount withdrawn (initial amount + final calculated reward)
    uint withdrawDate;   // Block timestamp at which the subscription was withdrawn (or 0 while staking is in progress)
  }

  constructor(
    address _token,
    address _registry,
    address _attester,
    uint _startDate,
    uint _endDate,
    uint _minAmount,
    uint _maxAmount,
    uint _cap
  ) CappedRewardCalculator(_startDate, _endDate, _cap) {
    require(_token != address(0), "Staking: token address cannot be 0x0");
    require(_registry != address(0), "Staking: claims registry address cannot be 0x0");
    require(_attester != address(0), "Staking: claim attester cannot be 0x0");
    require(block.timestamp <= _startDate, "Staking: start date must be in the future");
    require(_minAmount > 0, "Staking: invalid individual min amount");
    require(_maxAmount > _minAmount, "Staking: max amount must be higher than min amount");

    erc20 = ERC20(_token);
    registry = IClaimsRegistryVerifier(_registry);
    claimAttester = _attester;

    minAmount = _minAmount;
    maxAmount = _maxAmount;
  }

  function totalPool() public view returns (uint) {
    return erc20.balanceOf(address(this)) - stakedAmount + distributedReward;
  }

  function availablePool() public view returns (uint) {
    return erc20.balanceOf(address(this)) - stakedAmount - lockedReward;
  }

  function stake(uint _amount, bytes calldata claimSig) external {
    uint time = block.timestamp;
    address subscriber = msg.sender;

    require(registry.verifyClaim(msg.sender, claimAttester, claimSig), "Staking: could not verify claim");
    require(_amount >= minAmount, "Staking: staked amount needs to be greater than or equal to minimum amount");
    require(_amount <= maxAmount, "Staking: staked amount needs to be lower than or equal to maximum amount");
    require(time >= startDate, "Staking: staking period not started");
    require(time < endDate, "Staking: staking period finished");
    require(subscriptions[subscriber].active == false, "Staking: this account has already staked");


    uint maxReward = calculateReward(time, endDate, _amount);
    require(maxReward <= availablePool(), "Staking: not enough tokens available in the pool");
    lockedReward += maxReward;
    stakedAmount += _amount;

    subscriptions[subscriber] = Subscription(
      true,
      subscriber,
      time,
      _amount,
      maxReward,
      0,
      0
    );

    require(erc20.transferFrom(subscriber, address(this), _amount),
      "Staking: Could not transfer tokens from subscriber");

    emit Subscribed(subscriber, time, _amount, maxReward);
  }

  function withdraw() external {
    address subscriber = msg.sender;
    uint time = block.timestamp;

    require(subscriptions[subscriber].active == true, "Staking: no active subscription found for this address");

    Subscription memory sub = subscriptions[subscriber];

    uint actualReward = calculateReward(sub.startDate, time, sub.stakedAmount);
    uint total = sub.stakedAmount + actualReward;

    sub.withdrawAmount = total;
    sub.withdrawDate = time;
    sub.active = false;
    subscriptions[subscriber] = sub;

    lockedReward -= sub.maxReward;
    distributedReward += actualReward;
    stakedAmount -= sub.stakedAmount;

    require(erc20.transfer(subscriber, total), "Staking: Transfer has failed");

    emit Withdrawn(subscriber, time, total);
  }

  function getStakedAmount(address _subscriber) external view returns (uint) {
    if (subscriptions[_subscriber].stakedAmount > 0 && subscriptions[_subscriber].withdrawDate == 0) {
      return subscriptions[_subscriber].stakedAmount;
    } else {
      return 0;
    }
  }

  function getMaxStakeReward(address _subscriber) external view returns (uint) {
    Subscription memory sub = subscriptions[_subscriber];

    if (sub.active) {
      return subscriptions[_subscriber].maxReward;
    } else {
      return 0;
    }
  }

  function getCurrentReward(address _subscriber) external view returns (uint) {
    Subscription memory sub = subscriptions[_subscriber];

    if (sub.active) {
      return calculateReward(sub.startDate, block.timestamp, sub.stakedAmount);
    } else {
      return 0;
    }
  }

  function withdrawPool() external onlyOwner {
    require(block.timestamp > endDate, "Staking: staking not over yet");

    erc20.transfer(owner(), availablePool());
  }
}// MIT

pragma solidity ^0.8.3;


contract FractalToken is ERC20 {
  constructor(address targetOwner) ERC20("Fractal Protocol Token", "FCL") {
    _mint(targetOwner, 465000000000000000000000000);
  }
}

contract LPToken is ERC20 {
  constructor(address targetOwner) ERC20("FCL-ETH-LP Token", "FCL-ETH-LP") {
    _mint(targetOwner, 465000000000000000000000000);
  }
}