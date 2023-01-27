
pragma solidity ^0.8.0;

library Counters {

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        unchecked {
            counter._value += 1;
        }
    }

    function decrement(Counter storage counter) internal {

        uint256 value = counter._value;
        require(value > 0, "Counter: decrement overflow");
        unchecked {
            counter._value = value - 1;
        }
    }

    function reset(Counter storage counter) internal {

        counter._value = 0;
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
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
pragma solidity ^0.8.0;


contract GenesisSupply is VRFConsumerBase, AccessControl {

    using Counters for Counters.Counter;

    enum TokenType {
        NONE,
        GOD,
        DEMI_GOD,
        ELEMENTAL
    }
    enum TokenSubtype {
        NONE,
        CREATIVE,
        DESTRUCTIVE,
        AIR,
        EARTH,
        ELECTRICITY,
        FIRE,
        MAGMA,
        METAL,
        WATER
    }

    struct TokenTraits {
        TokenType tokenType;
        TokenSubtype tokenSubtype;
    }

    bytes32 private keyHash;
    uint256 private fee;
    uint256 private seed;
    bytes32 private randomizationRequestId;


    uint256 public constant MAX_SUPPLY = 1001;
    uint256 public constant GODS_MAX_SUPPLY = 51;
    uint256 public constant DEMI_GODS_MAX_SUPPLY = 400;
    uint256 public constant DEMI_GODS_SUBTYPE_MAX_SUPPLY = 200;
    uint256 public constant ELEMENTALS_MAX_SUPPLY = 550;
    uint256 public constant ELEMENTALS_MAJOR_SUBTYPE_MAX_SUPPLY = 100;
    uint256 public constant ELEMENTALS_MINOR_SUBTYPE_MAX_SUPPLY = 50;
    uint256 public constant RESERVED_GODS_MAX_SUPPLY = 6;

    Counters.Counter private tokenCounter;
    Counters.Counter private godsCounter;
    Counters.Counter private creativeDemiGodsCounter;
    Counters.Counter private destructiveDemiGodsCounter;
    Counters.Counter private earthElementalsCounter;
    Counters.Counter private waterElementalsCounter;
    Counters.Counter private fireElementalsCounter;
    Counters.Counter private airElementalsCounter;
    Counters.Counter private electricityElementalsCounter;
    Counters.Counter private metalElementalsCounter;
    Counters.Counter private magmaElementalsCounter;
    Counters.Counter private reservedGodsTransfered;

    mapping(uint256 => TokenTraits) private tokenIdToTraits;

    bool public isRevealed;
    bytes32 public constant GENESIS_ROLE = keccak256("GENESIS_ROLE");

    constructor(
        address vrfCoordinator,
        address linkToken,
        bytes32 _keyhash,
        uint256 _fee
    ) VRFConsumerBase(vrfCoordinator, linkToken) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        keyHash = _keyhash;
        fee = _fee;
        isRevealed = false;
        for (uint256 i = 0; i < RESERVED_GODS_MAX_SUPPLY; i++) {
            godsCounter.increment();
            tokenCounter.increment();
        }
    }

    function setIsRevealed(bool _isRevealed) external onlyRole(GENESIS_ROLE) {

        isRevealed = _isRevealed;
    }

    function currentIndex() public view returns (uint256 index) {

        return tokenCounter.current();
    }

    function reservedGodsCurrentIndexAndSupply()
        public
        view
        onlyRole(GENESIS_ROLE)
        returns (uint256 index, uint256 supply)
    {

        return (reservedGodsTransfered.current(), RESERVED_GODS_MAX_SUPPLY);
    }


    function mint(uint256 count)
        public
        onlyRole(GENESIS_ROLE)
        seedGenerated
        returns (uint256 startIndex, uint256 endIndex)
    {

        require(
            tokenCounter.current() + count < MAX_SUPPLY + 1,
            "Not enough supply"
        );
        uint256 firstTokenId = tokenCounter.current();
        for (uint256 i = 0; i < count; i++) {
            uint256 nextTokenId = firstTokenId + i;
            tokenIdToTraits[nextTokenId] = generateRandomTraits(
                generateRandomNumber(nextTokenId)
            );
            tokenCounter.increment();
        }
        return (firstTokenId, firstTokenId + count);
    }

    function mintReservedGods(uint256 count) public onlyRole(GENESIS_ROLE) {

        uint256 nextIndex = reservedGodsTransfered.current();
        for (uint256 i = nextIndex; i < count + nextIndex; i++) {
            tokenIdToTraits[i] = TokenTraits(TokenType.GOD, TokenSubtype.NONE);
            reservedGodsTransfered.increment();
        }
    }

    function generateSeed() external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(seed == 0, "Seed already generated");
        require(randomizationRequestId == 0, "Randomization already started");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        randomizationRequestId = requestRandomness(keyHash, fee);
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomNumber)
        internal
        override
    {

        require(requestId == randomizationRequestId, "Invalid requestId");
        require(seed == 0, "Seed already generated");
        seed = randomNumber;
    }


    function generateRandomNumber(uint256 nonce)
        private
        view
        seedGenerated
        returns (uint256 randomNumber)
    {

        return
            uint256(keccak256(abi.encodePacked(block.timestamp, nonce, seed)));
    }

    function generateRandomTraits(uint256 randomNumber)
        private
        returns (TokenTraits memory tokenTraits)
    {

        uint256 godsLeft = GODS_MAX_SUPPLY - godsCounter.current();

        uint256 creativeDemiGodsLeft = DEMI_GODS_SUBTYPE_MAX_SUPPLY -
            creativeDemiGodsCounter.current();
        uint256 destructiveDemiGodsLeft = DEMI_GODS_SUBTYPE_MAX_SUPPLY -
            destructiveDemiGodsCounter.current();
        uint256 demiGodsLeft = creativeDemiGodsLeft + destructiveDemiGodsLeft;

        uint256 elementalsLeft = ELEMENTALS_MAX_SUPPLY -
            earthElementalsCounter.current() -
            waterElementalsCounter.current() -
            fireElementalsCounter.current() -
            airElementalsCounter.current() -
            electricityElementalsCounter.current() -
            metalElementalsCounter.current() -
            magmaElementalsCounter.current();

        uint256 totalCountLeft = godsLeft + demiGodsLeft + elementalsLeft;

        uint256 randomTypeIndex = (randomNumber % totalCountLeft) + 1;
        if (randomTypeIndex <= godsLeft) {
            godsCounter.increment();
            return TokenTraits(TokenType.GOD, TokenSubtype.NONE);
        } else if (randomTypeIndex <= godsLeft + demiGodsLeft) {
            uint256 randomSubtypeIndex = (randomNumber % demiGodsLeft) + 1;
            if (randomSubtypeIndex <= creativeDemiGodsLeft) {
                creativeDemiGodsCounter.increment();
                return TokenTraits(TokenType.DEMI_GOD, TokenSubtype.CREATIVE);
            } else {
                destructiveDemiGodsCounter.increment();
                return
                    TokenTraits(TokenType.DEMI_GOD, TokenSubtype.DESTRUCTIVE);
            }
        } else {
            return generateElementalSubtype(randomNumber);
        }
    }

    function generateElementalSubtype(uint256 randomNumber)
        private
        returns (TokenTraits memory traits)
    {

        uint256 earthElementalsLeft = ELEMENTALS_MAJOR_SUBTYPE_MAX_SUPPLY -
            earthElementalsCounter.current();
        uint256 waterElementalsLeft = ELEMENTALS_MAJOR_SUBTYPE_MAX_SUPPLY -
            waterElementalsCounter.current();
        uint256 fireElementalsLeft = ELEMENTALS_MAJOR_SUBTYPE_MAX_SUPPLY -
            fireElementalsCounter.current();
        uint256 airElementalsLeft = ELEMENTALS_MAJOR_SUBTYPE_MAX_SUPPLY -
            airElementalsCounter.current();
        uint256 electricityElementalsLeft = ELEMENTALS_MINOR_SUBTYPE_MAX_SUPPLY -
                electricityElementalsCounter.current();
        uint256 metalElementalsLeft = ELEMENTALS_MINOR_SUBTYPE_MAX_SUPPLY -
            metalElementalsCounter.current();
        uint256 magmaElementalsLeft = ELEMENTALS_MINOR_SUBTYPE_MAX_SUPPLY -
            magmaElementalsCounter.current();
        uint256 elementalsLeft = earthElementalsLeft +
            waterElementalsLeft +
            fireElementalsLeft +
            airElementalsLeft +
            electricityElementalsLeft +
            metalElementalsLeft +
            magmaElementalsLeft;

        uint256 randomSubtypeIndex = (randomNumber % elementalsLeft) + 1;
        if (randomSubtypeIndex <= earthElementalsLeft) {
            earthElementalsCounter.increment();
            return TokenTraits(TokenType.ELEMENTAL, TokenSubtype.EARTH);
        } else if (
            randomSubtypeIndex <= earthElementalsLeft + waterElementalsLeft
        ) {
            waterElementalsCounter.increment();
            return TokenTraits(TokenType.ELEMENTAL, TokenSubtype.WATER);
        } else if (
            randomSubtypeIndex <=
            earthElementalsLeft + waterElementalsLeft + fireElementalsLeft
        ) {
            fireElementalsCounter.increment();
            return TokenTraits(TokenType.ELEMENTAL, TokenSubtype.FIRE);
        } else if (
            randomSubtypeIndex <=
            earthElementalsLeft +
                waterElementalsLeft +
                fireElementalsLeft +
                airElementalsLeft
        ) {
            airElementalsCounter.increment();
            return TokenTraits(TokenType.ELEMENTAL, TokenSubtype.AIR);
        } else if (
            randomSubtypeIndex <=
            earthElementalsLeft +
                waterElementalsLeft +
                fireElementalsLeft +
                airElementalsLeft +
                electricityElementalsLeft
        ) {
            electricityElementalsCounter.increment();
            return TokenTraits(TokenType.ELEMENTAL, TokenSubtype.ELECTRICITY);
        } else if (
            randomSubtypeIndex <=
            earthElementalsLeft +
                waterElementalsLeft +
                fireElementalsLeft +
                airElementalsLeft +
                electricityElementalsLeft +
                metalElementalsLeft
        ) {
            metalElementalsCounter.increment();
            return TokenTraits(TokenType.ELEMENTAL, TokenSubtype.METAL);
        } else {
            magmaElementalsCounter.increment();
            return TokenTraits(TokenType.ELEMENTAL, TokenSubtype.MAGMA);
        }
    }

    function getMetadataForTokenId(uint256 tokenId)
        public
        view
        validTokenId(tokenId)
        returns (TokenTraits memory traits)
    {

        require(isRevealed, "Not revealed yet");
        return tokenIdToTraits[tokenId];
    }


    modifier validTokenId(uint256 tokenId) {

        require(tokenId < MAX_SUPPLY, "Invalid tokenId");
        require(tokenId >= 0, "Invalid tokenId");
        _;
    }

    modifier seedGenerated() {

        require(seed > 0, "Seed not generated");
        _;
    }
}