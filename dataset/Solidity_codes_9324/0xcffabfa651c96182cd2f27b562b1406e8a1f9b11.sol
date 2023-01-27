

pragma solidity ^0.5.0;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b != 0, errorMessage);
        return a % b;
    }
}


pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
    }

    function toPayable(address account) internal pure returns (address payable) {

        return address(uint160(account));
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call.value(amount)("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
}


pragma solidity ^0.5.0;




library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.5.0;

interface InterestRateInterface {


    function getInterestRate(uint dmmTokenId, uint totalSupply, uint activeSupply) external view returns (uint);


}




pragma solidity ^0.5.0;

interface IUnderlyingTokenValuator {


    function getTokenValue(address token, uint amount) external view returns (uint);


}


pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}




pragma solidity ^0.5.0;


contract Blacklistable is Ownable {


    string public constant BLACKLISTED = "BLACKLISTED";

    mapping(address => bool) internal blacklisted;

    event Blacklisted(address indexed account);
    event UnBlacklisted(address indexed account);
    event BlacklisterChanged(address indexed newBlacklister);

    modifier onlyBlacklister() {

        require(msg.sender == owner(), "MUST_BE_BLACKLISTER");
        _;
    }

    modifier notBlacklisted(address account) {

        require(blacklisted[account] == false, BLACKLISTED);
        _;
    }

    function checkNotBlacklisted(address account) public view {

        require(!blacklisted[account], BLACKLISTED);
    }

    function isBlacklisted(address account) public view returns (bool) {

        return blacklisted[account];
    }

    function blacklist(address account) public onlyBlacklister {

        blacklisted[account] = true;
        emit Blacklisted(account);
    }

    function unBlacklist(address account) public onlyBlacklister {

        blacklisted[account] = false;
        emit UnBlacklisted(account);
    }

}


pragma solidity ^0.5.0;




interface IDmmController {


    event TotalSupplyIncreased(uint oldTotalSupply, uint newTotalSupply);
    event TotalSupplyDecreased(uint oldTotalSupply, uint newTotalSupply);

    event AdminDeposit(address indexed sender, uint amount);
    event AdminWithdraw(address indexed receiver, uint amount);

    function addMarket(
        address underlyingToken,
        string calldata symbol,
        string calldata name,
        uint8 decimals,
        uint minMintAmount,
        uint minRedeemAmount,
        uint totalSupply
    ) external;


    function addMarketFromExistingDmmToken(
        address dmmToken,
        address underlyingToken
    ) external;


    function transferOwnershipToNewController(
        address newController
    ) external;


    function enableMarket(uint dmmTokenId) external;


    function disableMarket(uint dmmTokenId) external;


    function setGuardian(address newGuardian) external;


    function setDmmTokenFactory(address newDmmTokenFactory) external;


    function setDmmEtherFactory(address newDmmEtherFactory) external;


    function setInterestRateInterface(address newInterestRateInterface) external;


    function setOffChainAssetValuator(address newOffChainAssetValuator) external;


    function setOffChainCurrencyValuator(address newOffChainCurrencyValuator) external;


    function setUnderlyingTokenValuator(address newUnderlyingTokenValuator) external;


    function setMinCollateralization(uint newMinCollateralization) external;


    function setMinReserveRatio(uint newMinReserveRatio) external;


    function increaseTotalSupply(uint dmmTokenId, uint amount) external;


    function decreaseTotalSupply(uint dmmTokenId, uint amount) external;


    function adminWithdrawFunds(uint dmmTokenId, uint underlyingAmount) external;


    function adminDepositFunds(uint dmmTokenId, uint underlyingAmount) external;


    function getDmmTokenIds() external view returns (uint[] memory);


    function getTotalCollateralization() external view returns (uint);


    function getActiveCollateralization() external view returns (uint);


    function getInterestRateByUnderlyingTokenAddress(address underlyingToken) external view returns (uint);


    function getInterestRateByDmmTokenId(uint dmmTokenId) external view returns (uint);


    function getInterestRateByDmmTokenAddress(address dmmToken) external view returns (uint);


    function getExchangeRateByUnderlying(address underlyingToken) external view returns (uint);


