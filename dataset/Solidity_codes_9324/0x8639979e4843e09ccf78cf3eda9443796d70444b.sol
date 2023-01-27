
pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;


library SafeMath {

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a);
        return c;
    }
  
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a);
        return a - b;
    }
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
  
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;
        return c;
    }
    
}

contract ERC20 {

    
    function balanceOf(address _address) public view returns (uint256 balance);

    
    function transfer(address _to, uint256 _value) public returns (bool success);

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    
    function approve(address _spender, uint256 _value) public returns (bool success);

    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);


    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}

contract UniSwap {

    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

}

contract BHT is ERC20, UniSwap {

    
    string public name = "Bounty Hunter Token";
    string public symbol = "BHT";
    uint8 public decimals = 18;
    uint256 public totalSupply = 10000 * 10**18;
    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;
    address public owner;
    
    address public pairAddress;
    
    address public BHCAddress;
    bytes4 private constant SELECTOR = bytes4(
        keccak256(bytes("transfer(address,uint256)"))
    );
    uint256 public lastTime = 0;
    uint256 public monthTime;
    uint256 public dayTime;
    uint256 public wTime;
    uint256 tokenNumber = 1000 * 10**18;
    struct invest {
        uint256 genre;
        uint256 time;
        uint256 withdrawTime;
        uint256 money;
        uint256 earnBHC;
        uint256 withdrawBHC;
        bool withdraw;
    }
    mapping(address => invest[]) public invests;
    struct inf {
        bool register;
        address super1;
        address super2;
        uint256 juniors;
        uint256 award;
        uint256 group;
        uint256 time;
    }
    mapping(address => inf) public info;
    struct record {
        uint256 time;
        uint256 money;
    }
    mapping(address => record[]) public records;
    
    
    constructor(address _BHCAddress, uint256 _day) public {
        balances[address(this)] = totalSupply;
        owner = msg.sender;
        BHCAddress = _BHCAddress;
        monthTime = _day * 30;
        dayTime = _day;
        wTime = _day * 7;
    }
    
    modifier onlyOwner { 

        require(msg.sender == owner, "You are not owner");
        _;
    }
    
    function balanceOf(address _address) public view returns (uint256 balance) {

        return balances[_address];
    }
    
    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(_to != address(0));
        require(balances[msg.sender] >= _value && _value > 0, "Insufficient balance or zero amount");
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    
    function approve(address _spender, uint256 _amount) public returns (bool success) {

        require(_spender != address(0));
        require((allowed[msg.sender][_spender] == 0) || (_amount == 0));
        allowed[msg.sender][_spender] = _amount;
        emit Approval(msg.sender, _spender, _amount);
        return true;
    }
    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_from != address(0) && _to != address(0));
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0, "Insufficient balance or zero amount");
        balances[_from] = SafeMath.sub(balances[_from], _value);
        balances[_to] = SafeMath.add(balances[_to], _value);
        allowed[_from][msg.sender] = SafeMath.sub(allowed[_from][msg.sender], _value);
        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {

        return allowed[_owner][_spender];
    }
    
    function setOwner(address _owner) public onlyOwner returns (bool success) {

        require(_owner != address(0));
        owner= _owner;
        return true;
    }
    
    modifier onlyRegistered {

        require(info[msg.sender].register, "You have not registered");
        _;
    }
    modifier onlyInvest {

        require(invests[msg.sender].length > 0, "You have not Invest");
        _;
    }
    
    event RegisterInvest(address indexed _super1, address indexed _address);
    event LockedInvest(address indexed _address, uint256 _value, uint256 _genre);
    event WithdrawInvest(address indexed _address, uint256 _value);
    event WithdrawAward(address indexed _address, uint256 _value);
    
    
    function fetchBHT(address _address) public onlyOwner returns (bool success) {

        require(_address != address(0));
        require(balances[address(this)] >= tokenNumber, "Contract insufficient balance");
        if(lastTime == 0) {
            lastTime = block.timestamp;
        }else {
            require(lastTime + monthTime < block.timestamp, "Time is not");
            lastTime += monthTime;
        }
        balances[_address] = SafeMath.add(balances[_address], tokenNumber);
        balances[address(this)] = SafeMath.sub(balances[address(this)], tokenNumber);
        emit Transfer(address(this), _address, tokenNumber);
        success = true;
    }
    
    function fetchBHC(address _to, uint256 _value) public onlyOwner returns (bool success2) {

        require(_to != address(0));
        (bool success, ) = BHCAddress.call(
            abi.encodeWithSelector(SELECTOR, _to, _value)
        );
        if(!success) {
            revert("transfer fail");
        }
        success2 = true;
    }
    
    function setPairAddress(address _address) public onlyOwner returns (bool success) {

        require(_address != address(0));
        pairAddress = _address;
        success = true;
    }
    
    function registerInvest(address _super1) public returns (bool success) {

        require(!(info[msg.sender].register), "You have been registered");
        if(_super1 == address(0)) {
            info[msg.sender].register = true;
            return true;
        }
        require(info[_super1].register, "The referee is not registered");
        info[msg.sender].register = true;
        info[msg.sender].super1 = _super1;
        info[_super1].juniors += 1;
        address super2 = info[_super1].super1;
        if(super2 != address(0)) {
            info[msg.sender].super2 = super2;
            info[super2].juniors += 1;
        }
        emit RegisterInvest(_super1, msg.sender);
        success = true;
    }
    
    function lockedInvest(uint256 _value, uint256 _genre) public onlyRegistered returns (bool success) {

        require(_genre == 30 || _genre == 90 || _genre == 180 || _genre == 360, "locked position type inexistence");
        require(balances[msg.sender] >= _value && _value > 0, "Insufficient balance or zero amount");
        balances[msg.sender] = SafeMath.sub(balances[msg.sender], _value);
        balances[address(this)] = SafeMath.add(balances[address(this)], _value);
        emit Transfer(msg.sender, address(this), _value);
        
        uint256 _value2 = getPro(_value);
        
        uint256 wt = block.timestamp + dayTime * _genre;
        uint256 eb;
        uint256 award1;
        uint256 award2;
        if(_genre == 30) {
            eb = _value2 + _value2 * 8/100;
            award1 = _value2 * 8/100 * 20/100;
            award2 = _value2 * 8/100 * 10/100;
        }
        if(_genre == 90) {
            eb = _value2 + _value2 * 9/100 * 3;
            award1 = _value2 * 9/100 * 20/100 * 3;
            award2 = _value2 * 9/100 * 10/100 * 3;
        }
        if(_genre == 180) {
            eb = _value2 + _value2 * 10/100 * 6;
            award1 = _value2 * 10/100 * 20/100 * 6;
            award2 = _value2 * 10/100 * 10/100 * 6;
        }
        if(_genre == 360) {
            eb = _value2 + _value2 * 12/100 * 12;
            award1 = _value2 * 12/100 * 20/100 * 12;
            award2 = _value2 * 12/100 * 10/100 * 12;
        }
        uint256 wb = eb - (eb * 3/100);
        invest memory i = invest(_genre, block.timestamp, wt, _value, eb, wb, false);
        invests[msg.sender].push(i);
        
        address super1 = info[msg.sender].super1;
        address super2 = info[msg.sender].super2;
        if(super1 != address(0)) {
           info[super1].award += award1;
           info[super1].group += _value;
        }
        if(super2 != address(0)) {
          info[super2].award += award2;
          info[super2].group += _value;
        }
        
        emit LockedInvest(msg.sender, _value, _genre);
        success = true;
    }
    
    function withdrawInvest(uint256 _index) public onlyInvest returns (bool success2) {

        require(invests[msg.sender].length > _index, "invest is not");
        invest memory i = invests[msg.sender][_index];
        uint256 wt = i.withdrawTime;
        bool w = i.withdraw;
        uint256 m = i.money;
        uint256 wb = i.withdrawBHC;
        require(block.timestamp > wt, "Time is not");
        require(!w, "already withdraw");
        
        balances[address(this)] = SafeMath.sub(balances[address(this)], m);
        balances[address(0)] = SafeMath.add(balances[address(0)], m);
        emit Transfer(address(this), address(0), m);
        (bool success, ) = BHCAddress.call(
            abi.encodeWithSelector(SELECTOR, msg.sender, wb)
        );
        if(!success) {
            revert("transfer fail");
        }
        
        invests[msg.sender][_index].withdraw = true;
        emit WithdrawInvest(msg.sender, wb);
        success2 = true;
        assert(invests[msg.sender][_index].withdraw);
    }
    
    function withdrawAward(uint256 _money) public onlyInvest returns (bool success2) {

        uint256 m = info[msg.sender].award;
        uint256 t = info[msg.sender].time;
        require(m >= _money, "The amount is not enough");
        require(t < block.timestamp, "Time is not");
        
        uint256 v = _money - (_money * 3/100);
       (bool success, ) = BHCAddress.call(
            abi.encodeWithSelector(SELECTOR, msg.sender, v)
        );
        if(!success) {
            revert("transfer fail");
        }
        info[msg.sender].award -= _money;
        emit WithdrawAward(msg.sender, _money);
        info[msg.sender].time = block.timestamp + wTime;
        record memory r = record(block.timestamp, _money);
        records[msg.sender].push(r);
        success2 = true;
    }
    
    function getInvests(address _address) public view returns (invest[] memory r) {

        uint256 l = invests[_address].length;
        r = new invest[](l);
        for(uint256 i = 0; i < l; i++) {
            r[i] = invests[_address][i];
        }
    }
    
    function getRecords(address _address) public view returns (record[] memory r) {

        uint256 l = records[_address].length;
        r = new record[](l);
        for(uint256 i = 0; i < l; i++) {
            r[i] = records[_address][i];
        }
    }
    
    function getInfo(address _address) public view returns (inf memory r) {

        r = info[_address];
    }
    
    function getReserves() public view returns (uint112 _reserve0, uint112 _reserve1, uint32 _blockTimestampLast) {

        UniSwap uniswap = UniSwap(pairAddress);
        (_reserve0, _reserve1, _blockTimestampLast) = uniswap.getReserves();
    }
    
    function getPro(uint256 _value) public view returns (uint256 v) {

        (uint256 _reserve0, uint256 _reserve1, ) = getReserves();
        require(address(this) != BHCAddress, "two address identical");
        if(address(this) < BHCAddress) {
            v = _value * _reserve1 / _reserve0;
        }else {
            v = _value * _reserve0 / _reserve1;
        }
    }
    
  
    
}