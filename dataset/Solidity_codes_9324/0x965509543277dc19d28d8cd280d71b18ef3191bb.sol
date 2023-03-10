

pragma solidity 0.5.11;


contract Etrix {


    address public _owner;
    Etrix public oldSC = Etrix(0xCB8E1352034b97Fb60fDD891c0b23A32AF29d25d);
    Etrix public newSC = Etrix(0x81c51a0B5c22dcA578039C7401B245aFd34F52F4);
    uint public oldSCUserId = 2;

      struct UserStruct {
        bool isExist;
        uint id;
        uint referrerIDMatrix1;
        uint referrerIDMatrix2;
        address[] referralMatrix1;
        address[] referralMatrix2;
        uint referralCounter;
        mapping(uint => uint) levelExpiredMatrix1;
        mapping(uint => uint) levelExpiredMatrix2;
        mapping(uint => uint) levelExpiredMatrix3; 
    }

    uint constant private REFERRER_1_LEVEL_LIMIT = 2;
    uint constant private PERIOD_LENGTH = 90 days;
    uint public availablePersonID;
    address [] public shareHoldersM1;
    address [] public shareHoldersM2;
    address [] public shareHoldersM3;
    mapping(uint => uint) public LEVEL_PRICE;
    mapping(uint => uint) public LEVEL_PRICEM3;
    uint public REFERRAL_COMMISSION;

    mapping (uint => uint) public uplinesToRcvEth;

    mapping (address => UserStruct) public users;
    mapping (uint => address) public userList;
    uint public currUserID = 0;

    event regLevelEvent(address indexed _user, address indexed _referrer, uint _time);
    event buyLevelEvent(address indexed _user, uint _level, uint _time, uint _matrix);
    event prolongateLevelEvent(address indexed _user, uint _level, uint _time);
    event getMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time, uint _matrix);
    event lostMoneyForLevelEvent(address indexed _user, address indexed _referral, uint _level, uint _time, uint _matrix);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event syncComplete();

    constructor() public {
        _owner = msg.sender;

        LEVEL_PRICE[1] = 0.05 ether;
        LEVEL_PRICE[2] = 0.1 ether;
        LEVEL_PRICE[3] = 0.3 ether;
        LEVEL_PRICE[4] = 1.25 ether;
        LEVEL_PRICE[5] = 5 ether;
        LEVEL_PRICE[6] = 10 ether;
        
        LEVEL_PRICEM3[1] = 0.05 ether;
        LEVEL_PRICEM3[2] = 0.12 ether;
        LEVEL_PRICEM3[3] = 0.35 ether;
        LEVEL_PRICEM3[4] = 1.24 ether;
        LEVEL_PRICEM3[5] = 5.4 ether;
        LEVEL_PRICEM3[6] = 10 ether;

        REFERRAL_COMMISSION = 0.03 ether;

        uplinesToRcvEth[1] = 5;
        uplinesToRcvEth[2] = 6;
        uplinesToRcvEth[3] = 7;
        uplinesToRcvEth[4] = 8;
        uplinesToRcvEth[5] = 9;
        uplinesToRcvEth[6] = 10;
        
        availablePersonID = 1;

    }

    modifier onlyOwner() {

        require(msg.sender == _owner, "only Owner");
        _;
    }

    function () external payable {
      
        uint level;

        if(msg.value == LEVEL_PRICE[1]) level = 1;
        else if(msg.value == LEVEL_PRICE[2]) level = 2;
        else if(msg.value == LEVEL_PRICE[3]) level = 3;
        else if(msg.value == LEVEL_PRICE[4]) level = 4;
        else if(msg.value == LEVEL_PRICE[5]) level = 5;
        else if(msg.value == LEVEL_PRICE[6]) level = 6;
        
        else revert('Incorrect Value send, please check');

        if(users[msg.sender].isExist) 
            buyLevelMatrix2(level);

        else if(level == 1) {
            uint refId = 0;
            address referrer = bytesToAddress(msg.data);

            if(users[referrer].isExist) refId = users[referrer].id;
            else revert('Incorrect referrer id');

            regUser(refId);
        }
        else revert('Please buy first level for 0.05 ETH and then proceed');
    }

    function regUser(uint _referrerID) public payable {


        require(!users[msg.sender].isExist, 'User exist');
        require(address(oldSC) == address(0), 'Initialize Still Open');
        require(_referrerID > 0 && _referrerID <= currUserID, 'Incorrect referrer Id');
        require(msg.value == LEVEL_PRICE[1] + REFERRAL_COMMISSION, 'Incorrect Value');
        

        uint _referrerIDMatrix1;
        uint _referrerIDMatrix2 = _referrerID;

        _referrerIDMatrix1 = findAvailablePersonMatrix1();

        if(users[userList[_referrerIDMatrix2]].referralMatrix2.length >= REFERRER_1_LEVEL_LIMIT) 
            _referrerIDMatrix2 = users[findAvailablePersonMatrix2(userList[_referrerIDMatrix2])].id;
        

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerIDMatrix1: _referrerIDMatrix1,
            referrerIDMatrix2: _referrerIDMatrix2,
            referralCounter: 0,
            referralMatrix1: new address[](0),
            referralMatrix2: new address[](0)
        });

        users[msg.sender] = userStruct;
        userList[currUserID] = msg.sender;

        
        users[msg.sender].levelExpiredMatrix2[1] = now + PERIOD_LENGTH;

        users[userList[_referrerIDMatrix1]].referralMatrix1.push(msg.sender);
        users[userList[_referrerIDMatrix2]].referralMatrix2.push(msg.sender);
        
        address(uint160(userList[_referrerID])).transfer(REFERRAL_COMMISSION);

        payForLevelMatrix2(1,msg.sender);

        users[userList[_referrerID]].referralCounter++;

        emit regLevelEvent(msg.sender, userList[_referrerID], now);
    }
    
    function regExtraUsers(uint [] memory _referrerID, address [] memory _userAddress) public onlyOwner {


        
        require(address(oldSC) != address(0), 'Initialize close');
        require(_referrerID.length == _userAddress.length);

        uint _referrerIDMatrix1;
        uint _referrerIDMatrix2;
        for(uint i = 0; i < _referrerID.length; i++){
            
            (,,,,uint _referralCounter) = newSC.users(_userAddress[i]);
            
        _referrerIDMatrix2 = _referrerID[i];
        _referrerIDMatrix1 = findAvailablePersonMatrix1();

        if(users[userList[_referrerIDMatrix2]].referralMatrix2.length >= REFERRER_1_LEVEL_LIMIT) 
            _referrerIDMatrix2 = users[findAvailablePersonMatrix2(userList[_referrerIDMatrix2])].id;
        

        UserStruct memory userStruct;
        currUserID++;

        userStruct = UserStruct({
            isExist: true,
            id: currUserID,
            referrerIDMatrix1: _referrerIDMatrix1,
            referrerIDMatrix2: _referrerIDMatrix2,
            referralCounter: _referralCounter,
            referralMatrix1: new address[](0),
            referralMatrix2: new address[](0)
        });

        users[_userAddress[i]] = userStruct;
        userList[currUserID] = _userAddress[i];
        
         for(uint j = 1; j <= 6; j++) {

                users[_userAddress[i]].levelExpiredMatrix1[j] = newSC.viewUserLevelExpiredMatrix1(_userAddress[i], j);
                users[_userAddress[i]].levelExpiredMatrix2[j] = newSC.viewUserLevelExpiredMatrix2(_userAddress[i], j);
                users[_userAddress[i]].levelExpiredMatrix3[j] = newSC.viewUserLevelExpiredMatrix3(_userAddress[i], j);
         }

        users[userList[_referrerIDMatrix1]].referralMatrix1.push(_userAddress[i]);
        users[userList[_referrerIDMatrix2]].referralMatrix2.push(_userAddress[i]);
        
        
        users[userList[_referrerID[i]]].referralCounter++;

        emit regLevelEvent(msg.sender, userList[_referrerID[i]], now);
    }
}

    function preRegAdmins(address [] memory _adminAddress) public onlyOwner{


        require(currUserID <= 100, "No more admins can be registered");

        UserStruct memory userStruct;

        for(uint i = 0; i < _adminAddress.length; i++){

            require(!users[_adminAddress[i]].isExist, 'One of the users exist');
            currUserID++;

            if(currUserID == 1){
                userStruct = UserStruct({
                isExist: true,
                id: currUserID,
                referrerIDMatrix1: 1,
                referrerIDMatrix2: 1,
                referralCounter: 87,
                referralMatrix1: new address[](0),
                referralMatrix2: new address[](0)
        });

            users[_adminAddress[i]] = userStruct;
            userList[currUserID] = _adminAddress[i];

            for(uint j = 1; j <= 6; j++) {
                users[_adminAddress[i]].levelExpiredMatrix1[j] = 66666666666;
                users[_adminAddress[i]].levelExpiredMatrix2[j] = 66666666666;
                users[_adminAddress[i]].levelExpiredMatrix3[j] = 66666666666;
            }
            
        }
            else {
                    uint _referrerIDMatrix1;
                    uint _referrerIDMatrix2 = 1;

                    _referrerIDMatrix1 = findAvailablePersonMatrix1();

                    if(users[userList[_referrerIDMatrix2]].referralMatrix2.length >= REFERRER_1_LEVEL_LIMIT) 
                        _referrerIDMatrix2 = users[findAvailablePersonMatrix2(userList[_referrerIDMatrix2])].id;

                                       
                    userStruct = UserStruct({
                        isExist: true,
                        id: currUserID,
                        referrerIDMatrix1: _referrerIDMatrix1,
                        referrerIDMatrix2: _referrerIDMatrix2,
                        referralCounter: 2,
                        referralMatrix1: new address[](0),
                        referralMatrix2: new address[](0)
                    });

                    users[_adminAddress[i]] = userStruct;
                    userList[currUserID] = _adminAddress[i];

                    for(uint j = 1; j <= 6; j++) {
                        users[_adminAddress[i]].levelExpiredMatrix1[j] = 66666666666;
                        users[_adminAddress[i]].levelExpiredMatrix2[j] = 66666666666;
                        users[_adminAddress[i]].levelExpiredMatrix3[j] = 66666666666;
                    }

                    users[userList[_referrerIDMatrix1]].referralMatrix1.push(_adminAddress[i]);
                    users[userList[_referrerIDMatrix2]].referralMatrix2.push(_adminAddress[i]);

                }
                emit regLevelEvent(_adminAddress[i], address(0x0), block.timestamp);
    }
}
    
    function changeAvailablePerson(uint _availablePersonID) public onlyOwner{

        
        availablePersonID = _availablePersonID;
    }

    function syncClose() external onlyOwner {

        require(address(oldSC) != address(0), 'Initialize already closed');
        oldSC = Etrix(0);
    }

    function syncWithOldSC(uint limit) public onlyOwner {

        require(address(oldSC) != address(0), 'Initialize closed');
        
        address refM1;
        address refM2;
        

        for(uint i = 0; i < limit; i++) {
            address user = oldSC.userList(oldSCUserId);
            (,, uint referrerIDM1, uint referrerIDM2,uint _referralCounter) = oldSC.users(user);

            
                oldSCUserId++;
                
                 refM1 = oldSC.userList(referrerIDM1);
                 refM2 = oldSC.userList(referrerIDM2);

                    users[user].isExist= true;
                    users[user].id= ++currUserID;
                    users[user].referrerIDMatrix1= referrerIDM1;
                    users[user].referrerIDMatrix2= referrerIDM2;
                    users[user].referralCounter= _referralCounter;
                    
                
                userList[currUserID] = user;

                users[refM1].referralMatrix1.push(user);
                users[refM2].referralMatrix2.push(user);
                
                    for(uint j = 1; j <= 6; j++) {
                         
                         users[user].levelExpiredMatrix1[j] = newSC.viewUserLevelExpiredMatrix1(user, j);
                         users[user].levelExpiredMatrix2[j] = newSC.viewUserLevelExpiredMatrix2(user, j);
                         users[user].levelExpiredMatrix3[j] = newSC.viewUserLevelExpiredMatrix3(user, j);
                    }

                    emit regLevelEvent(user, address(0x0), block.timestamp);
        }
        emit syncComplete();
    }


    function addShareHolderM1(address [] memory _shareHolderAddress) public onlyOwner returns(address[] memory){


        for(uint i=0; i < _shareHolderAddress.length; i++){

            if(shareHoldersM1.length < 20) {
                shareHoldersM1.push(_shareHolderAddress[i]);
            }
        }
        return shareHoldersM1;
    }

    function removeShareHolderM1(address  _shareHolderAddress) public onlyOwner returns(address[] memory){


        for(uint i=0; i < shareHoldersM1.length; i++){
            if(shareHoldersM1[i] == _shareHolderAddress) {
                shareHoldersM1[i] = shareHoldersM1[shareHoldersM1.length-1];
                delete shareHoldersM1[shareHoldersM1.length-1];
                shareHoldersM1.length--;
            }
        }
        return shareHoldersM1;

    }

    function addShareHolderM2(address [] memory _shareHolderAddress) public onlyOwner returns(address[] memory){


        for(uint i=0; i < _shareHolderAddress.length; i++){

            if(shareHoldersM2.length < 20) {
                shareHoldersM2.push(_shareHolderAddress[i]);
            }
        }
        return shareHoldersM2;
    }

    function removeShareHolderM2(address  _shareHolderAddress) public onlyOwner returns(address[] memory){


        for(uint i=0; i < shareHoldersM2.length; i++){
            if(shareHoldersM2[i] == _shareHolderAddress) {
                shareHoldersM2[i] = shareHoldersM2[shareHoldersM2.length-1];
                delete shareHoldersM2[shareHoldersM2.length-1];
                shareHoldersM2.length--;
            }
        }
        return shareHoldersM2;

    }

    function addShareHolderM3(address [] memory _shareHolderAddress) public onlyOwner returns(address[] memory){


        for(uint i=0; i < _shareHolderAddress.length; i++){

            if(shareHoldersM3.length < 20) {
                shareHoldersM3.push(_shareHolderAddress[i]);
            }
        }
        return shareHoldersM3;
    }

    function removeShareHolderM3(address  _shareHolderAddress) public onlyOwner returns(address[] memory){


        for(uint i=0; i < shareHoldersM3.length; i++){
            if(shareHoldersM3[i] == _shareHolderAddress) {
                shareHoldersM3[i] = shareHoldersM3[shareHoldersM3.length-1];
                delete shareHoldersM3[shareHoldersM3.length-1];
                shareHoldersM3.length--;
            }
        }
        return shareHoldersM3;

    }

    function findAvailablePersonMatrix1() internal returns(uint){

       
        uint _referrerID;
        uint _referralLength = users[userList[availablePersonID]].referralMatrix1.length;
        
         if(_referralLength >= REFERRER_1_LEVEL_LIMIT) {       
             availablePersonID++;
             _referrerID = availablePersonID;
        }
        else if( _referralLength == 1) {
            _referrerID = availablePersonID;
            availablePersonID++;            
        }
        else{
             _referrerID = availablePersonID;
        }

        return _referrerID;
    }

    function findAvailablePersonMatrix2(address _user) public view returns(address) {

        if(users[_user].referralMatrix2.length < REFERRER_1_LEVEL_LIMIT) return _user;

        address[] memory referrals = new address[](1022);
        referrals[0] = users[_user].referralMatrix2[0];
        referrals[1] = users[_user].referralMatrix2[1];

        address freeReferrer;
        bool noFreeReferrer = true;

        for(uint i = 0; i < 1022; i++) {
            if(users[referrals[i]].referralMatrix2.length >= REFERRER_1_LEVEL_LIMIT) {
                if(i < 510) {
                    referrals[(i+1)*2] = users[referrals[i]].referralMatrix2[0];
                    referrals[(i+1)*2+1] = users[referrals[i]].referralMatrix2[1];
                }
            }
            else {
                noFreeReferrer = false;
                freeReferrer = referrals[i];
                break;
            }
        }

        require(!noFreeReferrer, 'No Free Referrer');

        return freeReferrer;
    }


    function getUserUpline(address _user, uint height)
    public
    view
    returns (address)
  {

    if (height <= 0 || _user == address(0)) {
      return _user;
    }

    return this.getUserUpline(userList[users[_user].referrerIDMatrix2], height - 1);
  }

   

    function buyLevelMatrix1(uint _level) public payable {


        require(users[msg.sender].isExist, 'User not exist'); 
        require(_level > 0 && _level <= 6, 'Incorrect level');

        if(_level == 1) {
            require(msg.value == LEVEL_PRICE[1], 'Incorrect Value');

            if(users[msg.sender].levelExpiredMatrix1[1] > now)             
                users[msg.sender].levelExpiredMatrix1[1] += PERIOD_LENGTH;
                            
            else 
                users[msg.sender].levelExpiredMatrix1[1] = now + PERIOD_LENGTH;
            
        }
        else {
            require(msg.value == LEVEL_PRICE[_level], 'Incorrect Value');

            for(uint l =_level - 1; l > 0; l--) require(users[msg.sender].levelExpiredMatrix1[l] >= now, 'Buy the previous level');

            if(users[msg.sender].levelExpiredMatrix1[_level] == 0 || now > users[msg.sender].levelExpiredMatrix1[_level])
                users[msg.sender].levelExpiredMatrix1[_level] = now + PERIOD_LENGTH;
            else users[msg.sender].levelExpiredMatrix1[_level] += PERIOD_LENGTH;
        }

        payForLevelMatrix1(_level, msg.sender);

        emit buyLevelEvent(msg.sender, _level, now, 1);
    }

    function buyLevelMatrix2(uint _level) public payable {

        
        require(users[msg.sender].isExist, 'User not exist'); 
        require(_level > 0 && _level <= 6, 'Incorrect level');

        if(_level == 1) {
            require(msg.value == LEVEL_PRICE[1], 'Incorrect Value');

            if(users[msg.sender].levelExpiredMatrix2[1] > now)               
                users[msg.sender].levelExpiredMatrix2[1] += PERIOD_LENGTH;
                            
            else 
                users[msg.sender].levelExpiredMatrix2[1] = now + PERIOD_LENGTH;
            
       }
        else {
            require(msg.value == LEVEL_PRICE[_level], 'Incorrect Value');

            for(uint l =_level - 1; l > 0; l--) require(users[msg.sender].levelExpiredMatrix2[l] >= now, 'Buy the previous level');

            if(users[msg.sender].levelExpiredMatrix2[_level] == 0 || now > users[msg.sender].levelExpiredMatrix2[_level]) 
                users[msg.sender].levelExpiredMatrix2[_level] = now + PERIOD_LENGTH;
            
            else users[msg.sender].levelExpiredMatrix2[_level] += PERIOD_LENGTH;
        }

        payForLevelMatrix2(_level, msg.sender);

        emit buyLevelEvent(msg.sender, _level, now, 2);
    }

    function buyLevelMatrix3(uint _level) public payable {

        
        require(users[msg.sender].isExist, 'User not exist'); 
        require(_level > 0 && _level <= 6, 'Incorrect level');

        if(_level == 1) {
            require(msg.value == LEVEL_PRICEM3[1], 'Incorrect Value');

            if(users[msg.sender].levelExpiredMatrix3[1] > now)               
                users[msg.sender].levelExpiredMatrix3[1] += PERIOD_LENGTH;
                            
            else 
                users[msg.sender].levelExpiredMatrix3[1] = now + PERIOD_LENGTH;
            
       }
        else {
            require(msg.value == LEVEL_PRICEM3[_level], 'Incorrect Value');

            for(uint l =_level - 1; l > 0; l--) require(users[msg.sender].levelExpiredMatrix3[l] >= now, 'Buy the previous level');

            if(users[msg.sender].levelExpiredMatrix3[_level] == 0 || now > users[msg.sender].levelExpiredMatrix3[_level]) 
                users[msg.sender].levelExpiredMatrix3[_level] = now + PERIOD_LENGTH;
            
            else users[msg.sender].levelExpiredMatrix3[_level] += PERIOD_LENGTH;
        }

        payForLevelMatrix3(_level, msg.sender);

        emit buyLevelEvent(msg.sender, _level, now, 3);
    }

    function payForLevelMatrix1(uint _level, address _user) internal {

        address actualReferer;
        address tempReferer1;
        address tempReferer2;
        uint userID;

        if(_level == 1) {
            actualReferer = userList[users[_user].referrerIDMatrix1];
            userID = users[actualReferer].id;
        }
        else if(_level == 2) {
            tempReferer1 = userList[users[_user].referrerIDMatrix1];
            actualReferer = userList[users[tempReferer1].referrerIDMatrix1];
            userID = users[actualReferer].id;
        }
        else if(_level == 3) {
            tempReferer1 = userList[users[_user].referrerIDMatrix1];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix1];
            actualReferer = userList[users[tempReferer2].referrerIDMatrix1];
            userID = users[actualReferer].id;
        }
        else if(_level == 4) {
            tempReferer1 = userList[users[_user].referrerIDMatrix1];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix1];
            tempReferer1 = userList[users[tempReferer2].referrerIDMatrix1];
            actualReferer = userList[users[tempReferer1].referrerIDMatrix1];
            userID = users[actualReferer].id;
        }
        else if(_level == 5) {
            tempReferer1 = userList[users[_user].referrerIDMatrix1];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix1];
            tempReferer1 = userList[users[tempReferer2].referrerIDMatrix1];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix1];
            actualReferer = userList[users[tempReferer2].referrerIDMatrix1];
            userID = users[actualReferer].id;
        }
        else if(_level == 6) {
            tempReferer1 = userList[users[_user].referrerIDMatrix1];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix1];
            tempReferer1 = userList[users[tempReferer2].referrerIDMatrix1];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix1];
            tempReferer1 = userList[users[tempReferer2].referrerIDMatrix1];
            actualReferer = userList[users[tempReferer1].referrerIDMatrix1];
            userID = users[actualReferer].id;
        }

        if(!users[actualReferer].isExist) actualReferer = userList[1];

        bool sent = false;
        
        if(userID > 0 && userID <= 63) {
           for(uint i=0; i < shareHoldersM1.length; i++) {
                address(uint160(shareHoldersM1[i])).transfer(LEVEL_PRICE[_level]/(shareHoldersM1.length));
                emit getMoneyForLevelEvent(shareHoldersM1[i], msg.sender, _level, now, 1);
            }
            if(address(this).balance > 0)
                address(uint160(userList[1])).transfer(address(this).balance);
          }
        
        else{
          if(users[actualReferer].levelExpiredMatrix1[_level] >= now && users[actualReferer].referralCounter >= 2) {
              sent = address(uint160(actualReferer)).send(LEVEL_PRICE[_level]);
                if (sent) {
                        emit getMoneyForLevelEvent(actualReferer, msg.sender, _level, now, 1);
                    }
                }
            if(!sent) {
              emit lostMoneyForLevelEvent(actualReferer, msg.sender, _level, now, 1);
                payForLevelMatrix1(_level, actualReferer);
             }

        }
            
    }

    function payForLevelMatrix2(uint _level, address _user) internal {

        address actualReferer;
        address tempReferer1;
        address tempReferer2;
        uint userID;

        if(_level == 1) {
            actualReferer = userList[users[_user].referrerIDMatrix2];
            userID = users[actualReferer].id;
        }
        else if(_level == 2) {
            tempReferer1 = userList[users[_user].referrerIDMatrix2];
            actualReferer = userList[users[tempReferer1].referrerIDMatrix2];
            userID = users[actualReferer].id;
        }
        else if(_level == 3) {
            tempReferer1 = userList[users[_user].referrerIDMatrix2];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix2];
            actualReferer = userList[users[tempReferer2].referrerIDMatrix2];
            userID = users[actualReferer].id;
        }
        else if(_level == 4) {
            tempReferer1 = userList[users[_user].referrerIDMatrix2];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix2];
            tempReferer1 = userList[users[tempReferer2].referrerIDMatrix2];
            actualReferer = userList[users[tempReferer1].referrerIDMatrix2];
            userID = users[actualReferer].id;
        }
        else if(_level == 5) {
            tempReferer1 = userList[users[_user].referrerIDMatrix2];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix2];
            tempReferer1 = userList[users[tempReferer2].referrerIDMatrix2];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix2];
            actualReferer = userList[users[tempReferer2].referrerIDMatrix2];
            userID = users[actualReferer].id;
        }
        else if(_level == 6) {
            tempReferer1 = userList[users[_user].referrerIDMatrix2];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix2];
            tempReferer1 = userList[users[tempReferer2].referrerIDMatrix2];
            tempReferer2 = userList[users[tempReferer1].referrerIDMatrix2];
            tempReferer1 = userList[users[tempReferer2].referrerIDMatrix2];
            actualReferer = userList[users[tempReferer1].referrerIDMatrix2];
            userID = users[actualReferer].id;
        }

        if(!users[actualReferer].isExist) actualReferer = userList[1];

        bool sent = false;
        
        if(userID > 0 && userID <= 63) {
           for(uint i=0; i < shareHoldersM2.length; i++) {
                address(uint160(shareHoldersM2[i])).transfer(LEVEL_PRICE[_level]/(shareHoldersM2.length));
                emit getMoneyForLevelEvent(shareHoldersM2[i], msg.sender, _level, now, 2);
            }
            if(address(this).balance > 0)
                address(uint160(userList[1])).transfer(address(this).balance);
          }
        
        else{
          if(users[actualReferer].levelExpiredMatrix2[_level] >= now) {
              sent = address(uint160(actualReferer)).send(LEVEL_PRICE[_level]);
                if (sent) {
                        emit getMoneyForLevelEvent(actualReferer, msg.sender, _level, now, 2);
                    }
                }
            if(!sent) {
              emit lostMoneyForLevelEvent(actualReferer, msg.sender, _level, now, 2);
                payForLevelMatrix2(_level, actualReferer);
             }
        }
            
    }

    function payForLevelMatrix3(uint _level, address _user) internal {

        uint height = _level;
        address referrer = getUserUpline(_user, height);

        if (referrer == address(0)) { referrer = userList[1]; }
    
        uint uplines = uplinesToRcvEth[_level];
        bool chkLostProfit = false;
        for (uint i = 1; i <= uplines; i++) {
            referrer = getUserUpline(_user, i);
          
            if (viewUserLevelExpiredMatrix3(referrer, _level) < now) {
                chkLostProfit = true;
                uplines++;
                emit lostMoneyForLevelEvent(referrer, msg.sender, _level, now, 3);
                continue;
            }
            else {chkLostProfit = false;}
            
            if (referrer == address(0)) { referrer = userList[1]; }

            if(users[referrer].id >0 && users[referrer].id <= 63){
                
                uint test = (uplines - i) + 1;
                uint totalValue = test * (LEVEL_PRICEM3[_level]/uplinesToRcvEth[_level]);
                
                for(uint j=0; j < shareHoldersM3.length; j++) {
                        address(uint160(shareHoldersM3[j])).transfer(totalValue/(shareHoldersM3.length));
                        emit getMoneyForLevelEvent(shareHoldersM3[j], msg.sender, _level, now, 3);
                    }
                    break;
                    
            }
            else {
                if (address(uint160(referrer)).send( LEVEL_PRICEM3[_level] / uplinesToRcvEth[_level] )) {               
                    emit getMoneyForLevelEvent(referrer, msg.sender, _level, now, 3);
                }
            }               
    }
            if(address(this).balance > 0)
                address(uint160(userList[1])).transfer(address(this).balance);
          
  }

    function transferOwnership(address newOwner) external onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function viewUserReferralMatrix1(address _user) public view returns(address[] memory) {

        return users[_user].referralMatrix1;
    }

    function viewUserReferralMatrix2(address _user) public view returns(address[] memory) {

        return users[_user].referralMatrix2;
    }
    
    function viewUserLevelExpiredMatrix1(address _user, uint _level) public view returns(uint256) {

        return users[_user].levelExpiredMatrix1[_level];
    }

    function viewUserLevelExpiredMatrix2(address _user, uint _level) public view returns(uint256) {

        return users[_user].levelExpiredMatrix2[_level];
    }

    function viewUserLevelExpiredMatrix3(address _user, uint _level) public view returns(uint256) {

        return users[_user].levelExpiredMatrix3[_level];
    }

    function bytesToAddress(bytes memory bys) private pure returns (address addr) {

        assembly {
            addr := mload(add(bys, 20))
        }
    }
}