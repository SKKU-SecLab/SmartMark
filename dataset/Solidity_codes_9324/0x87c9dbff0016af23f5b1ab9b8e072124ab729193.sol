

pragma solidity ^0.4.24;

interface ERC20 {


    function totalSupply() public view returns (uint);

    function balanceOf(address owner) public view returns (uint);

    function allowance(address owner, address spender) public view returns (uint);

    function transfer(address to, uint value) public returns (bool);

    function transferFrom(address from, address to, uint value) public returns (bool);

    function approve(address spender, uint value) public returns (bool);


}


pragma solidity ^0.4.24;

contract Ownable {


    address public owner;

    modifier onlyOwner {

        require(isOwner(msg.sender));
        _;
    }

    function Ownable() public {

        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) public onlyOwner {

        owner = _newOwner;
    }

    function isOwner(address _address) public view returns (bool) {

        return owner == _address;
    }
}


pragma solidity ^0.4.24;

library SafeMath {


    function mul(uint a, uint b) internal pure returns (uint) {

        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint a, uint b) internal pure returns (uint) {

        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {

        assert(b <= a);
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {

        uint c = a + b;
        assert(c >= a);
        return c;
    }

    function max64(uint64 a, uint64 b) internal pure returns (uint64) {

        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {

        return a < b ? a : b;
    }

    function max256(uint a, uint b) internal pure returns (uint) {

        return a >= b ? a : b;
    }

    function min256(uint a, uint b) internal pure returns (uint) {

        return a < b ? a : b;
    }
}


pragma solidity ^0.4.24;


contract Pausable is Ownable {

  event Pause();
  event Unpause();

  bool public paused = false;


  modifier whenNotPaused() {

    require(!paused);
    _;
  }

  modifier whenPaused() {

    require(paused);
    _;
  }

  function pause() onlyOwner whenNotPaused public {

    paused = true;
    emit Pause();
  }

  function unpause() onlyOwner whenPaused public {

    paused = false;
    emit Unpause();
  }
}


pragma solidity ^0.4.24;



contract Whitelist is Ownable {

  mapping(address => bool) public whitelist;

  event WhitelistedAddressAdded(address addr);
  event WhitelistedAddressRemoved(address addr);

  modifier onlyWhitelisted() {

    require(whitelist[msg.sender]);
    _;
  }

  function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {

    if (!whitelist[addr]) {
      whitelist[addr] = true;
      emit WhitelistedAddressAdded(addr);
      success = true;
    }
  }

  function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {

    for (uint256 i = 0; i < addrs.length; i++) {
      if (addAddressToWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {

    if (whitelist[addr]) {
      whitelist[addr] = false;
      emit WhitelistedAddressRemoved(addr);
      success = true;
    }
  }

  function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {

    for (uint256 i = 0; i < addrs.length; i++) {
      if (removeAddressFromWhitelist(addrs[i])) {
        success = true;
      }
    }
  }

}


pragma solidity ^0.4.24;






contract Staking is Pausable, Whitelist {

    using SafeMath for uint256;

    event BucketCreated(uint256 bucketIndex, bytes12 canName, uint256 amount, uint256 stakeDuration, bool nonDecay, bytes data);
    event BucketUpdated(uint256 bucketIndex, bytes12 canName, uint256 stakeDuration, uint256 stakeStartTime, bool nonDecay, address bucketOwner, bytes data);
    event BucketUnstake(uint256 bucketIndex, bytes12 canName, uint256 amount, bytes data);
    event BucketWithdraw(uint256 bucketIndex, bytes12 canName, uint256 amount, bytes data);

    ERC20 stakingToken;

    uint256 public constant minStakeDuration = 0;
    uint256 public constant maxStakeDuration = 350;
    uint256 public constant minStakeAmount = 100 * 10 ** 18;
    uint256 public constant unStakeDuration = 3;

    uint256 public constant maxBucketsPerAddr = 500;
    uint256 public constant secondsPerEpoch = 86400;

    struct Bucket {
        bytes12 canName;            // Candidate name, which maps to public keys by NameRegistration.sol
        uint256 stakedAmount;       // Number of tokens
        uint256 stakeDuration;      // Stake duration, unit: second since epoch
        uint256 stakeStartTime;     // Staking start time, unit: second since epoch
        bool nonDecay;              // Nondecay staking -- staking for N epochs consistently without decaying
        uint256 unstakeStartTime;   // unstake timestamp, unit: second since epoch
        address bucketOwner;        // Owner of this bucket, usually the one who created it but can be someone else
        uint256 createTime;         // bucket firstly create time
        uint256 prev;               // Prev non-zero bucket index
        uint256 next;               // Next non-zero bucket index
    }
    mapping(uint256 => Bucket) public buckets;
    uint256 bucketCount; // number of total buckets. used to track the last used index for the bucket

    mapping(address => uint256[]) public stakeholders;

    modifier canTouchBucket(address _address, uint256 _bucketIndex) {

        require(_address != address(0));
        require(buckets[_bucketIndex].bucketOwner == msg.sender, "sender is not the owner.");
        _;
    }

    modifier checkStakeDuration(uint256 _duration) {

        require(_duration >= minStakeDuration && _duration <= maxStakeDuration, "The stake duration is too small or large");
        require(_duration % 7 == 0, "The stake duration should be multiple of 7");
        _;
    }

    constructor(address _stakingTokenAddr) public {
        stakingToken = ERC20(_stakingTokenAddr);
        buckets[0] = Bucket("", 1, 0, block.timestamp, true, 0, msg.sender, block.timestamp, 0, 0);
        stakeholders[msg.sender].push(0);
        bucketCount = 1;
    }

    function getActiveBucketIdxImpl(uint256 _prevIndex, uint256 _limit) internal returns(uint256 count, uint256[] indexes) {

        require (_limit > 0 && _limit < 5000);
        Bucket memory bucket = buckets[_prevIndex];
        require(bucket.next > 0, "cannot find bucket based on input index.");

        indexes = new uint256[](_limit);
        uint256 i = 0;
        for (i = 0; i < _limit; i++) {
            while (bucket.next > 0 && buckets[bucket.next].unstakeStartTime > 0) { // unstaked.
                bucket = buckets[bucket.next]; // skip
            }
            if (bucket.next == 0) { // no new bucket
                break;
            }
            indexes[i] = bucket.next;
            bucket = buckets[bucket.next];
        }
        return (i, indexes);
    }

    function getActiveBucketIdx(uint256 _prevIndex, uint256 _limit) external view returns(uint256 count, uint256[] indexes) {

        return getActiveBucketIdxImpl(_prevIndex, _limit);
    }

    function getActiveBuckets(uint256 _prevIndex, uint256 _limit) external view returns(uint256 count,
            uint256[] indexes, uint256[] stakeStartTimes, uint256[] stakeDurations, bool[] decays, uint256[] stakedAmounts, bytes12[] canNames, address[] owners) {


        (count, indexes) = getActiveBucketIdxImpl(_prevIndex, _limit);
        stakeStartTimes = new uint256[](count);
        stakeDurations = new uint256[](count);
        decays = new bool[](count);
        stakedAmounts = new uint256[](count);
        canNames = new bytes12[](count);
        owners = new address[](count);

        for (uint256 i = 0; i < count; i++) {
            Bucket memory bucket = buckets[indexes[i]];
            stakeStartTimes[i] = bucket.stakeStartTime;
            stakeDurations[i] = bucket.stakeDuration;
            decays[i] = !bucket.nonDecay;
            stakedAmounts[i] = bucket.stakedAmount;
            canNames[i] = bucket.canName;
            owners[i] = bucket.bucketOwner;

        }

        return (count, indexes, stakeStartTimes, stakeDurations, decays, stakedAmounts, canNames, owners);
    }


    function getActiveBucketCreateTimes(uint256 _prevIndex, uint256 _limit) external view returns(uint256 count,
            uint256[] indexes, uint256[] createTimes) {

        (count, indexes) = getActiveBucketIdxImpl(_prevIndex, _limit);
        createTimes = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            createTimes[i] = buckets[indexes[i]].createTime;
        }
        return (count, indexes, createTimes);
    }

    function getBucketIndexesByAddress(address _owner) external view returns(uint256[]) {

        return stakeholders[_owner];
    }

    function restake(uint256 _bucketIndex, uint256 _stakeDuration, bool _nonDecay, bytes _data)
            external whenNotPaused canTouchBucket(msg.sender, _bucketIndex) checkStakeDuration(_stakeDuration) {

        require(block.timestamp.add(_stakeDuration * secondsPerEpoch) >=
                buckets[_bucketIndex].stakeStartTime.add(buckets[_bucketIndex].stakeDuration * secondsPerEpoch),
                "current stake duration not finished.");
        if (buckets[_bucketIndex].nonDecay) {
          require(_stakeDuration >= buckets[_bucketIndex].stakeDuration, "cannot reduce the stake duration.");
        }
        buckets[_bucketIndex].stakeDuration = _stakeDuration;
        buckets[_bucketIndex].stakeStartTime = block.timestamp;
        buckets[_bucketIndex].nonDecay = _nonDecay;
        buckets[_bucketIndex].unstakeStartTime = 0;
        emitBucketUpdated(_bucketIndex, _data);
    }

    function revote(uint256 _bucketIndex, bytes12 _canName, bytes _data)
            external whenNotPaused canTouchBucket(msg.sender, _bucketIndex) {

        require(buckets[_bucketIndex].unstakeStartTime == 0, "cannot revote during unstaking.");
        buckets[_bucketIndex].canName = _canName;
        emitBucketUpdated(_bucketIndex, _data);
    }

    function setBucketOwner(uint256 _bucketIndex, address _newOwner, bytes _data)
            external whenNotPaused onlyWhitelisted canTouchBucket(msg.sender, _bucketIndex) {

        removeBucketIndex(_bucketIndex);
        buckets[_bucketIndex].bucketOwner = _newOwner;
        stakeholders[_newOwner].push(_bucketIndex);
        emitBucketUpdated(_bucketIndex, _data);
    }

    function unstake(uint256 _bucketIndex, bytes _data)
            external whenNotPaused canTouchBucket(msg.sender, _bucketIndex) {

        require(_bucketIndex > 0, "bucket 0 cannot be unstaked and withdrawn.");
        require(!buckets[_bucketIndex].nonDecay, "Cannot unstake with nonDecay flag. Need to disable non-decay mode first.");
        require(buckets[_bucketIndex].stakeStartTime.add(buckets[_bucketIndex].stakeDuration * secondsPerEpoch) <= block.timestamp,
            "Staking time does not expire yet. Please wait until staking expires.");
        require(buckets[_bucketIndex].unstakeStartTime == 0, "Unstaked already. No need to unstake again.");
        buckets[_bucketIndex].unstakeStartTime = block.timestamp;
        emit BucketUnstake(_bucketIndex, buckets[_bucketIndex].canName, buckets[_bucketIndex].stakedAmount, _data);
    }

    function withdraw(uint256 _bucketIndex, bytes _data)
            external whenNotPaused canTouchBucket(msg.sender, _bucketIndex) {

        require(buckets[_bucketIndex].unstakeStartTime > 0, "Please unstake first before withdraw.");
        require(
            buckets[_bucketIndex].unstakeStartTime.add(unStakeDuration * secondsPerEpoch) <= block.timestamp,
            "Stakeholder needs to wait for 3 days before withdrawing tokens.");

        uint256 prev = buckets[_bucketIndex].prev;
        uint256 next = buckets[_bucketIndex].next;
        buckets[prev].next = next;
        buckets[next].prev = prev;

        uint256 amount = buckets[_bucketIndex].stakedAmount;
        bytes12 canName = buckets[_bucketIndex].canName;
        address bucketowner = buckets[_bucketIndex].bucketOwner;
        buckets[_bucketIndex].stakedAmount = 0;
        removeBucketIndex(_bucketIndex);
        delete buckets[_bucketIndex];

        require(stakingToken.transfer(bucketowner, amount), "Unable to withdraw stake");
        emit BucketWithdraw(_bucketIndex, canName, amount, _data);
    }

    function totalStaked() public view returns (uint256) {

        return stakingToken.balanceOf(this);
    }

    function token() public view returns(address) {

        return stakingToken;
    }

    function emitBucketUpdated(uint256 _bucketIndex, bytes _data) internal {

        Bucket memory b = buckets[_bucketIndex];
        emit BucketUpdated(_bucketIndex, b.canName, b.stakeDuration, b.stakeStartTime, b.nonDecay, b.bucketOwner, _data);
    }

    function createBucket(bytes12 _canName, uint256 _amount, uint256 _stakeDuration, bool _nonDecay, bytes _data)
            external whenNotPaused checkStakeDuration(_stakeDuration) returns (uint256) {

        require(_amount >= minStakeAmount, "amount should >= 100.");
        require(stakeholders[msg.sender].length <= maxBucketsPerAddr, "One address can have up limited buckets");
        require(stakingToken.transferFrom(msg.sender, this, _amount), "Stake required"); // transfer token to contract
        buckets[bucketCount] = Bucket(_canName, _amount, _stakeDuration, block.timestamp, _nonDecay, 0, msg.sender, block.timestamp, buckets[0].prev, 0);
        buckets[buckets[0].prev].next = bucketCount;
        buckets[0].prev = bucketCount;
        stakeholders[msg.sender].push(bucketCount);
        bucketCount++;
        emit BucketCreated(bucketCount-1, _canName, _amount, _stakeDuration, _nonDecay, _data);
        return bucketCount-1;
    }

    function removeBucketIndex(uint256 _bucketidx) internal {

        address owner = buckets[_bucketidx].bucketOwner;
        require(stakeholders[owner].length > 0, "Expect the owner has at least one bucket index");

        uint256 i = 0;
        for (; i < stakeholders[owner].length; i++) {
          if(stakeholders[owner][i] == _bucketidx) {
                break;
          }
        }
        for (; i < stakeholders[owner].length - 1; i++) {
          stakeholders[owner][i] = stakeholders[owner][i + 1];
        }
        stakeholders[owner].length--;
    }
}