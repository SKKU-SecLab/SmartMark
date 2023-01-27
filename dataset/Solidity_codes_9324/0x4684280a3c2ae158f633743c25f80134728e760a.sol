
pragma solidity >=0.6.2 <0.8.0;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

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

pragma solidity >=0.4.24 <0.8.0;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
    uint256[50] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165Upgradeable is Initializable, IERC165Upgradeable {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function __ERC165_init() internal initializer {
        __ERC165_init_unchained();
    }

    function __ERC165_init_unchained() internal initializer {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
    uint256[49] private __gap;
}// MIT

pragma solidity >=0.6.0 <0.8.0;

interface IERC721ReceiverUpgradeable {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract ERC721HolderUpgradeable is Initializable, IERC721ReceiverUpgradeable {

    function __ERC721Holder_init() internal initializer {

        __ERC721Holder_init_unchained();
    }

    function __ERC721Holder_init_unchained() internal initializer {

    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
    uint256[50] private __gap;
}// MIT
pragma solidity ^0.7.3;


interface IBasicController is IERC165Upgradeable, IERC721ReceiverUpgradeable {

  event RegisteredDomain(
    string name,
    uint256 indexed id,
    uint256 indexed parent,
    address indexed owner,
    address minter
  );

  function registerDomain(string memory domain, address owner) external;


  function registerSubdomain(
    uint256 parentId,
    string memory label,
    address owner
  ) external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721EnumerableUpgradeable is IERC721Upgradeable {


    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721MetadataUpgradeable is IERC721Upgradeable {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// MIT
pragma solidity ^0.7.3;


interface IRegistrar is
  IERC721MetadataUpgradeable,
  IERC721EnumerableUpgradeable
{

  event ControllerAdded(address indexed controller);

  event ControllerRemoved(address indexed controller);

  event DomainCreated(
    uint256 indexed id,
    string name,
    uint256 indexed nameHash,
    uint256 indexed parent,
    address minter,
    address controller
  );

  event MetadataLocked(uint256 indexed id, address locker);

  event MetadataUnlocked(uint256 indexed id);

  event MetadataChanged(uint256 indexed id, string uri);

  event RoyaltiesAmountChanged(uint256 indexed id, uint256 amount);

  function addController(address controller) external;


  function removeController(address controller) external;


  function registerDomain(
    uint256 parentId,
    string memory name,
    address domainOwner,
    address minter
  ) external returns (uint256);


  function lockDomainMetadata(uint256 id) external;


  function lockDomainMetadataForOwner(uint256 id) external;


  function unlockDomainMetadata(uint256 id) external;


  function setDomainMetadataUri(uint256 id, string memory uri) external;


  function setDomainRoyaltyAmount(uint256 id, uint256 amount) external;


  function domainExists(uint256 id) external view returns (bool);


  function isAvailable(uint256 id) external view returns (bool);


  function minterOf(uint256 id) external view returns (address);


  function isDomainMetadataLocked(uint256 id) external view returns (bool);


  function domainMetadataLockedBy(uint256 id) external view returns (address);


  function domainController(uint256 id) external view returns (address);


  function domainRoyaltyAmount(uint256 id) external view returns (uint256);

}// MIT
pragma solidity ^0.7.3;



contract BasicController is
  IBasicController,
  ContextUpgradeable,
  ERC165Upgradeable,
  ERC721HolderUpgradeable
{

  IRegistrar private registrar;
  uint256 private rootDomain;

  modifier authorized(uint256 domain) {

    require(
      registrar.ownerOf(domain) == _msgSender(),
      "Zer0 Controller: Not Authorized"
    );
    _;
  }

  function initialize(IRegistrar _registrar) public initializer {

    __ERC165_init();
    __Context_init();
    __ERC721Holder_init();

    registrar = _registrar;
    rootDomain = 0x0;
  }

  function registerDomain(string memory domain, address owner)
    public
    override
    authorized(rootDomain)
  {

    registerSubdomain(rootDomain, domain, owner);
  }

  function registerSubdomain(
    uint256 parentId,
    string memory label,
    address owner
  ) public override authorized(parentId) {

    address minter = _msgSender();
    uint256 id = registrar.registerDomain(parentId, label, owner, minter);

    emit RegisteredDomain(label, id, parentId, owner, minter);
  }

  function registerSubdomainExtended(
    uint256 parentId,
    string memory label,
    address owner,
    string memory metadata,
    uint256 royaltyAmount,
    bool lockOnCreation
  ) external authorized(parentId) {

    address minter = _msgSender();
    address controller = address(this);

    uint256 id = registrar.registerDomain(parentId, label, controller, minter);
    registrar.setDomainMetadataUri(id, metadata);
    registrar.setDomainRoyaltyAmount(id, royaltyAmount);
    registrar.safeTransferFrom(controller, owner, id);

    if (lockOnCreation) {
      registrar.lockDomainMetadataForOwner(id);
    }

    emit RegisteredDomain(label, id, parentId, owner, minter);
  }
}