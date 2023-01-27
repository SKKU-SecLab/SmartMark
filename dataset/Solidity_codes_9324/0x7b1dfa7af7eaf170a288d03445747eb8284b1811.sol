
pragma solidity ^0.4.23;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}



library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}



contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}


contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    returns (bool)
  {

    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}



contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract MintableToken is StandardToken, Ownable {

  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {

    require(!mintingFinished);
    _;
  }

  modifier hasMintPermission() {

    require(msg.sender == owner);
    _;
  }

  function mint(
    address _to,
    uint256 _amount
  )
    hasMintPermission
    canMint
    public
    returns (bool)
  {

    totalSupply_ = totalSupply_.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    emit Mint(_to, _amount);
    emit Transfer(address(0), _to, _amount);
    return true;
  }

  function finishMinting() onlyOwner canMint public returns (bool) {

    mintingFinished = true;
    emit MintFinished();
    return true;
  }
}


contract FreezableToken is StandardToken {

    mapping (bytes32 => uint64) internal chains;
    mapping (bytes32 => uint) internal freezings;
    mapping (address => uint) internal freezingBalance;

    event Freezed(address indexed to, uint64 release, uint amount);
    event Released(address indexed owner, uint amount);

    function balanceOf(address _owner) public view returns (uint256 balance) {

        return super.balanceOf(_owner) + freezingBalance[_owner];
    }

    function actualBalanceOf(address _owner) public view returns (uint256 balance) {

        return super.balanceOf(_owner);
    }

    function freezingBalanceOf(address _owner) public view returns (uint256 balance) {

        return freezingBalance[_owner];
    }

    function freezingCount(address _addr) public view returns (uint count) {

        uint64 release = chains[toKey(_addr, 0)];
        while (release != 0) {
            count++;
            release = chains[toKey(_addr, release)];
        }
    }

    function getFreezing(address _addr, uint _index) public view returns (uint64 _release, uint _balance) {

        for (uint i = 0; i < _index + 1; i++) {
            _release = chains[toKey(_addr, _release)];
            if (_release == 0) {
                return;
            }
        }
        _balance = freezings[toKey(_addr, _release)];
    }

    function freezeTo(address _to, uint _amount, uint64 _until) public {

        require(_to != address(0));
        require(_amount <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_amount);

        bytes32 currentKey = toKey(_to, _until);
        freezings[currentKey] = freezings[currentKey].add(_amount);
        freezingBalance[_to] = freezingBalance[_to].add(_amount);

        freeze(_to, _until);
        emit Transfer(msg.sender, _to, _amount);
        emit Freezed(_to, _until, _amount);
    }

    function releaseOnce() public {

        bytes32 headKey = toKey(msg.sender, 0);
        uint64 head = chains[headKey];
        require(head != 0);
        require(uint64(block.timestamp) > head);
        bytes32 currentKey = toKey(msg.sender, head);

        uint64 next = chains[currentKey];

        uint amount = freezings[currentKey];
        delete freezings[currentKey];

        balances[msg.sender] = balances[msg.sender].add(amount);
        freezingBalance[msg.sender] = freezingBalance[msg.sender].sub(amount);

        if (next == 0) {
            delete chains[headKey];
        } else {
            chains[headKey] = next;
            delete chains[currentKey];
        }
        emit Released(msg.sender, amount);
    }

    function releaseAll() public returns (uint tokens) {

        uint release;
        uint balance;
        (release, balance) = getFreezing(msg.sender, 0);
        while (release != 0 && block.timestamp > release) {
            releaseOnce();
            tokens += balance;
            (release, balance) = getFreezing(msg.sender, 0);
        }
    }

    function toKey(address _addr, uint _release) internal pure returns (bytes32 result) {

        result = 0x5749534800000000000000000000000000000000000000000000000000000000;
        assembly {
            result := or(result, mul(_addr, 0x10000000000000000))
            result := or(result, _release)
        }
    }

    function freeze(address _to, uint64 _until) internal {

        require(_until > block.timestamp);
        bytes32 key = toKey(_to, _until);
        bytes32 parentKey = toKey(_to, uint64(0));
        uint64 next = chains[parentKey];

        if (next == 0) {
            chains[parentKey] = _until;
            return;
        }

        bytes32 nextKey = toKey(_to, next);
        uint parent;

        while (next != 0 && _until > next) {
            parent = next;
            parentKey = nextKey;

            next = chains[nextKey];
            nextKey = toKey(_to, next);
        }

        if (_until == next) {
            return;
        }

        if (next != 0) {
            chains[key] = next;
        }

        chains[parentKey] = _until;
    }
}


