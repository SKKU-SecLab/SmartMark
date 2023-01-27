

pragma solidity 0.8.10;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}

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
    
    function ceil(uint a, uint m) internal pure returns (uint r) {

        return (a + m - 1) / m * m;
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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


interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);

    
    function decimals() external view returns (uint8);


   
    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}
library TransferHelper {

    
    function safeTransferFrom(address token, address from, address to, uint value) internal {

        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

}
abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}

abstract contract IRewardDistributionRecipient is Ownable {
    address rewardDistribution;

    modifier onlyRewardDistribution() {
        require(_msgSender() == rewardDistribution, "Caller is not reward distribution");
        _;
    }

    function setRewardDistributionAdmin(address _rewardDistribution)
        internal
    {
        require(rewardDistribution == address(0), "Reward distribution Admin already set");
        rewardDistribution = _rewardDistribution;
    }
    
    function updateRewardDistributionAdmin(address _rewardDistribution) public onlyOwner {
        require(rewardDistribution == address(0), "Reward distribution Admin already set");
        rewardDistribution = _rewardDistribution;
    }
    
}

interface iGoldFarmFaaS {

    function Initialize(address, address, address, uint256, uint256, uint256, address) external; 

    function setFarmRewards(uint256, uint256) external;

    function setFarmRewards1(uint256, uint256) external;

}

interface iGoldFarmFaaSForOne {

    function Initialize(address, address, uint256, uint256, address) external; 

    function setFarmRewards(uint256, uint256) external;

}

contract GoldFarmFaasDeployer{

    using Address for address;
    event FaaSCreated(address, address, address);

    mapping(address => mapping(address => mapping(address => address))) public getFaaSContract;
    address[] public allContracts;
    
    
    
    function createFaaS(address _lpToken, address rewardToken0, address rewardToken1, 
                            uint256 rewardToken1Amount, uint256 _duration1, 
                            uint256 rewardToken2Amount, uint256 _duration2,
                            uint256 lpTokenFrictionlessFee) 
            external returns (address pair) {

        
        require(getFaaSContract[_lpToken][rewardToken0][rewardToken1] == address(0), 'Faas: Contract_EXISTS'); // single check is sufficient
        require(_duration1 !=0, "Cannot be 0");
        require(_duration2 !=0, "Cannot be 0");
        bytes memory bytecode = type(GoldFarmFaaS).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_lpToken, rewardToken0, rewardToken1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        
        iGoldFarmFaaS(pair).Initialize(_lpToken, rewardToken0, rewardToken1, _duration1, _duration2, lpTokenFrictionlessFee, msg.sender); 
        
        getFaaSContract[_lpToken][rewardToken0][rewardToken1] = pair;
        allContracts.push(pair);
        
        TransferHelper.safeTransferFrom(rewardToken0, msg.sender, address(pair), rewardToken1Amount);
        TransferHelper.safeTransferFrom(rewardToken1, msg.sender, address(pair), rewardToken2Amount);
        
        iGoldFarmFaaS(pair).setFarmRewards(rewardToken1Amount, _duration1);
        iGoldFarmFaaS(pair).setFarmRewards1(rewardToken2Amount, _duration2);
        
        emit FaaSCreated(_lpToken, rewardToken0, rewardToken1);
    }
    
    function createFaaSForOne(address _lpToken, address rewardToken0, 
                            uint256 rewardToken1Amount, uint256 _duration1,
                            uint256 lpTokenFrictionlessFee) 
            external returns (address pair) {

        
        require(getFaaSContract[_lpToken][rewardToken0][address(0)] == address(0), 'Faas: Contract_EXISTS'); // single check is sufficient
        require(_duration1 !=0, "Cannot be 0");
        bytes memory bytecode = type(GoldFarmFaaSForOne).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(_lpToken, rewardToken0, address(0)));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        
        iGoldFarmFaaSForOne(pair).Initialize(_lpToken, rewardToken0, _duration1, lpTokenFrictionlessFee, msg.sender); 
        
        getFaaSContract[_lpToken][rewardToken0][address(0)] = pair;
        allContracts.push(pair);
        
        TransferHelper.safeTransferFrom(rewardToken0, msg.sender, address(pair), rewardToken1Amount);
        
        iGoldFarmFaaSForOne(pair).setFarmRewards(rewardToken1Amount, _duration1);
        
        emit FaaSCreated(_lpToken, rewardToken0, address(0));
    }
    
    function getFaaSContractAddress(address _lpToken, address rewardToken0, address rewardToken1) public view returns(address){

        return getFaaSContract[_lpToken][rewardToken0][rewardToken1];
    }
}


