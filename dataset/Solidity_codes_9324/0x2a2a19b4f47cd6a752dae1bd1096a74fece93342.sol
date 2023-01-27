pragma solidity >=0.4.24;

interface ENS {


    event NewOwner(bytes32 indexed node, bytes32 indexed label, address owner);

    event Transfer(bytes32 indexed node, address owner);

    event NewResolver(bytes32 indexed node, address resolver);

    event NewTTL(bytes32 indexed node, uint64 ttl);


    function setSubnodeOwner(bytes32 node, bytes32 label, address owner) external;

    function setResolver(bytes32 node, address resolver) external;

    function setOwner(bytes32 node, address owner) external;

    function setTTL(bytes32 node, uint64 ttl) external;

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

    function ttl(bytes32 node) external view returns (uint64);


}
pragma solidity ^0.5.0;

contract Ownable {


    address public owner;

    modifier onlyOwner {

        require(isOwner(msg.sender));
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {

        owner = newOwner;
    }

    function isOwner(address addr) public view returns (bool) {

        return owner == addr;
    }
}
pragma solidity ^0.5.0;


contract Controllable is Ownable {

    mapping(address=>bool) public controllers;

    modifier onlyController {

        require(controllers[msg.sender]);
        _;
    }

    function setController(address controller, bool enabled) public onlyOwner {

        controllers[controller] = enabled;
    }
}
pragma solidity ^0.5.0;


contract Root is Ownable, Controllable {

    bytes32 constant private ROOT_NODE = bytes32(0);

    bytes4 constant private INTERFACE_META_ID = bytes4(keccak256("supportsInterface(bytes4)"));

    event TLDLocked(bytes32 indexed label);

    ENS public ens;
    mapping(bytes32=>bool) public locked;

    constructor(ENS _ens) public {
        ens = _ens;
    }

    function setSubnodeOwner(bytes32 label, address owner) external onlyController {

        require(!locked[label]);
        ens.setSubnodeOwner(ROOT_NODE, label, owner);
    }

    function setResolver(address resolver) external onlyOwner {

        ens.setResolver(ROOT_NODE, resolver);
    }

    function lock(bytes32 label) external onlyOwner {

        emit TLDLocked(label);
        locked[label] = true;
    }

    function supportsInterface(bytes4 interfaceID) external pure returns (bool) {

        return interfaceID == INTERFACE_META_ID;
    }
}
pragma solidity >=0.4.24;

interface Deed {


    function setOwner(address payable newOwner) external;

    function setRegistrar(address newRegistrar) external;

    function setBalance(uint newValue, bool throwOnFailure) external;

    function closeDeed(uint refundRatio) external;

    function destroyDeed() external;


    function owner() external view returns (address);

    function previousOwner() external view returns (address);

    function value() external view returns (uint);

    function creationDate() external view returns (uint);


}
pragma solidity ^0.5.0;


contract DeedImplementation is Deed {


    address payable constant burn = address(0xdead);

    address payable private _owner;
    address private _previousOwner;
    address private _registrar;

    uint private _creationDate;
    uint private _value;

    bool active;

    event OwnerChanged(address newOwner);
    event DeedClosed();

    modifier onlyRegistrar {

        require(msg.sender == _registrar);
        _;
    }

    modifier onlyActive {

        require(active);
        _;
    }

    constructor(address payable initialOwner) public payable {
        _owner = initialOwner;
        _registrar = msg.sender;
        _creationDate = now;
        active = true;
        _value = msg.value;
    }

    function setOwner(address payable newOwner) external onlyRegistrar {

        require(newOwner != address(0x0));
        _previousOwner = _owner;  // This allows contracts to check who sent them the ownership
        _owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function setRegistrar(address newRegistrar) external onlyRegistrar {

        _registrar = newRegistrar;
    }

    function setBalance(uint newValue, bool throwOnFailure) external onlyRegistrar onlyActive {

        require(_value >= newValue);
        _value = newValue;
        require(_owner.send(address(this).balance - newValue) || !throwOnFailure);
    }

    function closeDeed(uint refundRatio) external onlyRegistrar onlyActive {

        active = false;
        require(burn.send(((1000 - refundRatio) * address(this).balance)/1000));
        emit DeedClosed();
        _destroyDeed();
    }

    function destroyDeed() external {

        _destroyDeed();
    }

    function owner() external view returns (address) {

        return _owner;
    }

    function previousOwner() external view returns (address) {

        return _previousOwner;
    }

    function value() external view returns (uint) {

        return _value;
    }

    function creationDate() external view returns (uint) {

        _creationDate;
    }

    function _destroyDeed() internal {

        require(!active);

        if (_owner.send(address(this).balance)) {
            selfdestruct(burn);
        }
    }
}
pragma solidity >=0.4.24;


interface Registrar {


    enum Mode { Open, Auction, Owned, Forbidden, Reveal, NotYetAvailable }

    event AuctionStarted(bytes32 indexed hash, uint registrationDate);
    event NewBid(bytes32 indexed hash, address indexed bidder, uint deposit);
    event BidRevealed(bytes32 indexed hash, address indexed owner, uint value, uint8 status);
    event HashRegistered(bytes32 indexed hash, address indexed owner, uint value, uint registrationDate);
    event HashReleased(bytes32 indexed hash, uint value);
    event HashInvalidated(bytes32 indexed hash, string indexed name, uint value, uint registrationDate);

    function startAuction(bytes32 _hash) external;

    function startAuctions(bytes32[] calldata _hashes) external;

    function newBid(bytes32 sealedBid) external payable;

    function startAuctionsAndBid(bytes32[] calldata hashes, bytes32 sealedBid) external payable;

    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) external;

    function cancelBid(address bidder, bytes32 seal) external;

    function finalizeAuction(bytes32 _hash) external;

    function transfer(bytes32 _hash, address payable newOwner) external;

    function releaseDeed(bytes32 _hash) external;

    function invalidateName(string calldata unhashedName) external;

    function eraseNode(bytes32[] calldata labels) external;

    function transferRegistrars(bytes32 _hash) external;

    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) external;

    function entries(bytes32 _hash) external view returns (Mode, address, uint, uint, uint);

}
pragma solidity ^0.5.0;





