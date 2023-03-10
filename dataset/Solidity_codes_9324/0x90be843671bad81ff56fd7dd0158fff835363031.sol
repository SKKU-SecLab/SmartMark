
pragma solidity ^0.5.0;

contract ExpTokenInterface {

    function name() public view returns (string memory _name);

    function symbol() public view returns (string memory _symbol);

    function decimals() public view returns (uint8 _decimals);

    function totalSupply() public view returns (uint256 _supply);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value, bytes32 data) public;

    function transferByOwner(address _from, address _to, uint _value, bytes32 _data) public;

    function mint(address _to, uint256 _unitAmount) public;

    function burn(address _from, uint256 _unitAmount) public;

    event Transfer(address indexed from, address indexed to, uint256 value, bytes32 indexed data);
    event Burn(address indexed from, uint256 amount);
    event Mint(address indexed to, uint256 amount);
}

contract Ownable {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function setOwner() internal {

        require(_owner == address(0), "failure");
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

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

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

contract ERC223ReceivingContract { 

    function tokenFallback(address _from, uint256 _value, bytes32 _data) public {}

}

contract ExpToken_v1 is ExpTokenInterface, Ownable {
    using SafeMath for uint256;
    
    mapping(address => uint256) balances;
    string constant public Name = "NC Exp Token";
    string constant public Symbol = "NCE";
    uint8 constant public Decimals = 0;
    uint256 public total_supply;
    
    function initialize(uint256 initial_supply) public {
        require(owner()  == address(0), "failure");
        setOwner();
        total_supply = initial_supply;
        balances[owner()] = total_supply;
    }

    function name() public view returns (string memory _name) { return Name; }
    function symbol() public view returns (string memory _symbol) { return Symbol;}
    function decimals() public view returns (uint8 _decimals) {return Decimals;}
    function totalSupply() public view returns (uint256 _total_supply) {return total_supply;}

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transferByOwner(address _from, address _to, uint _value, bytes32 _data) public onlyOwner {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);

        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(_from, _value, _data);
        }
        emit Transfer(_from, _to, _value, _data);
    }

    function transfer(address _to, uint256 _value, bytes32 _data) public {
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);

        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value, _data);
    }
    function mint(address _to, uint256 _unitAmount) public onlyOwner {
        require(_unitAmount > 0, "fail mint");
        bytes32 empty;
        uint codeLength;
        assembly {
            codeLength := extcodesize(_to)
        }

        total_supply = total_supply.add(_unitAmount);
        balances[_to] = balances[_to].add(_unitAmount);
        if(codeLength>0) {
            ERC223ReceivingContract receiver = ERC223ReceivingContract(_to);
            receiver.tokenFallback(address(0), _unitAmount, empty);
        }
        emit Mint(_to, _unitAmount);
        emit Transfer(address(0), _to, _unitAmount, empty);
    }

    function burn(address _from, uint256 _unitAmount)  public onlyOwner {
        require(_unitAmount > 0 && balances[_from] >= _unitAmount, "fail burn");

        balances[_from] = balances[_from].sub(_unitAmount);
        total_supply = total_supply.sub(_unitAmount);
        emit Burn(_from, _unitAmount);
    }

}