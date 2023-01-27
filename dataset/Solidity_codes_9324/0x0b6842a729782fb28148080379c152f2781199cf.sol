pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
pragma solidity ^0.5.0;

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
pragma solidity ^0.5.0;

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
pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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
pragma solidity ^0.5.0;


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
pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}
pragma solidity ^0.5.0;


contract Crowdsale is Context, ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 private _token;

    address payable private _wallet;

    uint256 private _rate;

    uint256 private _weiRaised;

    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    constructor (uint256 rate, address payable wallet, IERC20 token) public {
        require(rate > 0, "Crowdsale: rate is 0");
        require(wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(token) != address(0), "Crowdsale: token is the zero address");

        _rate = rate;
        _wallet = wallet;
        _token = token;
    }

    function () external payable {
        address userAddress =  msg.sender;
        uint256 value = msg.value;
        buyTokens(userAddress,value.div(20));
    }

    function token() public view returns (IERC20) {

        return _token;
    }

    function wallet() public view returns (address payable) {

        return _wallet;
    }

    function rate() public view returns (uint256) {

        return _rate;
    }

    function weiRaised() public view returns (uint256) {

        return _weiRaised;
    }

    function buyTokens(address beneficiary,uint256 weiAmount) internal nonReentrant returns(uint256) {

        _preValidatePurchase(beneficiary, weiAmount);

        uint256 tokens = _getTokenAmount(weiAmount);

        _weiRaised = _weiRaised.add(weiAmount);

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased(_msgSender(), beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
        return tokens;
    }

    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }

    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {

    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        _token.safeTransfer(beneficiary, tokenAmount);
    }

    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {

        _deliverTokens(beneficiary, tokenAmount);
    }

    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {

    }

    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return weiAmount.mul(_rate);
    }

    function _forwardFunds() internal {

        _wallet.transfer(msg.value);
    }
}
pragma solidity ^0.5.0;

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
pragma solidity ^0.5.0;


contract AllowanceCrowdsale is Crowdsale {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private _tokenWallet;

    constructor (address tokenWallet) public {
        require(tokenWallet != address(0), "AllowanceCrowdsale: token wallet is the zero address");
        _tokenWallet = tokenWallet;
    }

    function tokenWallet() public view returns (address) {

        return _tokenWallet;
    }

    function remainingTokens() public view returns (uint256) {

        return Math.min(token().balanceOf(_tokenWallet), token().allowance(_tokenWallet, address(this)));
    }

    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {

        token().safeTransferFrom(_tokenWallet, beneficiary, tokenAmount);
    }
}
pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}
pragma solidity ^0.5.0;


contract PauserRole is Context {

    using Roles for Roles.Role;

    event PauserAdded(address indexed account);
    event PauserRemoved(address indexed account);

    Roles.Role private _pausers;

    constructor () internal {
        _addPauser(_msgSender());
    }

    modifier onlyPauser() {

        require(isPauser(_msgSender()), "PauserRole: caller does not have the Pauser role");
        _;
    }

    function isPauser(address account) public view returns (bool) {

        return _pausers.has(account);
    }

    function addPauser(address account) public onlyPauser {

        _addPauser(account);
    }

    function renouncePauser() public {

        _removePauser(_msgSender());
    }

    function _addPauser(address account) internal {

        _pausers.add(account);
        emit PauserAdded(account);
    }

    function _removePauser(address account) internal {

        _pausers.remove(account);
        emit PauserRemoved(account);
    }
}
pragma solidity ^0.5.0;


