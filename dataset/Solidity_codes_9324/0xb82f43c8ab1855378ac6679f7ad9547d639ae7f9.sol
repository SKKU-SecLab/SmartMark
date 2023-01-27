
pragma solidity 0.4.24;


contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {

  function allowance(address _owner, address _spender)
    public view returns (uint256);


  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);


  function approve(address _spender, uint256 _value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}


library SafeERC20 {

  function safeTransfer(
    ERC20Basic _token,
    address _to,
    uint256 _value
  )
    internal
  {

    require(_token.transfer(_to, _value));
  }

  function safeTransferFrom(
    ERC20 _token,
    address _from,
    address _to,
    uint256 _value
  )
    internal
  {

    require(_token.transferFrom(_from, _to, _value));
  }

  function safeApprove(
    ERC20 _token,
    address _spender,
    uint256 _value
  )
    internal
  {

    require(_token.approve(_spender, _value));
  }
}


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool wasInitializing = initializing;
    initializing = true;
    initialized = true;

    _;

    initializing = wasInitializing;
  }

  function isConstructor() private view returns (bool) {

    uint256 cs;
    assembly { cs := extcodesize(address) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


contract Ownable is Initializable {

  address private _owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  function initialize(address sender) public initializer {

    _owner = sender;
  }

  function owner() public view returns(address) {

    return _owner;
  }

  modifier onlyOwner() {

    require(isOwner());
    _;
  }

  function isOwner() public view returns(bool) {

    return msg.sender == _owner;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(_owner);
    _owner = address(0);
  }

  function transferOwnership(address newOwner) public onlyOwner {

    _transferOwnership(newOwner);
  }

  function _transferOwnership(address newOwner) internal {

    require(newOwner != address(0));
    emit OwnershipTransferred(_owner, newOwner);
    _owner = newOwner;
  }

  uint256[50] private ______gap;
}


library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);
    return a % b;
  }
}


library OperationStore {


    function storeInt(uint256[] storage _history, uint256 _value) internal {

        _history.push(block.timestamp);
        _history.push(_value);
    }

    function getInt(uint256[] memory _history, uint256 _timestamp) internal pure returns (uint256) {

        uint256 index = findIndex(_history, _timestamp, 2);
        if (index > 0) {
            return _history[index - 1];
        }
        return 0;
    }

    function storeBool(uint256[] storage _history, bool _value) internal {

        bool current = (_history.length % 2 == 1);
        if (current != _value) {
            _history.push(block.timestamp);
        }
    }

    function getBool(uint256[] memory _history, uint256 _timestamp) internal pure returns (bool) {

        return findIndex(_history, _timestamp, 1) % 2 == 1;
    }

    function storeTimestamp(uint256[] storage _history, uint256 _value) internal {

        _history.push(_value);
    }

    function getTimestamp(uint256[] memory _history, uint256 _timestamp) internal pure returns (uint256) {

        uint256 index = findIndex(_history, _timestamp, 1);
        if (index > 0) {
            return _history[index - 1];
        }
        return 0;
    }

    function findIndex(uint256[] memory _history, uint256 _timestamp, uint256 _step) internal pure returns (uint256) {

        if (_history.length == 0) {
            return 0;
        }
        uint256 low = 0;
        uint256 high = _history.length - _step;

        while (low <= high) {
            uint256 mid = ((low + high) >> _step) << (_step - 1);
            uint256 midVal = _history[mid];
            if (midVal < _timestamp) {
                low = mid + _step;
            } else if (midVal > _timestamp) {
                if (mid == 0) {
                    return 0;
                }
                high = mid - _step;
            } else {
                uint256 result = mid + _step;
                while (result < _history.length && _history[result] == _timestamp) {
                    result = result + _step;
                }
                return result;
            }
        }
        return low;
    }

}


contract Proxy {

  function () payable external {
    _fallback();
  }

  function _implementation() internal view returns (address);


  function _delegate(address implementation) internal {

    assembly {
      calldatacopy(0, 0, calldatasize)

      let result := delegatecall(gas, implementation, 0, calldatasize, 0, 0)

      returndatacopy(0, 0, returndatasize)

      switch result
      case 0 { revert(0, returndatasize) }
      default { return(0, returndatasize) }
    }
  }

  function _willFallback() internal {

  }

  function _fallback() internal {

    _willFallback();
    _delegate(_implementation());
  }
}


