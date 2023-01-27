
pragma solidity >=0.4.23 <0.6.0;

contract CC9{

    
    uint public entryAmount;
    uint public level3Prices;
    uint public payout3Price;
    uint public compTransfer;
    uint public votingpoolAmount = 0;
    
    address ownerAddress=0x7cf28a64934C1BF9A9680AE4576CdF732b3dc296; //
    
    address TokenContract=0x884322742bF47CA4B9fCB228E2E234595Be9ba18;
    address SlotContract=0x5cB4c65c8Cd4787109E6891B526D121a9A8A3144;
    address CompanyMatrixContract=0x3B0DF5305d416fBb091E939550036D103C563a13;
    address TwoLevelMatrix=0x22D109fE80CcedC7AE87aD539D80c8c784eC6D3A;
    
    Callee1 c = Callee1(TokenContract); // Token Contract
    Callee2 d = Callee2(SlotContract); // Slot Contract
    Callee3 e = Callee3(CompanyMatrixContract); // companyMatrix
    Callee4 f = Callee4(TwoLevelMatrix);
    uint8 public rentryID=0;
    uint8 public currentUserId = 0;
    mapping(address => uint) public TotalEarning;
    
    struct UserStruct {
        bool isExist;
        address referrer;
        uint balances;
        uint xbalances;
        bytes32 username;
        mapping(uint8 => bool) activeX39Levels;
        mapping(uint8 => X39) x39Matrix;
        mapping(uint8 => bool) activeX100Levels;
        mapping(uint => X100) x100Matrix;
    }
    struct X39 {
        address currentReferrer;
        address[] directReferrerals;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        address[] thirdLevelReferrals;
        uint8 reEntryCount;
        bool reEntry;
    }
    struct X100{
        address currentReferrer;
        address[] firstLevelReferrals;
        address[] secondLevelReferrals;
        uint8 reEntryCount;
        bool reEntry;
        bool upgrade;
        bool upgraded;
    }
    mapping(address => address) public currentReferrerfor100;
    mapping (address => UserStruct) public users;
    mapping(bytes32 => bool) public nameExist;
    mapping(bytes32 => address) public nameToAddress;
    
    
    function setEntryPrice(uint8 entryprice ,uint8 distribution,uint8 payoutOutPrice , uint8 companytransfer) public{

            require(msg.sender==ownerAddress);
            entryAmount=entryprice;
            level3Prices=distribution;
            payout3Price=payoutOutPrice; // RENTRY PRICE
            compTransfer=companytransfer;
    }
    
    constructor() public{
        entryAmount=1875;
        level3Prices=375;
        payout3Price=1875; // RENTRY PRICE
        compTransfer=500;
        
        UserStruct memory user=UserStruct({
            isExist:true,
            referrer:address(0),
            balances:0,
            xbalances:0,
            username:'cuckoo'
        });
        nameExist['cuckoo']=true;
        nameToAddress['cuckoo']=ownerAddress;
        
        users[ownerAddress] = user;
        
        users[ownerAddress].activeX39Levels[1] = true;
        users[ownerAddress].x39Matrix[1].reEntryCount=1;
        users[ownerAddress].activeX100Levels[1] = true;
        
     }
    
    function voteResult() public{

        require(msg.sender==ownerAddress);
        votingpoolAmount=0;
    }
    
    
    
    function enter(uint amount,address referrerAddress , bytes32 uname) public{

        require(!nameExist[uname],"UserName Exist");
        require(amount==entryAmount,"Invalid Amount");
        require(!users[msg.sender].isExist,"User Exists");
        require(users[referrerAddress].isExist,"Referrer Doesnot Exists");
        c.transferFrom(msg.sender,address(this),amount*1000000000000000000);
        d.saveUsers(msg.sender,referrerAddress); // Vote Contract
        f.SaveUsers2LevelMAtrix(msg.sender,referrerAddress);//Level2Matrix
        
        UserStruct memory user = UserStruct({
            isExist:true,
            referrer: referrerAddress,
            balances:0,           
            xbalances:0,
            username:uname
        });
        users[msg.sender]=user;
        nameExist[uname]=true;
        nameToAddress[uname]=msg.sender;
        users[msg.sender].activeX39Levels[1] = true;
        users[msg.sender].x39Matrix[1].reEntryCount=1;
        updateX39Referrer(msg.sender,referrerAddress ,1);
        
        users[referrerAddress].x39Matrix[1].directReferrerals.push(msg.sender);
        currentReferrerfor100[msg.sender]=referrerAddress;
        
        votingpoolAmount = votingpoolAmount + entryAmount*8/100;
        users[msg.sender].x39Matrix[1].currentReferrer = referrerAddress;
    }
   
    function updateX39Referrer(address userAddress, address referrerAddress, uint8 level) private {

        require(users[referrerAddress].activeX39Levels[level], "Referrer not active");
        c.transfer(CompanyMatrixContract,compTransfer*1000000000000000000);
        e.updateCompanyMatrix(userAddress,referrerAddress);
        
         
         if (users[referrerAddress].x39Matrix[level].firstLevelReferrals.length < 3){
            users[referrerAddress].x39Matrix[level].firstLevelReferrals.push(userAddress);
            users[referrerAddress].balances=users[referrerAddress].balances+level3Prices;
            if(users[referrerAddress].balances>=payout3Price){
                users[referrerAddress].balances=users[referrerAddress].balances-payout3Price;
                TotalEarning[referrerAddress]=TotalEarning[referrerAddress]+payout3Price;
                if(users[referrerAddress].x39Matrix[1].reEntry)
                    {
                    e.companyMatrix(referrerAddress,referrerAddress);
                    c.transfer(CompanyMatrixContract,compTransfer*1000000000000000000);
                    users[referrerAddress].x39Matrix[1].reEntry=false;
                    users[referrerAddress].x39Matrix[1].reEntryCount=users[referrerAddress].x39Matrix[1].reEntryCount+1;
                    updateX39Referrer(referrerAddress,referrerAddress,level);
                    }
                else{
                    users[referrerAddress].x39Matrix[1].reEntry=true;
                    c.transfer(referrerAddress,payout3Price*1000000000000000000);
                    }
                
            }
            

            if (referrerAddress == ownerAddress) {
                return;
            }
            address ref = users[referrerAddress].x39Matrix[level].currentReferrer;            
            users[ref].x39Matrix[level].secondLevelReferrals.push(userAddress); 
                users[ref].balances=users[ref].balances+level3Prices;
            if(users[ref].balances>=payout3Price){
                users[ref].balances=users[ref].balances-payout3Price;
                TotalEarning[ref]=TotalEarning[ref]+payout3Price;
                if(users[ref].x39Matrix[1].reEntry)
                    {
                    users[ref].x39Matrix[1].reEntry=false;
                    users[ref].x39Matrix[1].reEntryCount=users[ref].x39Matrix[1].reEntryCount+1;
                    e.companyMatrix(ref,ref);
                    c.transfer(CompanyMatrixContract,compTransfer*1000000000000000000);
                    updateX39Referrer(ref,ref,level);
                    }
                else{
                    users[ref].x39Matrix[1].reEntry=true;
                    c.transfer(ref,payout3Price*1000000000000000000);
                    }
            }
            if (ref == ownerAddress) {
                return;
            }
            address refref = users[ref].x39Matrix[level].currentReferrer;
            users[refref].x39Matrix[level].thirdLevelReferrals.push(userAddress);
                users[refref].balances=users[refref].balances+level3Prices;
            if(users[refref].balances>=payout3Price){
                users[refref].balances=users[refref].balances-payout3Price;
                 TotalEarning[refref]=TotalEarning[refref]+payout3Price;
                 if(users[refref].x39Matrix[1].reEntry)
                    {
                    users[refref].x39Matrix[1].reEntryCount=users[refref].x39Matrix[1].reEntryCount+1;
                    users[refref].x39Matrix[1].reEntry=false;
                    e.companyMatrix(refref,refref);
                    c.transfer(CompanyMatrixContract,compTransfer*1000000000000000000);
                    updateX39Referrer(refref,refref,level);
                    }
                else{
                    users[refref].x39Matrix[1].reEntry=true;
                    c.transfer(refref,payout3Price*1000000000000000000);
                }
            }
            if(ref == ownerAddress){
                return;
            }
            
            
            else{
                
            }
         }
         
         else if(users[referrerAddress].x39Matrix[level].secondLevelReferrals.length < 9){
            users[referrerAddress].x39Matrix[level].secondLevelReferrals.push(userAddress);
                users[referrerAddress].balances=users[referrerAddress].balances+level3Prices;
            if(users[referrerAddress].balances>=payout3Price){
                users[referrerAddress].balances=users[referrerAddress].balances-payout3Price;
                    TotalEarning[referrerAddress]=TotalEarning[referrerAddress]+payout3Price;
                if(users[referrerAddress].x39Matrix[1].reEntry)
                    {
                    users[referrerAddress].x39Matrix[1].reEntryCount=users[referrerAddress].x39Matrix[1].reEntryCount+1;
                    users[referrerAddress].x39Matrix[1].reEntry=false;   
                    e.companyMatrix(referrerAddress,referrerAddress);
                    c.transfer(CompanyMatrixContract,compTransfer*1000000000000000000);
                    updateX39Referrer(referrerAddress,referrerAddress,level);
                    }
                else{
                    users[referrerAddress].x39Matrix[1].reEntry=true;
                    c.transfer(referrerAddress,payout3Price*1000000000000000000);
                }
            }
            else{
               
            }
            if (referrerAddress == ownerAddress) {
                return;
            }
            
            
            address ref2 = users[referrerAddress].x39Matrix[level].currentReferrer;
            users[ref2].x39Matrix[level].thirdLevelReferrals.push(userAddress); 
                users[ref2].balances=users[ref2].balances+level3Prices;
            if(users[ref2].balances>=payout3Price){
                users[ref2].balances=users[ref2].balances-payout3Price;
                TotalEarning[ref2]=TotalEarning[ref2]+payout3Price;
                if(users[ref2].x39Matrix[1].reEntry)
                    {
                    users[ref2].x39Matrix[1].reEntryCount=users[ref2].x39Matrix[1].reEntryCount+1;
                    users[ref2].x39Matrix[1].reEntry=false;
                    e.companyMatrix(ref2,ref2);
                    c.transfer(CompanyMatrixContract,compTransfer*1000000000000000000);
                    updateX39Referrer(ref2,ref2,level);
                    }
                else{
                    users[ref2].x39Matrix[1].reEntry=true;
                    c.transfer(ref2,payout3Price*1000000000000000000);
                }
            }
            else{
                
            }
            
         }
         
         else if(users[referrerAddress].x39Matrix[level].thirdLevelReferrals.length < 27){
            users[referrerAddress].x39Matrix[level].thirdLevelReferrals.push(userAddress);
            
                users[referrerAddress].balances=users[referrerAddress].balances+level3Prices;
             if(users[referrerAddress].balances>=payout3Price){
                 users[referrerAddress].balances=users[referrerAddress].balances-payout3Price;
                    TotalEarning[referrerAddress]=TotalEarning[referrerAddress]+payout3Price;
                 if(users[referrerAddress].x39Matrix[1].reEntry)
                    {
                    users[referrerAddress].x39Matrix[1].reEntryCount=users[referrerAddress].x39Matrix[1].reEntryCount+1;
                    users[referrerAddress].x39Matrix[1].reEntry=false;
                    e.companyMatrix(referrerAddress,referrerAddress);
                    c.transfer(CompanyMatrixContract,compTransfer*1000000000000000000);
                    updateX39Referrer(referrerAddress,referrerAddress,level);
                    }
                else{
                    users[referrerAddress].x39Matrix[1].reEntry=true;
                    c.transfer(referrerAddress,payout3Price*1000000000000000000);
                }
            }
            else{
               
            }
         }
         else{
            
             for(uint8 i=2;i<=users[referrerAddress].x39Matrix[1].reEntryCount;i++){
             if(users[referrerAddress].activeX39Levels[i]&&((users[referrerAddress].x39Matrix[i].firstLevelReferrals.length+users[referrerAddress].x39Matrix[i].secondLevelReferrals.length+users[referrerAddress].x39Matrix[i].thirdLevelReferrals.length)<39)){
                 return updateX39Referrer(userAddress,referrerAddress, i);
                }
             }
            users[referrerAddress].x39Matrix[1].reEntryCount= users[referrerAddress].x39Matrix[1].reEntryCount+1;
            uint8 levelnew = users[referrerAddress].x39Matrix[1].reEntryCount;
            users[referrerAddress].activeX39Levels[levelnew] = true;
            
            e.companyMatrix(referrerAddress,referrerAddress);
            c.transfer(CompanyMatrixContract,compTransfer*1000000000000000000);
            
            return updateX39Referrer(userAddress,referrerAddress,levelnew);
         }
         
     }
     
   
    function Drain(uint amount) public{

        require(msg.sender==ownerAddress);
        c.transfer(ownerAddress,amount*1000000000000000000);
    }
    function resetpool() public{

        require(msg.sender==ownerAddress);
        votingpoolAmount=0;
        
    }
    function usersX39Matrix(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory, address[] memory,uint8,bool) {

        return (users[userAddress].x39Matrix[level].currentReferrer,
                users[userAddress].x39Matrix[level].firstLevelReferrals,
                users[userAddress].x39Matrix[level].secondLevelReferrals,
                users[userAddress].x39Matrix[level].thirdLevelReferrals,
                users[userAddress].x39Matrix[level].reEntryCount,
                users[userAddress].x39Matrix[level].reEntry);
    }
    
   
    
    function users2level(address userAddress, uint8 level) public view returns(address, address[] memory, address[] memory,uint8,bool) {

        return (users[userAddress].x100Matrix[level].currentReferrer,
                users[userAddress].x100Matrix[level].firstLevelReferrals,
                users[userAddress].x100Matrix[level].secondLevelReferrals,
                users[userAddress].x100Matrix[level].reEntryCount,
                users[userAddress].x100Matrix[level].reEntry);
    }
    
    function checkName(bytes32 usrname) public view returns(bool){

        return (nameExist[usrname]);
    }
    
    function nametoadd(bytes32 usname) public view returns(address){

        return (nameToAddress[usname]);
    }
  
     
}
contract Callee4{

    function SaveUsers2LevelMAtrix(address useraddress , address referrerAddress)public;

}
contract Callee3{

    function updateCompanyMatrix(address useraddress,address referrerAddress) public;

    function companyMatrix(address userAddress, address referrerAddress) public;

}

contract Callee2{

    function saveUsers(address useraddress,address referrerAddress) public;

}

contract Callee1 {

    function transferFrom(address from, address to, uint value) public;

    function approve(address spender, uint value) public;

    function transfer(address to, uint value) public;

}