contract GoldFarmFaaS is IRewardDistributionRecipient, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;
    
    IERC20 public rewardToken;
    
    IERC20 public rewardToken1;
    
    IERC20 public lpToken; // Farm Token BSC20
    
    address public devAddy = 0xdaC47d05e1aAa9Bd4DA120248E8e0d7480365CFB;//collects pool use fee
    uint256 public devtxfee = 1; //Fee for pool use, sent to GOLD farming pool
    uint256 public txfee = 0; //Amount of frictionless rewards of the LP token 
    
    uint256 public duration = 90 days;
    uint256 public duration1 = 90 days;
    bool public perform = true;
    
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    
    uint256 public periodFinish1 = 0;
    uint256 public rewardRate1 = 0;
    uint256 public lastUpdateTime1;
    uint256 public rewardPerTokenStored1;
    mapping(address => uint256) public userRewardPerTokenPaid1;
    mapping(address => uint256) public rewards1;
    
    mapping(address => uint) public farmTime; 
    bool public farmBreaker = false; // farm can be lock by admin,, default unlocked type=0
    bool public rewardBreaker = false; // getreward can be lock by admin,, default unlocked type=1
    bool public reward1Breaker = false; // getreward1 can be lock by admin,, default unlocked type=2
    bool public withdrawBreaker = false; // withdraw can be lock by admin,, default unlocked type=3
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    
    mapping(address => uint256) public lpTokenReward;

    event RewardAdded(uint256 reward);
    event Farmed(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    
    address[] public farmers;
    bool public deployed = false;
    
    struct USER{
        bool initialized;
    }
    
    mapping(address => USER) stakers;
    
    constructor() { }
    
    function Initialize(address _lpToken, address _rewardToken, address _rewardToken1, uint256 _duration1, uint256 _duration2, uint256 _lpTokenFrictionlessFee, address _newOwner) external nonReentrant {

        require(deployed != true, "Contract can only Initialize once");
        rewardToken = IERC20(_rewardToken);
        rewardToken1 = IERC20(_rewardToken1);
        lpToken = IERC20(_lpToken);
        setRewardDistributionAdmin(msg.sender);
        transferOwnership(_newOwner);
        
        duration = _duration1;
        duration1 = _duration2;
        
        txfee = _lpTokenFrictionlessFee;
        
        deployed = true;
    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    
    modifier updateReward1(address account) {

        rewardPerTokenStored1 = rewardPerToken1();
        lastUpdateTime1 = lastTimeRewardApplicable1();
        if (account != address(0)) {
            rewards1[account] = earned1(account);
            userRewardPerTokenPaid1[account] = rewardPerTokenStored1;
        }
        _;
    }


    modifier noContract(address account) {

        require(Address.isContract(account) == false, "Contracts are not allowed to interact with the farm");
        _;
    }
    
    function setdevAddy(address _addy) public onlyOwner {

        require(_addy != address(0), " Setting 0 as Addy "); 
        devAddy = _addy;
    }
    
    function setBreaker(bool _breaker, uint256 _type) external onlyOwner {

        if(_type==0){
            farmBreaker =_breaker;
            
        }
        else if(_type==1){
            rewardBreaker=_breaker;
            
        }
        else if(_type==2){
            reward1Breaker=_breaker;
            
        }else if(_type==3){
            withdrawBreaker=_breaker;
            
        }
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }
    
    function recoverLostTokensAfterFarmExpired(IERC20 _token, uint256 amount) external onlyOwner {

        require(duration < block.timestamp, "Cannot use if farm is live");
        _token.safeTransfer(owner(), amount);
    }
    
    receive() external payable {
        revert();
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }
    
    function lastTimeRewardApplicable1() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish1);
    }
    
    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(10** IERC20(rewardToken).decimals())
                    .div(totalSupply())
            );
    }
    
    function rewardPerToken1() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored1;
        }

        return
            rewardPerTokenStored1.add(
                lastTimeRewardApplicable1()
                    .sub(lastUpdateTime1)
                    .mul(rewardRate1)
                    .mul(10** IERC20(rewardToken1).decimals())
                    .div(totalSupply())
            );
    }



    function earned(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(10** IERC20(rewardToken).decimals())
                .add(rewards[account]);
    }
    
    function earned1(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken1().sub(userRewardPerTokenPaid1[account]))
                .div(10** IERC20(rewardToken1).decimals())
                .add(rewards1[account]);
    }
    
    function isStakeholder(address _address)
       public
       view
       returns(bool)
   {

       
       if(stakers[_address].initialized) return true;
       else return false;
   }
   
   function addStakeholder(address _stakeholder)
       internal
   {

       (bool _isStakeholder) = isStakeholder(_stakeholder);
       if(!_isStakeholder) {
           farmTime[msg.sender] =  block.timestamp;
           stakers[_stakeholder].initialized = true;
           farmers.push(_stakeholder);
       }
   }

    function farm(uint256 amount) external updateReward(msg.sender) updateReward1(msg.sender) noContract(msg.sender) nonReentrant {

        require(farmBreaker == false, "Admin Restricted function temporarily 0");
        require(amount > 0, "Cannot farm nothing");

        lpToken.safeTransferFrom(msg.sender, address(this), amount);
        
        uint256 devtax = amount.mul(devtxfee).div(100);
        uint256 _txfee = amount.mul(txfee).div(100);
        
        lpToken.safeTransfer(address(devAddy), devtax);
        
        uint256 finalAmount = amount.sub(_txfee).sub(devtax);
        
        _totalSupply = _totalSupply.add(finalAmount);
        _balances[msg.sender] = _balances[msg.sender].add(finalAmount);
        
        addStakeholder(msg.sender);
        
        emit Farmed(msg.sender,finalAmount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) updateReward1(msg.sender) noContract(msg.sender) nonReentrant {

        require(withdrawBreaker == false, "Admin Restricted function temporarily 3");
        require(amount > 0, "Cannot withdraw nothing");
        
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
        
        if( _balances[msg.sender] == 0) {
            stakers[msg.sender].initialized = false;
        }
        emit Withdrawn(msg.sender, amount);
        
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
        ClaimLPReward(); 
        getReward();
        getReward1();
        }

    function getReward() public updateReward(msg.sender) noContract(msg.sender) {

        require(rewardBreaker == false, "Admin Restricted function temporarily 1");
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }
    
    function getReward1() public updateReward1(msg.sender) noContract(msg.sender) {

        require(reward1Breaker == false, "Admin Restricted function temporarily 2");
        uint256 reward1 = earned1(msg.sender);
        if (reward1 > 0) {
            rewards1[msg.sender] = 0;
            rewardToken1.safeTransfer(msg.sender, reward1);
            emit RewardPaid(msg.sender, reward1);
        }
    }
    
    function setFarmRewards(uint256 reward, uint256 _duration)
        public
        onlyRewardDistribution
        nonReentrant
        updateReward(address(0))
    {

        require(_duration > 0, "Duration must not be 0");
        if(rewardRate.mul(duration) <= rewardToken.balanceOf(address(this))){
            duration = _duration.mul(1 days);
            if (block.timestamp >= periodFinish) {
                rewardRate = reward.div(duration);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(duration);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(duration);
            emit RewardAdded(reward);
        }
    }
    
    function setFarmRewards1(uint256 _reward1, uint256 _duration2)
        public
        onlyRewardDistribution
        nonReentrant
        updateReward1(address(0))
    {

        require(_duration2 > 0, "Duration must not be 0");
        if(rewardRate1.mul(duration1) <= rewardToken1.balanceOf(address(this))){
            duration1 = _duration2.mul(1 days);
            if (block.timestamp >= periodFinish1) {
                rewardRate1 = _reward1.div(duration1);
            } else {
                uint256 remaining1 = periodFinish1.sub(block.timestamp);
                uint256 leftover1 = remaining1.mul(rewardRate1);
                rewardRate1 = _reward1.add(leftover1).div(duration1);
            }
            lastUpdateTime1 = block.timestamp;
            periodFinish1 = block.timestamp.add(duration1);
            emit RewardAdded(_reward1);
        }
    }
    
    uint256 public aclaimed = 0;
    
    function DisributeLPTxFunds1() public { // distribute any TX rewards tokens sent to pool for tokens with TX rewards

        
        
        uint256 balanceOfContract = lpToken.balanceOf(address(this));
        uint256 transferToAmount = balanceOfContract.sub(_totalSupply.add(aclaimed));
        
        aclaimed = aclaimed.add(transferToAmount);
                   
        if(transferToAmount > 0 ){
            for (uint256 s = 0; s < farmers.length; s++){
                 address abc = farmers[s];
                 uint256 blnc = balanceOf(abc);
                 if(blnc > 0) {
                     uint256 userShare  = (transferToAmount).mul(blnc).div(_totalSupply); 
                       
                       lpTokenReward[abc] = lpTokenReward[abc].add(userShare);
                       
                       emit RewardAdded(userShare);
                 }
           }
        }
    }
    
    function ClaimAllRewards() public {

        ClaimLPReward();
        getReward();
        getReward1();
        if(perform==true){
        DisributeLPTxFunds1();}
    }
    
    
    function onePercent(uint256 _tokens) private pure returns (uint256){

        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
    function emergencySaveLostTokens(address _token) external onlyOwner {

        require(IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this))), "Error in retrieving tokens");
    }
    
    function ClaimLPReward() public {

        address _addy = msg.sender;
        
        if(lpTokenReward[_addy] > 0 ){
            aclaimed = aclaimed.sub(lpTokenReward[_addy]);
            
            lpToken.safeTransfer(msg.sender, lpTokenReward[_addy]);
            lpTokenReward[_addy] = 0;
        }
    }
    
    function changePerform(bool _bool) external onlyOwner{

        perform = _bool;
    }
}


