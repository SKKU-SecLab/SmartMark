
pragma solidity ^0.5.8;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0);
        return a % b;
    }
}

interface IERC20 {

    function transfer(address to, uint256 value) external returns (bool);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address who) external view returns (uint256);

    function allowance(address owner, address spender) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner());
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }
}

contract Delegable is Ownable {

    address private _delegator;
    
    event DelegateAppointed(address indexed previousDelegator, address indexed newDelegator);
    
    constructor () internal {
        _delegator = address(0);
    }
    
    function delegator() public view returns (address) {

        return _delegator;
    }
    
    modifier onlyDelegator() {

        require(isDelegator());
        _;
    }
    
    modifier ownerOrDelegator() {

        require(isOwner() || isDelegator());
        _;
    }
    
    function isDelegator() public view returns (bool) {

        return msg.sender == _delegator;
    }
    
    function appointDelegator(address delegator_) public onlyOwner returns (bool) {

        require(delegator_ != address(0));
        require(delegator_ != owner());
        return _appointDelegator(delegator_);
    }
    
    function dissmissDelegator() public onlyOwner returns (bool) {

        require(_delegator != address(0));
        return _appointDelegator(address(0));
    }
    
    function _appointDelegator(address delegator_) private returns (bool) {

        require(_delegator != delegator_);
        emit DelegateAppointed(_delegator, delegator_);
        _delegator = delegator_;
        return true;
    }
}

contract ERC20Like is IERC20, Delegable {

    using SafeMath for uint256;

    uint256 internal _totalSupply;  // 총 발행량 // Total Supply
    bool isLock = false;  // 계약 잠금 플래그 // Contract Lock Flag

    struct TokenContainer {
        uint256 balance;  // 가용잔액 // available balance
        mapping (address => uint256) allowed; // Spender
    }

    mapping (address => TokenContainer) internal _tokenContainers;
    
    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address holder) public view returns (uint256) {

        return _tokenContainers[holder].balance;
    }

    function allowance(address holder, address spender) public view returns (uint256) {

        return _tokenContainers[holder].allowed[spender];
    }

    function transfer(address to, uint256 value) public returns (bool) {

        _transfer(msg.sender, to, value);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {

        _approve(msg.sender, spender, value);
        return true;
    }
    
    function approveDelegator(address spender, uint256 value) public onlyDelegator returns (bool) {

        require(msg.sender == delegator());
        _approve(owner(), spender, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool) {

        _transfer(from, to, value);
        _approve(from, msg.sender, _tokenContainers[from].allowed[msg.sender].sub(value));
        return true;
    }
    
    function transferDelegator(address to, uint256 value) public onlyDelegator returns (bool) {

        require(msg.sender == delegator());
        _transfer(owner(), to, value);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {

        require(!isLock);
        uint256 value = _tokenContainers[msg.sender].allowed[spender].add(addedValue);
        _approve(msg.sender, spender, value);
        return true;
    }
    
    function increaseAllowanceDelegator(address spender, uint256 addedValue) public onlyDelegator returns (bool) {

        require(msg.sender == delegator());
        require(!isLock);
        uint256 value = _tokenContainers[owner()].allowed[spender].add(addedValue);
        _approve(owner(), spender, value);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {

        require(!isLock);
        if (_tokenContainers[msg.sender].allowed[spender] < subtractedValue) {
            subtractedValue = _tokenContainers[msg.sender].allowed[spender];
        }
        
        uint256 value = _tokenContainers[msg.sender].allowed[spender].sub(subtractedValue);
        _approve(msg.sender, spender, value);
        return true;
    }
    
    function decreaseAllowanceDelegator(address spender, uint256 subtractedValue) public onlyDelegator returns (bool) {

        require(msg.sender == delegator());
        require(!isLock);
        if (_tokenContainers[owner()].allowed[spender] < subtractedValue) {
            subtractedValue = _tokenContainers[owner()].allowed[spender];
        }
        
        uint256 value = _tokenContainers[owner()].allowed[spender].sub(subtractedValue);
        _approve(owner(), spender, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) private {

        require(!isLock);
        require(to != address(this));
        require(to != address(0));

        _tokenContainers[from].balance = _tokenContainers[from].balance.sub(value);
        _tokenContainers[to].balance = _tokenContainers[to].balance.add(value);
        emit Transfer(from, to, value);
    }

    function _approve(address holder, address spender, uint256 value) private {

        require(!isLock);
        require(spender != address(0));
        require(holder != address(0));

        _tokenContainers[holder].allowed[spender] = value;
        emit Approval(holder, spender, value);
    }

    function circulationAmount() external view returns (uint256) {

        return _totalSupply.sub(_tokenContainers[owner()].balance);
    }

    function lock() external onlyOwner returns (bool) {

        isLock = true;
        return isLock;
    }

    function unlock() external onlyOwner returns (bool) {

        isLock = false;
        return isLock;
    }
}

contract RIDER is ERC20Like {

    string public constant name = "RIDER";
    string public constant symbol = "RDR";
    uint256 public constant decimals = 18;
    
    event CreateToken(address indexed c_owner, string c_name, string c_symbol, uint256 c_totalSupply);

    constructor () public {
        _totalSupply = 3000000000 * (10 ** decimals);
        _tokenContainers[msg.sender].balance = _totalSupply;
        emit CreateToken(msg.sender, name, symbol, _tokenContainers[msg.sender].balance);
    }
}