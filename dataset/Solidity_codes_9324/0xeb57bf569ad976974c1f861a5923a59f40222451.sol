
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


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}// MIT

pragma solidity ^0.8.0;


contract ERC20 is Context, IERC20, IERC20Metadata {

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
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

pragma solidity ^0.8.7;



      
      
interface ILoomiSource {
  function getAccumulatedAmount(address staker) external view returns (uint256);
}

contract Loomi is ERC20, ReentrancyGuard, Ownable {
    ILoomiSource public LoomiSource;

    uint256 public MAX_SUPPLY;
    uint256 public constant MAX_TAX_VALUE = 100;

    uint256 public spendTaxAmount;
    uint256 public withdrawTaxAmount;

    uint256 public bribesDistributed;
    uint256 public activeTaxCollectedAmount;

    bool public tokenCapSet;

    bool public withdrawTaxCollectionStopped;
    bool public spendTaxCollectionStopped;

    bool public isPaused;
    bool public isDepositPaused;
    bool public isWithdrawPaused;
    bool public isTransferPaused;

    mapping (address => bool) private _isAuthorised;
    address[] public authorisedLog;

    mapping(address => uint256) public depositedAmount;
    mapping(address => uint256) public spentAmount;

    modifier onlyAuthorised {
      require(_isAuthorised[_msgSender()], "Not Authorised");
      _;
    }

    modifier whenNotPaused {
      require(!isPaused, "Transfers paused!");
      _;
    }

    event Withdraw(address indexed userAddress, uint256 amount, uint256 tax);
    event Deposit(address indexed userAddress, uint256 amount);
    event DepositFor(address indexed caller, address indexed userAddress, uint256 amount);
    event Spend(address indexed caller, address indexed userAddress, uint256 amount, uint256 tax);
    event ClaimTax(address indexed caller, address indexed userAddress, uint256 amount);
    event InternalTransfer(address indexed from, address indexed to, uint256 amount);

    constructor(address _source) ERC20("LOOMI", "LOOMI") {
      _isAuthorised[_msgSender()] = true;
      isPaused = true;
      isTransferPaused = true;

      withdrawTaxAmount = 25;
      spendTaxAmount = 25;

      LoomiSource = ILoomiSource(_source);
    }

    function getUserBalance(address user) public view returns (uint256) {
      return (LoomiSource.getAccumulatedAmount(user) + depositedAmount[user] - spentAmount[user]);
    }

    function depositLoomi(uint256 amount) public nonReentrant whenNotPaused {
      require(!isDepositPaused, "Deposit Paused");
      require(balanceOf(_msgSender()) >= amount, "Insufficient balance");

      _burn(_msgSender(), amount);
      depositedAmount[_msgSender()] += amount;

      emit Deposit(
        _msgSender(),
        amount
      );
    }

    function withdrawLoomi(uint256 amount) public nonReentrant whenNotPaused {
      require(!isWithdrawPaused, "Withdraw Paused");
      require(getUserBalance(_msgSender()) >= amount, "Insufficient balance");
      uint256 tax = withdrawTaxCollectionStopped ? 0 : (amount * withdrawTaxAmount) / 100;

      spentAmount[_msgSender()] += amount;
      activeTaxCollectedAmount += tax;
      _mint(_msgSender(), (amount - tax));

      emit Withdraw(
        _msgSender(),
        amount,
        tax
      );
    }

    function transferLoomi(address to, uint256 amount) public nonReentrant whenNotPaused {
      require(!isTransferPaused, "Transfer Paused");
      require(getUserBalance(_msgSender()) >= amount, "Insufficient balance");

      spentAmount[_msgSender()] += amount;
      depositedAmount[to] += amount;

      emit InternalTransfer(
        _msgSender(),
        to,
        amount
      );
    }

    function spendLoomi(address user, uint256 amount) external onlyAuthorised nonReentrant {
      require(getUserBalance(user) >= amount, "Insufficient balance");
      uint256 tax = spendTaxCollectionStopped ? 0 : (amount * spendTaxAmount) / 100;

      spentAmount[user] += amount;
      activeTaxCollectedAmount += tax;

      emit Spend(
        _msgSender(),
        user,
        amount,
        tax
      );
    }

    function depositLoomiFor(address user, uint256 amount) public onlyAuthorised nonReentrant {
      _depositLoomiFor(user, amount);
    }

    function distributeLoomi(address[] memory user, uint256[] memory amount) public onlyAuthorised nonReentrant {
      require(user.length == amount.length, "Wrong arrays passed");

      for (uint256 i; i < user.length; i++) {
        _depositLoomiFor(user[i], amount[i]);
      }
    }

    function _depositLoomiFor(address user, uint256 amount) internal {
      require(user != address(0), "Deposit to 0 address");
      depositedAmount[user] += amount;

      emit DepositFor(
        _msgSender(),
        user,
        amount
      );
    }

    function mintFor(address user, uint256 amount) external onlyAuthorised nonReentrant {
      if (tokenCapSet) require(totalSupply() + amount <= MAX_SUPPLY, "You try to mint more than max supply");
      _mint(user, amount);
    }

    function claimLoomiTax(address user, uint256 amount) public onlyAuthorised nonReentrant {
      require(activeTaxCollectedAmount >= amount, "Insufficiend tax balance");

      activeTaxCollectedAmount -= amount;
      depositedAmount[user] += amount;
      bribesDistributed += amount;

      emit ClaimTax(
        _msgSender(),
        user,
        amount
      );
    }

    function getMaxSupply() public view returns (uint256) {
      require(tokenCapSet, "Max supply is not set");
      return MAX_SUPPLY;
    }


    function setTokenCap(uint256 tokenCup) public onlyOwner {
      require(totalSupply() < tokenCup, "Value is smaller than the number of existing tokens");
      require(!tokenCapSet, "Token cap has been already set");

      MAX_SUPPLY = tokenCup;
    }

    function authorise(address addressToAuth) public onlyOwner {
      _isAuthorised[addressToAuth] = true;
      authorisedLog.push(addressToAuth);
    }

    function unauthorise(address addressToUnAuth) public onlyOwner {
      _isAuthorised[addressToUnAuth] = false;
    }

    function changeLoomiSourceContract(address _source) public onlyOwner {
      LoomiSource = ILoomiSource(_source);
      authorise(_source);
    }

    function updateWithdrawTaxAmount(uint256 _taxAmount) public onlyOwner {
      require(_taxAmount < MAX_TAX_VALUE, "Wrong value passed");
      withdrawTaxAmount = _taxAmount;
    }

    function updateSpendTaxAmount(uint256 _taxAmount) public onlyOwner {
      require(_taxAmount < MAX_TAX_VALUE, "Wrong value passed");
      spendTaxAmount = _taxAmount;
    }

    function stopTaxCollectionOnWithdraw(bool _stop) public onlyOwner {
      withdrawTaxCollectionStopped = _stop;
    }

    function stopTaxCollectionOnSpend(bool _stop) public onlyOwner {
      spendTaxCollectionStopped = _stop;
    }

    function pauseGameLoomi(bool _pause) public onlyOwner {
      isPaused = _pause;
    }

    function pauseTransfers(bool _pause) public onlyOwner {
      isTransferPaused = _pause;
    }

    function pauseWithdraw(bool _pause) public onlyOwner {
      isWithdrawPaused = _pause;
    }

    function pauseDeposits(bool _pause) public onlyOwner {
      isDepositPaused = _pause;
    }

    function rescue() external onlyOwner {
      payable(owner()).transfer(address(this).balance);
    }
}