contract GoldFarmFaaSForOne is IRewardDistributionRecipient, ReentrancyGuard {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    using Address for address;
    
    IERC20 public rewardToken;//  BSC20
    
    IERC20 public lpToken; //  BSC20
    
    address public devAddy = 0xdaC47d05e1aAa9Bd4DA120248E8e0d7480365CFB;//collects pool use fee
    uint256 public devtxfee = 1; //Fee for pool use, sent to GOLD farming pool
    uint256 public txfee = 0; //Amount of frictionless rewards of the LP token 
    
    uint256 public duration = 180 days;
    bool public perform = true;
    
    uint256 public periodFinish = 0;
    uint256 public rewardRate = 0;
    uint256 public lastUpdateTime;
    uint256 public rewardPerTokenStored;
    mapping(address => uint256) public userRewardPerTokenPaid;
    mapping(address => uint256) public rewards;
    
    
    mapping(address => uint) public farmTime; 
    bool public farmBreaker = false; // farm can be lock by admin,, default unlocked type=0
    bool public rewardBreaker = false; // getreward can be lock by admin,, default unlocked type=1
    bool public withdrawBreaker = false; // withdraw can be lock by admin,, default unlocked type=3
    
    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    
    mapping(address => uint256) public lpTokenReward;

    event RewardAdded(uint256 reward);
    event Farmed(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event RewardPaid(address indexed user, uint256 reward);
    
    address[] public farmers;
    bool public deployed = false;
    
    struct USER{
        bool initialized;
    }
    
    mapping(address => USER) stakers;
    
    constructor() { }

    function Initialize(address _lpToken, address _rewardToken, uint256 _duration1, uint256 _lpTokenFrictionlessFee, address _newOwner) external nonReentrant {

        rewardToken = IERC20(_rewardToken);
        lpToken = IERC20(_lpToken);
        setRewardDistributionAdmin(msg.sender);
        
        transferOwnership(_newOwner);
        
        duration = _duration1;
        
        txfee = _lpTokenFrictionlessFee;
        
        deployed = true;

    }

    modifier updateReward(address account) {

        rewardPerTokenStored = rewardPerToken();
        lastUpdateTime = lastTimeRewardApplicable();
        if (account != address(0)) {
            rewards[account] = earned(account);
            userRewardPerTokenPaid[account] = rewardPerTokenStored;
        }
        _;
    }
    
    

    modifier noContract(address account) {

        require(Address.isContract(account) == false, "Contracts are not allowed to interact with the farm");
        _;
    }
    
    function setdevAddy(address _addy) public onlyOwner {

        require(_addy != address(0), " Setting 0 as Addy "); 
        devAddy = _addy;
    }
    
    function setBreaker(bool _breaker, uint256 _type) external onlyOwner {

        if(_type==0){
            farmBreaker =_breaker;
            
        }
        else if(_type==1){
            rewardBreaker=_breaker;
            
        }
        else if(_type==3){
            withdrawBreaker=_breaker;
            
        }
    }

    function totalSupply() public view returns (uint256) {

        return _totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {

        return _balances[account];
    }
    
    function recoverLostTokensAfterFarmExpired(IERC20 _token, uint256 amount) external onlyOwner {

        require(duration < block.timestamp, "Cannot use if farm is live");
        _token.safeTransfer(owner(), amount);
    }
    
    receive() external payable {
        revert();
    }

    function lastTimeRewardApplicable() public view returns (uint256) {

        return Math.min(block.timestamp, periodFinish);
    }
    
    
    function rewardPerToken() public view returns (uint256) {

        if (totalSupply() == 0) {
            return rewardPerTokenStored;
        }

        return
            rewardPerTokenStored.add(
                lastTimeRewardApplicable()
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(10** IERC20(rewardToken).decimals())
                    .div(totalSupply())
            );
    }
    
    
    function earned(address account) public view returns (uint256) {

        return
            balanceOf(account)
                .mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(10** IERC20(rewardToken).decimals())
                .add(rewards[account]);
    }
    
    
    function isStakeholder(address _address)
       public
       view
       returns(bool)
   {

       
       if(stakers[_address].initialized) return true;
       else return false;
   }
   
   function addStakeholder(address _stakeholder)
       internal
   {

       (bool _isStakeholder) = isStakeholder(_stakeholder);
       if(!_isStakeholder) {
           farmTime[msg.sender] =  block.timestamp;
           stakers[_stakeholder].initialized = true;
	        farmers.push(_stakeholder);
       }
   }

    function farm(uint256 amount) external updateReward(msg.sender) noContract(msg.sender) nonReentrant {

        require(farmBreaker == false, "Admin Restricted function temporarily");
        require(amount > 0, "Cannot farm nothing");

        lpToken.safeTransferFrom(msg.sender, address(this), amount);
        
        uint256 devtax = amount.mul(devtxfee).div(100);
        uint256 _txfee = amount.mul(txfee).div(100);
        
        lpToken.safeTransfer(address(devAddy), devtax);
        
        uint256 finalAmount = amount.sub(_txfee).sub(devtax);
        
        _totalSupply = _totalSupply.add(finalAmount);
        _balances[msg.sender] = _balances[msg.sender].add(finalAmount);
        
        addStakeholder(msg.sender);
        
        emit Farmed(msg.sender,finalAmount);
    }

    function withdraw(uint256 amount) public updateReward(msg.sender) noContract(msg.sender) nonReentrant {

        require(withdrawBreaker == false, "Admin Restricted function temporarily");
        require(amount > 0, "Cannot withdraw nothing");
        
        _totalSupply = _totalSupply.sub(amount);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
        
        if( _balances[msg.sender] == 0) {
            stakers[msg.sender].initialized = false;
        }
        emit Withdrawn(msg.sender, amount);
        
    }

    function exit() external {

        withdraw(balanceOf(msg.sender));
        ClaimLPReward(); 
        getReward();
        }

    function getReward() public updateReward(msg.sender) noContract(msg.sender) {

        require(rewardBreaker == false, "Admin Restricted function temporarily");
        uint256 reward = earned(msg.sender);
        if (reward > 0) {
            rewards[msg.sender] = 0;
            rewardToken.safeTransfer(msg.sender, reward);
            emit RewardPaid(msg.sender, reward);
        }
    }
    
    
    function setFarmRewards(uint256 reward, uint256 _duration)
        public
        onlyRewardDistribution
        nonReentrant
        updateReward(address(0))
    {

        require(_duration > 0, "Duration must not be 0");
        if(rewardRate.mul(duration) <= rewardToken.balanceOf(address(this))){
            duration = _duration.mul(1 days);
            if (block.timestamp >= periodFinish) {
                rewardRate = reward.div(duration);
            } else {
                uint256 remaining = periodFinish.sub(block.timestamp);
                uint256 leftover = remaining.mul(rewardRate);
                rewardRate = reward.add(leftover).div(duration);
            }
            lastUpdateTime = block.timestamp;
            periodFinish = block.timestamp.add(duration);
            emit RewardAdded(reward);
        }
    }
    
    
    
    uint256 public aclaimed = 0;
    
    function DisributeLPTxFunds1() public { // distribute any TX rewards tokens sent to pool for tokens with TX rewards

        
        
        uint256 balanceOfContract = lpToken.balanceOf(address(this));
        uint256 transferToAmount = balanceOfContract.sub(_totalSupply.add(aclaimed));
        
        aclaimed = aclaimed.add(transferToAmount);
                   
        if(transferToAmount > 0 ){
            for (uint256 s = 0; s < farmers.length; s++){
                 address abc = farmers[s];
                 uint256 blnc = balanceOf(abc);
                 if(blnc > 0) {
                     uint256 userShare  = (transferToAmount).mul(blnc).div(_totalSupply); 
                       
                       lpTokenReward[abc] = lpTokenReward[abc].add(userShare);
                       
                       emit RewardAdded(userShare);
                 }
           }
        }
    }
    
    function ClaimAllRewards() public {

        ClaimLPReward();
        getReward();
        if(perform==true){
        DisributeLPTxFunds1();}
    }
    
    
    function onePercent(uint256 _tokens) private pure returns (uint256){

        uint256 roundValue = _tokens.ceil(100);
        uint onePercentofTokens = roundValue.mul(100).div(100 * 10**uint(2));
        return onePercentofTokens;
    }
    
    function emergencySaveLostTokens(address _token) external onlyOwner {

        require(IERC20(_token).transfer(owner(), IERC20(_token).balanceOf(address(this))), "Error in retrieving tokens");
    }
    
    function ClaimLPReward() public {

        address _addy = msg.sender;
        
        if(lpTokenReward[_addy] > 0 ){
            aclaimed = aclaimed.sub(lpTokenReward[_addy]);
            
            lpToken.safeTransfer(msg.sender, lpTokenReward[_addy]);
            lpTokenReward[_addy] = 0;
        }
    }
    
    function changePerform(bool _bool) external onlyOwner{

        perform = _bool;
    }
}