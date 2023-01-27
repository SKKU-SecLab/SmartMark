
pragma solidity ^0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal onlyInitializing {
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal onlyInitializing {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}// MIT LICENSE

pragma solidity ^0.8.4;


interface IHouseGame is IERC721Upgradeable {

    function getPropertyDamage(uint256 tokenId)
        external
        view
        returns (uint256 _propertyDamage);


    function getIncomePerDay(uint256 tokenId)
        external
        view
        returns (uint256 _incomePerDay);


    function getHousePaidTokens() external view returns (uint256);


    function getBuildingPaidTokens() external view returns (uint256);


    function getTokenTraits(uint256 tokenId)
        external
        view
        returns (HouseBuilding memory);


    struct HouseBuilding {
        bool isHouse;
        uint8 model;
        uint256 imageId;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT LICENSE

pragma solidity ^0.8.4;

interface ICASH is IERC20{

  function mint(address to, uint256 amount) external;

  function burn(address from, uint256 amount) external;

}// MIT LICENSE

pragma solidity ^0.8.4;

interface IRandomizer {

  function random(uint256 seed) external view returns (uint256);

}// MIT LICENSE 

pragma solidity ^0.8.4;

interface IRewardPool {

    function payTax(address account, uint256 burnAmount) external;

}// MIT LICENSE

pragma solidity ^0.8.4;



contract Agent is Initializable, OwnableUpgradeable, IERC721ReceiverUpgradeable, PausableUpgradeable {

  
  struct Stake {
    uint8 tenantRating;
    uint16 tokenId;
    uint256 value;
    address owner;
  }

  event TokenStaked(address owner, uint256 tokenId, bool isHouse, uint256 value);
  event HouseClaimed(uint256 tokenId, uint256 earned, bool unstaked);
  event BuildingClaimed(uint256 tokenId, uint256 earned, bool unstaked);

  IHouseGame public house;
  ICASH public cash;
  IRewardPool public rewardPool;

  mapping(uint256 => Stake) public agent; 
  mapping(uint256 => Stake) public pack; 
  uint256 public totalBuildingStaked; 
  uint256 public unaccountedRewards; 
  uint256 public totalReceivedBuidingTax; 

  uint256 public constant MINIMUM_TO_EXIT = 3 days;
  uint256 public constant BUILDING_CLAIM_TAX_PERCENTAGE = 25;

  uint256 public totalHouseStaked;
  uint256 private lastClaimTimestamp;

  bool public rescueEnabled;

  IRandomizer public randomizer;

  function initialize(address _house, address _cash, address _randomizer) external initializer { 

    OwnableUpgradeable.__Ownable_init();
    PausableUpgradeable.__Pausable_init();

    house = IHouseGame(_house);
    cash = ICASH(_cash);
    randomizer = IRandomizer(_randomizer);

    rescueEnabled = false;
  }


  function addManyToAgentAndPack(address account, uint16[] calldata tokenIds) external {

    require(account == _msgSender() || _msgSender() == address(house), "DONT GIVE YOUR TOKENS AWAY");
    require(tokenIds.length > 0, "No token to stake");
    
    for (uint i = 0; i < tokenIds.length; i++) {
      if (_msgSender() != address(house)) {
        require(house.ownerOf(tokenIds[i]) == _msgSender(), "AINT YO TOKEN");
        house.transferFrom(_msgSender(), address(this), tokenIds[i]);
      } else if (tokenIds[i] == 0) {
        continue;
      }

      if (isHouse(tokenIds[i])) 
        _addHouseToAgent(account, tokenIds[i]);
      else 
        _addBuildingToPack(account, tokenIds[i]);
    }
  }

  function _addHouseToAgent(address account, uint256 tokenId) internal whenNotPaused _updateEarnings {

    uint8 _random =  uint8(randomizer.random(tokenId) % 10 + 1);
    agent[tokenId] = Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: block.timestamp, // solhint-disable-line not-rely-on-time
      tenantRating: _random
    });
    totalHouseStaked += 1;
    emit TokenStaked(account, tokenId, true, block.timestamp); // solhint-disable-line not-rely-on-time
  }

  function _addBuildingToPack(address account, uint256 tokenId) internal {

    pack[tokenId] = Stake({
      owner: account,
      tokenId: uint16(tokenId),
      value: totalReceivedBuidingTax,
      tenantRating : 0
    });
    totalBuildingStaked += 1;
    emit TokenStaked(account, tokenId, false, totalReceivedBuidingTax);
  }


  function claimManyFromAgentAndPack(uint16[] calldata tokenIds, bool unstake, bool burn) external whenNotPaused _updateEarnings {

    require(tokenIds.length > 0, "No token to claim");
    if(burn) {
      require(unstake, "burn only when unstake");
    }
    uint256 owed = 0;
    for (uint i = 0; i < tokenIds.length; i++) {
      if (isHouse(tokenIds[i]))
        owed += _claimHouseFromAgent(tokenIds[i], unstake);
      else
        owed += _claimBuildingFromPack(tokenIds[i], unstake);
    }
    if (owed == 0) return;
    if (unstake && burn) {
      rewardPool.payTax(_msgSender(), owed);
      return;
    }
    cash.mint(_msgSender(), owed);
  }

  function _claimHouseFromAgent(uint256 tokenId, bool unstake) internal returns (uint256 owed) {

    Stake storage stake = agent[tokenId];
    require(stake.owner == _msgSender(), "SWIPER, NO SWIPING");
    require(!(unstake && block.timestamp - stake.value < MINIMUM_TO_EXIT), "GONNA BE COLD WITHOUT THREE DAY'S CASH"); // solhint-disable-line not-rely-on-time, reason-string
    if (stake.value > lastClaimTimestamp) {
      owed = 0; // $CASH production stopped already
    } else {
      owed = (lastClaimTimestamp - stake.value) * house.getIncomePerDay(tokenId) / 1 days;
    }
    uint256 _random = randomizer.random(tokenId) % 100 + 1;
    uint256 tax = owed * BUILDING_CLAIM_TAX_PERCENTAGE / 100;
    _payBuildingTax(tax); // percentage tax to staked building
    owed -= tax; // remainder goes to House owner
    if (_random > stake.tenantRating * 10) {
      owed = _propertyDamageTax(owed, house.getPropertyDamage(tokenId));
    }

    if (unstake) {
      _random = randomizer.random(tokenId) % 100 + 1;
      if (_random > stake.tenantRating * 10) {
        _payBuildingTax(owed);
        owed = 0;
      }
      house.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back House
      delete agent[tokenId];
      totalHouseStaked -= 1;
    } else {
      stake.value = block.timestamp; // solhint-disable-line not-rely-on-time
    }
    emit HouseClaimed(tokenId, owed, unstake);
  }

  function _claimBuildingFromPack(uint256 tokenId, bool unstake) internal returns (uint256 owed) {

    require(house.ownerOf(tokenId) == address(this), "you're not part of this!");
    Stake memory stake = pack[tokenId];
    require(stake.owner == _msgSender(), "no stealing here");
    owed = totalReceivedBuidingTax - stake.value;
    if (unstake) {
      totalBuildingStaked--;
      house.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // Send back Building
      delete pack[tokenId];
    } else {
      pack[tokenId].value =  totalReceivedBuidingTax;
    }
    emit BuildingClaimed(tokenId, owed, unstake);
  }

  function rescue(uint256[] calldata tokenIds) external {

    require(rescueEnabled, "RESCUE DISABLED");
    require(tokenIds.length > 0, "No token to rescue");
    uint256 tokenId;
    Stake memory stake;
    for (uint i = 0; i < tokenIds.length; i++) {
      tokenId = tokenIds[i];
      if (isHouse(tokenId)) {
        stake = agent[tokenId];
        require(stake.owner == _msgSender(), "no stealing here");
        house.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // send back House
        delete agent[tokenId];
        totalHouseStaked -= 1;
        emit HouseClaimed(tokenId, 0, true);
      } else {
        stake = pack[tokenId];
        require(stake.owner == _msgSender(), "no stealing here");
        totalBuildingStaked -= 1;
        house.safeTransferFrom(address(this), _msgSender(), tokenId, ""); // Send back Building
        delete pack[tokenId];
        emit BuildingClaimed(tokenId, 0, true);
      }
    }
  }


  function _payBuildingTax(uint256 amount) internal {

    if (totalBuildingStaked == 0) { // if there's no staked building
      unaccountedRewards += amount; // keep track of $CASH due to building
      return;
    }
    totalReceivedBuidingTax += (amount + unaccountedRewards) / totalBuildingStaked;
    unaccountedRewards = 0;
  }

  function _propertyDamageTax(uint256 amount, uint256 _propertyDamage) internal pure returns(uint256) {

    return amount * (100 - _propertyDamage) / 100;
  }

  modifier _updateEarnings() {

    lastClaimTimestamp = block.timestamp; // solhint-disable-line not-rely-on-time
    _;
  }


  function setContracts(address _randomizer, address _rewardPool) external onlyOwner {

    require(_randomizer != address(0) && _rewardPool != address(0), "Invalid contract address");
    randomizer = IRandomizer(_randomizer);
    rewardPool = IRewardPool(_rewardPool);
  }

  function setRescueEnabled(bool _enabled) external onlyOwner {

    rescueEnabled = _enabled;
  }

  function setPaused(bool _paused) external onlyOwner {

    if (_paused) _pause();
    else _unpause();
  }


  function isHouse(uint256 tokenId) public view returns (bool _house) {

    _house = house.getTokenTraits(tokenId).isHouse;
  }

  function onERC721Received(
        address,
        address from,
        uint256,
        bytes calldata
    ) external pure override returns (bytes4) {

      require(from == address(0x0), "Cannot send tokens to Agent directly"); // solhint-disable-line reason-string
      return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }
}