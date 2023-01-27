
pragma solidity ^0.8.0;

interface IERC20 {


  function balanceOf(address account) external view returns (uint256);


  function transfer(address recipient, uint256 amount) external returns (bool);


  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}

interface IERC721 {


  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

}

interface IVaultConfig {


  function fee() external view returns (uint256);

  function gasLimit() external view returns (uint256);

  function ownerReward() external view returns (uint256);

}

abstract contract Context {
  function _msgSender() internal view returns (address) {
    return msg.sender;
  }

  function _msgData() internal view returns (bytes memory) {
    this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    return msg.data;
  }

  function _msgValue() internal view returns (uint256) {
    return msg.value;
  }
}

abstract contract Ownable is Context {
  address private _owner;
  address private _newOwner;

  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  constructor (address owner_) {
    _owner = owner_;
    emit OwnershipTransferred(address(0), owner_);
  }

  function owner() public view returns (address) {
    return _owner;
  }

  modifier onlyOwner() {
    require(owner() == _msgSender(), "Ownable: caller is not the owner");
    _;
  }

  function acceptOwnership() public {
    require(_msgSender() == _newOwner, "Ownable: only new owner can accept ownership");
    address oldOwner = _owner;
    _owner = _newOwner;
    _newOwner = address(0);
    emit OwnershipTransferred(oldOwner, _owner);
  }

  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0), "Ownable: new owner is the zero address");
    _newOwner = newOwner;
  }
}

abstract contract Payable {

  event Deposited(address indexed sender, uint256 value);

  fallback() external payable {
    if(msg.value > 0) {
      emit Deposited(msg.sender, msg.value);
    }
  }

  receive() external payable {
    if(msg.value > 0) {
      emit Deposited(msg.sender, msg.value);
    }
  }
}

library MerkleProof {

  function verify(bytes32[] memory proof, bytes32 root, bytes32 leaf) internal pure returns (bool) {

    bytes32 computedHash = leaf;

    for (uint256 i = 0; i < proof.length; i++) {
      bytes32 proofElement = proof[i];

      if (computedHash <= proofElement) {
        computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
      } else {
        computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
      }
    }

    return computedHash == root;
  }
}

