
pragma solidity ^0.8.0;

abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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


interface IERC20MetadataUpgradeable is IERC20Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


contract ERC20Upgradeable is Initializable, ContextUpgradeable, IERC20Upgradeable, IERC20MetadataUpgradeable {

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    function __ERC20_init(string memory name_, string memory symbol_) internal initializer {

        __Context_init_unchained();
        __ERC20_init_unchained(name_, symbol_);
    }

    function __ERC20_init_unchained(string memory name_, string memory symbol_) internal initializer {

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

    uint256[45] private __gap;
}// MIT

pragma solidity ^0.8.4;


contract ATTRToken is ERC20Upgradeable {

  mapping(address => bool) private _preListingAddrWL;

  uint64 private _wlDisabledAt;

  address private _wlController;

  mapping(address => TransferRule) public transferRules;

  event TransferRuleConfigured(address addr, TransferRule rule);  

  function initialize(address preListWlController) public initializer {

    __ERC20_init("Attrace", "ATTR");
    _mint(msg.sender, 10 ** 27); // 1000000000000000000000000000 aces, 1,000,000,000 ATTR
    _wlController = address(preListWlController);
    _wlDisabledAt = 1624456800; // June 23 2021
  }

  function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual override {

    super._beforeTokenTransfer(from, to, amount);

    if(_wlDisabledAt > block.timestamp) {
      require(_preListingAddrWL[from] == true, "not yet tradeable");
    }

    if(transferRules[from].tokens > 0) {
      uint lockedTokens = calcBalanceLocked(from);
      uint balanceUnlocked = super.balanceOf(from) - lockedTokens;
      require(amount <= balanceUnlocked, "transfer rule violation");
    }

    if(transferRules[from].outboundVestingMonths > 0 || transferRules[from].outboundTimeLockMonths > 0) {
      require(transferRules[to].tokens == 0, "unsupported");
      transferRules[to].timeLockMonths = transferRules[from].outboundTimeLockMonths;
      transferRules[to].vestingMonths = transferRules[from].outboundVestingMonths;
      transferRules[to].tokens = uint96(amount);
      transferRules[to].activationTime = uint40(block.timestamp);
    }
  }

  function setPreReleaseAddressStatus(address addr, bool status) public {

    require(_wlController == msg.sender);
    _preListingAddrWL[addr] = status;
  }

  function setNoRulesTime(uint64 disableTime) public {

    require(_wlController == msg.sender); // Only controller can 
    require(_wlDisabledAt > uint64(block.timestamp)); // Can not be set anymore when rules are already disabled
    require(disableTime > uint64(block.timestamp)); // Has to be in the future
    _wlDisabledAt = disableTime;
  }


  struct TransferRule {
    uint16 timeLockMonths; // 2

    uint16 vestingMonths; // 2

    uint96 tokens; // 12

    uint40 activationTime; // 5

    uint16 outboundTimeLockMonths; // 2
    uint16 outboundVestingMonths; // 2
  }

  function calcBalanceLocked(address from) private view returns (uint) {

    uint activationTime = (transferRules[from].activationTime == 0 ? _wlDisabledAt : transferRules[from].activationTime);

    uint secondsLocked;
    if(transferRules[from].timeLockMonths > 0) {
      secondsLocked = (transferRules[from].timeLockMonths * (30 days));
      if(activationTime+secondsLocked >= block.timestamp) {
        return transferRules[from].tokens;
      }
    }

    if(transferRules[from].vestingMonths > 0) {
      uint vestingStart = activationTime + secondsLocked;
      uint unlockedSlices = 0;
      for(uint i = 0; i < transferRules[from].vestingMonths; i++) {
        if(block.timestamp >= (vestingStart + (i * 30 days))) {
          unlockedSlices++;
        }
      }
      if(transferRules[from].vestingMonths == unlockedSlices) {
        return 0;
      }

      return (transferRules[from].tokens - ((transferRules[from].tokens / transferRules[from].vestingMonths) * unlockedSlices));
    }

    return 0;
  }

  function setTransferRule(address addr, TransferRule calldata rule) public {

    require(_wlDisabledAt > (uint64(block.timestamp - (30 days)))); // Project can add rules for the final 30 days of erc20 claim.
    require(_wlController == msg.sender); // Only the whitelist controller can set rules

    require(
      (rule.tokens > 0 && (rule.vestingMonths > 0 || rule.timeLockMonths > 0))
      || (rule.outboundTimeLockMonths > 0 || rule.outboundVestingMonths > 0), 
      "invalid rule");

    transferRules[addr] = rule;

    emit TransferRuleConfigured(addr, rule);
  }

  function getLockedTokens(address addr) public view returns (uint256) {

    return calcBalanceLocked(addr);
  }

  function batchSetTransferRules(address[] calldata addresses, TransferRule[] calldata rules) public {

    require(_wlDisabledAt > uint64(block.timestamp)); // Can only be set before listing
    require(_wlController == msg.sender); // Only the whitelist controller can set rules before listing
    require(addresses.length != 0);
    require(addresses.length == rules.length);
    for(uint i = 0; i < addresses.length; i++) {
      setTransferRule(addresses[i], rules[i]);
    }
  }
}