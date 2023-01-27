
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

  
  struct TokenVars {
    uint128 cardId;
    uint32 level;
    uint32 number; // to assign a numbering to NFTs
    bytes1 mintedContractChar;
  }

  function tokenVars(uint256 _tokenId) external view returns (TokenVars memory);

}


contract RainiChildContractv1 is AccessControl, IRainiCustomNFT {


  IRainiNft1155 nftContract;

  bytes32 public constant EDITOR_ROLE = keccak256("EDITOR_ROLE");

  string public baseUri;

  mapping(uint256 => string) public pathUris;
  mapping(uint256 => bool) public ownerCanEdit;

  mapping(uint256 => uint32[]) public tokenData;

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

  function initCards(uint256[] memory _cardId, string[] memory _pathUri, bool[] memory _ownerCanEdit) 
    external onlyOwner {

      for (uint256 i; i < _cardId.length; i++) {
        pathUris[_cardId[i]] = _pathUri[i];
        ownerCanEdit[_cardId[i]] = _ownerCanEdit[i];
      }
  }

  function setBaseURI(string memory _baseURIString)
    external onlyOwner {

      baseUri = _baseURIString;
  }

    
  function onMinted(address _to, uint256 _tokenId, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number, uint256[] memory _data) 
    external override onlyEditor {

      if (_data.length > 0) {
        IRainiNft1155.TokenVars memory _tokenVars = nftContract.tokenVars(_tokenId);

        if (_tokenVars.number > 0) {
          uint32[] memory _temp = new uint32[](_data.length);
          for (uint256 i; i < _temp.length; i++) {
            _temp[i] = uint32(_data[i]);
          }
          tokenData[_tokenId] = _temp;
        }
      }
  }

  function onTransfered(address from, address to, uint256 id, uint256 amount, bytes memory data) external override {

  }
  
  function onMerged(uint256 _newTokenId, uint256[] memory _tokenId, address _nftContractAddress, uint256[] memory data) 
    external override {

  }

  function getTokenState(uint256 id) public view override returns (bytes memory) {

    return abi.encode(tokenData[id]);
  }

  function setTokenStates(uint256[] memory id, bytes[] memory state) external override onlyEditor {

    bool isEditor = hasRole(EDITOR_ROLE, _msgSender());

    for (uint256 i; i < id.length; i++) {

      if (!isEditor) {
        IRainiNft1155.TokenVars memory _tokenVars = nftContract.tokenVars(id[i]);
        require(_tokenVars.number > 0 && ownerCanEdit[_tokenVars.cardId] && nftContract.balanceOf(_msgSender(), id[i]) == 1, "can't edit");
      }

      (tokenData[id[i]]) = abi.decode(state[i], (uint32[]));
    }
  }

  function uri(uint256 id) external override view returns (string memory) {

    
    IRainiNft1155.TokenVars memory _tokenVars = nftContract.tokenVars(id);

    string memory query;

    for (uint256 i; i < tokenData[id].length; i++) {
      query = string(abi.encodePacked(query, "&p", Strings.toString(i), "=", Strings.toString(tokenData[id][i]), ""));
    }

    return string(abi.encodePacked(baseUri, pathUris[_tokenVars.cardId], "?c=", _tokenVars.mintedContractChar, "&l=", Strings.toString(_tokenVars.level), "&n=", Strings.toString(_tokenVars.number), query));
  }
}