contract HashRegistrar is Registrar {

    ENS public ens;
    bytes32 public rootNode;

    mapping (bytes32 => Entry) _entries;
    mapping (address => mapping (bytes32 => Deed)) public sealedBids;

    uint32 constant totalAuctionLength = 5 days;
    uint32 constant revealPeriod = 48 hours;
    uint32 public constant launchLength = 8 weeks;

    uint constant minPrice = 0.01 ether;
    uint public registryStarted;

    struct Entry {
        Deed deed;
        uint registrationDate;
        uint value;
        uint highestBid;
    }

    modifier inState(bytes32 _hash, Mode _state) {

        require(state(_hash) == _state);
        _;
    }

    modifier onlyOwner(bytes32 _hash) {

        require(state(_hash) == Mode.Owned && msg.sender == _entries[_hash].deed.owner());
        _;
    }

    modifier registryOpen() {

        require(now >= registryStarted && now <= registryStarted + (365 * 4) * 1 days && ens.owner(rootNode) == address(this));
        _;
    }

    constructor(ENS _ens, bytes32 _rootNode, uint _startDate) public {
        ens = _ens;
        rootNode = _rootNode;
        registryStarted = _startDate > 0 ? _startDate : now;
    }

    function startAuction(bytes32 _hash) external {

        _startAuction(_hash);
    }

    function startAuctions(bytes32[] calldata _hashes) external {

        _startAuctions(_hashes);
    }

    function newBid(bytes32 sealedBid) external payable {

        _newBid(sealedBid);
    }

    function startAuctionsAndBid(bytes32[] calldata hashes, bytes32 sealedBid) external payable {

        _startAuctions(hashes);
        _newBid(sealedBid);
    }

    function unsealBid(bytes32 _hash, uint _value, bytes32 _salt) external {

        bytes32 seal = shaBid(_hash, msg.sender, _value, _salt);
        Deed bid = sealedBids[msg.sender][seal];
        require(address(bid) != address(0x0));

        sealedBids[msg.sender][seal] = Deed(address(0x0));
        Entry storage h = _entries[_hash];
        uint value = min(_value, bid.value());
        bid.setBalance(value, true);

        Mode auctionState = state(_hash);
        if (auctionState == Mode.Owned) {
            bid.closeDeed(5);
            emit BidRevealed(_hash, msg.sender, value, 1);
        } else if (auctionState != Mode.Reveal) {
            revert();
        } else if (value < minPrice || bid.creationDate() > h.registrationDate - revealPeriod) {
            bid.closeDeed(995);
            emit BidRevealed(_hash, msg.sender, value, 0);
        } else if (value > h.highestBid) {
            if (address(h.deed) != address(0x0)) {
                Deed previousWinner = h.deed;
                previousWinner.closeDeed(995);
            }

            h.value = h.highestBid;  // will be zero if there's only 1 bidder
            h.highestBid = value;
            h.deed = bid;
            emit BidRevealed(_hash, msg.sender, value, 2);
        } else if (value > h.value) {
            h.value = value;
            bid.closeDeed(995);
            emit BidRevealed(_hash, msg.sender, value, 3);
        } else {
            bid.closeDeed(995);
            emit BidRevealed(_hash, msg.sender, value, 4);
        }
    }

    function cancelBid(address bidder, bytes32 seal) external {

        Deed bid = sealedBids[bidder][seal];
        
        require(address(bid) != address(0x0) && now >= bid.creationDate() + totalAuctionLength + 2 weeks);

        bid.setOwner(msg.sender);
        bid.closeDeed(5);
        sealedBids[bidder][seal] = Deed(0);
        emit BidRevealed(seal, bidder, 0, 5);
    }

    function finalizeAuction(bytes32 _hash) external onlyOwner(_hash) {

        Entry storage h = _entries[_hash];
        
        h.value = max(h.value, minPrice);
        h.deed.setBalance(h.value, true);

        trySetSubnodeOwner(_hash, h.deed.owner());
        emit HashRegistered(_hash, h.deed.owner(), h.value, h.registrationDate);
    }

    function transfer(bytes32 _hash, address payable newOwner) external onlyOwner(_hash) {

        require(newOwner != address(0x0));

        Entry storage h = _entries[_hash];
        h.deed.setOwner(newOwner);
        trySetSubnodeOwner(_hash, newOwner);
    }

    function releaseDeed(bytes32 _hash) external onlyOwner(_hash) {

        Entry storage h = _entries[_hash];
        Deed deedContract = h.deed;

        require(now >= h.registrationDate + 365 days || ens.owner(rootNode) != address(this));

        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);

        _tryEraseSingleNode(_hash);
        deedContract.closeDeed(1000);
        emit HashReleased(_hash, h.value);        
    }

    function invalidateName(string calldata unhashedName)
        external
        inState(keccak256(abi.encode(unhashedName)), Mode.Owned)
    {

        require(strlen(unhashedName) <= 6);
        bytes32 hash = keccak256(abi.encode(unhashedName));

        Entry storage h = _entries[hash];

        _tryEraseSingleNode(hash);

        if (address(h.deed) != address(0x0)) {
            h.value = max(h.value, minPrice);
            h.deed.setBalance(h.value/2, false);
            h.deed.setOwner(msg.sender);
            h.deed.closeDeed(1000);
        }

        emit HashInvalidated(hash, unhashedName, h.value, h.registrationDate);

        h.value = 0;
        h.highestBid = 0;
        h.deed = Deed(0);
    }

    function eraseNode(bytes32[] calldata labels) external {

        require(labels.length != 0);
        require(state(labels[labels.length - 1]) != Mode.Owned);

        _eraseNodeHierarchy(labels.length - 1, labels, rootNode);
    }

    function transferRegistrars(bytes32 _hash) external onlyOwner(_hash) {

        address registrar = ens.owner(rootNode);
        require(registrar != address(this));

        Entry storage h = _entries[_hash];
        h.deed.setRegistrar(registrar);

        Registrar(registrar).acceptRegistrarTransfer(_hash, h.deed, h.registrationDate);

        h.deed = Deed(0);
        h.registrationDate = 0;
        h.value = 0;
        h.highestBid = 0;
    }

    function acceptRegistrarTransfer(bytes32 hash, Deed deed, uint registrationDate) external {

        hash; deed; registrationDate; // Don't warn about unused variables
    }

    function entries(bytes32 _hash) external view returns (Mode, address, uint, uint, uint) {

        Entry storage h = _entries[_hash];
        return (state(_hash), address(h.deed), h.registrationDate, h.value, h.highestBid);
    }

    function state(bytes32 _hash) public view returns (Mode) {

        Entry storage entry = _entries[_hash];

        if (!isAllowed(_hash, now)) {
            return Mode.NotYetAvailable;
        } else if (now < entry.registrationDate) {
            if (now < entry.registrationDate - revealPeriod) {
                return Mode.Auction;
            } else {
                return Mode.Reveal;
            }
        } else {
            if (entry.highestBid == 0) {
                return Mode.Open;
            } else {
                return Mode.Owned;
            }
        }
    }

    function isAllowed(bytes32 _hash, uint _timestamp) public view returns (bool allowed) {

        return _timestamp > getAllowedTime(_hash);
    }

    function getAllowedTime(bytes32 _hash) public view returns (uint) {

        return registryStarted + ((launchLength * (uint(_hash) >> 128)) >> 128);
    }

    function shaBid(bytes32 hash, address owner, uint value, bytes32 salt) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(hash, owner, value, salt));
    }

    function _tryEraseSingleNode(bytes32 label) internal {

        if (ens.owner(rootNode) == address(this)) {
            ens.setSubnodeOwner(rootNode, label, address(this));
            bytes32 node = keccak256(abi.encodePacked(rootNode, label));
            ens.setResolver(node, address(0x0));
            ens.setOwner(node, address(0x0));
        }
    }

    function _startAuction(bytes32 _hash) internal registryOpen() {

        Mode mode = state(_hash);
        if (mode == Mode.Auction) return;
        require(mode == Mode.Open);

        Entry storage newAuction = _entries[_hash];
        newAuction.registrationDate = now + totalAuctionLength;
        newAuction.value = 0;
        newAuction.highestBid = 0;
        emit AuctionStarted(_hash, newAuction.registrationDate);
    }

    function _startAuctions(bytes32[] memory _hashes) internal {

        for (uint i = 0; i < _hashes.length; i ++) {
            _startAuction(_hashes[i]);
        }
    }

    function _newBid(bytes32 sealedBid) internal {

        require(address(sealedBids[msg.sender][sealedBid]) == address(0x0));
        require(msg.value >= minPrice);

        Deed bid = (new DeedImplementation).value(msg.value)(msg.sender);
        sealedBids[msg.sender][sealedBid] = bid;
        emit NewBid(sealedBid, msg.sender, msg.value);
    }

    function _eraseNodeHierarchy(uint idx, bytes32[] memory labels, bytes32 node) internal {

        ens.setSubnodeOwner(node, labels[idx], address(this));
        node = keccak256(abi.encodePacked(node, labels[idx]));

        if (idx > 0) {
            _eraseNodeHierarchy(idx - 1, labels, node);
        }

        ens.setResolver(node, address(0x0));
        ens.setOwner(node, address(0x0));
    }

    function trySetSubnodeOwner(bytes32 _hash, address _newOwner) internal {

        if (ens.owner(rootNode) == address(this))
            ens.setSubnodeOwner(rootNode, _hash, _newOwner);
    }

    function max(uint a, uint b) internal pure returns (uint) {

        if (a > b)
            return a;
        else
            return b;
    }

    function min(uint a, uint b) internal pure returns (uint) {

        if (a < b)
            return a;
        else
            return b;
    }

    function strlen(string memory s) internal pure returns (uint) {

        s; // Don't warn about unused variables
        uint ptr;
        uint end;
        assembly {
            ptr := add(s, 1)
            end := add(mload(s), ptr)
        }
        uint len = 0;
        for (len; ptr < end; len++) {
            uint8 b;
            assembly { b := and(mload(ptr), 0xFF) }
            if (b < 0x80) {
                ptr += 1;
            } else if (b < 0xE0) {
                ptr += 2;
            } else if (b < 0xF0) {
                ptr += 3;
            } else if (b < 0xF8) {
                ptr += 4;
            } else if (b < 0xFC) {
                ptr += 5;
            } else {
                ptr += 6;
            }
        }
        return len;
    }

}
pragma solidity ^0.5.0;