    function getExchangeRate(address dmmToken) external view returns (uint);


    function getDmmTokenForUnderlying(address underlyingToken) external view returns (address);


    function getUnderlyingTokenForDmm(address dmmToken) external view returns (address);


    function isMarketEnabledByDmmTokenId(uint dmmTokenId) external view returns (bool);


    function isMarketEnabledByDmmTokenAddress(address dmmToken) external view returns (bool);


    function getTokenIdFromDmmTokenAddress(address dmmTokenAddress) external view returns (uint);


    function getDmmTokenAddressByDmmTokenId(uint dmmTokenId) external view returns (address);


    function blacklistable() external view returns (Blacklistable);


    function underlyingTokenValuator() external view returns (IUnderlyingTokenValuator);


}




pragma solidity ^0.5.0;

interface IERC20WithDecimals {


    function decimals() external view returns (uint8);


}



pragma solidity ^0.5.0;

interface IERC721TokenReceiver {


    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);


}




pragma solidity >=0.5.0;

interface IERC721 {


    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    event Approval(
        address indexed owner,
        address indexed operator,
        uint256 indexed tokenId
    );

    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes calldata _data
    )
    external;


    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external;


    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
    external;


    function approve(
        address _approved,
        uint256 _tokenId
    )
    external;


    function setApprovalForAll(
        address _operator,
        bool _approved
    )
    external;


    function balanceOf(
        address _owner
    )
    external
    view
    returns (uint256);


    function ownerOf(
        uint256 _tokenId
    )
    external
    view
    returns (address);


    function getApproved(
        uint256 _tokenId
    )
    external
    view
    returns (address);


    function isApprovedForAll(
        address _owner,
        address _operator
    )
    external
    view
    returns (bool);


}




pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

interface IAssetIntroducerStakingV1Initializable {


    function initialize(
        address owner,
        address guardian,
        address assetIntroducerProxy,
        address dmgIncentivesPool
    ) external;


    function initializeOwnables(
        address owner,
        address guardian
    ) external;


}


pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}




pragma solidity ^0.5.0;


contract IOwnableOrGuardian is Initializable {



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event GuardianTransferred(address indexed previousGuardian, address indexed newGuardian);


    modifier onlyOwnerOrGuardian {

        require(
            msg.sender == _owner || msg.sender == _guardian,
            "OwnableOrGuardian: UNAUTHORIZED_OWNER_OR_GUARDIAN"
        );
        _;
    }

    modifier onlyOwner {

        require(
            msg.sender == _owner,
            "OwnableOrGuardian: UNAUTHORIZED"
        );
        _;
    }

    address internal _owner;
    address internal _guardian;


    function owner() external view returns (address) {

        return _owner;
    }

    function guardian() external view returns (address) {

        return _guardian;
    }


    function initialize(
        address __owner,
        address __guardian
    )
    public
    initializer {

        _transferOwnership(__owner);
        _transferGuardian(__guardian);
    }

    function transferOwnership(
        address __owner
    )
    public
    onlyOwner {

        require(
            __owner != address(0),
            "OwnableOrGuardian::transferOwnership: INVALID_OWNER"
        );
        _transferOwnership(__owner);
    }

    function renounceOwnership() public onlyOwner {

        _transferOwnership(address(0));
    }

    function transferGuardian(
        address __guardian
    )
    public
    onlyOwner {

        require(
            __guardian != address(0),
            "OwnableOrGuardian::transferGuardian: INVALID_OWNER"
        );
        _transferGuardian(__guardian);
    }

    function renounceGuardian() public onlyOwnerOrGuardian {

        _transferGuardian(address(0));
    }


    function _transferOwnership(
        address __owner
    )
    internal {

        address previousOwner = _owner;
        _owner = __owner;
        emit OwnershipTransferred(previousOwner, __owner);
    }

    function _transferGuardian(
        address __guardian
    )
    internal {

        address previousGuardian = _guardian;
        _guardian = __guardian;
        emit GuardianTransferred(previousGuardian, __guardian);
    }

}




pragma solidity ^0.5.13;

