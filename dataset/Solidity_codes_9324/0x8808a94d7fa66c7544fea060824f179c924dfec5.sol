
pragma solidity 0.4.24;

contract Database {

      address public dappAddress;
      address public contractOwner;
      address public ownerWallet;
      address public balAdmin;
      uint public currUserID = 0;
      uint public p1CUId = 0;
      uint public p2CUId = 0;
      uint public p3CUId = 0;
      uint public p4CUId = 0;
      uint public p5CUId = 0;
      uint public p6CUId = 0;
      uint public p7CUId = 0;
      uint public p8CUId = 0;
      uint public p9CUId = 0;
      uint public p10CUId = 0;
      
      uint public p1AcUId = 0;
      uint public p2AcUId = 0;
      uint public p3AcUId = 0;
      uint public p4AcUId = 0;
      uint public p5AcUId = 0;
      uint public p6AcUId = 0;
      uint public p7AcUId = 0;
      uint public p8AcUId = 0;
      uint public p9AcUId = 0;
      uint public p10AcUId = 0;
      
      uint public unlimited_level_price=0;
     
      struct User {
        bool isExist;
        uint id;
        uint refId;
        uint refUsers;
     }
    
     struct PoolUser {
        bool isExist;
        uint id;
       uint payment_received; 
    }
    
    mapping (address => User) public users;
     mapping (uint => address) public userList;
     
     mapping (address => PoolUser) public pool1users;
     mapping (uint => address) public pool1userList;
     
     mapping (address => PoolUser) public pool2users;
     mapping (uint => address) public pool2userList;
     
     mapping (address => PoolUser) public pool3users;
     mapping (uint => address) public pool3userList;
     
     mapping (address => PoolUser) public pool4users;
     mapping (uint => address) public pool4userList;
     
     mapping (address => PoolUser) public pool5users;
     mapping (uint => address) public pool5userList;
     
     mapping (address => PoolUser) public pool6users;
     mapping (uint => address) public pool6userList;
     
     mapping (address => PoolUser) public pool7users;
     mapping (uint => address) public pool7userList;
     
     mapping (address => PoolUser) public pool8users;
     mapping (uint => address) public pool8userList;
     
     mapping (address => PoolUser) public pool9users;
     mapping (uint => address) public pool9userList;
     
     mapping (address => PoolUser) public pool10users;
     mapping (uint => address) public pool10userList;
     
    mapping(uint => uint) public L_PRICE;
    mapping(uint => uint) public L_PRICE1;
    mapping(uint => uint) public L_PRICE2;
    mapping(uint => uint) public L_PRICE3;
    mapping(uint => uint) public L_PRICE4;
    mapping(uint => uint) public L_PRICE5;
    mapping(uint => uint) public L_PRICE6;
    mapping(uint => uint) public L_PRICE7;
    mapping(uint => uint) public L_PRICE8;
    mapping(uint => uint) public L_PRICE9;
    mapping(uint => uint) public L_PRICE10;
    
    function saveNewRegData(address oldUAddr, uint referrerID) public {}

    function saveNewPlData(uint pool,address _poolAddress) public {}
    function updPlPayment(uint pool,address _poolAddress) public {}

    function updCurAndActUsr(uint pool, uint cType) public {}
}