contract UsedByFactories is Ownable {


    mapping(address => bool) public isFactory;

    modifier onlyFactory() {

        require(isFactory[msg.sender]);
        _;
    }

    function setFactories(address[] memory factories, bool _isFactory)
    public
    onlyOwner
    {

        for(uint i = 0; i < factories.length; i++) {
            isFactory[factories[i]] = _isFactory;
        }
    }
}pragma solidity ^0.5.0;





contract OfferingRegistry is UsedByFactories {


  event onOfferingAdded(address indexed offering, bytes32 indexed node, address indexed owner, uint version);
  event onOfferingChanged(address indexed offering, uint version, bytes32 indexed eventType, uint[] extraData);

  address public emergencyMultisig;                           // Emergency Multisig wallet of Namebazaar
  bool public isEmergencyPaused = false;                      // Variable to pause buying activity on all offerings
  mapping (address => bool) public isOffering;                // Stores whether given address of namebazaar offering


  modifier onlyEmergencyMultisig() {

    require(msg.sender == emergencyMultisig);
    _;
  }

  constructor(address _emergencyMultisig) public {
    emergencyMultisig = _emergencyMultisig;
  }

  function addOffering(address offering, bytes32 node, address owner, uint version)
  public
  onlyFactory
  {

    isOffering[offering] = true;
    emit onOfferingAdded(offering, node, owner, version);
  }


  function fireOnOfferingChanged(uint version, bytes32 eventType, uint[] memory extraData) public {

    require(isOffering[msg.sender]);
    emit onOfferingChanged(msg.sender, version, eventType, extraData);
  }

  function emergencyPause() onlyEmergencyMultisig public {

    isEmergencyPaused = true;
  }

  function emergencyRelease() onlyEmergencyMultisig public {

    isEmergencyPaused = false;
  }
}pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
pragma solidity ^0.5.0;



