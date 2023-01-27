

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


pragma solidity ^0.5.13;


contract StakingAsset is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

}


pragma solidity ^0.5.13;


interface RegistryClone {

    function syncAttributeValue(address _who, bytes32 _attribute, uint256 _value) external;

}

contract Registry {

    struct AttributeData {
        uint256 value;
        bytes32 notes;
        address adminAddr;
        uint256 timestamp;
    }
    
    address public owner;
    address public pendingOwner;
    bool initialized;

    mapping(address => mapping(bytes32 => AttributeData)) attributes;
    bytes32 constant WRITE_PERMISSION = keccak256("canWriteTo-");
    mapping(bytes32 => RegistryClone[]) subscribers;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    event SetAttribute(address indexed who, bytes32 attribute, uint256 value, bytes32 notes, address indexed adminAddr);
    event SetManager(address indexed oldManager, address indexed newManager);
    event StartSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);
    event StopSubscription(bytes32 indexed attribute, RegistryClone indexed subscriber);

    function confirmWrite(bytes32 _attribute, address _admin) internal view returns (bool) {

        return (_admin == owner || hasAttribute(_admin, keccak256(abi.encodePacked(WRITE_PERMISSION ^ _attribute))));
    }

    function setAttribute(address _who, bytes32 _attribute, uint256 _value, bytes32 _notes) public {

        require(confirmWrite(_attribute, msg.sender));
        attributes[_who][_attribute] = AttributeData(_value, _notes, msg.sender, block.timestamp);
        emit SetAttribute(_who, _attribute, _value, _notes, msg.sender);

        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> 0) {
            targets[index].syncAttributeValue(_who, _attribute, _value);
        }
    }

    function subscribe(bytes32 _attribute, RegistryClone _syncer) external onlyOwner {

        subscribers[_attribute].push(_syncer);
        emit StartSubscription(_attribute, _syncer);
    }

    function unsubscribe(bytes32 _attribute, uint256 _index) external onlyOwner {

        uint256 length = subscribers[_attribute].length;
        require(_index < length);
        emit StopSubscription(_attribute, subscribers[_attribute][_index]);
        subscribers[_attribute][_index] = subscribers[_attribute][length - 1];
        subscribers[_attribute].length = length - 1;
    }

    function subscriberCount(bytes32 _attribute) public view returns (uint256) {

        return subscribers[_attribute].length;
    }

    function setAttributeValue(address _who, bytes32 _attribute, uint256 _value) public {

        require(confirmWrite(_attribute, msg.sender));
        attributes[_who][_attribute] = AttributeData(_value, "", msg.sender, block.timestamp);
        emit SetAttribute(_who, _attribute, _value, "", msg.sender);
        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> 0) {
            targets[index].syncAttributeValue(_who, _attribute, _value);
        }
    }

    function hasAttribute(address _who, bytes32 _attribute) public view returns (bool) {

        return attributes[_who][_attribute].value != 0;
    }


    function getAttribute(address _who, bytes32 _attribute) public view returns (uint256, bytes32, address, uint256) {

        AttributeData memory data = attributes[_who][_attribute];
        return (data.value, data.notes, data.adminAddr, data.timestamp);
    }

    function getAttributeValue(address _who, bytes32 _attribute) public view returns (uint256) {

        return attributes[_who][_attribute].value;
    }

    function getAttributeAdminAddr(address _who, bytes32 _attribute) public view returns (address) {

        return attributes[_who][_attribute].adminAddr;
    }

    function getAttributeTimestamp(address _who, bytes32 _attribute) public view returns (uint256) {

        return attributes[_who][_attribute].timestamp;
    }

    function syncAttribute(bytes32 _attribute, uint256 _startIndex, address[] calldata _addresses) external {

        RegistryClone[] storage targets = subscribers[_attribute];
        uint256 index = targets.length;
        while (index --> _startIndex) {
            RegistryClone target = targets[index];
            for (uint256 i = _addresses.length; i --> 0; ) {
                address who = _addresses[i];
                target.syncAttributeValue(who, _attribute, attributes[who][_attribute].value);
            }
        }
    }

    function reclaimEther(address payable _to) external onlyOwner {

        _to.transfer(address(this).balance);
    }

    function reclaimToken(IERC20 token, address _to) external onlyOwner {

        uint256 balance = token.balanceOf(address(this));
        token.transfer(_to, balance);
    }

    modifier onlyOwner() {

        require(msg.sender == owner, "only Owner");
        _;
    }

    modifier onlyPendingOwner() {

        require(msg.sender == pendingOwner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        pendingOwner = newOwner;
    }

    function claimOwnership() public onlyPendingOwner {

        emit OwnershipTransferred(owner, pendingOwner);
        owner = pendingOwner;
        pendingOwner = address(0);
    }
}


