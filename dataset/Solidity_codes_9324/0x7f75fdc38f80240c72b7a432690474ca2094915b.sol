
pragma solidity 0.5.16;







contract owned
{

    address payable internal owner;
    address payable internal newOwner;

    event OwnershipTransferred(address payable _from, address payable _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable _newOwner) public onlyOwner {

        newOwner = _newOwner;
    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}


interface stableCoin
{

    function transfer(address _to, uint256 _amount) external returns (bool);

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);    

}

interface  externalInterface
{

    function processExternalMain(uint256 _networkId,uint256 _planIndex,uint256 _userId,  uint256 _subUserId, uint256 _referrerId, uint256 _paidAmount, bool mainTree) external returns(bool);

}


contract megaTree is owned
{

   
    uint256 public networkPrice = 2 ether;  // Price to start new network admin can change value as per demand/supply
    uint256 public minPlanPrice = 0.00005 ether; // super admin need to set this minimum plan price for each plan to avoid system abuse ro fail
    uint256 public networkIdCount;  // total network running in the system
    uint256 public limitNetworkCount=5;
    mapping(address => uint256) public networkId; // network id of owner of particular network
    mapping(uint256 => address payable) public networkOwner; // network owner of id of particular network
    mapping(uint256 => uint256) platformCharge;  // platform Charge for tha particuar network
    uint256 public platFormFeePercentage = 1000000;  // if registration fee is >= limit this %age will be charged for joining 1000000 = 1.000000%;

    mapping(address => uint256) public validStableCoin; 

    struct userInfo
    {
        uint256 baseUserId;
        address payable user;
        uint256 parentId;
        uint256 referrerId;
        uint256 childCount;
        uint256 lastBoughtLevel;
        uint256 referralCount;
        uint128 levelExpiry;
        uint256[] childIds;
    }

    mapping(uint256 => mapping(uint256 => mapping(bool => userInfo[]))) public userInfos;  // tree records of an id , bool = true then main tree else sub tree


    mapping(uint256 => mapping(uint256 => mapping(bool => mapping(address => uint256[])))) public userIndex; // to retrive ids from the given address for particular tree id
    mapping(uint256 => mapping(uint256 => mapping(bool => mapping(uint256 => uint256)))) public subUserId;
    mapping(uint256 => address) public coinAddress;  // defined payment coin for particular network
    mapping(uint256 => bool) public pausenetwork; // In case of emergency or due to any reason networkOwner can pause entire or partial
    mapping(uint256 => bool) public goToPublic;  // once network owner  puts a network to public, he can not do any plan change further




    
    struct etherOutPlan
    {
        bytes16 name;
        uint256[] payoutType;
        uint256[] payoutTo;
        uint256[] payoutPercentage;
    }


    struct etherInPlan
    {
        bytes16 name;
        uint256 maxChild;     // If max child is 0 then no tree placing will be done for this plan only fund will move
        uint256 etheroutPlanId;  // Pay in amount will move ( pay to eligible ) according ot this id
        bool autoPlaceInTree;   // If true referrer will not be effective and member will join nearest blank slot; 
        uint256 nextBlankSlot;  // If auto place them new arrival will join below this id
        bool allowJoinAgain;  // same address can join again and again or not  
        bool triggerExternalContract;    // If some plan buy need extra action to do custom things should be developed on demand and here it should be true
        uint128 buyPrice;    // buy price of plan ( level )
        uint128 planExpiry;   // This particular level will expire after given seconds count
        bool[] triggerSubTree;  // If system has sub tree plan will thrigger that If index of that plan is true
    }


    mapping(uint256 => mapping (bool => etherInPlan[])) public etherInPlans; 


    mapping(uint256 => etherOutPlan[]) public etherOutPlans;
    mapping(uint256 => mapping( uint256 => uint256)) public poolAmount; 

    mapping(uint256 => address) public externalContract;  // this applies only on payoutType 4 to do custom distribution and custom things also can be done
    mapping(uint256 => uint256) public adminDeduction;  // this percent from all payout will go to admin, if 0 then no deduction for admin

    struct payInput
    {
        uint256 _networkId;
        uint256 _planIndex;
        uint256 _userId;
        uint256 _subUserId;
        uint256 _paidAmount;
        bool mainTree;
    }


    event doTransactionEv(uint256 timeNow, uint256 indexed _networkId, address payable from, address payable to,uint256 amount,uint256 paidToAdmin, uint256 indexed _planIndex, bool indexed mainTree);
    function doTransaction(uint256 _networkId, address payable from, address payable to,uint256 amount,uint256 _planIndex, bool mainTree, uint256 toUserId) internal returns(bool)
    {

        address _coinAddress = coinAddress[_networkId];
        address payable _networkOwner = networkOwner[_networkId];

        if(to != owner && from != address(0) && to != address(this)) 
        {
            if(userInfos[_networkId][0][mainTree][toUserId].levelExpiry < now)  to = _networkOwner; 
        }
        uint256 payAdmin;
        if(to != owner && to != _networkOwner && to != address(this)) payAdmin = amount * adminDeduction[_networkId] / 100000000;

        if(_coinAddress == address(0))
        {
            if(to != address(this)) 
            {
                to.transfer(amount - payAdmin);
                _networkOwner.transfer(payAdmin);
            }
        }
        else
        {
            if(from != address(0))
            {
                require( stableCoin(_coinAddress).transferFrom(from, address(this), amount),"token reveiving failed");
            }
            else
            {
                require( stableCoin(_coinAddress).transfer(to, (amount - payAdmin)),"transfer to user fail");
                if(payAdmin > 0) require( stableCoin(_coinAddress).transfer(_networkOwner, payAdmin),"transfer to admin fail");
            }
        }
        emit doTransactionEv(now,_networkId,from,to,amount,payAdmin,_planIndex,mainTree);
        return true;
    }

    function() external payable
    {
        revert();
    }

    function checkAmount(uint256 amount, uint256 price, address _coinAddress ) public view returns (bool)
    {

        uint256 amt = amount * validStableCoin[_coinAddress] / 100000000;
        if(price == amt ) return true;
        return false;
    }

    event BuynetworkEv(uint256 timeNow,address indexed user,uint256 indexed paidAmount,uint256 indexed networkIDCount);
    function BuyNetwork(address _coinAddress, uint256 amount) public payable returns(bool)
    {

        require(networkId[msg.sender] == 0,"same address can not own two network");
        require(networkIdCount < limitNetworkCount, "max network count reached");
        require(_coinAddress == address(0) || validStableCoin[_coinAddress] > 0, "Invalid coin address");
        networkIdCount++;       
        if(_coinAddress != address(0)) 
        {
            require(checkAmount(amount,networkPrice, _coinAddress), "Invalid amount sent");
            require( stableCoin(_coinAddress).transferFrom(msg.sender, owner, amount),"token reveiving failed"); 
        }
        else
        {
            require(msg.value == networkPrice, "Ivalid ether sent");
            amount = msg.value;
            owner.transfer(amount);
        }  
        uint nID = networkIdCount;     
        networkId[msg.sender] = nID;
        networkOwner[nID] = msg.sender;
        platformCharge[networkIdCount] = platFormFeePercentage;
        coinAddress[nID] = _coinAddress;
        pausenetwork[nID] = true;               
        emit BuynetworkEv(now, msg.sender, msg.value, networkIdCount);
    }

    event addEtherInPlanEv(uint256 timeNow, uint256 indexed _networkId, bytes16 indexed _name,uint128 _buyPrice,uint128 _planExpiry, uint256 _maxChild,bool _autoPlaceInTree,bool _allowJoinAgain, uint256 _etheroutPlanId,bool[] _triggerSubTree, bool  indexed _triggerExternalContract  );
    function addEtherInPlan(uint256 _networkId, bytes16 _name,uint128 _buyPrice,uint128 _planExpiry, uint256 _maxChild,bool _autoPlaceInTree,bool _allowJoinAgain, uint256 _etheroutPlanId,bool[] memory _triggerSubTree, bool  _triggerExternalContract  ) public returns(bool)
    {

        require(networkId[msg.sender] == _networkId,"Invalid caller");
        require(_etheroutPlanId < etherOutPlans[_networkId].length, "please define required ether out plan first");
        require(!goToPublic[_networkId], "network in function cannot change now");
        require(_triggerSubTree.length == etherInPlans[_networkId][false].length, "Invalid _triggerSubTree count");
        if(etherInPlans[_networkId][true].length == 0) require( _maxChild > 0,"maxChild cannot be 0 for first plan");
        require(_buyPrice >= minPlanPrice, "plan price is less then minimum");
        require(_planExpiry > 0, "plan expiry can not be 0");
        require(checkTotalPercentage(_networkId,_etheroutPlanId,_triggerSubTree), "payout not matching 100% ");
        if(etherInPlans[_networkId][true].length > 0) _autoPlaceInTree = true;
        etherInPlan memory temp;
        temp.name = _name;
        temp.buyPrice = _buyPrice;
        temp.planExpiry = _planExpiry;
        temp.maxChild = _maxChild;
        temp.autoPlaceInTree = _autoPlaceInTree;
        temp.allowJoinAgain = _allowJoinAgain;
        temp.etheroutPlanId = _etheroutPlanId;
        temp.triggerSubTree = _triggerSubTree;
        temp.triggerExternalContract = _triggerExternalContract;
        etherInPlans[_networkId][true].push(temp);
        emit addEtherInPlanEv(now, _networkId,_name,_buyPrice,_planExpiry, _maxChild,_autoPlaceInTree,_allowJoinAgain,_etheroutPlanId,_triggerSubTree,_triggerExternalContract );
        return true;
    }

    function setExternalContract(uint256 _networkId, address _externalContract, uint256 _adminDeduction ) public returns(bool)
    {

        require(networkId[msg.sender] == _networkId,"Invalid caller");
        require(!goToPublic[_networkId], "network in function cannot change now");
        externalContract[_networkId] = _externalContract;
        adminDeduction[_networkId] = _adminDeduction;
        return true;
    }


    function checkTotalPercentage(uint256 _networkId,uint256 _etheroutPlanId, bool[] memory _triggerSubTree) internal view returns(bool)
    {

        uint256 i;
        uint totalPercent = payoutPercentageSum(_networkId, _etheroutPlanId) + platformCharge[_networkId];
        for(i=0;i<_triggerSubTree.length; i++)
        {
            if(_triggerSubTree[i]) totalPercent += payoutPercentageSum(_networkId, etherInPlans[_networkId][false][i].etheroutPlanId);
        }
        require(totalPercent == 100000000 + platformCharge[_networkId], "payout sum is not 100 $");
        return true;
    }

    event addSubTreePlanEv(uint256 timeNow, uint256 indexed  _networkId, bytes16 indexed _name,uint128 _planExpiry, uint256 _maxChild,bool _allowJoinAgain, uint256 _etheroutPlanId,bool indexed _triggerExternalContract );
    function addSubTreePlan(uint256 _networkId, bytes16 _name,uint128 _planExpiry, uint256 _maxChild,bool _allowJoinAgain, uint256 _etheroutPlanId,bool _triggerExternalContract ) public returns(bool)
    {

        require(networkId[msg.sender] == _networkId,"Invalid caller");
        require(_etheroutPlanId < etherOutPlans[_networkId].length, "please define required ether out plan first");
        require(!goToPublic[_networkId], "network in function cannot change now");
        require(_planExpiry > 0, "plan expiry can not be 0");

        etherInPlan memory temp;
        temp.name = _name;
        temp.planExpiry = _planExpiry;
        temp.maxChild = _maxChild;
        temp.autoPlaceInTree = true;
        temp.allowJoinAgain = _allowJoinAgain;
        temp.etheroutPlanId = _etheroutPlanId;
        temp.triggerExternalContract = _triggerExternalContract;
        etherInPlans[_networkId][false].push(temp);
        emit addSubTreePlanEv(now,_networkId,_name,_planExpiry,_maxChild,_allowJoinAgain,_etheroutPlanId,_triggerExternalContract );
        return true;
    }


    event addEtherOutPlansEv(uint256 timeNow, uint256 indexed _networkId, bytes16 indexed _name,uint256[] _payoutType, uint256[] _payoutTo,uint256[] indexed _payoutPercentage);   
    function addEtherOutPlans(uint256 _networkId, bytes16 _name,uint256[] memory _payoutType, uint256[] memory _payoutTo,uint256[] memory _payoutPercentage) public returns(bool)
    {

        require(networkId[msg.sender] == _networkId,"Invalid caller");
        require(!goToPublic[_networkId], "network in function cannot change now");
        require(_payoutType.length == _payoutTo.length && _payoutType.length == _payoutPercentage.length);
        for(uint i=0;i<_payoutType.length;i++)
        {
            require(_payoutType[i] < 5, "_payoutTo should be 0 ~ 4 not more");
        }
        etherOutPlan memory temp;
        temp.name = _name;
        temp.payoutType = _payoutType;
        temp.payoutTo = _payoutTo;
        temp.payoutPercentage = _payoutPercentage;
        etherOutPlans[_networkId].push(temp);
        emit addEtherOutPlansEv(now,_networkId,_name,_payoutType,_payoutTo,_payoutPercentage);
        return true;
    }


    event startMynetworkEv(uint256 timeNow, uint256 indexed _networkId);
    function startMynetwork(uint256 _networkId) public returns(bool)
    {

        require(!goToPublic[_networkId], "network in function cannot change now");
        require(networkId[msg.sender] == _networkId,"Invalid caller");      
        uint256 len = etherInPlans[_networkId][true].length;
        require(len > 0, "no etherInPlan defined");
        for(uint256 i=0; i< len;i++)
        {
            etherInPlan memory temp;
            temp = etherInPlans[_networkId][true][i];
            _buyPlan(_networkId,i, 0, 0, 0,temp, 0, true);
        }
        pausenetwork[_networkId] = false;
        goToPublic[_networkId] = true;
        emit startMynetworkEv(now,_networkId);
        return true;
    }

    event pauseReleaseMynetworkEv(uint256 timeNow, uint256 indexed _networkId, bool indexed pause);
    function pauseReleaseMynetwork(uint256 _networkId, bool pause) public returns(bool)
    {

        require(networkId[msg.sender] == _networkId);
        pausenetwork[_networkId]= pause;
        emit pauseReleaseMynetworkEv(now, _networkId, pause);
        return true;
    }




    event regUserEv(uint timeNow, uint256 indexed _networkId,uint256 indexed _planIndex, address payable indexed _user,uint256 _userId, uint256 _referrerId, uint256 _parentId, uint256 amount);
    function regUser(uint256 _networkId,uint256 _referrerId,uint256 _parentId, uint256 amount) public payable returns(bool)
    {

        require(tx.origin != address(0), "invalid sender" );
        require(!pausenetwork[_networkId] && goToPublic[_networkId], "not ready or paused by admin");
        require(_networkId <= networkIdCount && _networkId > 0, "invalid network id" );
        require(userInfos[_networkId][0][true].length > _referrerId,"_referrerId not exist");
        address _coinAddress = coinAddress[_networkId];
        etherInPlan memory temp;
        temp = etherInPlans[_networkId][true][0];
        if(_coinAddress != address(0)) 
        {
            require(checkAmount(amount,temp.buyPrice, _coinAddress), "Invalid amount sent");
            require(doTransaction(_networkId, tx.origin, address(this),amount,0,true,0), "amount tx fail");  
        }
        else
        {
            require(msg.value == temp.buyPrice, "Ivalid ether sent");
            amount = msg.value;
        }      
        require(_buyPlan(_networkId,0,0, _referrerId, _parentId,temp, amount, true),"reg user fail");
        return true;
    }

    event buyLevelEv(uint timeNow, uint256 indexed _networkId,uint256 indexed _planIndex,uint256 _subPlanIndex, uint256 indexed _userId,uint256 _subUserId,uint256 _parentId, uint256 amount, bool mainTree);
    
    function buyLevel(uint256 _networkId,uint256 _planIndex, uint256 _userId, uint256 amount) public payable returns(bool)
    {

        require(tx.origin != address(0), "invalid sender" );
        require(!pausenetwork[_networkId] && goToPublic[_networkId], "not ready or paused by admin");
        require(_networkId <= networkIdCount && _networkId > 0, "invalid network id" );
        require(_planIndex < etherInPlans[_networkId][true].length && _planIndex > 0, "invalid planIndex");
        require(checkUserId(_networkId,0,true,tx.origin,_userId ),"_userId not matching to sender");
        require(_planIndex  == userInfos[_networkId][0][true][_userId].lastBoughtLevel ,"pls buy previous plan first");
        address _coinAddress = coinAddress[_networkId];
        etherInPlan memory temp;
        temp = etherInPlans[_networkId][true][_planIndex];
        if(_coinAddress != address(0)) 
        {
            require(checkAmount(amount,temp.buyPrice, _coinAddress), "Invalid amount sent");
            require(doTransaction(_networkId, tx.origin, address(this),amount,0,true,0), "amount tx fail");  
        }
        else
        {
            require(msg.value == temp.buyPrice, "Ivalid ether sent");
            amount = msg.value;
        }    
        require(_buyPlan(_networkId,_planIndex,_userId, 0, 0,temp, amount, true), "buy level fail");
        return true;
    }


    function _buyPlan(uint256 _networkId,uint256 _planIndex,uint256 _baseUserId, uint256 _referrerId, uint256 _parentId, etherInPlan memory _temp, uint256 _paidAmount, bool mainTree) internal returns(bool) // val1=userId, val2 = parentId
    {  

        uint256 _subUserId;
        if( _temp.maxChild > 0) // If tree need to create for the given level
        {
            if(!_temp.allowJoinAgain ) require(userIndex[_networkId][_planIndex][mainTree][tx.origin].length == 0, "user already joined");
           
            if(_temp.autoPlaceInTree)
            { 
                _parentId = etherInPlans[_networkId][mainTree][_planIndex].nextBlankSlot;
                if(userInfos[_networkId][_planIndex][mainTree].length > _parentId)
                {              
                    if(userInfos[_networkId][_planIndex][mainTree][_parentId].childCount == _temp.maxChild) 
                    {
                        etherInPlans[_networkId][mainTree][_planIndex].nextBlankSlot++;
                        _parentId++;
                    }
                }
                _referrerId = _parentId;
            }
            else if(userInfos[_networkId][_planIndex][mainTree].length > 0)
            {
                if(_parentId == 0 )
                {
                    _parentId = findBlankSlot(_networkId,0,_referrerId,mainTree, _temp.maxChild); 
                }
                else
                {
                    require(userInfos[_networkId][_planIndex][mainTree][_parentId].childCount < _temp.maxChild,"Invalid _parent Id");
                }
            }
            _subUserId = processTree(_networkId,_planIndex,_baseUserId,_referrerId,_parentId,mainTree, _paidAmount);
            if(_planIndex == 0 ) _baseUserId = _subUserId;      
        }

        if(mainTree)
        {
            userInfos[_networkId][0][true][_baseUserId].lastBoughtLevel = _planIndex + 1;
            require(payPlatformCharge(_networkId, _paidAmount), "fail deducting platform charge");
            _paidAmount = _paidAmount - (_paidAmount * platformCharge[_networkId] / 100000000);
            if(_temp.maxChild == 0) emit buyLevelEv(now,_networkId,_planIndex,0,_baseUserId,_subUserId,_parentId,_paidAmount, true);
        }
        payInput memory payIn;
        payIn._networkId = _networkId;
        payIn._planIndex = _planIndex;
        payIn._userId = _baseUserId;
        payIn._subUserId = _subUserId;
        payIn._paidAmount = _paidAmount;
        payIn.mainTree = mainTree;
        require(processPayOut(payIn),"payout failed");
        emit processPayOutEv(_networkId,_planIndex,_subUserId,_paidAmount,mainTree);

        etherInPlan memory _temp2;
        if(mainTree)
        {
            for(uint256 i=0;i<_temp.triggerSubTree.length;i++)
            {
                if(_temp.triggerSubTree[i])
                {
                    _temp2 = etherInPlans[_networkId][false][i];
                    require(_buyPlan(_networkId,i,_baseUserId, 0, 0,_temp2, _paidAmount, false),"sub tree fail");
                }
            }
        } 

        if(_temp.triggerExternalContract) externalInterface(externalContract[_networkId]).processExternalMain(_networkId,_planIndex,_baseUserId,_subUserId, _referrerId,_paidAmount,mainTree);
        return true;
    }

    function processTree(uint256 _networkId,uint256 _planIndex,uint256 _baseUserId, uint256 _referrerId, uint256 _parentId, bool mainTree,uint amount) internal returns(uint256)
    {

        userInfo memory temp;
        temp.user = tx.origin;
        uint256 thisId = uint256(userInfos[_networkId][_planIndex][mainTree].length);
        if(_planIndex == 0 ) _baseUserId = thisId;    
        temp.parentId = _parentId;
        temp.referrerId = _referrerId;
        uint256 expiry = now + etherInPlans[_networkId][mainTree][_planIndex].planExpiry;
        if(thisId == 0 ) expiry = 6745990791;
        temp.baseUserId = _baseUserId;
        temp.levelExpiry = uint128(expiry);
        userInfos[_networkId][_planIndex][mainTree].push(temp);
        if(mainTree && _planIndex == 0) emit regUserEv(now, _networkId,0,tx.origin,thisId,_referrerId,_parentId,amount);      
        userInfos[_networkId][_planIndex][mainTree][_parentId].childIds.push(thisId);
        if(thisId > 0 )
        {
            userInfos[_networkId][_planIndex][mainTree][_parentId].childCount++;
            userInfos[_networkId][_planIndex][mainTree][_referrerId].referralCount++;
        }
        userIndex[_networkId][_planIndex][mainTree][tx.origin].push(thisId);
        emit buyLevelEv(now,_networkId,_planIndex,_planIndex,_baseUserId,thisId,_parentId,amount, mainTree);
        subUserId[_networkId][_planIndex][mainTree][_baseUserId] = thisId;
        return thisId;   
    }

    event processPayOutEv(uint256 indexed _networkId,uint256 indexed _planIndex,uint256 _userId, uint256 _paidAmount,bool indexed mainTree);
    event depositedToPoolEv(uint256 timeNow, uint256 indexed _networkId,uint256 indexed _planIndex,uint256 Amount,uint256 poolIndex,bool indexed mainTree);
 
    function processPayOut(payInput memory payIn) internal returns (bool)
    {

        etherOutPlan memory temp;
        temp = etherOutPlans[payIn._networkId][etherInPlans[payIn._networkId][payIn.mainTree][payIn._planIndex].etheroutPlanId];
        uint256 _userId2 = payIn._userId;
        uint256 _userId1 = payIn._subUserId;
        address payable thisUser;
        uint256 thisAmount;
        uint256 _pi;
        if( etherInPlans[payIn._networkId][payIn.mainTree][payIn._planIndex].maxChild > 0)
        {
            _pi = payIn._planIndex;
        }

        uint j;

        for(uint256 k=0; k < temp.payoutType.length; k++)
        {
            thisAmount = payIn._paidAmount * temp.payoutPercentage[k] / 100000000;
            if(thisAmount>0)
            {
                if(temp.payoutType[k] == 0)
                {
                    for(j=0;j<temp.payoutTo[k];j++)
                    {
                        _userId1 = userInfos[payIn._networkId][_pi][payIn.mainTree][_userId1].parentId; // here _userId is reflecting parent
                    }
                    thisUser = userInfos[payIn._networkId][_pi][payIn.mainTree][_userId1].user;
                }
                else if(temp.payoutType[k] == 1)
                {
                    for(j=0;j<temp.payoutTo[k];j++)
                    {
                        _userId2 = userInfos[payIn._networkId][0][payIn.mainTree][_userId2].referrerId; //here _userid is reflecting referrer id
                    }
                    thisUser = userInfos[payIn._networkId][0][payIn.mainTree][_userId2].user;
                }
                else if(temp.payoutType[k] == 2)
                {
                    j = temp.payoutTo[k];
                    if ( temp.payoutTo[k] >= userInfos[payIn._networkId][_pi][payIn.mainTree].length ) j = 0;
                    thisUser = userInfos[payIn._networkId][_pi][payIn.mainTree][j].user;
                }
                else if(temp.payoutType[k] == 3)
                {
                    j = 0;
                    if (payIn._subUserId >= temp.payoutTo[k] ) j = payIn._subUserId - temp.payoutTo[k];
                    thisUser = userInfos[payIn._networkId][_pi][payIn.mainTree][j].user;
                }
                else if(temp.payoutType[k] == 4)
                {
                    poolAmount[payIn._networkId][temp.payoutTo[k]] = poolAmount[payIn._networkId][temp.payoutTo[k]] + thisAmount;      
                    emit depositedToPoolEv(now,payIn._networkId,payIn._planIndex,thisAmount,temp.payoutTo[k], payIn.mainTree);
                }
                if(temp.payoutType[k] < 4) require(stackTooDeepB(payIn,thisUser,thisAmount), "amount tx fail");
            }             
        }
        return true;
    }


   function stackTooDeepB(payInput memory payIn, address payable thisUser,uint256 thisAmount) internal returns(bool)
    { 

        require(doTransaction(payIn._networkId, address(0), thisUser,thisAmount,payIn._planIndex,payIn.mainTree,payIn._userId), "amount tx fail");
        return true;    
    }

    event doPayEv(uint256 indexed _networkId,uint256 indexed _poolIndex, uint256 _amount,address payable _user);


    function doPay(uint256 _networkId,uint256 _poolIndex, uint256 _amount, address payable _user) external returns(bool)
    {

        require(msg.sender == externalContract[_networkId], "Invalid caller" );
        require(_amount <= poolAmount[_networkId][_poolIndex],"not enough amount");
        poolAmount[_networkId][_poolIndex] = poolAmount[_networkId][_poolIndex] - _amount;
        address _coinAddress = coinAddress[_networkId];
        if(_coinAddress == address(0))
        {
            _user.transfer(_amount);
        }
        else
        {
            require( stableCoin(_coinAddress).transfer(_user, _amount),"transfer to user fail");
        }
        emit doPayEv(_networkId,_poolIndex,_amount,_user);
        return true;
    }  

    event addToPoolEv(uint256 _networkId,uint256 _poolIndex, uint256 _amount);
    function addToPool(uint256 _networkId,uint256 _poolIndex, uint256 _amount) external returns(bool)
    {

        poolAmount[_networkId][_poolIndex] = poolAmount[_networkId][_poolIndex] + _amount;
        emit addToPoolEv(_networkId,_poolIndex,_amount);
        return true;
    }  

    event payPlatformChargeEv(uint timeNow, uint256 indexed _networkId, uint256 indexed Amount);
    function payPlatformCharge(uint256 _networkId, uint256 _paidAmount) internal returns(bool)
    {

        uint256 amount = _paidAmount * platformCharge[_networkId] / 100000000; 
        require(doTransaction(_networkId, address(0), owner,amount,0,false,0), "amount tx fail");
        emit payPlatformChargeEv(now,_networkId,amount);
        return true;
    }

    function regUserViaContract(uint256 _networkId,uint256 _referrerId,uint256 _parentId, uint256 amount) public returns(bool)
    {

        require(msg.sender == externalContract[_networkId], "Invalid caller" );
        require(regUser(_networkId,_referrerId,_parentId, amount),"reg user fail");
        return true;
    }

    function buyLevelViaContract(uint256 _networkId,uint256 _planIndex, uint256 _userId, uint256 amount) public returns(bool)
    {

        require(msg.sender == externalContract[_networkId], "Invalid caller" );
        require(buyLevel(_networkId,_planIndex,_userId, amount),"reg user fail");
        return true;
    }


    function findBlankSlot(uint256 _networkId,uint256 _planIndex,uint256 _referrerId,bool mainTree, uint256 _maxChild) public view returns(uint256)
    {

        if(userInfos[_networkId][_planIndex][mainTree][_referrerId].childCount < _maxChild) return _referrerId;

        uint256[] memory referrals = new uint256[](126);
        uint j;
        for(j=0;j<_maxChild;j++)
        {
            referrals[j] = userInfos[_networkId][_planIndex][mainTree][_referrerId].childIds[j];
        }


        uint256 blankSlotId;
        bool noBlankSlot = true;

        for(uint i = 0; i < 126; i++) 
        {
            if(userInfos[_networkId][_planIndex][mainTree][referrals[i]].childCount >= _maxChild)
            {
                if(j < 126 - _maxChild) 
                {
                    referrals[j] = userInfos[_networkId][_planIndex][mainTree][referrals[i]].childIds[0]; 
                    j++;
                    referrals[j] = userInfos[_networkId][_planIndex][mainTree][referrals[i]].childIds[1]; 
                    j++;
                    referrals[j] = userInfos[_networkId][_planIndex][mainTree][referrals[i]].childIds[2]; 
                    j++;                                                           
                }
            }
            else 
            {
                noBlankSlot = false;
                blankSlotId = referrals[i];
                break;
            }
        }

        require(!noBlankSlot, 'No Free Referrer');

        return blankSlotId;
    }


    function payoutPercentageSum(uint256 _networkId, uint256 etherOutPlanIndex) public view returns(uint256)
    {

        uint256 i;
        uint256[] memory _payoutPercentage = etherOutPlans[_networkId][etherOutPlanIndex].payoutPercentage;
        uint256 totalPercentSum;
        for(i=0; i< _payoutPercentage.length; i++)
        {
                totalPercentSum += _payoutPercentage[i];
        }
        return totalPercentSum;        
    }

    function checkUserId(uint256 _networkId, uint256 _planIndex, bool mainTree, address payable _user, uint256 _userId ) public view returns (bool)
    {

        for(uint256 i; i< userIndex[_networkId][_planIndex][mainTree][_user].length;i++)
        {
            if(userIndex[_networkId][_planIndex][mainTree][_user][i] == _userId) return true;
        }
        return false;
    }


    function setNetworkPrice(uint256 _networkPrice) public onlyOwner returns (bool)
    {

        networkPrice = _networkPrice;
        return true;
    }

    function setMinPlanPrice(uint256 _minPlanPrice) public onlyOwner returns (bool)
    {

        minPlanPrice = _minPlanPrice;
        return true;
    }

    function setPlatFormFeePercentage(uint256 _platFormFeePercentage) public onlyOwner returns (bool)
    {

        platFormFeePercentage = _platFormFeePercentage;
        return true;
    } 

    function setValidStableCoin(address _coinAddress, uint256 _etherValue) public onlyOwner returns(bool)
    {

        validStableCoin[_coinAddress] = _etherValue;
        return true;
    }        

    function limitNetwork(uint256 _networkCount) public onlyOwner returns(bool)
    {

        limitNetworkCount = _networkCount;
        return true;
    }

}