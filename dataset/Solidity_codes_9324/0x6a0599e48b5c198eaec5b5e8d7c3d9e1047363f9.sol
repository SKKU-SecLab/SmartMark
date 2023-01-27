
pragma solidity 0.6.11;


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

        return _add(set._inner, bytes32(uint256(value)));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(value)));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(value)));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint256(_at(set._inner, index)));
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


  constructor() public {
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

    function burn(uint) external;

}

contract Staking is Ownable {

    using SafeMath for uint;
    using EnumerableSet for EnumerableSet.AddressSet;
    
    event RewardsTransferred(address holder, uint amount);
    
    address public constant trustedStakeTokenAddress = 0x9B1913fb1f3bE42632AAf49c6a00EC77b0e5767b;
    address public constant trustedRewardTokenAddress = trustedStakeTokenAddress;
    
    uint public rewardRatePercentX100 = 200e2;
    uint public constant rewardInterval = 100 days;
    
    uint public totalClaimedRewards = 0;
    
    
    EnumerableSet.AddressSet private holders;
    
    mapping (address => uint) public depositedTokens;
    mapping (address => uint) public stakingTime;
    mapping (address => uint) public lastClaimedTime;
    mapping (address => uint) public totalEarnedTokens;
    
    
    mapping (address => address) public referrals;
    mapping (address => uint) public totalReferralFeeEarned;
    
    
    function updateAccount(address account) private {

        uint pendingDivs = getPendingDivs(account);
        if (pendingDivs > 0) {
            uint _2Percent = pendingDivs.mul(2e2).div(100e2);
            Token(trustedRewardTokenAddress).burn(_2Percent);
            uint _3Percent = pendingDivs.mul(3e2).div(100e2);
            require(Token(trustedRewardTokenAddress).transfer(owner, _3Percent), "Could not transfer fee!");
            require(Token(trustedRewardTokenAddress).transfer(account, pendingDivs), "Could not transfer tokens.");
            
            uint _amountToDeduct = pendingDivs.div(2);
            if (depositedTokens[account] < _amountToDeduct) {
                _amountToDeduct = depositedTokens[account];
            }
            depositedTokens[account] = depositedTokens[account].sub(pendingDivs.div(2));
            
            totalEarnedTokens[account] = totalEarnedTokens[account].add(pendingDivs);
            totalClaimedRewards = totalClaimedRewards.add(pendingDivs);
            emit RewardsTransferred(account, pendingDivs);
        }
        lastClaimedTime[account] = now;
    }
    
    function getPendingDivs(address _holder) public view returns (uint) {

        if (!holders.contains(_holder)) return 0;
        if (depositedTokens[_holder] == 0) return 0;
        
        uint timeDiff;
        
        timeDiff = now.sub(lastClaimedTime[_holder]);
        
        uint stakedAmount = depositedTokens[_holder];
        
        uint pendingDivs = stakedAmount
                            .mul(rewardRatePercentX100)
                            .mul(timeDiff)
                            .div(rewardInterval)
                            .div(1e4);
                            
        uint _200Percent = stakedAmount.mul(2);
        
        if (pendingDivs > _200Percent) {
            pendingDivs = _200Percent;
        }
            
        return pendingDivs;
    }
    
    function getNumberOfHolders() public view returns (uint) {

        return holders.length();
    }
    
    
    function stake(uint amountToStake, address referrer) public {

        require(amountToStake > 0, "Cannot stake 0 Tokens");
        require(Token(trustedStakeTokenAddress).transferFrom(msg.sender, address(this), amountToStake), "Insufficient Token Allowance");
        
        updateAccount(msg.sender);
        
        uint _2Percent = amountToStake.mul(2e2).div(100e2);
        uint amountAfterFee = amountToStake;
        
        Token(trustedStakeTokenAddress).burn(_2Percent);
        
        
        depositedTokens[msg.sender] = depositedTokens[msg.sender].add(amountAfterFee);
        
        if (!holders.contains(msg.sender)) {
            holders.add(msg.sender);
            stakingTime[msg.sender] = now;
            
            referrals[msg.sender] = referrer;
        }
        
        disburseReferralFee(msg.sender, amountToStake);
    }
    
    function disburseReferralFee(address account, uint amount) private {

        address l1 = referrals[account];
        address l2 = referrals[l1];
        address l3 = referrals[l2];
        
        uint _1Percent = amount.mul(1e2).div(100e2);
        uint _2Percent = amount.mul(2e2).div(100e2);
        uint _3Percent = amount.mul(3e2).div(100e2);
        
        transferReferralFeeIfPossible(l1, _3Percent);
        transferReferralFeeIfPossible(l2, _2Percent);
        transferReferralFeeIfPossible(l3, _1Percent);
    }
    
    function transferReferralFeeIfPossible(address account, uint amount) private {

        if (account != address(0) && amount > 0) {
            totalReferralFeeEarned[account] = totalReferralFeeEarned[account].add(amount);
            require(Token(trustedRewardTokenAddress).transfer(account, amount), "Could not transfer referral fee!");
        }
    }

    
    function claim() public {

        updateAccount(msg.sender);
    }
    
    function getStakersList(uint startIndex, uint endIndex) 
        public 
        view 
        returns (address[] memory stakers, 
            uint[] memory stakingTimestamps, 
            uint[] memory lastClaimedTimeStamps,
            uint[] memory stakedTokens) {

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

    function transferAnyERC20Tokens(address _tokenAddr, address _to, uint _amount) public onlyOwner {

        require(_tokenAddr != trustedStakeTokenAddress, "Admin cannot transfer out Stake Tokens from this contract!");
        
        require((_tokenAddr != trustedRewardTokenAddress), "Admin cannot Transfer out Reward Tokens!");
        
        Token(_tokenAddr).transfer(_to, _amount);
    }
}