contract BurnableToken is BasicToken {


  event Burn(address indexed burner, uint256 value);

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}



contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused() {

    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {

    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {

    paused = false;
    emit Unpause();
  }
}


contract FreezableMintableToken is FreezableToken, MintableToken {

    function mintAndFreeze(address _to, uint _amount, uint64 _until) public onlyOwner canMint returns (bool) {

        totalSupply_ = totalSupply_.add(_amount);

        bytes32 currentKey = toKey(_to, _until);
        freezings[currentKey] = freezings[currentKey].add(_amount);
        freezingBalance[_to] = freezingBalance[_to].add(_amount);

        freeze(_to, _until);
        emit Mint(_to, _amount);
        emit Freezed(_to, _until, _amount);
        emit Transfer(msg.sender, _to, _amount);
        return true;
    }
}



contract Consts {

    uint public constant TOKEN_DECIMALS = 18;
    uint8 public constant TOKEN_DECIMALS_UINT8 = 18;
    uint public constant TOKEN_DECIMAL_MULTIPLIER = 10 ** TOKEN_DECIMALS;

    string public constant TOKEN_NAME = "yearn4.finance";
    string public constant TOKEN_SYMBOL = "YF4";
    bool public constant PAUSED = false;
    address public constant TARGET_USER = 0xA5403B1849CD49e7C9df080993EFA829EcF8f624;
    
    bool public constant CONTINUE_MINTING = true;
}




contract MainToken is Consts, FreezableMintableToken, BurnableToken, Pausable
    
{

    
    event Initialized();
    bool public initialized = false;

    constructor() public {
        init();
        transferOwnership(TARGET_USER);
    }
    

    function name() public pure returns (string _name) {

        return TOKEN_NAME;
    }

    function symbol() public pure returns (string _symbol) {

        return TOKEN_SYMBOL;
    }

    function decimals() public pure returns (uint8 _decimals) {

        return TOKEN_DECIMALS_UINT8;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool _success) {

        require(!paused);
        return super.transferFrom(_from, _to, _value);
    }

    function transfer(address _to, uint256 _value) public returns (bool _success) {

        require(!paused);
        return super.transfer(_to, _value);
    }

    
    function init() private {

        require(!initialized);
        initialized = true;

        if (PAUSED) {
            pause();
        }

        

        if (!CONTINUE_MINTING) {
            finishMinting();
        }

        emit Initialized();
    }
    
}// CC-BY-NC-4.0
pragma solidity >=0.4.20;

contract  YF4StakingPool001{

    
    address public owner;
    address  a;
   
    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    
    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        _transferOwnership(_newOwner);
    }

    function _transferOwnership(address _newOwner) internal {

        require(_newOwner != address(0));
        emit OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }

    using SafeMath for uint256;
    using SafeMath for uint8;
    
    ERC20 public token;
    
    uint8 decimals;
    uint8 ERC20decimals;
    
    struct User{
        bool referred;
        address referred_by;
        uint256 total_invested_amount;
        uint256 referal_profit;
    }
    
    struct Referal_levels{
        uint256 level_1;
        uint256 level_2;
        uint256 level_3;
    }

    struct Panel_1{
        uint256 invested_amount;
        uint256 profit;
        uint256 profit_withdrawn;
        uint256 start_time;
        uint256 exp_time;
        bool time_started;
        uint256 remaining_inv_prof;
    }


    mapping(address => Panel_1) public panel_1;

    mapping(address => User) public user_info;
    mapping(address => Referal_levels) public refer_info;
    uint public totalcontractamount;

    
    mapping(address => uint256) public overall_profit;

    constructor() public {
        ERC20decimals = 18; //  Decimal places of ERC20 token
        token = ERC20(0x38ACeFAd338b870373fB8c810fE705569E1C7225);
    }

    function getContractERC20Balance() public view returns (uint256){

       return token.balanceOf(address(this));
    }



function invest_panel1(uint256 t_value) public {

        require(t_value >= 50 * (10 ** 18), 'Please Enter Amount no less than 100');
        require(t_value <= 1000 * (10 ** 18), 'Please Enter Amount no greater than 1000');
        
        if( panel_1[msg.sender].time_started == false){
            panel_1[msg.sender].start_time = now;
            panel_1[msg.sender].time_started = true;
            panel_1[msg.sender].exp_time = now + 210 days; //210*24*60*60  = 210 days
        }

            totalcontractamount += t_value ;
            token.transferFrom(msg.sender, address(this), t_value);

            panel_1[msg.sender].invested_amount += t_value;
            user_info[msg.sender].total_invested_amount += t_value; 
            
            referral_system(t_value);
            
        if(panel1_days() <= 210){ //210
            panel_1[msg.sender].profit += ((t_value*1*(210 - panel1_days()))/(100)); // 210 - panel_days()
        }

    }

    function is_plan_completed_p1() public view returns(bool){


        uint256 local_overall_profit = overall_profit[msg.sender];
        uint256 local_current_profit = current_profit_p1();

        if(panel_1[msg.sender].exp_time != 0){

            if((local_current_profit + local_overall_profit) >= panel_1[msg.sender].profit){
                return true;
            }
            if(now >= panel_1[msg.sender].exp_time){
                return true;
            }
            if(now < panel_1[msg.sender].exp_time){
                return false;
            }
        }else{
            return false;
        }

    }

    function plan_completed_p1() public  returns(bool){

        uint256 local_overall_profit = overall_profit[msg.sender];
        uint256 local_current_profit = current_profit_p1();

        if( panel_1[msg.sender].exp_time != 0){

            if( (local_current_profit + local_overall_profit) >= panel_1[msg.sender].profit ){
                reset_panel_1();
                return true;
            }
            if(now >= panel_1[msg.sender].exp_time){
                reset_panel_1();
                return true;
            }
            if(now < panel_1[msg.sender].exp_time){
                return false;
            }

        }

    }

    function current_profit_p1() public view returns(uint256){

        uint256 local_profit ;

        if(now <= panel_1[msg.sender].exp_time){
            if((((panel_1[msg.sender].profit + panel_1[msg.sender].profit_withdrawn)*(now-panel_1[msg.sender].start_time))/(210*(1 days))) > panel_1[msg.sender].profit_withdrawn){  // 210 * 1 days
                local_profit = (((panel_1[msg.sender].profit + panel_1[msg.sender].profit_withdrawn)*(now-panel_1[msg.sender].start_time))/(210*(1 days))) - panel_1[msg.sender].profit_withdrawn; // 210*24*60*60
                return local_profit;
            }else{
                return 0;
            }
        }
        if(now > panel_1[msg.sender].exp_time){
            return panel_1[msg.sender].profit;
        }

    }

    function panel1_days() public view returns(uint256){

        if(panel_1[msg.sender].time_started == true){
            return ((now - panel_1[msg.sender].start_time)/(1 days)); // change to 24*60*60   1 days
        }
        else {
            return 0;
        }
    }
    
    function withdraw_profit_panel1(uint256 amount) public payable {

        uint256 current_profit = current_profit_p1();
        require(amount >= 10 * (10 ** 18), ' Amount sould be less than profit'); /////////change min withdrawal to 10YF4
        require(amount <= current_profit, ' Amount sould be less than profit');

        panel_1[msg.sender].profit_withdrawn = panel_1[msg.sender].profit_withdrawn + amount;
        panel_1[msg.sender].profit = panel_1[msg.sender].profit - amount;
        token.transfer(msg.sender, (amount - ((5*amount)/100)));
        token.transfer(a, ((5*amount)/100));
    }

    function is_valid_time_p1() public view returns(bool){

        if(panel_1[msg.sender].time_started == true){
        return (now > l_l1())&&(now < u_l1());    
        }
        else {
            return true;
        }
    }

    function l_l1() public view returns(uint256){

        if(panel_1[msg.sender].time_started == true){
            return (1 days)*panel1_days() + panel_1[msg.sender].start_time;     // 24*60*60 1 days
        }else{
            return now;
        }
    }
    
    function u_l1() public view returns(uint256){

        if(panel_1[msg.sender].time_started == true){
            return ((1 days)*panel1_days() + panel_1[msg.sender].start_time + 10 hours);    // 1 days  , 10 hours
        }else {
            return now + (10 hours);  // 10*60*60  8 hours
        }
    }

    function reset_panel_1() private{

        uint256 local_current_profit = current_profit_p1();

        panel_1[msg.sender].remaining_inv_prof = local_current_profit ;

        panel_1[msg.sender].invested_amount = 0;
        panel_1[msg.sender].profit = 0;
        panel_1[msg.sender].profit_withdrawn = 0;
        panel_1[msg.sender].start_time = 0;
        panel_1[msg.sender].exp_time = 0;
        panel_1[msg.sender].time_started = false;
        overall_profit[msg.sender] = 0;
    }  

    function withdraw_all_p1() public payable{


        token.transfer(msg.sender, panel_1[msg.sender].remaining_inv_prof);
        panel_1[msg.sender].remaining_inv_prof = 0;

    }


    



    function refer(address ref_add) public {

        require(user_info[msg.sender].referred == false, ' Already referred ');
        require(ref_add != msg.sender, ' You cannot refer yourself ');
        
        user_info[msg.sender].referred_by = ref_add;
        user_info[msg.sender].referred = true;        
        
        address level1 = user_info[msg.sender].referred_by;
        address level2 = user_info[level1].referred_by;
        address level3 = user_info[level2].referred_by;
        
        if( (level1 != msg.sender) && (level1 != address(0)) ){
            refer_info[level1].level_1 += 1;
        }
        if( (level2 != msg.sender) && (level2 != address(0)) ){
            refer_info[level2].level_2 += 1;
        }
        if( (level3 != msg.sender) && (level3 != address(0)) ){
            refer_info[level3].level_3 += 1;
        }
        
    }

    function referral_system(uint256 amount) private {

        
        address level1 = user_info[msg.sender].referred_by;
        address level2 = user_info[level1].referred_by;
        address level3 = user_info[level2].referred_by;

        if( (level1 != msg.sender) && (level1 != address(0)) ){
            user_info[level1].referal_profit += (amount*10)/(100);
            overall_profit[level1] += (amount*10)/(100);
        }
        if( (level2 != msg.sender) && (level2 != address(0)) ){
            user_info[level2].referal_profit += (amount*5)/(100);
            overall_profit[level2] += (amount*5)/(100);
        }
        if( (level3 != msg.sender) && (level3 != address(0)) ){
            user_info[level3].referal_profit += (amount*1)/(100);
            overall_profit[level3] += (amount*1)/(100);
        }

    }

    function referal_withdraw() public {

        uint256 t = user_info[msg.sender].referal_profit;
        user_info[msg.sender].referal_profit = 0;
        
        token.transfer(msg.sender, t);
    }  

}

 