contract Coin98Vault is Ownable, Payable {


  address private _factory;
  address[] private _admins;
  mapping(address => bool) private _adminStatuses;
  mapping(uint256 => EventData) private _eventDatas;
  mapping(uint256 => mapping(uint256 => bool)) private _eventRedemptions;

  constructor(address factory_, address owner_) Ownable(owner_) {
    _factory = factory_;
  }

  struct EventData {
    uint256 timestamp;
    bytes32 merkleRoot;
    address receivingToken;
    address sendingToken;
    uint8 isActive;
  }

  event AdminAdded(address indexed admin);
  event AdminRemoved(address indexed admin);
  event EventCreated(uint256 eventId, EventData eventData);
  event EventUpdated(uint256 eventId, uint8 isActive);
  event Redeemed(uint256 eventId, uint256 index, address indexed recipient, address indexed receivingToken, uint256 receivingTokenAmount, address indexed sendingToken, uint256 sendingTokenAmount);
  event Withdrawn(address indexed owner, address indexed recipient, address indexed token, uint256 value);

  function _setRedemption(uint256 eventId_, uint256 index_) private {

    _eventRedemptions[eventId_][index_] = true;
  }

  modifier onlyAdmin() {

    require(owner() == _msgSender() || _adminStatuses[_msgSender()], "Ownable: caller is not an admin");
    _;
  }

  function admins() public view returns (address[] memory) {

    return _admins;
  }

  function eventInfo(uint256 eventId_) public view returns (EventData memory) {

    return _eventDatas[eventId_];
  }

  function factory() public view returns (address) {

    return _factory;
  }

  function isRedeemed(uint256 eventId_, uint256 index_) public view returns (bool) {

    return _eventRedemptions[eventId_][index_];
  }

  function redeem(uint256 eventId_, uint256 index_, address recipient_, uint256 receivingAmount_, uint256 sendingAmount_, bytes32[] calldata proofs) public payable {

    uint256 fee = IVaultConfig(_factory).fee();
    uint256 gasLimit = IVaultConfig(_factory).gasLimit();
    if(fee > 0) {
      require(_msgValue() == fee, "C98Vault: Invalid fee");
    }

    EventData storage eventData = _eventDatas[eventId_];
    require(eventData.isActive > 0, "C98Vault: Invalid event");
    require(eventData.timestamp <= block.timestamp, "C98Vault: Schedule locked");
    require(recipient_ != address(0), "C98Vault: Invalid schedule");

    bytes32 node = keccak256(abi.encodePacked(index_, recipient_, receivingAmount_, sendingAmount_));
    require(MerkleProof.verify(proofs, eventData.merkleRoot, node), "C98Vault: Invalid proof");
    require(!isRedeemed(eventId_, index_), "C98Vault: Redeemed");

    uint256 availableAmount;
    if(eventData.receivingToken == address(0)) {
      availableAmount = address(this).balance;
    } else {
      availableAmount = IERC20(eventData.receivingToken).balanceOf(address(this));
    }

    require(receivingAmount_ <= availableAmount, "C98Vault: Insufficient token");

    _setRedemption(eventId_, index_);
    if(fee > 0) {
      uint256 reward = IVaultConfig(_factory).ownerReward();
      uint256 finalFee = fee - reward;
      (bool success, bytes memory data) = _factory.call{value:finalFee, gas:gasLimit}("");
      require(success, "C98Vault: Unable to charge fee");
    }
    if(sendingAmount_ > 0) {
      IERC20(eventData.sendingToken).transferFrom(_msgSender(), address(this), sendingAmount_);
    }
    if(eventData.receivingToken == address(0)) {
      recipient_.call{value:receivingAmount_, gas:gasLimit}("");
    } else {
      IERC20(eventData.receivingToken).transfer(recipient_, receivingAmount_);
    }

    emit Redeemed(eventId_, index_, recipient_, eventData.receivingToken, receivingAmount_, eventData.sendingToken, sendingAmount_);
  }

  function withdraw(address token_, address destination_, uint256 amount_) public onlyAdmin {

    require(destination_ != address(0), "C98Vault: Destination is zero address");

    uint256 availableAmount;
    if(token_ == address(0)) {
      availableAmount = address(this).balance;
    } else {
      availableAmount = IERC20(token_).balanceOf(address(this));
    }

    require(amount_ <= availableAmount, "C98Vault: Not enough balance");

    uint256 gasLimit = IVaultConfig(_factory).gasLimit();
    if(token_ == address(0)) {
      destination_.call{value:amount_, gas:gasLimit}("");
    } else {
      IERC20(token_).transfer(destination_, amount_);
    }

    emit Withdrawn(_msgSender(), destination_, token_, amount_);
  }

  function withdrawNft(address token_, address destination_, uint256 tokenId_) public onlyAdmin {

    require(destination_ != address(0), "C98Vault: destination is zero address");

    IERC721(token_).transferFrom(address(this), destination_, tokenId_);

    emit Withdrawn(_msgSender(), destination_, token_, 1);
  }

  function createEvent(uint256 eventId_, uint256 timestamp_, bytes32 merkleRoot_, address receivingToken_, address sendingToken_) public onlyAdmin {

    require(_eventDatas[eventId_].timestamp == 0, "C98Vault: Event existed");
    require(timestamp_ != 0, "C98Vault: Invalid timestamp");
    _eventDatas[eventId_].timestamp = timestamp_;
    _eventDatas[eventId_].merkleRoot = merkleRoot_;
    _eventDatas[eventId_].receivingToken = receivingToken_;
    _eventDatas[eventId_].sendingToken = sendingToken_;
    _eventDatas[eventId_].isActive = 1;

    emit EventCreated(eventId_, _eventDatas[eventId_]);
  }

  function setEventStatus(uint256 eventId_, uint8 isActive_) public onlyAdmin {

    require(_eventDatas[eventId_].timestamp != 0, "C98Vault: Invalid event");
    _eventDatas[eventId_].isActive = isActive_;

    emit EventUpdated(eventId_, isActive_);
  }

  function setAdmins(address[] memory nAdmins_, bool[] memory nStatuses_) public onlyOwner {

    require(nAdmins_.length != 0, "C98Vault: Empty arguments");
    require(nStatuses_.length != 0, "C98Vault: Empty arguments");
    require(nAdmins_.length == nStatuses_.length, "C98Vault: Invalid arguments");

    uint256 i;
    for(i = 0; i < nAdmins_.length; i++) {
      address nAdmin = nAdmins_[i];
      if(nStatuses_[i]) {
        if(!_adminStatuses[nAdmin]) {
          _admins.push(nAdmin);
          _adminStatuses[nAdmin] = nStatuses_[i];
          emit AdminAdded(nAdmin);
        }
      } else {
        uint256 j;
        for(j = 0; j < _admins.length; j++) {
          if(_admins[j] == nAdmin) {
            _admins[j] = _admins[_admins.length - 1];
            _admins.pop();
            delete _adminStatuses[nAdmin];
            emit AdminRemoved(nAdmin);
            break;
          }
        }
      }
    }
  }
}

