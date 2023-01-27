pragma solidity 0.8.12;

contract Deployer {

    event InstanceDeployed(address instance);
    
    function deploy(
        address _logic
    ) 
      internal 
      returns (address instance) 
    {

        bytes20 targetBytes = bytes20(_logic);
        assembly {
          let clone := mload(0x40)
          mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
          mstore(add(clone, 0x14), targetBytes)
          mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
          instance := create(0, clone, 0x37)
        }
        emit InstanceDeployed(address(instance));
    }
}pragma solidity 0.8.12;

interface IFactory {

    function createToken(
        uint256 _templateIndex,
        string[] calldata strings,
        address[] calldata addresses,
        uint256[] calldata uints,
        bytes[] calldata bytess
    ) external returns (address token);


    function erc721List(address ERC721address) external returns (address);


    function erc20List(address erc20dt) external view returns(bool);



    struct NftCreateData{
        string name;
        string symbol;
        uint256 templateIndex;
        string tokenURI;
        bool transferable;
        address owner;
    }
    struct ErcCreateData{
        uint256 templateIndex;
        string[] strings;
        address[] addresses;
        uint256[] uints;
        bytes[] bytess;
    }

    struct PoolData{
        uint256[] ssParams;
        uint256[] swapFees;
        address[] addresses;
    }

    struct FixedData{
        address fixedPriceAddress;
        address[] addresses;
        uint256[] uints;
    }

    struct DispenserData{
        address dispenserAddress;
        uint256 maxTokens;
        uint256 maxBalance;
        bool withMint;
        address allowedSwapper;
    }
    
    function createNftWithErc20(
        NftCreateData calldata _NftCreateData,
        ErcCreateData calldata _ErcCreateData
    ) external returns (address , address);


    function createNftWithErc20WithPool(
        NftCreateData calldata _NftCreateData,
        ErcCreateData calldata _ErcCreateData,
        PoolData calldata _PoolData
    ) external returns (address, address , address);


    
    function createNftWithErc20WithFixedRate(
         NftCreateData calldata _NftCreateData,
        ErcCreateData calldata _ErcCreateData,
        FixedData calldata _FixedData
    ) external returns (address, address , bytes32 );


    
    function createNftWithErc20WithDispenser(
        NftCreateData calldata _NftCreateData,
        ErcCreateData calldata _ErcCreateData,
        DispenserData calldata _DispenserData
    ) external returns (address, address);

}pragma solidity 0.8.12;



interface IERC721Template {

    
    enum RolesType {
        Manager,
        DeployERC20,
        UpdateMetadata,
        Store
    }
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event MetadataCreated(
        address indexed createdBy,
        uint8 state,
        string decryptorUrl,
        bytes flags,
        bytes data,
        string metaDataDecryptorAddress,
        uint256 timestamp,
        uint256 blockNumber
    );
    event MetadataUpdated(
        address indexed updatedBy,
        uint8 state,
        string decryptorUrl,
        bytes flags,
        bytes data,
        string metaDataDecryptorAddress,
        uint256 timestamp,
        uint256 blockNumber
    );
    function balanceOf(address owner) external view returns (uint256 balance);

    function name() external view returns (string memory);


    function symbol() external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address owner);


    function isERC20Deployer(address acount) external view returns (bool);

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


    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);


    function transferFrom(address from, address to) external;


    function initialize(
        address admin,
        string calldata name,
        string calldata symbol,
        address erc20Factory,
        address additionalERC20Deployer,
        address additionalMetaDataUpdater,
        string calldata tokenURI,
        bool transferable
    ) external returns (bool);


     struct Roles {
        bool manager;
        bool deployERC20;
        bool updateMetadata;
        bool store;
    }

    struct metaDataProof {
        address validatorAddress;
        uint8 v; // v of validator signed message
        bytes32 r; // r of validator signed message
        bytes32 s; // s of validator signed message
    }
    function getPermissions(address user) external view returns (Roles memory);


    function setDataERC20(bytes32 _key, bytes calldata _value) external;

    function setMetaData(uint8 _metaDataState, string calldata _metaDataDecryptorUrl
        , string calldata _metaDataDecryptorAddress, bytes calldata flags, 
        bytes calldata data,bytes32 _metaDataHash, metaDataProof[] memory _metadataProofs) external;

    function getMetaData() external view returns (string memory, string memory, uint8, bool);


    function createERC20(
        uint256 _templateIndex,
        string[] calldata strings,
        address[] calldata addresses,
        uint256[] calldata uints,
        bytes[] calldata bytess
    ) external returns (address);



    function removeFromCreateERC20List(address _allowedAddress) external;

    function addToCreateERC20List(address _allowedAddress) external;

    function addToMetadataList(address _allowedAddress) external;

    function removeFromMetadataList(address _allowedAddress) external;

    function getId() pure external returns (uint8);

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
}pragma solidity 0.8.12;

