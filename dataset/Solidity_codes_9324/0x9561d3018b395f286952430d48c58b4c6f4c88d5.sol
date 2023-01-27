
pragma solidity ^0.5.15;

library SafeMath {

    
    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        
        
        
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    
    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        
        require(b > 0, errorMessage);
        uint256 c = a / b;
        

        return c;
    }

    
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

contract Context {

    
    
    constructor () internal { }
    

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; 
        return msg.data;
    }
}

contract Ownable is Context {

    
    using SafeMath for uint256;
    
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    
    function owner() public view returns (address) {

        return _owner;
    }

    
    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    
    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    
    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    
    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface PZSConfig {

    
    function getStage(uint8 version) external view returns(uint256 minimum,uint256 maximum,uint256 period,uint256 scale,uint256 totalSuply,uint256 startTime,uint256 partnerBecome);

    
    function checkStart(uint8 version) external view returns(bool);

    
    function partnerBecome(uint8 version) external view returns(uint256);

    
    function underway() external view returns(uint8);

    
    function getCommon() external view returns(uint256 withdrawFee,uint256 partnerBecomePercent,uint256 partnerDirectPercent,uint256 partnerReferRewardPercent,uint256[2] memory referRewardPercent);


}

contract PZSSub is Ownable{

    
    using SafeMath for uint256;
    
    using SafeERC20 for IERC20;
    
    IERC20 public pzsImpl;
    
    
    address private ROOT_ADDRESS = address(0x89e7A033E4Ae02E8782D4a4e1c1B27eb068d574e);
    
    address payable private PROJECT_NODE_ADDRESS = address(0x78f3f95b10D91c5D4F6C808D576869f42C2d9F6b);
    
    address payable private PROJECT_LEADER_ADDRESS = address(0x78f3f95b10D91c5D4F6C808D576869f42C2d9F6b);
    
    address payable private PROJECT_FEE_ADDRESS = address(0x78f3f95b10D91c5D4F6C808D576869f42C2d9F6b);
    
    
    constructor(address conf,address pzt) public {
        config = PZSConfig(conf);
        
        registration(ROOT_ADDRESS,address(0),true);
        
        pzsImpl = IERC20(pzt);
    }
    
    function upgrade(address[] calldata addList,address referAddress) external onlyOwner returns(bool){

        for(uint8 i;i<addList.length;i++){
            registration(addList[i],referAddress,true);
        }
    }
    
    function changePZS(address pzsAddress) external onlyOwner returns(bool) {

        pzsImpl = IERC20(pzsAddress);
    }
    
    function changeConfig(address conf) external onlyOwner returns(bool) {

        config = PZSConfig(conf);
    }
    
    struct User {
        
        bool active;
        
        address referrer;
        
        uint256 id;
        
        bool node;
        
        uint256 direcCount;
        
        uint256 indirectCount;
        
        uint256 teamCount;
        
        uint256[3] subAmount;
        
        uint256[3] subAward;
        
        uint256[3] partnerAward;
    }
    
    
    PZSConfig private config;
    
    
    
    uint8 public teamCountLimit = 15;
    
    
    
    mapping(address=>User) public users;
    
    mapping(address=>uint256[3]) awards;
    
    mapping(uint256=>address) public addressIndexs;
    
    
    uint256 public userCounter;
    
    uint256[3] public totalSubEth;
    
    event Registration(address indexed user, address indexed referrer);
    
    event ApplyForPartner(address indexed user,address indexed referrer,address indexed node,uint256 partnerDirectAward,uint256 partnerBecomeAward);
    
    event Subscribe(address indexed user,uint256 changeAmount,uint256 exchangeAmout);
    
    event WithdrawAward(address indexed user,uint256 subAward);
    
    
    
    
    event AllotSubAward(address indexed user,address indexed subAddress,uint256 partnerAward,uint8 awardType);
    
    function isUserExists(address userAddress) private view returns(bool) {

        
        return users[userAddress].active;
    }
    
    function underway() public view returns(uint8 version){

        version = config.underway();
        return version;
    }
    
    function getGlobalStats(uint8 version) public view returns(uint256[9] memory stats){

        (uint256 minimum,uint256 maximum,uint256 period,uint256 scale,uint256 totalSuply,uint256 startTime,uint256 partnerBecome) = config.getStage(version);
        stats[0] = minimum;
        stats[1] = maximum;
        stats[2] = period;
        stats[3] = scale;
        stats[4] = totalSuply;
        stats[5] = startTime;
        stats[6] = partnerBecome;
        stats[7] = totalSubEth[version].mul(scale);
        stats[8] = userCounter;
        return stats;
    }
    
    function getPersonalStats(uint8 version,address userAddress) external view returns (uint256[10] memory stats){

        User memory user = users[userAddress];
        stats[0] = user.id;
        stats[1] = user.node?1:0;
        stats[2] = user.teamCount;
        stats[3] = user.direcCount;
        stats[4] = user.indirectCount;
        stats[5] = user.subAmount[version];
        stats[6] = user.subAward[version];
        stats[7] = user.partnerAward[version];
        stats[8] = awards[userAddress][version];
        stats[9] = user.active?1:0;
    }

    function getNodeAddress(address userAddress) public view returns (address nodeAddress){

        
        while(true){
            if (users[users[userAddress].referrer].node) {
                return users[userAddress].referrer;
            }
            userAddress = users[userAddress].referrer;
            
            if(userAddress==address(0)){
                break;
            }
        }
        
    }
    
    
    
    
    function regist(uint256 id) public  {

        require(!Address.isContract(msg.sender),"not allow");
        require(id>0,"error");
        require(!isUserExists(msg.sender),"exist");
        address referAddress = addressIndexs[id];
        require(isUserExists(referAddress),"ref not regist");

        registration(msg.sender,referAddress,false);
    }
    
    function applyForPartner(uint8 version) public payable returns (bool){

        
        require(isUserExists(msg.sender),"User not registered");
        
        require(config.checkStart(version),"Unsupported type");
        
        require(!users[msg.sender].node,"Has been activated");
        
        require(msg.value==config.partnerBecome(version),"amount error");
        
        address referrerAddress = users[msg.sender].referrer;
        
        address nodeAddress = getNodeAddress(msg.sender);
        
        require(referrerAddress!=address(0),"referrerAddress error 0");
        require(nodeAddress!=address(0),"referrerAddress error 0");
        
        (,uint256 partnerBecomePercent,uint256 partnerDirectPercent,,) =  config.getCommon();
        
        uint256 partnerDirectAward = msg.value.mul(partnerDirectPercent).div(100);
        uint256 partnerBecomeAward = msg.value.mul(partnerBecomePercent).div(100);
        
        
        users[msg.sender].node = true;
        
        awards[referrerAddress][version] = awards[referrerAddress][version].add(partnerDirectAward);
        awards[nodeAddress][version] = awards[nodeAddress][version].add(partnerBecomeAward);

        
        users[referrerAddress].partnerAward[version] = users[referrerAddress].partnerAward[version].add(partnerDirectAward);
        users[nodeAddress].partnerAward[version] = users[nodeAddress].partnerAward[version].add(partnerBecomeAward);
        

        PROJECT_NODE_ADDRESS.transfer(msg.value.sub(partnerDirectAward).sub(partnerBecomeAward));
        
        emit ApplyForPartner(msg.sender,referrerAddress,nodeAddress,partnerDirectAward,partnerBecomeAward);
        
        return true;
    }
     
    function subscribe(uint8 version) public payable returns(bool) {

        
        require(isUserExists(msg.sender),"User not registered");
        
        require(config.checkStart(version),"Unsupported type");
        
        (uint256 minimum,uint256 maximum,,uint256 scale,,,) = config.getStage(version);
        
        require(msg.value>=minimum,"error sub type");
        
        uint256 subVersionAmount = users[msg.sender].subAmount[version];
        
        require(subVersionAmount.add(msg.value)<=maximum,"Exceeding sub limit");
        
        (uint256 subAward1,uint256 subAward2) = allotSubAward(version,msg.sender,msg.value);
        uint256 partnerAward = allotPartnerAward(version,msg.sender,msg.value);
        
        PROJECT_LEADER_ADDRESS.transfer(msg.value.sub(subAward1).sub(subAward2).sub(partnerAward));
        
        totalSubEth[version] = totalSubEth[version].add(msg.value);
        users[msg.sender].subAmount[version] = users[msg.sender].subAmount[version].add(msg.value);
        
        uint256 exchangePZSAmount = msg.value.mul(scale);
        
        pzsImpl.safeTransfer(msg.sender,exchangePZSAmount);
        
        emit Subscribe(msg.sender,msg.value,exchangePZSAmount);
        
        return true;
    }

    
    function withdrawAward(uint8 version) public returns(uint256){

        uint256 subAward = awards[msg.sender][version];
        (uint256 withdrawFee,,,,) =  config.getCommon();
        require(subAward>withdrawFee,"error ");
        require(address(this).balance >= subAward,"not enought");
        awards[msg.sender][version] = 0;
        PROJECT_FEE_ADDRESS.transfer(withdrawFee);
        msg.sender.transfer(subAward.sub(withdrawFee));
        emit WithdrawAward(msg.sender,subAward);
    }
    
    
    function allotPartnerAward(uint8 version,address userAddress,uint256 amount) private returns (uint256 partnerAward){

        address nodeAddress = getNodeAddress(msg.sender);
        
        (,,,uint256 partnerReferRewardPercent,) =  config.getCommon();
        partnerAward = amount.mul(partnerReferRewardPercent).div(100);
        if(nodeAddress==address(0)){
            partnerAward = 0;
        }else{
            awards[nodeAddress][version] = awards[nodeAddress][version].add(partnerAward);
            
        }
        
        users[nodeAddress].subAward[version] = users[nodeAddress].subAward[version].add(partnerAward);
        emit AllotSubAward(userAddress,nodeAddress,partnerAward,3);
        
        return partnerAward;
    }
    
    function allotSubAward(uint8 version,address userAddress,uint256 amount) private returns (uint256 subAward1,uint256 subAward2) {

        address sub1 = users[userAddress].referrer;
        address sub2 = users[sub1].referrer;
        (,,,,uint256[2] memory referRewardPercent) =  config.getCommon();
        subAward1 = amount.mul(referRewardPercent[0]).div(100);
        subAward2 = amount.mul(referRewardPercent[1]).div(100);
        
        if(sub1==address(0)){
            subAward1 = 0;
            subAward2 = 0;
        }else{
            
            if(sub2==address(0)){
                subAward2 = 0;
                awards[sub1][version] = awards[sub1][version].add(subAward1);
            }else{
                awards[sub1][version] = awards[sub1][version].add(subAward1);
                awards[sub2][version] = awards[sub2][version].add(subAward2);
            }
        }
        
        
        users[sub1].subAward[version] = users[sub1].subAward[version].add(subAward1);
        users[sub2].subAward[version] = users[sub2].subAward[version].add(subAward2);
        
        emit AllotSubAward(userAddress,sub1,subAward1,1);
        emit AllotSubAward(userAddress,sub2,subAward2,2);
        return (subAward1,subAward2);
    }
    
    function registration (address userAddress,address referAddress,bool node) private {
        require(!isUserExists(msg.sender),"exist");
        users[userAddress] = createUser(userAddress,referAddress,node);
        users[referAddress].direcCount++;
        users[users[referAddress].referrer].indirectCount++;
        
        teamCount(userAddress);
        
        emit Registration(userAddress,referAddress);
    }
    
    function teamCount(address userAddress) private{

        address ref = users[userAddress].referrer;
        
        for(uint8 i = 0;i<teamCountLimit;i++){
            
            if(ref==address(0)){
                break;
            }
            users[ref].teamCount++;

            ref = users[ref].referrer;
        }
        
    }
    
    function createUser(address userAddress,address referrer,bool node) private returns(User memory user){

        uint256[3] memory subAmount;
        uint256[3] memory subAward;
        uint256[3] memory partnerAward;
        userCounter++;
        addressIndexs[userCounter] = userAddress;
        user = User({
            active: true,
            referrer: referrer,
            id: userCounter,
            node: node,
            direcCount: 0,
            indirectCount: 0,
            teamCount: 1,
            subAmount: subAmount,
            subAward: subAward,
            partnerAward: partnerAward
        });
    }
    
}