
pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT
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


}// MIT
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
}// MIT
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
}//MIT
pragma solidity >=0.8.4;



interface IKetherHomepage {

  function ads(uint _idx) external view returns (address,uint,uint,uint,uint,string memory,string memory,string memory,bool,bool);

  function getAdsLength() view external returns (uint);

}

interface IERC721 {

  function ownerOf(uint256) external view returns (address);

  function balanceOf(address) external view returns (uint256);

  function tokenOfOwnerByIndex(address, uint256) external view returns (uint256);

}

interface IERC20 {

  function balanceOf(address account) external view returns (uint256);

  function transfer(address recipient, uint256 amount) external returns (bool);

}

library Errors {

  string constant MustOwnToken = "must own token";
  string constant OnlyMagistrate = "only active magistrate can do this";
  string constant MustHaveEntropy = "waiting for entropy";
  string constant MustHaveNominations = "must have nominations";
  string constant AlreadyStarted = "election already started";
  string constant NotExecuted = "election not executed";
  string constant TermNotExpired = "term not expired";
  string constant NotEnoughLink = "not enough LINK";
  string constant NotNominated = "token is not nominated";
}

contract KetherSortition is Ownable, VRFConsumerBase {

  event Nominated(
      uint256 indexed termNumber,
      address nominator,
      uint256 pixels
  );

  event ElectionExecuting(
    uint256 indexed termNumber
  );

  event ElectionCompleted(
    uint256 indexed termNumber,
    uint256 magistrateToken,
    address currentTokenOwner
  );

  event StepDown(
    uint256 indexed termNumber,
    uint256 magistrateToken,
    address currentTokenOwner
  );

  event ReceivedPayment(
    uint256 indexed termNumber,
    uint256 value
  );

  struct Nomination{
    uint256 termNumber;
    uint256 nominatedToken;
  }
  uint256 constant PIXELS_PER_CELL = 100;

  uint256 public magistrateToken;
  uint256 public termDuration;
  uint256 public minElectionDuration;
  uint256 public termStarted;
  uint256 public termExpires;
  uint256 public termNumber = 0;

  IERC721 ketherNFTContract;
  IKetherHomepage ketherContract;

  uint256[] public nominatedTokens;
  uint256 public nominatedPixels = 0;
  mapping(uint256 => Nomination) nominations; // mapping of tokenId => {termNumber, nominatedToken}

  uint256 public electionEntropy;

  enum StateMachine { NOMINATING, WAITING_FOR_ENTROPY, GOT_ENTROPY }
  StateMachine public state = StateMachine.NOMINATING;

  bytes32 private s_keyHash;
  uint256 private s_fee;

  constructor(address _ketherNFTContract, address _ketherContract, address vrfCoordinator, address link, bytes32 keyHash, uint256 fee, uint256 _termDuration, uint256 _minElectionDuration ) VRFConsumerBase(vrfCoordinator, link) {
    s_keyHash = keyHash;
    s_fee = fee;

    ketherNFTContract = IERC721(_ketherNFTContract);
    ketherContract = IKetherHomepage(_ketherContract);

    termDuration = _termDuration;
    minElectionDuration = _minElectionDuration;
    termExpires = block.timestamp + _termDuration;
  }

  receive() external payable {
    emit ReceivedPayment(termNumber, msg.value);
  }


  function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {

    require(state == StateMachine.WAITING_FOR_ENTROPY, Errors.NotExecuted);
    electionEntropy = randomness;
    state = StateMachine.GOT_ENTROPY;
  }

  function _nominate(uint256 _ownedTokenId, uint256 _nominateTokenId) internal returns (uint256 pixels) {

    if (!isNominated(_ownedTokenId)) {
      pixels += getAdPixels(_ownedTokenId);
      nominatedTokens.push(_ownedTokenId);
    }

    nominations[_ownedTokenId] = Nomination(termNumber + 1, _nominateTokenId);

    return pixels;
  }

  function _nominateAll(bool _nominateSelf, uint256 _nominateTokenId) internal returns (uint256) {

    require(state == StateMachine.NOMINATING, Errors.AlreadyStarted);
    address sender = _msgSender();
    require(ketherNFTContract.balanceOf(sender) > 0, Errors.MustOwnToken);
    require(_nominateSelf || ketherNFTContract.ownerOf(_nominateTokenId) != address(0));


    uint256 pixels = 0;
    for (uint256 i = 0; i < ketherNFTContract.balanceOf(sender); i++) {
      uint256 idx = ketherNFTContract.tokenOfOwnerByIndex(sender, i);
      if (_nominateSelf) {
        pixels += _nominate(idx, idx);
      } else {
        pixels += _nominate(idx, _nominateTokenId);
      }
    }

    nominatedPixels += pixels;

    emit Nominated(termNumber+1, sender, pixels);
    return pixels;
  }



  function getMagistrate() public view returns (address) {

    return getAdOwner(magistrateToken);
  }

  function getAdOwner(uint256 _idx) public view returns (address) {

    return ketherNFTContract.ownerOf(_idx);
  }

  function getAdPixels(uint256 _idx) public view returns (uint256) {

    (,,,uint width,uint height,,,,,) = ketherContract.ads(_idx);
    return width * height * PIXELS_PER_CELL;
  }

  function isNominated(uint256 _idx) public view returns (bool) {

    return nominations[_idx].termNumber > termNumber;
  }

  function getNominatedToken(uint256 _idx) public view returns (uint256) {

    require(isNominated(_idx), Errors.NotNominated);

    return nominations[_idx].nominatedToken;
  }

  function getNextMagistrateToken() public view returns (uint256) {

    require(state == StateMachine.GOT_ENTROPY, Errors.MustHaveEntropy);
    require(nominatedTokens.length > 0, Errors.MustHaveNominations);

    uint256 pixelChosen = electionEntropy % nominatedPixels;
    uint256 curPixel = 0;

    for(uint256 i = 0; i < nominatedTokens.length; i++) {
      uint256 idx = nominatedTokens[i];
      curPixel += getAdPixels(idx);
      if (curPixel > pixelChosen) {
        return getNominatedToken(idx);
      }
    }
    return 0;
  }


  function nominate(uint256 _ownedTokenId, uint256 _nominateTokenId) external returns (uint256) {

    require(state == StateMachine.NOMINATING, Errors.AlreadyStarted);
    address sender = _msgSender();
    require(ketherNFTContract.ownerOf(_ownedTokenId) == sender, Errors.MustOwnToken);
    require(ketherNFTContract.ownerOf(_nominateTokenId) != address(0));
    uint256 pixels = _nominate(_ownedTokenId, _nominateTokenId);

    emit Nominated(termNumber+1, sender, pixels);

    return pixels;
  }

  function nominateAll(uint256 _nominateTokenId) public returns (uint256) {

    return _nominateAll(false, _nominateTokenId);
  }

  function nominateSelf() public returns (uint256) {

    return _nominateAll(true, 0);
  }

  function startElection() external {

    require(state == StateMachine.NOMINATING, Errors.AlreadyStarted);
    require(nominatedTokens.length > 0, Errors.MustHaveNominations);
    require(termExpires <= block.timestamp, Errors.TermNotExpired);
    require(LINK.balanceOf(address(this)) >= s_fee, Errors.NotEnoughLink);

    state = StateMachine.WAITING_FOR_ENTROPY;
    requestRandomness(s_keyHash, s_fee);

    emit ElectionExecuting(termNumber);
  }

  function completeElection() external {

    require(state == StateMachine.GOT_ENTROPY, Errors.MustHaveEntropy);
    magistrateToken = getNextMagistrateToken();

    termNumber += 1;
    termStarted = block.timestamp;
    termExpires = termStarted + termDuration;

    delete nominatedTokens;
    nominatedPixels = 0;
    state = StateMachine.NOMINATING;

    emit ElectionCompleted(termNumber, magistrateToken, getMagistrate());
  }



  function withdraw(address payable to) public {

    require(_msgSender() == getMagistrate(), Errors.OnlyMagistrate);

    to.transfer(address(this).balance);
  }

  function stepDown() public {

    require(_msgSender() == getMagistrate(), Errors.OnlyMagistrate);

    uint256 timeRemaining = termExpires - block.timestamp;
    if (timeRemaining > minElectionDuration) {
      termExpires = block.timestamp + minElectionDuration;
    }

    emit StepDown(termNumber, magistrateToken, _msgSender());
  }


  function adminWithdrawToken(IERC20 token, address to) external onlyOwner {

    token.transfer(to, token.balanceOf(address(this)));
  }
}