interface IDMGToken {


    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    event DelegateChanged(address indexed delegator, address indexed fromDelegate, address indexed toDelegate);

    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);


    function getPriorVotes(address account, uint blockNumber) external view returns (uint128);


    function getCurrentVotes(address account) external view returns (uint128);


    function delegates(address delegator) external view returns (address);


    function burn(uint amount) external returns (bool);


    function approveBySig(
        address spender,
        uint rawAmount,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;


}




pragma solidity ^0.5.0;




contract AssetIntroducerData is Initializable, IOwnableOrGuardian {




    uint64 internal _guardCounter;

    AssetIntroducerStateV1 internal _assetIntroducerStateV1;

    ERC721StateV1 internal _erc721StateV1;

    VoteStateV1 internal _voteStateV1;


    enum AssetIntroducerType {
        PRINCIPAL, AFFILIATE
    }

    struct AssetIntroducerStateV1 {
        uint64 initTimestamp;

        bool isDmmFoundationSetup;

        uint128 totalDmgLocked;

        bytes32 domainSeparator;

        address dmg;

        address dmmController;

        address underlyingTokenValuator;

        address assetIntroducerDiscount;

        address stakingPurchaser;

        mapping(uint => AssetIntroducer) idToAssetIntroducer;

        mapping(bytes3 => mapping(uint8 => uint[])) countryCodeToAssetIntroducerTypeToTokenIdsMap;

        mapping(bytes3 => mapping(uint8 => uint96)) countryCodeToAssetIntroducerTypeToPriceUsd;

        mapping(uint => mapping(address => uint)) tokenIdToUnderlyingTokenToWithdrawnAmount;

        mapping(address => uint) ownerToNonceMap;
    }

    struct ERC721StateV1 {
        uint64 totalSupply;

        address openSeaProxyRegistry;

        uint lastTokenId;

        string baseURI;

        mapping(uint => uint) allTokens;

        mapping(uint256 => address) idToOwnerMap;

        mapping(uint256 => address) idToSpenderMap;

        mapping(address => mapping(address => bool)) ownerToOperatorToIsApprovedMap;

        mapping(address => mapping(uint => uint)) ownerToTokenIds;

        mapping(address => uint32) ownerToTokenCount;

        mapping(bytes4 => bool) interfaceIdToIsSupportedMap;
    }

    struct VoteStateV1 {
        mapping(address => mapping(uint64 => Checkpoint)) ownerToCheckpointIndexToCheckpointMap;
        mapping(address => uint64) ownerToCheckpointCountMap;
    }

    struct AssetIntroducer {
        bytes3 countryCode;
        AssetIntroducerType introducerType;
        bool isOnSecondaryMarket;
        bool isAllowedToWithdrawFunds;
        uint16 serialNumber;
        uint96 dmgLocked;
        uint96 dollarAmountToManage;
        uint tokenId;
    }

    struct Checkpoint {
        uint64 fromBlock;
        uint128 votes;
    }

    struct DmgApprovalStruct {
        address spender;
        uint rawAmount;
        uint nonce;
        uint expiry;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct DiscountStruct {
        uint64 initTimestamp;
    }


    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;

        _;

        require(
            localCounter == _guardCounter,
            "AssetIntroducerData: REENTRANCY"
        );
    }

    modifier requireIsPrimaryMarketNft(uint __tokenId) {

        require(
            !_assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isOnSecondaryMarket,
            "AssetIntroducerData: IS_SECONDARY_MARKET"
        );

        _;
    }

    modifier requireIsSecondaryMarketNft(uint __tokenId) {

        require(
            _assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isOnSecondaryMarket,
            "AssetIntroducerData: IS_PRIMARY_MARKET"
        );

        _;
    }

    modifier requireIsValidNft(uint __tokenId) {

        require(
            _erc721StateV1.idToOwnerMap[__tokenId] != address(0),
            "AssetIntroducerData: INVALID_NFT"
        );

        _;
    }

    modifier requireIsNftOwner(uint __tokenId) {

        require(
            _erc721StateV1.idToOwnerMap[__tokenId] == msg.sender,
            "AssetIntroducerData: INVALID_NFT_OWNER"
        );

        _;
    }

    modifier requireCanWithdrawFunds(uint __tokenId) {

        require(
            _assetIntroducerStateV1.idToAssetIntroducer[__tokenId].isAllowedToWithdrawFunds,
            "AssetIntroducerData: NFT_NOT_ACTIVATED"
        );

        _;
    }

    modifier requireIsStakingPurchaser() {

        require(
            _assetIntroducerStateV1.stakingPurchaser != address(0),
            "AssetIntroducerData: STAKING_PURCHASER_NOT_SETUP"
        );

        require(
            _assetIntroducerStateV1.stakingPurchaser == msg.sender,
            "AssetIntroducerData: INVALID_SENDER_FOR_STAKING"
        );
        _;
    }

}




