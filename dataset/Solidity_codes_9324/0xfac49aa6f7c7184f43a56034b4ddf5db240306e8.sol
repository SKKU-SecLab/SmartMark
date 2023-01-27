
pragma solidity >=0.8.0;


library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
    }
}

contract Ownable {

  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  constructor()  {
    owner = msg.sender;
  }


  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }


  function transferOwnership(address newOwner) onlyOwner public {

    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}


interface Token {

    function transferFrom(address, address, uint) external returns (bool);

    function transfer(address, uint) external returns (bool);

}

contract BSB_StakingStrongStakers is Ownable {

    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    event RewardsRestaked(address holder, uint amount);
    
    address public constant tokenDepositAddress = 0xA478A13242b64629bff309125770B69f75Bd77cb;
    
    uint public rewardRate = 104000;
    uint public constant rewardInterval = 365 days;
    
    uint public constant stakingFeeRate = 100;
    
    uint public constant unstakingFeeRate = 50;
    
    uint public constant unstakeTime = 365 days;
    
    uint public constant claimTime = 10 days;
    
    uint public constant maxPoolSize = 50000000000000000000000;
    uint public availablePoolSize = 50000000000000000000000;
    
    uint public constant totalRewards = 400000000000000000000000; 
    
    uint public totalClaimedRewards = 0;
    uint public totalDeposited = 0; // usar esta variable que no se usa!
    bool public ended ;
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public maxDepositedTokens;
    mapping (address => uint) public stakingTime; //used for the unstaking locktime
    mapping (address => uint) public firstTime; //used for the APY boost
    mapping (address => uint) public lastClaimedTime; //used for the claiming locktime
    mapping (address => uint) public progressiveTime; //used for the claiming locktime
    mapping (address => uint) public totalEarnedTokens;
    
    mapping (address => uint) public rewardEnded;
    
    mapping (address => uint) public alreadyProgUnstaked; 
    mapping (address => uint) public amountPerInterval;
    uint public number_intervals = 6;
    uint public duration_interval = 30 days;
    
    uint extraAPY = 10400; // 2% extra weekly
    
    uint percent_claim = 4; // 20% of weekly rewards earned
    mapping (address => uint) public unclaimed;
    
    uint public endTime;
    
    
    function end() public onlyOwner returns (bool){

        require(!ended, "Staking already ended");
        address _aux;
        
        for(uint i = 0; i < holders.length(); i = i.add(1)){
            _aux = holders.at(i);
            rewardEnded[_aux] = getPendingRewards(_aux);
            unclaimed[_aux] = 0;
            stakingTime[_aux] = block.timestamp;
            progressiveTime[_aux] = block.timestamp;
            alreadyProgUnstaked[_aux] = 0;
            amountPerInterval[_aux] = depositedTokens[_aux].div(number_intervals);
        }
        
        ended = true;
        endTime = block.timestamp;
        return true;
    }
    
    function getRewardsLeft() public view returns (uint){

       
        uint _res;
        if(ended){
            _res = 0;
        }else{
            uint totalPending;
            for(uint i = 0; i < holders.length(); i = i.add(1)){
                totalPending = totalPending.add(getPendingRewards(holders.at(i)));
            }
            if(totalRewards > totalClaimedRewards.add(totalPending)){
                _res = totalRewards.sub(totalClaimedRewards).sub(totalPending);
            }else{
                _res = 0;
            }
            
        }
        
        return _res;
    }
    
    function updateAccount(address account, bool _restake, bool _withdraw) private returns (bool){

        uint pendingDivs = getPendingRewards(account);
        uint toSend = pendingDivs;
        
        if(depositedTokens[account].mul(percent_claim).div(100) < pendingDivs){
            toSend = depositedTokens[account].mul(percent_claim).div(100);
        }
        
        if (pendingDivs > 0) {
            if(ended){ // claim o withdraw cuando ha terminado
                if(!_withdraw){
                     
                    if(depositedTokens[account] == 0){
                        
                        if( maxDepositedTokens[account].mul(percent_claim).div(100) > pendingDivs ){
                            toSend = pendingDivs;
                        }else{
                            toSend = maxDepositedTokens[account].mul(percent_claim).div(100);
                        }
                    }
                     rewardEnded[account] = rewardEnded[account].sub(toSend);
                     require(Token(tokenDepositAddress).transfer(account, toSend), "Could not transfer tokens.");
                     totalEarnedTokens[account] = totalEarnedTokens[account].add(toSend);
                     totalClaimedRewards = totalClaimedRewards.add(toSend);
                }
               
            }else{
                
                if(_restake){ // deposit
                    require(pendingDivs <= availablePoolSize, "No spot available");
                    depositedTokens[account] = depositedTokens[account].add(pendingDivs);
                    
                    unclaimed[account] = 0;
                    
                    if(depositedTokens[account] > maxDepositedTokens[account]){
                        maxDepositedTokens[account] = depositedTokens[account];
                    } 
                    availablePoolSize = availablePoolSize.sub(pendingDivs);
                    totalDeposited = totalDeposited.add(pendingDivs);
                    totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
                    totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
                }else if(_withdraw){ // withdraw
                    unclaimed[account] = pendingDivs;
                }else{ // does not have deposited tokens
                    if(depositedTokens[account] == 0){
                        
                        if( maxDepositedTokens[account].mul(percent_claim).div(100) > pendingDivs ){
                            toSend = pendingDivs;
                        }else{
                            toSend = maxDepositedTokens[account].mul(percent_claim).div(100);
                        }
                    }
                    uint toUnclaimed = 0;
                    uint subUnclaimed = 0;
                    uint pendingWithoutUnclaimed = getOnlyPendingRewards(account);
                    if(toSend > pendingWithoutUnclaimed){
                        subUnclaimed = toSend.sub(pendingWithoutUnclaimed);
                        toUnclaimed = 0;
                    }else{
                        toUnclaimed = pendingWithoutUnclaimed.sub(toSend);
                        subUnclaimed = 0;
                    }
                
                    unclaimed[account] = unclaimed[account].add(toUnclaimed).sub(subUnclaimed);
                    require(Token(tokenDepositAddress).transfer(account, toSend), "Could not transfer tokens.");
                    totalEarnedTokens[account] = totalEarnedTokens[account].add(toSend);
                    totalClaimedRewards = totalClaimedRewards.add(toSend);
                }
            }    
        }
        lastClaimedTime[account] = block.timestamp;
        return true;
    }
    
    function getAPY(address _staker) public view returns(uint){

        uint apy = rewardRate;
        if(block.timestamp.sub(firstTime[_staker]) > unstakeTime && alreadyProgUnstaked[_staker] == 0 && !ended){
            apy = apy.add(extraAPY);
        }
        return apy;
    }
    
    function getPendingRewards(address _holder) public view returns (uint) { //getPendingRewards

        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0 && unclaimed[_holder] == 0 && !ended) return 0;
        uint pendingDivs;
        if(!ended){
             uint timeDiff = block.timestamp.sub(lastClaimedTime[_holder]);
             uint stakedAmount = depositedTokens[_holder];
             
             uint apy = getAPY(_holder);
        
             pendingDivs = stakedAmount
                                .mul(apy) 
                                .mul(timeDiff)
                                .div(rewardInterval)
                                .div(1e4);
                                
             pendingDivs = pendingDivs.add(unclaimed[_holder]);
            
        }else{
            pendingDivs = rewardEnded[_holder];
        }
       
        return pendingDivs;
    }
    
    function getOnlyPendingRewards(address _holder) internal view returns (uint) { // getPendingRewards without "Unclaimed"

        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0 || ended) return 0;
        uint pendingDivs;
        if(!ended){
             uint timeDiff = block.timestamp.sub(lastClaimedTime[_holder]);
             uint stakedAmount = depositedTokens[_holder];
             
             uint apy = getAPY(_holder);
        
             pendingDivs = stakedAmount
                                .mul(apy) 
                                .mul(timeDiff)
                                .div(rewardInterval)
                                .div(1e4);
            
        }else{
            pendingDivs = 0;
        }
       
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {

        return holders.length();
    }
    
    function deposit(uint amountToStake) public returns (bool){

        require(!ended, "Staking has ended");
        require(getRewardsLeft() > 0, "No rewards left");
        require(amountToStake > 0, "Cannot deposit 0 Tokens");
       
        require(Token(tokenDepositAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        
        require(updateAccount(msg.sender, true, false), "Error updating account");
        
        uint fee = amountToStake.mul(stakingFeeRate).div(1e4);
        uint amountAfterFee = amountToStake.sub(fee);
        require(amountAfterFee <= availablePoolSize, "No space available");
        require(Token(tokenDepositAddress).transfer(owner, fee), "Could not transfer deposit fee.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        if(depositedTokens[msg.sender] > maxDepositedTokens[msg.sender]){
            maxDepositedTokens[msg.sender] = depositedTokens[msg.sender];
        } 
        availablePoolSize = availablePoolSize.sub(amountAfterFee);
        totalDeposited = totalDeposited.add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            firstTime[msg.sender] = block.timestamp;
            
        }
        
        amountPerInterval[msg.sender] = 0;
        if(alreadyProgUnstaked[msg.sender] > 0){
            firstTime[msg.sender] = block.timestamp;
        } 
        
        alreadyProgUnstaked[msg.sender] = 0;
        
        stakingTime[msg.sender] = block.timestamp;
        return true;
    }
    
    function getMaxAmountWithdrawable(address _staker) public view returns(uint){

        uint _res = 0;
        if(block.timestamp.sub(stakingTime[msg.sender]) < unstakeTime && !ended && alreadyProgUnstaked[_staker] == 0){
            _res = 0;
        }else if(alreadyProgUnstaked[_staker] == 0 && !ended){
            
            if(block.timestamp.sub(stakingTime[msg.sender]) > unstakeTime){
                _res = depositedTokens[_staker].div(number_intervals);
            }
          
        }else{
            uint _time = progressiveTime[_staker];
            
            if(block.timestamp < _time.add(duration_interval)){
                _res = 0;
            }else{
               
                
                uint _numIntervals = (block.timestamp.sub(_time)).div(duration_interval);
                
                if(_numIntervals == 0){
                    return 0;
                }
                if(!ended){
                    _numIntervals = _numIntervals.add(1);
                }
                
                
                if(_numIntervals > number_intervals){
                    _numIntervals = number_intervals;
                }
                
                if(_numIntervals.mul(amountPerInterval[_staker]) > alreadyProgUnstaked[_staker]){
                    _res = _numIntervals.mul(amountPerInterval[_staker]).sub(alreadyProgUnstaked[_staker]);
                }else{
                    _res = 0;
                }
            }
            
            
        }

        return _res;
    }
    
    function withdraw2(uint amountToWithdraw) public returns (bool){

        require(holders.contains(msg.sender), "Not a staker");
        require(amountToWithdraw <= getMaxAmountWithdrawable(msg.sender), "Maximum reached");
        require(alreadyProgUnstaked[msg.sender] > 0 || ended, "Use withdraw first");
        
        alreadyProgUnstaked[msg.sender] = alreadyProgUnstaked[msg.sender].add(amountToWithdraw);
        
        uint fee = amountToWithdraw.mul(unstakingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        updateAccount(msg.sender, false, true);
        
        require(Token(tokenDepositAddress).transfer(owner, fee), "Could not transfer withdraw fee.");
        require(Token(tokenDepositAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        availablePoolSize = availablePoolSize.add(amountToWithdraw);
        totalDeposited = totalDeposited.sub(amountToWithdraw);
        
        if (holders.contains(msg.sender) && depositedTokens[msg.sender] == 0 && getPendingRewards(msg.sender) == 0) {
            holders.remove(msg.sender);
            firstTime[msg.sender] = 0;
        }
        return true;
    }
    
    function withdraw(uint amountToWithdraw) public returns (bool){

        require(holders.contains(msg.sender), "Not a staker");
        require(alreadyProgUnstaked[msg.sender] == 0 && !ended , "Use withdraw2 function");
        amountPerInterval[msg.sender] = depositedTokens[msg.sender].div(number_intervals);
        require(depositedTokens[msg.sender].div(number_intervals) >= amountToWithdraw, "Invalid amount to withdraw");
        alreadyProgUnstaked[msg.sender] = amountToWithdraw;
        require(block.timestamp.sub(stakingTime[msg.sender]) > unstakeTime || ended, "You recently staked, please wait before withdrawing.");
        
        
        
        updateAccount(msg.sender, false, true);
        
        uint fee = amountToWithdraw.mul(unstakingFeeRate).div(1e4);
        uint amountAfterFee = amountToWithdraw.sub(fee);
        
        require(Token(tokenDepositAddress).transfer(owner, fee), "Could not transfer withdraw fee.");
        require(Token(tokenDepositAddress).transfer(msg.sender, amountAfterFee), "Could not transfer tokens.");
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].sub(amountToWithdraw);
        availablePoolSize = availablePoolSize.add(amountToWithdraw);
        totalDeposited = totalDeposited.sub(amountToWithdraw);
        
        progressiveTime[msg.sender] = block.timestamp;
    
        return true;
    }
    
    function getTimeToWithdraw(address _staker) public view returns (uint){

        if(getMaxAmountWithdrawable(_staker) != 0) return 0;
        
        uint _res = 0;
        uint _time = stakingTime[_staker];
        if(alreadyProgUnstaked[_staker] == 0 && !ended ){
            
            if(block.timestamp <= _time.add(unstakeTime)){
                _res = _time.add(unstakeTime).sub(block.timestamp);
            }
            
        }else{
            _time = progressiveTime[_staker];
            
            for(uint i = 1; i <= number_intervals; i = i.add(1)){
                if(block.timestamp < _time.add(duration_interval.mul(i))){
                    _res = _time.add(duration_interval.mul(i)).sub(block.timestamp);
                    break;
                }
            }
            
        }
        return _res;
    }
    
    function getTimeToClaim(address _staker) public view returns (uint){

        uint _res = 0;
        
        if(lastClaimedTime[_staker].add(claimTime) > block.timestamp){
            _res = lastClaimedTime[_staker].add(claimTime).sub(block.timestamp);
        }
        
        return _res;
    }
    
    function claimDivs() public  returns (bool){

        require(holders.contains(msg.sender), "Not a staker");
        require(block.timestamp.sub(lastClaimedTime[msg.sender]) > claimTime, "Not yet");
        updateAccount(msg.sender, false, false);
        return true;
    }
    
    function getStakersList(uint startIndex, uint endIndex) public view returns (address[] memory stakers, uint[] memory stakingTimestamps,  uint[] memory lastClaimedTimeStamps, uint[] memory stakedTokens) {

        require (startIndex < endIndex);
        
        uint length = endIndex.sub(startIndex);
        address[] memory _stakers = new address[](length);
        uint[] memory _stakingTimestamps = new uint[](length);
        uint[] memory _lastClaimedTimeStamps = new uint[](length);
        uint[] memory _stakedTokens = new uint[](length);
        
        for (uint i = startIndex; i < endIndex; i = i.add(1)) {
            address staker = holders.at(i);
            uint listIndex = i.sub(startIndex);
            _stakers[listIndex] = staker;
            _stakingTimestamps[listIndex] = stakingTime[staker];
            _lastClaimedTimeStamps[listIndex] = lastClaimedTime[staker];
            _stakedTokens[listIndex] = depositedTokens[staker];
        }
        
        return (_stakers, _stakingTimestamps, _lastClaimedTimeStamps, _stakedTokens);
    }
    
    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner  returns (bool){

        require (_tokenAddr != tokenDepositAddress, "Cannot Transfer Out this token");
        Token(_tokenAddr).transfer(_to, _amount);
        return true;
    }
    
    function getClaimableAmount(address account) public view returns (uint){

        uint pendingDivs = getPendingRewards(account);
        uint toSend = pendingDivs;
        
        if(depositedTokens[account].mul(percent_claim).div(100) < pendingDivs){
            toSend = depositedTokens[account].mul(percent_claim).div(100);
        }
        
        if (pendingDivs > 0) {
            if(ended){ // claim o withdraw cuando ha terminado
                    if(depositedTokens[account] == 0){
                        
                        if( maxDepositedTokens[account].mul(percent_claim).div(100) > pendingDivs ){
                            toSend = pendingDivs;
                        }else{
                            toSend = maxDepositedTokens[account].mul(percent_claim).div(100);
                        }
                    }
                
            }else{
                if(depositedTokens[account] == 0){
                        
                    if( maxDepositedTokens[account].mul(percent_claim).div(100) > pendingDivs ){
                        toSend = pendingDivs;
                    }else{
                        toSend = maxDepositedTokens[account].mul(percent_claim).div(100);
                    }
                }
            }    
        }
        return toSend;
    }
    
}