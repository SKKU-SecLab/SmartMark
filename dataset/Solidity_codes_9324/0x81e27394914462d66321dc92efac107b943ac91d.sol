
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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
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

}// MIT

pragma solidity ^0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT LICENSE

pragma solidity ^0.8.0;


interface IDIAMOND is IERC20Upgradeable {

    function mint(address to, uint256 amount) external;

    function burn(address from, uint256 amount) external;

}// MIT LICENSE 

pragma solidity >=0.5.17;

interface ISablier {

    event CreateStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        address tokenAddress,
        uint256 startTime,
        uint256 stopTime
    );

    event WithdrawFromStream(uint256 indexed streamId, address indexed recipient, uint256 amount);

    event CancelStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 senderBalance,
        uint256 recipientBalance
    );

    function balanceOf(uint256 streamId, address who) external view returns (uint256 balance);


    function getStream(uint256 streamId)
        external
        view
        returns (
            address sender,
            address recipient,
            uint256 deposit,
            address token,
            uint256 startTime,
            uint256 stopTime,
            uint256 remainingBalance,
            uint256 ratePerSecond
        );


    function createStream(address recipient, uint256 deposit, address tokenAddress, uint256 startTime, uint256 stopTime)
        external
        returns (uint256 streamId);


    function withdrawFromStream(uint256 streamId, uint256 funds) external returns (bool);


    function cancelStream(uint256 streamId) external returns (bool);

}// MIT LICENSE

pragma solidity ^0.8.0;




interface IDiamondHeist is IERC721Upgradeable, IERC721MetadataUpgradeable {

  struct LlamaDog {
    bool isLlama;
    uint8 body;
    uint8 hat;
    uint8 eye;
    uint8 mouth;
    uint8 clothes;
    uint8 tail;
    uint8 alphaIndex;
  }
  function minted() external view returns (uint256);

  function getPaidTokens() external view returns (uint256);

  function getTokenTraits(uint256 tokenId) external view returns (LlamaDog memory);

  function isLlama(uint256 tokenId) external view returns(bool);

  function addManyToStaking(address account, uint16[] calldata tokenIds) external;

}