interface IERC20Template {

    struct RolesERC20 {
        bool minter;
        bool feeManager;
    }
    struct providerFee{
        address providerFeeAddress;
        address providerFeeToken; // address of the token marketplace wants to add fee on top
        uint256 providerFeeAmount; // amount to be transfered to marketFeeCollector
        uint8 v; // v of provider signed message
        bytes32 r; // r of provider signed message
        bytes32 s; // s of provider signed message
        uint256 validUntil; //validity expresses in unix timestamp
        bytes providerData; //data encoded by provider
    }
    struct consumeMarketFee{
        address consumeMarketFeeAddress;
        address consumeMarketFeeToken; // address of the token marketplace wants to add fee on top
        uint256 consumeMarketFeeAmount; // amount to be transfered to marketFeeCollector
    }
    function initialize(
        string[] calldata strings_,
        address[] calldata addresses_,
        address[] calldata factoryAddresses_,
        uint256[] calldata uints_,
        bytes[] calldata bytes_
    ) external returns (bool);

    
    function name() external pure returns (string memory);


    function symbol() external pure returns (string memory);


    function decimals() external pure returns (uint8);


    function totalSupply() external view returns (uint256);


    function cap() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 value) external returns (bool);


    function transfer(address to, uint256 value) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);


    function mint(address account, uint256 value) external;

    
    function isMinter(address account) external view returns (bool);


    function DOMAIN_SEPARATOR() external view returns (bytes32);


    function PERMIT_TYPEHASH() external pure returns (bytes32);


    function nonces(address owner) external view returns (uint256);


    function permissions(address user)
        external
        view
        returns (RolesERC20 memory);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


    function cleanFrom721() external;


    function deployPool(
        uint256[] memory ssParams,
        uint256[] memory swapFees,
        address[] memory addresses 
    ) external returns (address);


    function createFixedRate(
        address fixedPriceAddress,
        address[] memory addresses,
        uint[] memory uints
    ) external returns (bytes32);

    function createDispenser(
        address _dispenser,
        uint256 maxTokens,
        uint256 maxBalance,
        bool withMint,
        address allowedSwapper) external;

        
    function getPublishingMarketFee() external view returns (address , address, uint256);

    function setPublishingMarketFee(
        address _publishMarketFeeAddress, address _publishMarketFeeToken, uint256 _publishMarketFeeAmount
    ) external;


     function startOrder(
        address consumer,
        uint256 serviceIndex,
        providerFee calldata _providerFee,
        consumeMarketFee calldata _consumeMarketFee
     ) external;


     function reuseOrder(
        bytes32 orderTxId,
        providerFee calldata _providerFee
    ) external;

  
    function burn(uint256 amount) external;

    function burnFrom(address account, uint256 amount) external;

    function getERC721Address() external view returns (address);

    function isERC20Deployer(address user) external view returns(bool);

    function getPools() external view returns(address[] memory);

    struct fixedRate{
        address contractAddress;
        bytes32 id;
    }
    function getFixedRates() external view returns(fixedRate[] memory);

    function getDispensers() external view returns(address[] memory);

    function getId() pure external returns (uint8);

    function getPaymentCollector() external view returns (address);

}pragma solidity 0.8.12;


interface IERC20 {

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity 0.8.12;

library Address {

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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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


}



pragma solidity ^0.8.12;


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
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
}pragma solidity 0.8.12;