contract Offering {


    struct Offering {
        bytes32 node;                       // ENS node
        string name;                        // full ENS name
        bytes32 labelHash;                  // hash of ENS label
        address originalOwner;              // owner of ENS name, creator of offering
        address newOwner;                   // Address of a new owner of ENS name, buyer
        uint price;                         // Price of the offering, or the highest bid in auction
        uint128 version;                    // version of offering contract
        uint64 createdOn;                   // Time when offering was created
        uint64 finalizedOn;                 // Time when ENS name was transferred to a new owner
    }

    Offering public offering;

    ENS public ens = ENS(0x314159265dD8dbb310642f98f50C066173C1259b);

    bytes32 public constant rootNode = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

    OfferingRegistry public offeringRegistry = OfferingRegistry(0xfEEDFEEDfeEDFEedFEEdFEEDFeEdfEEdFeEdFEEd);

    address public emergencyMultisig = 0xDeEDdeeDDEeDDEEdDEedDEEdDEeDdEeDDEEDDeed;

    constructor(ENS _ens, OfferingRegistry _offeringRegistry, address _emergencyMultisig) public {
        ens = _ens;
        offeringRegistry = _offeringRegistry;
        emergencyMultisig = _emergencyMultisig;
    }

    modifier onlyOriginalOwner() {

        require(isSenderOriginalOwner());
        _;
    }

    modifier onlyEmergencyMultisig() {

        require(isSenderEmergencyMultisig());
        _;
    }

    modifier onlyWithoutNewOwner() {

        require(offering.newOwner == address(0));
        _;
    }

    modifier onlyWhenContractIsNodeOwner() {

        require(isContractNodeOwner());
        _;
    }


    modifier onlyWhenNotEmergencyPaused() {

        require(!offeringRegistry.isEmergencyPaused());
        _;
    }

    modifier onlyWhenContractIsNotNodeOwner() {

        require(!isContractNodeOwner());
        _;
    }

    function construct(
        bytes32 _node,
        string memory _name,
        bytes32 _labelHash,
        address _originalOwner,
        uint128 _version,
        uint _price
    )
    public
    onlyWhenNotEmergencyPaused
    {

        require(offering.createdOn == 0);               // Prevent constructing multiple times
        offering.node = _node;
        offering.name = _name;
        offering.labelHash = _labelHash;
        offering.originalOwner = _originalOwner;
        offering.version = _version;
        offering.createdOn = uint64(now);
        offering.price = _price;
    }

    function unregister()
    public
    onlyOriginalOwner
    onlyWithoutNewOwner
    onlyWhenContractIsNotNodeOwner
    {

        offering.newOwner = address(0xdeaddead);
        fireOnChanged("unregister");
    }

    function reclaimOwnership()
    public
    onlyWithoutNewOwner
    {

        bool isEmergency = isSenderEmergencyMultisig();
        require(isEmergency || isSenderOriginalOwner());

        if (isContractNodeOwner()) {
            doTransferOwnership(offering.originalOwner);
        }
        if (isEmergency) {
            offering.newOwner = address(0xdead);
        }
        fireOnChanged("reclaimOwnership");
    }

    function transferOwnership(address _newOwner)
    internal
    onlyWhenNotEmergencyPaused
    onlyWithoutNewOwner
    {

        offering.newOwner = _newOwner;
        offering.finalizedOn = uint64(now);
        doTransferOwnership(_newOwner);
        fireOnChanged("finalize");
    }

    function doTransferOwnership(address _newOwner)
    private
    {

        address payable newOwner = address(uint160(_newOwner));
        if (isNodeTLDOfRegistrar()) {
            HashRegistrar(ens.owner(rootNode)).transfer(offering.labelHash, newOwner);
        } else {
            ens.setOwner(offering.node, newOwner);
        }
    }

    function doSetSettings(uint _price)
    internal
    {

        offering.price = _price;
    }

    function fireOnChanged(bytes32 eventType, uint[] memory extraData)
    internal
    {

        offeringRegistry.fireOnOfferingChanged(offering.version, eventType, extraData);
    }

    function fireOnChanged(bytes32 eventType) internal {

        fireOnChanged(eventType, new uint[](0));
    }

    function isContractNodeOwner() public view returns(bool) {

        if (isNodeTLDOfRegistrar()) {
            address deed;
            (,deed,,,) = HashRegistrar(ens.owner(rootNode)).entries(offering.labelHash);
            return ens.owner(offering.node) == address(this) &&
            Deed(deed).owner() == address(this);
        } else {
            return ens.owner(offering.node) == address(this);
        }
    }

    function buy()
    public
    payable
    {

        require(msg.value == offering.price);
        address payable origOwner = address(uint160(offering.originalOwner));
        origOwner.transfer(offering.price);
        transferOwnership(msg.sender);
    }

    function isNodeTLDOfRegistrar() public view returns (bool) {

        return offering.node == keccak256(abi.encodePacked(rootNode, offering.labelHash));
    }

    function isSenderOriginalOwner() public view returns(bool) {

        return msg.sender == offering.originalOwner;
    }

    function isSenderEmergencyMultisig() public view returns(bool) {

        return msg.sender == emergencyMultisig;
    }

    function wasEmergencyCancelled() public view returns(bool) {

        return offering.newOwner == address(0xdead);
    }
}

