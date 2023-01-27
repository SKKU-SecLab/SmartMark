

pragma solidity >=0.4.23 <0.6.0;


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
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

contract Ownable {

    address public owner;

    function Ownable() public {

        owner = msg.sender;
    }

    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

contract ERC20Basic {

    uint public _totalSupply;
    function totalSupply() public constant returns (uint);

    function balanceOf(address who) public constant returns (uint);

    function transfer(address to, uint value) public;

    event Transfer(address indexed from, address indexed to, uint value);
}

contract ERC20 is ERC20Basic {

    function allowance(address owner, address spender) public constant returns (uint);

    function transferFrom(address from, address to, uint value) public;

    function approve(address spender, uint value) public;

    event Approval(address indexed owner, address indexed spender, uint value);
}

contract BasicToken is Ownable, ERC20Basic {

    using SafeMath for uint;

    mapping(address => uint) public balances;

    uint public basisPointsRate = 0;
    uint public maximumFee = 0;

    modifier onlyPayloadSize(uint size) {

        require(!(msg.data.length < size + 4));
        _;
    }

    function transfer(address _to, uint _value) public onlyPayloadSize(2 * 32) {

        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        uint sendAmount = _value.sub(fee);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            Transfer(msg.sender, owner, fee);
        }
        Transfer(msg.sender, _to, sendAmount);
    }

    function balanceOf(address _owner) public constant returns (uint balance) {

        return balances[_owner];
    }

}

