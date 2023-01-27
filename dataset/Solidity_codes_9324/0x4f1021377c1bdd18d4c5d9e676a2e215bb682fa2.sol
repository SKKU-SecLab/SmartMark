



abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}





contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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




library SafeMathChainlink {

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;
    require(c >= a, "SafeMath: addition overflow");

    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a, "SafeMath: subtraction overflow");
    uint256 c = a - b;

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

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0, "SafeMath: division by zero");
    uint256 c = a / b;

    return c;
  }

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0, "SafeMath: modulo by zero");
    return a % b;
  }
}




interface LinkTokenInterface {

  function allowance(address owner, address spender) external view returns (uint256 remaining);

  function approve(address spender, uint256 value) external returns (bool success);

  function balanceOf(address owner) external view returns (uint256 balance);

  function decimals() external view returns (uint8 decimalPlaces);

  function decreaseApproval(address spender, uint256 addedValue) external returns (bool success);

  function increaseApproval(address spender, uint256 subtractedValue) external;

  function name() external view returns (string memory tokenName);

  function symbol() external view returns (string memory tokenSymbol);

  function totalSupply() external view returns (uint256 totalTokensIssued);

  function transfer(address to, uint256 value) external returns (bool success);

  function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);

  function transferFrom(address from, address to, uint256 value) external returns (bool success);

}




contract VRFRequestIDBase {


  function makeVRFInputSeed(bytes32 _keyHash, uint256 _userSeed,
    address _requester, uint256 _nonce)
    internal pure returns (uint256)
  {

    return  uint256(keccak256(abi.encode(_keyHash, _userSeed, _requester, _nonce)));
  }

  function makeRequestId(
    bytes32 _keyHash, uint256 _vRFInputSeed) internal pure returns (bytes32) {

    return keccak256(abi.encodePacked(_keyHash, _vRFInputSeed));
  }
}







abstract contract VRFConsumerBase is VRFRequestIDBase {

  using SafeMathChainlink for uint256;

  function fulfillRandomness(bytes32 requestId, uint256 randomness)
    internal virtual;

  function requestRandomness(bytes32 _keyHash, uint256 _fee, uint256 _seed)
    internal returns (bytes32 requestId)
  {
    LINK.transferAndCall(vrfCoordinator, _fee, abi.encode(_keyHash, _seed));
    uint256 vRFSeed  = makeVRFInputSeed(_keyHash, _seed, address(this), nonces[_keyHash]);
    nonces[_keyHash] = nonces[_keyHash].add(1);
    return makeRequestId(_keyHash, vRFSeed);
  }

  LinkTokenInterface immutable internal LINK;
  address immutable private vrfCoordinator;

  mapping(bytes32 /* keyHash */ => uint256 /* nonce */) private nonces;

  constructor(address _vrfCoordinator, address _link) public {
    vrfCoordinator = _vrfCoordinator;
    LINK = LinkTokenInterface(_link);
  }

  function rawFulfillRandomness(bytes32 requestId, uint256 randomness) external {
    require(msg.sender == vrfCoordinator, "Only VRFCoordinator can fulfill");
    fulfillRandomness(requestId, randomness);
  }
}





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




