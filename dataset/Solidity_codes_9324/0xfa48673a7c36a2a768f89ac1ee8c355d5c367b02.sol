pragma solidity 0.8.12;

interface IFixedRateExchange {

    function createWithDecimals(
        address datatoken,
        address[] calldata addresses, // [baseToken,owner,marketFeeCollector]
        uint256[] calldata uints // [baseTokenDecimals,datatokenDecimals, fixedRate, marketFee]
    ) external returns (bytes32 exchangeId);


    function buyDT(bytes32 exchangeId, uint256 datatokenAmount,
        uint256 maxBaseTokenAmount, address consumeMarketAddress, uint256 consumeMarketSwapFeeAmount) external;

    function sellDT(bytes32 exchangeId, uint256 datatokenAmount,
        uint256 minBaseTokenAmount, address consumeMarketAddress, uint256 consumeMarketSwapFeeAmount) external;


    function getAllowedSwapper(bytes32 exchangeId) external view returns (address allowedSwapper);

    function getExchange(bytes32 exchangeId)
        external
        view
        returns (
            address exchangeOwner,
            address datatoken,
            uint256 dtDecimals,
            address baseToken,
            uint256 btDecimals,
            uint256 fixedRate,
            bool active,
            uint256 dtSupply,
            uint256 btSupply,
            uint256 dtBalance,
            uint256 btBalance,
            bool withMint
        );


    function getFeesInfo(bytes32 exchangeId)
        external
        view
        returns (
            uint256 marketFee,
            address marketFeeCollector,
            uint256 opcFee,
            uint256 marketFeeAvailable,
            uint256 oceanFeeAvailable
        );


    function isActive(bytes32 exchangeId) external view returns (bool);


    function calcBaseInGivenOutDT(bytes32 exchangeId, uint256 datatokenAmount, uint256 consumeMarketSwapFeeAmount)
        external
        view
        returns (
            uint256 baseTokenAmount,
            uint256 oceanFeeAmount,
            uint256 publishMarketFeeAmount,
            uint256 consumeMarketFeeAmount
        );

    function calcBaseOutGivenInDT(bytes32 exchangeId, uint256 datatokenAmount, uint256 consumeMarketSwapFeeAmount)
        external
        view
        returns (
            uint256 baseTokenAmount,
            uint256 oceanFeeAmount,
            uint256 publishMarketFeeAmount,
            uint256 consumeMarketFeeAmount
        );

    function updateMarketFee(bytes32 exchangeId, uint256 _newMarketFee) external;

    function updateMarketFeeCollector(bytes32 exchangeId, address _newMarketCollector) external;

    function setAllowedSwapper(bytes32 exchangeId, address newAllowedSwapper) external;

    function getId() pure external returns (uint8);

    function collectBT(bytes32 exchangeId, uint256 amount) external;

    function collectDT(bytes32 exchangeId, uint256 amount) external;

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

}pragma solidity 0.8.12;

interface IFactoryRouter {

    function deployPool(
        address[2] calldata tokens, // [datatokenAddress, baseTokenAddress]
        uint256[] calldata ssParams,
        uint256[] calldata swapFees,
        address[] calldata addresses
    ) external returns (address);


    function deployFixedRate(
        address fixedPriceAddress,
        address[] calldata addresses,
        uint256[] calldata uints
    ) external returns (bytes32 exchangeId);


    function getOPCFee(address baseToken) external view returns (uint256);

    function getOPCFees() external view returns (uint256,uint256);

    function getOPCConsumeFee() external view returns (uint256);

    function getOPCProviderFee() external view returns (uint256);


    function getMinVestingPeriod() external view returns (uint256);

    function deployDispenser(
        address _dispenser,
        address datatoken,
        uint256 maxTokens,
        uint256 maxBalance,
        address owner,
        address allowedSwapper
    ) external;


    function isApprovedToken(address) external view returns(bool);

    function getApprovedTokens() external view returns(address[] memory);

    function isSSContract(address) external view returns(bool);

    function getSSContracts() external view returns(address[] memory);

    function isFixedRateContract(address) external view returns(bool);

    function getFixedRatesContracts() external view returns(address[] memory);

    function isDispenserContract(address) external view returns(bool);