pragma solidity ^0.5.0;


interface IAssetIntroducerV1 {



    event AssetIntroducerBought(uint indexed tokenId, address indexed buyer, address indexed recipient, uint dmgAmount);
    event AssetIntroducerActivationChanged(uint indexed tokenId, bool isActivated);
    event AssetIntroducerCreated(uint indexed tokenId, string countryCode, AssetIntroducerData.AssetIntroducerType introducerType, uint serialNumber);
    event AssetIntroducerDiscountChanged(address indexed oldAssetIntroducerDiscount, address indexed newAssetIntroducerDiscount);
    event AssetIntroducerDollarAmountToManageChange(uint indexed tokenId, uint oldDollarAmountToManage, uint newDollarAmountToManage);
    event AssetIntroducerPriceChanged(string indexed countryCode, AssetIntroducerData.AssetIntroducerType indexed introducerType, uint oldPriceUsd, uint newPriceUsd);
    event BaseURIChanged(string newBaseURI);
    event CapitalDeposited(uint indexed tokenId, address indexed token, uint amount);
    event CapitalWithdrawn(uint indexed tokenId, address indexed token, uint amount);
    event DelegateVotesChanged(address indexed delegate, uint previousBalance, uint newBalance);
    event InterestPaid(uint indexed tokenId, address indexed token, uint amount);
    event SignatureValidated(address indexed signer, uint nonce);
    event StakingPurchaserChanged(address indexed oldStakingPurchaser, address indexed newStakingPurchaser);


    function createAssetIntroducersForPrimaryMarket(
        string[] calldata countryCode,
        AssetIntroducerData.AssetIntroducerType[] calldata introducerType
    ) external returns (uint[] memory);


    function setDollarAmountToManageByTokenId(
        uint tokenId,
        uint dollarAmountToManage
    ) external;


    function setDollarAmountToManageByCountryCodeAndIntroducerType(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType,
        uint dollarAmountToManage
    ) external;


    function setAssetIntroducerDiscount(
        address assetIntroducerDiscount
    ) external;


    function setAssetIntroducerPrice(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType,
        uint priceUsd
    ) external;


    function activateAssetIntroducerByTokenId(
        uint tokenId
    ) external;


    function setStakingPurchaser(
        address stakingPurchaser
    ) external;



    function initTimestamp() external view returns (uint64);


    function stakingPurchaser() external view returns (address);


    function openSeaProxyRegistry() external view returns (address);


    function domainSeparator() external view returns (bytes32);


    function dmg() external view returns (address);


    function dmmController() external view returns (address);


    function underlyingTokenValuator() external view returns (address);


    function assetIntroducerDiscount() external view returns (address);


    function getAssetIntroducerDiscount() external view returns (uint);


    function getAssetIntroducerPriceUsdByTokenId(
        uint tokenId
    ) external view returns (uint);


    function getAssetIntroducerPriceDmgByTokenId(
        uint tokenId
    ) external view returns (uint);


    function getAssetIntroducerPriceUsdByCountryCodeAndIntroducerType(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType
    )
    external view returns (uint);


    function getAssetIntroducerPriceDmgByCountryCodeAndIntroducerType(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType
    )
    external view returns (uint);


    function getTotalDmgLocked() external view returns (uint);


    function getDollarAmountToManageByTokenId(
        uint tokenId
    ) external view returns (uint);


    function getDmgLockedByTokenId(
        uint tokenId
    ) external view returns (uint);


