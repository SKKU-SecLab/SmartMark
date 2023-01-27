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
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}//GNU General Public License v3.0
pragma solidity ^0.8.0;

interface ILegionnaire {

  
  function safeMint(address to, uint256 tokenId) external;


  function setTokenURI(uint256 tokenId, string memory _tokenURI) external;

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

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) private {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}//GNU General Public License v3.0
pragma solidity ^0.8.0;


contract Operatorable is Ownable, AccessControl {

  bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
  bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");

  modifier onlyOperator() {

    require(hasRole(OPERATOR_ROLE, msg.sender), "Operatorable: CALLER_NO_OPERATOR_ROLE");
    _;
  }

  modifier onlyURISetter() {

    require(hasRole(URI_SETTER_ROLE, msg.sender), "Settable: CALLER_NO_URI_SETTER_ROLE");
    _;
  }

  constructor() {
    _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    _setupRole(OPERATOR_ROLE, msg.sender);
    _setupRole(URI_SETTER_ROLE, msg.sender);
  }

  function addOperator(address _account) public onlyOwner {

    grantRole(OPERATOR_ROLE, _account);
  }

  function removeOperator(address _account) public onlyOwner {

    revokeRole(OPERATOR_ROLE, _account);
  }

  function addURISetter(address _account) public onlyOwner {

    grantRole(URI_SETTER_ROLE, _account);
  }

  function removeURISetter(address _account) public onlyOwner {

    revokeRole(URI_SETTER_ROLE, _account);
  }

  function isOperator(address _account) public view returns (bool) {

    return hasRole(OPERATOR_ROLE, _account);
  }

  function isURISetter(address _account) public view returns (bool) {

    return hasRole(URI_SETTER_ROLE, _account);
  }
}//GNU General Public License v3.0
pragma solidity ^0.8.0;

library NumberHelper {

  function min(uint a, uint b) internal pure returns (uint) {

    return a < b ? a : b;
  }

  function daysSince(uint256 _activeDateTime, uint256 _interval) internal view returns (uint256) {

    unchecked {
      uint256 passedTime = (block.timestamp - _activeDateTime) / _interval;
      if( passedTime < 24) {
        return 1;
      } else if( passedTime < 48 ) {
        return 2;
      } else if( passedTime < 72 ) {
        return 3;
      } else if( passedTime < 96 ) {
        return 4;
      } else if( passedTime < 120 ) {
        return 5;
      } else if( passedTime < 144 ) {
        return 6;
      } else if( passedTime < 168 ) {
        return 7;
      } else {
        return 8;
      }
    }
  }
}//GNU General Public License v3.0

          

pragma solidity ^0.8.0;



