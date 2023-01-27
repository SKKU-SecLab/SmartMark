
pragma solidity ^0.5.8;

contract BK_Token {


    struct Event {
        address event_address;
        uint8 max_member;
        uint8 member_count;
    }

    uint256 public constant totalSupply=1000000;
    string public constant name = "BK_Token";
    string public constant symbol = "BKT";
    string public constant description = "A Peer to Peer Training Area For Investigators";
    uint32 public constant decimals = 0;

    Event[8] public Events;
    address public coin_address;

    address public owner;

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _value);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value);

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    mapping(address => mapping(address => bool)) public event_mapping;
    mapping(address => bool) public coin_purchased;

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    constructor() public {
        balanceOf[msg.sender]=totalSupply;
		owner = msg.sender;
    }

    function transfer(address _to, uint256 _value) public returns (bool success){

        require(_value <= balanceOf[msg.sender]);

        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        for (uint x=0;x < 8;x++) {
            if (_to == Events[x].event_address) {
                if (_value == 1 && Events[x].member_count < Events[x].max_member && event_mapping[Events[x].event_address][msg.sender] == false) {
                    event_mapping[Events[x].event_address][msg.sender] = true;
                    Events[x].member_count += 1;
                }
                else {
                    balanceOf[_to] -= _value;
                    balanceOf[msg.sender] += _value;
                }
            }
        }

         if (_to == coin_address){
            if (_value == 1 && coin_purchased[msg.sender] == false){
                     coin_purchased[msg.sender] = true;
                 }
            else {
             balanceOf[_to] -= _value;
             balanceOf[msg.sender] += _value;
             }
         }

        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success){

        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

        require(_value <= balanceOf[_from]);
        require(_value <= allowance[_from][msg.sender]);
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
    function create_event(uint8 _max_member, address _event_address, uint256 _pos) public onlyOwner {

        Events[_pos].event_address = _event_address;
        Events[_pos].max_member = _max_member;
        Events[_pos].member_count = 0;
    }

    function set_coin_address(address _coin_address) public onlyOwner {

        coin_address = _coin_address;
    }

}