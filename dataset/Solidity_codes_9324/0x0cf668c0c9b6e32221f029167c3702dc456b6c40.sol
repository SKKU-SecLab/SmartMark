



interface IyToken {

    function deposit(uint) external;

    function withdraw(uint) external; 


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);     
}





interface Iy_3dToken {

}





interface IERC20 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}





library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}





abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}






contract ERC20 is Context, IERC20 {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view override returns (string memory) {

        return _name;
    }

    function symbol() public view override returns (string memory) {

        return _symbol;
    }

    function decimals() public view override returns (uint8) {

        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view override returns (uint256) {

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
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {

        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual {

        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {

        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal virtual {

        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _setupDecimals(uint8 decimals_) internal {

        _decimals = decimals_;
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }

}





contract Ownable {

    address public _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
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
}

contract y_3dToken is ERC20, Iy_3dToken, Ownable {
    address public _u; // underlying token address
    address public _y; // yToken address
    uint public pool; // How many u token in the pool
    uint8 public _fee; // P3D exit fee

    constructor (address u_token, address y_token, uint8 fee, string memory name, string memory symbol, uint8 decimals, address to) ERC20(name, symbol, decimals) public {
        _u = u_token;
        if (y_token != address(0)) {
            _y = y_token;
            approveUtoY();
        }
        pool = 1; _mint(to, 1); // trick: avoid div by 0
        _fee = fee; _owner = to;
    }

    function stake(uint256 _amount) external {
        require(_amount > 0, "stake amount must be greater than 0");
        ERC20 u = ERC20(_u);
        u.transferFrom(msg.sender, address(this), _amount);
        uint256 shares = (_amount.mul(totalSupply())).div(pool);
        _mint(msg.sender, shares); pool = pool.add(_amount);
    }

    function unstake(uint256 _shares) public {
        require(_shares > 0, "unstake shares must be greater than 0");
        ERC20 u = ERC20(_u);
        uint256 _amount = (pool.mul(_shares)).div(totalSupply());
        _burn(msg.sender, _shares); pool = pool.sub(_amount);
        _amount = _amount.sub(_amount.mul(_fee).div(1000));
        uint256 b = u.balanceOf(address(this));
        if (b < _amount) _withdraw(_amount - b);
        u.transfer(msg.sender, _amount);
    }

    function profit(uint256 _amount) internal {
        require(_amount > 0, "deposit must be greater than 0");
        pool = pool.add(_amount);
    }
    
    function recycle() public {
        profit(ERC20(_u).balanceOf(address(this)).add(1).sub(pool));
    }

    function sync() public {
        _withdrawAll(); recycle(); depositAll();
    }

    function syncAndUnstake(uint256 _shares) external {
        sync(); unstake(_shares);
    }

    function setFee(uint8 fee) external onlyOwner() {
        _fee = fee;
    }

    function setY(address y) public onlyOwner() {
        unApproveUtoY(); _y = y; approveUtoY();
    }

    function unApproveUtoY() internal {
        ERC20(_u).approve(_y, 0);
    }

    function approveUtoY() internal {
        ERC20(_u).approve(_y, uint(-1));
    }    

    function deposit(uint a) public {
        require(a > 0, "deposit amount must be greater than 0");
        IyToken y = IyToken(_y);
        y.deposit(a);
    }
    function depositAll() public {
        ERC20 u = ERC20(_u);
        deposit(u.balanceOf(address(this)));
    }
    function _withdraw(uint s) internal {
        require(s > 0, "withdraw amount must be greater than 0");
        IyToken y = IyToken(_y);
        y.withdraw(s);
    }
    function _withdrawAll() internal {
        IyToken y = IyToken(_y);
        _withdraw(y.balanceOf(address(this)));
    }
    function withdraw(uint s) external onlyOwner() {
        _withdraw(s);
    }    
    function withdrawAll() external onlyOwner() {
        _withdrawAll();
    }
}




pragma solidity ^0.6.0;


contract y_3dFactory {

    event y_3dTokenCreated(address indexed from, address indexed underlying_token, address yToken);

    function y_3d(string memory _) internal pure returns (string memory) {
        return string(abi.encodePacked('y', bytes(_), '3d'));
    }

    function create(address u, address yToken, uint8 fee) external {
        address y = address(
            new y_3dToken(
                u, yToken, fee,
                y_3d(IERC20(u).name()), y_3d(IERC20(u).symbol()),
                IERC20(u).decimals(),
                msg.sender
            )
        );
        emit y_3dTokenCreated(msg.sender, u, y);
    }
}