


pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.6.0;

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





pragma solidity ^0.6.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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





pragma solidity ^0.6.0;


contract Pausable is Context {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}





pragma solidity 0.6.8;


contract WhitelistedOperators is Ownable {


    mapping(address => bool) internal _whitelistedOperators;

    event WhitelistedOperator(address operator, bool enabled);

    function whitelistOperator(address operator, bool enabled) external onlyOwner {

        _whitelistedOperators[operator] = enabled;
        emit WhitelistedOperator(operator, enabled);
    }

    function isOperator(address who) public view returns (bool) {

        return _whitelistedOperators[who];
    }
}





pragma solidity ^0.6.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}





pragma solidity ^0.6.0;


contract ERC165 is IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}





pragma solidity ^0.6.2;

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

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {

        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
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
}






pragma solidity 0.6.8;

interface IERC20 {


    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value
    );

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}






pragma solidity 0.6.8;

interface IERC20Detailed {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function decimals() external view returns (uint8);

}





pragma solidity 0.6.8;

interface IERC20Allowance {


    function increaseAllowance(address spender, uint256 addedValue) external returns (bool);


    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool);


}






pragma solidity 0.6.8;








abstract contract ERC20 is ERC165, Context, IERC20, IERC20Detailed, IERC20Allowance {

    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
    uint256 internal _totalSupply;

    constructor() internal {
        _registerInterface(type(IERC20).interfaceId);
        _registerInterface(type(IERC20Detailed).interfaceId);
        _registerInterface(type(IERC20Allowance).interfaceId);

        _registerInterface(0x06fdde03);
        _registerInterface(0x95d89b41);
        _registerInterface(0x313ce567);
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


    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual override returns (bool)
    {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual override returns (bool)
    {
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


    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}





pragma solidity 0.6.8;



abstract contract ERC20WithOperators is ERC20, WhitelistedOperators {

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        address msgSender = _msgSender();

        if (!isOperator(msgSender)) {
            _approve(sender, msgSender, allowance(sender, msgSender).sub(amount));
        }

        _transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public override view returns (uint256) {
        if (isOperator(spender)) {
            return type(uint256).max;
        } else {
            return super.allowance(owner, spender);
        }
    }

    function increaseAllowance(address spender, uint256 addedValue) public override returns (bool) {
        if (isOperator(spender)) {
            return true;
        } else {
            return super.increaseAllowance(spender, addedValue);
        }
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public override returns (bool) {
        if (isOperator(spender)) {
            return true;
        } else {
            return super.decreaseAllowance(spender, subtractedValue);
        }
    }

    function _approve(address owner, address spender, uint256 value) internal override {
        if (isOperator(spender)) {
            return;
        } else {
            super._approve(owner, spender, value);
        }
    }
}





pragma solidity 0.6.8;


contract REVV is ERC20WithOperators {


    string public override constant name = "REVV";
    string public override constant symbol = "REVV";
    uint8 public override constant decimals = 18;

    constructor (
        address[] memory holders,
        uint256[] memory amounts
    ) public ERC20WithOperators()
    {
        require(holders.length == amounts.length, "REVV: wrong arguments");
        for (uint256 i = 0; i < holders.length; ++i) {
            _mint(holders[i], amounts[i]);
        }
    }
}





pragma solidity 0.6.8;







contract PrePaid is Context, Pausable, WhitelistedOperators {

    using SafeMath for uint256;

    event Deposited(
        address wallet,
        uint256 amount
    );

    event Withdrawn(
        address wallet,
        uint256 amount
    );

    event StateChanged(
        uint8 state
    );

    uint8 public constant BEFORE_SALE_STATE = 1;
    uint8 public constant SALE_START_STATE = 2;
    uint8 public constant SALE_END_STATE = 3;

    uint8 public state = BEFORE_SALE_STATE;
    REVV public immutable revv;
    uint256 public globalDeposit = 0;
    uint256 public globalEarnings = 0;
    mapping(address => uint256) public balanceOf; // wallet => escrowed amount

    modifier whenInState(uint8 state_) {

        require(state == state_, "PrePaid: state locked");
        _;
    }

    modifier onlyWhitelistedOperator() {

        require(isOperator(_msgSender()), "PrePaid: invalid operator");
        _;
    }

    constructor(
        REVV revv_
    ) public {
        require(revv_ != REVV(0), "PrePaid: zero address");
        revv = revv_;
        _pause(); // pause on start
    }

    function deposit(
        uint256 amount
    ) external whenNotPaused whenInState(BEFORE_SALE_STATE) {

        require(amount != 0, "PrePaid: zero deposit");
        globalDeposit = globalDeposit.add(amount);
        address sender = _msgSender();
        uint256 newBalance = balanceOf[sender] + amount;
        balanceOf[sender] = newBalance;
        require(
            revv.transferFrom(sender, address(this), amount),
            "PrePaid: transfer in failed"
        );
        emit Deposited(sender, amount);
    }

    function withdraw() external whenInState(SALE_END_STATE) {

        address sender = _msgSender();
        uint256 balance = balanceOf[sender];
        require(balance != 0, "PrePaid: no balance");
        require(
            revv.transfer(sender, balance),
            "PrePaid: transfer out failed"
        );
        balanceOf[sender] = 0;
        emit Withdrawn(sender, balance);
    }

    function consume(
        address wallet,
        uint256 amount
    ) external whenNotPaused whenInState(SALE_START_STATE) onlyWhitelistedOperator {

        require(amount != 0, "PrePaid: zero amount");
        uint256 balance = balanceOf[wallet];
        require(balance >= amount, "PrePaid: insufficient funds");
        balanceOf[wallet] = balance - amount;
        globalEarnings = globalEarnings.add(amount);
    }

    function collectRevenue() external whenInState(SALE_END_STATE) onlyOwner {

        require(globalEarnings != 0, "PrePaid: no earnings");
        require(
            revv.transfer(_msgSender(), globalEarnings),
            "PrePaid: transfer out failed"
        );
        globalEarnings = 0;
    }

    function getDiscount() external view returns (
        uint256
    ) {

        uint256 value = globalDeposit;

        if (value < 2e25) {
            return 0;
        } else if (value < 3e25) {
            return 10;
        } else if (value < 4e25) {
            return 25;
        } else {
            return 50;
        }
    }
    
    function _setSaleState(uint8 state_) internal {

        require(state_ & 0x3 != 0, "PrePaid: invalid state");
        require(state_ != state, "PrePaid: state already set");
        state = state_;
        emit StateChanged(state_);
    }

    function setSaleState(uint8 state_) external onlyOwner {

        _setSaleState(state_);
    }

    function setSaleStart() external onlyWhitelistedOperator {

        _setSaleState(SALE_START_STATE);
    }

    function setSaleEnd() external onlyWhitelistedOperator {

        _setSaleState(SALE_END_STATE);
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }
}





pragma solidity 0.6.8;

