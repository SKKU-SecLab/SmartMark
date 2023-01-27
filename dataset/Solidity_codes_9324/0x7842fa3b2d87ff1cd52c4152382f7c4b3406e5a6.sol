

pragma solidity 0.8.12;

interface ISideStaking {



    function newDatatokenCreated(
        address datatokenAddress,
        address baseTokenAddress,
        address poolAddress,
        address publisherAddress,
        uint256[] calldata ssParams
    ) external returns (bool);


    function getDatatokenCirculatingSupply(address datatokenAddress)
        external
        view
        returns (uint256);


    function getPublisherAddress(address datatokenAddress)
        external
        view
        returns (address);


    function getBaseTokenAddress(address datatokenAddress)
        external
        view
        returns (address);


    function getPoolAddress(address datatokenAddress)
        external
        view
        returns (address);


    function getBaseTokenBalance(address datatokenAddress)
        external
        view
        returns (uint256);


    function getDatatokenBalance(address datatokenAddress)
        external
        view
        returns (uint256);


    function getvestingEndBlock(address datatokenAddress)
        external
        view
        returns (uint256);


    function getvestingAmount(address datatokenAddress)
        external
        view
        returns (uint256);


    function getvestingLastBlock(address datatokenAddress)
        external
        view
        returns (uint256);


    function getvestingAmountSoFar(address datatokenAddress)
        external
        view
        returns (uint256);




    function canStake(
        address datatokenAddress,
        uint256 amount
    ) external view returns (bool);


    function Stake(
        address datatokenAddress,
        uint256 amount
    ) external;


    function canUnStake(
        address datatokenAddress,
        uint256 amount
    ) external view returns (bool);


    function UnStake(
        address datatokenAddress,
        uint256 amount,
        uint256 poolAmountIn
    ) external;


    function getId() pure external returns (uint8);


  
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

}// This program is distributed in the hope that it will be useful,


pragma solidity 0.8.12;

interface IPool {

    function getDatatokenAddress() external view returns (address);


    function getBaseTokenAddress() external view returns (address);


    function getController() external view returns (address);


    function setup(
        address datatokenAddress,
        uint256 datatokenAmount,
        uint256 datatokennWeight,
        address baseTokenAddress,
        uint256 baseTokenAmount,
        uint256 baseTokenWeight
    ) external;


    function swapExactAmountIn(
        address[3] calldata tokenInOutMarket, //[tokenIn,tokenOut,marketFeeAddress]
        uint256[4] calldata amountsInOutMaxFee //[tokenAmountIn,minAmountOut,maxPrice,_swapMarketFee]
    ) external returns (uint256 tokenAmountOut, uint256 spotPriceAfter);


    function swapExactAmountOut(
        address[3] calldata tokenInOutMarket, // [tokenIn,tokenOut,marketFeeAddress]
        uint256[4] calldata amountsInOutMaxFee // [maxAmountIn,tokenAmountOut,maxPrice,_swapMarketFee]
    ) external returns (uint256 tokenAmountIn, uint256 spotPriceAfter);


    function getAmountInExactOut(
        address tokenIn,
        address tokenOut,
        uint256 tokenAmountOut,
        uint256 _consumeMarketSwapFee
    ) external view returns (uint256, uint256, uint256, uint256, uint256);


    function getAmountOutExactIn(
        address tokenIn,
        address tokenOut,
        uint256 tokenAmountIn,
        uint256 _consumeMarketSwapFee
    ) external view returns (uint256, uint256, uint256, uint256, uint256);


    function setSwapFee(uint256 swapFee) external;

    function getId() pure external returns (uint8);


