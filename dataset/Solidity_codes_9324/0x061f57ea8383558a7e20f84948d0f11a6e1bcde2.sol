
pragma solidity ^0.5.0;


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

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
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

interface InterestRateInterface {


    function getInterestRate(uint dmmTokenId, uint totalSupply, uint activeSupply) external view returns (uint);


}

interface IUnderlyingTokenValuator {


    function getTokenValue(address token, uint amount) external view returns (uint);


}

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

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
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

contract DMGYieldFarmingData is Initializable {



    uint256 private _guardCounter;
    address internal _owner;

    address internal _dmgToken;
    address internal _guardian;
    address internal _dmmController;
    address[] internal _supportedFarmTokens;
    uint internal _dmgGrowthCoefficient;

    bool internal _isFarmActive;
    uint internal _seasonIndex;
    mapping(address => uint16) internal _tokenToRewardPointMap;
    mapping(address => mapping(address => bool)) internal _userToSpenderToIsApprovedMap;
    mapping(uint => mapping(address => mapping(address => uint))) internal _seasonIndexToUserToTokenToEarnedDmgAmountMap;
    mapping(uint => mapping(address => mapping(address => uint64))) internal _seasonIndexToUserToTokenToDepositTimestampMap;
    mapping(address => address) internal _tokenToUnderlyingTokenMap;
    mapping(address => uint8) internal _tokenToDecimalsMap;
    mapping(address => uint) internal _tokenToIndexPlusOneMap;
    mapping(address => mapping(address => uint)) internal _addressToTokenToBalanceMap;
    mapping(address => bool) internal _globalProxyToIsTrustedMap;



    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


    function initialize(address owner) public initializer {

        _guardCounter = 1;

        _owner = owner;
        emit OwnershipTransferred(address(0), owner);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    function isOwner() public view returns (bool) {

        return msg.sender == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        require(newOwner != address(0), "DMGYieldFarmingData::transferOwnership: INVALID_OWNER");

        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }


    modifier onlyOwner() {

        require(isOwner(), "DMGYieldFarmingData: NOT_OWNER");
        _;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "DMGYieldFarmingData: REENTRANCY");
    }


    uint8 public constant POINTS_DECIMALS = 2;

    uint16 public constant POINTS_FACTOR = 10 ** uint16(POINTS_DECIMALS);

    uint8 public constant DMG_GROWTH_COEFFICIENT_DECIMALS = 18;

    uint public constant DMG_GROWTH_COEFFICIENT_FACTOR = 10 ** uint(DMG_GROWTH_COEFFICIENT_DECIMALS);

    uint8 public constant USD_VALUE_DECIMALS = 18;

    uint public constant USD_VALUE_FACTOR = 10 ** uint(USD_VALUE_DECIMALS);

}

interface IDMGYieldFarmingV1 {



    event GlobalProxySet(address indexed proxy, bool isTrusted);

    event TokenAdded(address indexed token, address indexed underlyingToken, uint8 underlyingTokenDecimals, uint16 points);
    event TokenRemoved(address indexed token);

    event FarmSeasonBegun(uint indexed seasonIndex, uint dmgAmount);
    event FarmSeasonEnd(uint indexed seasonIndex, address dustRecipient, uint dustyDmgAmount);

    event DmgGrowthCoefficientSet(uint coefficient);
    event RewardPointsSet(address indexed token, uint16 points);


    event Approval(address indexed user, address indexed spender, bool isTrusted);

    event BeginFarming(address indexed owner, address indexed token, uint depositedAmount);
    event EndFarming(address indexed owner, address indexed token, uint withdrawnAmount, uint earnedDmgAmount);

    event WithdrawOutOfSeason(address indexed owner, address indexed token, address indexed recipient, uint amount);


    function approveGloballyTrustedProxy(address proxy, bool isTrusted) external;


    function isGloballyTrustedProxy(address proxy) external view returns (bool);


    function addAllowableToken(address token, address underlyingToken, uint8 underlyingTokenDecimals, uint16 points) external;


    function removeAllowableToken(address token) external;


    function setRewardPointsByToken(address token, uint16 points) external;


