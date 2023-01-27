
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

abstract contract IRainiCard is IERC1155 {
  struct TokenVars {
    uint128 cardId;
    uint32 level;
    uint32 number;
    bytes1 mintedContractChar;
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
  
  mapping(uint256 => TokenVars) public tokenVars;
  
  mapping(uint256 => Card) public cards;

  uint256 public maxTokenId;

  function mint(address _to, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number, uint256[] memory _data) virtual external;

  function mint(address _to, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number) virtual external;

  function getTotalBalance(address _address) virtual external view returns (uint256[][] memory amounts);

  function getTotalBalance(address _address, uint256 _cardCount) virtual external view returns (uint256[][] memory amounts);

  function burn(address _owner, uint256 _tokenId, uint256 _amount) virtual external;
}// MIT

pragma solidity ^0.8.3;

interface IRainiCustomNFT {

    function onTransfered(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;


    function onMerged(
        uint256 _newTokenId,
        uint256[] memory _tokenId,
        address _nftContractAddress,
        uint256[] memory data
    ) external;


    function onMinted(
        address _to,
        uint256 _tokenId,
        uint256 _cardId,
        uint256 _cardLevel,
        uint256 _amount,
        bytes1 _mintedContractChar,
        uint256 _number,
        uint256[] memory _data
    ) external;


    function setTokenStates(uint256[] memory id, bytes[] memory state) external;


    function getTokenState(uint256 id) external view returns (bytes memory);


    function uri(uint256 id) external view returns (string memory);

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

    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view virtual {
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

    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
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
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.3;


interface INftStakingPool {

  function getTokenStaminaTotal(uint256 _tokenId, address _nftContractAddress) external view returns (uint32 stamina);

  function setTokenStaminaTotal(uint32 _stamina, uint256 _tokenId, address _nftContractAddress) external;

}

interface INftBridgePool {

  function withdrawNft(uint256 _contractId, address _recipient, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number, uint256 _requestsId, uint32 _stamina, bytes calldata _state) external;

  function bulkWithdrawNfts(uint232[] memory _contractId, address[] memory _recipient, uint256[] memory _cardId, uint256[] memory _cardLevel, uint256[] memory _amount, bytes1[] memory _mintedContractChar, uint256[] memory _number, uint256[] memory _requestsId, uint32[] memory _stamina, bytes[] calldata _state) external;

  function findHeldToken(uint256 _contractId, uint256 _cardId, uint256 _cardLevel, bytes1 _mintedContractChar, uint256 _number) external view returns (uint256);

}

contract SecondaryNftBridgePool is IERC721Receiver, IERC1155Receiver, AccessControl, ReentrancyGuard {

  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  event CardsDeposited(
    uint256 nftContractId,
    address indexed spender,
    address recipient,
    uint256 amount,
    uint256 requestId,
    uint128 cardId,
    uint32 level,
    uint32 number,
    uint32 stamina,
    bytes1 mintedContractChar,
    bytes state
  );

  event EthWithdrawn(uint256 amount);
  event AutoWithdrawFeeSet(bool autoWithdraw);
  event ConfigSet(address cardToken, address nftV1Token, address nftV2Token);
  event TreasuryAddressSet(address treasuryAddress);
  event FeesSet(uint256 card, uint256 nftV1, uint256 nftV2);
  event ItemFeeSet(uint256 card, uint256 nftV1, uint256 nftV2);

  event CardsWithdrawn(uint256 nftContractId, address indexed owner, uint256 requestId, uint256 cardId, uint256 amount);

  mapping(uint256 => address) public nftContracts;
  mapping(uint256 => bool) public hasSubcontracts;

  mapping(uint256 => mapping(uint256 => bool)) public cardDisabled;

  mapping(uint256 => mapping(uint256 => mapping(uint256 => mapping(bytes1 => mapping(uint256 => uint256))))) public heldTokens;

  uint256 public baseFee;
  uint256 public stateUpdateFee;
  uint256 public staminaUpdateFee;
  uint256 public gasPrice;
  mapping(uint256 => uint256) public itemFee;

  uint256 private requestId = 1000000000000;
  bool    private autoWithdrawFee;
  address private treasuryAddress;

  address public nftStakingPoolAddress;

  mapping(uint256 => bool) public requestWithdrawn;

  INftBridgePool public mainNftBridge;



  constructor(address _mainNftBridgeAddress) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(MINTER_ROLE, _msgSender());
    mainNftBridge = INftBridgePool(_mainNftBridgeAddress);
  }

  modifier onlyMinter() {

    require(hasRole(MINTER_ROLE, _msgSender()), "SNBP: not a minter");
    _;
  }

  modifier onlyOwner() {

    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "SNBP: not an owner");
    _;
  }

  function setFees(uint256  _baseFee, uint256 _stateUpdateFee, uint256 _staminaUpdateFee, uint256[] calldata _contractId, uint256[] calldata  _itemFee)
    external onlyOwner {

      baseFee = _baseFee;
      stateUpdateFee = _stateUpdateFee;
      staminaUpdateFee = _staminaUpdateFee;

      for (uint256 i; i < _contractId.length; i++) {
        itemFee[_contractId[i]] = _itemFee[i];
      }
  }

  function setGasPrice(uint256 _gasPrice) 
      external {

        require(hasRole(MINTER_ROLE, _msgSender()) || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'no access');
        gasPrice = _gasPrice;
  }

  function setContracts(uint256[] calldata _contractId, address[] calldata _contractAddress, bool[] calldata _hasSubcontracts)
    external onlyOwner {

      for (uint256 i; i < _contractId.length; i++) {
        nftContracts[_contractId[i]] = _contractAddress[i];
        hasSubcontracts[_contractId[i]] = _hasSubcontracts[i];
      }
  }

  function setDisabledCards(uint256[] calldata _contractId, uint256[] calldata _ids, bool[] calldata _disabled) 
    external onlyOwner {

      for (uint256 i; i < _ids.length; i++) {
        cardDisabled[_contractId[i]][_ids[i]] = _disabled[i];
      }
  }

  function setAutoWithdrawFee(bool _autoWithdrawFee)
    external onlyOwner {

      autoWithdrawFee = _autoWithdrawFee;
      emit AutoWithdrawFeeSet(autoWithdrawFee);
  }

  function setTreasuryAddress(address _treasuryAddress)
    external onlyOwner {

      treasuryAddress = _treasuryAddress;
      emit TreasuryAddressSet(_treasuryAddress);
  }

  function setNftStakingPoolAddress(address _nftStakingPoolAddress)
    external onlyOwner {

      nftStakingPoolAddress = (_nftStakingPoolAddress);
  }

  function getSubContractTokenState(address _token, uint256 _cardId, uint256 _tokenId) 
    internal view returns(bytes memory) {

      (,,,,,,,address subContract) = IRainiCard(_token).cards(_cardId);
          
      if (subContract != address(0)) {
        return IRainiCustomNFT(subContract).getTokenState(_tokenId);
      }

      return '';
  }

  function handleFeesWithdraw(uint256 _fee, uint256 _refund) internal {

    if (_refund > 0) {
      (bool refundSuccess, ) = _msgSender().call{ value: _refund }("");
      require(refundSuccess, "SNBP: refund transfer failed");
    }

    if (autoWithdrawFee) {
      (bool withdrawSuccess, ) = treasuryAddress.call{ value: _fee }("");
      require(withdrawSuccess, "SNBP: withdraw transfer failed");
    }
  }

  function updateSubContractState(address _token, uint256 _cardId, uint256 _tokenId, bytes calldata state) internal {

    if (state.length == 0) return;

    (,,,,,,,address subContract) = IRainiCard(_token).cards(_cardId);
    uint256[] memory ids = new uint256[](1);
    bytes[] memory states = new bytes[](1);
    ids[0] = _tokenId;
    states[0] = state;
    
    if (subContract != address(0)) {
      IRainiCustomNFT(subContract).setTokenStates(ids, states);
    }
  }

  function updateStamina(address _token, uint256 _tokenId, uint32 _stamina) internal {

    if (_stamina == 0 || nftStakingPoolAddress == address(0)) return;

    INftStakingPool(nftStakingPoolAddress).setTokenStaminaTotal(_stamina, _tokenId, _token);
  }

  struct DepositVars {
    uint256 fee;
    uint256 requestId;
  }

  function deposit(address _recipient, uint256[] calldata _contractId, uint256[] calldata _tokenIds, uint256[] calldata _amounts) 
    external payable nonReentrant {

      require(_tokenIds.length == _amounts.length, "SNBP: input arrays not equal");

      DepositVars memory _locals =  DepositVars(
        baseFee,
        requestId
      );

      for (uint256 i; i < _tokenIds.length; i++) {
        IRainiCard nftContract = IRainiCard(nftContracts[_contractId[i]]);
        IRainiCard.TokenVars memory tokenVars = IRainiCard.TokenVars(0,0,0,0);
        (tokenVars.cardId, tokenVars.level, tokenVars.number, tokenVars.mintedContractChar) = nftContract.tokenVars(_tokenIds[i]);
        require(!cardDisabled[_contractId[i]][tokenVars.cardId], "SNBP: bridging this card disabled");
        nftContract.safeTransferFrom(_msgSender(), address(this), _tokenIds[i], _amounts[i], "");
        _setHeldToken(_tokenIds[i], _contractId[i], tokenVars.cardId, tokenVars.level, tokenVars.mintedContractChar, tokenVars.number);
        _locals.requestId++;

        _locals.fee += itemFee[_contractId[i]];

        bytes memory state = "";
        if (tokenVars.number > 0 && hasSubcontracts[_contractId[i]]) {
          state = getSubContractTokenState(address(nftContract), tokenVars.cardId, _tokenIds[i]);
          if (state.length > 0) {
            _locals.fee += stateUpdateFee;
          }
        }

        uint32 stamina = 0;
        if (nftStakingPoolAddress != address(0)) {
          stamina = INftStakingPool(nftStakingPoolAddress).getTokenStaminaTotal(_tokenIds[i], address(nftContract));
          if (stamina != 0) {
            _locals.fee += staminaUpdateFee;
          }
        }

        emit CardsDeposited(
          _contractId[i],
          _msgSender(),
          _recipient,
          _amounts[i],
          _locals.requestId,
          tokenVars.cardId,
          tokenVars.level,
          tokenVars.number,
          stamina,
          tokenVars.mintedContractChar,
          state
        );
      }

      _locals.fee *= gasPrice;
 
      require(msg.value >= _locals.fee, "SNBP: not enough funds");
      handleFeesWithdraw(_locals.fee, msg.value - _locals.fee);

      requestId = _locals.requestId;
  }

  function getDepositFee(address _recipient, uint256[] calldata _contractId, uint256[] calldata _tokenIds, uint256[] calldata _amounts) 
    public view returns (uint256 fee) {

      require(_tokenIds.length == _amounts.length, "SNBP: input arrays not equal");

      DepositVars memory _locals =  DepositVars(
        baseFee,
        requestId
      );

      for (uint256 i; i < _tokenIds.length; i++) {
        IRainiCard nftContract = IRainiCard(nftContracts[_contractId[i]]);
        IRainiCard.TokenVars memory tokenVars = IRainiCard.TokenVars(0,0,0,0);
        (tokenVars.cardId, tokenVars.level, tokenVars.number, tokenVars.mintedContractChar) = nftContract.tokenVars(_tokenIds[i]);
        require(!cardDisabled[_contractId[i]][tokenVars.cardId], "SNBP: bridging this card disabled");

        _locals.fee += itemFee[_contractId[i]];

        bytes memory state = "";
        if (tokenVars.number > 0 && hasSubcontracts[_contractId[i]]) {
          state = getSubContractTokenState(address(nftContract), tokenVars.cardId, _tokenIds[i]);
          if (state.length > 0) {
            _locals.fee += stateUpdateFee;
          }
        }

        uint32 stamina = 0;
        if (nftStakingPoolAddress != address(0)) {
          INftStakingPool(nftStakingPoolAddress).getTokenStaminaTotal(_tokenIds[i], address(nftContract));
          if (stamina != 0) {
            _locals.fee += staminaUpdateFee;
          }
        }
      }

      _locals.fee *= gasPrice;
      return _locals.fee;
  }

  function _setHeldToken(uint256 tokenId, uint256 _contractId, uint256 _cardId, uint256 _cardLevel, bytes1 _mintedContractChar, uint256 _number) internal {

    if (_number == 0) {
      _mintedContractChar = bytes1(0);
    }
    if (heldTokens[_contractId][_cardId][_cardLevel][_mintedContractChar][_number] != tokenId) {
      heldTokens[_contractId][_cardId][_cardLevel][_mintedContractChar][_number] = tokenId;
    }
  }

  function setHeldToken(uint256 tokenId, uint256 _contractId, uint256 _cardId, uint256 _cardLevel, bytes1 _mintedContractChar, uint256 _number) external onlyMinter {

    _setHeldToken(tokenId, _contractId, _cardId, _cardLevel, _mintedContractChar, _number);
  }

  function findHeldToken(uint256 _contractId, uint256 _cardId, uint256 _cardLevel, bytes1 _mintedContractChar, uint256 _number) public view returns (uint256) {

    if (_number == 0) {
      _mintedContractChar = bytes1(0);
    }
    return heldTokens[_contractId][_cardId][_cardLevel][_mintedContractChar][_number];
  }

  struct WithdrawNftVars {
    uint256 tokenId;
    uint256 amount;
    uint256 leftAmount;
  }

  function withdrawNft(uint256 _contractId, address _recipient, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number, uint256 _requestsId, uint32 _stamina, bytes calldata _state) 
    public onlyMinter {


      if (requestWithdrawn[_requestsId]) {
        return;
      }

      requestWithdrawn[_requestsId] = true;

      WithdrawNftVars memory _locals = WithdrawNftVars(0, 0, 0);

      IRainiCard nftContract = IRainiCard(nftContracts[_contractId]);

      _locals.tokenId = findHeldToken(_contractId, _cardId, _cardLevel, _mintedContractChar, _number);
      _locals.amount = 0;
      if (_locals.tokenId > 0) {
        _locals.amount = nftContract.balanceOf(address(this), _locals.tokenId);
      }
      
      _locals.leftAmount = _amount;

      if (_locals.amount > 0) {
        if (_locals.amount > _amount) {
          _locals.leftAmount = 0;
          nftContract.safeTransferFrom(address(this), _recipient, _locals.tokenId, _amount, bytes(''));
        } else {
          _locals.leftAmount -= _locals.amount;
          nftContract.safeTransferFrom(address(this), _recipient, _locals.tokenId, _locals.amount, bytes(''));
          _setHeldToken(0, _contractId, _cardId, _cardLevel, _mintedContractChar, _number);
        }
        
        updateStamina(address(nftContract), _locals.tokenId, _stamina);
        updateSubContractState(address(nftContract), _cardId, _locals.tokenId, _state);
      } 

      if (_locals.leftAmount > 0) {
        if (hasSubcontracts[_contractId]) {
          nftContract.mint(_recipient, _cardId, _cardLevel, _locals.leftAmount, _mintedContractChar, _number, new uint256[](0));
          updateSubContractState(address(nftContract), _cardId, nftContract.maxTokenId(), _state);
        } else {
          nftContract.mint(_recipient, _cardId, _cardLevel, _locals.leftAmount, _mintedContractChar, _number);
        }
        updateStamina(address(nftContract), nftContract.maxTokenId(), _stamina);
      }

      emit CardsWithdrawn(_contractId, _recipient, _requestsId, _cardId, _amount);
  }

  struct BulkWithdrawNftsVars {
    uint256 tokenId;
    uint256 mainBridgeCount;
  }

  function bulkWithdrawNfts(uint232[] memory _contractId, address[] memory _recipient, uint256[] memory _cardId, uint256[] memory _cardLevel, uint256[] memory _amount, bytes1[] memory _mintedContractChar, uint256[] memory _number, uint256[] memory _requestsId, uint32[] memory _stamina, bytes[] calldata _state) 
    external onlyMinter {

      BulkWithdrawNftsVars memory _locals = BulkWithdrawNftsVars(0, 0);
      
      for (uint256 i; i < _contractId.length; i++) {
        _locals.tokenId = mainNftBridge.findHeldToken(_contractId[i], _cardId[i], _cardLevel[i], _mintedContractChar[i], _number[i]);
        if (_locals.tokenId > 0) {
          IRainiCard nftContract = IRainiCard(nftContracts[_contractId[i]]);
          _locals.mainBridgeCount = nftContract.balanceOf(address(mainNftBridge), _locals.tokenId);
        }
        if (_locals.mainBridgeCount > 0) {
          if (_amount[i] < _locals.mainBridgeCount) {
            _locals.mainBridgeCount = _amount[i];
          }
          mainNftBridge.withdrawNft(_contractId[i], _recipient[i], _cardId[i], _cardLevel[i], _locals.mainBridgeCount, _mintedContractChar[i], _number[i], _requestsId[i], _stamina[i], _state[i]);
        }
        if (_amount[i] > _locals.mainBridgeCount) {
          withdrawNft(_contractId[i], _recipient[i], _cardId[i], _cardLevel[i], _amount[i] - _locals.mainBridgeCount, _mintedContractChar[i], _number[i], _requestsId[i], _stamina[i], _state[i]);
        }

        if (!requestWithdrawn[_requestsId[i]]) {
          requestWithdrawn[_requestsId[i]] = true;
        }
      }
  }

  function withdrawEth(uint256 _amount)
    external onlyOwner {

      require(_amount <= address(this).balance, "SNBP: not enough balance");
      
      (bool success, ) = _msgSender().call{ value: _amount }("");
      require(success, "SNBP: transfer failed");

      emit EthWithdrawn(_amount);
  }

  function onERC721Received(address, address, uint256, bytes memory) 
    public virtual override returns (bytes4) {

      return this.onERC721Received.selector;
  }

  function onERC1155Received(address, address, uint256, uint256, bytes calldata)
    public virtual override returns (bytes4) {

      return this.onERC1155Received.selector;
  }

  function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
    public virtual override returns (bytes4) {

      return this.onERC1155BatchReceived.selector;
  }
}