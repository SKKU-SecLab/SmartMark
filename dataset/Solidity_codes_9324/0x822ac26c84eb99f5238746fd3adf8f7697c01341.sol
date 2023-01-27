
pragma solidity 0.5.8;

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
}

contract Ownable {

    address internal _owner;
    address private _pendingOwner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "The caller must be owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Cannot transfer control of the contract to the zero address");
        _pendingOwner = newOwner;
    }

    function receiveOwnership() public {

        require(msg.sender == _pendingOwner);
        emit OwnershipTransferred(_owner, _pendingOwner);
        _owner = _pendingOwner;
        _pendingOwner = address(0);  
    }
}

contract Operable is Ownable {


    address private _operator; 

    event OperatorChanged(address indexed oldOperator, address indexed newOperator);

    function operator() external view returns (address) {

        return _operator;
    }
    
    modifier onlyOperator() {

        require(msg.sender == _operator, "msg.sender should be operator");
        _;
    }

    function isContract(address addr) internal view returns (bool) {

        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function updateOperator(address _newOperator) public onlyOwner {

        require(_newOperator != address(0), "Cannot change the newOperator to the zero address");
        require(isContract(_newOperator), "New operator must be contract address");
        emit OperatorChanged(_operator, _newOperator);
        _operator = _newOperator;
    }

}

contract DUSDStorage is Operable {


    using SafeMath for uint256;
    bool private paused = false;
    mapping (address => uint256) private balances;
    mapping (address => mapping (address => uint256)) private allowances;
    mapping (address=>bool) private blackList;
    string private constant name = "Digital USD";
    string private constant symbol = "DUSD";
    uint8 private constant decimals = 18;
    uint256 private totalSupply;

    constructor() public {
        _owner = 0xfe30e619cc2915C905Ca45C1BA8311109A3cBdB1;
    }
    
    function getTokenName() public view onlyOperator returns (string memory) {

        return name;
    }
    
    function getSymbol() public view onlyOperator returns (string memory) {

        return symbol;
    }
    
    function getDecimals() public view onlyOperator returns (uint8) {

        return decimals;
    }
    
    function getTotalSupply() public view onlyOperator returns (uint256) {

        return totalSupply;
    }

    function getBalance(address _holder) public view onlyOperator returns (uint256) {

        return balances[_holder];
    }

    function addBalance(address _holder, uint256 _value) public onlyOperator {

        balances[_holder] = balances[_holder].add(_value);
    }

    function subBalance(address _holder, uint256 _value) public onlyOperator {

        balances[_holder] = balances[_holder].sub(_value);
    }

    function setBalance(address _holder, uint256 _value) public onlyOperator {

        balances[_holder] = _value;
    }
    
    function getAllowance(address _holder, address _spender) public view onlyOperator returns (uint256) {

        return allowances[_holder][_spender];
    }

    function addAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {

        allowances[_holder][_spender] = allowances[_holder][_spender].add(_value);
    }

    function subAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {

        allowances[_holder][_spender] = allowances[_holder][_spender].sub(_value);
    }

    function setAllowance(address _holder, address _spender, uint256 _value) public onlyOperator {

        allowances[_holder][_spender] = _value;
    }

    function addTotalSupply(uint256 _value) public onlyOperator {

        totalSupply = totalSupply.add(_value);
    }

    function subTotalSupply(uint256 _value) public onlyOperator {

        totalSupply = totalSupply.sub(_value);
    }

    function setTotalSupply(uint256 _value) public onlyOperator {

        totalSupply = _value;
    }

    function addBlackList(address user) public onlyOperator {

        blackList[user] = true;
    }

    function removeBlackList (address user) public onlyOperator {
        blackList[user] = false;
    }
    
    function isBlackList(address user) public view onlyOperator returns (bool) {

        return blackList[user];
    }

    function getPaused() public view onlyOperator returns (bool) {

        return paused;
    }
    
    function pause() public onlyOperator {

        paused = true;
    }
    
    function unpause() public onlyOperator {

        paused = false;
    }

}