library AddressUtils {


  function isContract(address _addr) internal view returns (bool) {

    uint256 size;
    assembly { size := extcodesize(_addr) }
    return size > 0;
  }

}


contract UpgradeabilityProxy is Proxy {

  event Upgraded(address indexed implementation);

  bytes32 private constant IMPLEMENTATION_SLOT = 0x7050c9e0f4ca769c69bd3a8ef740bc37934f8e2c036e5a723fd8ee048ed3f8c3;

  constructor(address _implementation, bytes _data) public payable {
    assert(IMPLEMENTATION_SLOT == keccak256("org.zeppelinos.proxy.implementation"));
    _setImplementation(_implementation);
    if(_data.length > 0) {
      require(_implementation.delegatecall(_data));
    }
  }

  function _implementation() internal view returns (address impl) {

    bytes32 slot = IMPLEMENTATION_SLOT;
    assembly {
      impl := sload(slot)
    }
  }

  function _upgradeTo(address newImplementation) internal {

    _setImplementation(newImplementation);
    emit Upgraded(newImplementation);
  }

  function _setImplementation(address newImplementation) private {

    require(AddressUtils.isContract(newImplementation), "Cannot set a proxy implementation to a non-contract address");

    bytes32 slot = IMPLEMENTATION_SLOT;

    assembly {
      sstore(slot, newImplementation)
    }
  }
}


contract AdminUpgradeabilityProxy is UpgradeabilityProxy {

  event AdminChanged(address previousAdmin, address newAdmin);

  bytes32 private constant ADMIN_SLOT = 0x10d6a54a4754c8869d6886b5f5d7fbfa5b4522237ea5c60d11bc4e7a1ff9390b;

  modifier ifAdmin() {

    if (msg.sender == _admin()) {
      _;
    } else {
      _fallback();
    }
  }

  constructor(address _implementation, bytes _data) UpgradeabilityProxy(_implementation, _data) public payable {
    assert(ADMIN_SLOT == keccak256("org.zeppelinos.proxy.admin"));

    _setAdmin(msg.sender);
  }

  function admin() external view ifAdmin returns (address) {

    return _admin();
  }

  function implementation() external view ifAdmin returns (address) {

    return _implementation();
  }

  function changeAdmin(address newAdmin) external ifAdmin {

    require(newAdmin != address(0), "Cannot change the admin of a proxy to the zero address");
    emit AdminChanged(_admin(), newAdmin);
    _setAdmin(newAdmin);
  }

  function upgradeTo(address newImplementation) external ifAdmin {

    _upgradeTo(newImplementation);
  }

  function upgradeToAndCall(address newImplementation, bytes data) payable external ifAdmin {

    _upgradeTo(newImplementation);
    require(newImplementation.delegatecall(data));
  }

  function _admin() internal view returns (address adm) {

    bytes32 slot = ADMIN_SLOT;
    assembly {
      adm := sload(slot)
    }
  }

  function _setAdmin(address newAdmin) internal {

    bytes32 slot = ADMIN_SLOT;

    assembly {
      sstore(slot, newAdmin)
    }
  }

  function _willFallback() internal {

    require(msg.sender != _admin(), "Cannot call fallback function from the proxy admin");
    super._willFallback();
  }
}


contract OwnedUpgradeabilityProxy is AdminUpgradeabilityProxy {


    constructor(address _implementation) AdminUpgradeabilityProxy(_implementation, "") public {
    }

    function _willFallback() internal {

    }
}