pragma solidity ^0.5.0;


contract MultiSigWallet {


  uint constant public MAX_OWNER_COUNT = 50;

  event Confirmation(address indexed sender, uint indexed transactionId);
  event Revocation(address indexed sender, uint indexed transactionId);
  event Submission(uint indexed transactionId);
  event Execution(uint indexed transactionId, bytes data);
  event ExecutionFailure(uint indexed transactionId);
  event Deposit(address indexed sender, uint value);
  event OwnerAddition(address indexed owner);
  event OwnerRemoval(address indexed owner);
  event RequirementChange(uint required);

  mapping (uint => Transaction) public transactions;
  mapping (uint => mapping (address => bool)) public confirmations;
  mapping (address => bool) public isOwner;
  address[] public owners;
  uint public required;
  uint public transactionCount;

  struct Transaction {
    address destination;
    uint value;
    bytes data;
    bool executed;
  }

  modifier onlyWallet() {

    if (msg.sender != address(this))
      revert();
    _;
  }

  modifier ownerDoesNotExist(address owner) {

    if (isOwner[owner])
      revert();
    _;
  }

  modifier ownerExists(address owner) {

    if (!isOwner[owner])
      revert();
    _;
  }

  modifier transactionExists(uint transactionId) {

    if (transactions[transactionId].destination == address(0))
      revert();
    _;
  }

  modifier confirmed(uint transactionId, address owner) {

    if (!confirmations[transactionId][owner])
      revert();
    _;
  }

  modifier notConfirmed(uint transactionId, address owner) {

    if (confirmations[transactionId][owner])
      revert();
    _;
  }

  modifier notExecuted(uint transactionId) {

    if (transactions[transactionId].executed)
      revert();
    _;
  }

  modifier notNull(address _address) {

    if (_address == address(0))
      revert();
    _;
  }

  modifier validRequirement(uint ownerCount, uint _required) {

    if (   ownerCount > MAX_OWNER_COUNT
    || _required > ownerCount
    || _required == 0
    || ownerCount == 0)
      revert();
    _;
  }

  constructor(address[] memory _owners, uint _required)
  public
  validRequirement(_owners.length, _required)
  {
    for (uint i=0; i<_owners.length; i++) {
      if (isOwner[_owners[i]] || _owners[i] == address(0))
        revert();
      isOwner[_owners[i]] = true;
    }
    owners = _owners;
    required = _required;
  }

  function addOwner(address owner)
  public
  onlyWallet
  ownerDoesNotExist(owner)
  notNull(owner)
  validRequirement(owners.length + 1, required)
  {

    isOwner[owner] = true;
    owners.push(owner);
    emit OwnerAddition(owner);
  }

  function removeOwner(address owner)
  public
  onlyWallet
  ownerExists(owner)
  {

    isOwner[owner] = false;
    for (uint i=0; i<owners.length - 1; i++)
      if (owners[i] == owner) {
        owners[i] = owners[owners.length - 1];
        break;
      }
    owners.length -= 1;
    if (required > owners.length)
      changeRequirement(owners.length);
    emit OwnerRemoval(owner);
  }

  function replaceOwner(address owner, address newOwner)
  public
  onlyWallet
  ownerExists(owner)
  ownerDoesNotExist(newOwner)
  {

    for (uint i=0; i<owners.length; i++)
      if (owners[i] == owner) {
        owners[i] = newOwner;
        break;
      }
    isOwner[owner] = false;
    isOwner[newOwner] = true;
    emit OwnerRemoval(owner);
    emit OwnerAddition(newOwner);
  }

  function changeRequirement(uint _required)
  public
  onlyWallet
  validRequirement(owners.length, _required)
  {

    required = _required;
    emit RequirementChange(_required);
  }

  function submitTransaction(address destination, uint value, bytes memory data)
  public
  returns (uint transactionId)
  {

    transactionId = addTransaction(destination, value, data);
    confirmTransaction(transactionId);
  }

  function confirmTransaction(uint transactionId)
  public
  ownerExists(msg.sender)
  transactionExists(transactionId)
  notConfirmed(transactionId, msg.sender)
  {

    confirmations[transactionId][msg.sender] = true;
    emit Confirmation(msg.sender, transactionId);
    executeTransaction(transactionId);
  }

  function revokeConfirmation(uint transactionId)
  public
  ownerExists(msg.sender)
  confirmed(transactionId, msg.sender)
  notExecuted(transactionId)
  {

    confirmations[transactionId][msg.sender] = false;
    emit Revocation(msg.sender, transactionId);
  }

  function executeTransaction(uint transactionId)
  public
  notExecuted(transactionId)
  {

    if (isConfirmed(transactionId)) {
      Transaction storage tx = transactions[transactionId];
      tx.executed = true;
      bool success;
      (success,) = tx.destination.call.value(tx.value)(tx.data);
      if (success)
        emit Execution(transactionId, tx.data);
      else {
        emit ExecutionFailure(transactionId);
        tx.executed = false;
      }
    }
  }

  function isConfirmed(uint transactionId)
  public
  view
  returns (bool)
  {

    uint count = 0;
    for (uint i=0; i<owners.length; i++) {
      if (confirmations[transactionId][owners[i]])
        count += 1;
      if (count == required)
        return true;
    }
  }

  function addTransaction(address destination, uint value, bytes memory data)
  internal
  notNull(destination)
  returns (uint transactionId)
  {

    transactionId = transactionCount;
    transactions[transactionId] = Transaction({
      destination: destination,
      value: value,
      data: data,
      executed: false
      });
    transactionCount += 1;
    emit Submission(transactionId);
  }

  function getConfirmationCount(uint transactionId)
  public
  view
  returns (uint count)
  {

    for (uint i=0; i<owners.length; i++)
      if (confirmations[transactionId][owners[i]])
        count += 1;
  }

  function getTransactionCount(bool pending, bool executed)
  public
  view
  returns (uint count)
  {

    for (uint i=0; i<transactionCount; i++)
      if (   pending && !transactions[i].executed
      || executed && transactions[i].executed)
        count += 1;
  }

  function getOwners()
  public
  view
  returns (address[] memory)
  {

    return owners;
  }

  function getConfirmations(uint transactionId)
  public
  view
  returns (address[] memory _confirmations)
  {

    address[] memory confirmationsTemp = new address[](owners.length);
    uint count = 0;
    uint i;
    for (i=0; i<owners.length; i++)
      if (confirmations[transactionId][owners[i]]) {
        confirmationsTemp[count] = owners[i];
        count += 1;
      }
    _confirmations = new address[](count);
    for (i=0; i<count; i++)
      _confirmations[i] = confirmationsTemp[i];
  }

  function getTransactionIds(uint from, uint to, bool pending, bool executed)
  public
  view
  returns (uint[] memory _transactionIds)
  {

    uint[] memory transactionIdsTemp = new uint[](transactionCount);
    uint count = 0;
    uint i;
    for (i=0; i<transactionCount; i++)
      if (   pending && !transactions[i].executed
      || executed && transactions[i].executed)
      {
        transactionIdsTemp[count] = i;
        count += 1;
      }
    _transactionIds = new uint[](to - from);
    for (i=from; i<to; i++)
      _transactionIds[i - from] = transactionIdsTemp[i];
  }
}pragma solidity ^0.5.0;