    function setDmgGrowthCoefficient(uint dmgGrowthCoefficient) external;


    function beginFarmingSeason(uint dmgAmount) external;


    function endActiveFarmingSeason(address dustRecipient) external;



    function getFarmTokens() external view returns (address[] memory);


    function isSupportedToken(address token) external view returns (bool);


    function isFarmActive() external view returns (bool);


    function guardian() external view returns (address);


    function dmgToken() external view returns (address);


    function dmgGrowthCoefficient() external view returns (uint);


    function getRewardPointsByToken(address token) external view returns (uint16);


    function getTokenDecimalsByToken(address token) external view returns (uint8);


    function getTokenIndexPlusOneByToken(address token) external view returns (uint);



    function approve(address spender, bool isTrusted) external;


    function isApproved(address user, address spender) external view returns (bool);


    function beginFarming(address user, address funder, address token, uint amount) external;


    function endFarmingByToken(address from, address recipient, address token) external returns (uint, uint);


    function withdrawAllWhenOutOfSeason(address user, address recipient) external;


    function withdrawByTokenWhenOutOfSeason(
        address user,
        address recipient,
        address token
    ) external returns (uint);


    function getRewardBalanceByOwner(address owner) external view returns (uint);


    function getRewardBalanceByOwnerAndToken(address owner, address token) external view returns (uint);


    function balanceOf(address owner, address token) external view returns (uint);


    function getMostRecentDepositTimestampByOwnerAndToken(address owner, address token) external view returns (uint64);


    function getMostRecentIndexedDmgEarnedByOwnerAndToken(address owner, address token) external view returns (uint);


}

interface IDMGYieldFarmingV1Initializable {


    function initialize(
        address dmgToken,
        address guardian,
        address dmmController,
        uint dmgGrowthCoefficient,
        address[] calldata allowableTokens,
        address[] calldata underlyingTokens,
        uint8[] calldata tokenDecimals,
        uint16[] calldata points
    ) external;


}

