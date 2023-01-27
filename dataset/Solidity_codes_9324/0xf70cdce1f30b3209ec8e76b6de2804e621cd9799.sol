





pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}



pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

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






pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;





interface IOracle{

    function getPrice() external view returns(uint256);

}


contract Staketoken is Context,Ownable{

    using SafeMath for uint256;
    

    
    struct StakeType1{
        uint256 dividentStart;
        uint256 claimedDividents;
    }
    struct StakeType2{
        uint256 dividentStart;
        uint256 claimedDividents;
        bytes32 referredStake;
    }
    struct StakeType3{
        uint256 dividentStart;
        uint256 claimedDividents;
        bytes32 referredStake;
    }
    struct TimeLock{
        uint256 amount;
        uint256 unlockTime;
    }
    struct StakeMeta{
        address initiator;
        uint256 nonce;
        uint256 timestamp;
        uint256 amount;
        bool referral;
        bool extention;
        bool expired;
    }
    struct ReferralTree{
        address r1;
        address r2;
        address r3;
        address r4;
        address r5;
        address r6;
        address r7;
        address r8;
        address r9;
        address r10;
    }
    
    
    
    
    
    
    
    mapping (bytes32 => StakeMeta) private _stakeHub;
    mapping (bytes32 => StakeType1) private _stake1;
    mapping (bytes32 => StakeType2) private _stake2;
    mapping (bytes32 => StakeType3) private _stake3;
    mapping (bytes32 => TimeLock) private _timeLock;
    mapping (address => uint256) private _nonce;
    mapping (bytes32 => uint256) private _claimedRewards;
    
    
    
    mapping (address => uint256) private EWallet;
    mapping (address => bool) private registered;
    mapping (address => uint256) private _stakeAmount;
    mapping (address => uint256) private _RstakeAmount;
    
    
    mapping (uint256 => uint256) private _dividents;
    mapping (address => bool) private _registered;
    mapping (address => ReferralTree) private _referrals;
    mapping (address => uint256) private _directCount;
    mapping (address => uint256) private _registerTime;
    mapping (address => bool) private _cashback;
    
    
    
    uint256 private Supply;
    address private ROTHS;
    address private admin;
    address private oracle;
    uint256 public lastDivident;
    uint256 private _totalStaked;
    
    function getSupply() public view returns (uint256){

        return Supply;
    }
    function getClaimedRewards(bytes32 stakeid) public view returns (uint256){

        return _claimedRewards[stakeid];
    }
    
    function getStaked() public view returns (uint256) {

        return _totalStaked;
    }
    
     constructor(address token) {
        ROTHS = token;
        Supply = 895 * 1e5 * 1e18;
        admin = msg.sender;
        lastDivident = getDividentId();
    }
    
    
    modifier isRegistered{

        require(getRegistered(_msgSender()), "User not Registered.");
        _updateDivident();
        _;
    }
    
    
    function min(uint256 a,
        uint256 b) internal pure returns (uint256 minN) {

        if (a <= b) minN = a;
        if (b < a) minN = b;
    }
    
    
    function getDividents(uint256 dividentId) public view returns (uint256) {

        require(_dividents[dividentId] != 0, "Divident Id does not exist.");
        return _dividents[dividentId];
    }
    function _updateDivident() public virtual {

        while (getDividentId() > lastDivident) {
            lastDivident++;
            _dividents[lastDivident] = _dividents[lastDivident - 1] + IOracle(oracle).getPrice() * 5 / 1e3;
        }
    }
    function getDividentId() internal view returns(uint256){

        return block.timestamp/60/60/24;
    }
    
    
   
    
    function setOracle(address _oracle) public onlyOwner {

        oracle=_oracle;
    }
    
    
    
    function register(address refree) public virtual {

        register();
        _setRefree(_msgSender(),refree);
    }
    function register() public virtual {

        require(_registered[_msgSender()] == false, "User already registered.");
        IERC20(ROTHS).transferFrom(_msgSender(),admin,getTokens(25*1e18));
        _registerTime[_msgSender()]=block.timestamp;
        _register(_msgSender());
    }
    function getRegistered(address user) public view virtual returns(bool){

        return _registered[user];
    }
    function _register(address user) internal virtual {

        _registered[user]=true;
    }
    
    function getrefree (address user) public view returns(address) {
        return _referrals[user].r1;
        
    }
    function _setRefree(address user,
        address refree) internal virtual {

        _directCount[refree]++;
        _referrals[user].r1=refree;
        _referrals[user].r2=_referrals[refree].r1;
        _referrals[user].r3=_referrals[refree].r2;
        _referrals[user].r4=_referrals[refree].r3;
        _referrals[user].r5=_referrals[refree].r4;
        _referrals[user].r6=_referrals[refree].r5;
        _referrals[user].r7=_referrals[refree].r6;
        _referrals[user].r8=_referrals[refree].r7;
        _referrals[user].r9=_referrals[refree].r8;
        _referrals[user].r10=_referrals[refree].r9;
        if (_directCount[refree]==2){
            createStake(refree, getTokens(50*1e18), false, true);
        }
        if (_directCount[refree] >= 5 && block.timestamp-_registerTime[refree] <= 7 days && _cashback[refree] == false){
            uint256 tokens=getTokens(25*1e18);
            transferToEWallet(refree,tokens);
            _cashback[refree]=true;
        }
    }
    
    
    
    
    
    function getTokens(uint256 usdIn) internal view virtual returns (uint256 amount) {

        amount= IOracle(oracle).getPrice() * usdIn / 1e18;
    }
    function getEWalletBalance(address user) public view returns(uint256){

        return EWallet[user];
    }
    function getStakeAmount(address user) public view returns(uint256){

        return _stakeAmount[user];
    }
    function getRStakeAmount(address user) public view returns(uint256){

        return _RstakeAmount[user];
    }
    function getDirectCount(address user) public view returns(uint256){

        return _directCount[user];
    }
    function getRegisterTime(address user) public view returns(uint256){

        return _registerTime[user];
    }
    function getNonce(address user) public view virtual returns (uint256) {

        return _nonce[user]+1;
    }
    function isStakeActive(bytes32 stakeid) public view returns(bool) {

        return !_stakeHub[stakeid].expired;
    }
    
    function getStakeMeta(bytes32 stakeid) public view returns(address initiator,
        uint256 nonce,
        uint256 timestamp,
        uint256 amount,
        bool referral,
        bool extention,
        bool expired) {

            initiator = _stakeHub[stakeid].initiator;
            nonce = _stakeHub[stakeid].nonce;
            timestamp = _stakeHub[stakeid].timestamp;
            amount = _stakeHub[stakeid].amount;
            referral = _stakeHub[stakeid].referral;
            extention = _stakeHub[stakeid].extention;
            expired = _stakeHub[stakeid].expired;
                 
    }
    function getStakeT1(bytes32 stakeid) public view returns(uint256 dividentStart,
        uint256 claimedDividents) {

            dividentStart = _stake1[stakeid].dividentStart;
            claimedDividents = _stake1[stakeid].claimedDividents;
    }
    function getStakeT2(bytes32 stakeid) public view returns(uint256 dividentStart,
        uint256 claimedDividents,
        bytes32 referredStake) {

            dividentStart = _stake2[stakeid].dividentStart;
            claimedDividents = _stake2[stakeid].claimedDividents;
            referredStake = _stake2[stakeid].referredStake;
    }
    function getStakeT3(bytes32 stakeid) public view returns(uint256 dividentStart,
        uint256 claimedDividents,
        bytes32 referredStake) {

            dividentStart = _stake3[stakeid].dividentStart;
            claimedDividents = _stake3[stakeid].claimedDividents;
            referredStake = _stake3[stakeid].referredStake;
    }
    function getTimeLock(bytes32 stakeid) public view returns (uint256 amount, uint256 unlockTime) {

        amount = _timeLock[stakeid].amount;
        unlockTime = _timeLock[stakeid].unlockTime;
    }
    
    
    
    
    function transferToEWallet(address user,
        uint256 amount) internal {

        Supply = Supply.sub(amount);
        EWallet[user] = EWallet[user].add(amount);
    }
    
    function createStake(address user,
        uint256 amount,
        bool referral,
        bool extention) internal virtual returns (bytes32 stakeid) {

        stakeid = createStake(user, amount, referral, extention, bytes32(0));
    }
    function createStake(address user,
        uint256 amount,
        bool referral,
        bool extention,
        bytes32 referredstakeid) internal virtual returns (bytes32 stakeid) {

        stakeid=_createStakeMeta(user, amount, referral, extention);
        if (referral == false && extention == false) {
            _createTimeStake(stakeid, amount, block.timestamp + 300 days);
            _createStakeT1(stakeid);
        } else if (referral == false && extention == true) {
            _createTimeStake(stakeid, amount, block.timestamp + 100 days);
        } else if (referral == true && extention == false) {
            _createStakeT2(stakeid, referredstakeid);
        } else {
            _createTimeStake(stakeid, amount, block.timestamp + 300 days);
            _createStakeT3(stakeid, referredstakeid);
        }
        
    }
    
    function calcStakeHash(address user, uint256 nonce) public pure returns(bytes32){

        return keccak256(abi.encodePacked(user,nonce));
    }
    
    
    function _createStakeMeta(address user,
        uint256 amount,
         bool referral,
        bool extention) internal virtual returns (bytes32 stakeid){

        uint256 nonce = getNonce(user);
        stakeid= keccak256(abi.encodePacked(user,nonce));
        _stakeHub[stakeid].initiator = user;
        _stakeHub[stakeid].amount = amount;
        _stakeHub[stakeid].nonce = nonce;
        _stakeHub[stakeid].timestamp = block.timestamp;
        _stakeHub[stakeid].referral=referral;
        _stakeHub[stakeid].extention=extention;
        _nonce[user]++;
    }
    function _createTimeStake(bytes32 stakeid,
        uint256 amount,
        uint256 UnlockTime) internal virtual {

        _timeLock[stakeid].unlockTime = UnlockTime;
        _timeLock[stakeid].amount = amount;
    }
    function _createStakeT1(bytes32 stakeid) internal virtual {

        _stake1[stakeid].dividentStart = getDividentId();
        _stake1[stakeid].claimedDividents = getDividentId();
        
    }
    function _createStakeT2(bytes32 stakeid,
        bytes32 referredstakeid) internal virtual {

        _stake2[stakeid].dividentStart = getDividentId();
        _stake2[stakeid].claimedDividents = getDividentId();
        _stake2[stakeid].referredStake = referredstakeid;
    }
    function _createStakeT3(bytes32 stakeid,
        bytes32 referredstakeid) internal virtual {

        _stake3[stakeid].dividentStart = getDividentId();
        _stake3[stakeid].claimedDividents = getDividentId();
        _stake3[stakeid].referredStake = referredstakeid;
    }
    function _createReferralStakes(address refree,
        uint256 direct,
        uint256 kickback,
        uint256 amount,
        bytes32 referredstakeid) internal virtual {

        if (_stakeAmount[refree]>=_stakeAmount[_msgSender()] && _directCount[refree] >= direct){
            createStake(refree, amount * kickback / 100, true, false, referredstakeid);
            _RstakeAmount[refree]=_RstakeAmount[refree]+(amount * kickback / 100);
        }
    }
    
    function claimStake(bytes32 stakeid) internal virtual {

        require(_stakeHub[stakeid].expired == false, "Stake has expired.");
        bool referral = _stakeHub[stakeid].referral;
        bool extention = _stakeHub[stakeid].extention;
        if (referral == false && extention == false) {
            _claimStakeT1(stakeid);
            _claimTimeStake(stakeid);
        } else if (referral == false && extention == true) {
            _claimTimeStake(stakeid);
        } else if (referral == true && extention == false) {
            _claimStakeT2(stakeid);
        } else {
            _claimStakeT3(stakeid);
            _claimTimeStake(stakeid);
        }
    }
    function _claimTimeStake(bytes32 stakeid) internal virtual {

        if (_timeLock[stakeid].unlockTime <= block.timestamp){
            transferToEWallet(_stakeHub[stakeid].initiator, _timeLock[stakeid].amount);
            bool referral = _stakeHub[stakeid].referral;
            bool extention = _stakeHub[stakeid].extention;
            if (!(referral == false && extention == true)) {
                _stakeAmount[_msgSender()] = _stakeAmount[_msgSender()] - _stakeHub[stakeid].amount;
                _totalStaked = _totalStaked.sub(_stakeHub[stakeid].amount);
            }
            _stakeHub[stakeid].expired=true;
            
        }
        
    }
    function _claimStakeT1(bytes32 stakeid) internal virtual {

        uint256 payableDividents= min(getDividentId(), _stake1[stakeid].dividentStart+300);
        uint256 tokens = (_dividents[payableDividents].sub(_dividents[_stake1[stakeid].claimedDividents])) * _stakeHub[stakeid].amount /1e18;
        _stake1[stakeid].claimedDividents = payableDividents;
        transferToEWallet(_stakeHub[stakeid].initiator, tokens);
        _claimedRewards[stakeid] = _claimedRewards[stakeid].add(tokens);
    }
    function _claimStakeT2(bytes32 stakeid) internal virtual {

        uint256 payableDividents= min(getDividentId(), _stake2[stakeid].dividentStart+300);
        if (payableDividents == _stake2[stakeid].dividentStart+300){
            _stakeHub[stakeid].expired=true;
            _RstakeAmount[_stakeHub[stakeid].initiator] = _RstakeAmount[_stakeHub[stakeid].initiator] - _stakeHub[stakeid].amount; 
        }
        uint256 tokens = (_dividents[payableDividents].sub(_dividents[_stake2[stakeid].claimedDividents])) * _stakeHub[stakeid].amount /1e18;
        _stake2[stakeid].claimedDividents = payableDividents;
        transferToEWallet(_stakeHub[stakeid].initiator, tokens);
        _claimedRewards[stakeid] = _claimedRewards[stakeid].add(tokens);
    }
    function _claimStakeT3(bytes32 stakeid) internal virtual {

        uint256 payableDividents= min(getDividentId(), _stake3[stakeid].dividentStart+300);
        uint256 tokens = (_dividents[payableDividents].sub(_dividents[_stake3[stakeid].claimedDividents])) * _stakeHub[stakeid].amount * 2 /1e18;
        _stake3[stakeid].claimedDividents = payableDividents;
        transferToEWallet(_stakeHub[stakeid].initiator, tokens);
        _claimedRewards[stakeid] = _claimedRewards[stakeid].add(tokens);
    }
    
    
    
    function claimableStake(bytes32 stakeid) public view virtual returns (uint256){

        if (_stakeHub[stakeid].expired) {return 0;}
        bool referral = _stakeHub[stakeid].referral;
        bool extention = _stakeHub[stakeid].extention;
        if (referral == false && extention == false) {
           return  _claimableStakeT1(stakeid);
            
        } else if (referral == true && extention == false) {
         return _claimableStakeT2(stakeid);
        } else if (referral == true && extention == true) {
           return _claimableStakeT3(stakeid);
        } else {
            return 0;
        }
    }
    
    function _claimableStakeT1(bytes32 stakeid) internal view virtual returns (uint256 tokens){

        uint256 payableDividents= min(getDividentId(), _stake1[stakeid].dividentStart+300);
        tokens = (_dividents[payableDividents].sub(_dividents[_stake1[stakeid].claimedDividents])) * _stakeHub[stakeid].amount /1e18;
        
    }
    function _claimableStakeT2(bytes32 stakeid) internal view virtual  returns (uint256 tokens) {

        uint256 payableDividents= min(getDividentId(), _stake2[stakeid].dividentStart+300);
       tokens = (_dividents[payableDividents].sub(_dividents[_stake2[stakeid].claimedDividents])) * _stakeHub[stakeid].amount /1e18;
    }
    function _claimableStakeT3(bytes32 stakeid) internal view virtual returns (uint256 tokens) {

        uint256 payableDividents= min(getDividentId(), _stake3[stakeid].dividentStart+300);
        tokens = (_dividents[payableDividents].sub(_dividents[_stake3[stakeid].claimedDividents])) * _stakeHub[stakeid].amount * 2 /1e18;
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    function stake(uint256 amount,
        bytes32 referredstakeid) public isRegistered {

        require(_msgSender() == _stakeHub[referredstakeid].initiator, "Referred StakeId should belong to you.");
        require(amount >= _stakeHub[referredstakeid].amount, "New stake amount should be higher or euqal to referred stake.");
        require((_stakeHub[referredstakeid].referral==false && _stakeHub[referredstakeid].extention == false), "Referred Stake Id invalid.");
        _claimStakeT1(referredstakeid);
        _stakeHub[referredstakeid].expired=true;
        createStake(_msgSender(), _stakeHub[referredstakeid].amount, true, true, referredstakeid);
        stake(amount);
    }
    function stake(uint256 amount) public isRegistered {

        IERC20(ROTHS).transferFrom(_msgSender(), address(this), amount);
        bytes32 stakeid = createStake(_msgSender(), amount, false, false);
        _stakeAmount[_msgSender()] = _stakeAmount[_msgSender()] + amount;
        _totalStaked = _totalStaked.add(amount);
        address r1= _referrals[_msgSender()].r1;
        address r2= _referrals[_msgSender()].r2;
        address r3= _referrals[_msgSender()].r3;
        address r4= _referrals[_msgSender()].r4;
        address r5= _referrals[_msgSender()].r5;
        address r6= _referrals[_msgSender()].r6;
        address r7= _referrals[_msgSender()].r7;
        address r8= _referrals[_msgSender()].r8;
        address r9= _referrals[_msgSender()].r9;
        address r10= _referrals[_msgSender()].r10;
        
        _createReferralStakes(r1,2,20, amount, stakeid);
        _createReferralStakes(r2,4,10, amount, stakeid);
        _createReferralStakes(r3,6,5, amount, stakeid);
        _createReferralStakes(r4,8,5, amount, stakeid);
        _createReferralStakes(r5,10,4, amount, stakeid);
        _createReferralStakes(r6,12,4, amount, stakeid);
        _createReferralStakes(r7,14,3, amount, stakeid);
        _createReferralStakes(r8,16,3, amount, stakeid);
        _createReferralStakes(r9,18,2, amount, stakeid);
        _createReferralStakes(r10,20,2, amount, stakeid);
        
    }
    
    
    
    
    
    function claim(bytes32 stakeid) public isRegistered {

        require(isStakeActive(stakeid), "Stake already finished.");
        require(_stakeHub[stakeid].initiator == _msgSender(), "Stake does not belong to user.");
        claimStake(stakeid);
        
    }
    
    
    
    
    function withdraw(uint256 amount) public isRegistered {

        require(amount <= EWallet[_msgSender()], "Not enough balance.");
        EWallet[_msgSender()] = EWallet[_msgSender()].sub(amount); 
        IERC20(ROTHS).transfer(_msgSender(),amount);
    }
    
    
    
    
    
    
    
}