pragma solidity ^0.5.13;


contract ProxyStorage {

    bool initalized;
    uint256 public totalSupply;

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    mapping (uint144 => uint256) attributes; // see RegistrySubscriber

    address owner_;
    address pendingOwner_;

}


pragma solidity ^0.5.13;

library ValSafeMath {

    function add(uint256 a, uint256 b, string memory overflowMessage) internal pure returns (uint256 result) {

        result = a + b;
        require(result >= a, overflowMessage);
    }
    function sub(uint256 a, uint256 b, string memory underflowMessage) internal pure returns (uint256 result) {

        require(b <= a, underflowMessage);
        result = a - b;
    }
    function mul(uint256 a, uint256 b, string memory overflowMessage) internal pure returns (uint256 result) {

        if (a == 0) {
            return 0;
        }
        result = a * b;
        require(result / a == b, overflowMessage);
    }
    function div(uint256 a, uint256 b, string memory divideByZeroMessage) internal pure returns (uint256 result) {

        require(b > 0, divideByZeroMessage);
        result = a / b;
    }
}


pragma solidity ^0.5.13;




contract ModularBasicToken is ProxyStorage {

    using ValSafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    function _addBalance(address _who, uint256 _value) internal returns (uint256 priorBalance) {

        priorBalance = balanceOf[_who];
        balanceOf[_who] = priorBalance.add(_value, "balance overflow");
    }

    function _subBalance(address _who, uint256 _value) internal returns (uint256 result) {

        result = balanceOf[_who].sub(_value, "insufficient balance");
        balanceOf[_who] = result;
    }

    function _setBalance(address _who, uint256 _value) internal {

        balanceOf[_who] = _value;
    }
}

