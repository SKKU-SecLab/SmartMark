
pragma solidity ^0.4.23;

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

contract managerContract{

    address superAdmin;

    mapping(address => address) internal admin;

    address pool;

    modifier onlySuper {

        require(msg.sender == superAdmin,'Depends on super administrator');
        _;
    }
}

contract unLockContract {


    using SafeMath for uint256;

    uint256 public startTime;
    uint256 public totalToPool = 0;
    uint256 public sayNo = 980 * 1000 * 1000000000000000000 ;

    function totalUnLockAmount() internal view returns (uint256 _unLockTotalAmount) {

        if(startTime==0){ return 0;}
        if(now <= startTime){ return 0; }
        uint256 dayDiff = (now.sub(startTime)) .div (1 days);
        uint256 totalUnLock = dayDiff.mul(9800).mul(1000000000000000000);
        if(totalUnLock >= (980 * 10000 * 1000000000000000000)){
            return 980 * 10000 * 1000000000000000000;
        }
        return totalUnLock;
    }
}



contract dnss is managerContract,unLockContract{


    string public constant name     = "Distributed Number Shared Settlement";
    string public constant symbol   = "DNSS";
    uint8  public constant decimals = 18;
    uint256 public totalSupply = 980 * 10000 * 1000000000000000000 ;

    mapping (address => uint256) public balanceOf;
    
    mapping (address => uint256) public balanceBurn;
   

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor() public {
        superAdmin = msg.sender ;
        balanceOf[superAdmin] = totalSupply;
    }
    
    function totalUnLock() public view returns(uint256 _unlock){

       return totalUnLockAmount();
    }


    function setTime(uint256 _startTime) public onlySuper returns (bool success) {

        require(startTime==0,'already started');
        require(_startTime > now,'The start time cannot be less than or equal to the current time');
        startTime = _startTime;
        require(startTime == _startTime,'The start time was not set successfully');
        return true;
    }

    function superApproveAdmin(address _adminAddress) public onlySuper  returns (bool success) {

        require(_adminAddress != 0x0,'is bad');
        admin[_adminAddress] = _adminAddress;
        if(admin[_adminAddress] == 0x0){
             return false;
        }
        return true;
    }


    function superApprovePool(address _poolAddress) public onlySuper  returns (bool success) {

        require(_poolAddress != 0x0,'is bad');
        pool = _poolAddress; //Approve pool
        require(pool == _poolAddress,'is failed');
        return true;
    }


    function superBurnFrom(address _burnTargetAddess, uint256 _value) public onlySuper returns (bool success) {

        require(balanceOf[_burnTargetAddess] >= _value,'Not enough balance');
        require(totalSupply > _value,' SHIT ! YOURE A FUCKING BAD GUY ! Little bitches ');
        require(totalSupply.sub(_value) >= sayNo,' SHIT ! YOURE A FUCKING BAD GUY ! Little bitches ');
        balanceOf[_burnTargetAddess] = balanceOf[_burnTargetAddess].sub(_value);
        totalSupply=totalSupply.sub(_value);
        emit Burn(_burnTargetAddess, _value);
        balanceBurn[superAdmin] = balanceBurn[superAdmin].add(_value);
        return true;
    }


    function superUnLock( address _poolAddress , uint256 _amount ) public onlySuper {

        require(pool==_poolAddress,'Mine pool address error');
        require( totalToPool.add(_amount)  <= totalSupply ,'totalSupply balance low');
        uint256 _unLockTotalAmount = totalUnLockAmount();
        require( totalToPool.add(_amount)  <= _unLockTotalAmount ,'Not enough dnss has been unlocked');
        balanceOf[_poolAddress]=balanceOf[_poolAddress].add(_amount);
        balanceOf[superAdmin]=balanceOf[superAdmin].sub(_amount);
        totalToPool=totalToPool.add(_amount);
    }


    function _transfer(address _from, address _to, uint _value) internal {

       require(_from != superAdmin,'Administrator has no rights transfer');
       require(_to != superAdmin,'Administrator has no rights transfer');
       require(_to != 0x0);
       require(balanceOf[_from] >= _value);
       require(balanceOf[_to] + _value > balanceOf[_to]);
       uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
       balanceOf[_from] -= _value;
       balanceOf[_to] += _value;
       emit Transfer(_from, _to, _value);
       assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }


    function transfer(address _to, uint256 _value) public returns (bool) {

         _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        if(admin[msg.sender] != 0x0){
          _transfer(_from, _to, _value);
        } 
        return true;
    }

}