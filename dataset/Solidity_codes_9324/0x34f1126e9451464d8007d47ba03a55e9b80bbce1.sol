

pragma solidity ^0.8.0;

interface LinkTokenInterface {


  function allowance(
    address owner,
    address spender
  )
    external
    view
    returns (
      uint256 remaining
    );


  function approve(
    address spender,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function balanceOf(
    address owner
  )
    external
    view
    returns (
      uint256 balance
    );


  function decimals()
    external
    view
    returns (
      uint8 decimalPlaces
    );


  function decreaseApproval(
    address spender,
    uint256 addedValue
  )
    external
    returns (
      bool success
    );


  function increaseApproval(
    address spender,
    uint256 subtractedValue
  ) external;


  function name()
    external
    view
    returns (
      string memory tokenName
    );


  function symbol()
    external
    view
    returns (
      string memory tokenSymbol
    );


  function totalSupply()
    external
    view
    returns (
      uint256 totalTokensIssued
    );


  function transfer(
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


  function transferAndCall(
    address to,
    uint256 value,
    bytes calldata data
  )
    external
    returns (
      bool success
    );


  function transferFrom(
    address from,
    address to,
    uint256 value
  )
    external
    returns (
      bool success
    );


}


pragma solidity ^0.8.0;

contract VRFRequestIDBase {


  function makeVRFInputSeed(
    bytes32 _keyHash,
    uint256 _userSeed,
    address _requester,
    uint256 _nonce
  )
    internal
    pure
    returns (
      uint256
    )
  {

    return uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash,
    uint256 _vRFInputSeed
  )
    internal
    pure
    returns (
      bytes32
    )
  {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}


pragma solidity ^0.8.0;



abstract contract VRFConsumerBase is VRFRequestIDBase {

  function fulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    internal
    virtual;

  uint256 constant private USER_SEED_PLACEHOLDER = 0;

  function requestRandomness(
    bytes32 _keyHash,
    uint256 _fee
  )
    internal
    returns (
      bytes32 requestId
    )
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, USER_SEED_PLACEHOLDER));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, USER_SEED_PLACEHOLDER, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash] + 1;
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(
    address _vrfCoordinator,
    address _link
  ) {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(
    bytes32 requestId,
    uint256 randomness
  )
    external
  {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}



pragma solidity ^0.8.0;

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
            set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex

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


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
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


pragma solidity >=0.7.0 <0.9.0;


contract OwnershipAgreementv3 {


    uint constant private resTypeNone = 0; // This indicates that the resolution hasn't been set (default value)
    uint constant private resTypeAddOwner = 1;
    uint constant private resTypeRemoveOwner = 2;
    uint constant private resTypeReplaceOwner = 3;
    uint constant private resTypeAddOperator = 4;
    uint constant private resTypeRemoveOperator = 5;
    uint constant private resTypeReplaceOperator = 6;
    uint constant private resTypeUpdateThreshold = 7;
    uint constant private resTypeUpdateTransactionLimit = 8;
    uint constant private resTypePause = 9;
    uint constant private resTypeUnpause = 10;
    uint constant private resTypeCustom = 1000; // Custom resoutions for each subclass

    struct Resolution {
        bool passed;
        uint256 resType;
        address oldAddress;
        address newAddress;
        bytes32[] extra;
    }
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.AddressSet private _owners;
    bool private _paused;
    EnumerableSet.AddressSet private _operators;
    uint256 public operatorLimit = 1;
    uint256 public ownerAgreementThreshold = 1;
    uint256 public transactionLimit = 0;
    mapping(address => mapping(uint256 => bool)) public ownerVotes;
    uint256 public nextResolution = 1;
    mapping(address => uint256) lastOwnerResolutionNumber;
    mapping(uint256 => Resolution) public resolutions;

    event OwnerAddition(address owner);
    event OwnerRemoval(address owner);
    event OwnerReplacement(address oldOwner, address newOwner);

    event OperatorAddition(address newOperator);
    event OperatorRemoval(address oldOperator);
    event OperatorReplacement(address oldOperator, address newOperator);

    event UpdateThreshold(uint256 newThreshold);
    event UpdateNumberOfOperators(uint256 newOperators);
    event UpdateTransactionLimit(uint256 newLimit);
    event Paused(address account);
    event Unpaused(address account);

    function isValidAddress(address newAddr) public pure {

        require(newAddr != address(0), "Invaild Address");
    }

    modifier onlyOperators() {

        isValidAddress(msg.sender);
        require(
            EnumerableSet.contains(_operators, msg.sender) == true,
            "Only the operator can run this function."
        );
        _;
    }
    modifier onlyOwners() {

        isValidAddress(msg.sender);
        require(
            EnumerableSet.contains(_owners, msg.sender) == true,
            "Only an owner can run this function."
        );
        _;
    }

    modifier onlyOwnersOrOperator() {

        isValidAddress(msg.sender);
        require(
            EnumerableSet.contains(_operators, msg.sender) == true ||
                EnumerableSet.contains(_owners, msg.sender) == true,
            "Only an owner or the operator can run this function."
        );
        _;
    }

    modifier ownerExists(address thisOwner) {

        require(
            EnumerableSet.contains(_owners, thisOwner) == true,
            "Owner does not exists."
        );
        _;
    }

    modifier whenNotPaused() {

        require(!_paused, "Smart Contract is paused");
        _;
    }

    modifier whenPaused() {

        require(_paused, "Smart Contract is not paused");
        _;
    }

    modifier withinLimit(uint256 amount) {

        require(
            transactionLimit == 0 || amount <= transactionLimit,
            "Amount is over the transaction limit"
        );
        _;
    }

    constructor() {
        _addOwner(msg.sender);
        _paused = false;
    }


    function owner() public view virtual returns (address) {

        if(EnumerableSet.length(_owners) == 0) return address(0);
        return EnumerableSet.at(_owners, 0);
    }

    function getOwners() public view returns (address[] memory) {

        uint256 len = EnumerableSet.length(_owners);
        address[] memory o = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            o[i] = EnumerableSet.at(_owners, i);
        }

        return o;
    }

    function getNumberOfOwners() public view returns (uint) {

        return EnumerableSet.length(_owners);
    }

    function getOperators() public view returns (address[] memory) {

        uint256 len = EnumerableSet.length(_operators);
        address[] memory o = new address[](len);

        for (uint256 i = 0; i < len; i++) {
            o[i] = EnumerableSet.at(_operators, i);
        }

        return o;
    }

    function getNumberOfOperators() public view returns (uint8) {

        return uint8(EnumerableSet.length(_operators));
    }

    function getVoteThreshold() public view returns (uint256) {

        return ownerAgreementThreshold;
    }

    function getTransactionLimit() public view returns (uint256) {

        return transactionLimit;
    }

    function getNextResolutionNumber() public view returns (uint256) {

        return nextResolution;
    }

    function getLastOwnerResolutionNumber(address thisOwner)
        public
        view
        returns (uint256)
    {

        return lastOwnerResolutionNumber[thisOwner];
    }

    function paused() public view returns (bool) {

        return _paused;
    }

    function resolutionAlreadyUsed(uint256 resNum) public view {

        require(
            !(resolutions[resNum].oldAddress != address(0) ||
                resolutions[resNum].newAddress != address(0)),
            "Resolution is already in use."
        );
    }

    function isResolutionPassed(uint256 resNum) public view returns (bool) {

        return resolutions[resNum].passed;
    }

    function canResolutionPass(uint256 resNum) public view returns (bool) {

        uint256 voteCount = 0;
        uint256 len = EnumerableSet.length(_owners);

        for (uint256 i = 0; i < len; i++) {
            if (ownerVotes[EnumerableSet.at(_owners, i)][resNum] == true) {
                voteCount++;
            }
        }

        return voteCount >= ownerAgreementThreshold;
    }


    function voteResolution(uint256 resNum) public onlyOwners() returns (bool) {

        ownerVotes[msg.sender][resNum] = true;

        if (isResolutionPassed(resNum)) {
            return true;
        }

        if (canResolutionPass(resNum)) {
            _performResolution(resNum);
            return true;
        }

        return false;
    }

    function createResolutionAddOwner(address newOwner) public onlyOwners() {

        isValidAddress(newOwner);
        require(
            !EnumerableSet.contains(_owners, newOwner),
            "newOwner already exists."
        );

        createResolution(resTypeAddOwner, address(0), newOwner, new bytes32[](0));
    }

    function createResolutionRemoveOwner(address oldOwner) public onlyOwners() {

        isValidAddress(oldOwner);
        require(getNumberOfOwners() > 1, "Must always be one owner");
        require(
            EnumerableSet.contains(_owners, oldOwner),
            "owner is not an owner."
        );

        createResolution(resTypeRemoveOwner, oldOwner, address(0), new bytes32[](0));
    }

    function createResolutionReplaceOwner(address oldOwner, address newOwner)
        public
        onlyOwners()
    {

        isValidAddress(oldOwner);
        isValidAddress(newOwner);
        require(
            EnumerableSet.contains(_owners, oldOwner),
            "oldOwner is not an owner."
        );
        require(
            !EnumerableSet.contains(_owners, newOwner),
            "newOwner already exists."
        );

        createResolution(resTypeReplaceOwner, oldOwner, newOwner, new bytes32[](0));
    }

    function createResolutionAddOperator(address newOperator)
        public
        onlyOwners()
    {

        isValidAddress(newOperator);
        require(
            !EnumerableSet.contains(_operators, newOperator),
            "newOperator already exists."
        );

        createResolution(resTypeAddOperator, address(0), newOperator, new bytes32[](0));
    }

    function createResolutionRemoveOperator(address operator)
        public
        onlyOwners()
    {

        require(
            EnumerableSet.contains(_operators, operator),
            "operator is not an Operator."
        );
        createResolution(resTypeRemoveOperator, operator, address(0), new bytes32[](0));
    }

    function createResolutionReplaceOperator(
        address oldOperator,
        address newOperator
    ) public onlyOwners() {

        isValidAddress(oldOperator);
        isValidAddress(newOperator);
        require(
            EnumerableSet.contains(_operators, oldOperator),
            "oldOperator is not an Operator."
        );
        require(
            !EnumerableSet.contains(_operators, newOperator),
            "newOperator already exists."
        );

        createResolution(resTypeReplaceOperator, oldOperator, newOperator,new bytes32[](0));
    }

    function createResolutionUpdateTransactionLimit(uint160 newLimit)
        public
        onlyOwners()
    {

        createResolution(
            resTypeUpdateTransactionLimit,
            address(0),
            address(newLimit),
            new bytes32[](0)
        );
    }

    function createResolutionUpdateThreshold(uint160 threshold)
        public
        onlyOwners()
    {

        createResolution(
            resTypeUpdateThreshold,
            address(0),
            address(threshold),
            new bytes32[](0)
        );
    }

    function pause() public onlyOwners() {

        _pause();
    }

    function createResolutionUnpause() public onlyOwners() {

        createResolution(resTypeUnpause, address(1), address(1), new bytes32[](0));
    }

    function createResolution(
        uint256 resType,
        address oldAddress,
        address newAddress,
        bytes32[] memory extra
    ) internal {

        uint256 resNum = nextResolution;
        nextResolution++;
        resolutionAlreadyUsed(resNum);

        resolutions[resNum].resType = resType;
        resolutions[resNum].oldAddress = oldAddress;
        resolutions[resNum].newAddress = newAddress;
        resolutions[resNum].extra = extra;

        ownerVotes[msg.sender][resNum] = true;
        lastOwnerResolutionNumber[msg.sender] = resNum;

        if (ownerAgreementThreshold <= 1) {
            _performResolution(resNum);
        }
    }

    function _performResolution(uint256 resNum) internal {

        if (resolutions[resNum].resType == resTypeAddOwner) {
            _addOwner(resolutions[resNum].newAddress);
        } else if (resolutions[resNum].resType == resTypeRemoveOwner) {
            _removeOwner(resolutions[resNum].oldAddress);
        } else if (resolutions[resNum].resType == resTypeReplaceOwner) {
            _replaceOwner(
                resolutions[resNum].oldAddress,
                resolutions[resNum].newAddress
            );
        } else if (resolutions[resNum].resType == resTypeAddOperator) {
            _addOperator(resolutions[resNum].newAddress);
        } else if (resolutions[resNum].resType == resTypeRemoveOperator) {
            _removeOperator(resolutions[resNum].oldAddress);
        } else if (resolutions[resNum].resType == resTypeReplaceOperator) {
            _replaceOperator(
                resolutions[resNum].oldAddress,
                resolutions[resNum].newAddress
            );
        } else if (
            resolutions[resNum].resType == resTypeUpdateTransactionLimit
        ) {
            _updateTransactionLimit(uint160(resolutions[resNum].newAddress));
        } else if (resolutions[resNum].resType == resTypeUpdateThreshold) {
            _updateThreshold(uint160(resolutions[resNum].newAddress));
        } else if (resolutions[resNum].resType == resTypePause) {
            _pause();
        } else if (resolutions[resNum].resType == resTypeUnpause) {
            _unpause();
        } else {
            _customResolutions(resNum);
            return;
        }

        resolutions[resNum].passed = true;
    }

    function _customResolutions(uint256 resNum) internal virtual {}


    function _addOwner(address newOwner) internal {

        EnumerableSet.add(_owners, newOwner);
        emit OwnerAddition(newOwner);
    }

    function _removeOwner(address newOwner) internal {

        EnumerableSet.remove(_owners, newOwner);
        emit OwnerRemoval(newOwner);

        uint numOwners = getNumberOfOwners();
        if (ownerAgreementThreshold > numOwners) {
            _updateThreshold(numOwners);
        }
    }

    function _replaceOwner(address oldOwner, address newOwner) internal {

        EnumerableSet.remove(_owners, oldOwner);
        EnumerableSet.add(_owners, newOwner);
        emit OwnerReplacement(oldOwner, newOwner);
    }

    function _addOperator(address operator) internal {

        EnumerableSet.add(_operators, operator);
        emit OperatorAddition(operator);
    }

    function _removeOperator(address operator) internal {

        EnumerableSet.remove(_operators, operator);
        emit OperatorRemoval(operator);
    }

    function _replaceOperator(address oldOperator, address newOperator)
        internal
    {

        emit OperatorReplacement(oldOperator, newOperator);
        EnumerableSet.remove(_operators, oldOperator);
        EnumerableSet.add(_operators, newOperator);
    }

    function _updateTransactionLimit(uint256 newLimit) internal {

        emit UpdateTransactionLimit(newLimit);
        transactionLimit = newLimit;
    }

    function _updateThreshold(uint threshold) internal {

        require(
            threshold <= getNumberOfOwners(),
            "Unable to set threshold above the number of owners"
        );
        emit UpdateThreshold(threshold);
        ownerAgreementThreshold = threshold;
    }

    function _updateNumberOfOperators(uint160 numOperators) internal {

        require(
            numOperators >= getNumberOfOperators(),
            "Unable to set number of Operators below the number of operators"
        );
        emit UpdateNumberOfOperators(numOperators);
        operatorLimit = numOperators;
    }

    function _pause() internal virtual whenNotPaused {

        _paused = true;
        emit Paused(msg.sender);
    }

    function _unpause() internal virtual whenPaused {

        _paused = false;
        emit Unpaused(msg.sender);
    }
}


pragma solidity >=0.7.0 <0.9.0;



contract UreeqaRandomNumberv1 is OwnershipAgreementv3, VRFConsumerBase {

    struct RandomNumber {
        uint256 id;
        bytes32 fileHash;
        bytes32 requestId;
        uint256 blockTime;
        uint256 blockNumber;
        uint256 randomNumber;
    }

    bytes32 keyHash;
    uint256 fee;

    mapping(uint256 => RandomNumber) randomNumbers;
    mapping(bytes32 => uint256) requestIdToId;
    uint256 lastId;
    uint256 numberOfRandomNumbers;
    mapping(bytes32 => uint256) hashToId;

    constructor(
        address vrfCoordinator,
        address linkToken,
        bytes32 _keyHash,
        uint256 _fee,
        address operator
    ) VRFConsumerBase(vrfCoordinator, linkToken) {
        keyHash = _keyHash;
        fee = _fee;
        if (operator != address(0)) {
            createResolutionAddOperator(operator);
        }
    }

    event NewRandomNumber(uint256 id, bytes32 fileHash);

    event RandomNumberGenerated(
        uint256 id,
        bytes32 fileHash,
        uint256 blockNumber,
        uint256 randomNumber
    );

    event FileHashChanged(
        uint256 id,
        bytes32 old_fileHash,
        bytes32 new_fileHash
    );


    modifier nonZeroId(uint256 id) {

        require(id != 0, "Content Staking ID cannot be 0.");
        _;
    }
    modifier nonZeroFileHash(bytes32 fileHash) {

        require(fileHash != 0, "File hash cannot be 0.");
        _;
    }
    modifier idMustExists(uint256 id) {

        require(randomNumbers[id].id != 0, "ID does not exists");
        _;
    }
    modifier idMustBeUnique(uint256 id) {

        require(randomNumbers[id].id == 0, "ID must be unique");
        _;
    }
    modifier hashMustBeUnique(bytes32 fileHash) {

        require(hashToId[fileHash] == 0, "File Hash must be unique");
        _;
    }


    function getLastId() public view returns (uint256) {

        return lastId;
    }

    function getId(bytes32 fileHash)
        public
        view
        nonZeroFileHash(fileHash)
        returns (uint256)
    {

        return hashToId[fileHash];
    }

    function getFileHash(uint256 id)
        public
        view
        nonZeroId(id)
        idMustExists(id)
        returns (bytes32)
    {

        return randomNumbers[id].fileHash;
    }

    function getBlockTime(uint256 id)
        public
        view
        nonZeroId(id)
        idMustExists(id)
        returns (uint256)
    {

        return randomNumbers[id].blockTime;
    }

    function getBlockNumber(uint256 id)
        public
        view
        nonZeroId(id)
        idMustExists(id)
        returns (uint256)
    {

        return randomNumbers[id].blockNumber;
    }

    function getRandomNumber(uint256 id)
        public
        view
        nonZeroId(id)
        idMustExists(id)
        returns (uint256)
    {

        return randomNumbers[id].randomNumber;
    }


    function newRandomNumber(uint256 id, bytes32 fileHash)
        public
        onlyOperators()
        nonZeroId(id)
        idMustBeUnique(id)
        nonZeroFileHash(fileHash)
        hashMustBeUnique(fileHash)
    {

        randomNumbers[id].id = id;
        randomNumbers[id].fileHash = fileHash;

        emit NewRandomNumber(id, fileHash);

        hashToId[fileHash] = id;
        lastId = id;
        numberOfRandomNumbers += 1;
    }

    function bulkRandomNumbers(
        uint256[] memory ids,
        bytes32[] memory fileHashes
    ) public onlyOperators() {

        require(
            ids.length == fileHashes.length,
            "Arrays must be the same length"
        );

        for (uint256 i = 0; i < ids.length; i++) {
            newRandomNumber(ids[i], fileHashes[i]);
        }
    }

    function generateRandomNumber(uint256 id)
        public
        onlyOperators()
        nonZeroId(id)
        idMustExists(id)
    {

        require(
            randomNumbers[id].requestId == 0,
            "Request already exists for this ID."
        );
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        bytes32 requestId = requestRandomness(keyHash, fee);
        randomNumbers[id].requestId = requestId;
        requestIdToId[requestId] = id;
    }

    function bulkGenerateRandomNumbers(uint256[] memory ids)
        public
        onlyOperators()
    {

        require(
            LINK.balanceOf(address(this)) >= fee * ids.length,
            "Not enough LINK"
        );

        for (uint256 i = 0; i < ids.length; i++) {
            require(ids[i] != 0, "ID cannot be 0");
            require(randomNumbers[ids[i]].fileHash != 0, "ID does not exists");
            require(
                randomNumbers[ids[i]].requestId == 0,
                "Request already exists for this ID."
            );

            bytes32 requestId = requestRandomness(keyHash, fee);
            randomNumbers[ids[i]].requestId = requestId;
            requestIdToId[requestId] = ids[i];
        }
    }


    function updateFileHash(uint256 id, bytes32 newFileHash)
        public
        onlyOwners()
        nonZeroId(id)
        idMustExists(id)
    {

        bytes32 oldFileHash = randomNumbers[id].fileHash;

        emit FileHashChanged(id, oldFileHash, newFileHash);

        randomNumbers[id].fileHash = newFileHash;
        hashToId[oldFileHash] = 0;
        hashToId[newFileHash] = id;
    }

    function transferLINK(address sendTo, uint256 amount) public onlyOwners() {

        LINK.transfer(sendTo, amount);
    }

    function updateLINKFee(uint256 new_fee) public onlyOwners() {

        fee = new_fee;
    }


    function fulfillRandomness(bytes32 requestId, uint256 randomness)
        internal
        override
    {

        require(requestIdToId[requestId] != 0, "Unknown request ID");
        require(randomNumbers[requestIdToId[requestId]].randomNumber == 0, "Request ID already fulfilled");
        
        randomNumbers[requestIdToId[requestId]].randomNumber = randomness;
        randomNumbers[requestIdToId[requestId]].blockTime = block.timestamp;
        randomNumbers[requestIdToId[requestId]].blockNumber = block.number;

        emit RandomNumberGenerated(
            requestIdToId[requestId],
            randomNumbers[requestIdToId[requestId]].fileHash,
            randomNumbers[requestIdToId[requestId]].blockNumber,
            randomNumbers[requestIdToId[requestId]].randomNumber
        );
    }

}