contract NameBazaarRescue is Ownable {

  bytes32 constant public ETH_NODE = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;
  bytes32 constant public ETH_LABEL = 0x4f5b812789fc606be1b3b16908db13fc7a9adf7ca72641f84d75b47069d3d7f0;

  Root public root;
  OfferingRegistry public offeringRegistry;
  address public previousRegistrar;

  event ReclaimSuccess(address offering, uint transactionId);

  constructor(address _root, address _offeringRegistry, address _previousRegistrar) public {
    require(_root != address(0));
    require(_offeringRegistry != address(0));
    require(_previousRegistrar != address(0));

    root = Root(_root);
    offeringRegistry = OfferingRegistry(_offeringRegistry);
    previousRegistrar = _previousRegistrar;
  }

  function reclaimOwnerships(address[] memory offerings) public onlyOwner {

    address originalNodeOwner = root.ens().owner(ETH_NODE);
    MultiSigWallet emergencyMultisig = MultiSigWallet(offeringRegistry.emergencyMultisig());

    root.setSubnodeOwner(ETH_LABEL, previousRegistrar);

    for (uint i = 0; i < offerings.length; i++) {
      require(offeringRegistry.isOffering(offerings[i]));
      bool executed = false;
      uint txId = emergencyMultisig.submitTransaction(offerings[i], 0, abi.encodeWithSignature("reclaimOwnership()"));
      (,,,executed) = emergencyMultisig.transactions(txId);

      if (executed) {
        emit ReclaimSuccess(offerings[i], txId);
      } else {
        revert("reclaimOwnership transaction couldn't be executed");
      }
    }

    root.setSubnodeOwner(ETH_LABEL, originalNodeOwner);
  }

}
pragma solidity ^0.5.0;



