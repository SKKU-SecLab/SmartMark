
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

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


interface IERC721Enumerable is IERC721 {

    function totalSupply() external view returns (uint256);


    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) external view returns (uint256);

}// MIT

pragma solidity ^0.8.0;

interface IERC777Recipient {

    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC777 {

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function granularity() external view returns (uint256);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function send(
        address recipient,
        uint256 amount,
        bytes calldata data
    ) external;


    function burn(uint256 amount, bytes calldata data) external;


    function isOperatorFor(address operator, address tokenHolder) external view returns (bool);


    function authorizeOperator(address operator) external;


    function revokeOperator(address operator) external;


    function defaultOperators() external view returns (address[] memory);


    function operatorSend(
        address sender,
        address recipient,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    function operatorBurn(
        address account,
        uint256 amount,
        bytes calldata data,
        bytes calldata operatorData
    ) external;


    event Sent(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 amount,
        bytes data,
        bytes operatorData
    );

    event Minted(address indexed operator, address indexed to, uint256 amount, bytes data, bytes operatorData);

    event Burned(address indexed operator, address indexed from, uint256 amount, bytes data, bytes operatorData);

    event AuthorizedOperator(address indexed operator, address indexed tokenHolder);

    event RevokedOperator(address indexed operator, address indexed tokenHolder);
}// MIT

pragma solidity ^0.8.0;

interface IERC1820Registry {

    function setManager(address account, address newManager) external;


    function getManager(address account) external view returns (address);


    function setInterfaceImplementer(
        address account,
        bytes32 _interfaceHash,
        address implementer
    ) external;


    function getInterfaceImplementer(address account, bytes32 _interfaceHash) external view returns (address);


    function interfaceHash(string calldata interfaceName) external pure returns (bytes32);


    function updateERC165Cache(address account, bytes4 interfaceId) external;


    function implementsERC165Interface(address account, bytes4 interfaceId) external view returns (bool);


    function implementsERC165InterfaceNoCache(address account, bytes4 interfaceId) external view returns (bool);


    event InterfaceImplementerSet(address indexed account, bytes32 indexed interfaceHash, address indexed implementer);

    event ManagerChanged(address indexed account, address indexed newManager);
}pragma solidity ^0.8.0;

interface IRNGV2 {

    function requestRandomNumber( ) external returns (uint256);

    function requestRandomNumberWithCallback( ) external returns (uint256);

    function isRequestComplete(uint256 requestId) external view returns (bool isCompleted);

    function randomNumber(uint256 requestId) external view returns (uint256 randomNum);

}pragma solidity ^0.8.0;

interface IRNGrequestorV2 {

    function process(uint256 rand, uint256 requestId) external;

}pragma solidity ^0.8.0;

interface dust_redeemer {

    function redeem(DustBusterPro memory general) external returns (uint256) ;

    function balanceOf(address token, address vault) external view returns(uint256);

}


struct DustBusterPro {
    string  name;
    address vault;
    address token;
    uint256 random;
    address recipient;
    address handler;
    uint256 position;
    uint256 token_id;
    bool    redeemed;
}pragma solidity ^0.8.13;

interface RegistryConsumer {


    function getRegistryAddress(string memory key) external view returns (address) ;


    function getRegistryBool(string memory key) external view returns (bool);


    function getRegistryUINT(string memory key) external view returns (uint256) ;


    function getRegistryString(string memory key) external view returns (string memory) ;


    function isAdmin(address user) external view returns (bool) ;


    function isAppAdmin(address app, address user) external view returns (bool);


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

pragma solidity ^0.8.2;


abstract contract Initializable {
    uint8 private _initialized;

    bool private _initializing;

    event Initialized(uint8 version);

    modifier initializer() {
        bool isTopLevelCall = _setInitializedVersion(1);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(1);
        }
    }

    modifier reinitializer(uint8 version) {
        bool isTopLevelCall = _setInitializedVersion(version);
        if (isTopLevelCall) {
            _initializing = true;
        }
        _;
        if (isTopLevelCall) {
            _initializing = false;
            emit Initialized(version);
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _disableInitializers() internal virtual {
        _setInitializedVersion(type(uint8).max);
    }

    function _setInitializedVersion(uint8 version) private returns (bool) {
        if (_initializing) {
            require(
                version == 1 && !AddressUpgradeable.isContract(address(this)),
                "Initializable: contract is already initialized"
            );
            return false;
        } else {
            require(_initialized < version, "Initializable: contract is already initialized");
            _initialized = version;
            return true;
        }
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
}pragma solidity ^0.8.13;






struct DustBuster {
    string  name;
    uint256 price;
    uint256 remaining;
    address vault;
    address token;
    uint256 reserved;
    address handler;
    address destination; // Zero if for burning
    bool    enabled;
}


contract dust_for_punkz is Initializable, OwnableUpgradeable,  dust_redeemer, IRNGrequestorV2,IERC777Recipient, ReentrancyGuardUpgradeable {


    RegistryConsumer   constant public reg = RegistryConsumer(0x1e8150050A7a4715aad42b905C08df76883f396F);

    uint256       public next_redeemable;
    mapping(uint256 => DustBuster)            redeemables;
    mapping(uint256 => DustBusterPro)         waiting;
    mapping(address => uint256[])      public userhashes;

    string constant public punksForDust = "https://www.youtube.com/watch?v=wsOHvP1XnRg";

    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    event RedemptionRequest(uint256 hash);

    modifier onlyAppAdmin() {

        require(
            msg.sender == owner() ||
            reg.isAppAdmin(address(this),msg.sender),
            "AppAdmin : Unauthorised"
        );
        _;
    }

    function initialize() public initializer {

        require(rngAddress() != address(0),"Rng address not set in registry");
        require(dustAddress() != address(0),"DUST address not set in registry");
        
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
        __Ownable_init();
    }

 
    function add_external_redeemer(
        string  memory name,
        uint256 price,
        uint256 remaining,
        address vault,
        address token,
        address handler,
        address destinasi
    ) external onlyAppAdmin {

        redeemables[next_redeemable++] = DustBuster(name,price,remaining, vault,token,0,handler, destinasi, true);
    }

    function add_721_vault(
        string  memory name,
        uint256 price,
        uint256 remaining,
        address vault,
        address token,
        address destinasi
    ) external onlyAppAdmin {

        require(IERC721(token).isApprovedForAll(vault,address(this)),"Token vault has not approved this contract");
        redeemables[next_redeemable++] = DustBuster(name,price, remaining,vault,token,0,address(this),destinasi,true);
    }

    function vaultName(uint256 vaultID) external view returns (string memory) {

        return redeemables[vaultID].name;
    }

    function vaultPrice(uint256 vaultID) external view returns (uint256) {

        return redeemables[vaultID].price;
    }

    function vaultAddress(uint256 vaultID) external view returns (address) {

        return redeemables[vaultID].vault;
    }

    function vaultToken(uint256 vaultID) external view returns (address) {

        return redeemables[vaultID].token;
    }

    function change_vault_price(uint vaultID, uint256 price) external onlyAppAdmin {

        redeemables[vaultID].price = price;
    }

    function enable_vault(uint vaultID,  bool enabled) external onlyAppAdmin {

        redeemables[vaultID].enabled = enabled;
    }
 
    function tokensReceived(
        address ,
        address from,
        address ,
        uint256 amount,
        bytes calldata userData,
        bytes calldata
    ) external override nonReentrant {

        require(msg.sender == dustAddress(),"Unauthorised");
        require(userData.length == 32,"Invalid user data");
        uint pos = uint256(bytes32(userData[0:32]));
        DustBuster memory db = redeemables[pos];
        require(db.enabled,"Vault not enabled");
        require(IERC721(db.token).isApprovedForAll(db.vault,address(this)),"Token vault has not approved this contract");
        require(dust_redeemer(db.handler).balanceOf(db.token,db.vault) > db.reserved,"Insufficient tokens in vault");
        require(db.remaining > 0, "Insufficient tokens available");
        redeemables[pos].reserved++;
        require(amount>= db.price,"Insufficent Dust sent");
        uint256 hash = rng().requestRandomNumberWithCallback( );
        waiting[hash] = DustBusterPro(db.name,db.vault,db.token,0,from, db.handler,pos,0,false);
        userhashes[from].push(hash);
        bytes memory data;
        redeemables[pos].remaining--;
        if (db.destination == address(0)){
            IERC777(dustAddress()).burn(amount,data);
        } else {
            IERC777(dustAddress()).send(db.destination,amount,data);
        }
        emit RedemptionRequest(hash);
    }


    function redeem(DustBusterPro memory general) external override returns (uint256) {

        require(msg.sender == address(this),"Invalid sender");
        IERC721Enumerable  token = IERC721Enumerable(general.token);
        require(token.supportsInterface(type(IERC721Enumerable).interfaceId),"Not an ERC721Enumerable");
        uint256 balance = token.balanceOf(general.vault);
        require(balance > 0,"No NFTs in vault");
        uint256 tokenPos = general.random % balance;
        uint256 tokenId = token.tokenOfOwnerByIndex(general.vault, tokenPos);
        token.safeTransferFrom(general.vault,general.recipient,tokenId);
        return tokenId;
    }

    function balanceOf(address token, address vault) external override view returns(uint256) {

        return IERC721Enumerable(token).balanceOf(vault);
    }

    function process(uint256 rand, uint256 requestId) external override {

        require(msg.sender == rngAddress(),"unauthorised");
        DustBusterPro memory dbp = waiting[requestId];
        dbp.random = rand;
        redeemables[dbp.position].reserved--;
        uint256 tokenId = dust_redeemer(dbp.handler).redeem(dbp);
        dbp.token_id = tokenId;
        dbp.redeemed = true;
        waiting[requestId] = dbp;
    }

    function numberOfHashes(address user) external view returns (uint256){

        return userhashes[user].length;
    }

    function redeemedTokenId(uint256 hash) external view returns (uint256) {

        return waiting[hash].token_id;
    }

    function isTokenRedeemed(uint256 hash) external view returns (bool) {

        return waiting[hash].redeemed;
    }

    function rngAddress() internal view returns (address) {

        return reg.getRegistryAddress("RANDOMV2");
    }

    function rng() internal view returns (IRNGV2) {

        return IRNGV2(rngAddress());
    }

    function dustAddress() internal view returns (address) {

        return reg.getRegistryAddress("DUST");
    }

}