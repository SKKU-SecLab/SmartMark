
pragma solidity ^0.4.24;

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

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() public {
        owner = msg.sender;
    }
    modifier onlyOwner() {

        require(msg.sender == owner);
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract Manager is Ownable {

    
    address[] managers;

    modifier onlyManagers() {

        bool exist = false;
        if(owner == msg.sender) {
            exist = true;
        } else {
            uint index = 0;
            (exist, index) = existManager(msg.sender);
        }
        require(exist);
        _;
    }
    
    function getManagers() public view returns (address[] memory){

        return managers;
    }
    
    function existManager(address _to) private view returns (bool, uint) {

        for (uint i = 0 ; i < managers.length; i++) {
            if (managers[i] == _to) {
                return (true, i);
            }
        }
        return (false, 0);
    }
    function addManager(address _to) onlyOwner public {

        bool exist = false;
        uint index = 0;
        (exist, index) = existManager(_to);
        
        require(!exist);
        
        managers.push(_to);
    }
    function deleteManager(address _to) onlyOwner public {

        bool exist = false;
        uint index = 0;
        (exist, index) = existManager(_to);
        
        require(exist);
   
        uint lastElementIndex = managers.length - 1; 
        managers[index] = managers[lastElementIndex];

        delete managers[managers.length - 1];
        managers.length--;
    }

}

contract Pausable is Manager {

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

    function pause() onlyManagers whenNotPaused public {

        paused = true;
        emit Pause();
    }

    function unpause() onlyManagers whenPaused public {

        paused = false;
        emit Unpause();
    }
}

contract ProtectAddress is Ownable {

    
    address[] protect;


    function getProtect() public view returns (address[] memory){

        return protect;
    }
    function isProtect(address _to) public view returns (bool) {

        for (uint i = 0 ; i < protect.length; i++) {
            if (protect[i] == _to) {
                return true;
            }
        }
        return false;
    }
    function isProtectIndex(address _to) internal view returns (bool, uint) {

        for (uint i = 0 ; i < protect.length; i++) {
            if (protect[i] == _to) {
                return (true, i);
            }
        }
        return (false, 0);
    }
    function addProtect(address _to) onlyOwner public {

        bool exist = false;
        uint index = 0;
        (exist, index) = isProtectIndex(_to);
        
        require(!exist);
        
        protect.push(_to);
    }
    function deleteProtect(address _to) onlyOwner public {

        bool exist = false;
        uint index = 0;
        (exist, index) = isProtectIndex(_to);
        
        require(exist);
   
        uint lastElementIndex = protect.length - 1; 
        protect[index] = protect[lastElementIndex];

        delete protect[protect.length - 1];
        protect.length--;
    }

}

contract ERC20 {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function allowance(address owner, address spender) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    function approve(address spender, uint256 value) public returns (bool);

    function transferFrom(address from, address to, uint256 value) public returns (bool);


    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract Token is ERC20, Pausable, ProtectAddress {


    struct sUserInfo {
        uint256 balance;
        bool lock;
        mapping(address => uint256) allowed;
    }
    
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

  

    mapping(address => sUserInfo) user;

    event Burn(uint256 value);

   
    
    function () public payable {
        revert();
    }
    
    function validTransfer(address _from, address _to, uint256 _value, bool _lockCheck) internal view returns (bool) {

        require(_to != address(this));
        require(_to != address(0));
        require(user[_from].balance >= _value);
        if(_lockCheck) {
            require(user[_from].lock == false);
        }
    }

    function lock(address _owner) public onlyManagers returns (bool) {

        require(user[_owner].lock == false);
        require(!isProtect(_owner));
        
        user[_owner].lock = true;
        return true;
    }
    function unlock(address _owner) public onlyManagers returns (bool) {

        require(user[_owner].lock == true);
        user[_owner].lock = false;
       return true;
    }
 
    function mint(address _owner, uint256 _value) internal returns (bool) {

        require(_value > 0);
        user[_owner].balance = user[_owner].balance.add(_value);
        totalSupply = totalSupply.add(_value);
        emit Transfer(this, _owner, _value);
        return true;
    }
    function burn(uint256 _value) public onlyOwner returns (bool) {

        require(_value <= user[msg.sender].balance);
        user[msg.sender].balance = user[msg.sender].balance.sub(_value);
        totalSupply = totalSupply.sub(_value);
        emit Burn(_value);
        return true;
    }
   
    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {

        require(_value == 0 || user[msg.sender].allowed[_spender] == 0); 
        user[msg.sender].allowed[_spender] = _value; 
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {

        require(_value <=  user[_from].allowed[msg.sender]);
        user[_from].allowed[msg.sender] = user[_from].allowed[msg.sender].sub(_value);
        return _transfer(_from, _to, _value);
    }
    
    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

        return _transfer(msg.sender, _to, _value);
    }
    
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool) {

        validTransfer(_from, _to, _value, true);

        user[_from].balance = user[_from].balance.sub(_value);
        user[_to].balance = user[_to].balance.add(_value);

        emit Transfer(_from, _to, _value);
        return true;
    }
    
    function totalSupply() public view returns (uint256) {

        return totalSupply;
    }
    function balanceOf(address _owner) public view returns (uint256) {

        return user[_owner].balance;
    }
    function lockState(address _owner) public view returns (bool) {

        return user[_owner].lock;
    }
    function allowance(address _owner, address _spender) public view returns (uint256) {

        return user[_owner].allowed[_spender];
    }
    
}

contract LockBalance is Manager {

    
    enum eLockType {None, Individual, GroupA, GroupB}
    struct sGroupLockDate {
        uint256[] lockTime;
        uint256[] lockPercent;
    }
    struct sLockInfo {
        uint256[] lockType;
        uint256[] lockBalanceStandard;
        uint256[] startTime;
        uint256[] endTime;
    }
    
    using SafeMath for uint256;

    mapping(uint => sGroupLockDate) groupLockDate;
    
    mapping(address => sLockInfo) lockUser;

    event Lock(address indexed from, uint256 value, uint256 endTime);
    
    function setLockUser(address _to, eLockType _lockType, uint256 _value, uint256 _endTime) internal {

        require(_endTime > now); 
        require(_value > 0); 
        lockUser[_to].lockType.push(uint256(_lockType));
        lockUser[_to].lockBalanceStandard.push(_value);
        lockUser[_to].startTime.push(now);
        lockUser[_to].endTime.push(_endTime);

        emit Lock(_to, _value, _endTime);
    }

    function lockBalanceGroup(address _owner, uint _index) internal view returns (uint256) {

        uint256 percent = 0;
        uint256 key = uint256(lockUser[_owner].lockType[_index]);

        uint256 time = 99999999999;
        for(uint256 i = 0 ; i < groupLockDate[key].lockTime.length; i++) {
            if(now < groupLockDate[key].lockTime[i]) {
                if(groupLockDate[key].lockTime[i] < time) {
                    time = groupLockDate[key].lockTime[i];
                    percent = groupLockDate[key].lockPercent[i];    
                }
            }
        }
        
        if(percent == 0){
            return 0;
        } else {
            return lockUser[_owner].lockBalanceStandard[_index].div(100).mul(uint256(percent));
        }
    }

    function lockBalanceIndividual(address _owner, uint _index) internal view returns (uint256) {

        if(now < lockUser[_owner].endTime[_index]) {
            return lockUser[_owner].lockBalanceStandard[_index];
        } else {
            return 0;
        }
    }
        
    function addLockDate(eLockType _lockType, uint256 _second, uint256 _percent) onlyManagers public {

        sGroupLockDate storage lockInfo = groupLockDate[uint256(_lockType)];
        bool isExists = false;
        for(uint256 i = 0; i < lockInfo.lockTime.length; i++) {
            if(lockInfo.lockTime[i] == _second) {
                revert();
                break;
            }
        }
        
        if(isExists) {
           revert();
        } else {
            lockInfo.lockTime.push(_second);
            lockInfo.lockPercent.push(_percent);
        }
    }
    
    function deleteLockDate(eLockType _lockType, uint256 _lockTime) onlyManagers public {

        sGroupLockDate storage lockDate = groupLockDate[uint256(_lockType)];
        
        bool isExists = false;
        uint256 index = 0;
        for(uint256 i = 0; i < lockDate.lockTime.length; i++) {
            if(lockDate.lockTime[i] == _lockTime) {
                isExists = true;
                index = i;
                break;
            }
        }
        
        if(isExists) {
            for(uint256 k = index; k < lockDate.lockTime.length - 1; k++){
                lockDate.lockTime[k] = lockDate.lockTime[k + 1];
                lockDate.lockPercent[k] = lockDate.lockPercent[k + 1];
            }
            delete lockDate.lockTime[lockDate.lockTime.length - 1];
            lockDate.lockTime.length--;
            delete lockDate.lockPercent[lockDate.lockPercent.length - 1];
            lockDate.lockPercent.length--;
        } else {
            revert();
        }
        
    }
    function deleteLockUserInfo(address _to, eLockType _lockType, uint256 _startTime, uint256 _endTime) onlyManagers public {


        bool isExists = false;
        uint256 index = 0;
        for(uint256 i = 0; i < lockUser[_to].lockType.length; i++) {
            if(lockUser[_to].lockType[i] == uint256(_lockType) &&
                lockUser[_to].startTime[i] == _startTime &&
                lockUser[_to].endTime[i] == _endTime) {
                isExists = true;
                index = i;
                break;
            }
        }
        require(isExists);

        for(uint256 k = index; k < lockUser[_to].lockType.length - 1; k++){
            lockUser[_to].lockType[k] = lockUser[_to].lockType[k + 1];
            lockUser[_to].lockBalanceStandard[k] = lockUser[_to].lockBalanceStandard[k + 1];
            lockUser[_to].startTime[k] = lockUser[_to].startTime[k + 1];
            lockUser[_to].endTime[k] = lockUser[_to].endTime[k + 1];
        }
        
        delete lockUser[_to].lockType[lockUser[_to].lockType.length - 1];
        lockUser[_to].lockType.length--;
        
        delete lockUser[_to].lockBalanceStandard[lockUser[_to].lockBalanceStandard.length - 1];
        lockUser[_to].lockBalanceStandard.length--;
        
        delete lockUser[_to].startTime[lockUser[_to].startTime.length - 1];
        lockUser[_to].startTime.length--;
        
        delete lockUser[_to].endTime[lockUser[_to].endTime.length - 1];
        lockUser[_to].endTime.length--;
        
    }

    function lockTypeInfoGroup(eLockType _type) public view returns (uint256[], uint256[]) {

        uint256 key = uint256(_type);
        return (groupLockDate[key].lockTime, groupLockDate[key].lockPercent);
    }
    function lockUserInfo(address _owner) public view returns (uint256[], uint256[], uint256[], uint256[], uint256[]) {

        
        uint256[] memory balance = new uint256[](lockUser[_owner].lockType.length);
        for(uint256 i = 0; i < lockUser[_owner].lockType.length; i++){
            if(lockUser[_owner].lockType[i] == uint256(eLockType.Individual)) {
                balance[i] = balance[i].add(lockBalanceIndividual(_owner, i));
            } else if(lockUser[_owner].lockType[i] != uint256(eLockType.None)) {
                balance[i] = balance[i].add(lockBalanceGroup(_owner, i));
            }
        }
        
        return (lockUser[_owner].lockType,
        lockUser[_owner].lockBalanceStandard,
        balance,
        lockUser[_owner].startTime,
        lockUser[_owner].endTime);
    }
    function lockBalanceAll(address _owner) public view returns (uint256) {

        uint256 lockBalance = 0;
        for(uint256 i = 0; i < lockUser[_owner].lockType.length; i++){
            if(lockUser[_owner].lockType[i] == uint256(eLockType.Individual)) {
                lockBalance = lockBalance.add(lockBalanceIndividual(_owner, i));
            } else if(lockUser[_owner].lockType[i] != uint256(eLockType.None)) {
                lockBalance = lockBalance.add(lockBalanceGroup(_owner, i));
            }
        }
        return lockBalance;
    }
    
}

contract ERC20USDT {

    function transfer(address to, uint value) public;

    function transferFrom(address from, address to, uint256 value) public;

}

contract SwapUSDT is Token, LockBalance {

    
    address usdtToken = address(0xdAC17F958D2ee523a2206206994597C13D831ec7);//USDT
    
    bool finishChange = false;
    uint256 depositRate = 30;
    
    function finishDepositChange() public onlyOwner {

        finishChange = true;
    }
    function setDepositRate(uint256 value) public onlyManagers returns(bool) {

        require(!finishChange);
        depositRate = value;
    }
  
    function swapUSDT(uint256 value) public returns(bool) {

        require(value >= 1000000);
 
        bool ret = usdtToken.call(bytes4(keccak256("transferFrom(address,address,uint256)")), msg.sender, address(this), value);
        require(ret);
        
        mint(msg.sender, value);
                
        if(depositRate > 0 ) {
            uint256 depositValue = value.mul(depositRate).div(100);
            mint(address(this), depositValue);
        }
      
        return true;
    }
    
    function withdrawUSDT(address to, uint256 value) public onlyOwner returns (bool) {

        require(to != address(0));
        require(value > 0);
        
        ERC20USDT(usdtToken).transfer(to, value);
        return true;
    }
    
    function withdrawDeposit(uint256 value) public onlyOwner returns (bool) {

        require(value > 0);
        return _transfer(address(this), msg.sender, value);
    }
}


contract USDP is SwapUSDT {


    constructor() public {
        name = "USDP";
        symbol = "USDP";
        decimals = 6;
        uint256 initialSupply = 0;//
        totalSupply = initialSupply * 10 ** uint(decimals);
        user[owner].balance = totalSupply;
        emit Transfer(address(0), owner, totalSupply);
    }


    bool public finishRestore = false; 
    
    function isFinishRestore() public onlyOwner { 

        finishRestore = true; 
    }     
  
    function validTransfer(address _from, address _to, uint256 _value, bool _lockCheck) internal view returns (bool) {

        super.validTransfer(_from, _to, _value, _lockCheck);
        if(_lockCheck) {
            require(_value <= useBalanceOf(_from));
        }
    }

    function setLockUsers(eLockType _type, address[] _to, uint256[] _value, uint256[] _endTime) onlyManagers public {  

        require(_to.length > 0);
        require(_to.length == _value.length);
        require(_to.length == _endTime.length);
        require(_type != eLockType.None);
        
        
        for(uint256 i = 0; i < _to.length; i++){
            require(!isProtect(_to[i]));
            setLockUser(_to[i], _type, _value[i], _endTime[i]);
        }
    }
    
    function transferRestore(address _from, address _to, uint256 _value) public onlyOwner returns (bool) {

        require(!finishRestore);
        require(!isProtect(_from));
        
        require(_to != address(this));
        require(_to != address(0));
        require(user[_from].balance >= _value);
        
        user[_from].balance = user[_from].balance.sub(_value);
        user[_to].balance = user[_to].balance.add(_value);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }
    function useBalanceOf(address _owner) public view returns (uint256) {

        return balanceOf(_owner).sub(lockBalanceAll(_owner));
    }
  

}