contract ModularStandardToken is ModularBasicToken {

    using ValSafeMath for uint256;
    uint256 constant INFINITE_ALLOWANCE = 0xfe00000000000000000000000000000000000000000000000000000000000000;
    
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    function approve(address _spender, uint256 _value) public returns (bool) {

        _approveAllArgs(_spender, _value, msg.sender);
        return true;
    }

    function _approveAllArgs(address _spender, uint256 _value, address _tokenHolder) internal {

        _setAllowance(_tokenHolder, _spender, _value);
        emit Approval(_tokenHolder, _spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {

        _increaseApprovalAllArgs(_spender, _addedValue, msg.sender);
        return true;
    }

    function _increaseApprovalAllArgs(address _spender, uint256 _addedValue, address _tokenHolder) internal {

        _addAllowance(_tokenHolder, _spender, _addedValue);
        emit Approval(_tokenHolder, _spender, allowance[_tokenHolder][_spender]);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {

        _decreaseApprovalAllArgs(_spender, _subtractedValue, msg.sender);
        return true;
    }

    function _decreaseApprovalAllArgs(address _spender, uint256 _subtractedValue, address _tokenHolder) internal {

        uint256 oldValue = allowance[_tokenHolder][_spender];
        uint256 newValue;
        if (_subtractedValue > oldValue) {
            newValue = 0;
        } else {
            newValue = oldValue - _subtractedValue;
        }
        _setAllowance(_tokenHolder, _spender, newValue);
        emit Approval(_tokenHolder,_spender, newValue);
    }

    function _addAllowance(address _who, address _spender, uint256 _value) internal {

        allowance[_who][_spender] = allowance[_who][_spender].add(_value, "allowance overflow");
    }

    function _subAllowance(address _who, address _spender, uint256 _value) internal returns (uint256 newAllowance){

        newAllowance = allowance[_who][_spender].sub(_value, "insufficient allowance");
        if (newAllowance < INFINITE_ALLOWANCE) {
            allowance[_who][_spender] = newAllowance;
        }
    }

    function _setAllowance(address _who, address _spender, uint256 _value) internal {

        allowance[_who][_spender] = _value;
    }
}


pragma solidity ^0.5.13;


contract RegistrySubscriber is ProxyStorage {

    bytes32 constant PASSED_KYCAML = "hasPassedKYC/AML";
    bytes32 constant IS_DEPOSIT_ADDRESS = "isDepositAddress";
    bytes32 constant BLACKLISTED = 0x6973426c61636b6c697374656400000000000000000000000000000000000000;
    bytes32 constant REGISTERED_CONTRACT = 0x697352656769737465726564436f6e7472616374000000000000000000000000;

    uint256 constant ACCOUNT_BLACKLISTED     = 0xff00000000000000000000000000000000000000000000000000000000000000;
    uint256 constant ACCOUNT_BLACKLISTED_INV = 0x00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant ACCOUNT_KYC             = 0x00ff000000000000000000000000000000000000000000000000000000000000;
    uint256 constant ACCOUNT_KYC_INV         = 0xff00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    uint256 constant ACCOUNT_ADDRESS         = 0x000000000000000000000000ffffffffffffffffffffffffffffffffffffffff;
    uint256 constant ACCOUNT_ADDRESS_INV     = 0xffffffffffffffffffffffff0000000000000000000000000000000000000000;
    uint256 constant ACCOUNT_HOOK            = 0x0000ff0000000000000000000000000000000000000000000000000000000000;
    uint256 constant ACCOUNT_HOOK_INV        = 0xffff00ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    function registry() internal view returns (Registry);


    modifier onlyRegistry {

        require(msg.sender == address(registry()));
        _;
    }

    function syncAttributeValue(address _who, bytes32 _attribute, uint256 _value) public onlyRegistry {

        uint144 who = uint144(uint160(_who) >> 20);
        uint256 prior = attributes[who];
        if (prior == 0) {
            prior = uint256(_who);
        }
        if (_attribute == IS_DEPOSIT_ADDRESS) {
            if (address(prior) != address(_value)) {
            }
            attributes[who] = (prior & ACCOUNT_ADDRESS_INV) | uint256(address(_value));
        } else if (_attribute == BLACKLISTED) {
            if (_value != 0) {
                attributes[who] = prior | ACCOUNT_BLACKLISTED;
            } else  {
                attributes[who] = prior & ACCOUNT_BLACKLISTED_INV;
            }
        } else if (_attribute == PASSED_KYCAML) {
            if (_value != 0) {
                attributes[who] = prior | ACCOUNT_KYC;
            } else {
                attributes[who] = prior & ACCOUNT_KYC_INV;
            }
        } else if (_attribute == REGISTERED_CONTRACT) {
            if (_value != 0) {
                attributes[who] = prior | ACCOUNT_HOOK;
            } else {
                attributes[who] = prior & ACCOUNT_HOOK_INV;
            }
        }
    }
}


pragma solidity ^0.5.13;

contract TrueCoinReceiver {

    function tokenFallback( address from, uint256 value ) external;

}


pragma solidity ^0.5.13;




contract ValTokenWithHook is IERC20, ModularStandardToken, RegistrySubscriber {


    event Burn(address indexed from, uint256 indexed amount);
    event Mint(address indexed to, uint256 indexed amount);

    function _resolveRecipient(address _to) internal view returns (address to, bool hook) {

        uint256 flags = (attributes[uint144(uint160(_to) >> 20)]);
        if (flags == 0) {
            to = _to;
            hook = false;
        } else {
            to = address(flags);
            hook = (flags & ACCOUNT_HOOK) != 0;
        }
    }

    modifier resolveSender(address _from) {

        uint256 flags = (attributes[uint144(uint160(_from) >> 20)]);
        address from = address(flags);
        if (from != address(0)) {
            require(from == _from, "account collision");
        }
        _;
    }

    function _transferFromAllArgs(address _from, address _to, uint256 _value, address _spender) internal {

        _subAllowance(_from, _spender, _value);
        _transferAllArgs(_from, _to, _value);
    }
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {

        _transferFromAllArgs(_from, _to, _value, msg.sender);
        return true;
    }
    function transfer(address _to, uint256 _value) external returns (bool) {

        _transferAllArgs(msg.sender, _to, _value);
        return true;
    }
    function _transferAllArgs(address _from, address _to, uint256 _value) internal resolveSender(_from) {

        _subBalance(_from, _value);
        emit Transfer(_from, _to, _value);
        bool hasHook;
        address to;
        (to, hasHook) = _resolveRecipient(_to);
        _addBalance(to, _value);
        if (_to != to) {
            emit Transfer(_to, to, _value);
        }
        if (hasHook) {
            TrueCoinReceiver(to).tokenFallback(_from, _value);
        }
    }

    function _burn(address _from, uint256 _value) internal returns (uint256 resultBalance_, uint256 resultSupply_) {

        emit Transfer(_from, address(0), _value);
        emit Burn(_from, _value);
        resultBalance_ = _subBalance(_from, _value);
        resultSupply_ = totalSupply.sub(_value, "removing more stake than in supply");
        totalSupply = resultSupply_;
    }

    function _mint(address _to, uint256 _value) internal {

        emit Transfer(address(0), _to, _value);
        emit Mint(_to, _value);
        (address to, bool hook) = _resolveRecipient(_to);
        if (_to != to) {
            emit Transfer(_to, to, _value);
        }
        _addBalance(to, _value);
        totalSupply = totalSupply.add(_value, "totalSupply overflow");
        if (hook) {
            TrueCoinReceiver(to).tokenFallback(address(0x0), _value);
        }
    }
}


pragma solidity ^0.5.13;




contract AStakedToken is ValTokenWithHook {

    using ValSafeMath for uint256;

    uint256 cumulativeRewardsPerStake;

    mapping (address => uint256) claimedRewardsPerStake;

    uint256 rewardsRemainder;

    uint256 public stakePendingWithdrawal;

    mapping (address => mapping (uint256 => uint256)) pendingWithdrawals;

    uint256 constant UNSTAKE_PERIOD = 14 days;

    event PendingWithdrawal(address indexed staker, uint256 indexed timestamp, uint256 indexed amount);

    function unclaimedRewards(address _staker) public view returns (uint256 unclaimedRewards_) {

        uint256 stake = balanceOf[_staker];
        if (stake == 0) {
            return 0;
        }
        unclaimedRewards_ = stake.mul(cumulativeRewardsPerStake.sub(claimedRewardsPerStake[_staker], "underflow"), "unclaimed rewards overflow");
    }

    function stakeAsset() internal view returns (StakingAsset);


    function rewardAsset() internal view returns (StakingAsset);


    function liquidator() internal view returns (address);


    uint256 constant MAX_UINT256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;

    uint256 constant DEFAULT_RATIO = 1000;

    function initialize() internal {

        stakeAsset().approve(liquidator(), MAX_UINT256);
    }

    function _transferAllArgs(address _from, address _to, uint256 _value) internal resolveSender(_from) {

        uint256 fromRewards = claimedRewardsPerStake[_from];
        if (_subBalance(_from, _value) == 0) {
            claimedRewardsPerStake[_from] = 0;
        }
        emit Transfer(_from, _to, _value);
        (address to, bool hasHook) = _resolveRecipient(_to);
        if (_to != to) {
            emit Transfer(_to, to, _value);
        }
        uint256 priorBalance = _addBalance(to, _value);
        uint256 numerator = (_value * fromRewards + priorBalance * claimedRewardsPerStake[to]);
        uint256 denominator = (_value + priorBalance);
        uint256 result = numerator / denominator;
        uint256 remainder = numerator % denominator;
        if (remainder > 0) {
            rewardsRemainder = rewardsRemainder.add(denominator - remainder, "remainder overflow");
            result += 1;
        }
        claimedRewardsPerStake[to] = result;
        if (hasHook) {
            TrueCoinReceiver(to).tokenFallback(_from, _value);
        }
    }

    function _burn(address _from, uint256 _value) internal returns (uint256 resultBalance_, uint256 resultSupply_) {

        (resultBalance_, resultSupply_) = super._burn(_from, _value);
        uint256 userClaimedRewardsPerStake = claimedRewardsPerStake[_from];
        uint256 totalRewardsPerStake = cumulativeRewardsPerStake;
        uint256 pendingRewards = (totalRewardsPerStake - userClaimedRewardsPerStake) * _value;
        if (resultBalance_ == 0) {
            _award(pendingRewards);
        } else {
            uint256 pendingRewardsPerStake = pendingRewards / resultBalance_;
            uint256 award_ = pendingRewards % resultBalance_;
            if (pendingRewardsPerStake > userClaimedRewardsPerStake) {
                claimedRewardsPerStake[_from] = 0;
                _award(award_.add((pendingRewardsPerStake - userClaimedRewardsPerStake).mul(resultBalance_, "award overflow"), "award overflow?"));
            } else {
                claimedRewardsPerStake[_from] = userClaimedRewardsPerStake - pendingRewardsPerStake;
                _award(award_);
            }
        }
    }

    function _mint(address _to, uint256 _value) internal {

        emit Transfer(address(0), _to, _value);
        emit Mint(_to, _value);
        (address to, bool hook) = _resolveRecipient(_to);
        if (_to != to) {
            emit Transfer(_to, to, _value);
        }
        uint256 priorBalance = _addBalance(to, _value);
        uint256 numerator = (cumulativeRewardsPerStake * _value + claimedRewardsPerStake[_to] * priorBalance);
        uint256 denominator = (priorBalance + _value);
        uint256 result = numerator / denominator;
        uint256 remainder = numerator % denominator;
        if (remainder > 0) {
            rewardsRemainder = rewardsRemainder.add(denominator - remainder, "remainder overflow");
            result += 1;
        }
        claimedRewardsPerStake[_to] = result;
        totalSupply = totalSupply.add(_value, "totalSupply overflow");
        if (hook) {
            TrueCoinReceiver(to).tokenFallback(address(0x0), _value);
        }
    }

    function _deposit(address _staker, uint256 _amount) internal {

        uint256 balance = stakeAsset().balanceOf(address(this));
        uint256 stakeAmount;
        if (_amount < balance) {
            stakeAmount = _amount.mul(totalSupply.add(stakePendingWithdrawal, "stakePendingWithdrawal > totalSupply"), "overflow").div(balance - _amount, "insufficient deposit");
        } else {
            require(totalSupply == 0, "pool drained");
            stakeAmount = _amount * DEFAULT_RATIO;
        }
        _mint(_staker, stakeAmount);
    }

    function tokenFallback(address _originalSender, uint256 _amount) external {

        if (msg.sender == address(stakeAsset())) {
            if (_originalSender == liquidator()) {
                return;
            }
            _deposit(_originalSender, _amount);
        } else if (msg.sender == address(rewardAsset())) {
            _award(_amount);
        } else {
            revert("Wrong token");
        }
    }

    function deposit(uint256 _amount) external {

        require(stakeAsset().transferFrom(msg.sender, address(this), _amount));
    }

    function initUnstake(uint256 _maxAmount) external returns (uint256 unstake_) {

        unstake_ = balanceOf[msg.sender];
        if (unstake_ > _maxAmount) {
            unstake_ = _maxAmount;
        }
        _burn(msg.sender, unstake_); // burn tokens

        stakePendingWithdrawal = stakePendingWithdrawal.add(unstake_, "stakePendingWithdrawal overflow");
        pendingWithdrawals[msg.sender][now] = pendingWithdrawals[msg.sender][now].add(unstake_, "pendingWithdrawals overflow");
        emit PendingWithdrawal(msg.sender, now, unstake_);
    }

    function finalizeUnstake(address recipient, uint256[] calldata _timestamps) external {

        uint256 totalUnstake = 0;
        for (uint256 i = _timestamps.length; i --> 0;) {
            uint256 timestamp = _timestamps[i];
            require(timestamp + UNSTAKE_PERIOD <= now, "must wait 2 weeks to unstake");
            totalUnstake = totalUnstake.add(pendingWithdrawals[msg.sender][timestamp], "stake overflow");

            pendingWithdrawals[msg.sender][timestamp] = 0;
        }
        IERC20 stake = stakeAsset(); // get stake asset
        uint256 totalStake = stake.balanceOf(address(this)); // get total stake

        uint256 correspondingStake = totalStake.mul(totalUnstake, "totalStake*totalUnstake overflow").div(totalSupply.add(stakePendingWithdrawal, "overflow totalSupply+stakePendingWithdrawal"), "zero totals");
        stakePendingWithdrawal = stakePendingWithdrawal.sub(totalUnstake, "stakePendingWithdrawal underflow");
        stake.transfer(recipient, correspondingStake);
    }

    function award(uint256 _amount) external {

        require(rewardAsset().transferFrom(msg.sender, address(this), _amount));
    }

    function _award(uint256 _amount) internal {

        uint256 remainder = rewardsRemainder.add(_amount, "rewards overflow");
        uint256 totalStake = totalSupply;
        if (totalStake > 0) {
            uint256 rewardsAdded = remainder / totalStake;
            rewardsRemainder = remainder % totalStake;
            cumulativeRewardsPerStake = cumulativeRewardsPerStake.add(rewardsAdded, "cumulative rewards overflow");
        } else {
            rewardsRemainder = remainder;
        }
    }

    function claimRewards(address _destination) external {

        require(attributes[uint144(uint160(msg.sender) >> 20)] & ACCOUNT_KYC != 0 || registry().getAttributeValue(msg.sender, PASSED_KYCAML) != 0, "please register at app.trusttoken.com");

        uint256 stake = balanceOf[msg.sender];
        if (stake == 0) {
            return;
        }
        uint256 dueRewards = stake.mul(cumulativeRewardsPerStake.sub(claimedRewardsPerStake[msg.sender], "underflow"), "dueRewards overflow");
        if (dueRewards == 0) {
            return;
        }
        claimedRewardsPerStake[msg.sender] = cumulativeRewardsPerStake;

        require(rewardAsset().transfer(_destination, dueRewards));
    }

    function decimals() public view returns (uint8) {

        return stakeAsset().decimals() + 3;
    }

    function name() public view returns (string memory) {

        return string(abi.encodePacked(stakeAsset().name(), " staked for ", rewardAsset().name()));
    }

    function symbol() public view returns (string memory) {

        return string(abi.encodePacked(stakeAsset().symbol(), ":", rewardAsset().symbol()));
    }
}


pragma solidity ^0.5.13;





contract StakedToken is AStakedToken {

    StakingAsset stakeAsset_;
    StakingAsset rewardAsset_;
    Registry registry_;
    address liquidator_;

    function configure(
        StakingAsset _stakeAsset,
        StakingAsset _rewardAsset,
        Registry _registry,
        address _liquidator
    ) external {

        require(!initalized, "already initalized StakedToken");
        stakeAsset_ = _stakeAsset;
        rewardAsset_ = _rewardAsset;
        registry_ = _registry;
        liquidator_ = _liquidator;
        initialize();
        initalized = true;
    }

    function stakeAsset() internal view returns (StakingAsset) {

        return stakeAsset_;
    }

    function rewardAsset() internal view returns (StakingAsset) {

        return rewardAsset_;
    }

    function registry() internal view returns (Registry) {

        return registry_;
    }

    function liquidator() internal view returns (address) {

        return liquidator_;
    }
}