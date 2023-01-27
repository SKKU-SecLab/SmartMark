
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

pragma solidity ^0.8.0;


interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

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

interface AggregatorV3Interface {
  function decimals() external view returns (uint8);

  function description() external view returns (string memory);

  function version() external view returns (uint256);

  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}// MIT
pragma solidity ^0.8.0;

contract ReentrancyGuard {

  uint256 private _guardCounter;

  constructor() {
    _guardCounter = 1;
  }

  modifier nonReentrant() {
    _guardCounter += 1;
    uint256 localCounter = _guardCounter;
    _;
    require(localCounter == _guardCounter);
  }

}// GPL-2.0-or-later
pragma solidity >=0.6.0;


library TransferHelper {
    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20.transferFrom.selector, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'STF');
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'ST');
    }

    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(IERC20.approve.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'SA');
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'STE');
    }
}pragma solidity ^0.8.0;


contract GPOLockedReworked is ERC20, Ownable, ReentrancyGuard {

    event TokensPurchased(
        address indexed purchaser,
        uint256 value,
        uint256 amount,
        uint256 timestamp
    );
    event TokensSwaped(
        address indexed swapper,
        uint256 value,
        uint256 timestamp
    );

    uint256 public lockedUntil;
    uint256 public vestingTime;
    string public _name = "GoldPesa Option Locked";
    string public _symbol = "GPOL";
    IERC20 public gpo;
    AggregatorV3Interface internal priceFeed;

    address payable public fundWallet;
    uint256 public priceInUSDCents;

    mapping(address => uint256) public balancesSold;
    mapping(address => uint256) public balancesSwap;
    uint256 public amountSold;

    constructor(address _gpoAddress,
        uint256 _priceInUSDCents,
        address _ethUsdAggregator,
        address payable _fundWallet,
        uint256 _lockedUntil,
        uint256 _vestingTime) 
        
        ERC20(_name, _symbol)
    {
        gpo = IERC20(_gpoAddress);
        priceInUSDCents = _priceInUSDCents;
        priceFeed = AggregatorV3Interface(_ethUsdAggregator);
        fundWallet = _fundWallet;
        lockedUntil = _lockedUntil;
        amountSold = 0;
        vestingTime = _vestingTime;
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal override {
        require(from == address(this) || to == address(this) || from == address(0x0) || to == address(0x0), "GPOLs are not transferrable");
    }

    function getSalePriceInETH() public view returns (uint256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        return (priceInUSDCents * 10**24) / uint256(price);
    }
    function tentativeAmountGPOPerETH(uint256 amount) public view returns (uint256) {
        return (amount * 10**18) / getSalePriceInETH();
    }

    function availableAmount() public view returns (uint256) {
        return balanceOf(address(this));
    }

    function addGPOsToSale(uint256 amount) public onlyOwner {
        require(gpo.balanceOf(address(this)) - availableAmount() >= amount, "Must transfer the exact amount of GPOs to the sale");
        _mint(address(this), amount);
    }

    function buyTokens() public payable nonReentrant {
        require(msg.value > 0, "Has to be > 0 eth");
        uint256 tentativeAmountGPO = tentativeAmountGPOPerETH(msg.value);
        require(availableAmount() >= tentativeAmountGPO, "Do not have enough GPO");
        _transfer(address(this), _msgSender(), tentativeAmountGPO);
        balancesSold[_msgSender()] += tentativeAmountGPO;
        amountSold += tentativeAmountGPO;
        emit TokensPurchased(_msgSender(), msg.value, tentativeAmountGPO, block.timestamp);
        transferFunds();
    }

    function swapGPOLtoGPO(uint256 amountIn) external {
        require(block.timestamp >= lockedUntil, "Cannot swap during the lock period");
        require(balanceOf(_msgSender()) >= amountIn, "GPOL balance is too low for this tx");
        require(amountIn <= unlockedGPOAllowance(_msgSender()), "Not enough unlocked GPOs atm");
        _burn(_msgSender(), amountIn);
        gpo.transfer(_msgSender(), amountIn);
        balancesSwap[_msgSender()] += amountIn;
        emit TokensSwaped(_msgSender(), amountIn, block.timestamp);
    }

    function unlockedGPOAllowance(address account) public view returns (uint256) {
        if (block.timestamp < lockedUntil) return 0;
        if (vestingTime == 0) return balancesSold[account];
        if (block.timestamp >= lockedUntil + vestingTime) return balancesSold[account] - balancesSwap[account];
        uint256 theoreticalAllowance = balancesSold[account] / 10 + ((block.timestamp - lockedUntil) * balancesSold[account] * 9 / 10) / vestingTime;
        return theoreticalAllowance - balancesSwap[account];
    }

    function setFundWallet(address payable _fundWallet) external onlyOwner {
        fundWallet = _fundWallet;
    }

    function transferFunds() internal {
        fundWallet.transfer(address(this).balance);
    } 

    function removeGPOsFromSale(uint256 amount) public onlyOwner {
        require(balanceOf(address(this)) >= amount, "Not enough GPOs");
        _burn(address(this), amount);
        gpo.transfer(address(gpo), amount);
    }
}