contract DMGYieldFarmingV1 is IDMGYieldFarmingV1, IDMGYieldFarmingV1Initializable, DMGYieldFarmingData {


    using SafeMath for uint;
    using SafeERC20 for IERC20;

    modifier isSpenderApproved(address user) {

        require(
            msg.sender == user || _globalProxyToIsTrustedMap[msg.sender] || _userToSpenderToIsApprovedMap[user][msg.sender],
            "DMGYieldFarmingV1: UNAPPROVED"
        );
        _;
    }

    modifier onlyOwnerOrGuardian {

        require(
            msg.sender == _owner || msg.sender == _guardian,
            "DMGYieldFarming: UNAUTHORIZED"
        );
        _;
    }

    modifier farmIsActive {

        require(_isFarmActive, "DMGYieldFarming: FARM_NOT_ACTIVE");
        _;
    }

    modifier requireIsFarmToken(address token) {

        require(_tokenToIndexPlusOneMap[token] != 0, "DMGYieldFarming: TOKEN_UNSUPPORTED");
        _;
    }

    modifier farmIsNotActive {

        require(!_isFarmActive, "DMGYieldFarming: FARM_IS_ACTIVE");
        _;
    }

    function initialize(
        address __dmgToken,
        address __guardian,
        address __dmmController,
        uint __dmgGrowthCoefficient,
        address[] memory __allowableTokens,
        address[] memory __underlyingTokens,
        uint8[] memory __tokenDecimals,
        uint16[] memory __points
    )
    initializer
    public {

        DMGYieldFarmingData.initialize(__guardian);

        require(
            __allowableTokens.length == __points.length,
            "DMGYieldFarming::initialize: INVALID_LENGTH"
        );
        require(
            __points.length == __underlyingTokens.length,
            "DMGYieldFarming::initialize: INVALID_LENGTH"
        );
        require(
            __underlyingTokens.length == __tokenDecimals.length,
            "DMGYieldFarming::initialize: INVALID_LENGTH"
        );

        _dmgToken = __dmgToken;
        _guardian = __guardian;
        _dmmController = __dmmController;

        _verifyDmgGrowthCoefficient(__dmgGrowthCoefficient);
        _dmgGrowthCoefficient = __dmgGrowthCoefficient;
        _seasonIndex = 1;
        _isFarmActive = false;

        for (uint i = 0; i < __allowableTokens.length; i++) {
            require(
                __allowableTokens[i] != address(0),
                "DMGYieldFarming::initialize: INVALID_UNDERLYING"
            );
            require(
                __underlyingTokens[i] != address(0),
                "DMGYieldFarming::initialize: INVALID_UNDERLYING"
            );

            _supportedFarmTokens.push(__allowableTokens[i]);
            _tokenToIndexPlusOneMap[__allowableTokens[i]] = i + 1;
            _tokenToUnderlyingTokenMap[__allowableTokens[i]] = __underlyingTokens[i];
            _tokenToDecimalsMap[__allowableTokens[i]] = __tokenDecimals[i];

            _verifyPoints(__points[i]);
            _tokenToRewardPointMap[__allowableTokens[i]] = __points[i];
        }
    }


    function approveGloballyTrustedProxy(
        address proxy,
        bool isTrusted
    )
    public
    nonReentrant
    onlyOwnerOrGuardian {

        _globalProxyToIsTrustedMap[proxy] = isTrusted;
        emit GlobalProxySet(proxy, isTrusted);
    }

    function isGloballyTrustedProxy(
        address proxy
    ) public view returns (bool) {

        return _globalProxyToIsTrustedMap[proxy];
    }

    function addAllowableToken(
        address token,
        address underlyingToken,
        uint8 underlyingTokenDecimals,
        uint16 points
    )
    public
    nonReentrant
    onlyOwner {

        uint index = _tokenToIndexPlusOneMap[token];
        require(
            index == 0,
            "DMGYieldFarming::addAllowableToken: TOKEN_ALREADY_SUPPORTED"
        );
        _tokenToIndexPlusOneMap[token] = _supportedFarmTokens.push(token);
        _tokenToRewardPointMap[token] = points;
        _tokenToDecimalsMap[token] = underlyingTokenDecimals;
        emit TokenAdded(token, underlyingToken, underlyingTokenDecimals, points);
    }

    function removeAllowableToken(
        address token
    )
    public
    nonReentrant
    farmIsNotActive
    onlyOwner {

        uint index = _tokenToIndexPlusOneMap[token];
        require(
            index != 0,
            "DMGYieldFarming::removeAllowableToken: TOKEN_NOT_SUPPORTED"
        );
        _tokenToIndexPlusOneMap[token] = 0;
        _tokenToRewardPointMap[token] = 0;
        delete _supportedFarmTokens[index - 1];
        emit TokenRemoved(token);
    }

    function setRewardPointsByToken(
        address token,
        uint16 points
    )
    public
    nonReentrant
    onlyOwner {

        _verifyPoints(points);
        _tokenToRewardPointMap[token] = points;
        emit RewardPointsSet(token, points);
    }

    function setDmgGrowthCoefficient(
        uint dmgGrowthCoefficient
    )
    public
    nonReentrant
    onlyOwnerOrGuardian {

        _verifyDmgGrowthCoefficient(dmgGrowthCoefficient);

        _dmgGrowthCoefficient = dmgGrowthCoefficient;
        emit DmgGrowthCoefficientSet(dmgGrowthCoefficient);
    }

    function beginFarmingSeason(
        uint dmgAmount
    )
    public
    onlyOwnerOrGuardian
    nonReentrant {

        require(!_isFarmActive, "DMGYieldFarming::beginFarmingSeason: FARM_ALREADY_ACTIVE");

        _seasonIndex += 1;
        _isFarmActive = true;
        IERC20(_dmgToken).safeTransferFrom(msg.sender, address(this), dmgAmount);

        emit FarmSeasonBegun(_seasonIndex, dmgAmount);
    }

    function endActiveFarmingSeason(
        address dustRecipient
    )
    public
    nonReentrant {

        uint dmgBalance = IERC20(_dmgToken).balanceOf(address(this));
        require(
            dmgBalance == 0 || msg.sender == owner() || msg.sender == _guardian,
            "DMGYieldFarming::endActiveFarmingSeason: FARM_ACTIVE_OR_INVALID_SENDER"
        );

        _isFarmActive = false;
        if (dmgBalance > 0) {
            IERC20(_dmgToken).safeTransfer(dustRecipient, dmgBalance);
        }

        emit FarmSeasonEnd(_seasonIndex, dustRecipient, dmgBalance);
    }


    function getFarmTokens() public view returns (address[] memory) {

        return _supportedFarmTokens;
    }

    function isSupportedToken(address token) public view returns (bool) {

        return _tokenToIndexPlusOneMap[token] > 0;
    }

    function isFarmActive() public view returns (bool) {

        return _isFarmActive;
    }

    function guardian() public view returns (address) {

        return _guardian;
    }

    function dmgToken() public view returns (address) {

        return _dmgToken;
    }

    function dmgGrowthCoefficient() public view returns (uint) {

        return _dmgGrowthCoefficient;
    }

    function getRewardPointsByToken(
        address token
    ) public view returns (uint16) {

        uint16 rewardPoints = _tokenToRewardPointMap[token];
        return rewardPoints == 0 ? POINTS_FACTOR : rewardPoints;
    }

    function getTokenDecimalsByToken(
        address token
    ) public view returns (uint8) {

        return _tokenToDecimalsMap[token];
    }

    function getTokenIndexPlusOneByToken(
        address token
    ) public view returns (uint) {

        return _tokenToIndexPlusOneMap[token];
    }


    function approve(
        address spender,
        bool isTrusted
    ) public {

        _userToSpenderToIsApprovedMap[msg.sender][spender] = isTrusted;
        emit Approval(msg.sender, spender, isTrusted);
    }

    function isApproved(
        address user,
        address spender
    ) public view returns (bool) {

        return _userToSpenderToIsApprovedMap[user][spender];
    }

    function beginFarming(
        address user,
        address funder,
        address token,
        uint amount
    )
    public
    farmIsActive
    requireIsFarmToken(token)
    isSpenderApproved(user)
    nonReentrant {

        require(
            funder == msg.sender || funder == user,
            "DMGYieldFarmingV1::beginFarming: INVALID_FUNDER"
        );

        if (amount > 0) {
            IERC20(token).safeTransferFrom(funder, address(this), amount);
        }

        _reindexEarningsByTimestamp(user, token);

        if (amount > 0) {
            _addressToTokenToBalanceMap[user][token] = _addressToTokenToBalanceMap[user][token].add(amount);
        }

        emit BeginFarming(user, token, amount);
    }

    function endFarmingByToken(
        address user,
        address recipient,
        address token
    )
    public
    farmIsActive
    requireIsFarmToken(token)
    isSpenderApproved(user)
    nonReentrant
    returns (uint, uint) {

        uint balance = _addressToTokenToBalanceMap[user][token];
        require(balance > 0, "DMGYieldFarming::endFarmingByToken: ZERO_BALANCE");

        uint earnedDmgAmount = _getTotalRewardBalanceByUserAndToken(user, token, _seasonIndex);
        require(earnedDmgAmount > 0, "DMGYieldFarming::endFarmingByToken: ZERO_EARNED");

        address dmgToken = _dmgToken;
        uint contractDmgBalance = IERC20(dmgToken).balanceOf(address(this));
        _endFarmingByToken(user, recipient, token, balance, earnedDmgAmount, contractDmgBalance);

        earnedDmgAmount = _transferDmgOut(recipient, earnedDmgAmount, dmgToken, contractDmgBalance);

        return (balance, earnedDmgAmount);
    }

    function withdrawAllWhenOutOfSeason(
        address user,
        address recipient
    )
    public
    farmIsNotActive
    isSpenderApproved(user)
    nonReentrant {

        address[] memory farmTokens = _supportedFarmTokens;
        for (uint i = 0; i < farmTokens.length; i++) {
            _withdrawByTokenWhenOutOfSeason(user, recipient, farmTokens[i]);
        }
    }

    function withdrawByTokenWhenOutOfSeason(
        address user,
        address recipient,
        address token
    )
    isSpenderApproved(user)
    nonReentrant
    public returns (uint) {

        require(
            !_isFarmActive || _tokenToIndexPlusOneMap[token] == 0,
            "DMGYieldFarmingV1::withdrawByTokenWhenOutOfSeason: FARM_ACTIVE_OR_TOKEN_SUPPORTED"
        );

        return _withdrawByTokenWhenOutOfSeason(user, recipient, token);
    }

    function getRewardBalanceByOwner(
        address owner
    ) public view returns (uint) {

        if (_isFarmActive) {
            return _getTotalRewardBalanceByUser(owner, _seasonIndex);
        } else {
            return 0;
        }
    }

    function getRewardBalanceByOwnerAndToken(
        address owner,
        address token
    ) public view returns (uint) {

        if (_isFarmActive) {
            return _getTotalRewardBalanceByUserAndToken(owner, token, _seasonIndex);
        } else {
            return 0;
        }
    }

    function balanceOf(
        address owner,
        address token
    ) public view returns (uint) {

        return _addressToTokenToBalanceMap[owner][token];
    }

    function getMostRecentDepositTimestampByOwnerAndToken(
        address owner,
        address token
    ) public view returns (uint64) {

        if (_isFarmActive) {
            return _seasonIndexToUserToTokenToDepositTimestampMap[_seasonIndex][owner][token];
        } else {
            return 0;
        }
    }

    function getMostRecentIndexedDmgEarnedByOwnerAndToken(
        address owner,
        address token
    ) public view returns (uint) {

        if (_isFarmActive) {
            return _seasonIndexToUserToTokenToEarnedDmgAmountMap[_seasonIndex][owner][token];
        } else {
            return 0;
        }
    }

    function getMostRecentBlockTimestamp() public view returns (uint64) {

        return uint64(block.timestamp);
    }


    function _getUsdValueByTokenAndTokenAmount(
        address token,
        uint tokenAmount
    ) internal view returns (uint) {

        uint8 decimals = _tokenToDecimalsMap[token];
        address underlyingToken = _tokenToUnderlyingTokenMap[token];

        tokenAmount = tokenAmount
        .mul(IERC20(underlyingToken).balanceOf(token)) /* For Uniswap pools, underlying tokens are held in the pool's contract. */
        .div(IERC20(token).totalSupply(), "DMGYieldFarmingV1::_getUsdValueByTokenAndTokenAmount: INVALID_TOTAL_SUPPLY")
        .mul(2) /* The user deposits effectively 2x the amount, to account for both sides of the pool. Assuming the pool is at (or close to it) equilibrium, this 2x suffices as an estimate */;

        if (decimals < 18) {
            tokenAmount = tokenAmount.mul((10 ** (18 - uint(decimals))));
        } else if (decimals > 18) {
            tokenAmount = tokenAmount.div((10 ** (uint(decimals) - 18)));
        }

        return IDmmController(_dmmController).underlyingTokenValuator().getTokenValue(
            underlyingToken,
            tokenAmount
        );
    }

    function _endFarmingByToken(
        address user,
        address recipient,
        address token,
        uint tokenBalance,
        uint earnedDmgAmount,
        uint contractDmgBalance
    ) internal {

        IERC20(token).safeTransfer(recipient, tokenBalance);

        _addressToTokenToBalanceMap[user][token] = _addressToTokenToBalanceMap[user][token].sub(tokenBalance);
        _seasonIndexToUserToTokenToEarnedDmgAmountMap[_seasonIndex][user][token] = 0;
        _seasonIndexToUserToTokenToDepositTimestampMap[_seasonIndex][user][token] = uint64(block.timestamp);

        if (earnedDmgAmount > contractDmgBalance) {
            earnedDmgAmount = contractDmgBalance;
        }

        emit EndFarming(user, token, tokenBalance, earnedDmgAmount);
    }

    function _withdrawByTokenWhenOutOfSeason(
        address user,
        address recipient,
        address token
    ) internal returns (uint) {

        uint amount = _addressToTokenToBalanceMap[user][token];
        if (amount > 0) {
            _addressToTokenToBalanceMap[user][token] = 0;
            IERC20(token).safeTransfer(recipient, amount);
        }

        emit WithdrawOutOfSeason(user, token, recipient, amount);

        return amount;
    }

    function _reindexEarningsByTimestamp(
        address user,
        address token
    ) internal {

        uint64 previousIndexTimestamp = _seasonIndexToUserToTokenToDepositTimestampMap[_seasonIndex][user][token];
        if (previousIndexTimestamp != 0) {
            uint dmgEarnedAmount = _getUnindexedRewardsByUserAndToken(user, token, previousIndexTimestamp);
            if (dmgEarnedAmount > 0) {
                _seasonIndexToUserToTokenToEarnedDmgAmountMap[_seasonIndex][user][token] = _seasonIndexToUserToTokenToEarnedDmgAmountMap[_seasonIndex][user][token].add(dmgEarnedAmount);
            }
        }
        _seasonIndexToUserToTokenToDepositTimestampMap[_seasonIndex][user][token] = uint64(block.timestamp);
    }

    function _getTotalRewardBalanceByUser(
        address owner,
        uint seasonIndex
    ) internal view returns (uint) {

        address[] memory supportedFarmTokens = _supportedFarmTokens;
        uint totalDmgEarned = 0;
        for (uint i = 0; i < supportedFarmTokens.length; i++) {
            totalDmgEarned = totalDmgEarned.add(_getTotalRewardBalanceByUserAndToken(owner, supportedFarmTokens[i], seasonIndex));
        }
        return totalDmgEarned;
    }

    function _getUnindexedRewardsByUserAndToken(
        address owner,
        address token,
        uint64 previousIndexTimestamp
    ) internal view returns (uint) {

        uint balance = _addressToTokenToBalanceMap[owner][token];
        if (balance > 0 && previousIndexTimestamp > 0) {
            uint usdValue = _getUsdValueByTokenAndTokenAmount(token, balance);
            uint16 points = getRewardPointsByToken(token);
            return _calculateRewardBalance(
                usdValue,
                points,
                _dmgGrowthCoefficient,
                block.timestamp,
                previousIndexTimestamp
            );
        } else {
            return 0;
        }
    }

    function _getTotalRewardBalanceByUserAndToken(
        address owner,
        address token,
        uint seasonIndex
    ) internal view returns (uint) {

        uint64 previousIndexTimestamp = _seasonIndexToUserToTokenToDepositTimestampMap[seasonIndex][owner][token];
        return _getUnindexedRewardsByUserAndToken(owner, token, previousIndexTimestamp)
        .add(_seasonIndexToUserToTokenToEarnedDmgAmountMap[seasonIndex][owner][token]);
    }

    function _verifyDmgGrowthCoefficient(
        uint dmgGrowthCoefficient
    ) internal pure {

        require(
            dmgGrowthCoefficient > 0,
            "DMGYieldFarming::_verifyDmgGrowthCoefficient: INVALID_GROWTH_COEFFICIENT"
        );
    }

    function _verifyPoints(
        uint16 points
    ) internal pure {

        require(
            points > 0,
            "DMGYieldFarming::_verifyPoints: INVALID_POINTS"
        );
    }

    function _transferDmgOut(
        address recipient,
        uint amount,
        address dmgToken,
        uint contractDmgBalance
    ) internal returns (uint) {

        if (contractDmgBalance < amount) {
            IERC20(dmgToken).safeTransfer(recipient, contractDmgBalance);
            return contractDmgBalance;
        } else {
            IERC20(dmgToken).safeTransfer(recipient, amount);
            return amount;
        }
    }

    function _calculateRewardBalance(
        uint usdValue,
        uint16 points,
        uint dmgGrowthCoefficient,
        uint currentTimestamp,
        uint previousIndexTimestamp
    ) internal pure returns (uint) {

        if (usdValue == 0) {
            return 0;
        } else {
            uint elapsedTime = currentTimestamp.sub(previousIndexTimestamp);
            return elapsedTime
            .mul(dmgGrowthCoefficient)
            .mul(points)
            .mul(usdValue)
            .div(POINTS_FACTOR)
            .div(DMG_GROWTH_COEFFICIENT_FACTOR);
        }
    }

}