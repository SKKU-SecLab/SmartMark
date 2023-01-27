

pragma solidity 0.7.6;

library SafeMath {

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);
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
}

interface ERC20 {

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);

}

contract LockTokens {

    using SafeMath for uint256;

    struct Lock {
        uint256 lockID;
        address createdBy;
        address tokenAddress;
        address ownerAddress;
        uint256 amount;
        uint256 unlockedAtTime;
        uint256 lockCreatedAtTime;
        bool hasWithdrawn;
    }

    address public owner;
    address payable private feeCollector; //address for fees

    uint256 public ethFeePerLock; //eth fee per address that a vest is created for
    mapping(address => bool) addressExemptFromFee; //addresses not charged fee
    mapping(address => bool) public feeExemptToken; // map if holding a token provides fee exemption
    mapping(address => uint256) public tokenBalanceThreshold; // map token to required balance for fee exemption

    uint256 public lockID; //current id
    mapping (uint256 => Lock) public tokenLocked; // map id to lock parameters

    mapping (address => uint256[]) public locksCreatedByAddress;
    mapping (address => uint256[]) public locksOwnedByAddress;
    mapping (address => uint256[]) public locksByTokenAddress;
    
    uint256 private constant functionCalled = 1;
    uint256 private constant functionComplete = 2;
    uint256 private status;

    constructor(){
        owner = msg.sender;
        ethFeePerLock = 1e16;
    }

    modifier ReEntrancyGuard {

        require(status != functionCalled);
        status = functionCalled;
        _;
        status = functionComplete;
    }

    modifier onlyOwner {

        require(msg.sender == owner);
        _;
    }

    event TokensLocked(address TokenAddress, address LockCreator, address LockOwner, uint256 Amount,uint256 UnlockedAtTime);
    event TokensWithdrawn(uint256 LockID, address WithdrawnBy, uint256 Amount);
    event LockExtended(uint256 LockID, uint256 PreviousUnlockTime, uint256 NewUnlockTime);
    event LockOwnershipTransferred(uint256 LockID, address PreviousOwner, address NewOwner);
    event LockBalanceIncreased(address Supplier,uint256 LockID,uint256 Amount);

    function lockTokens(address _tokenExemption, address _tokenAddress,address _ownerAddress,uint256 _amount,uint256 _unlockedAtTime) public payable ReEntrancyGuard{

        bool takeFee = true;
        if(addressExemptFromFee[msg.sender] || (feeExemptToken[_tokenExemption] && (ERC20(_tokenExemption).balanceOf(msg.sender) >= tokenBalanceThreshold[_tokenExemption]))){
             takeFee = false;
        }
        if(takeFee) require(msg.value == ethFeePerLock, "Fee amount invalid");
        require(_amount > 0, "Must be more than 0");
        require(ERC20(_tokenAddress).balanceOf(msg.sender)>= _amount, "Insuffecient balance");
        require(ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount), "Transfer failed");
        uint256 _thisLockID = ++lockID;
        locksCreatedByAddress[msg.sender].push(_thisLockID);
        locksOwnedByAddress[_ownerAddress].push(_thisLockID);
        locksByTokenAddress[_tokenAddress].push(_thisLockID);
        Lock memory lock = Lock(_thisLockID, msg.sender, _tokenAddress, _ownerAddress, _amount, _unlockedAtTime, block.timestamp, false);
        tokenLocked[_thisLockID] = lock;

        emit TokensLocked(_tokenAddress, msg.sender, _ownerAddress, _amount, _unlockedAtTime);
    }

    function createVest(address _tokenExemption, address _tokenAddress, address[] calldata _vestOwnersAddresses, uint256 _totalAmount, uint256[] calldata _unlockTimes, uint256[] calldata _unlockAmounts) public payable ReEntrancyGuard {

        bool takeFee = true;
        if(addressExemptFromFee[msg.sender] || (feeExemptToken[_tokenExemption] && (ERC20(_tokenExemption).balanceOf(msg.sender) >= tokenBalanceThreshold[_tokenExemption]))){
             takeFee = false;
        }
        uint256 feeCost = ethFeePerLock.mul(_vestOwnersAddresses.length);
        if(takeFee) require(msg.value == feeCost, "Fee amount invalid");

        require(_unlockTimes.length == _unlockAmounts.length, "Array sizes must match");
        
        uint256 _sumOfUnlockAmounts;
        for(uint256 i = 0; i < _unlockAmounts.length; i++){
            _sumOfUnlockAmounts += _unlockAmounts[i];
        }
        uint256 _totalVestAmount = _sumOfUnlockAmounts.mul(_vestOwnersAddresses.length);
        require(_totalAmount > 0 && _totalAmount == _totalVestAmount, "Invalid amount input");

        require(ERC20(_tokenAddress).balanceOf(msg.sender) >= _totalAmount, "Insufficient balance");
        require(ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _totalAmount), "Transfer failed");

        for(uint256 i = 0; i < _vestOwnersAddresses.length; i++){
            for(uint256 j = 0; j < _unlockTimes.length; j++){
                _lockTokens(msg.sender, _tokenAddress, _vestOwnersAddresses[i], _unlockAmounts[j], _unlockTimes[j]);
                emit TokensLocked(_tokenAddress, msg.sender, _vestOwnersAddresses[i], _unlockAmounts[j], _unlockTimes[j]);
          }
        }                
    }

    function _lockTokens(address _createdBy, address _tokenAddress, address _ownerAddress, uint256 _amount, uint256 _unlockedAtTime) private {

        uint256 _thisLockID = ++lockID;
        locksCreatedByAddress[msg.sender].push(_thisLockID);
        locksOwnedByAddress[_ownerAddress].push(_thisLockID);
        locksByTokenAddress[_tokenAddress].push(_thisLockID);
        Lock memory lock = Lock(_thisLockID, _createdBy, _tokenAddress, _ownerAddress, _amount, _unlockedAtTime, block.timestamp, false);
        tokenLocked[_thisLockID] = lock;
    }

    function withdrawAllTokens(uint256 _lockID) public ReEntrancyGuard {

        require(block.timestamp >= tokenLocked[_lockID].unlockedAtTime, "Timed lock has not expired");
        require(msg.sender == tokenLocked[_lockID].ownerAddress, "Not authorized to withdraw");
        require(!tokenLocked[_lockID].hasWithdrawn, "Lock already withdrawn");        
        require(ERC20(tokenLocked[_lockID].tokenAddress).transfer(msg.sender, tokenLocked[_lockID].amount), "Tokens not withdrawn");

        tokenLocked[_lockID].hasWithdrawn = true;

        emit TokensWithdrawn(_lockID, msg.sender, tokenLocked[_lockID].amount);
    }

    function extendLock(uint256 _lockID, uint256 _newUnlockTime) public ReEntrancyGuard{

        require(msg.sender == tokenLocked[_lockID].ownerAddress);
        require(_newUnlockTime > tokenLocked[_lockID].unlockedAtTime);
            
        uint256 previousUnlockAtTime = tokenLocked[_lockID].unlockedAtTime;
        tokenLocked[_lockID].unlockedAtTime = _newUnlockTime;

        emit LockExtended(_lockID, previousUnlockAtTime, _newUnlockTime);
    }

    function addToLock(uint256 _lockID, address _tokenAddress, uint256 _amount) public ReEntrancyGuard{

        require(_amount > 0, "Invalid amount");
        require(tokenLocked[_lockID].unlockedAtTime > block.timestamp, "Lock has expired");
        require(tokenLocked[_lockID].tokenAddress == _tokenAddress, "Token not held in lock");
        require(ERC20(_tokenAddress).balanceOf(msg.sender) >= _amount, "Insuffecient balance");
        require(ERC20(_tokenAddress).approve(address(this), _amount), "Must approve to transfer");
        require(ERC20(_tokenAddress).transferFrom(msg.sender, address(this), _amount), "Tokens not transferred");

        tokenLocked[_lockID].amount = tokenLocked[_lockID].amount.add(_amount);

        emit LockBalanceIncreased(msg.sender, _lockID, _amount);
    }


    function getTokenLockInformation(uint256 _lockID) view external returns(address, address, uint256, uint256, uint256, bool){

        return(tokenLocked[_lockID].tokenAddress,tokenLocked[_lockID].ownerAddress,tokenLocked[_lockID].amount,tokenLocked[_lockID].unlockedAtTime,tokenLocked[_lockID].lockCreatedAtTime,tokenLocked[_lockID].hasWithdrawn);
    }

    function getTokenLocksCreatedByAddress(address _locksCreatedByAddress) view external returns( uint256[] memory){

        return locksCreatedByAddress[_locksCreatedByAddress];
    }

    function getLockedTokensOwnedByAddress(address _locksOwnedByAddress) view external returns(uint256[] memory){

        return locksOwnedByAddress[_locksOwnedByAddress];
    }
    function getLockedTokensByTokenAddress(address _tokenAddress) view external returns(uint256[] memory){

        return locksByTokenAddress[_tokenAddress];
    }

    function transferVestOwnerShip(uint256 _lockID, address _newOwner) external {

        require(msg.sender == tokenLocked[_lockID].ownerAddress, "Not owner");
        tokenLocked[_lockID].ownerAddress = _newOwner;
        emit LockOwnershipTransferred(_lockID, msg.sender, _newOwner);
    }

    function setFeeCollectorWallet(address payable _feeCollector) external onlyOwner{

        feeCollector = _feeCollector;
    }

    function setETHFee(uint256 _fee) external onlyOwner{

        ethFeePerLock = _fee;
    }

    function getTime() external view returns(uint256){

        return block.timestamp;
    }

    function transferContracOwnership(address _newOwner) external onlyOwner{

        owner = _newOwner;
    }
}