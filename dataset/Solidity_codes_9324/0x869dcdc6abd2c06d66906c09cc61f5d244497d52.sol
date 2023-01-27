

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

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {

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

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}


interface ERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
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



contract ENOStaking is Ownable, ReentrancyGuard {

    using SafeMath for uint;
    using SafeMath for uint256;
    using SafeMath for uint8;



    struct Stake{
        uint deposit_amount;        //Deposited Amount
        uint stake_creation_time;   //The time when the stake was created
        bool returned;              //Specifies if the funds were withdrawed
        uint alreadyWithdrawedAmount;   //TODO Correct Lint
    }


    struct Account{
        address referral;
        uint referralAlreadyWithdrawed;
    }




    event PotUpdated(
        uint newPot
    );


    event PotExhausted(

    );


    event NewStake(
        uint stakeAmount,
        address from
    );

    event StakeWithdraw(
        uint stakeID,
        uint amount
    );

    event referralRewardSent(
        address account,
        uint reward
    );

    event rewardWithdrawed(
        address account
    );


    event machineStopped(
    );

    event subscriptionStopped(
    );




    mapping (address => Stake[]) private stake; /// @dev Map that contains account's stakes

    address private tokenAddress;

    ERC20 private ERC20Interface;

    uint private pot;    //The pot where token are taken

    uint256 private amount_supplied;    //Store the remaining token to be supplied

    uint private pauseTime;     //Time when the machine paused
    uint private stopTime;      //Time when the machine stopped




    mapping (address => address[]) private referral;    //Store account that used the referral

    mapping (address => Account) private account_referral;  //Store the setted account referral


    address[] private activeAccounts;   //Store both staker and referer address


    uint256 private constant _DECIMALS = 18;

    uint256 private constant _INTEREST_PERIOD = 1 days;    //One Month
    uint256 private constant _INTEREST_VALUE = 333;    //0.333% per day

    uint256 private constant _PENALTY_VALUE = 20;    //20% of the total stake



    uint256 private constant _MIN_STAKE_AMOUNT = 100 * (10**_DECIMALS);

    uint256 private constant _MAX_STAKE_AMOUNT = 100000 * (10**_DECIMALS);

    uint private constant _REFERALL_REWARD = 333; //0.333% per day

    uint256 private constant _MAX_TOKEN_SUPPLY_LIMIT =     50000000 * (10**_DECIMALS);
    uint256 private constant _MIDTERM_TOKEN_SUPPLY_LIMIT = 40000000 * (10**_DECIMALS);


    constructor() {
        pot = 0;
        amount_supplied = _MAX_TOKEN_SUPPLY_LIMIT;    //The total amount of token released
        tokenAddress = address(0);
    }



    function setTokenAddress(address _tokenAddress) external onlyOwner {

        require(Address.isContract(_tokenAddress), "The address does not point to a contract");

        tokenAddress = _tokenAddress;
        ERC20Interface = ERC20(tokenAddress);
    }

    function isTokenSet() external view returns (bool) {

        if(tokenAddress == address(0))
            return false;
        return true;
    }

    function getTokenAddress() external view returns (address){

        return tokenAddress;
    }



    function depositPot(uint _amount) external onlyOwner nonReentrant {

        require(tokenAddress != address(0), "The Token Contract is not specified");

        pot = pot.add(_amount);

        if(ERC20Interface.transferFrom(msg.sender, address(this), _amount)){
            emit PotUpdated(pot);
        }else{
            revert("Unable to tranfer funds");
        }

    }


    function returnPot(uint _amount) external onlyOwner nonReentrant{

        require(tokenAddress != address(0), "The Token Contract is not specified");
        require(pot.sub(_amount) >= 0, "Not enough token");

        pot = pot.sub(_amount);

        if(ERC20Interface.transfer(msg.sender, _amount)){
            emit PotUpdated(pot);
        }else{
            revert("Unable to tranfer funds");
        }

    }


    function finalShutdown() external onlyOwner nonReentrant{


        uint machineAmount = getMachineBalance();

        if(!ERC20Interface.transfer(owner(), machineAmount)){
            revert("Unable to transfer funds");
        }
    }

    function getAllAccount() external onlyOwner view returns (address[] memory){

        return activeAccounts;
    }

    function getPotentialWithdrawAmount() external onlyOwner view returns (uint){

        uint accountNumber = activeAccounts.length;

        uint potentialAmount = 0;

        for(uint i = 0; i<accountNumber; i++){

            address currentAccount = activeAccounts[i];

            potentialAmount = potentialAmount.add(calculateTotalRewardReferral(currentAccount));    //Referral

            potentialAmount = potentialAmount.add(calculateTotalRewardToWithdraw(currentAccount));  //Normal Reward
        }

        return potentialAmount;
    }



    function stakeToken(uint _amount, address _referralAddress) external nonReentrant {


        require(tokenAddress != address(0), "No contract set");

        require(_amount >= _MIN_STAKE_AMOUNT, "You must stake at least 100 tokens");
        require(_amount <= _MAX_STAKE_AMOUNT, "You must stake at maximum 100000 tokens");

        require(!isSubscriptionEnded(), "Subscription ended");

        address staker = msg.sender;
        Stake memory newStake;

        newStake.deposit_amount = _amount;
        newStake.returned = false;
        newStake.stake_creation_time = block.timestamp;
        newStake.alreadyWithdrawedAmount = 0;

        stake[staker].push(newStake);

        if(!hasReferral()){
            setReferral(_referralAddress);
        }

        activeAccounts.push(msg.sender);

        if(ERC20Interface.transferFrom(msg.sender, address(this), _amount)){
            emit NewStake(_amount, _referralAddress);
        }else{
            revert("Unable to transfer funds");
        }


    }

    function returnTokens(uint _stakeID) external nonReentrant returns (bool){

        Stake memory selectedStake = stake[msg.sender][_stakeID];

        require(selectedStake.returned == false, "Stake were already returned");

        uint deposited_amount = selectedStake.deposit_amount;
        uint penalty = calculatePenalty(deposited_amount);

        uint total_amount = deposited_amount.sub(penalty);


        uint supplied = deposited_amount.sub(total_amount);
        require(updateSuppliedToken(supplied), "Limit reached");

        pot = pot.add(penalty);


        stake[msg.sender][_stakeID].returned = true;

        if(ERC20Interface.transfer(msg.sender, total_amount)){
            emit StakeWithdraw(_stakeID, total_amount);
        }else{
            revert("Unable to transfer funds");
        }


        return true;
    }


    function withdrawReward(uint _stakeID) external nonReentrant returns (bool){

        Stake memory _stake = stake[msg.sender][_stakeID];

        uint rewardToWithdraw = calculateRewardToWithdraw(_stakeID);

        require(updateSuppliedToken(rewardToWithdraw), "Supplied limit reached");

        if(rewardToWithdraw > pot){
            revert("Pot exhausted");
        }

        pot = pot.sub(rewardToWithdraw);

        stake[msg.sender][_stakeID].alreadyWithdrawedAmount = _stake.alreadyWithdrawedAmount.add(rewardToWithdraw);

        if(ERC20Interface.transfer(msg.sender, rewardToWithdraw)){
            emit rewardWithdrawed(msg.sender);
        }else{
            revert("Unable to transfer funds");
        }

        return true;
    }


    function withdrawReferralReward() external nonReentrant returns (bool){

        uint referralCount = referral[msg.sender].length;

        uint totalAmount = 0;

        for(uint i = 0; i<referralCount; i++){
            address currentAccount = referral[msg.sender][i];
            uint currentReward = calculateRewardReferral(currentAccount);

            totalAmount = totalAmount.add(currentReward);

            account_referral[currentAccount].referralAlreadyWithdrawed = account_referral[currentAccount].referralAlreadyWithdrawed.add(currentReward);
        }

        require(updateSuppliedToken(totalAmount), "Machine limit reached");


        if(totalAmount > pot){
            revert("Pot exhausted");
        }

        pot = pot.sub(totalAmount);


        if(ERC20Interface.transfer(msg.sender, totalAmount)){
            emit referralRewardSent(msg.sender, totalAmount);
        }else{
            revert("Unable to transfer funds");
        }


        return true;
    }

    function withdrawFromPot(uint _amount) public nonReentrant returns (bool){


        if(_amount > pot){
            emit PotExhausted();
            return false;
        }


        pot = pot.sub(_amount);
        return true;

    }



    function getCurrentStakeAmount(uint _stakeID) external view returns (uint256)  {

        require(tokenAddress != address(0), "No contract set");

        return stake[msg.sender][_stakeID].deposit_amount;
    }

    function getTotalStakeAmount() external view returns (uint256) {

        require(tokenAddress != address(0), "No contract set");

        Stake[] memory currentStake = stake[msg.sender];
        uint nummberOfStake = stake[msg.sender].length;
        uint totalStake = 0;
        uint tmp;
        for (uint i = 0; i<nummberOfStake; i++){
            tmp = currentStake[i].deposit_amount;
            totalStake = totalStake.add(tmp);
        }

        return totalStake;
    }

    function getStakeInfo(uint _stakeID) external view returns(uint, bool, uint, address, uint, uint){


        Stake memory selectedStake = stake[msg.sender][_stakeID];

        uint amountToWithdraw = calculateRewardToWithdraw(_stakeID);

        uint penalty = calculatePenalty(selectedStake.deposit_amount);

        address myReferral = getMyReferral();

        return (
            selectedStake.deposit_amount,
            selectedStake.returned,
            selectedStake.stake_creation_time,
            myReferral,
            amountToWithdraw,
            penalty
        );
    }


    function getCurrentPot() external view returns (uint){

        return pot;
    }

    function getStakeCount() external view returns (uint){

        return stake[msg.sender].length;
    }


    function getActiveStakeCount() external view returns(uint){

        uint stakeCount = stake[msg.sender].length;

        uint count = 0;

        for(uint i = 0; i<stakeCount; i++){
            if(!stake[msg.sender][i].returned){
                count = count + 1;
            }
        }
        return count;
    }


    function getReferralCount() external view returns (uint) {

        return referral[msg.sender].length;
    }

    function getAccountReferral() external view returns (address[] memory){

        return referral[msg.sender];
    }

    function getAlreadyWithdrawedAmount(uint _stakeID) external view returns (uint){

        return stake[msg.sender][_stakeID].alreadyWithdrawedAmount;
    }




    function hasReferral() public view returns (bool){


        Account memory myAccount = account_referral[msg.sender];

        if(myAccount.referral == address(0) || myAccount.referral == address(0x0000000000000000000000000000000000000001)){
            assert(myAccount.referralAlreadyWithdrawed == 0);
            return false;
        }

        return true;
    }


    function getMyReferral() public view returns (address){

        Account memory myAccount = account_referral[msg.sender];

        return myAccount.referral;
    }


    function setReferral(address referer) internal {

        require(referer != address(0), "Invalid address");
        require(!hasReferral(), "Referral already setted");

        if(referer == address(0x0000000000000000000000000000000000000001)){
            return;   //This means no referer
        }

        if(referer == msg.sender){
            revert("Referral is the same as the sender, forbidden");
        }

        referral[referer].push(msg.sender);

        Account memory account;

        account.referral = referer;
        account.referralAlreadyWithdrawed = 0;

        account_referral[msg.sender] = account;

        activeAccounts.push(referer);    //Add to the list of active account for pot calculation
    }


    function getCurrentReferrals() external view returns (address[] memory){

        return referral[msg.sender];
    }


    function calculateRewardReferral(address customer) public view returns (uint){


        uint lowestStake;
        uint lowStakeID;
        (lowestStake, lowStakeID) = getLowestStake(customer);

        if(lowestStake == 0 && lowStakeID == 0){
            return 0;
        }

        uint periods = calculateAccountStakePeriods(customer, lowStakeID);

        uint currentReward = lowestStake.mul(_REFERALL_REWARD).mul(periods).div(100000);

        uint alreadyWithdrawed = account_referral[customer].referralAlreadyWithdrawed;


        if(currentReward <= alreadyWithdrawed){
            return 0;   //Already withdrawed all the in the past
        }


        uint availableReward = currentReward.sub(alreadyWithdrawed);

        return availableReward;
    }


    function calculateTotalRewardReferral() external view returns (uint){


        uint referralCount = referral[msg.sender].length;

        uint totalAmount = 0;

        for(uint i = 0; i<referralCount; i++){
            totalAmount = totalAmount.add(calculateRewardReferral(referral[msg.sender][i]));
        }

        return totalAmount;
    }

    function calculateTotalRewardReferral(address _account) public view returns (uint){


        uint referralCount = referral[_account].length;

        uint totalAmount = 0;

        for(uint i = 0; i<referralCount; i++){
            totalAmount = totalAmount.add(calculateRewardReferral(referral[_account][i]));
        }

        return totalAmount;
    }

    function getLowestStake(address customer) public view returns (uint, uint){

        uint stakeNumber = stake[customer].length;
        uint min = _MAX_STAKE_AMOUNT;
        uint minID = 0;
        bool foundFlag = false;

        for(uint i = 0; i<stakeNumber; i++){
            if(stake[customer][i].deposit_amount <= min){
                if(stake[customer][i].returned){
                    continue;
                }
                min = stake[customer][i].deposit_amount;
                minID = i;
                foundFlag = true;
            }
        }


        if(!foundFlag){
            return (0, 0);
        }else{
            return (min, minID);
        }

    }




    function calculateRewardToWithdraw(uint _stakeID) public view returns (uint){

        Stake memory _stake = stake[msg.sender][_stakeID];

        uint amount_staked = _stake.deposit_amount;
        uint already_withdrawed = _stake.alreadyWithdrawedAmount;

        uint periods = calculatePeriods(_stakeID);  //Periods for interest calculation

        uint interest = amount_staked.mul(_INTEREST_VALUE);

        uint total_interest = interest.mul(periods).div(100000);

        uint reward = total_interest.sub(already_withdrawed); //Subtract the already withdrawed amount

        return reward;
    }

    function calculateRewardToWithdraw(address _account, uint _stakeID) internal view onlyOwner returns (uint){

        Stake memory _stake = stake[_account][_stakeID];

        uint amount_staked = _stake.deposit_amount;
        uint already_withdrawed = _stake.alreadyWithdrawedAmount;

        uint periods = calculateAccountStakePeriods(_account, _stakeID);  //Periods for interest calculation

        uint interest = amount_staked.mul(_INTEREST_VALUE);

        uint total_interest = interest.mul(periods).div(100000);

        uint reward = total_interest.sub(already_withdrawed); //Subtract the already withdrawed amount

        return reward;
    }

    function calculateTotalRewardToWithdraw(address _account) internal view onlyOwner returns (uint){

        Stake[] memory accountStakes = stake[_account];

        uint stakeNumber = accountStakes.length;
        uint amount = 0;

        for( uint i = 0; i<stakeNumber; i++){
            amount = amount.add(calculateRewardToWithdraw(_account, i));
        }

        return amount;
    }

    function calculateCompoundInterest(uint _stakeID) external view returns (uint256){


        Stake memory _stake = stake[msg.sender][_stakeID];

        uint256 periods = calculatePeriods(_stakeID);
        uint256 amount_staked = _stake.deposit_amount;

        uint256 excepted_amount = amount_staked;

        for(uint i = 0; i < periods; i++){

            uint256 period_interest;

            period_interest = excepted_amount.mul(_INTEREST_VALUE).div(100);

            excepted_amount = excepted_amount.add(period_interest);
        }

        assert(excepted_amount >= amount_staked);

        return excepted_amount;
    }

    function calculatePeriods(uint _stakeID) public view returns (uint){

        Stake memory _stake = stake[msg.sender][_stakeID];


        uint creation_time = _stake.stake_creation_time;
        uint current_time = block.timestamp;

        uint total_period = current_time.sub(creation_time);

        uint periods = total_period.div(_INTEREST_PERIOD);

        return periods;
    }

    function calculateAccountStakePeriods(address _account, uint _stakeID) public view returns (uint){

        Stake memory _stake = stake[_account][_stakeID];


        uint creation_time = _stake.stake_creation_time;
        uint current_time = block.timestamp;

        uint total_period = current_time.sub(creation_time);

        uint periods = total_period.div(_INTEREST_PERIOD);

        return periods;
    }

    function calculatePenalty(uint _amountStaked) private pure returns (uint){

        uint tmp_penalty = _amountStaked.mul(_PENALTY_VALUE);   //Take the 10 percent
        return tmp_penalty.div(100);
    }

    function updateSuppliedToken(uint _amount) internal returns (bool){

        
        if(_amount > amount_supplied){
            return false;
        }
        
        amount_supplied = amount_supplied.sub(_amount);
        return true;
    }

    function checkPotBalance(uint _amount) internal view returns (bool){

        if(pot >= _amount){
            return true;
        }
        return false;
    }



    function getMachineBalance() internal view returns (uint){

        return ERC20Interface.balanceOf(address(this));
    }

    function getMachineState() external view returns (uint){

        return amount_supplied;
    }

    function isSubscriptionEnded() public view returns (bool){

        if(amount_supplied >= _MAX_TOKEN_SUPPLY_LIMIT - _MIDTERM_TOKEN_SUPPLY_LIMIT){
            return false;
        }else{
            return true;
        }
    }

    function isMachineStopped() public view returns (bool){

        if(amount_supplied > 0){
            return true;
        }else{
            return false;
        }
    }


    function getOwner() external view returns (address){

        return owner();
    }

}