contract OfferingFactory {


    ENS public ens;
    OfferingRegistry public offeringRegistry;

    bytes32 public constant rootNode = 0x93cdeb708b7545dc668eb9280176169d1c33cfd8ed6f04690a0bcc88a93fc4ae;

    constructor (
        ENS _ens,
        OfferingRegistry _offeringRegistry
    ) public {
        ens = _ens;
        offeringRegistry = _offeringRegistry;
    }

    function createOffering(
        bytes32 node,
        string memory name,
        bytes32 labelHash,
        uint price
    ) public {

        Offering newOffering = new Offering(ens, offeringRegistry, offeringRegistry.emergencyMultisig());
        uint8 version = 1;

        newOffering.construct(
            node,
            name,
            labelHash,
            msg.sender,
            version,
            price
        );

        registerOffering(node, labelHash, address(newOffering), version);
    }

    function registerOffering(bytes32 node, bytes32 labelHash, address newOffering, uint version)
        internal
    {

        require(ens.owner(node) == msg.sender);
        if (node == keccak256(abi.encodePacked(rootNode, labelHash))) {
            address deed;
            (,deed,,,) = HashRegistrar(ens.owner(rootNode)).entries(labelHash);
            require(Deed(deed).owner() == msg.sender);
        }

        offeringRegistry.addOffering(newOffering, node, msg.sender, version);
    }
}