pragma solidity >=0.4.24;
contract LUKTokenStore {

    uint8 public decimals = 8;
    uint256 public totalSupply;
    mapping (address => uint256) private tokenAmount;
    mapping (address => mapping (address => uint256)) private allowanceMapping;
    address private owner;
    mapping (address => bool) private authorization;
    
    constructor (uint256 initialSupply) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        tokenAmount[msg.sender] = totalSupply;                // Give the creator all initial tokens
        owner = msg.sender;
    }
    
    modifier onlyOwner() {

        require(msg.sender == owner,"Illegal operation.");
        _;
    }
    
    modifier checkWrite() {

        require(authorization[msg.sender] == true,"Illegal operation.");
        _;
    }
    
    function writeGrant(address _address) public onlyOwner {

        authorization[_address] = true;
    }
    function writeRevoke(address _address) public onlyOwner {

        authorization[_address] = false;
    }
    
    function approve(address _from,address _spender, uint256 _value) public checkWrite returns (bool) {

        allowanceMapping[_from][_spender] = _value;
        return true;
    }
    
    function allowance(address _from, address _spender) public view returns (uint256) {

        return allowanceMapping[_from][_spender];
    }
    
    function transfer(address _from, address _to, uint256 _value) public checkWrite returns (bool) {

        require(_to != address(0x0),"Invalid address");
        require(tokenAmount[_from] >= _value,"Not enough balance.");
        require(tokenAmount[_to] + _value > tokenAmount[_to],"Target account cannot be received.");

        tokenAmount[_from] -= _value;
        tokenAmount[_to] += _value;

        return true;
    }
    
    function transferFrom(address _from,address _spender, address _to, uint256 _value) public checkWrite returns (bool) {

        require(_from != address(0x0),"Invalid address");
        require(_to != address(0x0),"Invalid address");
        
        require(allowanceMapping[_from][_spender] >= _value,"Insufficient credit limit.");
        require(tokenAmount[_from] >= _value,"Not enough balance.");
        require(tokenAmount[_to] + _value > tokenAmount[_to],"Target account cannot be received.");
        
        tokenAmount[_from] -= _value;
        tokenAmount[_to] += _value;
        
        allowanceMapping[_from][_spender] -= _value; 
    }
    
    function balanceOf(address _owner) public view returns (uint256){

        require(_owner != address(0x0),"Address can't is zero.");
        return tokenAmount[_owner] ;
    }
}pragma solidity >=0.4.24;

contract LUKToken {

    string public name = "Lucky Coin";
    string public symbol = "LUK";
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    address private owner;
    LUKTokenStore private tokenStore;
    mapping (address => bool) private blackList;

    modifier onlyOwner() {

        require(msg.sender == owner,"Illegal operation.");
        _;
    }
    
    constructor (address storeAddr) public {
        owner = msg.sender;
        tokenStore = LUKTokenStore(storeAddr);
    }

    function () external payable{
    }
    
    function decimals() public view returns (uint8){

        return tokenStore.decimals();
    }
    function totalSupply() public view returns (uint256){

        return tokenStore.totalSupply();
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {

        balance = tokenStore.balanceOf(_owner);
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(!blackList[msg.sender],"Prohibit trading.");
        require(!blackList[_to],"Prohibit trading.");

        tokenStore.transfer(msg.sender,_to,_value);
        emit Transfer(msg.sender, _to, _value);
        
        success = true;
    }

    function transferFrom (address _from, address _to, uint256 _value) public returns (bool success) {
        require(!blackList[_from],"Prohibit trading.");
        require(!blackList[msg.sender],"Prohibit trading.");
        require(!blackList[_to],"Prohibit trading.");

        tokenStore.transferFrom(_from,msg.sender,_to,_value);
        emit Transfer(_from, _to, _value);

        success = true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {

        if (tokenStore.approve(msg.sender,_spender,_value)){
            emit Approval(msg.sender,_spender,_value); 
            success = true;
        } else {
            success = false;
        }
    }

    function allowance(address _from, address _spender) public view returns (uint256 remaining) {

        remaining = tokenStore.allowance(_from,_spender);
    }
    
    function addToBlackList(address _addr) public onlyOwner returns (bool success) {

        require(_addr != address(0x0),"Invalid address");

        blackList[_addr] = true;
        success = true;
    }

    function removeFromBlackList(address _addr) public onlyOwner returns (bool success) {

        require(_addr != address(0x0),"Invalid address");

        blackList[_addr] = false;
        success = true;
    }
}