
pragma solidity ^0.4.24;

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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }



contract GBT {

    string public name; //代币名称
    string public symbol; //代币符号比如'$'
    uint8 public decimals = 4;  //代币单位，展示的小数点后面多少个0,后面是是4个0
    uint256 public totalSupply; //代币总量

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);  //转帐通知事件
    event Burn(address indexed from, uint256 value);  //减去用户余额事件


    constructor(
       uint256 initialSupply, string tokenName, string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);    //带着小数的精度

        balanceOf[msg.sender] = totalSupply;

        name = tokenName;
        symbol = tokenSymbol;
    }


    function _transfer(address _from, address _to, uint256 _value) internal {


      require(_to != 0x0);

      require(balanceOf[_from] >= _value);

      require(balanceOf[_to] + _value > balanceOf[_to]);

      uint previousBalances = balanceOf[_from] + balanceOf[_to];

      balanceOf[_from] -= _value;

      balanceOf[_to] += _value;

      emit  Transfer(_from, _to, _value);

      assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }

    function transfer(address _to, uint256 _value) public {

        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

        require(_value <= allowance[_from][msg.sender]);   // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        require((_value == 0) || (allowance[msg.sender][_spender] == 0));

        allowance[msg.sender][_spender] = _value;
        return true;
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {

        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }

    function burn(uint256 _value) public returns (bool success) {

        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough

        balanceOf[msg.sender] -= _value;

        totalSupply -= _value;

        emit  Burn(msg.sender, _value);
        return true;
    }

    function burnFrom(address _from, uint256 _value) public returns (bool success) {


        require(balanceOf[_from] >= _value);

        require(_value <= allowance[_from][msg.sender]);

        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;

        totalSupply -= _value;
        emit Burn(_from, _value);
        return true;
    }
}

contract QinWa01 is IERC20 {

    address private addrA;
    address private addrB;
    address private addrC;
    address private addrD;
    address private addrToken;
    
    struct Permit {
        bool addrAYes;
        bool addrBYes;
        bool addrCYes;
        bool addrDYes;
    }

    mapping (address => mapping (uint => Permit)) private permits;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint public totalSupply = 2000000000000000000000000;
    uint8 constant public decimals = 4;
    string constant public name = "DGBT";
    string constant public symbol = "DGBT";

     function approve(address spender, uint256 value) external returns (bool){

         return false;
     }

    function transferFrom(address from, address to, uint256 value) external returns (bool){

        return false;
    }

    function totalSupply() external view returns (uint256){

          GBT token = GBT(addrToken);
          return token.totalSupply();
    }


    function allowance(address owner, address spender) external view returns (uint256){

        return 0;
    }

    constructor(address a, address b, address c, address d, address tokenAddress) public{
        addrA = a;
        addrB = b;
        addrC = c;
        addrD = d;
        addrToken = tokenAddress;
    }
    function getAddrs() public view returns(address, address,address,address,address) {

      return (addrA, addrB,addrC,addrD,addrToken);
    }
    
    function  transfer(address to,  uint amount)  public returns (bool){
        GBT token = GBT(addrToken);
        require(token.balanceOf(this) >= amount);
        if (msg.sender == addrA) {
            permits[to][amount].addrAYes = true;
        } else if (msg.sender == addrB) {
            permits[to][amount].addrBYes = true;
        }else if(msg.sender == addrC){
            permits[to][amount].addrCYes = true;
        }else if(msg.sender == addrD){
            permits[to][amount].addrDYes = true;
        } else {
            require(false);
        }

        if ((permits[to][amount].addrAYes == true && permits[to][amount].addrBYes == true&& permits[to][amount].addrCYes == true)
        ||(permits[to][amount].addrAYes == true && permits[to][amount].addrBYes == true&& permits[to][amount].addrDYes == true)
        ||(permits[to][amount].addrAYes == true && permits[to][amount].addrCYes == true&& permits[to][amount].addrDYes == true)
        ||(permits[to][amount].addrBYes == true && permits[to][amount].addrCYes == true&& permits[to][amount].addrDYes == true)){
            token.transfer(to, amount);
            permits[to][amount].addrAYes = false;
            permits[to][amount].addrBYes = false;
            permits[to][amount].addrCYes = false;
            permits[to][amount].addrDYes = false;
        }

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint) {

        GBT token = GBT(addrToken);
        if (_owner==addrA || _owner==addrB || _owner==addrC || _owner==addrD){
            return token.balanceOf(this);
        }
        return 0;
    }
}