contract Coin98VaultFactory is Ownable, Payable, IVaultConfig {


  uint256 private _fee;
  uint256 private _gasLimit;
  uint256 private _ownerReward;
  address[] private _vaults;

  constructor () Ownable(_msgSender()) {
    _gasLimit = 9000;
  }

  event Created(address indexed vault);
  event FeeUpdated(uint256 fee);
  event OwnerRewardUpdated(uint256 fee);
  event Withdrawn(address indexed owner, address indexed recipient, address indexed token, uint256 value);

  function fee() override external view returns (uint256) {

    return _fee;
  }

  function gasLimit() override external view returns (uint256) {

    return _gasLimit;
  }

  function ownerReward() override external view returns (uint256) {

    return _ownerReward;
  }

  function vaults() external view returns (address[] memory) {

    return _vaults;
  }

  function createVault(address owner_) external returns (Coin98Vault vault) {

    vault = new Coin98Vault(address(this), owner_);
    _vaults.push(address(vault));
    emit Created(address(vault));
  }

  function setGasLimit(uint256 limit_) public onlyOwner {

    _gasLimit = limit_;
  }

  function setFee(uint256 fee_, uint256 reward_) public onlyOwner {

    require(fee_ >= reward_, "C98Vault: Invalid reward amount");

    _fee = fee_;
    _ownerReward = reward_;

    emit FeeUpdated(fee_);
    emit OwnerRewardUpdated(reward_);
  }

  function withdraw(address token_, address destination_, uint256 amount_) public onlyOwner {

    require(destination_ != address(0), "C98Vault: Destination is zero address");

    uint256 availableAmount;
    if(token_ == address(0)) {
      availableAmount = address(this).balance;
    } else {
      availableAmount = IERC20(token_).balanceOf(address(this));
    }

    require(amount_ <= availableAmount, "C98Vault: Not enough balance");

    if(token_ == address(0)) {
      destination_.call{value:amount_, gas:_gasLimit}("");
    } else {
      IERC20(token_).transfer(destination_, amount_);
    }

    emit Withdrawn(_msgSender(), destination_, token_, amount_);
  }

  function withdrawNft(address token_, address destination_, uint256 tokenId_) public onlyOwner {

    require(destination_ != address(0), "C98Vault: destination is zero address");

    IERC721(token_).transferFrom(address(this), destination_, tokenId_);

    emit Withdrawn(_msgSender(), destination_, token_, 1);
  }
}