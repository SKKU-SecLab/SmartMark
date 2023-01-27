
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

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
}// MIT

pragma solidity ^0.8.3;

interface IRainiCustomNFT {

  function onTransfered(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

  function onMerged(uint256 _newTokenId, uint256[] memory _tokenId, address _nftContractAddress, uint256[] memory data) external;

  function onMinted(address _to, uint256 _tokenId, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number, uint256[] memory _data) external;

  
  function setTokenStates(uint256[] memory id, bytes[] memory state) external;


  function getTokenState(uint256 id) external view returns (bytes memory);

  function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.3;



interface IRainiNft1155 is IERC1155 {

  struct CardLevel {
    uint64 conversionRate; // number of base tokens required to create
    uint32 numberMinted;
    uint128 tokenId; // ID of token if grouped, 0 if not
    uint32 maxStamina; // The initial and maxiumum stamina for a token
  }

  struct Card {
    uint64 costInUnicorns;
    uint64 costInRainbows;
    uint16 maxMintsPerAddress;
    uint32 maxSupply; // number of base tokens mintable
    uint32 allocation; // number of base tokens mintable with points on this contract
    uint32 mintTimeStart; // the timestamp from which the card can be minted
    bool locked;
    address subContract;
  }
  
  struct TokenVars {
    uint128 cardId;
    uint32 level;
    uint32 number; // to assign a numbering to NFTs
    bytes1 mintedContractChar;
  }

  function cardPathUri(uint256 _cardId) view external returns (string memory);


  function cards(uint256 _cardId) external view returns (Card memory);

  function cardLevels(uint256 _cardId, uint256 _level) external view returns (CardLevel memory);

  function tokenVars(uint256 _tokenId) external view returns (TokenVars memory);

}

contract RainiEvolvingNFTv2 is AccessControl, IRainiCustomNFT {


  IRainiNft1155 public nftContract;

  bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");

  string public baseUri;

  struct CardVars {
    uint32 numStates;
    uint32 timePeriod;
    uint32 initTime;
    bool repeats;
    bool resetsOnTransfer;
    bool coreEvolves;
    bool allowTimezoneSet;
    bool allowHemisphereSet;
    bool exists;
  }
  
  struct EvolvingTokenVars {
    uint128 cardId;
    uint32 initTime;
    uint32 lastState;
    bool evolves;
    bool isGrouped;
    bool exists;
  }

  mapping(uint256 => CardVars) public cards;
  mapping(uint256 => EvolvingTokenVars) public tokenVars;

  modifier onlyOwner() {

    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "caller is not an admin");
    _;
  }

  modifier onlyEditor() {

    require(hasRole(EDITOR_ROLE, _msgSender()), "caller is not an editor");
    _;
  }

  constructor (address _nftContractAddress, string memory _uri) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(EDITOR_ROLE, _nftContractAddress);
    nftContract = IRainiNft1155(_nftContractAddress);
    baseUri = _uri;
  }