    function getDispensersContracts() external view returns(address[] memory);

    function isPoolTemplate(address) external view returns(bool);

    function getPoolTemplates() external view returns(address[] memory);


    struct Stakes {
        address poolAddress;
        uint256 tokenAmountIn;
        uint256 minPoolAmountOut;
    }
    function stakeBatch(Stakes[] calldata) external;


    enum operationType {
        SwapExactIn,
        SwapExactOut,
        FixedRate,
        Dispenser
    }

    struct Operations {
        bytes32 exchangeIds; // used for fixedRate or dispenser
        address source; // pool, dispenser or fixed rate address
        operationType operation; // type of operation: enum operationType
        address tokenIn; // token in address, only for pools
        uint256 amountsIn; // ExactAmount In for swapExactIn operation, maxAmount In for swapExactOut
        address tokenOut; // token out address, only for pools
        uint256 amountsOut; // minAmountOut for swapExactIn or exactAmountOut for swapExactOut
        uint256 maxPrice; // maxPrice, only for pools
        uint256 swapMarketFee;
        address marketFeeAddress;
    }
    function buyDTBatch(Operations[] calldata) external;

    function updateOPCCollector(address _opcCollector) external;

    function getOPCCollector() view external returns (address);

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




contract FixedRateExchange is ReentrancyGuard, IFixedRateExchange {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    uint256 private constant BASE = 1e18;
    uint public constant MIN_FEE           = BASE / 1e4;
    uint public constant MAX_FEE           = 5e17;
    uint public constant MIN_RATE          = 1e10;

    address public router;
    
    struct Exchange {
        bool active;
        address exchangeOwner;
        address datatoken;
        address baseToken;
        uint256 fixedRate;
        uint256 dtDecimals;
        uint256 btDecimals;
        uint256 dtBalance;
        uint256 btBalance;
        uint256 marketFee;
        address marketFeeCollector;
        uint256 marketFeeAvailable;
        uint256 oceanFeeAvailable;
        bool withMint;
        address allowedSwapper;
    }

    mapping(bytes32 => Exchange) private exchanges;
    bytes32[] private exchangeIds;

    modifier onlyActiveExchange(bytes32 exchangeId) {

        require(
                exchanges[exchangeId].active,
            "FixedRateExchange: Exchange does not exist!"
        );
        _;
    }

    modifier onlyExchangeOwner(bytes32 exchangeId) {

        IERC20Template dt = IERC20Template(exchanges[exchangeId].datatoken);
        require(
            dt.isERC20Deployer(msg.sender) || 
            IERC721Template(dt.getERC721Address()).ownerOf(1) == msg.sender
            ,
            "FixedRateExchange: invalid exchange owner"
        );
        _;
    }

    modifier onlyRouter() {

        require(msg.sender == router, "FixedRateExchange: only router");
        _;
    }

    event ExchangeCreated(
        bytes32 indexed exchangeId,
        address indexed baseToken,
        address indexed datatoken,
        address exchangeOwner,
        uint256 fixedRate
    );

    event ExchangeRateChanged(
        bytes32 indexed exchangeId,
        address indexed exchangeOwner,
        uint256 newRate
    );

    event ExchangeMintStateChanged(
        bytes32 indexed exchangeId,
        address indexed exchangeOwner,
        bool withMint
    );
    
    event ExchangeActivated(
        bytes32 indexed exchangeId,
        address indexed exchangeOwner
    );

    event ExchangeDeactivated(
        bytes32 indexed exchangeId,
        address indexed exchangeOwner
    );

    event ExchangeAllowedSwapperChanged(
        bytes32 indexed exchangeId,
        address indexed allowedSwapper
    );
    
    event Swapped(
        bytes32 indexed exchangeId,
        address indexed by,
        uint256 baseTokenSwappedAmount,
        uint256 datatokenSwappedAmount,
        address tokenOutAddress,
        uint256 marketFeeAmount,
        uint256 oceanFeeAmount,
        uint256 consumeMarketFeeAmount
    );

    event TokenCollected(
        bytes32 indexed exchangeId,
        address indexed to,
        address indexed token,
        uint256 amount
    );

    event OceanFeeCollected(
        bytes32 indexed exchangeId,
        address indexed feeToken,
        uint256 feeAmount
    );
    event MarketFeeCollected(
        bytes32 indexed exchangeId,
        address indexed feeToken,
        uint256 feeAmount
    );
    event ConsumeMarketFee(
        bytes32 indexed exchangeId,
        address to,
        address token,
        uint256 amount);
    event SWAP_FEES(
        bytes32 indexed exchangeId,
        uint oceanFeeAmount,
        uint marketFeeAmount,
        uint consumeMarketFeeAmount,
        address tokenFeeAddress);
    event PublishMarketFeeChanged(
        bytes32 indexed exchangeId,
        address caller,
        address newMarketCollector,
        uint256 swapFee);


    constructor(address _router) {
        require(_router != address(0), "FixedRateExchange: Wrong Router address");
        router = _router;
    }

    function getId() pure public returns (uint8) {

        return 1;
    }
    
    function getOPCFee(address baseTokenAddress) public view returns (uint) {

        return IFactoryRouter(router).getOPCFee(baseTokenAddress);
    }
  

    function createWithDecimals(
        address datatoken,
        address[] memory addresses, 
        uint256[] memory uints 
    ) external onlyRouter returns (bytes32 exchangeId) {

       require(uints.length >=5, 'Invalid uints length');
       require(addresses.length >=4, 'Invalid addresses length');
        require(
            addresses[0] != address(0),
            "FixedRateExchange: Invalid baseToken,  zero address"
        );
        require(
            datatoken != address(0),
            "FixedRateExchange: Invalid datatoken,  zero address"
        );
        require(
            addresses[0] != datatoken,
            "FixedRateExchange: Invalid datatoken,  equals baseToken"
        );
        require(
            uints[2] >= MIN_RATE,
            "FixedRateExchange: Invalid exchange rate value"
        );
        exchangeId = generateExchangeId(addresses[0], datatoken);
        require(
            exchanges[exchangeId].fixedRate == 0,
            "FixedRateExchange: Exchange already exists!"
        );
        bool withMint=true;
        if(uints[4] == 0) withMint = false;
        exchanges[exchangeId] = Exchange({
            active: true,
            exchangeOwner: addresses[1],
            datatoken: datatoken,
            baseToken: addresses[0],
            fixedRate: uints[2],
            dtDecimals: uints[1],
            btDecimals: uints[0],
            dtBalance: 0,
            btBalance: 0,
            marketFee: uints[3],
            marketFeeCollector: addresses[2],
            marketFeeAvailable: 0,
            oceanFeeAvailable: 0,
            withMint: withMint,
            allowedSwapper: addresses[3]
        });
        require(uints[3] ==0 || uints[3] >= MIN_FEE,'SwapFee too low');
        require(uints[3] <= MAX_FEE,'SwapFee too high');
        exchangeIds.push(exchangeId);

        emit ExchangeCreated(
            exchangeId,
            addresses[0], // 
            datatoken,
            addresses[1],
            uints[2]
        );

        emit ExchangeActivated(exchangeId, addresses[1]);
        emit ExchangeAllowedSwapperChanged(exchangeId, addresses[3]);
        emit PublishMarketFeeChanged(exchangeId,msg.sender, addresses[2], uints[3]);
    }

    function generateExchangeId(
        address baseToken,
        address datatoken
    ) public pure returns (bytes32) {

        return keccak256(abi.encode(baseToken, datatoken));
    }

    struct Fees{
            uint256 baseTokenAmount;
            uint256 oceanFeeAmount;
            uint256 publishMarketFeeAmount;
            uint256 consumeMarketFeeAmount;
    }
        
    function _getBaseTokenOutPrice(bytes32 exchangeId, uint256 datatokenAmount) 
    internal view returns (uint256 baseTokenAmount){

        baseTokenAmount = datatokenAmount
            .mul(exchanges[exchangeId].fixedRate)
            .mul(10**exchanges[exchangeId].btDecimals)
            .div(10**exchanges[exchangeId].dtDecimals)
            .div(BASE);
    }
    function calcBaseInGivenOutDT(bytes32 exchangeId, uint256 datatokenAmount, uint256 consumeMarketSwapFeeAmount)
        public
        view
        onlyActiveExchange(exchangeId)
        returns (
            uint256 baseTokenAmount,
            uint256 oceanFeeAmount,
            uint256 publishMarketFeeAmount,
            uint256 consumeMarketFeeAmount
        )


    {

        uint256 baseTokenAmountBeforeFee = _getBaseTokenOutPrice(exchangeId, datatokenAmount);
        Fees memory fee = Fees(0,0,0,0);
        uint256 opcFee = getOPCFee(exchanges[exchangeId].baseToken);
        if (opcFee != 0) {
            fee.oceanFeeAmount = baseTokenAmountBeforeFee
                .mul(opcFee)
                .div(BASE);
        }
        else
            fee.oceanFeeAmount = 0;

        if( exchanges[exchangeId].marketFee !=0){
            fee.publishMarketFeeAmount = baseTokenAmountBeforeFee
            .mul(exchanges[exchangeId].marketFee)
            .div(BASE);
        }
        else{
            fee.publishMarketFeeAmount = 0;
        }

        if( consumeMarketSwapFeeAmount !=0){
            fee.consumeMarketFeeAmount = baseTokenAmountBeforeFee
            .mul(consumeMarketSwapFeeAmount)
            .div(BASE);
        }
        else{
            fee.consumeMarketFeeAmount = 0;
        }
       
        
        fee.baseTokenAmount = baseTokenAmountBeforeFee.add(fee.publishMarketFeeAmount)
            .add(fee.oceanFeeAmount).add(fee.consumeMarketFeeAmount);
      
        return(fee.baseTokenAmount,fee.oceanFeeAmount,fee.publishMarketFeeAmount,fee.consumeMarketFeeAmount);
    }

    
    function calcBaseOutGivenInDT(bytes32 exchangeId, uint256 datatokenAmount, uint256 consumeMarketSwapFeeAmount)
        public
        view
        onlyActiveExchange(exchangeId)
        returns (
            uint256 baseTokenAmount,
            uint256 oceanFeeAmount,
            uint256 publishMarketFeeAmount,
            uint256 consumeMarketFeeAmount
        )
    {

        uint256 baseTokenAmountBeforeFee = _getBaseTokenOutPrice(exchangeId, datatokenAmount);

        Fees memory fee = Fees(0,0,0,0);
        uint256 opcFee = getOPCFee(exchanges[exchangeId].baseToken);
        if (opcFee != 0) {
            fee.oceanFeeAmount = baseTokenAmountBeforeFee
                .mul(opcFee)
                .div(BASE);
        }
        else fee.oceanFeeAmount=0;
      
        if(exchanges[exchangeId].marketFee !=0 ){
            fee.publishMarketFeeAmount = baseTokenAmountBeforeFee
                .mul(exchanges[exchangeId].marketFee)
                .div(BASE);
        }
        else{
            fee.publishMarketFeeAmount = 0;
        }

        if( consumeMarketSwapFeeAmount !=0){
            fee.consumeMarketFeeAmount = baseTokenAmountBeforeFee
                .mul(consumeMarketSwapFeeAmount)
                .div(BASE);
        }
        else{
            fee.consumeMarketFeeAmount = 0;
        }

        fee.baseTokenAmount = baseTokenAmountBeforeFee.sub(fee.publishMarketFeeAmount)
            .sub(fee.oceanFeeAmount).sub(fee.consumeMarketFeeAmount);
        return(fee.baseTokenAmount,fee.oceanFeeAmount,fee.publishMarketFeeAmount,fee.consumeMarketFeeAmount);
    }

    
    function buyDT(bytes32 exchangeId, uint256 datatokenAmount, uint256 maxBaseTokenAmount,
        address consumeMarketAddress, uint256 consumeMarketSwapFeeAmount)
        external
        onlyActiveExchange(exchangeId)
        nonReentrant
    {

        require(
            datatokenAmount != 0,
            "FixedRateExchange: zero datatoken amount"
        );
        require(consumeMarketSwapFeeAmount ==0 || consumeMarketSwapFeeAmount >= MIN_FEE,'ConsumeSwapFee too low');
        require(consumeMarketSwapFeeAmount <= MAX_FEE,'ConsumeSwapFee too high');
        if(exchanges[exchangeId].allowedSwapper != address(0)){
            require(
                exchanges[exchangeId].allowedSwapper == msg.sender,
                "FixedRateExchange: This address is not allowed to swap"
            );
        }
        if(consumeMarketAddress == address(0)) consumeMarketSwapFeeAmount=0; 
        Fees memory fee = Fees(0,0,0,0);
        (fee.baseTokenAmount,
            fee.oceanFeeAmount,
            fee.publishMarketFeeAmount,
            fee.consumeMarketFeeAmount
        )
         = calcBaseInGivenOutDT(exchangeId, datatokenAmount, consumeMarketSwapFeeAmount);
        require(
            fee.baseTokenAmount <= maxBaseTokenAmount,
            "FixedRateExchange: Too many base tokens"
        );
        exchanges[exchangeId].oceanFeeAvailable = exchanges[exchangeId]
            .oceanFeeAvailable
            .add(fee.oceanFeeAmount);
        exchanges[exchangeId].marketFeeAvailable = exchanges[exchangeId]
            .marketFeeAvailable
            .add(fee.publishMarketFeeAmount);
        _pullUnderlying(exchanges[exchangeId].baseToken,msg.sender,
                address(this),
                fee.baseTokenAmount);
        uint256 baseTokenAmountBeforeFee = fee.baseTokenAmount.sub(fee.oceanFeeAmount).
            sub(fee.publishMarketFeeAmount).sub(fee.consumeMarketFeeAmount);
        exchanges[exchangeId].btBalance = (exchanges[exchangeId].btBalance).add(
            baseTokenAmountBeforeFee
        );

        if (datatokenAmount > exchanges[exchangeId].dtBalance) {
            if(exchanges[exchangeId].withMint 
            && IERC20Template(exchanges[exchangeId].datatoken).isMinter(address(this)))
            {
                IERC20Template(exchanges[exchangeId].datatoken).mint(msg.sender,datatokenAmount);
            }
            else{
                    _pullUnderlying(exchanges[exchangeId].datatoken,exchanges[exchangeId].exchangeOwner,
                    msg.sender,
                    datatokenAmount);
            }
        } else {
            exchanges[exchangeId].dtBalance = (exchanges[exchangeId].dtBalance)
                .sub(datatokenAmount);
            IERC20(exchanges[exchangeId].datatoken).safeTransfer(
                msg.sender,
                datatokenAmount
            );
        }
        if(consumeMarketAddress!= address(0) && fee.consumeMarketFeeAmount>0){
            IERC20(exchanges[exchangeId].baseToken).safeTransfer(consumeMarketAddress, fee.consumeMarketFeeAmount);
            emit ConsumeMarketFee(
                exchangeId,
                consumeMarketAddress,
                exchanges[exchangeId].baseToken,
                fee.consumeMarketFeeAmount);
        }
        emit Swapped(
            exchangeId,
            msg.sender,
            fee.baseTokenAmount,
            datatokenAmount,
            exchanges[exchangeId].datatoken,
            fee.publishMarketFeeAmount,
            fee.oceanFeeAmount,
            fee.consumeMarketFeeAmount
        );
    }


    function sellDT(bytes32 exchangeId, uint256 datatokenAmount,
    uint256 minBaseTokenAmount, address consumeMarketAddress, uint256 consumeMarketSwapFeeAmount)
        external
        onlyActiveExchange(exchangeId)
        nonReentrant
    {

        require(
            datatokenAmount != 0,
            "FixedRateExchange: zero datatoken amount"
        );
        require(consumeMarketSwapFeeAmount ==0 || consumeMarketSwapFeeAmount >= MIN_FEE,'ConsumeSwapFee too low');
        require(consumeMarketSwapFeeAmount <= MAX_FEE,'ConsumeSwapFee too high');
        if(exchanges[exchangeId].allowedSwapper != address(0)){
            require(
                exchanges[exchangeId].allowedSwapper == msg.sender,
                "FixedRateExchange: This address is not allowed to swap"
            );
        }
        Fees memory fee = Fees(0,0,0,0);
        if(consumeMarketAddress == address(0)) consumeMarketSwapFeeAmount=0; 
        (fee.baseTokenAmount,
            fee.oceanFeeAmount,
            fee.publishMarketFeeAmount,
            fee.consumeMarketFeeAmount
        ) = calcBaseOutGivenInDT(exchangeId, datatokenAmount, consumeMarketSwapFeeAmount);
        require(
            fee.baseTokenAmount >= minBaseTokenAmount,
            "FixedRateExchange: Too few base tokens"
        );
        exchanges[exchangeId].oceanFeeAvailable = exchanges[exchangeId]
            .oceanFeeAvailable
            .add(fee.oceanFeeAmount);
        exchanges[exchangeId].marketFeeAvailable = exchanges[exchangeId]
            .marketFeeAvailable
            .add(fee.publishMarketFeeAmount);
        uint256 baseTokenAmountWithFees = fee.baseTokenAmount.add(fee.oceanFeeAmount)
            .add(fee.publishMarketFeeAmount).add(fee.consumeMarketFeeAmount);
        _pullUnderlying(exchanges[exchangeId].datatoken,msg.sender,
                address(this),
                datatokenAmount);
        exchanges[exchangeId].dtBalance = (exchanges[exchangeId].dtBalance).add(
            datatokenAmount
        );
        if (baseTokenAmountWithFees > exchanges[exchangeId].btBalance) {
                _pullUnderlying(exchanges[exchangeId].baseToken,exchanges[exchangeId].exchangeOwner,
                    address(this),
                    baseTokenAmountWithFees);
                IERC20(exchanges[exchangeId].baseToken).safeTransfer(
                    msg.sender,
                    fee.baseTokenAmount);
        } else {
            exchanges[exchangeId].btBalance = (exchanges[exchangeId].btBalance)
                .sub(baseTokenAmountWithFees);
            IERC20(exchanges[exchangeId].baseToken).safeTransfer(
                msg.sender,
                fee.baseTokenAmount
            );
        }
        if(consumeMarketAddress!= address(0) && fee.consumeMarketFeeAmount>0){
            IERC20(exchanges[exchangeId].baseToken).safeTransfer(consumeMarketAddress, fee.consumeMarketFeeAmount);    
             emit ConsumeMarketFee(
                exchangeId,
                consumeMarketAddress,
                exchanges[exchangeId].baseToken,
                fee.consumeMarketFeeAmount);
        }
        emit Swapped(
            exchangeId,
            msg.sender,
            fee.baseTokenAmount,
            datatokenAmount,
            exchanges[exchangeId].baseToken,
            fee.publishMarketFeeAmount,
            fee.oceanFeeAmount,
            fee.consumeMarketFeeAmount
        );
    }

    function collectBT(bytes32 exchangeId, uint256 amount) public
        nonReentrant
    {

        _collectBT(exchangeId, amount);
    }

    function _collectBT(bytes32 exchangeId, uint256 amount) internal{

        require(amount <= exchanges[exchangeId].btBalance, "Amount too high");
        address destination = IERC20Template(exchanges[exchangeId].datatoken).getPaymentCollector();
        exchanges[exchangeId].btBalance = exchanges[exchangeId].btBalance.sub(amount);
        emit TokenCollected(
            exchangeId,
            destination,
            exchanges[exchangeId].baseToken,
            amount
        );
        IERC20(exchanges[exchangeId].baseToken).safeTransfer(
            destination,
            amount
        );
    }
    function collectDT(bytes32 exchangeId, uint256 amount) public
        nonReentrant
    {

        _collectDT(exchangeId, amount);
    }
    function _collectDT(bytes32 exchangeId, uint256 amount) internal {

        require(amount <= exchanges[exchangeId].dtBalance, "Amount too high");
        address destination = IERC20Template(exchanges[exchangeId].datatoken).getPaymentCollector();
        exchanges[exchangeId].dtBalance = exchanges[exchangeId].dtBalance.sub(amount);
        emit TokenCollected(
            exchangeId,
            destination,
            exchanges[exchangeId].datatoken,
            amount
        );
        IERC20(exchanges[exchangeId].datatoken).safeTransfer(
            destination,
            amount
        );
    }

    function collectMarketFee(bytes32 exchangeId) public nonReentrant {

        _collectMarketFee(exchangeId);
    }

    function _collectMarketFee(bytes32 exchangeId) internal {

        uint256 amount = exchanges[exchangeId].marketFeeAvailable;
        exchanges[exchangeId].marketFeeAvailable = 0;
        emit MarketFeeCollected(
            exchangeId,
            exchanges[exchangeId].baseToken,
            amount
        );
        IERC20(exchanges[exchangeId].baseToken).safeTransfer(
            exchanges[exchangeId].marketFeeCollector,
            amount
        );
        
    }

    function collectOceanFee(bytes32 exchangeId) public nonReentrant {

        _collectOceanFee(exchangeId);
        
    }
    function _collectOceanFee(bytes32 exchangeId) internal {

        uint256 amount = exchanges[exchangeId].oceanFeeAvailable;
        exchanges[exchangeId].oceanFeeAvailable = 0;
        IERC20(exchanges[exchangeId].baseToken).safeTransfer(
            IFactoryRouter(router).getOPCCollector(),
            amount
        );
        emit OceanFeeCollected(
            exchangeId,
            exchanges[exchangeId].baseToken,
            amount
        );
    }

    function updateMarketFeeCollector(
        bytes32 exchangeId,
        address _newMarketCollector
    ) external {

        require(
            msg.sender == exchanges[exchangeId].marketFeeCollector,
            "not marketFeeCollector"
        );
        exchanges[exchangeId].marketFeeCollector = _newMarketCollector;
        emit PublishMarketFeeChanged(exchangeId, msg.sender, _newMarketCollector, exchanges[exchangeId].marketFee);
    }

    function updateMarketFee(
        bytes32 exchangeId,
        uint256 _newMarketFee
    ) external {

        require(
            msg.sender == exchanges[exchangeId].marketFeeCollector,
            "not marketFeeCollector"
        );
        require(_newMarketFee ==0 || _newMarketFee >= MIN_FEE,'SwapFee too low');
        require(_newMarketFee <= MAX_FEE,'SwapFee too high');
        exchanges[exchangeId].marketFee = _newMarketFee;
        emit PublishMarketFeeChanged(exchangeId, msg.sender, exchanges[exchangeId].marketFeeCollector, _newMarketFee);
    }

    function getMarketFee(bytes32 exchangeId) view public returns(uint256){

        return(exchanges[exchangeId].marketFee);
    }

    function getNumberOfExchanges() external view returns (uint256) {

        return exchangeIds.length;
    }

    function setRate(bytes32 exchangeId, uint256 newRate)
        external
        onlyExchangeOwner(exchangeId)
    {

        require(
            newRate >= MIN_RATE,
            "FixedRateExchange: Invalid exchange rate value"
        );
        exchanges[exchangeId].fixedRate = newRate;
        emit ExchangeRateChanged(exchangeId, msg.sender, newRate);
    }

    function toggleMintState(bytes32 exchangeId, bool withMint)
        external
        onlyExchangeOwner(exchangeId)
    {

        exchanges[exchangeId].withMint = 
            _checkAllowedWithMint(exchanges[exchangeId].exchangeOwner, exchanges[exchangeId].datatoken,withMint);
        emit ExchangeMintStateChanged(exchangeId, msg.sender, withMint);
    }

    function _checkAllowedWithMint(address owner, address datatoken, bool withMint) internal view returns(bool){

            if(withMint == false) return false;
            IERC721Template nft = IERC721Template(IERC20Template(datatoken).getERC721Address());
            IERC721Template.Roles memory roles = nft.getPermissions(owner);
            if(roles.manager == true || roles.deployERC20 == true || nft.ownerOf(1) == owner)
                return true;
            else
                return false;
    }

    function toggleExchangeState(bytes32 exchangeId)
        external
        onlyExchangeOwner(exchangeId)
    {

        if (exchanges[exchangeId].active) {
            exchanges[exchangeId].active = false;
            emit ExchangeDeactivated(exchangeId, msg.sender);
        } else {
            exchanges[exchangeId].active = true;
            emit ExchangeActivated(exchangeId, msg.sender);
        }
    }

    function setAllowedSwapper(bytes32 exchangeId, address newAllowedSwapper) external
    onlyExchangeOwner(exchangeId)
    {

        exchanges[exchangeId].allowedSwapper = newAllowedSwapper;
        emit ExchangeAllowedSwapperChanged(exchangeId, newAllowedSwapper);
    }
    function getRate(bytes32 exchangeId) external view returns (uint256) {

        return exchanges[exchangeId].fixedRate;
    }

    function getDTSupply(bytes32 exchangeId)
        public
        view
        returns (uint256 supply)
    {

        if (exchanges[exchangeId].active == false) supply = 0;
        else if (exchanges[exchangeId].withMint
        && IERC20Template(exchanges[exchangeId].datatoken).isMinter(address(this))){
            supply = IERC20Template(exchanges[exchangeId].datatoken).cap() 
            - IERC20Template(exchanges[exchangeId].datatoken).totalSupply();
        }
        else {
            uint256 balance = IERC20Template(exchanges[exchangeId].datatoken)
                .balanceOf(exchanges[exchangeId].exchangeOwner);
            uint256 allowance = IERC20Template(exchanges[exchangeId].datatoken)
                .allowance(exchanges[exchangeId].exchangeOwner, address(this));
            if (balance < allowance)
                supply = balance.add(exchanges[exchangeId].dtBalance);
            else supply = allowance.add(exchanges[exchangeId].dtBalance);
        }
    }

    function getBTSupply(bytes32 exchangeId)
        public
        view
        returns (uint256 supply)
    {

        if (exchanges[exchangeId].active == false) supply = 0;
        else {
            uint256 balance = IERC20Template(exchanges[exchangeId].baseToken)
                .balanceOf(exchanges[exchangeId].exchangeOwner);
            uint256 allowance = IERC20Template(exchanges[exchangeId].baseToken)
                .allowance(exchanges[exchangeId].exchangeOwner, address(this));
            if (balance < allowance)
                supply = balance.add(exchanges[exchangeId].btBalance);
            else supply = allowance.add(exchanges[exchangeId].btBalance);
        }
    }

    function getExchange(bytes32 exchangeId)
        external
        view
        returns (
            address exchangeOwner,
            address datatoken,
            uint256 dtDecimals,
            address baseToken,
            uint256 btDecimals,
            uint256 fixedRate,
            bool active,
            uint256 dtSupply,
            uint256 btSupply,
            uint256 dtBalance,
            uint256 btBalance,
            bool withMint
        )
    {

        exchangeOwner = exchanges[exchangeId].exchangeOwner;
        datatoken = exchanges[exchangeId].datatoken;
        dtDecimals = exchanges[exchangeId].dtDecimals;
        baseToken = exchanges[exchangeId].baseToken;
        btDecimals = exchanges[exchangeId].btDecimals;
        fixedRate = exchanges[exchangeId].fixedRate;
        active = exchanges[exchangeId].active;
        dtSupply = getDTSupply(exchangeId);
        btSupply = getBTSupply(exchangeId);
        dtBalance = exchanges[exchangeId].dtBalance;
        btBalance = exchanges[exchangeId].btBalance;
        withMint = exchanges[exchangeId].withMint;
    }

    function getAllowedSwapper(bytes32 exchangeId)
        external
        view
        returns (
            address allowedSwapper
        )
    {

        Exchange memory exchange = exchanges[exchangeId];
        allowedSwapper = exchange.allowedSwapper;
    }

    function getFeesInfo(bytes32 exchangeId)
        external
        view
        returns (
            uint256 marketFee,
            address marketFeeCollector,
            uint256 opcFee,
            uint256 marketFeeAvailable,
            uint256 oceanFeeAvailable
        )
    {

        Exchange memory exchange = exchanges[exchangeId];
        marketFee = exchange.marketFee;
        marketFeeCollector = exchange.marketFeeCollector;
        opcFee = getOPCFee(exchanges[exchangeId].baseToken);
        marketFeeAvailable = exchange.marketFeeAvailable;
        oceanFeeAvailable = exchange.oceanFeeAvailable;
    }

    function getExchanges() external view returns (bytes32[] memory) {

        return exchangeIds;
    }

    function isActive(bytes32 exchangeId) external view returns (bool) {

        return exchanges[exchangeId].active;
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