
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

}//Unlicense
pragma solidity ^0.8.0;

interface IDividends {
    function withdrawableBy(address investor) external view returns (uint256);
    function withdrawnBy(address investor) external view returns (uint256);
    function totalDistributed() external view returns (uint256);
    function undistributedBalance() external view returns (uint256);

    function distribute() external;
    function withdrawDividends() external;
    function withdraw() external;
}//Unlicense
pragma solidity ^0.8.0;

library CCMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "add overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(a >= b, "sub overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) return 0;

        uint256 c = a * b;
        require(c / a == b, "mul overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "division by zero");
        return a / b;
    }
}//Unlicense
pragma solidity ^0.8.0;


abstract contract AbstractDividends is IDividends {
    using CCMath for uint256;

    struct Account {
        uint256 withdrawn;
        int256 ptsCorrection;
    }

    mapping (address => Account) private _stakeHolders;

    uint256 constant private PM = type(uint128).max;
    uint256 private _pointsPerShare = 0;

    uint256 private _expectedBalance = 0;
    uint256 private _totalDistributed = 0;
    uint256 private _ownerBalance = 0;

    event PaymentDistributed(uint256 amount);
    event Withdrawn(address holder, uint256 amount);

    modifier correctPts(address holder, int256 shares) {
        _stakeHolders[holder].ptsCorrection += int256(_pointsPerShare) * shares;
        _;
    }

    function _sharesOf(address holder) internal virtual view returns (int256);
    function _totalShares() internal virtual view returns (uint256);

    function totalDistributed() external view override returns (uint256) {
        return _totalDistributed;
    }

    function withdrawableBy(address holder) public view override returns (uint256) {
        int256 correction = _stakeHolders[holder].ptsCorrection;
        int256 cumulative = (int256(_pointsPerShare) * _sharesOf(holder) + correction) / int256(PM);
        int256 withdrawn = int256(withdrawnBy(holder));
        uint256 r = cumulative > withdrawn ? uint256(cumulative - withdrawn) : 0;
        return r;
    }

    function withdrawnBy(address holder) public view override returns (uint256) {
        return _stakeHolders[holder].withdrawn;
    }

    function undistributedBalance() public view override returns (uint256) {
        uint256 contractBalance = address(this).balance.sub(_ownerBalance);
        uint256 undistributed = contractBalance > _expectedBalance ? contractBalance.sub(_expectedBalance) : 0;
        return undistributed;
    }

    function distribute() external override {
        _distribute(undistributedBalance());
    }

    function _distribute(uint256 amount) internal {
        require(_totalShares() > 0, "no stakeholders");
        if (amount > 0) {
            _totalDistributed += amount;
            _expectedBalance += amount;
            _pointsPerShare = amount.mul(PM).div(_totalShares()).add(_pointsPerShare);
            emit PaymentDistributed(amount);
        }
    }

    function _stake(address holder, uint256 shares) internal correctPts(holder, -int256(shares)) {
    }

    function _unstake(address holder, uint256 shares) internal correctPts(holder, int256(shares)) {
    }

    function _increaseOwnerBalance(uint256 amount) internal {
        _ownerBalance = _ownerBalance.add(amount);
    }

    function _decreaseOwnerBalance(uint256 amount) internal {
        _ownerBalance = _ownerBalance.sub(amount);
    }

    function _getOwnerBalance() internal view returns (uint256) {
        return _ownerBalance;
    }

    function _withdrawFor(address payable holder) internal {
        uint256 amount = withdrawableBy(holder);
        if (amount == 0) return;

        uint256 contractBalance = address(this).balance - _ownerBalance;
        require(contractBalance >= amount, "unexpected balance state");

        _stakeHolders[holder].withdrawn += amount;
        _expectedBalance -= amount;
        emit Withdrawn(holder, amount);
        holder.transfer(amount);
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
}//Unlicense
pragma solidity ^0.8.0;

interface IKillswitch {
    function isEnabled() external view returns (bool);
    function enableContract() external;
    function disableContract() external;
}//Unlicense
pragma solidity ^0.8.0;


contract Killswitch is Ownable, IKillswitch {
    bool private _enabled = false;

    modifier killswitch() {
        require(!!_enabled, "contract disabled");
        _;
    }

    function isEnabled() external view override returns (bool)
    {
        return _enabled;
    }

    function enableContract() public override onlyOwner {
        _enabled = true;
    }

    function disableContract() public override onlyOwner {
        _enabled = false;
    }
}//Unlicense
pragma solidity ^0.8.0;


interface IBMShares is IDividends, IERC20, IKillswitch {
    function mintForHoney(address for_, uint256 amount, uint256 value) external;
    function mintForEth(address for_, uint256 amount) external payable;

    function getPriceEth() external view returns (uint256);
    function getPriceHoney() external view returns (uint256);

    function availableForEth() external view returns (uint256);

    function setPriceEth(uint256 price) external;
    function setPriceHoney(uint256 price) external;
}//Unlicense
pragma solidity ^0.8.0;

interface IValidator {
    function allowValidator(address validatorAddress) external;
    function disallowValidator(address validatorAddress) external;
}//Unlicense
pragma solidity ^0.8.0;


interface IHoney is IERC20, IValidator {
    function mint(address for_, uint256 amount) external;
    function burn(address for_, uint256 amount) external;
}//Unlicense
pragma solidity ^0.8.0;




contract BMShares is IBMShares, ERC20, AbstractDividends, Killswitch {
    using CCMath for uint256;

    IHoney private _honey;

    uint256 private priceHoney = 0;
    uint256 private priceEth = 0;

    uint256 private constant MAX_SUPPLY = 500e6;
    uint256 private constant MINTABLE_FOR_ETH_SUPPLY = 100e6;
    uint256 private mintedForEth = 0;

    constructor(string memory name_, string memory symbol_, IHoney honey) ERC20(name_, symbol_) {
        require(address(honey) != address(0), "IHoney must be specified");
        _honey = honey;
        _mintInternal(msg.sender, 10000);

        setPriceEth(1e14);
        setPriceHoney(10e18);
    }

    function mintForHoney(address for_, uint256 amount, uint256 value) external override killswitch {
        require(value >= amount * priceHoney, "value doesn't match");
        address spender = msg.sender;
        _honey.burn(spender, priceHoney * amount);
        _mintInternal(for_, amount);
    }

    function mintForEth(address for_, uint256 amount) external override payable killswitch {
        require(mintedForEth + amount <= MINTABLE_FOR_ETH_SUPPLY, "can't mint above allowed");
        require(msg.value >= amount * priceEth, "value doesn't match");
        mintedForEth = mintedForEth.add(amount);
        _mintInternal(for_, amount);

        _increaseOwnerBalance(msg.value);
    }

    function _mintInternal(address for_, uint256 amount) private {
        require(amount > 0, "0 amount");
        require(totalSupply() + amount <= MAX_SUPPLY, "can't mint above MAX_SUPPLY");
        _mint(for_, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 0;
    }

    function _sharesOf(address holder) internal override view returns (int256) {
        return int256(balanceOf(holder));
    }

    function _totalShares() internal override view returns (uint256)
    {
        return totalSupply();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        if (from != address(0)) {
            _unstake(from, amount);
        }

        if (to != address(0)) {
            _stake(to, amount);
        }
    }

    function getPriceEth() external view override returns (uint256) {
        return priceEth;
    }

    function getPriceHoney() external view override returns (uint256) {
        return priceHoney;
    }

    function availableForEth() external view override returns (uint256) {
        return MINTABLE_FOR_ETH_SUPPLY.sub(mintedForEth);
    }

    function setPriceEth(uint256 price) public override onlyOwner {
        priceEth = price;
    }

    function setPriceHoney(uint256 price) public override onlyOwner {
        priceHoney = price;
    }

    function withdrawDividends() external override {
        _withdrawFor(payable(msg.sender));
    }

    function withdraw() external override onlyOwner {
        uint256 amount = _getOwnerBalance();
        _decreaseOwnerBalance(amount);
        address payable to_ = payable(owner());
        to_.transfer(amount);
    }

    receive() external payable {
    }
}