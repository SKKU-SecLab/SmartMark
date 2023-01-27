
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
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
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



contract StarToken is Context, Ownable, ERC20 {
    constructor() Ownable() ERC20("WrappedStar", "WSTR") {}

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function ownerBurn(address from, uint256 amount) external onlyOwner {
        _burn(from, amount);
    }
}// MIT
pragma solidity ^0.8.0;

interface IAzimuth {
    function canSpawnAs(uint32, address) view external returns (bool);
    function canTransfer(uint32, address) view external returns (bool);
    function getPrefix(uint32) external pure returns (uint16);
    function getPointSize(uint32) external pure returns (Size);
    function owner() external returns (address);
    function getSpawnCount(uint32) view external returns (uint32);
    function getSpawnProxy(uint32) view external returns (address);
    enum Size
    {
        Galaxy, // = 0
        Star,   // = 1
        Planet  // = 2
    }
}// MIT
pragma solidity ^0.8.0;

interface IEcliptic {
    function spawn(uint32, address) external;
    function transferPoint(uint32, address, bool) external;
}// MIT
pragma solidity ^0.8.0;



contract Treasury is Context {

    uint16[] public assets;

    IAzimuth public immutable azimuth;

    StarToken public immutable startoken;

    uint256 constant public ONE_STAR = 1e18;


    event Deposit(
        uint16 indexed prefix,
        uint16 indexed star,
        address sender
    );

    event Redeem(
        uint16 indexed prefix,
        uint16 indexed star,
        address sender
    );


    constructor(IAzimuth _azimuth, StarToken _startoken)
    {
        azimuth = _azimuth;
        startoken = _startoken;
    }

    function getAllAssets()
        view
        external
        returns (uint16[] memory allAssets)
    {
        return assets;
    }

    function getAssetCount()
        view
        external
        returns (uint256 count)
    {
        return assets.length;
    }

    function deposit(uint16 _star) external
    {
        require(azimuth.getPointSize(_star) == IAzimuth.Size.Star, "Treasury: must be a star");
        IEcliptic ecliptic = IEcliptic(azimuth.owner());

        if (
            azimuth.canTransfer(_star, _msgSender()) &&
            azimuth.getSpawnCount(_star) == 0 &&
            azimuth.getSpawnProxy(_star) != 0x1111111111111111111111111111111111111111
        ) {
            ecliptic.transferPoint(_star, address(this), true);
        }

        else if (azimuth.canSpawnAs(azimuth.getPrefix(_star), _msgSender())) {
            ecliptic.spawn(_star, address(this));
        }
        else {
            revert();
        }

        assets.push(_star);

        startoken.mint(_msgSender(), ONE_STAR);
        emit Deposit(azimuth.getPrefix(_star), _star, _msgSender());
    }

    function redeem() external returns (uint16) {
        require(startoken.balanceOf(_msgSender()) >= ONE_STAR, "Treasury: Not enough balance");

        require(assets.length > 0, "Treasury: no star available to redeem");

        uint16 _star = assets[assets.length-1];
        assets.pop();

        startoken.ownerBurn(_msgSender(), ONE_STAR);

        IEcliptic ecliptic = IEcliptic(azimuth.owner());
        ecliptic.transferPoint(_star, _msgSender(), true);

        emit Redeem(azimuth.getPrefix(_star), _star, _msgSender());
        return _star;
    }
}