
pragma solidity ^0.5.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value)
        private
        view
        returns (bool)
    {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index)
        private
        view
        returns (bytes32)
    {

        require(
            set._values.length > index,
            "EnumerableSet: index out of bounds"
        );
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index)
        internal
        view
        returns (address)
    {

        return address(uint256(_at(set._inner, index)));
    }


    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value)
        internal
        returns (bool)
    {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value)
        internal
        view
        returns (bool)
    {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index)
        internal
        view
        returns (uint256)
    {

        return uint256(_at(set._inner, index));
    }
}


library SafeMath {


    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

}

contract Token {

    function totalSupply() public view returns (uint256 supply);


    function balanceOf(address _owner) public view returns (uint256 balance);


    function transfer(address _to, uint256 _value)
        public
        returns (bool success);


    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success);


    function approve(address _spender, uint256 _value)
        public
        returns (bool success);


    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining);

    
    function burn(uint256 amount) public;


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}


contract DepositKAI {

    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    constructor(address[] memory _valAddr) public {
        owner = msg.sender;
        for(uint i=0; i<_valAddr.length; i++) {
            valAddr.push(_valAddr[i]);
        }

        isRefundAble = false;
    }
    
    address constant KAI_ADDRESS = 0xD9Ec3ff1f8be459Bb9369b4E79e9Ebcf7141C093;
    uint256 constant public MIN_DEPOSIT = 25000000000000000000000; // 25K KAI
    uint256 constant public MIN_VALIDATOR_AMOUNT = 12500000000000000000000000; // 12,5M kai
    
    address private owner;
    uint256 public currentCap;
    mapping (address => mapping(address => uint256)) public delAmount;
    mapping (address => uint256) public valAmount;
    mapping (address => EnumerableSet.AddressSet) private dels;
    address[] public winValAddr;
    address[] public valAddr;
    bool public isRefundAble;

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }
    
    function depositKAI(address _valAddr ,uint256 _amount) public {

        require(_amount >= MIN_DEPOSIT, "Amount must be greater or equal 25000 KAI");
        require(isWinValAddr(_valAddr) == false, "The validator is win");
        require(winValAddr.length < 5, "The campaign is ended");
        require(Token(KAI_ADDRESS).transferFrom(msg.sender, address(this), _amount));

        if(!dels[_valAddr].contains(msg.sender)) {
            dels[_valAddr].add(msg.sender);
        }
        delAmount[msg.sender][_valAddr] += _amount;
        currentCap = currentCap.add(_amount);
        valAmount[_valAddr] +=  _amount;

        if (valAmount[_valAddr] >= MIN_VALIDATOR_AMOUNT){
            winValAddr.push(_valAddr);
        }
    }
    
    function burnKAI() public onlyOwner {

        Token(KAI_ADDRESS).burn(getBalanceKAIContract());
    }
    
    function withdrawKAI(address _valAddr) public {

        require(isRefundAble == true, "Is not withdrawable yet");
        require(winValAddr.length == 5, "The campaign is ended");
        require(isWinValAddr(_valAddr) == false, "This is not a winner");
        require(delAmount[msg.sender][_valAddr] > 0, "Can only withdraw once");
    
        uint256 amount = delAmount[msg.sender][_valAddr];
        Token(KAI_ADDRESS).transfer(msg.sender, amount);
        delAmount[msg.sender][_valAddr] = 0;
    }
    
    function getBalanceKAIContract() public view returns (uint256) {

        return Token(KAI_ADDRESS).balanceOf(address(this));
    }
    
    function getWinValidatorLength() public view returns (uint256) {

        return winValAddr.length;
    }

    function getValidatorLength() public view returns (uint256) {

        return valAddr.length;
    }

    function getDelegators(address _valAddr) public view returns (address[] memory, uint256[] memory) {

        uint256 totalDels = dels[_valAddr].length();
        address[] memory delegators = new address[](totalDels);
        uint256[] memory amount = new uint256[](totalDels);
        
        for (uint i=0; i<totalDels; i++){
            delegators[i] = dels[_valAddr].at(i);
            amount[i] = delAmount[delegators[i]][_valAddr];
        }
        return (delegators,amount);
    }

    function isWinValAddr(address _valAddr) public view returns(bool) {

        for (uint i=0; i<winValAddr.length; i++) {
            if (winValAddr[i] == _valAddr) {
                return true;
            }
        }
      return false;
    }
    
    function addValAddr(address _valAddr) public onlyOwner {

        valAddr.push(_valAddr);
    }

    function setIsRefundAble() public onlyOwner {

        isRefundAble = true;
    }

    function emergencyWithdrawalKAI(uint256 amount) public onlyOwner {

        Token(KAI_ADDRESS).transfer(msg.sender, amount);
    }  
}