library Uint256ArrayUtils {


    function indexOf(uint256[] memory A, uint256 a) internal pure returns (uint256, bool) {

        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (uint256(-1), false);
    }

    function contains(uint256[] memory A, uint256 a) internal pure returns (bool) {

        (, bool isIn) = indexOf(A, a);
        return isIn;
    }

    function hasDuplicate(uint256[] memory A) internal pure returns(bool) {

        require(A.length > 0, "A is empty");

        for (uint256 i = 0; i < A.length - 1; i++) {
            uint256 current = A[i];
            for (uint256 j = i + 1; j < A.length; j++) {
                if (current == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    function remove(uint256[] memory A, uint256 a)
        internal
        pure
        returns (uint256[] memory)
    {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("uint256 not in array.");
        } else {
            (uint256[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    function removeStorage(uint256[] storage A, uint256 a)
        internal
    {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("uint256 not in array.");
        } else {
            uint256 lastIndex = A.length - 1; // If the array would be empty, the previous line would throw, so no underflow here
            if (index != lastIndex) { A[index] = A[lastIndex]; }
            A.pop();
        }
    }

    function pop(uint256[] memory A, uint256 index)
        internal
        pure
        returns (uint256[] memory, uint256)
    {

        uint256 length = A.length;
        require(index < A.length, "Index must be < A length");
        uint256[] memory newUint256s = new uint256[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newUint256s[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newUint256s[j - 1] = A[j];
        }
        return (newUint256s, A[index]);
    }

    function extend(uint256[] memory A, uint256[] memory B) internal pure returns (uint256[] memory) {

        uint256 aLength = A.length;
        uint256 bLength = B.length;
        uint256[] memory newUint256s = new uint256[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newUint256s[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newUint256s[aLength + j] = B[j];
        }
        return newUint256s;
    }

    function _validateLengthAndUniqueness(uint256[] memory A) internal pure {

        require(A.length > 0, "Array length must be > 0");
        require(!hasDuplicate(A), "Cannot duplicate uint256");
    }
}



library AddressArrayUtils {


    function indexOf(address[] memory A, address a) internal pure returns (uint256, bool) {

        uint256 length = A.length;
        for (uint256 i = 0; i < length; i++) {
            if (A[i] == a) {
                return (i, true);
            }
        }
        return (uint256(-1), false);
    }

    function contains(address[] memory A, address a) internal pure returns (bool) {

        (, bool isIn) = indexOf(A, a);
        return isIn;
    }

    function hasDuplicate(address[] memory A) internal pure returns(bool) {

        require(A.length > 0, "A is empty");

        for (uint256 i = 0; i < A.length - 1; i++) {
            address current = A[i];
            for (uint256 j = i + 1; j < A.length; j++) {
                if (current == A[j]) {
                    return true;
                }
            }
        }
        return false;
    }

    function remove(address[] memory A, address a)
        internal
        pure
        returns (address[] memory)
    {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("Address not in array.");
        } else {
            (address[] memory _A,) = pop(A, index);
            return _A;
        }
    }

    function removeStorage(address[] storage A, address a)
        internal
    {

        (uint256 index, bool isIn) = indexOf(A, a);
        if (!isIn) {
            revert("Address not in array.");
        } else {
            uint256 lastIndex = A.length - 1; // If the array would be empty, the previous line would throw, so no underflow here
            if (index != lastIndex) { A[index] = A[lastIndex]; }
            A.pop();
        }
    }

    function pop(address[] memory A, uint256 index)
        internal
        pure
        returns (address[] memory, address)
    {

        uint256 length = A.length;
        require(index < A.length, "Index must be < A length");
        address[] memory newAddresses = new address[](length - 1);
        for (uint256 i = 0; i < index; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = index + 1; j < length; j++) {
            newAddresses[j - 1] = A[j];
        }
        return (newAddresses, A[index]);
    }

    function extend(address[] memory A, address[] memory B) internal pure returns (address[] memory) {

        uint256 aLength = A.length;
        uint256 bLength = B.length;
        address[] memory newAddresses = new address[](aLength + bLength);
        for (uint256 i = 0; i < aLength; i++) {
            newAddresses[i] = A[i];
        }
        for (uint256 j = 0; j < bLength; j++) {
            newAddresses[aLength + j] = B[j];
        }
        return newAddresses;
    }

    function validatePairsWithArray(address[] memory A, uint[] memory B) internal pure {

        require(A.length == B.length, "Array length mismatch");
        _validateLengthAndUniqueness(A);
    }

    function validatePairsWithArray(address[] memory A, bool[] memory B) internal pure {

        require(A.length == B.length, "Array length mismatch");
        _validateLengthAndUniqueness(A);
    }

    function validatePairsWithArray(address[] memory A, string[] memory B) internal pure {

        require(A.length == B.length, "Array length mismatch");
        _validateLengthAndUniqueness(A);
    }

    function validatePairsWithArray(address[] memory A, address[] memory B) internal pure {

        require(A.length == B.length, "Array length mismatch");
        _validateLengthAndUniqueness(A);
    }

    function validatePairsWithArray(address[] memory A, bytes[] memory B) internal pure {

        require(A.length == B.length, "Array length mismatch");
        _validateLengthAndUniqueness(A);
    }

    function _validateLengthAndUniqueness(address[] memory A) internal pure {

        require(A.length > 0, "Array length must be > 0");
        require(!hasDuplicate(A), "Cannot duplicate addresses");
    }
}




interface IWETH is IERC20{

    function deposit() external payable;


    function withdraw(uint256 wad) external;

}



interface IController {

    function getWeth() external view returns (address);


    function getChanceToken() external view returns (address);


    function getVrfKeyHash() external view returns (bytes32);


    function getVrfFee() external view returns (uint256);


    function getLinkToken() external view returns (address);


    function getVrfCoordinator() external view returns (address);


    function getAllPools() external view returns (address[] memory);

}




interface IChanceToken {

    function mint(address _account, uint256 _id, uint256 _amount) external;


    function burn(address _account, uint256 _id, uint256 _amount) external;

}



pragma experimental ABIEncoderV2;



contract ProphetPool is VRFConsumerBase, Ownable {

    using Uint256ArrayUtils for uint256[];
    using AddressArrayUtils for address[];


    struct PoolConfig {
        uint256 numOfWinners;
        uint256 participantLimit;
        uint256 enterAmount;
        uint256 feePercentage;
        uint256 randomSeed;
        uint256 startedAt;
    }


    enum PoolStatus { NOTSTARTED, INPROGRESS, CLOSED }


    event FeeRecipientSet(address indexed _feeRecipient);
    event MaxParticipationCompleted(address indexed _from);
    event RandomNumberGenerated(uint256 indexed randomness);
    event WinnersGenerated(uint256[] winnerIndexes);
    event PoolSettled();
    event PoolStarted(
        uint256 participantLimit,
        uint256 numOfWinners,
        uint256 enterAmount,
        uint256 feePercentage,
        uint256 startedAt
    );
    event PoolReset();
    event EnteredPool(address indexed _participant, uint256 _amount, uint256 indexed _participantIndex);


    IController private controller;
    address private feeRecipient;
    string private poolName;
    IERC20 private enterToken;
    PoolStatus private poolStatus;
    PoolConfig private poolConfig;
    uint256 private chanceTokenId;

    address[] private participants;
    uint256[] private winnerIndexes;
    uint256 private totalEnteredAmount;
    uint256 private rewardPerParticipant;

    bool internal isRNDGenerated;
    uint256 internal randomResult;
    bool internal areWinnersGenerated;


    modifier onlyValidPool() {

        require(participants.length < poolConfig.participantLimit, "exceed max");
        require(poolStatus == PoolStatus.INPROGRESS, "in progress");
        _;
    }

    modifier onlyEOA() {

        require(tx.origin == msg.sender, "should be EOA");
        _;
    }


    constructor(
        string memory _poolName,
        address _enterToken,
        address _controller,
        address _feeRecipient,
        uint256 _chanceTokenId
    )
        public
        VRFConsumerBase(IController(_controller).getVrfCoordinator(), IController(_controller).getLinkToken())
    {
        poolName = _poolName;
        enterToken = IERC20(_enterToken);
        controller = IController(_controller);
        feeRecipient = _feeRecipient;
        chanceTokenId = _chanceTokenId;

        poolStatus = PoolStatus.NOTSTARTED;
    }


    function setPoolRules(
        uint256 _numOfWinners,
        uint256 _participantLimit,
        uint256 _enterAmount,
        uint256 _feePercentage,
        uint256 _randomSeed
    ) external onlyOwner {

        require(poolStatus == PoolStatus.NOTSTARTED, "in progress");
        require(_numOfWinners != 0, "invalid numOfWinners");
        require(_numOfWinners < _participantLimit, "too much numOfWinners");

        poolConfig = PoolConfig(
            _numOfWinners,
            _participantLimit,
            _enterAmount,
            _feePercentage,
            _randomSeed,
            block.timestamp
        );
        poolStatus = PoolStatus.INPROGRESS;
        emit PoolStarted(
            _participantLimit,
            _numOfWinners,
            _enterAmount,
            _feePercentage,
            block.timestamp
        );
    }

    function setFeeRecipient(address _feeRecipient) external onlyOwner {

        require(_feeRecipient != address(0), "invalid address");
        feeRecipient = _feeRecipient;

        emit FeeRecipientSet(feeRecipient);
    }

    function enterPoolEth() external payable onlyValidPool onlyEOA returns (uint256) {

        require(msg.value == poolConfig.enterAmount, "insufficient amount");
        if (!_isEthPool()) {
            revert("not accept ETH");
        }
        IWETH(controller.getWeth()).deposit{ value: msg.value }();

        return _enterPool();
    }

    function enterPool() external onlyValidPool onlyEOA returns (uint256) {

        enterToken.transferFrom(
                msg.sender,
                address(this),
                poolConfig.enterAmount
            );

        return _enterPool();
    }

    function settlePool() external {

        require(isRNDGenerated, "RND in progress");
        require(poolStatus == PoolStatus.INPROGRESS, "pool in progress");

        uint256 newRandom = randomResult;
        uint256 offset = 0;
        while(winnerIndexes.length < poolConfig.numOfWinners) {
            uint256 winningIndex = newRandom.mod(poolConfig.participantLimit);
            if (!winnerIndexes.contains(winningIndex)) {
                winnerIndexes.push(winningIndex);
            }
            offset = offset.add(1);
            newRandom = _getRandomNumberBlockchain(offset, newRandom);
        }
        areWinnersGenerated = true;
        emit WinnersGenerated(winnerIndexes);

        poolStatus = PoolStatus.CLOSED;

        uint256 feeAmount = totalEnteredAmount.mul(poolConfig.feePercentage).div(100);
        rewardPerParticipant = (totalEnteredAmount.sub(feeAmount)).div(poolConfig.numOfWinners);
        _transferEnterToken(feeRecipient, feeAmount);

        emit PoolSettled();
    }

    function collectRewards() external {

        require(poolStatus == PoolStatus.CLOSED, "not settled");

        for (uint256 i = 0; i < poolConfig.participantLimit; i = i.add(1)) {
            address player = participants[i];
            if (winnerIndexes.contains(i)) {
                _transferEnterToken(player, rewardPerParticipant);
            } else {
                IChanceToken(controller.getChanceToken()).mint(player, chanceTokenId, 1);
            }
        }
        _resetPool();
    }

    receive() external payable {}

    function getController() external view returns (address) {

        return address(controller);
    }

    function getFeeRecipient() external view returns (address) {

        return feeRecipient;
    }

    function getPoolName() external view returns (string memory) {

        return poolName;
    }

    function getEnterToken() external view returns (address) {

        return address(enterToken);
    }

    function getChanceTokenId() external view returns (uint256) {

        return chanceTokenId;
    }

    function getPoolStatus() external view returns (PoolStatus) {

        return poolStatus;
    }

    function getPoolConfig() external view returns (PoolConfig memory) {

        return poolConfig;
    }

    function getTotalEnteredAmount() external view returns (uint256) {

        return totalEnteredAmount;
    }

    function getRewardPerParticipant() external view returns (uint256) {

        return rewardPerParticipant;
    }

    function getParticipants() external view returns(address[] memory) {

        return participants;
    }

    function getParticipant(uint256 _index) external view returns(address) {

        return participants[_index];
    }

    function getWinnerIndexes() external view returns(uint256[] memory) {

        return winnerIndexes;
    }

    function isWinner(address _account) external view returns(bool) {

        (uint256 index, bool isExist) = participants.indexOf(_account);
        if (isExist) {
            return winnerIndexes.contains(index);
        } else {
            return false;
        }
    }


    function _enterPool() internal returns(uint256 _participantIndex) {

        participants.push(msg.sender);

        totalEnteredAmount = totalEnteredAmount.add(poolConfig.enterAmount);

        if (participants.length == poolConfig.participantLimit) {
            emit MaxParticipationCompleted(msg.sender);
            _getRandomNumber(poolConfig.randomSeed);
        }

        _participantIndex = (participants.length).sub(1);
        emit EnteredPool(msg.sender, poolConfig.enterAmount, _participantIndex);
    }

    function _resetPool() internal {

        poolStatus = PoolStatus.INPROGRESS;
        delete totalEnteredAmount;
        delete rewardPerParticipant;
        isRNDGenerated = false;
        randomResult = 0;
        areWinnersGenerated = false;
        delete winnerIndexes;
        delete participants;
        emit PoolReset();

        uint256 tokenBalance = enterToken.balanceOf(address(this));
        if (tokenBalance > 0) {
            _transferEnterToken(feeRecipient, tokenBalance);
        }
    }

    function _transferEnterToken(address _to, uint256 _amount) internal {

        if (_isEthPool()) {
            IWETH(controller.getWeth()).withdraw(_amount);
            (bool status, ) = payable(_to).call{value: _amount}("");
            require(status, "ETH not transferred");
        } else {
            enterToken.transfer(address(_to), _amount);
        }
    }

    function _isEthPool() internal view returns (bool) {

        return address(enterToken) == controller.getWeth();
    }

    function _getRandomNumberBlockchain(uint256 _offset, uint256 _randomness)
        internal
        view
        returns (uint256)
    {

        bytes32 baseHash = keccak256(
            abi.encodePacked(
                blockhash(block.number),
                bytes32(_offset),
                bytes32(_randomness)
            )
        );
        return uint256(baseHash);
    }

    function _getRandomNumber(uint256 _userProvidedSeed)
        internal
        returns (bytes32 requestId)
    {

        require(
            IERC20(controller.getLinkToken()).balanceOf(address(this)) >= controller.getVrfFee(),
            "not enough LINK"
        );
        randomResult = 0;
        isRNDGenerated = false;
        return
            requestRandomness(
                controller.getVrfKeyHash(),
                controller.getVrfFee(),
                _userProvidedSeed
            );
    }

    function fulfillRandomness(bytes32, uint256 _randomness) internal override {

        randomResult = _randomness;
        isRNDGenerated = true;
        emit RandomNumberGenerated(_randomness);
    }
}






contract SecondChancePool is VRFConsumerBase, Ownable {

    using Uint256ArrayUtils for uint256[];
    using AddressArrayUtils for address[];


    struct PoolConfig {
        uint256 numOfWinners;
        uint256 participantLimit;
        uint256 rewardAmount;
        uint256 randomSeed;
        uint256 startedAt;
    }


    enum PoolStatus { NOTSTARTED, INPROGRESS, CLOSED }


    event MaxParticipationCompleted(address indexed _from);
    event RandomNumberGenerated(uint256 indexed randomness);
    event WinnersGenerated(uint256[] winnerIndexes);
    event PoolSettled();
    event PoolStarted(
        uint256 participantLimit,
        uint256 numOfWinners,
        uint256 rewardAmount,
        uint256 startedAt
    );
    event PoolReset();
    event EnteredPool(address indexed _participant, uint256 indexed _participantIndex);


    IController private controller;
    string private poolName;
    IERC20 private rewardToken;
    PoolStatus private poolStatus;
    PoolConfig private poolConfig;
    uint256 private chanceTokenId;

    address[] private participants;
    uint256[] private winnerIndexes;

    bool internal isRNDGenerated;
    uint256 internal randomResult;
    bool internal areWinnersGenerated;


    modifier onlyValidPool() {

        require(participants.length < poolConfig.participantLimit, "exceed max");
        require(poolStatus == PoolStatus.INPROGRESS, "in progress");
        _;
    }

    modifier onlyEOA() {

        require(tx.origin == msg.sender, "should be EOA");
        _;
    }


    constructor(
        string memory _poolName,
        address _rewardToken,
        address _controller,
        uint256 _chanceTokenId
    )
        public
        VRFConsumerBase(IController(_controller).getVrfCoordinator(), IController(_controller).getLinkToken())
    {
        poolName = _poolName;
        rewardToken = IERC20(_rewardToken);
        controller = IController(_controller);
        chanceTokenId = _chanceTokenId;

        poolStatus = PoolStatus.NOTSTARTED;
    }


    receive() external payable {
        if (!_isEthPool()) {
            revert("not accept ETH");
        }
        IWETH(controller.getWeth()).deposit{ value: msg.value }();
    }

    function setPoolRules(
        uint256 _numOfWinners,
        uint256 _participantLimit,
        uint256 _rewardAmount,
        uint256 _randomSeed
    ) external onlyOwner {

        require(poolStatus != PoolStatus.INPROGRESS, "in progress");
        require(_numOfWinners != 0, "invalid numOfWinners");
        require(_numOfWinners < _participantLimit, "too much numOfWinners");

        poolConfig = PoolConfig(
            _numOfWinners,
            _participantLimit,
            _rewardAmount,
            _randomSeed,
            block.timestamp
        );
        poolStatus = PoolStatus.INPROGRESS;
        emit PoolStarted(
            _participantLimit,
            _numOfWinners,
            _rewardAmount,
            block.timestamp
        );
    }

    function enterPool() external onlyValidPool onlyEOA returns (uint256) {

        IChanceToken(controller.getChanceToken()).burn(msg.sender, chanceTokenId, 1);

        return _enterPool();
    }

    function settlePool() external {

        require(isRNDGenerated, "RND in progress");
        require(poolStatus == PoolStatus.INPROGRESS, "pool in progress");

        uint256 newRandom = randomResult;
        uint256 offset = 0;
        while(winnerIndexes.length < poolConfig.numOfWinners) {
            uint256 winningIndex = newRandom.mod(poolConfig.participantLimit);
            if (!winnerIndexes.contains(winningIndex)) {
                winnerIndexes.push(winningIndex);
            }
            offset = offset.add(1);
            newRandom = _getRandomNumberBlockchain(offset, newRandom);
        }
        areWinnersGenerated = true;
        emit WinnersGenerated(winnerIndexes);

        poolStatus = PoolStatus.CLOSED;

        emit PoolSettled();
    }

    function collectRewards() external {

        require(poolStatus == PoolStatus.CLOSED, "not settled");

        uint rewardAmount_ = poolConfig.rewardAmount;
        require(rewardAmount_.mul(poolConfig.numOfWinners) <= rewardToken.balanceOf(address(this)), "insufficient reward");

        for (uint256 i = 0; i < winnerIndexes.length; i = i.add(1)) {
            address player = participants[winnerIndexes[i]];
            _transferRewardToken(player, rewardAmount_);
        }
        _resetPool();
    }

    function getController() external view returns (address) {

        return address(controller);
    }

    function getPoolName() external view returns (string memory) {

        return poolName;
    }

    function getRewardToken() external view returns (address) {

        return address(rewardToken);
    }

    function getChanceTokenId() external view returns (uint256) {

        return chanceTokenId;
    }

    function getPoolStatus() external view returns (PoolStatus) {

        return poolStatus;
    }

    function getPoolConfig() external view returns (PoolConfig memory) {

        return poolConfig;
    }

    function getParticipants() external view returns(address[] memory) {

        return participants;
    }

    function getParticipant(uint256 _index) external view returns(address) {

        return participants[_index];
    }

    function getWinnerIndexes() external view returns(uint256[] memory) {

        return winnerIndexes;
    }

    function isWinner(address _account) external view returns(bool) {

        (uint256 index, bool isExist) = participants.indexOf(_account);
        if (isExist) {
            return winnerIndexes.contains(index);
        } else {
            return false;
        }
    }


    function _enterPool() internal returns(uint256 _participantIndex) {

        participants.push(msg.sender);

        if (participants.length == poolConfig.participantLimit) {
            emit MaxParticipationCompleted(msg.sender);
            _getRandomNumber(poolConfig.randomSeed);
        }

        _participantIndex = (participants.length).sub(1);
        emit EnteredPool(msg.sender, _participantIndex);
    }

    function _resetPool() internal {

        poolStatus = PoolStatus.INPROGRESS;
        isRNDGenerated = false;
        randomResult = 0;
        areWinnersGenerated = false;
        delete winnerIndexes;
        delete participants;
        emit PoolReset();
    }

    function _transferRewardToken(address _to, uint256 _amount) internal {

        if (_isEthPool()) {
            IWETH(controller.getWeth()).withdraw(_amount);
            (bool status, ) = payable(_to).call{value: _amount}("");
            require(status, "ETH not transferred");
        } else {
            rewardToken.transfer(address(_to), _amount);
        }
    }

    function _isEthPool() internal view returns (bool) {

        return address(rewardToken) == controller.getWeth();
    }

    function _getRandomNumberBlockchain(uint256 _offset, uint256 _randomness)
        internal
        view
        returns (uint256)
    {

        bytes32 baseHash = keccak256(
            abi.encodePacked(
                blockhash(block.number),
                bytes32(_offset),
                bytes32(_randomness)
            )
        );
        return uint256(baseHash);
    }

    function _getRandomNumber(uint256 _userProvidedSeed)
        internal
        returns (bytes32 requestId)
    {

        require(
            IERC20(controller.getLinkToken()).balanceOf(address(this)) >= controller.getVrfFee(),
            "not enough LINK"
        );
        randomResult = 0;
        isRNDGenerated = false;
        return
            requestRandomness(
                controller.getVrfKeyHash(),
                controller.getVrfFee(),
                _userProvidedSeed
            );
    }

    function fulfillRandomness(bytes32, uint256 _randomness) internal override {

        randomResult = _randomness;
        isRNDGenerated = true;
        emit RandomNumberGenerated(_randomness);
    }
}



pragma solidity ^0.6.10;



contract Controller is Ownable {



    event ProphetPoolCreated(
        address indexed _prophetPool,
        string _poolName,
        address _buyToken,
        address _manager,
        address _feeRecipient,
        uint256 _chanceTokenId
    );
    event SecondChancePoolCreated(
        address indexed _secondChancePool,
        string _poolName,
        address _rewardToken,
        address _manager,
        uint256 _chanceTokenId
    );
    event CreatorStatusUpdated(address indexed _creator, bool _status);

    address private weth;
    address[] private prophetPools;
    address[] private secondChancePools;
    
    address private chanceToken;

    bytes32 private vrfKeyHash;
    uint256 private vrfFee;
    address private vrfCoordinator;
    address private linkToken;

    mapping(address => bool) private createAllowList;         // Mapping of addresses allowed to call create()


    modifier onlyAllowedCreator(address _caller) {

        require(isAllowedCreator(_caller), "not allowed");
        _;
    }


    constructor(
        address _weth,
        address _chanceToken,
        bytes32 _vrfKeyHash,
        uint256 _vrfFee,
        address _vrfCoordinator,
        address _linkToken
    ) public {
        require(_vrfFee > 0, "invalid vrfFee");
        require(_vrfCoordinator != address(0), "invalid vrfCoordinator");
        require(_linkToken != address(0), "invalid LINK");

        weth = _weth;
        chanceToken = _chanceToken;

        vrfKeyHash = _vrfKeyHash;
        vrfFee = _vrfFee;
        vrfCoordinator = _vrfCoordinator;
        linkToken = _linkToken;
    }


    function createProphetPool(
        string memory _poolName,
        address _buyToken,
        address _manager,
        address _feeRecipient,
        uint256 _chanceTokenId
    ) external onlyAllowedCreator(msg.sender) returns (address) {

        require(_buyToken != address(0), "invalid buyToken");
        require(_manager != address(0), "invalid manager");

        ProphetPool prophetPool =
            new ProphetPool(
                _poolName,
                _buyToken,
                address(this),
                _feeRecipient,
                _chanceTokenId
            );

        prophetPool.transferOwnership(_manager);
        prophetPools.push(address(prophetPool));

        emit ProphetPoolCreated(address(prophetPool), _poolName, _buyToken, _manager, _feeRecipient, _chanceTokenId);

        return address(prophetPool);
    }

    function createSecondChancePool(
        string memory _poolName,
        address _rewardToken,
        address _manager,
        uint256 _chanceTokenId
    ) external onlyAllowedCreator(msg.sender) returns (address) {

        require(_rewardToken != address(0), "invalid rewardToken");
        require(_manager != address(0), "invalid manager");

        SecondChancePool secondChancePool =
            new SecondChancePool(
                _poolName,
                _rewardToken,
                address(this),
                _chanceTokenId
            );

        secondChancePool.transferOwnership(_manager);
        secondChancePools.push(address(secondChancePool));

        emit SecondChancePoolCreated(
            address(secondChancePool),
            _poolName,
            _rewardToken,
            _manager,
            _chanceTokenId
        );

        return address(secondChancePool);
    }

    function updateCreatorStatus(address[] calldata _creators, bool[] calldata _statuses) external onlyOwner {

        require(_creators.length == _statuses.length, "array mismatch");
        require(_creators.length > 0, "invalid length");

        for (uint256 i = 0; i < _creators.length; i++) {
            address creator = _creators[i];
            bool status = _statuses[i];
            createAllowList[creator] = status;
            emit CreatorStatusUpdated(creator, status);
        }
    }

    function getWeth() external view returns (address) {

        return weth;
    }

    function getChanceToken() external view returns (address) {

        return chanceToken;
    }

    function getVrfKeyHash() external view returns (bytes32) {

        return vrfKeyHash;
    }

    function getVrfFee() external view returns (uint256) {

        return vrfFee;
    }

    function getLinkToken() external view returns (address) {

        return linkToken;
    }

    function getVrfCoordinator() external view returns (address) {

        return vrfCoordinator;
    }

    function getAllProphetPools() external view returns (address[] memory) {

        return prophetPools;
    }

    function isAllowedCreator(address _caller) public view returns (bool) {

        return createAllowList[_caller];
    }
}