
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

pragma solidity ^0.8.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// MIT

pragma solidity ^0.8.1;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155 is Context, ERC165, IERC1155, IERC1155MetadataURI {

    using Address for address;

    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    string private _uri;

    constructor(string memory uri_) {
        _setURI(uri_);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {

        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function uri(uint256) public view virtual override returns (string memory) {

        return _uri;
    }

    function balanceOf(address account, uint256 id) public view virtual override returns (uint256) {

        require(account != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][account];
    }

    function balanceOfBatch(address[] memory accounts, uint256[] memory ids)
        public
        view
        virtual
        override
        returns (uint256[] memory)
    {

        require(accounts.length == ids.length, "ERC1155: accounts and ids length mismatch");

        uint256[] memory batchBalances = new uint256[](accounts.length);

        for (uint256 i = 0; i < accounts.length; ++i) {
            batchBalances[i] = balanceOf(accounts[i], ids[i]);
        }

        return batchBalances;
    }

    function setApprovalForAll(address operator, bool approved) public virtual override {

        _setApprovalForAll(_msgSender(), operator, approved);
    }

    function isApprovedForAll(address account, address operator) public view virtual override returns (bool) {

        return _operatorApprovals[account][operator];
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: caller is not owner nor approved"
        );
        _safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public virtual override {

        require(
            from == _msgSender() || isApprovedForAll(from, _msgSender()),
            "ERC1155: transfer caller is not owner nor approved"
        );
        _safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    function _safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, _asSingletonArray(id), _asSingletonArray(amount), data);

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }
        _balances[id][to] += amount;

        emit TransferSingle(operator, from, to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, from, to, id, amount, data);
    }

    function _safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");
        require(to != address(0), "ERC1155: transfer to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; ++i) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: insufficient balance for transfer");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
            _balances[id][to] += amount;
        }

        emit TransferBatch(operator, from, to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, from, to, ids, amounts, data);
    }

    function _setURI(string memory newuri) internal virtual {

        _uri = newuri;
    }

    function _mint(
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, _asSingletonArray(id), _asSingletonArray(amount), data);

        _balances[id][to] += amount;
        emit TransferSingle(operator, address(0), to, id, amount);

        _doSafeTransferAcceptanceCheck(operator, address(0), to, id, amount, data);
    }

    function _mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {

        require(to != address(0), "ERC1155: mint to the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, address(0), to, ids, amounts, data);

        for (uint256 i = 0; i < ids.length; i++) {
            _balances[ids[i]][to] += amounts[i];
        }

        emit TransferBatch(operator, address(0), to, ids, amounts);

        _doSafeBatchTransferAcceptanceCheck(operator, address(0), to, ids, amounts, data);
    }

    function _burn(
        address from,
        uint256 id,
        uint256 amount
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), _asSingletonArray(id), _asSingletonArray(amount), "");

        uint256 fromBalance = _balances[id][from];
        require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
        unchecked {
            _balances[id][from] = fromBalance - amount;
        }

        emit TransferSingle(operator, from, address(0), id, amount);
    }

    function _burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) internal virtual {

        require(from != address(0), "ERC1155: burn from the zero address");
        require(ids.length == amounts.length, "ERC1155: ids and amounts length mismatch");

        address operator = _msgSender();

        _beforeTokenTransfer(operator, from, address(0), ids, amounts, "");

        for (uint256 i = 0; i < ids.length; i++) {
            uint256 id = ids[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][from];
            require(fromBalance >= amount, "ERC1155: burn amount exceeds balance");
            unchecked {
                _balances[id][from] = fromBalance - amount;
            }
        }

        emit TransferBatch(operator, from, address(0), ids, amounts);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {

        require(owner != operator, "ERC1155: setting approval status for self");
        _operatorApprovals[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual {}


    function _doSafeTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155Received(operator, from, id, amount, data) returns (bytes4 response) {
                if (response != IERC1155Receiver.onERC1155Received.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _doSafeBatchTransferAcceptanceCheck(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) private {

        if (to.isContract()) {
            try IERC1155Receiver(to).onERC1155BatchReceived(operator, from, ids, amounts, data) returns (
                bytes4 response
            ) {
                if (response != IERC1155Receiver.onERC1155BatchReceived.selector) {
                    revert("ERC1155: ERC1155Receiver rejected tokens");
                }
            } catch Error(string memory reason) {
                revert(reason);
            } catch {
                revert("ERC1155: transfer to non ERC1155Receiver implementer");
            }
        }
    }

    function _asSingletonArray(uint256 element) private pure returns (uint256[] memory) {

        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
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

pragma solidity ^0.8.3;


interface IStakingPool {

  function balanceOf(address _owner) external view returns (uint256 balance);

  function burn(address _owner, uint256 _amount) external;

}

interface INftStakingPool {

  function getTokenStamina(uint256 _tokenId, address _nftContractAddress) external view returns (uint256 stamina);

  function mergeTokens(uint256 _newTokenId, uint256[] memory _tokenIds, address _nftContractAddress) external;

}

interface IRainiCustomNFT {

  function onTransfered(address from, address to, uint256 id, uint256 amount, bytes memory data) external;

  function onMerged(uint256 _newTokenId, uint256[] memory _tokenId, address _nftContractAddress, uint256[] memory data) external;

  function onMinted(address _to, uint256 _tokenId, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number, uint256[] memory _data) external;

  function uri(uint256 id) external view returns (string memory);

}

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

  function maxTokenId() external view returns (uint256);

  function contractChar() external view returns (bytes1);


  function numberMintedByAddress(address _address, uint256 _cardID) external view returns (uint256);


  function burn(address _owner, uint256 _tokenId, uint256 _amount, bool _isBridged) external;


  function getPathUri(uint256 _cardId) view external returns (string memory);


  function cards(uint256 _cardId) external view returns (Card memory);

  function cardLevels(uint256 _cardId, uint256 _level) external view returns (CardLevel memory);

  function tokenVars(uint256 _tokenId) external view returns (TokenVars memory);


  function mint(address _to, uint256 _cardId, uint256 _cardLevel, uint256 _amount, bytes1 _mintedContractChar, uint256 _number, uint256[] memory _data) external;

  function addToNumberMintedByAddress(address _address, uint256 _cardId, uint256 amount) external;

}

contract RainiNft1155Functions is AccessControl, ReentrancyGuard {


  address public nftStakingPoolAddress;

  uint256 public constant POINT_COST_DECIMALS = 1000000000000000000;

  uint256 public rainbowToEth;
  uint256 public unicornToEth;
  uint256 public minPointsPercentToMint;

  mapping(address => bool) public rainbowPools;
  mapping(address => bool) public unicornPools;
  mapping(uint256 => uint256) public mergeFees;

  mapping(uint256 => uint256) public startTimeOverrides;

  uint256 public mintingFeeBasisPointsUnicorns;
  uint256 public mintingFeeBasisPointsRainbows;

  mapping(uint256 => uint256) public maxMintsOverrides;


  IRainiNft1155 nftContract;

  constructor(address _nftContractAddress, address _contractOwner) {
    _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
    _setupRole(DEFAULT_ADMIN_ROLE, _contractOwner);
    nftContract = IRainiNft1155(_nftContractAddress);
  }

  modifier onlyOwner() {

    require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()));
    _;
  }

  function addRainbowPool(address _rainbowPool) 
    external onlyOwner {

      rainbowPools[_rainbowPool] = true;
  }

  function removeRainbowPool(address _rainbowPool) 
    external onlyOwner {

      rainbowPools[_rainbowPool] = false;
  }

  function addUnicornPool(address _unicornPool) 
    external onlyOwner {

      unicornPools[_unicornPool] = true;
  }

  function removeUnicornPool(address _unicornPool) 
    external onlyOwner {

      unicornPools[_unicornPool] = false;
  }

  function setEtherValues(uint256 _unicornToEth, uint256 _rainbowToEth, uint256 _minPointsPercentToMint)
     external onlyOwner {

      unicornToEth = _unicornToEth;
      rainbowToEth = _rainbowToEth;
      minPointsPercentToMint = _minPointsPercentToMint;
   }

  function setFees(uint256 _mintingFeeBasisPointsRainbows, uint256 _mintingFeeBasisPointsUnicorns, uint256[] memory _mergeFees) 
    external onlyOwner {

      mintingFeeBasisPointsRainbows =_mintingFeeBasisPointsRainbows;
      mintingFeeBasisPointsUnicorns =_mintingFeeBasisPointsUnicorns;
      for (uint256 i = 1; i < _mergeFees.length; i++) {
        mergeFees[i] = _mergeFees[i];
      }
  }

  function setNftStakingPoolAddress(address _nftStakingPoolAddress)
    external onlyOwner {

      nftStakingPoolAddress = (_nftStakingPoolAddress);
  }

  function setTimeStartOverrides(uint256[] memory _cardId, uint256[] memory _newStartTime) 
    external onlyOwner {

      for (uint256 i = 0; i < _cardId.length; i++) {
        startTimeOverrides[_cardId[i]] = _newStartTime[i];
      }
  }

  function setMaxMintsOverrides(uint256[] memory _cardId, uint256[] memory _newMaxMints) 
    external onlyOwner {

      for (uint256 i = 0; i < _cardId.length; i++) {
        maxMintsOverrides[_cardId[i]] = _newMaxMints[i];
      }
  }

  struct MergeData {
    uint256 cost;
    uint256 totalPointsBurned;
    uint256 currentTokenToMint;
    bool willCallPool;
    bool willCallSubContract;
  }

  function merge(uint256 _cardId, uint256 _level, uint256 _mintAmount, uint256[] memory _tokenIds, uint256[] memory _burnAmounts, uint256[] memory _data) 
    external payable nonReentrant {

      IRainiNft1155.CardLevel memory _cardLevel = nftContract.cardLevels(_cardId, _level);

      require(_level > 0 && _cardLevel.conversionRate > 0, "merge not allowed");

      MergeData memory _locals = MergeData({
        cost: 0,
        totalPointsBurned: 0,
        currentTokenToMint: 0,
        willCallPool: false,
        willCallSubContract: false
      });


      _locals.cost = _cardLevel.conversionRate * _mintAmount;

      uint256[] memory mergedTokensIds;
      INftStakingPool nftStakingPool;
      IRainiCustomNFT subContract;

      _locals.willCallPool = nftStakingPoolAddress != address(0) && _level > 0 && nftContract.cardLevels(_cardId, _level-1).tokenId == 0;
      _locals.willCallSubContract = _cardLevel.tokenId == 0 && nftContract.cards(_cardId).subContract != address(0);
      if (_locals.willCallPool || _locals.willCallSubContract) {
        mergedTokensIds = new uint256[](_tokenIds.length);
        if (_locals.willCallPool) {
          nftStakingPool = INftStakingPool(nftStakingPoolAddress);
        }
        if (_locals.willCallSubContract) {
          subContract = IRainiCustomNFT(nftContract.cards(_cardId).subContract);
        }
      }

      for (uint256 i = 0; i < _tokenIds.length; i++) {
        require(_burnAmounts[i] <= nftContract.balanceOf(_msgSender(), _tokenIds[i]), 'not enough balance');
        IRainiNft1155.TokenVars memory _tempTokenVars =  nftContract.tokenVars(_tokenIds[i]);
        require(_tempTokenVars.cardId == _cardId, "card mismatch");
        require(_tempTokenVars.level < _level, "can only merge into higher levels");
        IRainiNft1155.CardLevel memory _tempCardLevel = nftContract.cardLevels(_tempTokenVars.cardId, _tempTokenVars.level);
        if (_tempTokenVars.level == 0) {
          _locals.totalPointsBurned += _burnAmounts[i];
        } else {
          _locals.totalPointsBurned += _burnAmounts[i] * _tempCardLevel.conversionRate;
        }
        nftContract.burn(_msgSender(), _tokenIds[i], _burnAmounts[i], false);

        if (_locals.willCallPool || _locals.willCallSubContract) {
          mergedTokensIds[i] = _tokenIds[i];
          if (_locals.totalPointsBurned > (_locals.currentTokenToMint + 1) * _cardLevel.conversionRate || i == _tokenIds.length - 1) {
            _locals.currentTokenToMint++;
            if (_locals.willCallPool) {
              nftStakingPool.mergeTokens(_locals.currentTokenToMint + nftContract.maxTokenId(), mergedTokensIds, address(nftContract));
            }
            if (_locals.willCallSubContract) {
              subContract.onMerged(_locals.currentTokenToMint + nftContract.maxTokenId(), mergedTokensIds, address(nftContract), _data);
            }
            if (_locals.currentTokenToMint < _mintAmount) {
              mergedTokensIds = new uint256[](_cardLevel.conversionRate);
            }
          }
        }
      }

      require(_locals.totalPointsBurned == _locals.cost, "wrong no tkns burned");

      require(mergeFees[_level] * _mintAmount <= msg.value, "Not enough ETH");

      (bool success, ) = _msgSender().call{ value: msg.value - mergeFees[_level] * _mintAmount}(""); // refund excess Eth
      require(success, "transfer failed");

      nftContract.mint(_msgSender(), _cardId, _level, _mintAmount, nftContract.contractChar(), 0, _data);
  }

  struct MintWithPointsData {
    uint256 totalPriceRainbows;
    uint256 totalPriceUnicorns;
    uint256 fee;
    uint256 amountEthToWithdraw;
    bool success;
  }
  
  function mintWithPoints(uint256[] memory _cardId, uint256[] memory _amount, bool[] memory _useUnicorns, uint256[][] memory _data, address[] memory _rainbowPools, address[] memory _unicornPools)
    external payable nonReentrant {


    MintWithPointsData memory _locals = MintWithPointsData({
      totalPriceRainbows: 0,
      totalPriceUnicorns: 0,
      fee: 0,
      amountEthToWithdraw: 0,
      success: false
    });

    for (uint256 i = 0; i < _cardId.length; i++) {
      IRainiNft1155.Card memory card =  nftContract.cards(_cardId[i]);
      IRainiNft1155.CardLevel memory cardLevel =  nftContract.cardLevels(_cardId[i], 0);

      require(block.timestamp >= ((startTimeOverrides[_cardId[i]] > 0) ? startTimeOverrides[_cardId[i]] : card.mintTimeStart)
               || hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'too early');
      require(nftContract.numberMintedByAddress(_msgSender(), _cardId[i]) + _amount[i]  
                <= ((maxMintsOverrides[_cardId[i]] > 0) ? maxMintsOverrides[_cardId[i]] : card.maxMintsPerAddress), "Max mints reached for address");

      if (cardLevel.numberMinted + _amount[i] > card.allocation) {
        _amount[i] = card.allocation - cardLevel.numberMinted;
      }

      if (_useUnicorns[i]) {
        require(card.costInUnicorns > 0, "unicorns not allowed");
        _locals.totalPriceUnicorns += card.costInUnicorns * _amount[i] * POINT_COST_DECIMALS;
        _locals.fee += (card.costInUnicorns * _amount[i] * POINT_COST_DECIMALS * mintingFeeBasisPointsUnicorns) / (unicornToEth * 10000);
      } else {
        require(card.costInRainbows > 0, "rainbows not allowed");
        _locals.totalPriceRainbows += card.costInRainbows * _amount[i] * POINT_COST_DECIMALS;
        _locals.fee += (card.costInRainbows * _amount[i] * POINT_COST_DECIMALS * mintingFeeBasisPointsRainbows) / (rainbowToEth * 10000);
      }
    }

    _locals.amountEthToWithdraw = 0;
    
    for (uint256 n = 0; n < 2; n++) {
      bool loopTypeUnicorns = n > 0;

      uint256 totalBalance = 0;
      uint256 totalPrice = loopTypeUnicorns ? _locals.totalPriceUnicorns : _locals.totalPriceRainbows;
      uint256 remainingPrice = totalPrice;

      if (totalPrice > 0) {
        uint256 loopLength = loopTypeUnicorns ? _unicornPools.length : _rainbowPools.length;

        require(loopLength > 0, "invalid pools");

        for (uint256 i = 0; i < loopLength; i++) {
          IStakingPool pool;
          if (loopTypeUnicorns) {
            require((unicornPools[_unicornPools[i]]), "invalid unicorn pool");
            pool = IStakingPool(_unicornPools[i]);
          } else {
            require((rainbowPools[_rainbowPools[i]]), "invalid rainbow pool");
            pool = IStakingPool(_rainbowPools[i]);
          }
          uint256 _balance = pool.balanceOf(_msgSender());
          totalBalance += _balance;

          if (totalBalance >=  totalPrice) {
            pool.burn(_msgSender(), remainingPrice);
            remainingPrice = 0;
            break;
          } else {
            pool.burn(_msgSender(), _balance);
            remainingPrice -= _balance;
          }
        }

        if (remainingPrice > 0) {
          uint256 minPoints = (totalPrice * minPointsPercentToMint) / 100;
          require(totalPrice - remainingPrice >= minPoints, "not enough balance");
          uint256 pointsToEth = loopTypeUnicorns ? unicornToEth : rainbowToEth;
          require(msg.value * pointsToEth > remainingPrice, "not enough balance");
          _locals.amountEthToWithdraw += remainingPrice / pointsToEth;
        }
      }
    }

    _locals.amountEthToWithdraw += _locals.fee;

    require(_locals.amountEthToWithdraw <= msg.value);

    (_locals.success, ) = _msgSender().call{ value: msg.value - _locals.amountEthToWithdraw }(""); // refund excess Eth
    require(_locals.success, "transfer failed");

    bool _tokenMinted = false;
    for (uint256 i = 0; i < _cardId.length; i++) {
      if (_amount[i] > 0) {
        nftContract.addToNumberMintedByAddress(_msgSender(), _cardId[i], _amount[i]);
        nftContract.mint(_msgSender(), _cardId[i], 0, _amount[i], nftContract.contractChar(), 0, _data[i]);
        _tokenMinted = true;
      }
    }
    require(_tokenMinted, 'Allocation exhausted');
  }

  function withdrawEth(uint256 _amount)
    external onlyOwner {

      require(_amount <= address(this).balance, "not enough balance");
      (bool success, ) = _msgSender().call{ value: _amount }("");
      require(success, "transfer failed");
  }
}