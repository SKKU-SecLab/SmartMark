
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


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

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
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
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

pragma solidity ^0.8.0;

library MathUpgradeable {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
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

}//MIT
pragma solidity ^0.8.0;


contract CollarERC20 is Ownable, ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }

    function drop(uint256 amount) public {
        _burn(msg.sender, amount);
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract Collar is Initializable {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    uint256 public rate;

    function initialize() public virtual initializer {
        rate = 1e18 + 1;
    }

    function mint_dual(uint256 n) public before_expiry {
        send_call(n);
        send_coll(n);
        recv_bond(n);
    }

    function mint_coll(uint256 n) public before_expiry {
        send_coll(n);
        recv_want(n);
    }

    function burn_dual(uint256 n) public before_expiry {
        recv_call(n);
        recv_coll(n);
        send_bond(n);
    }

    function burn_call(uint256 n) public before_expiry {
        recv_call(n);
        recv_want(n);
        send_bond(n);
    }

    function burn_coll(uint256 n) public {
        uint256 rw = rate;
        uint256 rb = 1e18 - rw;
        recv_coll(n);
        send_want((n * rw) / 1e18);
        send_bond((n * rb) / 1e18);
    }

    function expire() public {
        require(rate > 1e18);
        uint256 time = expiry_time();
        require(block.timestamp > time);
        uint256 nw = get_want_norm();
        uint256 nw0 = get_coll_norm();
        if (nw >= nw0) {
            rate = 1e18;
        } else {
            rate = (nw * 1e18) / nw0;
        }
    }

    function send_call(uint256 n) internal virtual {
        address call = address_call();
        CollarERC20(call).mint(msg.sender, n);
    }

    function send_coll(uint256 n) internal virtual {
        address coll = address_coll();
        CollarERC20(coll).mint(msg.sender, n);
    }

    function recv_call(uint256 n) internal virtual {
        address call = address_call();
        CollarERC20(call).burn(msg.sender, n);
    }

    function recv_coll(uint256 n) internal virtual {
        address coll = address_coll();
        CollarERC20(coll).burn(msg.sender, n);
    }

    function send_want(uint256 n) internal virtual {
        address want = address_want();
        n = norm_want_min(n);
        IERC20Upgradeable(want).safeTransfer(msg.sender, n);
    }

    function send_bond(uint256 n) internal virtual {
        address bond = address_bond();
        n = norm_bond_min(n);
        IERC20Upgradeable(bond).safeTransfer(msg.sender, n);
    }

    function recv_want(uint256 n) internal virtual {
        address want = address_want();
        n = norm_want_max(n);
        IERC20Upgradeable(want).safeTransferFrom(msg.sender, address(this), n);
    }

    function recv_bond(uint256 n) internal virtual {
        address bond = address_bond();
        n = norm_bond_max(n);
        IERC20Upgradeable(bond).safeTransferFrom(msg.sender, address(this), n);
    }

    function norm_bond_max(uint256 n) public view virtual returns (uint256) {
        return n;
    }

    function norm_bond_min(uint256 n) public view virtual returns (uint256) {
        return n;
    }

    function norm_want_max(uint256 n) public view virtual returns (uint256) {
        return n;
    }

    function norm_want_min(uint256 n) public view virtual returns (uint256) {
        return n;
    }

    function get_coll_norm() internal view virtual returns (uint256) {
        address coll = address_coll();
        uint256 num = CollarERC20(coll).totalSupply();
        return norm_want_max(num);
    }

    function get_want_norm() internal view virtual returns (uint256) {
        address want = address_want();
        return IERC20Upgradeable(want).balanceOf(address(this));
    }

    function expiry_time() public pure virtual returns (uint256);

    function address_bond() public pure virtual returns (address);

    function address_want() public pure virtual returns (address);

    function address_call() public pure virtual returns (address);

    function address_coll() public pure virtual returns (address);

    function address_collar() public pure virtual returns (address);

    modifier before_expiry() {
        uint256 time = expiry_time();
        require(block.timestamp < time);
        _;
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract CIPSwap is ERC20Upgradeable, Collar {
    uint256 public sx;
    uint256 public sy;

    function initialize() public virtual override initializer {
        super.initialize();
        __Context_init_unchained();
        __ERC20_init_unchained("Collar Liquidity Proof Token", "CLPT");
    }

    function swap_coll_to_min_want(uint256 dx, uint256 mindy) public {
        uint256 fee = swap_fee();
        uint256 dy = calc_dy(sx, sy, dx);
        dy = (dy * fee) / 1e18;
        require(dy >= mindy, "insufficient fund");
        sx += dx;
        sy -= dy;
        recv_coll(dx);
        send_want(dy);
    }

    function swap_want_to_min_coll(uint256 mindx, uint256 dy) public {
        uint256 fee = swap_fee();
        uint256 dx = calc_dx(sx, sy, dy);
        dx = (dx * fee) / 1e18;
        require(dx >= mindx, "insufficient fund");
        sx -= dx;
        sy += dy;
        send_coll(dx);
        recv_want(dy);
    }

    function mint(
        uint256 dx,
        uint256 dy,
        uint256 mindk
    ) public {
        uint256 k = calc_k(sx, sy);
        uint256 nk = calc_k(sx + dx, sy + dy);
        uint256 dk = nk - k;
        require(dk >= mindk, "insufficient fund");
        sx += dx;
        sy += dy;
        _mint(msg.sender, dk);
        recv_coll(dx);
        recv_want(dy);
    }

    function burn(uint256 dk) public {
        uint256 k = calc_k(sx, sy);
        uint256 dx = (sx * dk) / k;
        uint256 dy = (sy * dk) / k;
        dx = (dx * swap_fee()) / 1e18;
        dy = (dy * swap_fee()) / 1e18;
        sx -= dx;
        sy -= dy;
        _burn(msg.sender, dk);
        send_coll(dx);
        send_want(dy);
    }

    function get_coll_norm() internal view virtual override returns (uint256) {
        return super.get_coll_norm() + norm_want_max(sx);
    }

    function get_want_norm() internal view virtual override returns (uint256) {
        return super.get_want_norm() - norm_want_max(sy);
    }

    function sk() public view returns (uint256) {
        return calc_k(sx, sy);
    }

    function calc_dx(
        uint256 x,
        uint256 y,
        uint256 dy
    ) public pure returns (uint256) {
        uint256 k = calc_k(x, y) + 1;
        uint256 nx = calc_x(k, y + dy) + 1;
        if (x <= nx) {
            return 0;
        }
        unchecked {return x - nx;}
    }

    function calc_dy(
        uint256 x,
        uint256 y,
        uint256 dx
    ) public pure returns (uint256) {
        uint256 k = calc_k(x, y) + 1;
        uint256 ny = calc_y(k, x + dx) + 1;
        if (y <= ny) {
            return 0;
        }
        unchecked {return y - ny;}
    }

    function calc_x(uint256 k, uint256 y) public pure returns (uint256) {
        uint256 a = swap_sqp();
        uint256 ye9 = y * 1e9;
        uint256 ak = a * k;
        return (k * k * 1e9) / (ye9 + ak) - k;
    }

    function calc_y(uint256 k, uint256 x) public pure returns (uint256) {
        uint256 a = swap_sqp();
        uint256 ak = a * k;
        uint256 X = x + k;
        return (k * k * 1e9 - ak * X) / (X * 1e9);
    }

    function calc_k(uint256 x, uint256 y) public pure returns (uint256) {
        uint256 a = swap_sqp();
        uint256 ye9 = y * 1e9;
        uint256 ax = a * x;
        uint256 a_ = 1e9 - a;
        uint256 D = (ax + ye9)**2 + 4 * x * ye9 * a_;
        return (sqrt(D) + ye9 + ax) / (2 * a_);
    }

    function sqrt(uint256 x) internal pure returns (uint256) {
        if (x == 0) return 0;
        uint256 xx = x;
        uint256 r = 1;
        if (xx >= 0x100000000000000000000000000000000) {
            xx >>= 128;
            r <<= 64;
        }
        if (xx >= 0x10000000000000000) {
            xx >>= 64;
            r <<= 32;
        }
        if (xx >= 0x100000000) {
            xx >>= 32;
            r <<= 16;
        }
        if (xx >= 0x10000) {
            xx >>= 16;
            r <<= 8;
        }
        if (xx >= 0x100) {
            xx >>= 8;
            r <<= 4;
        }
        if (xx >= 0x10) {
            xx >>= 4;
            r <<= 2;
        }
        if (xx >= 0x8) {
            r <<= 1;
        }
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        r = (r + x / r) >> 1;
        uint256 r1 = x / r;
        return (r < r1 ? r : r1);
    }

    function swap_sqp() public pure virtual returns (uint256) {
        return 950000000;
    }

    function swap_fee() public pure virtual returns (uint256) {
        return 9999e14;
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract CIPStaking is OwnableUpgradeable, CIPSwap {
    using SafeERC20Upgradeable for IERC20Upgradeable;
    using MathUpgradeable for uint256;

    uint256 public reward_rate;
    uint256 public reward_per_token_stored;
    uint256 public last_time_updated;
    mapping(address => uint256) public paid;
    mapping(address => uint256) public rewards;

    function initialize() public virtual override initializer {
        super.initialize();
        __Ownable_init_unchained();
    }

    function claim_reward() public {
        sync_reward();
        sync_account(msg.sender);
        uint256 reward = rewards[msg.sender];
        if (reward > 0) {
            rewards[msg.sender] = 0;
            address collar = address_collar();
            IERC20Upgradeable(collar).safeTransfer(msg.sender, reward);
        }
    }

    function start_reward(uint256 rate) external onlyOwner {
        sync_reward();
        reward_rate = rate;
    }

    function reward_per_token() public view returns (uint256) {
        uint256 ts = totalSupply();

        if (ts == 0) {
            return reward_per_token_stored;
        }

        uint256 time = reward_end().min(block.timestamp);
        time -= last_time_updated;
        return (time * reward_rate * 1e18) / ts + reward_per_token_stored;
    }

    function earned(address account) public view returns (uint256) {
        uint256 result = balanceOf(account);
        uint256 reward = reward_per_token() - paid[account];
        return (result * reward) / 1e18 + rewards[account];
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256
    ) internal override {
        sync_reward();
        if (from != address(0)) {
            sync_account(from);
        }
        if (to != address(0)) {
            sync_account(to);
        }
    }

    function sync_reward() internal {
        reward_per_token_stored = reward_per_token();
        last_time_updated = reward_end().min(block.timestamp);
    }

    function sync_account(address account) internal {
        rewards[account] = earned(account);
        paid[account] = reward_per_token_stored;
    }

    function reward_end() public pure virtual returns (uint256) {
        return 2008000000;
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract CHCCollect is CIPStaking {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function burn_coll_want_only(uint256 n) public {
        require(rate == 1e18);
        recv_coll(n);
        send_coll(n);
    }

    function burn_coll_bond_only(uint256 n) public {
        require(rate == 0);
        recv_coll(n);
        send_bond(n);
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract CHSLite is CIPStaking {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function borrow_want(uint256 nb, uint256 minnw) public {
        mint_dual(nb);
        swap_coll_to_min_want(nb, minnw);
    }

    function repay_both(uint256 nw, uint256 no) public {
        burn_dual(no);
        burn_call(nw);
    }

    function withdraw_both(uint256 dk) public {
        burn(dk);
    }

    function get_dx(uint256 dy) public view returns (uint256) {
        return calc_dx(sx, sy, dy);
    }

    function get_dy(uint256 dx) public view returns (uint256) {
        return calc_dy(sx, sy, dx);
    }

    function get_dk(uint256 dx, uint256 dy) public view returns (uint256) {
        uint256 k = calc_k(sx, sy);
        uint256 nk = calc_k(sx + dx, sy + dy);
        return nk - k;
    }

    function get_dxdy(uint256 dk) public view returns (uint256, uint256) {
        uint256 k = calc_k(sx, sy);
        uint256 dx = (sx * dk) / k;
        uint256 dy = (sy * dk) / k;
        return (dx, dy);
    }
    
    function burn_and_claim(uint256 dk) public {
        burn(dk);
        claim_reward();
    }
}//MIT
pragma solidity ^0.8.0;



abstract contract CHSSwap is CIPSwap {
    using SafeERC20Upgradeable for IERC20Upgradeable;

    function borrow_want(uint256 nb, uint256 minnw) public {
        mint_dual(nb);
        swap_coll_to_min_want(nb, minnw);
    }

    function repay_both(uint256 nw, uint256 no) public {
        burn_dual(no);
        burn_call(nw);
    }

    function withdraw_both(uint256 dk) public {
        burn(dk);
    }

    function get_dx(uint256 dy) public view returns (uint256) {
        return calc_dx(sx, sy, dy);
    }

    function get_dy(uint256 dx) public view returns (uint256) {
        return calc_dy(sx, sy, dx);
    }

    function get_dk(uint256 dx, uint256 dy) public view returns (uint256) {
        uint256 k = calc_k(sx, sy);
        uint256 nk = calc_k(sx + dx, sy + dy);
        return nk - k;
    }

    function get_dxdy(uint256 dk) public view returns (uint256, uint256) {
        uint256 k = calc_k(sx, sy);
        uint256 dx = (sx * dk) / k;
        uint256 dy = (sy * dk) / k;
        return (dx, dy);
    }
}//MIT
pragma solidity ^0.8.0;


contract CoverCollarPool is CIPSwap, CHSSwap {
    function address_bond() public pure override returns (address) {
        return 0x4688a8b1F292FDaB17E9a90c8Bc379dC1DBd8713;
    }

    function address_want() public pure override returns (address) {
        return 0x11facD2B150caDD5322AeB62219cBF9A3cF8Da79;
    }

    function address_coll() public pure override returns (address) {
        return 0xC5fb11512E724941b8Ed28966459Ac8e9332507E;
    }

    function address_call() public pure override returns (address) {
        return 0xc8f6E9E7E3b106Bcc5f8c1Cf8Ab3dBC1D0a256c4;
    }

    function address_collar() public pure override returns (address) {
        return 0x11facD2B150caDD5322AeB62219cBF9A3cF8Da79;
    }

    function expiry_time() public pure override returns (uint256) {
        return 1696118400;
    }
}

contract RulerCollarPool is CIPSwap, CHSSwap {
    function address_bond() public pure override returns (address) {
        return 0x2aECCB42482cc64E087b6D2e5Da39f5A7A7001f8;
    }

    function address_want() public pure override returns (address) {
        return 0x46D9464fA3ebF33A1f9B22CE93024fb8A8122404;
    }

    function address_coll() public pure override returns (address) {
        return 0x6F85f9e369e8777cAeCaBc3fcd7f3997838AbF0f;
    }

    function address_call() public pure override returns (address) {
        return 0x4ab83FDe6ADaB8a2d049eEF050e603040afa8D13;
    }

    function address_collar() public pure override returns (address) {
        return 0x46D9464fA3ebF33A1f9B22CE93024fb8A8122404;
    }

    function expiry_time() public pure override returns (uint256) {
        return 1696118400;
    }
}