library Conversions {


    function bytes20ToString(bytes20 _input) internal pure returns (string) {

        bytes memory bytesString = new bytes(20);
        uint256 charCount = 0;
        for (uint256 index = 0; index < 20; index++) {
            byte char = byte(bytes20(uint256(_input) * 2 ** (8 * index)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (index = 0; index < charCount; index++) {
            bytesStringTrimmed[index] = bytesString[index];
        }
        return string(bytesStringTrimmed);
    }

}


interface GovernanceReference {


    function submitBlacklistProposal(bytes32 _id, address _delegate, bool _blacklisted) external;


    function submitActivateProposal(bytes32 _id) external;


    function vote(bytes32 _id, bool _inFavor) external;


    function finalizeVoting(bytes32 _id) external;


    function isDelegateKnown(address _delegate) external view returns (bool);


    function unregisterDelegate() external;


}


interface DelegateReference {

    function stake(uint256 _amount) external;


    function unstake(uint256 _amount) external;


    function stakeOf(address _staker) external view returns (uint256);


    function setAerumAddress(address _aerum) external;

}


contract Delegate is DelegateReference, Initializable, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using OperationStore for uint256[];
    using Conversions for bytes20;

    ERC20 public token;

    GovernanceReference public governance;

    address public aerum;

    bytes20 public name;

    mapping(address => uint256) public stakes;

    mapping(address => address) public stakerAerumAddress;

    uint256 public lockedStake;

    uint256[] stakeHistory;
    uint256[] keepAliveHistory;
    uint256[] blacklistHistory;
    uint256[] activationHistory;

    event AerumAddressUpdated(address aerum);
    event KeepAlive(uint256 timestamp);
    event BlacklistUpdated(bool blocked);
    event IsActiveUpdated(bool active);

    event Staked(address indexed staker, uint256 amount);
    event Unstaked(address indexed staker, uint256 amount);
    event StakeLocked(uint256 amount);

    modifier onlyGovernance {

        require(msg.sender == address(governance));
        _;
    }

    modifier onlyOwnerOrGovernance {

        require((msg.sender == address(governance)) || (msg.sender == owner()));
        _;
    }

    modifier onlyForApprovedDelegate() {

        require(activationHistory.getBool(block.timestamp));
        _;
    }

    function init(address _owner, ERC20 _token, bytes20 _name, address _aerum) initializer public {

        Ownable.initialize(_owner);
        token = _token;
        name = _name;
        aerum = _aerum;
        governance = GovernanceReference(msg.sender);
    }

    function getName() public view returns (string) {

        return name.bytes20ToString();
    }

    function keepAlive() external onlyOwner {

        keepAliveHistory.storeTimestamp(block.timestamp);
        emit KeepAlive(block.timestamp);
    }

    function getKeepAliveTimestamp(uint256 _timestamp) public view returns (uint256) {

        return keepAliveHistory.getTimestamp(_timestamp);
    }

    function setAerumAddress(address _aerum) external {

        require(stakes[msg.sender] > 0);
        stakerAerumAddress[msg.sender] = _aerum;
        emit AerumAddressUpdated(_aerum);
    }

    function getAerumAddress(address _staker) external view returns (address) {

        return stakerAerumAddress[_staker];
    }

    function updateBlacklist(bool _blocked) external onlyGovernance {

        blacklistHistory.storeBool(_blocked);
        emit BlacklistUpdated(_blocked);
    }

    function isBlacklisted(uint256 _timestamp) public view returns (bool) {

        return blacklistHistory.getBool(_timestamp);
    }

    function setActive(bool _active) external onlyGovernance {

        activationHistory.storeBool(_active);
        emit IsActiveUpdated(_active);
    }

    function isActive(uint256 _timestamp) external view returns (bool) {

        return activationHistory.getBool(_timestamp);
    }

    function deactivate() external onlyOwner {

        governance.unregisterDelegate();
    }

    function stake(uint256 _amount) external onlyForApprovedDelegate() {

        address staker = msg.sender;
        token.safeTransferFrom(staker, this, _amount);
        stakes[staker] = stakes[staker].add(_amount);
        emit Staked(staker, _amount);
    }

    function unstake(uint256 _amount) external {

        address staker = msg.sender;
        require(stakes[staker] >= _amount);
        require(token.balanceOf(this).sub(_amount) >= lockedStake);
        token.safeTransfer(staker, _amount);
        stakes[staker] = stakes[staker].sub(_amount);
        emit Unstaked(staker, _amount);
    }

    function stakeOf(address _staker) external view returns (uint256) {

        return stakes[_staker];
    }

    function lockStake(uint256 _amount) external onlyOwnerOrGovernance {

        require(token.balanceOf(this) >= _amount);
        stakeHistory.storeInt(_amount);
        lockedStake = _amount;
        emit StakeLocked(_amount);
    }

    function getStake(uint256 _timestamp) public view returns (uint256) {

        return stakeHistory.getInt(_timestamp);
    }

    function submitBlacklistProposal(bytes32 _id, address _delegate, bool _blacklisted) external onlyOwner {

        governance.submitBlacklistProposal(_id, _delegate, _blacklisted);
    }

    function submitActivateProposal(bytes32 _id) external onlyOwner {

        governance.submitActivateProposal(_id);
    }

    function vote(bytes32 _id, bool _inFavor) external onlyOwner {

        governance.vote(_id, _inFavor);
    }

    function finalizeVoting(bytes32 _id) external {

        governance.finalizeVoting(_id);
    }

}


contract Governance is GovernanceReference, Initializable, Ownable {

    using SafeMath for uint256;
    using SafeERC20 for ERC20;
    using OperationStore for uint256[];

    uint256 constant votingPeriod = 60 * 60 * 24 * 7;
    uint256 constant delegatesUpdateAerumBlocksPeriod = 1000;
    uint256 public delegateBond;

    address public upgradeAdmin;
    address public delegateApprover;
    bool public delegateApproverRenounced;

    ERC20 public token;

    address[] public delegates;
    mapping(address => bool) public knownDelegates;
    mapping(address => uint256) public bonds;

    uint256[] public minBalance;
    uint256[] public keepAliveDuration;
    uint256[] public composersCount;

    enum VotingCategory { BLACKLIST, ACTIVATE }

    struct Voting {
        bytes32 id;
        VotingCategory category;
        uint256 timestamp;
        address delegate;
        bool proposal;
        mapping(address => bool) votes;
        address[] voters;
    }

    mapping(bytes32 => Voting) public votings;

    event UpgradeAdminUpdated(address admin);
    event DelegateApproverUpdated(address admin);
    event DelegateApproverRenounced();

    event MinBalanceUpdated(uint256 balance);
    event KeepAliveDurationUpdated(uint256 duration);
    event ComposersCountUpdated(uint256 count);
    event BlacklistUpdated(address indexed delegate, bool blocked);

    event DelegateCreated(address indexed delegate, address indexed owner);
    event DelegateApproved(address indexed delegate);
    event DelegateUnregistered(address indexed delegate);
    event BondSent(address indexed delegate, uint256 amount);
    event StakeLocked(address indexed delegate, uint256 amount);

    event ProposalSubmitted(bytes32 indexed id, address indexed author, address indexed delegate, VotingCategory category, bool proposal);
    event Vote(bytes32 indexed id, address indexed voter, bool inFavor);
    event VotingFinalized(bytes32 indexed id, bool voted, bool supported);

    modifier onlyOwnerOrDelegateApprover() {

        require((owner() == msg.sender) || (delegateApprover == msg.sender));
        _;
    }

    modifier onlyKnownDelegate(address delegate) {

        require(knownDelegates[delegate]);
        _;
    }

    modifier onlyValidDelegate {

        require(isDelegateValid(msg.sender, block.timestamp));
        _;
    }

    modifier onlyWhenDelegateApproverActive {

        require(!delegateApproverRenounced);
        _;
    }

    function init(
        address _owner, address _token,
        uint256 _minBalance, uint256 _keepAliveDuration, uint256 _delegatesLimit,
        uint256 _delegateBond
    ) initializer public {

        require(_owner != address(0));
        require(_token != address(0));

        Ownable.initialize(_owner);
        token = ERC20(_token);

        delegateBond = _delegateBond;
        delegateApprover = _owner;
        upgradeAdmin = _owner;

        minBalance.storeInt(_minBalance);
        keepAliveDuration.storeInt(_keepAliveDuration);
        composersCount.storeInt(_delegatesLimit);
    }

    function setUpgradeAdmin(address _admin) external onlyOwner {

        upgradeAdmin = _admin;
        emit UpgradeAdminUpdated(_admin);
    }

    function setDelegateApprover(address _admin) external onlyOwner onlyWhenDelegateApproverActive {

        delegateApprover = _admin;
        emit DelegateApproverUpdated(_admin);
    }

    function renouncedDelegateApprover() external onlyOwner {

        delegateApproverRenounced = true;
        delegateApprover = address(0);
        emit DelegateApproverRenounced();
    }

    function setMinBalance(uint256 _balance) external onlyOwner {

        minBalance.storeInt(_balance);
        emit MinBalanceUpdated(_balance);
    }

    function setKeepAliveDuration(uint256 _duration) external onlyOwner {

        keepAliveDuration.storeInt(_duration);
        emit KeepAliveDurationUpdated(_duration);
    }

    function setComposersCount(uint256 _count) external onlyOwner {

        composersCount.storeInt(_count);
        emit ComposersCountUpdated(_count);
    }

    function updateBlacklist(address _delegate, bool _blocked) external onlyOwner onlyKnownDelegate(_delegate) {

        Delegate(_delegate).updateBlacklist(_blocked);
        emit BlacklistUpdated(_delegate, _blocked);
    }

    function getMinBalance(uint256 _timestamp) external view returns (uint256) {

        return minBalance.getInt(_timestamp);
    }

    function getKeepAliveDuration(uint256 _timestamp) external view returns (uint256) {

        return keepAliveDuration.getInt(_timestamp);
    }

    function getComposersCount(uint256 _timestamp) external view returns (uint256) {

        return composersCount.getInt(_timestamp);
    }

    function lockStake(address _delegate, uint256 _amount) external onlyOwner onlyKnownDelegate(_delegate) {

        Delegate(_delegate).lockStake(_amount);
        emit StakeLocked(_delegate, _amount);
    }

    function createDelegate(bytes20 _name, address _aerum) external returns (address) {

        token.safeTransferFrom(msg.sender, address(this), delegateBond);

        Delegate impl = new Delegate();
        OwnedUpgradeabilityProxy proxy = new OwnedUpgradeabilityProxy(impl);
        proxy.changeAdmin(upgradeAdmin);
        Delegate wrapper = Delegate(proxy);
        wrapper.init(msg.sender, token, _name, _aerum);

        address proxyAddr = address(wrapper);
        knownDelegates[proxyAddr] = true;
        bonds[proxyAddr] = delegateBond;

        emit DelegateCreated(proxyAddr, msg.sender);

        return proxyAddr;
    }

    function approveDelegate(address _delegate) external onlyOwnerOrDelegateApprover onlyKnownDelegate(_delegate) {

        approveDelegateInternal(_delegate);
    }

    function approveDelegateInternal(address _delegate) internal {

        require(bonds[_delegate] >= delegateBond);

        Delegate(_delegate).setActive(true);

        emit DelegateApproved(_delegate);

        for (uint256 index = 0; index < delegates.length; index++) {
            if (delegates[index] == _delegate) {
                return;
            }
        }
        delegates.push(_delegate);
    }

    function unregisterDelegate() external onlyKnownDelegate(msg.sender) {

        address delegateAddr = msg.sender;
        Delegate delegate = Delegate(delegateAddr);
        require(delegate.isActive(block.timestamp));

        uint256 bond = bonds[delegateAddr];
        bonds[delegateAddr] = 0;
        token.safeTransfer(delegate.owner(), bond);
        delegate.setActive(false);

        emit DelegateUnregistered(delegateAddr);
    }

    function sendBond(address _delegate, uint256 _amount) external onlyKnownDelegate(_delegate) {

        token.safeTransferFrom(msg.sender, address(this), _amount);
        bonds[_delegate] = bonds[_delegate].add(_amount);
        emit BondSent(_delegate, _amount);
    }

    function isDelegateKnown(address _delegate) public view returns (bool) {

        return knownDelegates[_delegate];
    }

    function getComposers(uint256 _blockNum, uint256 _timestamp) external view returns (address[]) {

        (address[] memory candidates,) = getValidDelegates(_timestamp);
        uint256 candidatesLength = candidates.length;

        uint256 limit = composersCount.getInt(_timestamp);
        if (candidatesLength < limit) {
            limit = candidatesLength;
        }

        address[] memory composers = new address[](limit);

        if (candidatesLength == 0) {
            return composers;
        }

        uint256 first = _blockNum.div(delegatesUpdateAerumBlocksPeriod) % candidatesLength;
        for (uint256 index = 0; index < limit; index++) {
            composers[index] = candidates[(first + index) % candidatesLength];
        }

        return composers;
    }

    function getDelegates() public view returns (address[]) {

        return delegates;
    }

    function getDelegateCount() public view returns (uint256) {

        return delegates.length;
    }

    function getValidDelegates(uint256 _timestamp) public view returns (address[], bytes20[]) {

        address[] memory array = new address[](delegates.length);
        uint16 length = 0;
        for (uint256 i = 0; i < delegates.length; i++) {
            if (isDelegateValid(delegates[i], _timestamp)) {
                array[length] = delegates[i];
                length++;
            }
        }
        address[] memory addresses = new address[](length);
        bytes20[] memory names = new bytes20[](length);
        for (uint256 j = 0; j < length; j++) {
            Delegate delegate = Delegate(array[j]);
            addresses[j] = delegate.aerum();
            names[j] = delegate.name();
        }
        return (addresses, names);
    }

    function getValidDelegateCount() public view returns (uint256) {

        (address[] memory validDelegates,) = getValidDelegates(block.timestamp);
        return validDelegates.length;
    }

    function isDelegateValid(address _delegate, uint256 _timestamp) public view returns (bool) {

        if (!knownDelegates[_delegate]) {
            return false;
        }
        Delegate proxy = Delegate(_delegate);
        if (!proxy.isActive(_timestamp)) {
            return false;
        }
        if (proxy.isBlacklisted(_timestamp)) {
            return false;
        }
        uint256 stake = proxy.getStake(_timestamp);
        if (stake < minBalance.getInt(_timestamp)) {
            return false;
        }
        uint256 lastKeepAlive = proxy.getKeepAliveTimestamp(_timestamp);
        return lastKeepAlive.add(keepAliveDuration.getInt(_timestamp)) >= block.timestamp;
    }

    function submitActivateProposal(bytes32 _id) external onlyKnownDelegate(msg.sender) {

        address delegate = msg.sender;
        require(!Delegate(delegate).isActive(block.timestamp));

        submitProposal(_id, delegate, VotingCategory.ACTIVATE, true);
    }

    function submitBlacklistProposal(bytes32 _id, address _delegate, bool _proposal) external onlyValidDelegate {

        submitProposal(_id, _delegate, VotingCategory.BLACKLIST, _proposal);
    }

    function submitProposal(bytes32 _id, address _delegate, VotingCategory _category, bool _proposal) internal {

        require(votings[_id].id != _id);

        Voting memory voting = Voting({
            id : _id,
            category : _category,
            timestamp : block.timestamp,
            delegate : _delegate,
            proposal : _proposal,
            voters : new address[](0)
        });

        votings[_id] = voting;

        emit ProposalSubmitted(_id, msg.sender, _delegate, _category, _proposal);
    }

    function vote(bytes32 _id, bool _inFavor) external onlyValidDelegate {

        Voting storage voting = votings[_id];
        require(voting.id == _id);
        require(voting.timestamp.add(votingPeriod) > block.timestamp);

        address voter = msg.sender;
        for (uint256 index = 0; index < voting.voters.length; index++) {
            if (voting.voters[index] == voter) {
                return;
            }
        }

        voting.voters.push(voter);
        voting.votes[voter] = _inFavor;

        emit Vote(_id, voter, _inFavor);
    }

    function finalizeVoting(bytes32 _id) external {

        bool voted;
        bool supported;
        Voting storage voting = votings[_id];
        require(voting.id == _id);
        require(voting.timestamp.add(votingPeriod) <= block.timestamp);

        uint256 requiredVotesNumber = getValidDelegateCount() * 3 / 10;
        if (voting.voters.length >= requiredVotesNumber) {
            voted = true;
            uint256 proponents = 0;
            for (uint256 index = 0; index < voting.voters.length; index++) {
                if (voting.votes[voting.voters[index]]) {
                    proponents++;
                }
            }
            if (proponents * 2 > voting.voters.length) {
                supported = true;
                if (voting.category == VotingCategory.BLACKLIST) {
                    Delegate(voting.delegate).updateBlacklist(voting.proposal);
                }
                if (voting.category == VotingCategory.ACTIVATE) {
                    approveDelegateInternal(voting.delegate);
                }
            }
        }

        delete votings[_id];

        emit VotingFinalized(_id, voted, supported);
    }

    function getVotingDetails(bytes32 _id) external view returns (bytes32, uint256, address, VotingCategory, bool, address[], bool[]) {

        Voting storage voting = votings[_id];
        address[] storage voters = voting.voters;

        bool[] memory votes = new bool[] (voters.length);
        for (uint256 index = 0; index < voters.length; index++) {
            votes[index] = voting.votes[voters[index]];
        }

        return (voting.id, voting.timestamp, voting.delegate, voting.category, voting.proposal, voters, votes);
    }

}