contract LlamaPoolV2 is Initializable, ContextUpgradeable, OwnableUpgradeable, PausableUpgradeable, ReentrancyGuardUpgradeable {

  event DepositLlama(address indexed owner, uint16[] indexed tokenIds, uint256 diamonds, uint256 streamId);
  event WithdrawLlama(address indexed owner, uint16[] indexed tokenIds, uint256 diamonds);
  event EmergencyWithdraw(address indexed owner, uint16[] indexed tokenIds);
  event EmergencyCancel(uint256[] indexed streams);

  IDiamondHeist public game;
  IDIAMOND public diamond;
  ISablier public sablier;

  uint256 public depositPct;
  uint256 public withdrawPct;

  uint256 public depositCounter;
  uint256 public withdrawCounter;
  uint256[] public deposits;
  mapping(address => uint256[]) public ownerStreams;

  constructor() initializer {}

  function initialize() initializer public {

      __Pausable_init();
      __Ownable_init();
      __ReentrancyGuard_init();
      __Context_init();

      depositPct = 50;
      withdrawPct = 90;

      _pause();
  }

  function setContracts(
    IDiamondHeist _diamondheist,
    IDIAMOND _diamond,
    ISablier _sablier
  ) external onlyOwner {

    game = _diamondheist;
    diamond = _diamond;
    sablier = _sablier;
  }

  function getBasePrice() public view returns (uint256) {

    uint256 tokenId = game.minted();
    if (tokenId <= 15000) return 2000 ether;
    if (tokenId <= 22500) return 5000 ether;
    if (tokenId <= 30000) return 10000 ether;
    return 20000 ether;
  }

  function getDepositPrice() public view returns (uint256) {

    return getBasePrice() * depositPct / 100;
  }

  function getWithdrawPrice() public view returns (uint256) {

    return getBasePrice() * withdrawPct / 100;
  }

  function count() public view returns (uint256) {

    return depositCounter - withdrawCounter;
  }

  function streamDiamond(address recipient, uint256 amount) internal returns (uint256, uint256) {

    uint256 timeDelta = 864000; // 10 days
    uint256 depositAmount = amount - (amount % timeDelta); // not quite the full amount
    uint256 startTime = block.timestamp; // Now
    uint256 stopTime = block.timestamp + timeDelta; // 10 days from now

    diamond.mint(address(this), depositAmount);
    diamond.approve(address(sablier), depositAmount); // approve the transfer

    uint256 streamId = sablier.createStream(recipient, depositAmount, address(diamond), startTime, stopTime);
    ownerStreams[_msgSender()].push(streamId);
    return (streamId, depositAmount);
  }

  function deposit(uint16[] calldata tokenIds) external whenNotPaused nonReentrant {

    require(tx.origin == _msgSender(), "Only EOA");
    require(tokenIds.length > 0, "No tokenIds");

    uint256 llamaBefore = game.balanceOf(address(this));
    for (uint i = 0; i < tokenIds.length; i++) {
      require(game.isLlama(tokenIds[i]), "You can only deposit llamas");
      deposits.push(tokenIds[i]);
      depositCounter++;
      game.transferFrom(_msgSender(), address(this), tokenIds[i]);
    }
    
    uint256 reward = tokenIds.length * getDepositPrice();
    (uint256 streamId, uint256 depositAmount) = streamDiamond(_msgSender(), reward);

    emit DepositLlama(_msgSender(), tokenIds, depositAmount, streamId);
    require(game.balanceOf(address(this)) == llamaBefore + tokenIds.length, "Not received");
  }

  function withdraw(uint256 amount) external whenNotPaused nonReentrant returns (uint16[] memory tokenIds) {

    require(tx.origin == _msgSender(), "Only EOA");
    require(amount <= count(), "Not enough llamas");

    uint256 llamaBefore = game.balanceOf(address(this));
    uint256 diamondBefore = diamond.balanceOf(address(_msgSender()));

    tokenIds = new uint16[](amount);
    for (uint i = 0; i < amount; i++) {
      tokenIds[i] = uint16(deposits[withdrawCounter]);
      withdrawCounter++;
    }
    game.addManyToStaking(address(_msgSender()), tokenIds);

    uint256 payment = amount * getWithdrawPrice();
    diamond.burn(_msgSender(), payment);

    emit WithdrawLlama(_msgSender(), tokenIds, payment);

    require(game.balanceOf(address(this)) == llamaBefore - amount, "Not sent llama");
    require(diamond.balanceOf(_msgSender()) == diamondBefore - payment, "Not paid diamond");

    return tokenIds;
  }

  function pause() external onlyOwner {

      _pause();
  }

  function unpause() external onlyOwner {

      _unpause();
  }

  function emergencyWithdraw(uint16[] memory tokenIds) external whenPaused onlyOwner {

    for (uint i = 0; i < tokenIds.length; i++) {
      game.transferFrom(address(this), address(_msgSender()), tokenIds[i]);
    }
    emit WithdrawLlama(_msgSender(), tokenIds, 0);
    emit EmergencyWithdraw(_msgSender(), tokenIds);
  }

  function emergencyCancel(uint256[] memory streamIds) external whenPaused onlyOwner {

    for (uint256 index = 0; index < streamIds.length; index++) {
      sablier.cancelStream(streamIds[index]);
    }
    emit EmergencyCancel(streamIds);
  }

  function getStreams(address owner) external view returns (uint256[] memory) {

    return ownerStreams[owner];
  }

  function withdrawStreams(uint256[] memory streamIds, uint256[] memory funds) external nonReentrant {

    for (uint i = 0; i < streamIds.length; i++) {
      sablier.withdrawFromStream(streamIds[i], funds[i]);
    }
  }

  function setPercentages(uint256 _newDeposit, uint256 _newWithdraw) external onlyOwner {

    depositPct = _newDeposit;
    withdrawPct = _newWithdraw;
  }

  uint256[42] private __gap;
}