    function getAssetIntroducerByTokenId(
        uint tokenId
    ) external view returns (AssetIntroducerData.AssetIntroducer memory);


    function getAssetIntroducersByCountryCode(
        string calldata countryCode
    ) external view returns (AssetIntroducerData.AssetIntroducer[] memory);


    function getAllAssetIntroducers() external view returns (AssetIntroducerData.AssetIntroducer[] memory);


    function getPrimaryMarketAssetIntroducers() external view returns (AssetIntroducerData.AssetIntroducer[] memory);


    function getSecondaryMarketAssetIntroducers() external view returns (AssetIntroducerData.AssetIntroducer[] memory);



    function getNonceByUser(
        address user
    ) external view returns (uint);


    function getNextAssetIntroducerTokenId(
        string calldata __countryCode,
        AssetIntroducerData.AssetIntroducerType __introducerType
    ) external view returns (uint);


    function buyAssetIntroducerSlot(
        uint tokenId
    ) external returns (bool);


    function buyAssetIntroducerSlotViaStaking(
        uint tokenId,
        uint additionalDiscount
    ) external returns (bool);


    function nonceOf(
        address user
    ) external view returns (uint);


    function buyAssetIntroducerSlotBySig(
        uint tokenId,
        address recipient,
        uint nonce,
        uint expiry,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (bool);


    function buyAssetIntroducerSlotBySigWithDmgPermit(
        uint __tokenId,
        address __recipient,
        uint __nonce,
        uint __expiry,
        uint8 __v,
        bytes32 __r,
        bytes32 __s,
        AssetIntroducerData.DmgApprovalStruct calldata dmgApprovalStruct
    ) external returns (bool);


    function getPriorVotes(
        address user,
        uint blockNumber
    ) external view returns (uint128);


    function getCurrentVotes(
        address user
    ) external view returns (uint);


    function getDmgLockedByUser(
        address user
    ) external view returns (uint);


    function getDeployedCapitalUsdByTokenId(
        uint tokenId
    ) external view returns (uint);


    function getWithdrawnAmountByTokenIdAndUnderlyingToken(
        uint tokenId,
        address underlyingToken
    ) external view returns (uint);


    function deactivateAssetIntroducerByTokenId(
        uint tokenId
    ) external;


    function withdrawCapitalByTokenIdAndToken(
        uint tokenId,
        address token,
        uint amount
    ) external;


    function depositCapitalByTokenIdAndToken(
        uint tokenId,
        address token,
        uint amount
    ) external;


    function payInterestByTokenIdAndToken(
        uint tokenId,
        address token,
        uint amount
    ) external;



    function buyDmmFoundationToken(
        uint tokenId,
        address usdcToken
    ) external returns (bool);


    function isDmmFoundationSetup() external view returns (bool);


}




pragma solidity ^0.5.0;



contract AssetIntroducerStakingData is IOwnableOrGuardian {


    uint64 internal _guardCounter;

    address internal _assetIntroducerProxy;
    address internal _dmgIncentivesPool;
    mapping(address => UserStake[]) internal _userToStakesMap;
    bool internal _isOwnableInitialized;

    enum StakingDuration {
        TWELVE_MONTHS, EIGHTEEN_MONTHS
    }

    struct UserStake {
        bool isWithdrawn;
        uint64 unlockTimestamp;
        address mToken;
        uint amount;
        uint tokenId;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;

        _;

        require(
            localCounter == _guardCounter,
            "AssetIntroducerData: REENTRANCY"
        );
    }


}




pragma solidity ^0.5.0;



interface IAssetIntroducerStakingV1 {



    event UserBeginStaking(address indexed user, uint indexed tokenId, address dmmToken, uint amount, uint unlockTimestamp);
    event UserEndStaking(address indexed user, uint indexed tokenId, address dmmToken, uint amount);
    event IncentiveDmgUsed(uint indexed tokenId, address indexed buyer, uint amount);


    function assetIntroducerProxy() external view returns (address);


    function dmg() external view returns (address);


    function dmgIncentivesPool() external view returns (address);


    function isReady() external view returns (bool);