contract ERC721Factory is Deployer, Ownable, ReentrancyGuard, IFactory {

    using SafeERC20 for IERC20;
    using SafeMath for uint256;
    uint256 private currentNFTCount;
    address private erc20Factory;
    uint256 private nftTemplateCount;

    struct Template {
        address templateAddress;
        bool isActive;
    }

    mapping(uint256 => Template) public nftTemplateList;

    mapping(uint256 => Template) public templateList;

    mapping(address => address) public erc721List;

    mapping(address => bool) public erc20List;

    event NFTCreated(
        address newTokenAddress,
        address indexed templateAddress,
        string tokenName,
        address indexed admin,
        string symbol,
        string tokenURI,
        bool transferable,
        address indexed creator
    );

       uint256 private currentTokenCount = 0;
    uint256 public templateCount;
    address public router;

    event Template721Added(address indexed _templateAddress, uint256 indexed nftTemplateCount);
    event Template20Added(address indexed _templateAddress, uint256 indexed nftTemplateCount);
    event TokenCreated(
        address indexed newTokenAddress,
        address indexed templateAddress,
        string name,
        string symbol,
        uint256 cap,
        address creator
    );  
    
    event NewPool(
        address poolAddress,
        address ssContract,
        address baseTokenAddress
    );


    event NewFixedRate(bytes32 exchangeId, address indexed owner, address exchangeContract, address indexed baseToken);
    event NewDispenser(address dispenserContract);

    event DispenserCreated(  // emited when a dispenser is created
        address indexed datatokenAddress,
        address indexed owner,
        uint256 maxTokens,
        uint256 maxBalance,
        address allowedSwapper
    );
    
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    constructor(
        address _template721,
        address _template,
        address _router
    ) {
        require(
            _template != address(0) &&
                _router != address(0) &&
                _template721 != address(0),
            "ERC721DTFactory: Invalid template/router address"
        );
        add721TokenTemplate(_template721);
        addTokenTemplate(_template);
        router = _router;
    }



    function deployERC721Contract(
        string memory name,
        string memory symbol,
        uint256 _templateIndex,
        address additionalERC20Deployer,
        address additionalMetaDataUpdater,
        string memory tokenURI,
        bool transferable,
        address owner
    ) public returns (address token) {

        require(
            _templateIndex <= nftTemplateCount && _templateIndex != 0,
            "ERC721DTFactory: Template index doesnt exist"
        );
        Template memory tokenTemplate = nftTemplateList[_templateIndex];

        require(
            tokenTemplate.isActive,
            "ERC721DTFactory: ERC721Token Template disabled"
        );
        require(
            owner!=address(0),
            "ERC721DTFactory: address(0) cannot be owner"
        );
        token = deploy(tokenTemplate.templateAddress);

        require(
            token != address(0),
            "ERC721DTFactory: Failed to perform minimal deploy of a new token"
        );
       
        erc721List[token] = token;
        emit NFTCreated(token, tokenTemplate.templateAddress, name, owner, symbol, tokenURI, transferable, msg.sender);
        currentNFTCount += 1;
        IERC721Template tokenInstance = IERC721Template(token);
        require(
            tokenInstance.initialize(
                owner,
                name,
                symbol,
                address(this),
                additionalERC20Deployer,
                additionalMetaDataUpdater,
                tokenURI,
                transferable
            ),
            "ERC721DTFactory: Unable to initialize token instance"
        );

        
    }
    
    function getCurrentNFTCount() external view returns (uint256) {

        return currentNFTCount;
    }

    function getNFTTemplate(uint256 _index)
        external
        view
        returns (Template memory)
    {

        Template memory template = nftTemplateList[_index];
        return template;
    }

    
    function add721TokenTemplate(address _templateAddress)
        public
        onlyOwner
        returns (uint256)
    {

        require(
            _templateAddress != address(0),
            "ERC721DTFactory: ERC721 template address(0) NOT ALLOWED"
        );
        require(_isContract(_templateAddress), "ERC721Factory: NOT CONTRACT");
        nftTemplateCount += 1;
        Template memory template = Template(_templateAddress, true);
        nftTemplateList[nftTemplateCount] = template;
        emit Template721Added(_templateAddress,nftTemplateCount);
        return nftTemplateCount;
    }
    
    function reactivate721TokenTemplate(uint256 _index) external onlyOwner {

        require(
            _index <= nftTemplateCount && _index != 0,
            "ERC721DTFactory: Template index doesnt exist"
        );
        Template storage template = nftTemplateList[_index];
        template.isActive = true;
    }

    function disable721TokenTemplate(uint256 _index) external onlyOwner {

        require(
            _index <= nftTemplateCount && _index != 0,
            "ERC721DTFactory: Template index doesnt exist"
        );
        Template storage template = nftTemplateList[_index];
        template.isActive = false;
    }

    function getCurrentNFTTemplateCount() external view returns (uint256) {

        return nftTemplateCount;
    }

    function _isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

 
    struct tokenStruct{
        string[] strings;
        address[] addresses;
        uint256[] uints;
        bytes[] bytess;
        address owner;
    }
    function createToken(
        uint256 _templateIndex,
        string[] memory strings,
        address[] memory addresses,
        uint256[] memory uints,
        bytes[] memory bytess
    ) external returns (address token) {

        require(
            erc721List[msg.sender] == msg.sender,
            "ERC721Factory: ONLY ERC721 INSTANCE FROM ERC721FACTORY"
        );
        token = _createToken(_templateIndex, strings, addresses, uints, bytess, msg.sender);
        
    }
    function _createToken(
        uint256 _templateIndex,
        string[] memory strings,
        address[] memory addresses,
        uint256[] memory uints,
        bytes[] memory bytess,
        address owner
    ) internal returns (address token) {

        require(uints[0] != 0, "ERC20Factory: zero cap is not allowed");
        require(
            _templateIndex <= templateCount && _templateIndex != 0,
            "ERC20Factory: Template index doesnt exist"
        );
        Template memory tokenTemplate = templateList[_templateIndex];

        require(
            tokenTemplate.isActive,
            "ERC20Factory: ERC721Token Template disabled"
        );
        token = deploy(tokenTemplate.templateAddress);
        erc20List[token] = true;

        require(
            token != address(0),
            "ERC721Factory: Failed to perform minimal deploy of a new token"
        );
        emit TokenCreated(token, tokenTemplate.templateAddress, strings[0], strings[1], uints[0], owner);
        currentTokenCount += 1;
        tokenStruct memory tokenData = tokenStruct(strings,addresses,uints,bytess,owner); 
        _createTokenStep2(token, tokenData);
    }

    function _createTokenStep2(address token, tokenStruct memory tokenData) internal {

        
        IERC20Template tokenInstance = IERC20Template(token);
        address[] memory factoryAddresses = new address[](3);
        factoryAddresses[0] = tokenData.owner;
        
        factoryAddresses[1] = router;
        
        require(
            tokenInstance.initialize(
                tokenData.strings,
                tokenData.addresses,
                factoryAddresses,
                tokenData.uints,
                tokenData.bytess
            ),
            "ERC20Factory: Unable to initialize token instance"
        );
        
    }

    function getCurrentTokenCount() external view returns (uint256) {

        return currentTokenCount;
    }


    function getTokenTemplate(uint256 _index)
        external
        view
        returns (Template memory)
    {

        Template memory template = templateList[_index];
        require(
            _index <= templateCount && _index != 0,
            "ERC20Factory: Template index doesnt exist"
        );
        return template;
    }


    
    function addTokenTemplate(address _templateAddress)
        public
        onlyOwner
        returns (uint256)
    {

        require(
            _templateAddress != address(0),
            "ERC20Factory: ERC721 template address(0) NOT ALLOWED"
        );
        require(_isContract(_templateAddress), "ERC20Factory: NOT CONTRACT");
        templateCount += 1;
        Template memory template = Template(_templateAddress, true);
        templateList[templateCount] = template;
        emit Template20Added(_templateAddress, templateCount);
        return templateCount;
    }


    function disableTokenTemplate(uint256 _index) external onlyOwner {

        Template storage template = templateList[_index];
        template.isActive = false;
    }



    function reactivateTokenTemplate(uint256 _index) external onlyOwner {

        require(
            _index <= templateCount && _index != 0,
            "ERC20DTFactory: Template index doesnt exist"
        );
        Template storage template = templateList[_index];
        template.isActive = true;
    }

    function getCurrentTemplateCount() external view returns (uint256) {

        return templateCount;
    }

    struct tokenOrder {
        address tokenAddress;
        address consumer;
        uint256 serviceIndex;
        IERC20Template.providerFee _providerFee;
        IERC20Template.consumeMarketFee _consumeMarketFee;
    }

    function startMultipleTokenOrder(
        tokenOrder[] memory orders
    ) external nonReentrant {

        require(orders.length <= 50, 'ERC721Factory: Too Many Orders');
        for (uint256 i = 0; i < orders.length; i++) {
            (address publishMarketFeeAddress, address publishMarketFeeToken, uint256 publishMarketFeeAmount) 
                = IERC20Template(orders[i].tokenAddress).getPublishingMarketFee();
            
            if (publishMarketFeeAmount > 0 && publishMarketFeeToken!=address(0) 
            && publishMarketFeeAddress!=address(0)) {
                _pullUnderlying(publishMarketFeeToken,msg.sender,
                    address(this),
                    publishMarketFeeAmount);
                IERC20(publishMarketFeeToken).safeIncreaseAllowance(orders[i].tokenAddress, publishMarketFeeAmount);
            }
            if (orders[i]._consumeMarketFee.consumeMarketFeeAmount > 0
            && orders[i]._consumeMarketFee.consumeMarketFeeAddress!=address(0) 
            && orders[i]._consumeMarketFee.consumeMarketFeeToken!=address(0)) {
                _pullUnderlying(orders[i]._consumeMarketFee.consumeMarketFeeToken,msg.sender,
                    address(this),
                    orders[i]._consumeMarketFee.consumeMarketFeeAmount);
                IERC20(orders[i]._consumeMarketFee.consumeMarketFeeToken)
                .safeIncreaseAllowance(orders[i].tokenAddress, orders[i]._consumeMarketFee.consumeMarketFeeAmount);
            }
            if (orders[i]._providerFee.providerFeeAmount > 0 && orders[i]._providerFee.providerFeeToken!=address(0) 
            && orders[i]._providerFee.providerFeeAddress!=address(0)) {
                _pullUnderlying(orders[i]._providerFee.providerFeeToken,msg.sender,
                    address(this),
                    orders[i]._providerFee.providerFeeAmount);
                IERC20(orders[i]._providerFee.providerFeeToken)
                .safeIncreaseAllowance(orders[i].tokenAddress, orders[i]._providerFee.providerFeeAmount);
            }
            _pullUnderlying(orders[i].tokenAddress,msg.sender,
                    address(this),
                    1e18);
            IERC20Template(orders[i].tokenAddress).startOrder(
                orders[i].consumer,
                orders[i].serviceIndex,
                orders[i]._providerFee,
                orders[i]._consumeMarketFee
            );
        }
    }

    struct reuseTokenOrder {
        address tokenAddress;
        bytes32 orderTxId;
        IERC20Template.providerFee _providerFee;
    }
    function reuseMultipleTokenOrder(
        reuseTokenOrder[] memory orders
    ) external nonReentrant {

        require(orders.length <= 50, 'ERC721Factory: Too Many Orders');
        for (uint256 i = 0; i < orders.length; i++) {
            if (orders[i]._providerFee.providerFeeAmount > 0 && orders[i]._providerFee.providerFeeToken!=address(0) 
            && orders[i]._providerFee.providerFeeAddress!=address(0)) {
                _pullUnderlying(orders[i]._providerFee.providerFeeToken,msg.sender,
                    address(this),
                    orders[i]._providerFee.providerFeeAmount);
                IERC20(orders[i]._providerFee.providerFeeToken)
                .safeIncreaseAllowance(orders[i].tokenAddress, orders[i]._providerFee.providerFeeAmount);
            }
        
            IERC20Template(orders[i].tokenAddress).reuseOrder(
                orders[i].orderTxId,
                orders[i]._providerFee
            );
        }
    }


    function createNftWithErc20(
        NftCreateData calldata _NftCreateData,
        ErcCreateData calldata _ErcCreateData
    ) external nonReentrant returns (address erc721Address, address erc20Address){

        erc721Address = deployERC721Contract(
            _NftCreateData.name,
            _NftCreateData.symbol,
            _NftCreateData.templateIndex,
            address(this),
            address(0),
            _NftCreateData.tokenURI,
            _NftCreateData.transferable,
            _NftCreateData.owner
            );
        erc20Address = IERC721Template(erc721Address).createERC20(
            _ErcCreateData.templateIndex,
            _ErcCreateData.strings,
            _ErcCreateData.addresses,
            _ErcCreateData.uints,
            _ErcCreateData.bytess
        );
        IERC721Template(erc721Address).removeFromCreateERC20List(address(this));
    }

    function createNftWithErc20WithPool(
        NftCreateData calldata _NftCreateData,
        ErcCreateData calldata _ErcCreateData,
        PoolData calldata _PoolData
    ) external nonReentrant returns (address erc721Address, address erc20Address, address poolAddress){

        _pullUnderlying(_PoolData.addresses[1],msg.sender,
                    address(this),
                    _PoolData.ssParams[4]);
        erc721Address = deployERC721Contract(
            _NftCreateData.name,
            _NftCreateData.symbol,
            _NftCreateData.templateIndex,
            address(this),
            address(0),
            _NftCreateData.tokenURI,
            _NftCreateData.transferable,
            _NftCreateData.owner);
        erc20Address = IERC721Template(erc721Address).createERC20(
            _ErcCreateData.templateIndex,
            _ErcCreateData.strings,
            _ErcCreateData.addresses,
            _ErcCreateData.uints,
            _ErcCreateData.bytess
        );
        IERC20(_PoolData.addresses[1]).safeIncreaseAllowance(router,_PoolData.ssParams[4]);
      
        poolAddress = IERC20Template(erc20Address).deployPool(
            _PoolData.ssParams,
            _PoolData.swapFees,
           _PoolData.addresses
        );
        IERC721Template(erc721Address).removeFromCreateERC20List(address(this));
    
   }

    function createNftWithErc20WithFixedRate(
        NftCreateData calldata _NftCreateData,
        ErcCreateData calldata _ErcCreateData,
        FixedData calldata _FixedData
    ) external nonReentrant returns (address erc721Address, address erc20Address, bytes32 exchangeId){

        erc721Address = deployERC721Contract(
            _NftCreateData.name,
            _NftCreateData.symbol,
            _NftCreateData.templateIndex,
            address(this),
            address(0),
            _NftCreateData.tokenURI,
            _NftCreateData.transferable,
            _NftCreateData.owner);
        erc20Address = IERC721Template(erc721Address).createERC20(
            _ErcCreateData.templateIndex,
            _ErcCreateData.strings,
            _ErcCreateData.addresses,
            _ErcCreateData.uints,
            _ErcCreateData.bytess
        );
        exchangeId = IERC20Template(erc20Address).createFixedRate(
            _FixedData.fixedPriceAddress,
            _FixedData.addresses,
            _FixedData.uints
            );
        IERC721Template(erc721Address).removeFromCreateERC20List(address(this));
    }

    function createNftWithErc20WithDispenser(
        NftCreateData calldata _NftCreateData,
        ErcCreateData calldata _ErcCreateData,
        DispenserData calldata _DispenserData
    ) external nonReentrant returns (address erc721Address, address erc20Address){

        erc721Address = deployERC721Contract(
            _NftCreateData.name,
            _NftCreateData.symbol,
            _NftCreateData.templateIndex,
            address(this),
            address(0),
            _NftCreateData.tokenURI,
            _NftCreateData.transferable,
            _NftCreateData.owner);
        erc20Address = IERC721Template(erc721Address).createERC20(
            _ErcCreateData.templateIndex,
            _ErcCreateData.strings,
            _ErcCreateData.addresses,
            _ErcCreateData.uints,
            _ErcCreateData.bytess
        );
        IERC20Template(erc20Address).createDispenser(
            _DispenserData.dispenserAddress,
            _DispenserData.maxTokens,
            _DispenserData.maxBalance,
            _DispenserData.withMint,
            _DispenserData.allowedSwapper
            );
        IERC721Template(erc721Address).removeFromCreateERC20List(address(this));
    }


    
    struct MetaData {
        uint8 _metaDataState;
        string _metaDataDecryptorUrl;
        string _metaDataDecryptorAddress;
        bytes flags;
        bytes data;
        bytes32 _metaDataHash;
        IERC721Template.metaDataProof[] _metadataProofs;
    }

    function createNftWithMetaData(
        NftCreateData calldata _NftCreateData,
        MetaData calldata _MetaData
    ) external nonReentrant returns (address erc721Address){

        erc721Address = deployERC721Contract(
            _NftCreateData.name,
            _NftCreateData.symbol,
            _NftCreateData.templateIndex,
            address(0),
            address(this),
            _NftCreateData.tokenURI,
            _NftCreateData.transferable,
            _NftCreateData.owner);
        IERC721Template(erc721Address).setMetaData(_MetaData._metaDataState, _MetaData._metaDataDecryptorUrl
        , _MetaData._metaDataDecryptorAddress, _MetaData.flags, 
        _MetaData.data,_MetaData._metaDataHash, _MetaData._metadataProofs);
        IERC721Template(erc721Address).removeFromMetadataList(address(this));
    }


    function _pullUnderlying(
        address erc20,
        address from,
        address to,
        uint256 amount
    ) internal {

        uint256 balanceBefore = IERC20(erc20).balanceOf(to);
        IERC20(erc20).safeTransferFrom(from, to, amount);
        require(IERC20(erc20).balanceOf(to) >= balanceBefore.add(amount),
                    "Transfer amount is too low");
    }

}