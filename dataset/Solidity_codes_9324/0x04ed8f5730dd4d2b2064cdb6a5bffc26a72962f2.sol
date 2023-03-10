
pragma solidity ^0.4.24;

contract Ownable {

  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {

    require(msg.sender == owner);
    _;
  }

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);
  }

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
}

library SafeMath {


  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    if (a == 0) {
      return 0;
    }

    c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    return a / b;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;
    assert(c >= a);
    return c;
  }
}

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  function totalSupply() public view returns (uint256) {

    return totalSupply_;
  }

  function transfer(address _to, uint256 _value) public returns (bool) {

    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _owner) public view returns (uint256) {

    return balances[_owner];
  }

}

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)
    public view returns (uint256);


  function transferFrom(address from, address to, uint256 value)
    public returns (bool);


  function approve(address spender, uint256 value) public returns (bool);

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

contract StandardToken is ERC20, BasicToken {


  mapping (address => mapping (address => uint256)) internal allowed;


  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    returns (bool)
  {

    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    emit Transfer(_from, _to, _value);
    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {

    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(
    address _owner,
    address _spender
   )
    public
    view
    returns (uint256)
  {

    return allowed[_owner][_spender];
  }

  function increaseApproval(
    address _spender,
    uint256 _addedValue
  )
    public
    returns (bool)
  {

    allowed[msg.sender][_spender] = (
      allowed[msg.sender][_spender].add(_addedValue));
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval(
    address _spender,
    uint256 _subtractedValue
  )
    public
    returns (bool)
  {

    uint256 oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

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

contract PausableToken is StandardToken, Pausable {


  function transfer(
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {

    return super.transfer(_to, _value);
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {

    return super.transferFrom(_from, _to, _value);
  }

  function approve(
    address _spender,
    uint256 _value
  )
    public
    whenNotPaused
    returns (bool)
  {

    return super.approve(_spender, _value);
  }

  function increaseApproval(
    address _spender,
    uint _addedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {

    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(
    address _spender,
    uint _subtractedValue
  )
    public
    whenNotPaused
    returns (bool success)
  {

    return super.decreaseApproval(_spender, _subtractedValue);
  }
}

contract BurnableToken is BasicToken {


  event Burn(address indexed burner, uint256 value);

  function burn(uint256 _value) public {

    _burn(msg.sender, _value);
  }

  function _burn(address _who, uint256 _value) internal {

    require(_value <= balances[_who]);

    balances[_who] = balances[_who].sub(_value);
    totalSupply_ = totalSupply_.sub(_value);
    emit Burn(_who, _value);
    emit Transfer(_who, address(0), _value);
  }
}

contract RepublicToken is PausableToken, BurnableToken {


    string public constant name = "Republic Token";
    string public constant symbol = "REN";
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000 * 10**uint256(decimals);

    constructor() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
    }

    function transferTokens(address beneficiary, uint256 amount) public onlyOwner returns (bool) {

        require(amount > 0);

        balances[owner] = balances[owner].sub(amount);
        balances[beneficiary] = balances[beneficiary].add(amount);
        emit Transfer(owner, beneficiary, amount);

        return true;
    }
}

library LinkedList {


    address public constant NULL = 0x0;

    struct Node {
        bool inList;
        address previous;
        address next;
    }

    struct List {
        mapping (address => Node) list;
    }

    function insertBefore(List storage self, address target, address newNode) internal {

        require(!isInList(self, newNode), "already in list");
        require(isInList(self, target) || target == NULL, "not in list");

        address prev = self.list[target].previous;

        self.list[newNode].next = target;
        self.list[newNode].previous = prev;
        self.list[target].previous = newNode;
        self.list[prev].next = newNode;

        self.list[newNode].inList = true;
    }

    function insertAfter(List storage self, address target, address newNode) internal {

        require(!isInList(self, newNode), "already in list");
        require(isInList(self, target) || target == NULL, "not in list");

        address n = self.list[target].next;

        self.list[newNode].previous = target;
        self.list[newNode].next = n;
        self.list[target].next = newNode;
        self.list[n].previous = newNode;

        self.list[newNode].inList = true;
    }

    function remove(List storage self, address node) internal {

        require(isInList(self, node), "not in list");
        if (node == NULL) {
            return;
        }
        address p = self.list[node].previous;
        address n = self.list[node].next;

        self.list[p].next = n;
        self.list[n].previous = p;

        self.list[node].inList = false;
        delete self.list[node];
    }

    function prepend(List storage self, address node) internal {


        insertBefore(self, begin(self), node);
    }

    function append(List storage self, address node) internal {


        insertAfter(self, end(self), node);
    }

    function swap(List storage self, address left, address right) internal {


        address previousRight = self.list[right].previous;
        remove(self, right);
        insertAfter(self, left, right);
        remove(self, left);
        insertAfter(self, previousRight, left);
    }

    function isInList(List storage self, address node) internal view returns (bool) {

        return self.list[node].inList;
    }

    function begin(List storage self) internal view returns (address) {

        return self.list[NULL].next;
    }

    function end(List storage self) internal view returns (address) {

        return self.list[NULL].previous;
    }

    function next(List storage self, address node) internal view returns (address) {

        require(isInList(self, node), "not in list");
        return self.list[node].next;
    }

    function previous(List storage self, address node) internal view returns (address) {

        require(isInList(self, node), "not in list");
        return self.list[node].previous;
    }

}

contract DarknodeRegistryStore is Ownable {

    string public VERSION; // Passed in as a constructor parameter.

    struct Darknode {
        address owner;

        uint256 bond;

        uint256 registeredAt;

        uint256 deregisteredAt;

        bytes publicKey;
    }

    mapping(address => Darknode) private darknodeRegistry;
    LinkedList.List private darknodes;

    RepublicToken public ren;

    constructor(
        string _VERSION,
        RepublicToken _ren
    ) public {
        VERSION = _VERSION;
        ren = _ren;
    }

    function appendDarknode(
        address _darknodeID,
        address _darknodeOwner,
        uint256 _bond,
        bytes _publicKey,
        uint256 _registeredAt,
        uint256 _deregisteredAt
    ) external onlyOwner {

        Darknode memory darknode = Darknode({
            owner: _darknodeOwner,
            bond: _bond,
            publicKey: _publicKey,
            registeredAt: _registeredAt,
            deregisteredAt: _deregisteredAt
        });
        darknodeRegistry[_darknodeID] = darknode;
        LinkedList.append(darknodes, _darknodeID);
    }

    function begin() external view onlyOwner returns(address) {

        return LinkedList.begin(darknodes);
    }

    function next(address darknodeID) external view onlyOwner returns(address) {

        return LinkedList.next(darknodes, darknodeID);
    }

    function removeDarknode(address darknodeID) external onlyOwner {

        uint256 bond = darknodeRegistry[darknodeID].bond;
        delete darknodeRegistry[darknodeID];
        LinkedList.remove(darknodes, darknodeID);
        require(ren.transfer(owner, bond), "bond transfer failed");
    }

    function updateDarknodeBond(address darknodeID, uint256 bond) external onlyOwner {

        uint256 previousBond = darknodeRegistry[darknodeID].bond;
        darknodeRegistry[darknodeID].bond = bond;
        if (previousBond > bond) {
            require(ren.transfer(owner, previousBond - bond), "cannot transfer bond");
        }
    }

    function updateDarknodeDeregisteredAt(address darknodeID, uint256 deregisteredAt) external onlyOwner {

        darknodeRegistry[darknodeID].deregisteredAt = deregisteredAt;
    }

    function darknodeOwner(address darknodeID) external view onlyOwner returns (address) {

        return darknodeRegistry[darknodeID].owner;
    }

    function darknodeBond(address darknodeID) external view onlyOwner returns (uint256) {

        return darknodeRegistry[darknodeID].bond;
    }

    function darknodeRegisteredAt(address darknodeID) external view onlyOwner returns (uint256) {

        return darknodeRegistry[darknodeID].registeredAt;
    }

    function darknodeDeregisteredAt(address darknodeID) external view onlyOwner returns (uint256) {

        return darknodeRegistry[darknodeID].deregisteredAt;
    }

    function darknodePublicKey(address darknodeID) external view onlyOwner returns (bytes) {

        return darknodeRegistry[darknodeID].publicKey;
    }
}

contract DarknodeRegistry is Ownable {

    string public VERSION; // Passed in as a constructor parameter.

    struct Epoch {
        uint256 epochhash;
        uint256 blocknumber;
    }

    uint256 public numDarknodes;
    uint256 public numDarknodesNextEpoch;
    uint256 public numDarknodesPreviousEpoch;

    uint256 public minimumBond;
    uint256 public minimumPodSize;
    uint256 public minimumEpochInterval;
    address public slasher;

    uint256 public nextMinimumBond;
    uint256 public nextMinimumPodSize;
    uint256 public nextMinimumEpochInterval;
    address public nextSlasher;

    Epoch public currentEpoch;
    Epoch public previousEpoch;

    RepublicToken public ren;

    DarknodeRegistryStore public store;

    event LogDarknodeRegistered(address _darknodeID, uint256 _bond);

    event LogDarknodeDeregistered(address _darknodeID);

    event LogDarknodeOwnerRefunded(address _owner, uint256 _amount);

    event LogNewEpoch();

    event LogMinimumBondUpdated(uint256 previousMinimumBond, uint256 nextMinimumBond);
    event LogMinimumPodSizeUpdated(uint256 previousMinimumPodSize, uint256 nextMinimumPodSize);
    event LogMinimumEpochIntervalUpdated(uint256 previousMinimumEpochInterval, uint256 nextMinimumEpochInterval);
    event LogSlasherUpdated(address previousSlasher, address nextSlasher);

    modifier onlyDarknodeOwner(address _darknodeID) {

        require(store.darknodeOwner(_darknodeID) == msg.sender, "must be darknode owner");
        _;
    }

    modifier onlyRefunded(address _darknodeID) {

        require(isRefunded(_darknodeID), "must be refunded or never registered");
        _;
    }

    modifier onlyRefundable(address _darknodeID) {

        require(isRefundable(_darknodeID), "must be deregistered for at least one epoch");
        _;
    }

    modifier onlyDeregisterable(address _darknodeID) {

        require(isDeregisterable(_darknodeID), "must be deregisterable");
        _;
    }

    modifier onlySlasher() {

        require(slasher == msg.sender, "must be slasher");
        _;
    }

    constructor(
        string _VERSION,
        RepublicToken _renAddress,
        DarknodeRegistryStore _storeAddress,
        uint256 _minimumBond,
        uint256 _minimumPodSize,
        uint256 _minimumEpochInterval
    ) public {
        VERSION = _VERSION;

        store = _storeAddress;
        ren = _renAddress;

        minimumBond = _minimumBond;
        nextMinimumBond = minimumBond;

        minimumPodSize = _minimumPodSize;
        nextMinimumPodSize = minimumPodSize;

        minimumEpochInterval = _minimumEpochInterval;
        nextMinimumEpochInterval = minimumEpochInterval;

        currentEpoch = Epoch({
            epochhash: uint256(blockhash(block.number - 1)),
            blocknumber: block.number
        });
        numDarknodes = 0;
        numDarknodesNextEpoch = 0;
        numDarknodesPreviousEpoch = 0;
    }

    function register(address _darknodeID, bytes _publicKey, uint256 _bond) external onlyRefunded(_darknodeID) {

        require(_bond >= minimumBond, "insufficient bond");
        require(ren.transferFrom(msg.sender, address(this), _bond), "bond transfer failed");
        ren.transfer(address(store), _bond);

        store.appendDarknode(
            _darknodeID,
            msg.sender,
            _bond,
            _publicKey,
            currentEpoch.blocknumber + minimumEpochInterval,
            0
        );

        numDarknodesNextEpoch += 1;

        emit LogDarknodeRegistered(_darknodeID, _bond);
    }

    function deregister(address _darknodeID) external onlyDeregisterable(_darknodeID) onlyDarknodeOwner(_darknodeID) {

        store.updateDarknodeDeregisteredAt(_darknodeID, currentEpoch.blocknumber + minimumEpochInterval);
        numDarknodesNextEpoch -= 1;

        emit LogDarknodeDeregistered(_darknodeID);
    }

    function epoch() external {

        if (previousEpoch.blocknumber == 0) {
            require(msg.sender == owner, "not authorized (first epochs)");
        }

        require(block.number >= currentEpoch.blocknumber + minimumEpochInterval, "epoch interval has not passed");
        uint256 epochhash = uint256(blockhash(block.number - 1));

        previousEpoch = currentEpoch;
        currentEpoch = Epoch({
            epochhash: epochhash,
            blocknumber: block.number
        });

        numDarknodesPreviousEpoch = numDarknodes;
        numDarknodes = numDarknodesNextEpoch;

        if (nextMinimumBond != minimumBond) {
            minimumBond = nextMinimumBond;
            emit LogMinimumBondUpdated(minimumBond, nextMinimumBond);
        }
        if (nextMinimumPodSize != minimumPodSize) {
            minimumPodSize = nextMinimumPodSize;
            emit LogMinimumPodSizeUpdated(minimumPodSize, nextMinimumPodSize);
        }
        if (nextMinimumEpochInterval != minimumEpochInterval) {
            minimumEpochInterval = nextMinimumEpochInterval;
            emit LogMinimumEpochIntervalUpdated(minimumEpochInterval, nextMinimumEpochInterval);
        }
        if (nextSlasher != slasher) {
            slasher = nextSlasher;
            emit LogSlasherUpdated(slasher, nextSlasher);
        }

        emit LogNewEpoch();
    }

    function transferStoreOwnership(address _newOwner) external onlyOwner {

        store.transferOwnership(_newOwner);
    }

    function updateMinimumBond(uint256 _nextMinimumBond) external onlyOwner {

        nextMinimumBond = _nextMinimumBond;
    }

    function updateMinimumPodSize(uint256 _nextMinimumPodSize) external onlyOwner {

        nextMinimumPodSize = _nextMinimumPodSize;
    }

    function updateMinimumEpochInterval(uint256 _nextMinimumEpochInterval) external onlyOwner {

        nextMinimumEpochInterval = _nextMinimumEpochInterval;
    }

    function updateSlasher(address _slasher) external onlyOwner {

        nextSlasher = _slasher;
    }

    function slash(address _prover, address _challenger1, address _challenger2)
        external
        onlySlasher
    {

        uint256 penalty = store.darknodeBond(_prover) / 2;
        uint256 reward = penalty / 4;

        store.updateDarknodeBond(_prover, penalty);

        if (isDeregisterable(_prover)) {
            store.updateDarknodeDeregisteredAt(_prover, currentEpoch.blocknumber + minimumEpochInterval);
            numDarknodesNextEpoch -= 1;
            emit LogDarknodeDeregistered(_prover);
        }

        ren.transfer(store.darknodeOwner(_challenger1), reward);
        ren.transfer(store.darknodeOwner(_challenger2), reward);
    }

    function refund(address _darknodeID) external onlyRefundable(_darknodeID) {

        address darknodeOwner = store.darknodeOwner(_darknodeID);

        uint256 amount = store.darknodeBond(_darknodeID);

        store.removeDarknode(_darknodeID);

        ren.transfer(darknodeOwner, amount);

        emit LogDarknodeOwnerRefunded(darknodeOwner, amount);
    }

    function getDarknodeOwner(address _darknodeID) external view returns (address) {

        return store.darknodeOwner(_darknodeID);
    }

    function getDarknodeBond(address _darknodeID) external view returns (uint256) {

        return store.darknodeBond(_darknodeID);
    }

    function getDarknodePublicKey(address _darknodeID) external view returns (bytes) {

        return store.darknodePublicKey(_darknodeID);
    }

    function getDarknodes(address _start, uint256 _count) external view returns (address[]) {

        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }
        return getDarknodesFromEpochs(_start, count, false);
    }

    function getPreviousDarknodes(address _start, uint256 _count) external view returns (address[]) {

        uint256 count = _count;
        if (count == 0) {
            count = numDarknodesPreviousEpoch;
        }
        return getDarknodesFromEpochs(_start, count, true);
    }

    function isPendingRegistration(address _darknodeID) external view returns (bool) {

        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        return registeredAt != 0 && registeredAt > currentEpoch.blocknumber;
    }

    function isPendingDeregistration(address _darknodeID) external view returns (bool) {

        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt > currentEpoch.blocknumber;
    }

    function isDeregistered(address _darknodeID) public view returns (bool) {

        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return deregisteredAt != 0 && deregisteredAt <= currentEpoch.blocknumber;
    }

    function isDeregisterable(address _darknodeID) public view returns (bool) {

        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return isRegistered(_darknodeID) && deregisteredAt == 0;
    }

    function isRefunded(address _darknodeID) public view returns (bool) {

        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        return registeredAt == 0 && deregisteredAt == 0;
    }

    function isRefundable(address _darknodeID) public view returns (bool) {

        return isDeregistered(_darknodeID) && store.darknodeDeregisteredAt(_darknodeID) <= previousEpoch.blocknumber;
    }

    function isRegistered(address _darknodeID) public view returns (bool) {

        return isRegisteredInEpoch(_darknodeID, currentEpoch);
    }

    function isRegisteredInPreviousEpoch(address _darknodeID) public view returns (bool) {

        return isRegisteredInEpoch(_darknodeID, previousEpoch);
    }

    function isRegisteredInEpoch(address _darknodeID, Epoch _epoch) private view returns (bool) {

        uint256 registeredAt = store.darknodeRegisteredAt(_darknodeID);
        uint256 deregisteredAt = store.darknodeDeregisteredAt(_darknodeID);
        bool registered = registeredAt != 0 && registeredAt <= _epoch.blocknumber;
        bool notDeregistered = deregisteredAt == 0 || deregisteredAt > _epoch.blocknumber;
        return registered && notDeregistered;
    }

    function getDarknodesFromEpochs(address _start, uint256 _count, bool _usePreviousEpoch) private view returns (address[]) {

        uint256 count = _count;
        if (count == 0) {
            count = numDarknodes;
        }

        address[] memory nodes = new address[](count);

        uint256 n = 0;
        address next = _start;
        if (next == 0x0) {
            next = store.begin();
        }

        while (n < count) {
            if (next == 0x0) {
                break;
            }
            bool includeNext;
            if (_usePreviousEpoch) {
                includeNext = isRegisteredInPreviousEpoch(next);
            } else {
                includeNext = isRegistered(next);
            }
            if (!includeNext) {
                next = store.next(next);
                continue;
            }
            nodes[n] = next;
            next = store.next(next);
            n += 1;
        }
        return nodes;
    }
}

interface BrokerVerifier {


    function verifyOpenSignature(
        address _trader,
        bytes _signature,
        bytes32 _orderID
    ) external returns (bool);

}

interface Settlement {

    function submitOrder(
        bytes _details,
        uint64 _settlementID,
        uint64 _tokens,
        uint256 _price,
        uint256 _volume,
        uint256 _minimumVolume
    ) external;


    function submissionGasPriceLimit() external view returns (uint256);


    function settle(
        bytes32 _buyID,
        bytes32 _sellID
    ) external;


    function orderStatus(bytes32 _orderID) external view returns (uint8);

}

contract SettlementRegistry is Ownable {

    string public VERSION; // Passed in as a constructor parameter.

    struct SettlementDetails {
        bool registered;
        Settlement settlementContract;
        BrokerVerifier brokerVerifierContract;
    }

    mapping(uint64 => SettlementDetails) public settlementDetails;

    event LogSettlementRegistered(uint64 settlementID, Settlement settlementContract, BrokerVerifier brokerVerifierContract);
    event LogSettlementUpdated(uint64 settlementID, Settlement settlementContract, BrokerVerifier brokerVerifierContract);
    event LogSettlementDeregistered(uint64 settlementID);

    constructor(string _VERSION) public {
        VERSION = _VERSION;
    }

    function settlementRegistration(uint64 _settlementID) external view returns (bool) {

        return settlementDetails[_settlementID].registered;
    }

    function settlementContract(uint64 _settlementID) external view returns (Settlement) {

        return settlementDetails[_settlementID].settlementContract;
    }

    function brokerVerifierContract(uint64 _settlementID) external view returns (BrokerVerifier) {

        return settlementDetails[_settlementID].brokerVerifierContract;
    }

    function registerSettlement(uint64 _settlementID, Settlement _settlementContract, BrokerVerifier _brokerVerifierContract) public onlyOwner {

        bool alreadyRegistered = settlementDetails[_settlementID].registered;
        
        settlementDetails[_settlementID] = SettlementDetails({
            registered: true,
            settlementContract: _settlementContract,
            brokerVerifierContract: _brokerVerifierContract
        });

        if (alreadyRegistered) {
            emit LogSettlementUpdated(_settlementID, _settlementContract, _brokerVerifierContract);
        } else {
            emit LogSettlementRegistered(_settlementID, _settlementContract, _brokerVerifierContract);
        }
    }

    function deregisterSettlement(uint64 _settlementID) external onlyOwner {

        require(settlementDetails[_settlementID].registered, "not registered");

        delete settlementDetails[_settlementID];

        emit LogSettlementDeregistered(_settlementID);
    }
}


library ECRecovery {


  function recover(bytes32 hash, bytes sig)
    internal
    pure
    returns (address)
  {

    bytes32 r;
    bytes32 s;
    uint8 v;

    if (sig.length != 65) {
      return (address(0));
    }

    assembly {
      r := mload(add(sig, 32))
      s := mload(add(sig, 64))
      v := byte(0, mload(add(sig, 96)))
    }

    if (v < 27) {
      v += 27;
    }

    if (v != 27 && v != 28) {
      return (address(0));
    } else {
      return ecrecover(hash, v, r, s);
    }
  }

  function toEthSignedMessageHash(bytes32 hash)
    internal
    pure
    returns (bytes32)
  {

    return keccak256(
      abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    );
  }
}

library Utils {


    function uintToBytes(uint256 _v) internal pure returns (bytes) {

        uint256 v = _v;
        if (v == 0) {
            return "0";
        }

        uint256 digits = 0;
        uint256 v2 = v;
        while (v2 > 0) {
            v2 /= 10;
            digits += 1;
        }

        bytes memory result = new bytes(digits);

        for (uint256 i = 0; i < digits; i++) {
            result[digits - i - 1] = bytes1((v % 10) + 48);
            v /= 10;
        }

        return result;
    }

    function addr(bytes _hash, bytes _signature) internal pure returns (address) {

        bytes memory prefix = "\x19Ethereum Signed Message:\n";
        bytes memory encoded = abi.encodePacked(prefix, uintToBytes(_hash.length), _hash);
        bytes32 prefixedHash = keccak256(encoded);

        return ECRecovery.recover(prefixedHash, _signature);
    }

}

contract Orderbook is Ownable {

    string public VERSION; // Passed in as a constructor parameter.

    enum OrderState {Undefined, Open, Confirmed, Canceled}

    struct Order {
        OrderState state;     // State of the order
        address trader;       // Trader that owns the order
        address confirmer;    // Darknode that confirmed the order in a match
        uint64 settlementID;  // The settlement that signed the order opening
        uint256 priority;     // Logical time priority of this order
        uint256 blockNumber;  // Block number of the most recent state change
        bytes32 matchedOrder; // Order confirmed in a match with this order
    }

    RepublicToken public ren;
    DarknodeRegistry public darknodeRegistry;
    SettlementRegistry public settlementRegistry;

    bytes32[] private orderbook;

    mapping(bytes32 => Order) public orders;

    event LogFeeUpdated(uint256 previousFee, uint256 nextFee);
    event LogDarknodeRegistryUpdated(DarknodeRegistry previousDarknodeRegistry, DarknodeRegistry nextDarknodeRegistry);

    modifier onlyDarknode(address _sender) {

        require(darknodeRegistry.isRegistered(address(_sender)), "must be registered darknode");
        _;
    }

    constructor(
        string _VERSION,
        RepublicToken _renAddress,
        DarknodeRegistry _darknodeRegistry,
        SettlementRegistry _settlementRegistry
    ) public {
        VERSION = _VERSION;
        ren = _renAddress;
        darknodeRegistry = _darknodeRegistry;
        settlementRegistry = _settlementRegistry;
    }

    function updateDarknodeRegistry(DarknodeRegistry _newDarknodeRegistry) external onlyOwner {

        emit LogDarknodeRegistryUpdated(darknodeRegistry, _newDarknodeRegistry);
        darknodeRegistry = _newDarknodeRegistry;
    }

    function openOrder(uint64 _settlementID, bytes _signature, bytes32 _orderID) external {

        require(orders[_orderID].state == OrderState.Undefined, "invalid order status");

        address trader = msg.sender;

        require(settlementRegistry.settlementRegistration(_settlementID), "settlement not registered");
        BrokerVerifier brokerVerifier = settlementRegistry.brokerVerifierContract(_settlementID);
        require(brokerVerifier.verifyOpenSignature(trader, _signature, _orderID), "invalid broker signature");

        orders[_orderID] = Order({
            state: OrderState.Open,
            trader: trader,
            confirmer: 0x0,
            settlementID: _settlementID,
            priority: orderbook.length + 1,
            blockNumber: block.number,
            matchedOrder: 0x0
        });

        orderbook.push(_orderID);
    }

    function confirmOrder(bytes32 _orderID, bytes32 _matchedOrderID) external onlyDarknode(msg.sender) {

        require(orders[_orderID].state == OrderState.Open, "invalid order status");
        require(orders[_matchedOrderID].state == OrderState.Open, "invalid order status");

        orders[_orderID].state = OrderState.Confirmed;
        orders[_orderID].confirmer = msg.sender;
        orders[_orderID].matchedOrder = _matchedOrderID;
        orders[_orderID].blockNumber = block.number;

        orders[_matchedOrderID].state = OrderState.Confirmed;
        orders[_matchedOrderID].confirmer = msg.sender;
        orders[_matchedOrderID].matchedOrder = _orderID;
        orders[_matchedOrderID].blockNumber = block.number;
    }

    function cancelOrder(bytes32 _orderID) external {

        require(orders[_orderID].state == OrderState.Open, "invalid order state");

        address brokerVerifier = address(settlementRegistry.brokerVerifierContract(orders[_orderID].settlementID));
        require(msg.sender == orders[_orderID].trader || msg.sender == brokerVerifier, "not authorized");

        orders[_orderID].state = OrderState.Canceled;
        orders[_orderID].blockNumber = block.number;
    }

    function orderState(bytes32 _orderID) external view returns (OrderState) {

        return orders[_orderID].state;
    }

    function orderMatch(bytes32 _orderID) external view returns (bytes32) {

        return orders[_orderID].matchedOrder;
    }

    function orderPriority(bytes32 _orderID) external view returns (uint256) {

        return orders[_orderID].priority;
    }

    function orderTrader(bytes32 _orderID) external view returns (address) {

        return orders[_orderID].trader;
    }

    function orderConfirmer(bytes32 _orderID) external view returns (address) {

        return orders[_orderID].confirmer;
    }

    function orderBlockNumber(bytes32 _orderID) external view returns (uint256) {

        return orders[_orderID].blockNumber;
    }

    function orderDepth(bytes32 _orderID) external view returns (uint256) {

        if (orders[_orderID].blockNumber == 0) {
            return 0;
        }
        return (block.number - orders[_orderID].blockNumber);
    }

    function ordersCount() external view returns (uint256) {

        return orderbook.length;
    }

    function getOrders(uint256 _offset, uint256 _limit) external view returns (bytes32[], address[], uint8[]) {

        if (_offset >= orderbook.length) {
            return;
        }

        uint256 limit = _limit;
        if (_offset + limit > orderbook.length) {
            limit = orderbook.length - _offset;
        }

        bytes32[] memory orderIDs = new bytes32[](limit);
        address[] memory traderAddresses = new address[](limit);
        uint8[] memory states = new uint8[](limit);

        for (uint256 i = 0; i < limit; i++) {
            bytes32 order = orderbook[i + _offset];
            orderIDs[i] = order;
            traderAddresses[i] = orders[order].trader;
            states[i] = uint8(orders[order].state);
        }

        return (orderIDs, traderAddresses, states);
    }
}

library SettlementUtils {


    struct OrderDetails {
        uint64 settlementID;
        uint64 tokens;
        uint256 price;
        uint256 volume;
        uint256 minimumVolume;
    }

    function hashOrder(bytes details, OrderDetails memory order) internal pure returns (bytes32) {

        return keccak256(
            abi.encodePacked(
                details,
                order.settlementID,
                order.tokens,
                order.price,
                order.volume,
                order.minimumVolume
            )
        );
    }

    function verifyMatchDetails(OrderDetails memory _buy, OrderDetails memory _sell) internal pure returns (bool) {


        if (!verifyTokens(_buy.tokens, _sell.tokens)) {
            return false;
        }

        if (_buy.price < _sell.price) {
            return false;
        }

        if (_buy.volume < _sell.minimumVolume) {
            return false;
        }

        if (_sell.volume < _buy.minimumVolume) {
            return false;
        }

        if (_buy.settlementID != _sell.settlementID) {
            return false;
        }

        return true;
    }

    function verifyTokens(uint64 _buyTokens, uint64 _sellToken) internal pure returns (bool) {

        return ((
                uint32(_buyTokens) == uint32(_sellToken >> 32)) && (
                uint32(_sellToken) == uint32(_buyTokens >> 32)) && (
                uint32(_buyTokens >> 32) <= uint32(_buyTokens))
        );
    }
}

contract DarknodeSlasher is Ownable {

    string public VERSION; // Passed in as a constructor parameter.

    DarknodeRegistry public trustedDarknodeRegistry;
    Orderbook public trustedOrderbook;

    mapping(bytes32 => bool) public orderSubmitted;
    mapping(bytes32 => mapping(bytes32 => bool)) public challengeSubmitted;
    mapping(bytes32 => SettlementUtils.OrderDetails) public orderDetails;
    mapping(bytes32 => address) public challengers;

    modifier onlyDarknode() {

        require(
            trustedDarknodeRegistry.isRegistered(msg.sender) ||
            trustedDarknodeRegistry.isDeregistered(msg.sender),
            "must be darknode");
        _;
    }

    constructor(string _VERSION, DarknodeRegistry _darknodeRegistry, Orderbook _orderbook) public {
        VERSION = _VERSION;
        trustedDarknodeRegistry = _darknodeRegistry;
        trustedOrderbook = _orderbook;
    }

    function submitChallengeOrder(
        bytes details,
        uint64 settlementID,
        uint64 tokens,
        uint256 price,
        uint256 volume,
        uint256 minimumVolume
    ) external onlyDarknode {

        SettlementUtils.OrderDetails memory order = SettlementUtils.OrderDetails({
            settlementID: settlementID,
            tokens: tokens,
            price: price,
            volume: volume,
            minimumVolume: minimumVolume
        });

        bytes32 orderID = SettlementUtils.hashOrder(details, order);

        require(!orderSubmitted[orderID], "already submitted");

        orderDetails[orderID] = order;
        challengers[orderID] = msg.sender;
        orderSubmitted[orderID] = true;
    }

    function submitChallenge(bytes32 _buyID, bytes32 _sellID) external {

        require(!challengeSubmitted[_buyID][_sellID], "already challenged");

        require(orderSubmitted[_buyID], "details unavailable");
        require(orderSubmitted[_sellID], "details unavailable");

        require(trustedOrderbook.orderMatch(_buyID) == _sellID, "unconfirmed orders");

        bool mismatchedDetails = !SettlementUtils.verifyMatchDetails(orderDetails[_buyID], orderDetails[_sellID]);
        bool nondistinctTrader = trustedOrderbook.orderTrader(_buyID) == trustedOrderbook.orderTrader(_sellID);
        require(mismatchedDetails || nondistinctTrader, "invalid challenge");

        address confirmer = trustedOrderbook.orderConfirmer(_buyID);

        challengeSubmitted[_buyID][_sellID] = true;
        challengeSubmitted[_sellID][_buyID] = true;

        trustedDarknodeRegistry.slash(confirmer, challengers[_buyID], challengers[_sellID]);
    }
}