  function initCards(
    uint256[] memory _cardId, 
    uint256[] memory _timePeriod, 
    uint256[] memory _numStates, 
    uint256[] memory _initTime, 
    bool[] memory _repeats, 
    bool[] memory _resetsOnTransfer, 
    bool[] memory _coreEvolves, 
    bool[] memory _allowTimezoneSet, 
    bool[] memory _allowHemisphereSet) 
    external onlyOwner {

      for (uint256 i; i < _cardId.length; i++) {
        cards[_cardId[i]] = CardVars({
          numStates: uint32(_numStates[i]),
          timePeriod: uint32(_timePeriod[i]),
          initTime: uint32(_initTime[i]),
          repeats: _repeats[i],
          resetsOnTransfer: _resetsOnTransfer[i],
          coreEvolves: _coreEvolves[i],
          allowTimezoneSet: _allowTimezoneSet[i],
          allowHemisphereSet: _allowHemisphereSet[i],
          exists: true
        });
        uint256 _tokenId = nftContract.cardLevels(_cardId[i], 0).tokenId;
        if (_tokenId != 0) {
          tokenVars[_tokenId] = EvolvingTokenVars({
            cardId: uint128(_cardId[i]),
            initTime: uint32(_coreEvolves[i] ? _initTime[i] : 0),
            lastState: 0,
            evolves: _coreEvolves[i],
            isGrouped: true,
            exists: true
          });
        }
      }
  }

    
  function onMinted(address _to, uint256 _tokenId, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number, uint256[] memory _data) 
    external override onlyEditor {


      if (tokenVars[_tokenId].exists || !cards[_cardId].exists) {
        return;
      }

      CardVars memory _card = cards[_cardId];

      uint256 _startTime = _card.initTime;

      if (_startTime == 0) {
        _startTime = block.timestamp;
      } else {
        if (_card.allowTimezoneSet) {
          uint256 offset = _data.length > 0 ? _data[0] : 0;
          require (offset < 24 * 60 * 60, 'offset too big');
          _startTime -= offset;
        }

        if (_card.allowHemisphereSet) {
          if (_data.length > 1 && _data[1] == 1) {
            _startTime -= 183 * 24 * 60 * 60;
          }
        }
      }

      tokenVars[_tokenId] = EvolvingTokenVars({
        cardId: uint128(_cardId),
        initTime: uint32(_startTime),
        lastState: 0,
        evolves: _cardLevel > 0 || _card.coreEvolves,
        isGrouped: false,
        exists: true
      });
  }

  function onTransfered(address from, address to, uint256 id, uint256 amount, bytes memory data) external override onlyEditor {

      if (!tokenVars[id].exists) {
        return;
      }
      if (cards[tokenVars[id].cardId].resetsOnTransfer && !tokenVars[id].isGrouped) {
        tokenVars[id].lastState = uint32(getState(id, 0));
        tokenVars[id].initTime = uint32(block.timestamp);
      }
  }
  
  function onMerged(uint256 _newTokenId, uint256[] memory _tokenId, address _nftContractAddress, uint256[] memory data) 
    external override {

  }

  function getState(uint256 _tokenId, uint256 _timeStamp) public view returns (uint256) {


    if (_timeStamp == 0) {
      _timeStamp = block.timestamp;
    }

    EvolvingTokenVars memory _tokenVars =  tokenVars[_tokenId];

    if (!_tokenVars.evolves) {
      return 0;
    }

    CardVars memory _cardVars = cards[_tokenVars.cardId];

    uint256 _timeSinceStart = _timeStamp - _tokenVars.initTime;
    uint256 _state = _timeSinceStart / _cardVars.timePeriod;

    if (_state >= _cardVars.numStates) {
      if (_cardVars.repeats) {
        _state = _state % _cardVars.numStates;
      } else {
        _state = _cardVars.numStates - 1;
      }
    }

    return _state;
  }

  function uri(uint256 id) external view override returns (string memory) {

    IRainiNft1155.TokenVars memory _tokenVars = nftContract.tokenVars(id);
    require(_tokenVars.cardId != 0, "No token for given ID");

    return string(abi.encodePacked(baseUri, nftContract.cardPathUri(_tokenVars.cardId), "/", _tokenVars.mintedContractChar, "l", Strings.toString(_tokenVars.level), "n", Strings.toString(_tokenVars.number), "s", Strings.toString(getState(id, 0)), ".json"));
  }

  function getTokenState(uint256 id) public view override returns (bytes memory) {

    return abi.encode(tokenVars[id]);
  }

  function setTokenStates(uint256[] memory id, bytes[] memory state) external override onlyEditor {

    for (uint256 i; i < id.length; i++) {
      (tokenVars[id[i]]) = abi.decode(state[i], (EvolvingTokenVars));
    }
  }

  function setTokenStates(uint256[] memory id, uint128[] memory cardId, uint32[] memory initTime, uint32[] memory lastState, bool[] memory evolves, bool[] memory isGrouped, bool[] memory exists)
       external onlyOwner {

    for (uint256 i; i < id.length; i++) {
      tokenVars[id[i]] = EvolvingTokenVars(
        cardId[i],
        initTime[i],
        lastState[i],
        evolves[i],
        isGrouped[i],
        exists[i]
      );
    }
  }
}