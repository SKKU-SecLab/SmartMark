pragma solidity =0.8.4;

interface IERC20NoTransfer {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    event Transfer(address indexed from, address indexed to, uint256 value);
}
pragma solidity =0.8.4;


contract BrinkVote is IERC20NoTransfer {

  string private constant _symbol = "BRINKVOTE";
  string private constant _name = "Brink Vote";
  uint8 private constant _decimals = 18;
  uint256 private constant _cap = 5_000_000_000000000000000000; // 5 Million

  mapping (address => uint256) private _balances;
  mapping (address => bool) private _owners;

  uint256 private _totalSupply;
  bool private _frozen;

  modifier onlyOwner() {

    require(_isOwner(msg.sender), "NOT_OWNER");
    _;
  }

  modifier notFrozen() {

    require(!_frozen, "FROZEN");
    _;
  }

  constructor (address initialOwner) {
    _owners[initialOwner] = true;
  }

  function totalSupply() external view override returns (uint256) {

    return _totalSupply;
  }

  function balanceOf(address account) external view override returns (uint256) {

    return _balances[account];
  }

  function name() external pure returns (string memory) {

      return _name;
  }

  function symbol() external pure returns (string memory) {

    return _symbol;
  }

  function decimals() external pure returns (uint8) {

    return _decimals;
  }

  function cap() external pure returns (uint256) {

    return _cap;
  }

  function frozen() external view returns (bool) {

    return _frozen;
  }

  function isOwner(address owner) external view returns (bool) {

    return _isOwner(owner);
  }

  function grant(address account, uint256 amount) external onlyOwner notFrozen {

    _mint(account, amount);
  }

  function multigrant(address[] calldata accounts, uint256 amount) external onlyOwner notFrozen {

    for(uint8 i = 0; i < accounts.length; i++) {
      _mint(accounts[i], amount);
    }
  }

  function addOwner(address owner) external onlyOwner {

    require(!_isOwner(owner), "ALREADY_OWNER");
    _owners[owner] = true;
  }

  function removeOwner(address owner) external onlyOwner {

    require(_isOwner(owner), "CANNOT_REMOVE_NON_OWNER");
    require(owner != msg.sender, "CANNOT_REMOVE_SELF_OWNER");
    _owners[owner] = false;
  }

  function freeze() external onlyOwner {

    _frozen = true;
  }

  function _capExceeded() internal view returns (bool) {

    return _totalSupply > _cap;
  }

  function _isOwner(address owner) internal view returns (bool) {

    return _owners[owner];
  }

  function _mint(address account, uint256 amount) internal {

    _balances[account] += amount;
    _totalSupply += amount;
    require(!_capExceeded(), "CAP_EXCEEDED");
    emit Transfer(address(0), account, amount);
  }
}