contract Satoshiverse is VRFConsumerBase, Operatorable, ReentrancyGuard {

  ILegionnaire public legionnaire;

  address payable public svEthAddr = payable(0x981268bF660454e24DBEa9020D57C2504a538C57);
  
  uint16 _claimSV = 190;
  uint16 _purchaseSV = 3301;

  uint256 SV_MAX = 10000;
  
  uint256 _activeDateTime; 
  uint256 INTERVAL = 3600;
  uint256 randNonce;
  
  uint256 randomNess;
  uint256 internal fee;
  bytes32 internal keyHash;
  
  bool revealState;

  bool public claimState = true;
  bool public purchaseState = true;

  bytes32 requestId;

  string[] public leftoverUris;

  mapping(address => mapping(string => uint8)) public tokensCount;

  mapping(address => uint8) public purchasedSoFar;
  

  constructor(
    address _operator,
    address _uriSetter,
    address _legionnaire,
    address _vrfCoordinator,
    address _link,
    bytes32 _keyHash,
    uint256 _fee
  ) 
    VRFConsumerBase(_vrfCoordinator, _link)
  {
    keyHash = _keyHash;
    fee = _fee;

    legionnaire = ILegionnaire(_legionnaire);

    addOperator(_operator);
    addURISetter(_uriSetter);
  }

  function setPaymentAddress(address _svEthAddr) external onlyOwner {

    svEthAddr = payable(_svEthAddr);
  }

  function seedPresaleWhiteList(address[] calldata users, string calldata tokenType, uint8[] calldata counts) external onlyOperator {

    require(users.length == counts.length, "Mismatched presale addresses and counts");

    for(uint256 i = 0; i < users.length; i++) {
      tokensCount[users[i]][tokenType] += counts[i];
    }
  }

  function toggleClaim() external onlyOperator {

    claimState = !claimState;
  }
  function togglePurchase() external onlyOperator {

    purchaseState = !purchaseState;
  }

  function popRandomTokenURI() internal returns(string memory) {

    uint256 randomIndex = getRandomIndex(leftoverUris.length);
    string memory tokenURI = leftoverUris[randomIndex];
    leftoverUris[randomIndex] = leftoverUris[leftoverUris.length - 1];
    leftoverUris.pop();
    return tokenURI;
  }

  function claim(uint256 claimedCount) external nonReentrant {

    require(claimState, "Claim is disabled");
    require(block.timestamp >= _activeDateTime, "Presale not start yet");
    
    uint8 genesisTokenCount = tokensCount[msg.sender]['genesis'];
    uint8 platinumTokenCount = tokensCount[msg.sender]['platinum'];
    uint8 goldTokenCount = tokensCount[msg.sender]['gold'];
    uint8 silverTokenCount = tokensCount[msg.sender]['silver'];

    uint256 passedDays = NumberHelper.daysSince(_activeDateTime, INTERVAL);

    uint256 totalCount = genesisTokenCount;
    if (passedDays >= 1) {
        totalCount += platinumTokenCount;
    }
    if (passedDays >= 2) {
        totalCount += goldTokenCount;
    }
    if (passedDays >= 3) {
        totalCount += silverTokenCount;
    }

    uint256 minCount = NumberHelper.min(totalCount, claimedCount);
    require(_claimSV + minCount <= 3301, "No legionnaires left for presale");

    uint256 i = 0;
    uint256 tokenId;
    string memory tokenURI;

    while(i < minCount) {
      if(genesisTokenCount > 0) {
        genesisTokenCount--;
      } else if (passedDays >= 1 && platinumTokenCount > 0) {
        platinumTokenCount--;
      } else if (passedDays >= 2 && goldTokenCount > 0) {
        goldTokenCount--;
      } else if (passedDays >= 3 && silverTokenCount > 0) {
        silverTokenCount--;
      }

      if(revealState) {
        tokenURI = popRandomTokenURI();
      }

      tokenId = _claimSV;
      _claimSV++;
      
      legionnaire.safeMint(msg.sender, tokenId);
      if(!revealState) {
        legionnaire.setTokenURI(tokenId, "placeholder");
      } else {
        legionnaire.setTokenURI(tokenId, tokenURI);
      }
      i++;
    }

    tokensCount[msg.sender]['genesis'] = genesisTokenCount;
    tokensCount[msg.sender]['platinum'] = platinumTokenCount;
    tokensCount[msg.sender]['gold'] = goldTokenCount;
    tokensCount[msg.sender]['silver'] = silverTokenCount;
  }

  
  function purchase(uint256 count) external payable nonReentrant {

    require(purchaseState, "Purchase is disabled");
    require(block.timestamp >= _activeDateTime, "Sale not start yet");
    uint256 passedDays = NumberHelper.daysSince(_activeDateTime, INTERVAL);
    require(passedDays > 3, "Public sale not start yet");
    require(msg.value >= count * .1 ether, "Not enough ether");
    
    uint256 limit; 
    if(passedDays < 5) {
      limit = purchasedSoFar[msg.sender];
      require(count + limit > 0 && count + limit < 3, "Not allowed to purchase that amount");
      purchasedSoFar[msg.sender] += uint8(count);
    } else if (passedDays < 6) {
      require(count < 11, "Up to 10 only");
    }

    limit = count;
    require(_purchaseSV + limit <= SV_MAX + 1, "No legionnaires left for public sale");

    uint256 tokenId;
    string memory tokenURI;


    for (uint256 i = 0; i < limit; i++) {
      if(revealState) {
        tokenURI = popRandomTokenURI();
      }

      tokenId = _purchaseSV;
      _purchaseSV++;
    
      legionnaire.safeMint(msg.sender, tokenId);
      if(!revealState) {
        legionnaire.setTokenURI(tokenId, "placeholder");
      } else {
        legionnaire.setTokenURI(tokenId, tokenURI);
      }
    }

    (bool sent, ) = svEthAddr.call{ value: limit * .1 ether }("");
    require(sent, "Failed to send Ether");

    if(msg.value > count * .1 ether) {
      (sent, ) = payable(msg.sender).call{ value: msg.value - limit * .1 ether }("");
      require(sent, "Failed to send change back to user");
    }
  }

  function setActiveDateTime(uint256 activeDateTime) external onlyOperator {

    _activeDateTime = activeDateTime;
  }


  function pushLeftOverUris(string[] memory leftoverUris_) external onlyOperator {

    require(!revealState, "Self-Reveal already begun");

    for(uint256 i = 0; i < leftoverUris_.length; i++) {
      leftoverUris.push(leftoverUris_[i]);
    }
  }

  function getLeftOverUrisLength() public view returns(uint256) {

    return leftoverUris.length;
  }

  function beginSelfRevealPeriod() external onlyOperator {

    revealState = true;
  }
   
  
  function getRandomIndex(uint256 range) internal returns(uint256) {

    randNonce++;
    return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce, randomNess))) % range;
  }


  function safeBatchMintAndTransfer(address holder, bool isSetUri, uint16 batchSize) external onlyOperator {

    require(revealState, "Have to begin Self-Reveal");
    require(_purchaseSV + batchSize <= SV_MAX + 1, "No legionnaires left for public sale");

    for(uint256 i = _purchaseSV; i < _purchaseSV + batchSize; i++) {
      legionnaire.safeMint(holder, i);
      if(isSetUri) {
        legionnaire.setTokenURI(i, "placeholder");
      }
    }

    _purchaseSV = uint16(_purchaseSV + batchSize);
  }

  function pairLegionnairesWithUris(uint16[] memory _tokenIds, string[] memory _tokenURIs) external onlyURISetter {

    require(_tokenIds.length == _tokenURIs.length, "Mismatched ids and URIs");
    require(_tokenIds.length > 0, "Empty parameters");

    while(_tokenIds.length > 0) {
      uint256 length = _tokenIds.length;
      uint256 randomIndex = getRandomIndex(length);
      legionnaire.setTokenURI(_tokenIds[length - 1], _tokenURIs[randomIndex]);
      _tokenURIs[randomIndex] = _tokenURIs[length - 1];
      delete _tokenIds[length - 1];
      delete _tokenURIs[length - 1];

      assembly { mstore(_tokenIds, sub(mload(_tokenIds), 1)) }
      assembly { mstore(_tokenURIs, sub(mload(_tokenURIs), 1)) }
    }
  }

  function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override {

    if(requestId == _requestId) {
      randomNess = _randomness;
    }
  }

  function setMaxLimit(uint256 maxLimit) external onlyOwner {

    require(maxLimit < 10001, "Exceed max limit 10000");
    SV_MAX = maxLimit;
  }

  function requestRandomToVRF() external onlyOperator {

    require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
    requestId = requestRandomness(keyHash, fee);
  }
}