contract Akodax2_0 {

    Database dbInst;
    address public dbAddress;
    address public owner;
    
    struct User {
        bool isExist;
        uint id;
        uint refId;
        uint refUsers;
     }
    
     struct PoolUser {
        bool isExist;
        uint id;
       uint payment_received; 
    }
    
    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time);

    event getPoolMoneyForLevelEvent(uint _pool, address indexed _user, address indexed _referral, uint _level, uint _time);

    event regPoolEntry(address indexed _user, uint _pool, uint _time);

    event getPoolPayment(address indexed _user,address indexed _receiver, uint _level, uint _time);
    
    constructor () public {
        owner = msg.sender;
        dbAddress = address(0);
    }
    
    function changeDbAddress(address _addr) public returns (bool) {

        require(msg.sender==owner);
        dbAddress = _addr;
        dbInst = Database(dbAddress);
        return true;
    }
    
     function regUser(uint _referrerID) public payable  {

         (bool isExist,,,) = dbInst.users(msg.sender);
          if(!isExist){
                require(_referrerID > 0 && _referrerID <= dbInst.currUserID(),'Incorrect referral ID');
                require(msg.value == 0.1 ether,'Incorrect Value');
               dbInst.saveNewRegData(msg.sender,_referrerID);
               payReferral(1,msg.sender);
                emit regLevelEvent(msg.sender,dbInst.userList(_referrerID), now);
          }
    }
     function payReferral(uint _level,address _user) internal {

         (,,uint256 rId,) = dbInst.users(_user);
         address referer = dbInst.userList(rId);
         bool sent = false;
            uint level_price_local=0;
            if(_level>3){
                level_price_local=uint(dbInst.unlimited_level_price());
            }
            else{
                level_price_local=dbInst.L_PRICE(_level);
            }
            sent = address(uint160(referer)).send(level_price_local);
            if (sent) {
                emit getMoneyForLevelEvent(referer,msg.sender,_level,now);
                (,,uint256 refId,) = dbInst.users(referer);
                if(_level < 100 && refId >= 1){
                    payReferral(_level+1,referer);
                }
                else
                {
                    sendBalance();
                }
            }
        if(!sent) {
            payReferral(_level,referer);
        }
     }
      function payPoolReferral(uint _level,address _user,uint pool) internal {

        (,,uint256 rId,) = dbInst.users(_user);
        address referer = dbInst.userList(rId);
        bool sent = false;
        uint level_price_local=0;
        if(pool==1){
            (bool isExist,,) = dbInst.pool1users(referer);
            if(isExist){
                if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE1(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE1(_level));    
                }
            }                
        }else if(pool==2){
          (isExist,,) = dbInst.pool2users(referer);
          if(isExist){
                if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE2(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE2(_level));    
                }
          }
        }else if(pool==3){
            (isExist,,) = dbInst.pool3users(referer);
            if(isExist){
             if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE3(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE3(_level));    
                }
            }
        }else if(pool==4){
          (isExist,,) = dbInst.pool4users(referer);
            if(isExist){
                 if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE4(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE4(_level));    
                }
            }
        }else if(pool==5){
          (isExist,,) = dbInst.pool5users(referer);
            if(isExist){
                if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE5(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE5(_level));    
                }
             }
        }else if(pool==6){
             (isExist,,) = dbInst.pool6users(referer);
            if(isExist){
                if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE6(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE6(_level));    
                }
             }
        }else if(pool==7){
          (isExist,,) = dbInst.pool7users(referer);
            if(isExist){
                if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE7(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE7(_level));    
                }
             }
        }else if(pool==8){
         (isExist,,) = dbInst.pool8users(referer);
            if(isExist){
                if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE8(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE8(_level));    
                }
             }
        }else if(pool==9){
             (isExist,,) = dbInst.pool9users(referer);
            if(isExist){
                if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE9(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE9(_level));    
                }
             }
        }else if(pool==10){
            (isExist,,) = dbInst.pool10users(referer);
            if(isExist){
                if(_level>=2){
                    level_price_local=uint(dbInst.L_PRICE10(2));
                }else{
                    level_price_local=uint(dbInst.L_PRICE10(_level));    
                }
             }
        }
        if(level_price_local>0){
            if(address(this).balance > level_price_local) 
                sent = address(uint160(referer)).send(level_price_local);
            if (sent) {
                emit getPoolMoneyForLevelEvent(pool,referer,msg.sender,_level,now);
                (,,uint256 refId,) = dbInst.users(referer);
                if(_level < 4 && refId >= 1){
                    payPoolReferral(_level+1,referer,pool);
                }
                else
                {
                    sendBalance();
                }
            }
            if(!sent) {
                payPoolReferral(_level,referer,pool);
            }              
        }else{
            payPoolReferral(_level,referer,pool);
        }
            
}
     
 modifier userExist(){

     (bool isExist,,,) = dbInst.users(msg.sender);
     require(isExist==true,"User Not Registered");
    _;
}
     
  function poolExist(bool isExist) pure private {

      require(isExist!=true,"Already in Pool");
  }
   
   function buyPool(uint _pool) public payable userExist {

       address poolCurrentuser = address(0);
       bool give=true;
       (,,uint256 payment_received) = (false,0,0);
       if(_pool==1){
           require(msg.value == 0.25 ether,'Incorrect Value');
           (bool isExist,,) = dbInst.pool1users(msg.sender);
            if(isExist){ 
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool1userList(dbInst.p1AcUId());
               (,,payment_received) = dbInst.pool1users(poolCurrentuser);
                 uint256 amtSend = 200000000000000000;
            }
       }else if(_pool==2){
           (isExist,,) = dbInst.pool2users(msg.sender);
            if(isExist || msg.value != 500000000000000000){ // 0.5 ether
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool2userList(dbInst.p2AcUId());
                (,,payment_received) = dbInst.pool2users(poolCurrentuser);
                amtSend = 400000000000000000;
            }
       }else if(_pool==3){
           (isExist,,) = dbInst.pool3users(msg.sender);
             if(isExist || msg.value != 1000000000000000000){ // 1 ether
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool3userList(dbInst.p3AcUId());
                (,,payment_received) = dbInst.pool3users(poolCurrentuser);
                amtSend = 800000000000000000;
            }
       }else if(_pool==4){
           require(msg.value == 2.5 ether,'Incorrect Value');
           (isExist,,) = dbInst.pool4users(msg.sender);
            poolExist(isExist);
           poolCurrentuser=dbInst.pool4userList(dbInst.p4AcUId());
           (,,payment_received) = dbInst.pool4users(poolCurrentuser);
           amtSend = 2000000000000000000;
       }else if(_pool==5){
           (isExist,,) = dbInst.pool5users(msg.sender);
             if(isExist || msg.value != 6000000000000000000){ // 6 ether
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool5userList(dbInst.p5AcUId());
               (,,payment_received) = dbInst.pool5users(poolCurrentuser);
                amtSend = 4800000000000000000;
            }
       }else if(_pool==6){
           (isExist,,) = dbInst.pool6users(msg.sender);
           if(isExist || msg.value != 15000000000000000000){ // 15 ether
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool6userList(dbInst.p6AcUId());
               (,,payment_received) = dbInst.pool6users(poolCurrentuser);
               amtSend = 12000000000000000000;                
            }
       }else if(_pool==7){
           (isExist,,) = dbInst.pool7users(msg.sender);
           if(isExist || msg.value != 35000000000000000000){ // 35 ether
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool7userList(dbInst.p7AcUId());
               (,,payment_received) = dbInst.pool7users(poolCurrentuser);
               amtSend = 28000000000000000000;
            }
       }else if(_pool==8){
           (isExist,,) = dbInst.pool8users(msg.sender);
            if(isExist || msg.value != 85000000000000000000){ // 85 ether
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool8userList(dbInst.p8AcUId());
               (,,payment_received) = dbInst.pool8users(poolCurrentuser);
               amtSend = 68000000000000000000;
            }
       }else if(_pool==9){
           (isExist,,) = dbInst.pool9users(msg.sender);
            if(isExist || msg.value!=210000000000000000000){ // 210 ether
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool9userList(dbInst.p10AcUId());
               (,,payment_received) = dbInst.pool9users(poolCurrentuser);
               amtSend = 168000000000000000000;
            }
       }else if(_pool==10){
           (isExist,,) = dbInst.pool10users(msg.sender);
            if(isExist || msg.value!=500000000000000000000){ // 500 ether
               give = false; 
            }else{
                poolCurrentuser=dbInst.pool10userList(dbInst.p10AcUId());
               (,,payment_received) = dbInst.pool10users(poolCurrentuser);
               amtSend = 400000000000000000000;
            }
       }else{
           give = false;
       }
        if(give){
            dbInst.saveNewPlData(_pool,msg.sender);
            bool sent = false;
            sent = address(uint160(poolCurrentuser)).send(amtSend);
            if (sent) {
                payPoolReferral(1,msg.sender,_pool);
                dbInst.updPlPayment(_pool,poolCurrentuser);
                if((payment_received+1)>=3)
                {
                    dbInst.updCurAndActUsr(_pool,2);
                }
                emit getPoolPayment(msg.sender,poolCurrentuser,_pool, now);
            }
            emit regPoolEntry(msg.sender,_pool,now);
        }
    }
   
   function getEthBalance() public view returns(uint) {

        return address(this).balance;
    }
   
    function sendBalance() private
    {

         if (!address(uint160(dbInst.ownerWallet())).send(getEthBalance()))
         {
             
         }
    }
    function sendBalanceToOwner() public
    {

        require(msg.sender==owner);
         if (!address(uint160(dbInst.ownerWallet())).send(getEthBalance()))
         {
             
         }
    } 
    
}