contract StandardToken is BasicToken, ERC20 {


    mapping (address => mapping (address => uint)) public allowed;

    uint public constant MAX_UINT = 2**256 - 1;

    function transferFrom(address _from, address _to, uint _value) public onlyPayloadSize(3 * 32) {

        var _allowance = allowed[_from][msg.sender];


        uint fee = (_value.mul(basisPointsRate)).div(10000);
        if (fee > maximumFee) {
            fee = maximumFee;
        }
        if (_allowance < MAX_UINT) {
            allowed[_from][msg.sender] = _allowance.sub(_value);
        }
        uint sendAmount = _value.sub(fee);
        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(sendAmount);
        if (fee > 0) {
            balances[owner] = balances[owner].add(fee);
            Transfer(_from, owner, fee);
        }
        Transfer(_from, _to, sendAmount);
    }

    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {


        require(!((_value != 0) && (allowed[msg.sender][_spender] != 0)));

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {

        return allowed[_owner][_spender];
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
    Pause();
  }

  function unpause() onlyOwner whenPaused public {

    paused = false;
    Unpause();
  }
}

contract BlackList is Ownable, BasicToken {


    function getBlackListStatus(address _maker) external constant returns (bool) {

        return isBlackListed[_maker];
    }

    function getOwner() external constant returns (address) {

        return owner;
    }

    mapping (address => bool) public isBlackListed;

    function addBlackList (address _evilUser) public onlyOwner {
        isBlackListed[_evilUser] = true;
        AddedBlackList(_evilUser);
    }

    function removeBlackList (address _clearedUser) public onlyOwner {
        isBlackListed[_clearedUser] = false;
        RemovedBlackList(_clearedUser);
    }

    function destroyBlackFunds (address _blackListedUser) public onlyOwner {
        require(isBlackListed[_blackListedUser]);
        uint dirtyFunds = balanceOf(_blackListedUser);
        balances[_blackListedUser] = 0;
        _totalSupply -= dirtyFunds;
        DestroyedBlackFunds(_blackListedUser, dirtyFunds);
    }

    event DestroyedBlackFunds(address _blackListedUser, uint _balance);

    event AddedBlackList(address _user);

    event RemovedBlackList(address _user);

}

contract UpgradedStandardToken is StandardToken{

    function transferByLegacy(address from, address to, uint value) public;

    function transferFromByLegacy(address sender, address from, address spender, uint value) public;

    function approveByLegacy(address from, address spender, uint value) public;

}

contract TetherToken is Pausable, StandardToken, BlackList {


    string public name;
    string public symbol;
    uint public decimals;
    address public upgradedAddress;
    bool public deprecated;

    function TetherToken(uint _initialSupply, string _name, string _symbol, uint _decimals) public {

        _totalSupply = _initialSupply;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        balances[owner] = _initialSupply;
        deprecated = false;
    }

    function transfer(address _to, uint _value) public whenNotPaused {

        require(!isBlackListed[msg.sender]);
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferByLegacy(msg.sender, _to, _value);
        } else {
            return super.transfer(_to, _value);
        }
    }

    function transferFrom(address _from, address _to, uint _value) public whenNotPaused {

        require(!isBlackListed[_from]);
        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).transferFromByLegacy(msg.sender, _from, _to, _value);
        } else {
            return super.transferFrom(_from, _to, _value);
        }
    }

    function balanceOf(address who) public constant returns (uint) {

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }

    function approve(address _spender, uint _value) public onlyPayloadSize(2 * 32) {

        if (deprecated) {
            return UpgradedStandardToken(upgradedAddress).approveByLegacy(msg.sender, _spender, _value);
        } else {
            return super.approve(_spender, _value);
        }
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {

        if (deprecated) {
            return StandardToken(upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }
    }

    function deprecate(address _upgradedAddress) public onlyOwner {

        deprecated = true;
        upgradedAddress = _upgradedAddress;
        Deprecate(_upgradedAddress);
    }

    function totalSupply() public constant returns (uint) {

        if (deprecated) {
            return StandardToken(upgradedAddress).totalSupply();
        } else {
            return _totalSupply;
        }
    }

    function issue(uint amount) public onlyOwner {

        require(_totalSupply + amount > _totalSupply);
        require(balances[owner] + amount > balances[owner]);

        balances[owner] += amount;
        _totalSupply += amount;
        Issue(amount);
    }

    function redeem(uint amount) public onlyOwner {

        require(_totalSupply >= amount);
        require(balances[owner] >= amount);

        _totalSupply -= amount;
        balances[owner] -= amount;
        Redeem(amount);
    }

    function setParams(uint newBasisPoints, uint newMaxFee) public onlyOwner {

        require(newBasisPoints < 20);
        require(newMaxFee < 50);

        basisPointsRate = newBasisPoints;
        maximumFee = newMaxFee.mul(10**decimals);

        Params(basisPointsRate, maximumFee);
    }

    event Issue(uint amount);

    event Redeem(uint amount);

    event Deprecate(address newAddress);

    event Params(uint feeBasisPoints, uint maxFee);
}



contract PhoenixTiger {

    TetherToken tether;
    
    address public owner;
    uint public totalGpv;
    uint public lastuid;
    uint[6] private poolEli = [uint(100000000000), 1000000000000, 250000000000, 100000000000, 100000000000, 1000000000000];
    
    uint private total_packs = 11;
    uint private totalcountry = 200;
    uint private countrycommissionprice = 2;
    uint private gloComPrice = 1;
    uint private milComPrice = 1;
    uint private orgComPrice = 1;
    address private expenseAddress;
    address[] private orgPool;
    address[] private milPool;
    address[] private gloPool; 
    
    
    mapping(address => User) public users;
    mapping(address => bool) public userExist;
    mapping(uint => uint) public totalCountryGpv;
    mapping(address => uint[]) private userPackages;
    mapping(uint=>address[]) private countrypool;
    mapping(uint=>address[]) private countEliPool;
    mapping(address => bool) public orgpool;
    mapping(address=> bool) public millpool;
    mapping(address => bool) public globalpool;
    mapping(address=>address[]) public userDownlink;
    mapping(address => bool) public isRegistrar;
    mapping(address=> uint) public userLockTime;
    mapping(address =>bool) public isCountryEli;    
    mapping(uint => address) public useridmap;
    
    
    uint[12] public Packs;
    
    enum Status {CREATED, ACTIVE}

    modifier onlyOwner(){

      require(msg.sender == owner,"only owner");
      _;
    }

    struct User {
    	uint userid;
        uint countrycode;
        uint pbalance;
        uint rbalance;
        uint rank;
        uint gHeight;
        uint gpv;
        uint[2] lastBuy;   //0- time ; 1- pack;
        uint[7] earnings;  // 0 - team earnings; 1 - family earnings; 2 - match earnings; 3 - country earnings, 4- organisation, 5 - global, 6 - millionaire
        bool isbonus;
        bool isKyc;
        address teamaddress;
        address familyaddress;
        Status status;
        uint traininglevel;
        mapping(uint=>TrainingLevel) trainingpackage;
    }
    
    struct TrainingLevel {
        uint package;
        bool purchased;

    }
    event Registration(
                
                address useraddress,
                uint countrycode,
                uint gHeight,
                address teamaddress
    );

    event newPackage (
                address useraddress,
                uint pack
            );

    event RaiseTrainingLevel(
            
                address useraddress,
                uint tlevel,
                uint rank
            );

    event RedeemEarning(
            
                address useraddress,
                uint pbalance,
                uint rbalance
            );
            
    event LockTimeUpdate(
                address useraddress,
                uint locktime
            );
 
    event KycDone(
                address useraddress
            );
            

    constructor(address ownerAddress,address _expenseAddress) public {

        tether = TetherToken(0xdAC17F958D2ee523a2206206994597C13D831ec7);
        Packs = [0,500, 1000, 2000, 5000, 10000, 20000,50000,100000,250000, 500000, 1000000];

        owner = ownerAddress;
        expenseAddress = _expenseAddress;
        isRegistrar[owner] = true;
  
        address master = 0x3417F6448eeDbf8737af2cef9Ca2d2dd2Ee3d543;
        
        userExist[master] = true;
        User memory user;
        user= User({
            userid : 1000001,
            teamaddress : address(0),
            countrycode: 165,
            isbonus : false,
            familyaddress : address(0),
            pbalance: 0,
            rbalance : 0,
            rank : 0,
            gHeight: 1,
            status : Status.ACTIVE,
            traininglevel : 0,
            gpv : 0,
            isKyc:false,
            lastBuy:[uint(0),0],
            earnings:[uint(0),0,0,0,0,0,0]
        });
        users[master] = user; //Master
        lastuid = 1000001;
        useridmap[lastuid] = master;

    }

    
    function superRegister(address useraddress,address referrerAddress,uint usercountry,uint pack, uint rbal, uint gbv, uint[7] userEarnings, uint[2] lastBuy, uint ltime) external onlyOwner {

        require(!isUserExists(useraddress) && isUserExists(referrerAddress), "user exists");
        require(checkCountry(usercountry), "country must be from 0 to 200");
        require(isAddress(useraddress), "cannot be a contract");
        totalCountryGpv[usercountry] += Packs[pack]*1000000;
        totalGpv += Packs[pack]*1000000;
       
        userExist[useraddress] = true;
        User memory user = User({
	        userid : ++lastuid,
            teamaddress : referrerAddress,
            countrycode: usercountry,
            isbonus : true,
            familyaddress : getFamilyFromReferral(referrerAddress),
            pbalance: 0,
            rbalance : rbal,
            rank : pack,
            gHeight: users[referrerAddress].gHeight+1,
            status : Status.ACTIVE,
            gpv : gbv,
            isKyc : false,
            lastBuy:[uint(lastBuy[0]),lastBuy[1]],
            traininglevel :0,
            earnings: [uint(userEarnings[0]),userEarnings[1],userEarnings[2],userEarnings[3],userEarnings[4],userEarnings[5],userEarnings[6]]
        });
    	users[useraddress] = user;
    	useridmap[lastuid] = useraddress;
        if(lastBuy[1]==0){
            users[useraddress].status = Status.CREATED;
            users[useraddress].isbonus = false;
        }
        
        isCountryEli[useraddress] = false;
        globalpool[useraddress] = false;
        millpool[useraddress] = false;
        orgpool[useraddress] = false;
        
        users[useraddress].trainingpackage[pack].package=pack;
        users[useraddress].traininglevel=0;
        users[useraddress].trainingpackage[pack].purchased=true;     
      
        userLockTime[useraddress] = ltime;
        userPackages[useraddress].push(pack);
        countrypool[usercountry].push(useraddress);
        userDownlink[referrerAddress].push(useraddress);
        
        emit Registration(
            useraddress,
            users[useraddress].countrycode,
            users[useraddress].gHeight,
            users[useraddress].teamaddress
        );        
    }
    
    function registration(address useraddress, address referrerAddress, uint usercountry,uint locktime) external {

        require(!isUserExists(useraddress) && isUserExists(referrerAddress), "user exists");
        require(referrerAddress != address(0),"referrerAddress cannot be zero address");
        require(checkCountry(usercountry), "country must be from 0 to 200");
        require(isAddress(useraddress) && isAddress(referrerAddress), "cannot be a contract");
        
        address teamaddress = referrerAddress;
    
        userExist[useraddress] = true;
        User memory user = User({
            userid : ++lastuid,
            teamaddress : teamaddress,
            countrycode: usercountry,
            isbonus : false,
            familyaddress : getFamilyFromReferral(teamaddress),
            pbalance: 0,
            rbalance : 0,
            rank : 0,
            gHeight: getHeight(teamaddress),
            status : Status.CREATED,
            gpv :0,
            isKyc : false,
            lastBuy:[uint(0),0],
            traininglevel :0,
            earnings:[uint(0),0,0,0,0,0,0]
        });
        users[useraddress] = user;
        useridmap[lastuid] = useraddress;
        userLockTime[useraddress] = locktime;
        countrypool[usercountry].push(useraddress);
        userDownlink[teamaddress].push(useraddress);

        emit Registration(
	    useraddress,
            users[useraddress].countrycode,
            users[useraddress].gHeight,
            users[useraddress].teamaddress
        );

    }

    function buypackage( uint pack ,uint amount) external {

        
        uint _amount = amount/1000000;
        require(isUserExists(msg.sender), "user not exists");
        require(pack > users[msg.sender].lastBuy[1] && pack < total_packs && pack>0, "check pack purchase");
        require(Packs[pack]<= _amount, "invalid amount of wholesale package purchase");
        require(tether.allowance(msg.sender,address(this)) >= amount,"set allowance");
        
        if(discountValid(msg.sender,pack)){
            uint newAmount = (Packs[pack] - Packs[users[msg.sender].lastBuy[1]])*1000000;
            tether.transferFrom(msg.sender,address(this),newAmount); 
            disburse(msg.sender, newAmount, pack);            
        }else{
            tether.transferFrom(msg.sender,address(this),amount); 
            disburse(msg.sender, amount, pack);
        }
        
        userPackages[msg.sender].push(pack);
        users[msg.sender].lastBuy = [now,pack];
        emit newPackage (
          msg.sender,
          pack
        );
    }
    
    function raiseTrainingLevel(address [] useraddress, uint[] pack) external  payable {

        require(isRegistrar[msg.sender],"Not a registrar");
        require(useraddress.length == pack.length,"useraddress length not equal to packs length");
       for(uint i=0;i<useraddress.length;i++){
        require(isUserExists(useraddress[i]), "user not exists");
        require(total_packs >= pack[i], "invalid pack");

        require(users[useraddress[i]].trainingpackage[pack[i]].purchased, "Pack is not purchased.");
        users[useraddress[i]].isbonus = true;
        users[useraddress[i]].traininglevel= ++users[useraddress[i]].traininglevel;

        emit RaiseTrainingLevel(
            
            useraddress[i],
            users[useraddress[i]].traininglevel,
            users[useraddress[i]].rank
        );   
       }
    }

    function redeemEarning(address useraddress) public{

        require(isUserExists(useraddress), "user not exists");
        require(users[msg.sender].pbalance>0, "insufficient balance");
        tether.transfer(useraddress,users[useraddress].pbalance);
        users[useraddress].rbalance = users[useraddress].rbalance + users[useraddress].pbalance;
        users[useraddress].pbalance = 0;

        emit RedeemEarning(
            useraddress,
            users[useraddress].pbalance,
            users[useraddress].rbalance
        );
    }


    function addRegistrar(address registrar) public onlyOwner{

        isRegistrar[registrar] = true;
    }
    
    function removeRegistrar(address registrar) public onlyOwner{

        isRegistrar[registrar] = false;
    } 
    
    function updateLockTime(address useraddress ,uint locktime ) public{

        require(useraddress==msg.sender);
        require(locktime> 6,"must be greater than 6 months");
        require(isUserExists(useraddress),"user not exist");
        userLockTime[useraddress] = locktime;
        
        emit LockTimeUpdate(
            useraddress, 
            locktime
        );
    }

    function discountValid(address useraddress,uint pack) public view returns(bool _bool){

       uint  _lastPack =  users[useraddress].lastBuy[1] ;
       uint  _lastTime =  users[useraddress].lastBuy[0];
       
       if(_lastPack==0 || pack<= _lastPack || now - _lastTime >= 30 days){
           return false;
       }else{
           return true;
       }
    }
    
    function getEarnings(address useraddress) public view returns(uint[7] memory _earnings){

        return users[useraddress].earnings;
    }
    
    function getidfromaddress(address useraddress) public view returns(uint userID){

        return users[useraddress].userid;
    }
    
    function getLastBuyPack(address useraddress) public view returns(uint[2] memory _lastpack){

        return users[useraddress].lastBuy;
    }
    
    function getCountryUsersCount(uint country) public view returns (uint count){

        return countrypool[country].length;
    }

    function getTrainingLevel(address useraddress, uint pack) public view returns (uint tlevel, uint upack) {

        return (users[useraddress].traininglevel, pack);

    }

    function getUserDownLink(address useraddress) public view  returns (address[] memory addr) {

        if(userDownlink[useraddress].length != 0){
            return userDownlink[useraddress];
        }
        else{
            address[] memory pack;
            return pack ;
        }
    }

    
    function getAllPacksofUsers(address useraddress) public view returns(uint[] memory pck) {

        return userPackages[useraddress];
    }

    function getAllLevelsofUsers(address useraddress,uint pack) public view returns(uint lvl) {

        
        if(users[useraddress].trainingpackage[pack].purchased){
            return users[useraddress].traininglevel;
        }
        
        return 0;
    }

    function isAddress(address _address) private view returns (bool value){

        uint32 size;
        assembly {
                size := extcodesize(_address)
        }
        return(size==0);
    }

    function isUserExists(address user) public view returns (bool) {

        return userExist[user];
    }

    function checkCountry(uint country) private pure returns (bool) {

        return (country <= 200);
    }

    function getFamilyFromReferral(address referrerAddres) private view returns (address addr) {

        if (users[referrerAddres].teamaddress != address(0)){
            return users[referrerAddres].teamaddress;
        }
        else {
            return address(0);
        }
    }

    function getFamilyFromUser(address useraddress) private view returns (address addr) {

        if (users[users[useraddress].teamaddress].teamaddress != address(0)){
            return users[users[useraddress].teamaddress].teamaddress;
        }
        else {
            return address(0);
        }
    }

    function getTeam(address useraddress) private view returns (address addr) {

        return users[useraddress].teamaddress;
    }

    function getGminus2(address useraddress) private view returns (address gaddr) {


        if(users[useraddress].teamaddress == address(0)){
            return address(0);
        }
        else{
            return users[users[useraddress].teamaddress].familyaddress;
        }
    }
    
    function getHeight(address referrerAddres) private view returns (uint ghgt) {

        return users[referrerAddres].gHeight +1;
    }

    function disburse(address useraddress, uint amount, uint pack) private {


      uint leftamount;
      uint disbursedamount;

      disbursedamount = disburseTeam(useraddress, amount);
      leftamount = amount - disbursedamount;

      disbursedamount = disburseFamily(useraddress,  amount);
      leftamount = leftamount - disbursedamount;

      disbursedamount = disburseMatch(useraddress,amount);
      leftamount = leftamount - disbursedamount;

      disbursedamount = disburseCountryPool(useraddress, amount);
      leftamount = leftamount - disbursedamount;

      disbursedamount = disburseOMGPool(useraddress, amount);
      leftamount = leftamount - disbursedamount;
      
      payoutGpv(useraddress,amount);
      tether.transfer(expenseAddress,leftamount);
    
      users[useraddress].status = Status.ACTIVE;
      users[useraddress].rank = pack;

      users[useraddress].trainingpackage[pack].package=pack;
      users[useraddress].traininglevel=0;
      users[useraddress].trainingpackage[pack].purchased=true;     
    }

    function disburseTeam(address useraddress, uint amount) private  returns (uint amnt) {

        address teamaddress = getTeam(useraddress);
        if(teamaddress == address(0)){
            return 0;
        }
        else if(users[teamaddress].status == Status.CREATED) {
            return amount;
        }
        else{
            users[teamaddress].pbalance = users[teamaddress].pbalance+ (amount * 10)/100;
            users[teamaddress].earnings[0] += (amount * 10)/100;
            return (amount * 10)/100;
        }
    }

    function disburseFamily(address useraddress, uint amount) private  returns (uint amnt) {

        address familyaddress = getFamilyFromUser(useraddress);
        if(familyaddress != address(0)){
            if(users[familyaddress].status == Status.CREATED){
                return 0;
            }
            else{
                users[familyaddress].pbalance = users[familyaddress].pbalance+ (amount * 30)/1000;
                users[familyaddress].earnings[1] += (amount * 30)/1000;
                
                return (amount * 30)/1000;
            }
        }
        else {
            return 0;
        }
    }

    function disburseMatch(address useraddress, uint amount) private  returns (uint amnt) {

        uint commissionamount;
        uint disbursed ;
        uint gold_due;
        uint diamond_due;
        uint plat_due;
        
        address familyaddress = getFamilyFromUser(useraddress);
        if(familyaddress != address(0)){
            users[familyaddress].earnings[2] += (amount * 4)/1000;
            users[familyaddress].pbalance += (amount * 4)/1000;
            disbursed += (amount * 4)/1000;
        }else{
            return 0;
        }

        address teamaddress = getTeam(familyaddress);
        if(teamaddress != address(0)){
            users[teamaddress].earnings[2] += (amount * 136)/100000;
            users[teamaddress].pbalance += (amount * 136)/100000;
            amount = (amount * 136)/100000;
            disbursed += amount;
        }else{
            return disbursed;
        }

        address matchaddress = getGminus2(useraddress);
        if(matchaddress==address(0)){
            return disbursed;
        }
        else{
            while(matchaddress != address(0)){

                if(users[matchaddress].status == Status.CREATED){
                    matchaddress = users[matchaddress].teamaddress;
                }
                else{
                    
                    commissionamount = (amount *4 )/100; //checkmatch = 4%
                    
                    gold_due = gold_due +commissionamount;
                    diamond_due = diamond_due + commissionamount;
                    plat_due = plat_due + commissionamount;
                    
                    if( users[useraddress].trainingpackage[11].purchased){//PlatinumFounder
                        commissionamount += (plat_due*3)/100;
                        plat_due = 0;
                    }
                    else if( users[useraddress].trainingpackage[10].purchased){//DiamondFounder
                        commissionamount += (diamond_due*2)/100;
                        diamond_due = 0;
                    }
                    else if( users[useraddress].trainingpackage[9].purchased ){  // Gold-founder
                        commissionamount += (gold_due)/100;
                        gold_due = 0;
                    }
                 
                    users[matchaddress].pbalance = users[matchaddress].pbalance + commissionamount;
                    users[matchaddress].earnings[2] += commissionamount;
                    matchaddress = users[matchaddress].teamaddress;
                    amount = commissionamount;
                    disbursed = disbursed + amount;
                }
            }
            return disbursed;
        }
    }

    function disburseCountryPool(address useraddress, uint amount) private  returns (uint amnt) {

        uint country = users[useraddress].countrycode;
        uint disbursed;

        for(uint i=0; i < countEliPool[country].length && disbursed <= ((amount*2)/100); i++){
                uint gpv = users[countEliPool[country][i]].gpv;
				uint countDisbursed = (amount * countrycommissionprice*gpv)/(100*totalCountryGpv[users[useraddress].countrycode]);
                users[countEliPool[country][i]].pbalance = users[countEliPool[country][i]].pbalance + countDisbursed;
                users[countEliPool[country][i]].earnings[3] += countDisbursed;
                disbursed = disbursed + countDisbursed;
            }
        
        return disbursed;
    }

    function disburseOMGPool(address useraddress, uint amount) private  returns (uint amnt) {

        uint disbursed;

    	for(uint i=orgPool.length ; i > 0 ; i--) {
    	    uint gpvOrg = users[orgPool[i]].gpv;
    	    users[orgPool[i]].earnings[4] += (amount * orgComPrice *gpvOrg)/(100*totalGpv);
    	    users[orgPool[i]].pbalance += (amount * orgComPrice *gpvOrg)/(100*totalGpv);
            disbursed += (amount * orgComPrice *gpvOrg)/(100*totalGpv);
    	}
    
    	for( i=milPool.length ; i > 0 ; i--) {
    	    uint gpvMill = users[milPool[i]].gpv;
    	    users[milPool[i]].earnings[4] += (amount * milComPrice *gpvMill)/(100*totalGpv);
    	    users[milPool[i]].pbalance = (amount * milComPrice *gpvMill)/(100*totalGpv);
            disbursed += (amount * milComPrice *gpvMill)/(100*totalGpv);
    	}
    
    	for(i=gloPool.length ; i > 0 ; i--) {
    	    uint gpvGlo = users[gloPool[i]].gpv;
    	    users[gloPool[i]].earnings[4] += (amount * gloComPrice *gpvGlo)/(100*totalGpv);
    	    users[gloPool[i]].pbalance = (amount * gloComPrice *gpvGlo)/(100*totalGpv);
            disbursed += (amount * gloComPrice *gpvGlo)/(100*totalGpv);
    	}

	    return disbursed;
    }

    function checkPackPurchased(address useraddress, uint pack) public view returns (uint userpack, uint usertraininglevel, bool packpurchased){

        if(users[useraddress].trainingpackage[pack].purchased){
            return (pack, users[useraddress].traininglevel, users[useraddress].trainingpackage[pack].purchased);
        }
    }

    function payoutGpv(address useraddress,uint amount) private{


        totalGpv = totalGpv + (amount*(users[useraddress].gHeight-1));  
        totalCountryGpv[users[useraddress].countrycode] = totalCountryGpv[users[useraddress].countrycode] + (amount*users[useraddress].gHeight-1);
        address _Address = users[useraddress].teamaddress;
        for(uint i = users[useraddress].gHeight-1 ; i>0 ;i--){
            users[_Address].gpv += amount;
            _Address = users[_Address].teamaddress;
            
            if(users[_Address].gpv > poolEli[0]  && !orgpool[_Address] && checkEligible(_Address,poolEli[4])){
                orgpool[_Address] = true;
		        orgPool.push(_Address);
            }
            if(users[_Address].gpv > poolEli[1] && !millpool[_Address] && checkEligible(_Address,poolEli[5])){
                millpool[_Address] = true;
		        milPool.push(_Address);
            }
            if(users[_Address].gpv > poolEli[2] && !globalpool[_Address]){
                globalpool[_Address] = true;
		        milPool.push(_Address);
            }
            if(users[_Address].gpv > poolEli[3] && !isCountryEli[_Address] && users[_Address].isKyc == true){
                isCountryEli[_Address] =true;
		        countEliPool[users[useraddress].countrycode].push(_Address);

            }
         }
    }
    
    function checkEligible(address useraddress,uint amount) private view returns(bool){

        uint a = 0 ;
        address [] memory _addresses = getUserDownLink(useraddress);
        if(_addresses.length < 5){
                return false;
        }
        for(uint i =0;i< _addresses.length;i++){
            if(users[_addresses[i]].gpv > amount){
                a += 1;
             }
            if(a>=5){
              return true;
            }
        }
        return false;
        
    }
    
    function setKyc(address useraddress) public onlyOwner{

        users[useraddress].isKyc = true;
        
        emit KycDone(
            useraddress
            );
    }
   
    function updateEligibilty(uint _orgEli,uint _millEli,uint _gloEli,uint _countEli,uint _orgDownEli,uint _millDownEli ) public onlyOwner{

        uint i;
        uint j;
        poolEli[5] = _millDownEli;
        poolEli[4] = _orgDownEli;
        gloPool.length = 0;
        milPool.length = 0;
        orgPool.length = 0; 
        if(poolEli[0] != _orgEli){
           poolEli[0] = _orgEli;
           for(  i= 0; i<totalcountry;i++){
               for( j=0; j<countrypool[i].length; j++){
                   orgpool[countrypool[i][j]] = false;
                   if(checkEligible(countrypool[i][j],poolEli[0])){
                       orgpool[countrypool[i][j]] = true;
                       orgPool.push(countrypool[i][j]);
                    } 
                }
            }
        }
        if(poolEli[1] != _millEli){
            poolEli[1] = _millEli;
            for(  i= 0; i<totalcountry;i++){
                for( j=0; j<countrypool[i].length; j++){
                    millpool[countrypool[i][j]] = false;
                    if(checkEligible(countrypool[i][j],poolEli[0])){
                        millpool[countrypool[i][j]] = true;
                        milPool.push(countrypool[i][j]);
                    } 
                }
            }
        }     
        if(poolEli[2] != _gloEli){
            poolEli[2] = _gloEli;
            for(  i= 0; i<totalcountry;i++){
                for( j=0; j<countrypool[i].length; j++){
                    globalpool[countrypool[i][j]] = false;
                    if(users[countrypool[i][j]].gpv > poolEli[2]){
                       globalpool[countrypool[i][j]] = true;
                       gloPool.push(countrypool[i][j]);
                    }
                }
            }
        }
        if(poolEli[3] != _countEli){
            poolEli[3] = _countEli;
            for(  i= 0; i<totalcountry;i++){
                countEliPool[i].length = 0;
                for( j=0; j<countrypool[i].length; j++){
                    isCountryEli[countrypool[i][j]] = false;
                    if(users[countrypool[i][j]].gpv > poolEli[3] && users[countrypool[i][j]].isKyc == true){
                        isCountryEli[countrypool[i][j]] =true;
                        countEliPool[users[countrypool[i][j]].countrycode].push(countrypool[i][j]);
                    }               
                }
            }
        }
    }
}