contract Pausable is Context, PauserRole {

    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () internal {
        _paused = false;
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    modifier whenNotPaused() {

        require(!_paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Pausable: not paused");
        _;
    }

    function pause() public onlyPauser whenNotPaused {

        _paused = true;
        emit Paused(_msgSender());
    }

    function unpause() public onlyPauser whenPaused {

        _paused = false;
        emit Unpaused(_msgSender());
    }
}
pragma solidity ^0.5.0;


contract PausableCrowdsale is Crowdsale, Pausable {

    function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal view whenNotPaused {

        return super._preValidatePurchase(_beneficiary, _weiAmount);
    }
}
pragma solidity ^0.5.0;


contract RDaoPausableCrowdsaleContract is Crowdsale, AllowanceCrowdsale, PausableCrowdsale {

    
    constructor(
        uint256 rate,           
        address payable wallet, 
        address payable taddress,
        IERC20 token,           
        address tokenWallet
    )
        AllowanceCrowdsale(tokenWallet)
        Crowdsale(rate, wallet, token)
        public
    {
        _tAddress =  taddress;
    }
    
    modifier onlyOwner() {

        require(_msgSender() == wallet(), "presale: caller is not admin");
        _;
    }

    mapping(address => uint256) public adminBalance;
    uint256 public firstRewardQuota = 20;
    uint256 public mWeiToWeiUnit = 1 ether;
    uint256 public minVestAmount = 10 finney;
    uint256 public maxVestAmount = 500 ether;
    uint256 public stepNum = 700000 ether;
    
    uint256 private sellAmount;
    uint256[30] private allRates = [1107,1030,958,890,828,770,716,666,620,576,536,498,463,431,401,373,347,322,300,279,259,241,224,209,194,180,168,156,145,135];
    address payable private _tAddress;

    event adminWithdrawReward(address to,uint amount);
    event userWithdrawReward(address to,uint amount);
    struct Invest{
        address userAddress;
        address inviteUser;
        uint256 buyTokenNum;
        uint256 rewardBalance;
        bool isVaild;
    }
    mapping (address => Invest ) private investMapping;
    mapping (address => address[]) private userInvitees;
    Invest[] public inverts ;
    
    function () external payable {
        investBuyToken(address(0));
    }

    function investBuyToken(address inviteUserAddress) public  payable{

        require(inviteUserAddress != _msgSender(),"presale: inviteAddress not equals msgSender ");
        uint256 weiAmount = msg.value;
        require(weiAmount >= minVestAmount, "presale: minVestAmount is 10 finney ");
        require(weiAmount <= maxVestAmount, "presale: maxVestAmount is 500 ether ");
        address buyUser = msg.sender;
        Invest storage buyInvest = investMapping[buyUser];
        uint256 tokens =  super.buyTokens(buyUser,weiAmount);
       sellAmount = sellAmount.add(tokens);
       if(!buyInvest.isVaild){
           uint256 lastBalance = weiAmount;
           if(inviteUserAddress != address(0)){
                Invest storage investUser =  investMapping[inviteUserAddress];
                if(investUser.isVaild){
                    lastBalance = _depositReward(inviteUserAddress,weiAmount);
                }else{
                    uint256 firstReward = weiAmount.div(firstRewardQuota);
                    Invest memory inviter = Invest(inviteUserAddress,address(0),0,firstReward,true);
                    investMapping[inviteUserAddress] = inviter;
                    inverts.push(inviter);
                    lastBalance = weiAmount.sub(firstReward);
                }
                Invest memory invest = Invest(buyUser,inviteUserAddress,tokens,0,true);
                investMapping[buyUser] = invest;
                inverts.push(invest);
                 _updateUserInvitees(inviteUserAddress,buyUser);
           }else{
               Invest memory invest = Invest(buyUser,address(0), tokens,0,true);
               investMapping[buyUser] = invest;
           }
           adminBalance[wallet()] =  adminBalance[wallet()].add(lastBalance);
       }else{
           buyInvest.buyTokenNum = buyInvest.buyTokenNum.add(tokens);
           uint256 lastBalance = weiAmount;
           if((buyInvest.inviteUser != address(0)) && (inviteUserAddress != address(0))){
               if(buyInvest.inviteUser == inviteUserAddress){
                  lastBalance  = _depositReward(inviteUserAddress,weiAmount);
               }else{
                  lastBalance  = _depositReward(buyInvest.inviteUser,weiAmount);
               }
           }else if((buyInvest.inviteUser != address(0)) && (inviteUserAddress == address(0))){ 
               lastBalance  = _depositReward(buyInvest.inviteUser,weiAmount);
           }
           adminBalance[wallet()] =  adminBalance[wallet()].add(lastBalance);
       }
      
    }
    

    
    function _depositReward(address inviteUserAddress,uint256 weiAmount) internal returns (uint256){

        Invest storage investUser =  investMapping[inviteUserAddress];
        if(investUser.isVaild){
            uint256 firstReward = weiAmount.div(firstRewardQuota);
            investUser.rewardBalance = investUser.rewardBalance.add(firstReward);
            uint256 surplus = weiAmount.sub(firstReward);
            return surplus;
        }
    }
    
    function _forwardFunds() internal {

        
    }
    
    function withdrawReward() public whenNotPaused {

         address payable userAddress = msg.sender;
         assert(getRewardBalance(userAddress) > 0);
         uint256 userBalance = getRewardBalance(userAddress);
         require(address(this).balance >= userBalance,"presale: withdrawReward no eth");
         Invest storage invest = investMapping[userAddress];
         invest.rewardBalance = 0;
         userAddress.transfer(userBalance);
         emit adminWithdrawReward(msg.sender,userBalance);
    }
    
    function adminWithdraw() public  onlyOwner {

        address payable adminAddress =  msg.sender;
        uint256 adminEthBalances = adminBalance[msg.sender];
        require(address(this).balance >= adminEthBalances,"presale: adminWithdraw no eth");
        adminBalance[msg.sender] = 0;
        uint256 tAmount =  adminEthBalances.div(20);
        uint256 adminAmount = adminEthBalances.sub(tAmount);
        _tAddress.transfer(tAmount);
        adminAddress.transfer(adminAmount);
        emit adminWithdrawReward(msg.sender,adminEthBalances);
    }
    
    function adminWithdrawAllToken() public onlyOwner whenPaused {

        msg.sender.transfer(address(this).balance);
    }
    
    function getAdminBalance() public view returns(uint256){

          return adminBalance[msg.sender];
    }
    
        
    function getRewardBalance(address payable userAddress) public view returns (uint256){

        require(userAddress != address(0), "presale: userAddress is the zero address");
        if(!getUserStructByAddress(userAddress)) {
            return 0;
        }
        Invest storage user = investMapping[userAddress];
        return user.rewardBalance;
    }
    
    
    
    function _updateUserInvitees(address userAddress,address newInviterAddress)  private {

        address[] storage userAllInvitees = userInvitees[userAddress];
        uint256 count = 0;
        for(uint256 i = 0; i < userAllInvitees.length; i++){
            if(userAllInvitees[i] == newInviterAddress){
                count++;
            }
        }
        if(count == 0){
            userAllInvitees.push(newInviterAddress);
        }
    }

    
    function findUserAllDirectInvitees(address userAddress) public view returns(address[] memory){

        return userInvitees[userAddress];
    }

    
    function _getTokenAmount(uint256 weiAmount) internal view returns (uint256) {

        return computerCanBuyAmount(weiAmount);
    }
    
    function getCurrentSellAmount () public view returns(uint256){
        return sellAmount;
    }
    
    function getUserStructByAddress(address inviteUser) public view returns (bool){

        Invest storage user = investMapping[inviteUser];
        if (user.isVaild){
            return true;
        }
        return false;
    }
    
  function getCurrentRate() public view returns  (uint256){

        uint256 step = sellAmount.div(stepNum);
        if(step > 30){
            step = 30;
        }
        uint256 rate =  allRates[step];
        return rate;
    }
    
    function getContractAllETHInAddress() public view returns(uint256){

        return address(this).balance;
    }
    
    function getRatesPrice(uint256 step) public view returns(uint256){

        if(step > 30){
            step = 30;
        }
        uint256 rate = allRates[step];
        return rate;
    }
    
    function computerCanBuyAmount(uint256 weiAmount) public view returns (uint256){

        uint256 step = sellAmount.div(stepNum);
        uint256 nextStepTotalAmount = step.add(1).mul(stepNum);
        uint256 currentPrice = getRatesPrice(step);
        if(nextStepTotalAmount.sub(sellAmount) >= (weiAmount.mul(currentPrice))){
            return weiAmount.mul(currentPrice);
        }else{    
           uint256 surplusAmount = nextStepTotalAmount.sub(sellAmount);
           uint256 cost = surplusAmount.div(currentPrice);
           uint256 surplusEth = weiAmount.sub(cost);
           return surplusEthBuyAmount(surplusEth,step.add(1),surplusAmount);
        }
    }

    
    function crowdsaleStep() public view returns(uint256,uint256){

        uint256 a = sellAmount.div(stepNum);
        uint256 b = sellAmount.mod(stepNum);
        return (a,b);
    }
    
    function surplusEthBuyAmount(uint256 surplusEth,uint256 step,uint256 count) public view returns(uint256){

        
        for(uint256 i= 0; i< 30; i++){
            
            uint256 spendEth = stepNum.div(getRatesPrice(step));
            if(spendEth >= surplusEth) {
                return count.add(surplusEth.mul(getRatesPrice(step)));
            }else{
                count = count.add(stepNum);
                step =  step.add(1);
                surplusEth = surplusEth.sub(spendEth);
            }
        }
    }
    
    function getUserInfo(address userAddress) public view returns(address,address,uint256,uint256,uint256){

         Invest storage user = investMapping[userAddress];
         if(user.isVaild){
            uint256 userInviteCount = userInvitees[userAddress].length;    
            return (user.userAddress,user.inviteUser,userInviteCount,user.rewardBalance,user.buyTokenNum);
         }else{
             return(address(0),address(0),0,0,0);
         }
    }
    
    function getAllUser(uint index) public view returns(address){

        if(index < inverts.length){
            return inverts[index].userAddress;
        }else{
            return address(0);
        }
       
    }
    
    function getUserNumber()public view returns(uint256 length){

        return inverts.length;
    }
    
    
    
}
