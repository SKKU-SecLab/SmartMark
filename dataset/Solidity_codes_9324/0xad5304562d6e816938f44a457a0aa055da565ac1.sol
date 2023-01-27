
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
}pragma solidity ^0.8.0;

interface IRNG {

    function requestRandomNumber( ) external returns (bytes32);

    function requestRandomNumberWithCallback( ) external returns (bytes32);

    function isRequestComplete(bytes32 requestId) external view returns (bool isCompleted);

    function randomNumber(bytes32 requestId) external view returns (uint256 randomNum);

}pragma solidity ^0.8.0;

interface IRNGrequestor {

    function process(uint256 rand, bytes32 requestId) external;

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
}pragma solidity ^0.8.0;



struct DustBuster {
    string  name;
    uint256 price;
    address vault;
    address token;
    uint256 reserved;
    address handler;
    bool    enabled;
}


contract dust_for_punkz is Ownable, dust_redeemer, IRNGrequestor,IERC777Recipient, ReentrancyGuard {


    IRNG          public rng;
    address       public DUST_TOKEN;

    uint256       public next_redeemable;
    mapping(uint256 => DustBuster)            redeemables;
    mapping(bytes32 => DustBusterPro)         waiting;
    mapping(address => bytes32[])      public userhashes;

    string constant public punksForDust = "https://www.youtube.com/watch?v=wsOHvP1XnRg";

    bytes32 constant private TOKENS_RECIPIENT_INTERFACE_HASH = keccak256("ERC777TokensRecipient");
    IERC1820Registry internal constant _ERC1820_REGISTRY = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
    event RedemptionRequest(bytes32 hash);

    constructor(IRNG _rng,address dust) {
        rng = _rng;
        DUST_TOKEN = dust;
        _ERC1820_REGISTRY.setInterfaceImplementer(address(this), TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

 
    function add_external_redeemer(
        string  memory name,
        uint256 price,
        address vault,
        address token,
        address handler
    ) external onlyOwner {

        redeemables[next_redeemable++] = DustBuster(name,price,vault,token,0,handler, true);
    }

    function add_721_vault(
        string  memory name,
        uint256 price,
        address vault,
        address token
    ) external onlyOwner {

        redeemables[next_redeemable++] = DustBuster(name,price,vault,token,0,address(this),true);
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

    function change_vault_price(uint vaultID, uint256 price) external onlyOwner {

        redeemables[vaultID].price = price;
    }

    function enable_vault(uint vaultID,  bool enabled) external onlyOwner {

        redeemables[vaultID].enabled = enabled;
    }


    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {

        require(_bytes.length >= (_start + 32), "Read out of bounds");
        uint256 tempUint;

        assembly {
            tempUint := mload(add(add(_bytes, 0x20), _start))
        }
        return tempUint;
    }
 
    function tokensReceived(
        address ,
        address from,
        address ,
        uint256 amount,
        bytes calldata userData,
        bytes calldata
    ) external override nonReentrant {

        require(msg.sender == DUST_TOKEN,"Unauthorised");
        require(userData.length == 32,"Invalid user data");
        uint pos = toUint256(userData, 0);
        DustBuster memory db = redeemables[pos];
        require(db.enabled,"Vault not enabled");
        require(dust_redeemer(db.handler).balanceOf(db.token,db.vault) > db.reserved,"Insufficient tokens in vault");
        redeemables[pos].reserved++;
        require(amount>= db.price,"Insufficent Dust sent");
        bytes32 hash = rng.requestRandomNumberWithCallback( );
        waiting[hash] = DustBusterPro(db.name,db.vault,db.token,0,from, db.handler,pos,0,false);
        userhashes[from].push(hash);
        bytes memory data;
        IERC777(DUST_TOKEN).burn(amount,data);
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

    function process(uint256 rand, bytes32 requestId) external override {

        require(msg.sender == address(rng),"unauthorised");
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

    function redeemedTokenId(bytes32 hash) external view returns (uint256) {

        return waiting[hash].token_id;
    }

    function isTokenRedeemed(bytes32 hash) external view returns (bool) {

        return waiting[hash].redeemed;
    }


}