    function getTotalDiscountByStakingDuration(
        AssetIntroducerStakingData.StakingDuration duration
    ) external view returns (uint);


    function getAssetIntroducerPriceDmgByTokenIdAndStakingDuration(
        uint tokenId,
        AssetIntroducerStakingData.StakingDuration duration
    ) external view returns (uint, uint);



    function buyAssetIntroducerSlot(
        uint tokenId,
        uint dmmTokenId,
        AssetIntroducerStakingData.StakingDuration duration
    ) external returns (bool);


    function withdrawStake() external;


    function getUserStakesByAddress(
        address user
    ) external view returns (AssetIntroducerStakingData.UserStake[] memory);


    function getActiveUserStakesByAddress(
        address user
    ) external view returns (AssetIntroducerStakingData.UserStake[] memory);


    function balanceOf(
        address user,
        address mToken
    ) external view returns (uint);


    function getStakeAmountByTokenIdAndDmmTokenId(
        uint tokenId,
        uint dmmTokenId
    ) external view returns (uint);


    function getStakeAmountByCountryCodeAndIntroducerTypeAndDmmTokenId(
        string calldata countryCode,
        AssetIntroducerData.AssetIntroducerType introducerType,
        uint dmmTokenId
    ) external view returns (uint);


    function mapDurationEnumToSeconds(
        AssetIntroducerStakingData.StakingDuration duration
    ) external pure returns (uint64);


}




pragma solidity ^0.5.0;











contract AssetIntroducerStakingV1 is IAssetIntroducerStakingV1Initializable, IAssetIntroducerStakingV1, IERC721TokenReceiver, AssetIntroducerStakingData {


    using SafeERC20 for IERC20;
    using SafeMath for uint;

    uint constant internal ONE_ETH = 1 ether;

    function initialize(
        address __owner,
        address __guardian,
        address __assetIntroducerProxy,
        address __dmgIncentivesPool
    ) public initializer {

        IOwnableOrGuardian.initialize(__owner, __guardian);
        _assetIntroducerProxy = __assetIntroducerProxy;
        _dmgIncentivesPool = __dmgIncentivesPool;
        _guardCounter = 1;
    }

    function initializeOwnables(
        address __owner,
        address __guardian
    ) external {

        require(
            !_isOwnableInitialized,
            "AssetIntroducerStakingV1::initializeOwnables: ALREADY_INITIALIZED"
        );
        _isOwnableInitialized = true;
        _transferOwnership(__owner);
        _transferGuardian(__guardian);
    }

    function assetIntroducerProxy() external view returns (address) {

        return _assetIntroducerProxy;
    }

    function dmg() public view returns (address) {

        return IAssetIntroducerV1(_assetIntroducerProxy).dmg();
    }

    function dmgIncentivesPool() external view returns (address) {

        return _dmgIncentivesPool;
    }

    function buyAssetIntroducerSlot(
        uint __tokenId,
        uint __dmmTokenId,
        StakingDuration __duration
    )
    external
    nonReentrant
    returns (bool) {

        IAssetIntroducerV1 __assetIntroducerProxy = IAssetIntroducerV1(_assetIntroducerProxy);
        (uint fullPriceDmg, uint additionalDiscount) = getAssetIntroducerPriceDmgByTokenIdAndStakingDuration(__tokenId, __duration);
        uint userPriceDmg = fullPriceDmg / 2;

        address __dmg = dmg();
        address __dmgIncentivesPool = _dmgIncentivesPool;

        require(
            IERC20(__dmg).balanceOf(__dmgIncentivesPool) >= fullPriceDmg.sub(userPriceDmg),
            "AssetIntroducerBuyerRouter::buyAssetIntroducerSlot: INSUFFICIENT_INCENTIVES"
        );
        IERC20(__dmg).safeTransferFrom(__dmgIncentivesPool, address(this), fullPriceDmg.sub(userPriceDmg));
        IERC20(__dmg).safeTransferFrom(msg.sender, address(this), userPriceDmg);

        _performStakingForToken(__tokenId, __dmmTokenId, __duration, __assetIntroducerProxy);

        IERC20(__dmg).safeApprove(address(__assetIntroducerProxy), fullPriceDmg);
        __assetIntroducerProxy.buyAssetIntroducerSlotViaStaking(__tokenId, additionalDiscount);

        IERC721(address(__assetIntroducerProxy)).safeTransferFrom(address(this), msg.sender, __tokenId);

        emit IncentiveDmgUsed(__tokenId, msg.sender, fullPriceDmg.sub(userPriceDmg));

        return true;
    }

    function withdrawStake() external nonReentrant {

        UserStake[] memory userStakes = _userToStakesMap[msg.sender];
        for (uint i = 0; i < userStakes.length; i++) {
            if (!userStakes[i].isWithdrawn && block.timestamp > userStakes[i].unlockTimestamp) {
                _userToStakesMap[msg.sender][i].isWithdrawn = true;
                IERC20(userStakes[i].mToken).safeTransfer(msg.sender, userStakes[i].amount);
                emit UserEndStaking(msg.sender, userStakes[i].tokenId, userStakes[i].mToken, userStakes[i].amount);
            }
        }
    }

    function getUserStakesByAddress(
        address user
    ) external view returns (AssetIntroducerStakingData.UserStake[] memory) {

        return _userToStakesMap[user];
    }

    function getActiveUserStakesByAddress(
        address user
    ) external view returns (AssetIntroducerStakingData.UserStake[] memory) {

        AssetIntroducerStakingData.UserStake[] memory allStakes = _userToStakesMap[user];

        uint count = 0;
        for (uint i = 0; i < allStakes.length; i++) {
            if (!allStakes[i].isWithdrawn) {
                count += 1;
            }
        }

        AssetIntroducerStakingData.UserStake[] memory activeStakes = new AssetIntroducerStakingData.UserStake[](count);
        count = 0;
        for (uint i = 0; i < allStakes.length; i++) {
            if (!allStakes[i].isWithdrawn) {
                activeStakes[count++] = allStakes[i];
            }
        }
        return activeStakes;
    }

    function balanceOf(
        address user,
        address mToken
    ) external view returns (uint) {

        uint balance = 0;
        AssetIntroducerStakingData.UserStake[] memory allStakes = _userToStakesMap[user];
        for (uint i = 0; i < allStakes.length; i++) {
            if (!allStakes[i].isWithdrawn && allStakes[i].mToken == mToken) {
                balance += allStakes[i].amount;
            }
        }
        return balance;
    }

    function getStakeAmountByTokenIdAndDmmTokenId(
        uint __tokenId,
        uint __dmmTokenId
    ) public view returns (uint) {

        uint priceUsd = IAssetIntroducerV1(_assetIntroducerProxy).getAssetIntroducerPriceUsdByTokenId(__tokenId);
        return _getStakeAmountByDmmTokenId(__dmmTokenId, priceUsd);
    }

    function getStakeAmountByCountryCodeAndIntroducerTypeAndDmmTokenId(
        string calldata __countryCode,
        AssetIntroducerData.AssetIntroducerType __introducerType,
        uint __dmmTokenId
    ) external view returns (uint) {

        uint priceUsd = IAssetIntroducerV1(_assetIntroducerProxy).getAssetIntroducerPriceUsdByCountryCodeAndIntroducerType(__countryCode, __introducerType);
        return _getStakeAmountByDmmTokenId(__dmmTokenId, priceUsd);
    }

    function mapDurationEnumToSeconds(
        StakingDuration __duration
    ) public pure returns (uint64) {

        if (__duration == StakingDuration.TWELVE_MONTHS) {
            return 86400 * 30 * 12;
        } else if (__duration == StakingDuration.EIGHTEEN_MONTHS) {
            return 86400 * 30 * 18;
        } else {
            revert("AssetIntroducerStakingV1::mapDurationEnumToSeconds: INVALID_DURATION");
        }
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public returns (bytes4) {

        return bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    }

    function isReady() public view returns (bool) {

        return IERC20(dmg()).allowance(_dmgIncentivesPool, address(this)) > 0 &&
        IAssetIntroducerV1(_assetIntroducerProxy).stakingPurchaser() == address(this);
    }

    function getAssetIntroducerPriceDmgByTokenIdAndStakingDuration(
        uint __tokenId,
        StakingDuration __duration
    ) public view returns (uint, uint) {

        IAssetIntroducerV1 __assetIntroducerProxy = IAssetIntroducerV1(_assetIntroducerProxy);
        uint nonStakingDiscount = __assetIntroducerProxy.getAssetIntroducerDiscount();
        uint totalDiscount = getTotalDiscountByStakingDuration(__duration);
        uint additionalDiscount = totalDiscount.sub(nonStakingDiscount);

        uint fullPriceDmg = __assetIntroducerProxy.getAssetIntroducerPriceDmgByTokenId(__tokenId);
        uint originalPriceDmg = fullPriceDmg.mul(ONE_ETH).div(ONE_ETH.sub(nonStakingDiscount));

        return (originalPriceDmg.mul(ONE_ETH.sub(totalDiscount)).div(ONE_ETH), additionalDiscount);
    }

    function getTotalDiscountByStakingDuration(
        StakingDuration duration
    ) public view returns (uint) {

        uint baseDiscount;
        uint originalDiscount;
        if (duration == StakingDuration.TWELVE_MONTHS) {
            originalDiscount = 0.7 ether;
            baseDiscount = 0.25 ether;
        } else if (duration == StakingDuration.EIGHTEEN_MONTHS) {
            originalDiscount = 0.49 ether;
            baseDiscount = 0.50 ether;
        } else {
            revert("AssetIntroducerStakingV1::getTotalDiscountByStakingDuration: INVALID_DURATION");
        }

        uint elapsedTime = block.timestamp.sub(IAssetIntroducerV1(_assetIntroducerProxy).initTimestamp());
        uint discountDurationInSeconds = 86400 * 30 * 18;
        if (elapsedTime > discountDurationInSeconds) {
            return baseDiscount;
        } else {
            return (originalDiscount.mul(discountDurationInSeconds.sub(elapsedTime)).div(discountDurationInSeconds)).add(baseDiscount);
        }
    }


    function _performStakingForToken(
        uint __tokenId,
        uint __dmmTokenId,
        StakingDuration __duration,
        IAssetIntroducerV1 __assetIntroducerProxy
    ) internal {

        uint stakeAmount = getStakeAmountByTokenIdAndDmmTokenId(__tokenId, __dmmTokenId);
        address mToken = IDmmController(__assetIntroducerProxy.dmmController()).getDmmTokenAddressByDmmTokenId(__dmmTokenId);
        IERC20(mToken).safeTransferFrom(msg.sender, address(this), stakeAmount);
        uint64 unlockTimestamp = uint64(block.timestamp) + mapDurationEnumToSeconds(__duration);
        _userToStakesMap[msg.sender].push(UserStake({
        isWithdrawn : false,
        unlockTimestamp : unlockTimestamp,
        mToken : mToken,
        amount : stakeAmount,
        tokenId : __tokenId
        }));
        emit UserBeginStaking(msg.sender, __tokenId, mToken, stakeAmount, unlockTimestamp);
    }

    function _getStakeAmountByDmmTokenId(
        uint __dmmTokenId,
        uint __priceUsd
    ) internal view returns (uint) {

        IDmmController controller = IDmmController(IAssetIntroducerV1(_assetIntroducerProxy).dmmController());
        address dmmToken = controller.getDmmTokenAddressByDmmTokenId(__dmmTokenId);
        address underlyingToken = controller.getUnderlyingTokenForDmm(dmmToken);
        uint usdPricePerToken = controller.underlyingTokenValuator().getTokenValue(underlyingToken, ONE_ETH);
        uint numberOfDmmTokensStandardized = __priceUsd.mul(ONE_ETH).div(usdPricePerToken).mul(ONE_ETH).div(controller.getExchangeRate(dmmToken));
        uint8 decimals = IERC20WithDecimals(dmmToken).decimals();
        if (decimals > 18) {
            return numberOfDmmTokensStandardized.mul(10 ** uint(decimals - 18));
        } else if (decimals < 18) {
            return numberOfDmmTokensStandardized.div(10 ** uint(18 - decimals));
        } else {
            return numberOfDmmTokensStandardized;
        }
    }

}