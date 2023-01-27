




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}




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
}




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
}




pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}




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

    function transfer(address to, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {

        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {

        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
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

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {

        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
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

}



pragma solidity ^0.8.0;



contract AprilFools is ERC20, Ownable {
    uint32 public _taxPercision = 100000;
    address[] public _taxRecipients;
    uint16 public _taxTotal;
    bool public _taxActive;

    mapping(address => uint16) public _taxRecipientAmounts;
    mapping(address => bool) private _isTaxRecipient;
    mapping(address => bool) public _whitelisted;

    event UpdateTaxPercentage(address indexed wallet, uint16 _newTaxAmount);
    event AddTaxRecipient(address indexed wallet, uint16 _taxAmount);
    event RemoveFromWhitelist(address indexed wallet);
    event RemoveTaxRecipient(address indexed wallet);
    event AddToWhitelist(address indexed wallet);
    event ToggleTax(bool _active);

    uint256 private _totalSupply;

    constructor() ERC20('April Fools', 'FOOL') payable {
      _totalSupply = 1000000000 * (10**18);

      _mint(msg.sender, _totalSupply);
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        require(balanceOf(from) >= amount, "ERC20: transfer amount exceeds balance");
        if(_taxActive && !_whitelisted[from] && !_whitelisted[to]) {
          uint256 tax = amount *_taxTotal / _taxPercision;
          amount = amount - tax;
          _transfer(from, address(this), tax);
        }
        _transfer(from, to, amount);
        return true;
    }


    function transfer(address to, uint256 amount) public virtual override returns (bool) {
      address owner = _msgSender();
      require(balanceOf(owner) >= amount, "ERC20: transfer amount exceeds balance");
      if(_taxActive && !_whitelisted[owner] && !_whitelisted[to]) {
        uint256 tax = amount*_taxTotal/_taxPercision;
        amount = amount - tax;
        _transfer(owner, address(this), tax);
      }
      _transfer(owner, to, amount);
      return true;
    }


    function burn(uint256 value) public {
      _burn(msg.sender, value);
    }

    function toggleTax() external onlyOwner {
      _taxActive = !_taxActive;
      emit ToggleTax(_taxActive);
    }

    function addTaxRecipient(address wallet, uint16 _tax) external onlyOwner {
      require(_taxRecipients.length < 100, "Reached maximum number of tax addresses");
      require(wallet != address(0), "Cannot add 0 address");
      require(!_isTaxRecipient[wallet], "Recipient already added");
      require(_tax > 0 && _tax + _taxTotal <= _taxPercision/10, "Total tax amount must be between 0 and 10%");

      _isTaxRecipient[wallet] = true;
      _taxRecipients.push(wallet);
      _taxRecipientAmounts[wallet] = _tax;
      _taxTotal = _taxTotal + _tax;
      emit AddTaxRecipient(wallet, _tax);
    }

    function updateTaxPercentage(address wallet, uint16 newTax) external onlyOwner {
      require(wallet != address(0), "Cannot add 0 address");
      require(_isTaxRecipient[wallet], "Not a tax address");

      uint16 currentTax = _taxRecipientAmounts[wallet];
      require(currentTax != newTax, "Tax already this amount for this address");

      if(currentTax < newTax) {
        uint16 diff = newTax - currentTax;
        require(_taxTotal + diff <= 10000, "Tax amount too high for current tax rate");
        _taxTotal = _taxTotal + diff;
      } else {
        uint16 diff = currentTax - newTax;
        _taxTotal = _taxTotal - diff;
      }
      _taxRecipientAmounts[wallet] = newTax;
      emit UpdateTaxPercentage(wallet, newTax);
    }

    function removeTaxRecipient(address wallet) external onlyOwner {
      require(wallet != address(0), "Cannot add 0 address");
      require(_isTaxRecipient[wallet], "Recipient has not been added");
      uint16 _tax = _taxRecipientAmounts[wallet];

      for(uint8 i = 0; i < _taxRecipients.length; i++) {
        if(_taxRecipients[i] == wallet) {
          _taxTotal = _taxTotal - _tax;
          _taxRecipientAmounts[wallet] = 0;
          _taxRecipients[i] = _taxRecipients[_taxRecipients.length - 1];
          _isTaxRecipient[wallet] = false;
          _taxRecipients.pop();
          emit RemoveTaxRecipient(wallet);

          break;
        }
      }
    }

    function addToWhitelist(address wallet) external onlyOwner {
      require(wallet != address(0), "Cant use 0 address");
      require(!_whitelisted[wallet], "Address already added");
      _whitelisted[wallet] = true;

      emit AddToWhitelist(wallet);
    }

    function removeFromWhitelist(address wallet) external onlyOwner {
      require(wallet != address(0), "Cant use 0 address");
      require(_whitelisted[wallet], "Address not added");
      _whitelisted[wallet] = false;

      emit RemoveFromWhitelist(wallet);
    }

    function taxReset() external onlyOwner {
      _taxActive = false;
      _taxTotal = 0;

      for(uint8 i = 0; i < _taxRecipients.length; i++) {
        _taxRecipientAmounts[_taxRecipients[i]] = 0;
        _isTaxRecipient[_taxRecipients[i]] = false;
      }

      delete _taxRecipients;
    }

    function distributeTaxes() external onlyOwner {
      require(balanceOf(address(this)) > 0, "Nothing to withdraw");
      uint256 taxableAmount = balanceOf(address(this));
      for(uint8 i = 0; i < _taxRecipients.length; i++) {
        address taxAddress = _taxRecipients[i];
        if(i == _taxRecipients.length - 1) {
           _transfer(address(this), taxAddress, balanceOf(address(this)));
        } else {
          uint256 amount = taxableAmount * _taxRecipientAmounts[taxAddress]/_taxTotal;
          _transfer(address(this), taxAddress, amount);
        }
      }
    }
}