    function exitswapPoolAmountIn(
        uint256 poolAmountIn,
        uint256 minAmountOut
    ) external returns (uint256 tokenAmountOut);

    
    function joinswapExternAmountIn(
        uint256 tokenAmountIn,
        uint256 minPoolAmountOut
    ) external returns (uint256 poolAmountOut);

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


contract SideStaking is ReentrancyGuard, ISideStaking {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    address public router;

    event VestingCreated(
        address indexed datatokenAddress,
        address indexed publisherAddress,
        uint256 vestingEndBlock,
        uint256 totalVestingAmount
    );
    event Vesting(
        address indexed datatokenAddress,
        address indexed publisherAddress,
        address indexed caller,
        uint256 amountVested
    );

    struct Record {
        bool bound; //datatoken bounded
        address baseTokenAddress;
        address poolAddress;
        bool poolFinalized; // did we finalized the pool ? We have to do it after burn-in
        uint256 datatokenBalance; //current dt balance
        uint256 datatokenCap; //dt cap
        uint256 baseTokenBalance; //current baseToken balance
        uint256 lastPrice; //used for creating the pool
        uint256 rate; // rate to exchange DT<->baseToken
        address publisherAddress;
        uint256 blockDeployed; //when this record was created
        uint256 vestingEndBlock; //see below
        uint256 vestingAmount; // total amount to be vested to publisher until vestingEndBlock
        uint256 vestingLastBlock; //last block in which a vesting has been granted
        uint256 vestingAmountSoFar; //how much was vested so far
    }

    mapping(address => Record) private _datatokens;
    uint256 private constant BASE = 1e18;

    modifier onlyRouter() {

        require(msg.sender == router, "ONLY ROUTER");
        _;
    }

    modifier onlyOwner(address datatoken) {

        require(
            datatoken != address(0),
            'Invalid token contract address'
        );
        IERC20Template dt = IERC20Template(datatoken);
        require(
            dt.isERC20Deployer(msg.sender) || 
            IERC721Template(dt.getERC721Address()).ownerOf(1) == msg.sender
            ,
            "Invalid owner"
        );
        _;
    }
    constructor(address _router) {
        require(_router != address(0), "Invalid _router address");
        router = _router;
    }

    function getId() public pure returns (uint8) {

        return 1;
    }


    function newDatatokenCreated(
        address datatokenAddress,
        address baseTokenAddress,
        address poolAddress,
        address publisherAddress,
        uint256[] memory ssParams
    ) external onlyRouter nonReentrant returns (bool) {

        require(poolAddress != address(0), "Invalid poolAddress");
        IPool bpool = IPool(poolAddress);
        require(
            bpool.getController() == address(this),
            "We are not the pool controller"
        );
        require(
            bpool.getDatatokenAddress() == datatokenAddress,
            "Datatoken address missmatch"
        );
        require(
            bpool.getBaseTokenAddress() == baseTokenAddress,
            "baseToken address missmatch"
        );
        require(ssParams[0]>1e12 , "Invalid rate");
        IERC20Template dt = IERC20Template(datatokenAddress);
        require(
            (dt.permissions(address(this))).minter,
            "baseToken address mismatch"
        );
        dt.mint(address(this), dt.cap());

        require(dt.balanceOf(address(this)) >= dt.totalSupply(), "Mint failed");

        ssParams[2] = 0;
        ssParams[3] = 0;
        require(dt.totalSupply().div(10) >= ssParams[2], "Max vesting 10%");
        _datatokens[datatokenAddress] = Record({
            bound: true,
            baseTokenAddress: baseTokenAddress,
            poolAddress: poolAddress,
            poolFinalized: false,
            datatokenBalance: dt.totalSupply(),
            datatokenCap: dt.cap(),
            baseTokenBalance: ssParams[4],
            lastPrice: 0,
            rate: ssParams[0],
            publisherAddress: publisherAddress,
            blockDeployed: block.number,
            vestingEndBlock: block.number + ssParams[3],
            vestingAmount: ssParams[2],
            vestingLastBlock: block.number,
            vestingAmountSoFar: 0
        });
        emit VestingCreated(
            datatokenAddress,
            publisherAddress,
            _datatokens[datatokenAddress].vestingEndBlock,
            _datatokens[datatokenAddress].vestingAmount
        );

        _notifyFinalize(datatokenAddress, ssParams[1]);

        return (true);
    }


    function getDatatokenCirculatingSupply(address datatokenAddress)
        external
        view
        returns (uint256)
    {

        if (!_datatokens[datatokenAddress].bound) return (0);
        return (_datatokens[datatokenAddress].datatokenCap -
            _datatokens[datatokenAddress].datatokenBalance);
    }


    function getDatatokenCurrentCirculatingSupply(address datatokenAddress)
        external
        view
        returns (uint256)
    {

        if (!_datatokens[datatokenAddress].bound) return (0);
        return (_datatokens[datatokenAddress].datatokenCap -
            _datatokens[datatokenAddress].datatokenBalance -
            _datatokens[datatokenAddress].vestingAmountSoFar);
    }


    function getPublisherAddress(address datatokenAddress)
        external
        view
        returns (address)
    {

        if (!_datatokens[datatokenAddress].bound) return (address(0));
        return (_datatokens[datatokenAddress].publisherAddress);
    }


    function getBaseTokenAddress(address datatokenAddress)
        external
        view
        returns (address)
    {

        if (!_datatokens[datatokenAddress].bound) return (address(0));
        return (_datatokens[datatokenAddress].baseTokenAddress);
    }


    function getPoolAddress(address datatokenAddress)
        external
        view
        returns (address)
    {

        if (!_datatokens[datatokenAddress].bound) return (address(0));
        return (_datatokens[datatokenAddress].poolAddress);
    }

    function getBaseTokenBalance(address datatokenAddress)
        external
        view
        returns (uint256)
    {

        if (!_datatokens[datatokenAddress].bound) return (0);
        return (_datatokens[datatokenAddress].baseTokenBalance);
    }


    function getDatatokenBalance(address datatokenAddress)
        external
        view
        returns (uint256)
    {

        if (!_datatokens[datatokenAddress].bound) return (0);
        return (_datatokens[datatokenAddress].datatokenBalance);
    }


    function getvestingEndBlock(address datatokenAddress)
        external
        view
        returns (uint256)
    {

        if (!_datatokens[datatokenAddress].bound) return (0);
        return (_datatokens[datatokenAddress].vestingEndBlock);
    }


    function getvestingAmount(address datatokenAddress)
        public
        view
        returns (uint256)
    {

        if (!_datatokens[datatokenAddress].bound) return (0);
        return (_datatokens[datatokenAddress].vestingAmount);
    }


    function getvestingLastBlock(address datatokenAddress)
        external
        view
        returns (uint256)
    {

        if (!_datatokens[datatokenAddress].bound) return (0);
        return (_datatokens[datatokenAddress].vestingLastBlock);
    }


    function getvestingAmountSoFar(address datatokenAddress)
        public
        view
        returns (uint256)
    {

        if (!_datatokens[datatokenAddress].bound) return (0);
        return (_datatokens[datatokenAddress].vestingAmountSoFar);
    }

    function canStake(address datatokenAddress, uint256 amount)
        public
        view
        returns (bool)
    {

        require(
            msg.sender == _datatokens[datatokenAddress].poolAddress,
            "ERR: Only pool can call this"
        );
        if (!_datatokens[datatokenAddress].bound) return (false);

        if (
            _datatokens[datatokenAddress].datatokenBalance >=
            (amount +
                (_datatokens[datatokenAddress].vestingAmount -
                    _datatokens[datatokenAddress].vestingAmountSoFar))
        ) return (true);
        return (false);
    }

    function Stake(address datatokenAddress, uint256 amount)
        external
        nonReentrant
    {

        if (!_datatokens[datatokenAddress].bound) return;
        require(
            msg.sender == _datatokens[datatokenAddress].poolAddress,
            "ERR: Only pool can call this"
        );
        bool ok = canStake(datatokenAddress, amount);
        if (!ok) return;
        IERC20 dt = IERC20(datatokenAddress);
        dt.safeIncreaseAllowance(
            _datatokens[datatokenAddress].poolAddress,
            amount
        );
        _datatokens[datatokenAddress].datatokenBalance -= amount;
    }

    function canUnStake(address datatokenAddress, uint256 lptIn)
        public
        view
        returns (bool)
    {

        if (!_datatokens[datatokenAddress].bound) return (false);
        require(
            msg.sender == _datatokens[datatokenAddress].poolAddress,
            "ERR: Only pool can call this"
        );

        if (IERC20(msg.sender).balanceOf(address(this)) >= lptIn) {
            return true;
        }
        return false;
    }

    function UnStake(
        address datatokenAddress,
        uint256 dtAmountIn,
        uint256 poolAmountOut
    ) external nonReentrant {

        if (!_datatokens[datatokenAddress].bound) return;
        require(
            msg.sender == _datatokens[datatokenAddress].poolAddress,
            "ERR: Only pool can call this"
        );
        bool ok = canUnStake(datatokenAddress, poolAmountOut);
        if (!ok) return;
        _datatokens[datatokenAddress].datatokenBalance += dtAmountIn;
    }

    function _notifyFinalize(address datatokenAddress, uint256 decimals)
        internal
    {

        if (!_datatokens[datatokenAddress].bound) return;
        if (_datatokens[datatokenAddress].poolFinalized) return;
        _datatokens[datatokenAddress].poolFinalized = true;
        uint256 baseTokenWeight = 5 * BASE; //pool weight: 50-50
        uint256 datatokenWeight = 5 * BASE; //pool weight: 50-50
        uint256 baseTokenAmount = _datatokens[datatokenAddress]
            .baseTokenBalance;

        uint256 datatokenAmount = (10**(18 - decimals))*_datatokens[datatokenAddress].rate *
            baseTokenAmount *
            datatokenWeight /
            baseTokenWeight /
            BASE;

        _datatokens[datatokenAddress].baseTokenBalance -= baseTokenAmount;
        _datatokens[datatokenAddress].datatokenBalance -= datatokenAmount;
        IERC20 dt = IERC20(datatokenAddress);
        dt.safeIncreaseAllowance(
            _datatokens[datatokenAddress].poolAddress,
            datatokenAmount
        );
        IERC20 dtBase = IERC20(_datatokens[datatokenAddress].baseTokenAddress);
        dtBase.safeIncreaseAllowance(
            _datatokens[datatokenAddress].poolAddress,
            baseTokenAmount
        );
        
        
        IPool pool = IPool(_datatokens[datatokenAddress].poolAddress);
        pool.setup(
            datatokenAddress,
            datatokenAmount,
            datatokenWeight,
            _datatokens[datatokenAddress].baseTokenAddress,
            baseTokenAmount,
            baseTokenWeight
        );
        IERC20 lPTokens = IERC20(_datatokens[datatokenAddress].poolAddress);
        uint256 lpBalance = lPTokens.balanceOf(address(this));
        lPTokens.safeTransfer(
            _datatokens[datatokenAddress].publisherAddress,
            lpBalance.div(2)
        );
    }

    function getAvailableVesting(address)
        public
        pure
        returns (uint256)
    {

        return 0;
    }

    function getVesting(address datatokenAddress) external nonReentrant {

        require(_datatokens[datatokenAddress].bound, "ERR:Invalid datatoken");
        uint256 amount = getAvailableVesting(datatokenAddress);
        if (
            amount > 0 &&
            _datatokens[datatokenAddress].datatokenBalance >= amount
        ) {
            IERC20Template dt = IERC20Template(datatokenAddress);
            _datatokens[datatokenAddress].vestingLastBlock = block.number;
            _datatokens[datatokenAddress].datatokenBalance -= amount;
            _datatokens[datatokenAddress].vestingAmountSoFar += amount;
            address collector = dt.getPaymentCollector();
            emit Vesting(
                datatokenAddress,
                collector,
                msg.sender,
                amount
            );
            dt.transfer(
                collector,
                amount
            );
            
        }
    }

    function setPoolSwapFee(
        address datatokenAddress,
        address poolAddress,
        uint256 swapFee
    ) external onlyOwner(datatokenAddress) nonReentrant {

        require(_datatokens[datatokenAddress].bound, "Invalid datatoken");
        require(poolAddress != address(0), "Invalid poolAddress");
        IPool bpool = IPool(poolAddress);
        require(
            bpool.getController() == address(this),
            "We are not the pool controller"
        );
        require(
            bpool.getDatatokenAddress() == datatokenAddress,
            "Datatoken address missmatch"
        );
        bpool.setSwapFee(swapFee);
    }
}