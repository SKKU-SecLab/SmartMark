
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT

pragma solidity >=0.6.0 <0.8.0;

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;

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
}// MIT

pragma solidity >=0.6.0 <0.8.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// UNLICENSED
pragma solidity 0.7.6;


interface IERC20Permit is IERC20 {

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}// UNLICENSED
pragma solidity 0.7.6;

library Errors {

  string public constant INVALID_AUCTION_TIMESTAMPS = '1';
  string public constant INVALID_BID_TIMESTAMPS = '2';
  string public constant INVALID_BID_AMOUNT = '3';
  string public constant AUCTION_ONGOING = '4';
  string public constant VALID_BIDDER = '5';
  string public constant NONEXISTANT_VAULT = '6';
  string public constant INVALID_DISTRIBUTION_BPS = '7';
  string public constant AUCTION_EXISTS = '8';
  string public constant NOT_STAKING_AUCTION = '9';
  string public constant INVALID_CALL_TYPE = '10';
  string public constant INVALID_AUCTION_DURATION = '11';
  string public constant INVALID_BIDDER = '12';
  string public constant PAUSED = '13';
  string public constant NOT_ADMIN = '14';
  string public constant INVALID_INIT_PARAMS = '15';
  string public constant INVALID_DISTRIBUTION_COUNT = '16';
  string public constant ZERO_RECIPIENT = '17';
  string public constant ZERO_CURRENCY = '18';
  string public constant RA_NOT_OUTBID = '19';
  string public constant RA_OUTBID = '20';
  string public constant NO_DISTRIBUTIONS = '21';
  string public constant VAULT_ARRAY_MISMATCH = '22';
  string public constant CURRENCY_NOT_WHITELSITED = '23';
  string public constant NOT_NFT_OWNER = '24';
  string public constant ZERO_NFT = '25';
  string public constant NOT_COLLECTION_CREATOR = '26';
  string public constant INVALID_BUY_NOW = '27';
  string public constant INVALID_RESERVE_PRICE = '28';
}// UNLICENSED
pragma solidity 0.7.6;


contract AdminPausableUpgradeSafe {

    address internal _admin;
    bool internal _paused;
    
    event Paused(address admin);

    event Unpaused(address admin);

    event AdminChanged(address to);

    constructor() {
        _paused = true;
    }

    modifier whenNotPaused() {

        require(!_paused, Errors.PAUSED);
        _;
    }

    modifier onlyAdmin() {

        require(msg.sender == _admin, Errors.NOT_ADMIN);
        _;
    }

    function pause() external onlyAdmin {

        _paused = true;
        emit Paused(_admin);
    }

    function unpause() external onlyAdmin {

        _paused = false;
        emit Unpaused(_admin);
    }

    function changeAdmin(address to) external onlyAdmin {

        _admin = to;
        emit AdminChanged(to);
    }

    function getAdmin() external view returns (address) {

        return _admin;
    }
}// UNLICENSED
pragma solidity 0.7.6;

interface IWETH {


  function balanceOf(address guy) external returns (uint256);


  function deposit() external payable;


  function withdraw(uint256 wad) external;


  function approve(address guy, uint256 wad) external returns (bool);


  function transferFrom(
    address src,
    address dst,
    uint256 wad
  ) external returns (bool);


}// UNLICENSED
pragma solidity 0.7.6;


contract WETHBase {


    IWETH public immutable WETH;

    constructor(address weth) {
        WETH = IWETH(weth);
    }

    function _safeTransferETH(address to, uint256 value) internal {

        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'ETH_TRANSFER_FAILED');
    }    
}// agpl-3.0
pragma solidity 0.7.6;

abstract contract VersionedInitializable {
  uint256 private lastInitializedRevision = 0;

  bool private initializing;

  modifier initializer() {
    uint256 revision = getRevision();
    require(
      initializing || isConstructor() || revision > lastInitializedRevision,
      'Contract instance has already been initialized'
    );

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      lastInitializedRevision = revision;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function getRevision() internal pure virtual returns (uint256);

  function isConstructor() private view returns (bool) {
    uint256 cs;
    assembly {
      cs := extcodesize(address())
    }
    return cs == 0;
  }

  uint256[50] private ______gap;
}// UNLICENSED
pragma solidity 0.7.6;

library DataTypes {

    struct DistributionData {
        address recipient;
        uint256 bps;
    }

    struct StakingAuctionFullData {
        StakingAuctionData auction;
        DistributionData[] distribution;
        uint256 auctionId;
        address auctioner;
        address vault;
    }

    struct StakingAuctionData {
        uint256 currentBid;
        address currentBidder;
        uint40 startTimestamp;
        uint40 endTimestamp;
    }

    struct StakingAuctionConfiguration {
        address vaultLogic;
        address treasury;
        uint40 minimumAuctionDuration;
        uint40 overtimeWindow;
        uint16 treasuryFeeBps;
        uint16 burnPenaltyBps;
    }

    struct GenericAuctionFullData {
        GenericAuctionData auction;
        DistributionData[] distribution;
        uint256 auctionId;
        address auctioner;
    }

    struct GenericAuctionData {
        uint256 currentBid;
        address currency;
        address currentBidder;
        uint40 startTimestamp;
        uint40 endTimestamp;
    }

    struct GenericAuctionConfiguration {
        address treasury;
        uint40 minimumAuctionDuration;
        uint40 overtimeWindow;
        uint16 treasuryFeeBps;
    }

    struct RankedAuctionData {
        uint256 minPrice;
        address recipient;
        address currency;
        uint40 startTimestamp;
        uint40 endTimestamp;
    }

    struct ReserveAuctionFullData {
        ReserveAuctionData auction;
        DistributionData[] distribution;
        uint256 auctionId;
        address auctioner;
    }

    struct ReserveAuctionData {
        uint256 currentBid;
        uint256 buyNow;
        address currency;
        address currentBidder;
        uint40 duration;
        uint40 firstBidTimestamp;
        uint40 endTimestamp;
    }

    struct OpenEditionFullData {
        DistributionData[] distribution;
        OpenEditionSaleData saleData;
    }

    struct OpenEditionSaleData {
        uint256 price;
        address currency;
        address nft;
        uint40 startTimestamp;
        uint40 endTimestamp;
    }

    struct OpenEditionConfiguration {
        address treasury;
        uint40 minimumAuctionDuration;
        uint16 treasuryFeeBps;
    }

    struct OpenEditionBuyWithPermitParams {
        uint256 id;
        uint256 amount;
        uint256 permitAmount;
        uint256 deadline;
        address onBehalfOf;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct BidWithPermitParams {
        uint256 amount;
        uint256 deadline;
        uint256 nftId;
        address onBehalfOf;
        address nft;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    struct SimpleBidWithPermitParams {
        uint256 amount;
        uint256 deadline;
        address onBehalfOf;
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    enum CallType {Call, DelegateCall}
}// UNLICENSED
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


contract RankedAuction is
    VersionedInitializable,
    AdminPausableUpgradeSafe,
    WETHBase,
    ReentrancyGuard
{

    using SafeERC20 for IERC20Permit;
    using SafeMath for uint256;

    uint256 public constant RANKEDAUCTION_REVISION = 0x1;

    mapping(uint256 => DataTypes.RankedAuctionData) internal _auctionsById;
    mapping(address => mapping(uint256 => uint256)) internal _bids;
    mapping(address => mapping(uint256 => bool)) internal _outbid;
    mapping(address => bool) internal _currencyWhitelisted;

    uint256 internal _auctionCounter;
    uint40 internal _overtimeWindow;

    event Initialized(address weth, uint256 overtimeWindow);

    event BidSubmitted(uint256 indexed auctionId, address bidder, address spender, uint256 amount);

    event MinimumPriceUpdated(uint256 indexed auctionId, uint256 minimumPrice);

    event BidWithdrew(uint256 indexed auctionId, address indexed bidder, uint256 indexed amount);

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed currency,
        uint256 indexed minPrice,
        uint256 maxWinners,
        address recipient,
        uint40 startTimestamp,
        uint40 endTimestamp
    );

    event FundsReceived(
        uint256 indexed auctionId,
        address indexed recipient,
        address[] bidders,
        uint256 amount
    );

    event CurrencyWhitelisted(address currency);

    event CurrencyUnwhitelisted(address currency);

    event UsersOutbid(uint256 indexed auctionId, address[] bidders);

    constructor(address weth) WETHBase(weth) {}

    function initialize(address admin, uint40 overtimeWindow) external initializer {

        require(admin != address(0) && overtimeWindow < 2 days, Errors.INVALID_INIT_PARAMS);
        _admin = admin;
        _overtimeWindow = overtimeWindow;
        _currencyWhitelisted[address(WETH)] = true;
        _paused = false;

        emit Initialized(address(WETH), overtimeWindow);
    }

    function createAuction(
        uint256 maxWinners,
        address currency,
        uint256 minPrice,
        address recipient,
        uint40 startTimestamp,
        uint40 endTimestamp
    ) external nonReentrant onlyAdmin whenNotPaused {

        require(recipient != address(0), Errors.ZERO_RECIPIENT);
        require(currency != address(0), Errors.ZERO_CURRENCY);
        require(_currencyWhitelisted[currency], Errors.CURRENCY_NOT_WHITELSITED);
        require(
            startTimestamp > block.timestamp && endTimestamp > startTimestamp,
            Errors.INVALID_AUCTION_TIMESTAMPS
        );
        DataTypes.RankedAuctionData storage auction = _auctionsById[_auctionCounter];
        auction.minPrice = minPrice;
        auction.recipient = recipient;
        auction.currency = currency;
        auction.startTimestamp = startTimestamp;
        auction.endTimestamp = endTimestamp;

        emit AuctionCreated(
            _auctionCounter++,
            currency,
            minPrice,
            maxWinners,
            recipient,
            startTimestamp,
            endTimestamp
        );
    }

    function bid(
        uint256 auctionId,
        address onBehalfOf,
        uint256 amount
    ) external nonReentrant whenNotPaused {

        _bid(auctionId, msg.sender, onBehalfOf, amount);
    }

    function bidWithPermit(uint256 auctionId, DataTypes.SimpleBidWithPermitParams calldata params)
        external
        nonReentrant
        whenNotPaused
    {

        IERC20Permit currency = IERC20Permit(_auctionsById[auctionId].currency);
        currency.permit(
            msg.sender,
            address(this),
            params.amount,
            params.deadline,
            params.v,
            params.r,
            params.s
        );
        _bid(auctionId, msg.sender, params.onBehalfOf, params.amount);
    }

    function updateMinimumPrice(uint256 auctionId, uint256 newMinimum)
        external
        nonReentrant
        onlyAdmin
    {

        _auctionsById[auctionId].minPrice = newMinimum;

        emit MinimumPriceUpdated(auctionId, newMinimum);
    }

    function setOutbid(uint256 auctionId, address[] calldata toOutbid)
        external
        nonReentrant
        onlyAdmin
    {

        for (uint256 i = 0; i < toOutbid.length; i++) {
            require(_bids[toOutbid[i]][auctionId] > 0, Errors.INVALID_BID_AMOUNT);
            _outbid[toOutbid[i]][auctionId] = true;
        }

        emit UsersOutbid(auctionId, toOutbid);
    }

    function withdrawBid(uint256 auctionId) external nonReentrant whenNotPaused {

        DataTypes.RankedAuctionData storage auction = _auctionsById[auctionId];
        uint256 returnAmount = _bids[msg.sender][auctionId];
        require(
            (returnAmount > 0 && returnAmount < auction.minPrice) || _outbid[msg.sender][auctionId],
            Errors.RA_NOT_OUTBID
        );
        IERC20Permit currency = IERC20Permit(auction.currency);
        delete (_bids[msg.sender][auctionId]);
        delete (_outbid[msg.sender][auctionId]);

        if (address(currency) == address(WETH)) {
            WETH.withdraw(returnAmount);
            (bool success, ) = msg.sender.call{value: returnAmount}(new bytes(0));
            if (!success) {
                WETH.deposit{value: returnAmount}();
                IERC20Permit(address(WETH)).safeTransferFrom(
                    address(this),
                    msg.sender,
                    returnAmount
                );
            }
        } else {
            currency.safeTransfer(msg.sender, returnAmount);
        }

        emit BidWithdrew(auctionId, msg.sender, returnAmount);
    }

    function receiveFunds(uint256 auctionId, address[] calldata toReceive)
        external
        nonReentrant
        onlyAdmin
    {

        DataTypes.RankedAuctionData storage auction = _auctionsById[auctionId];
        uint256 endTimestamp = auction.endTimestamp;
        uint256 minPrice = auction.minPrice;
        uint256 amountToTransfer;
        address recipient = auction.recipient;
        IERC20Permit currency = IERC20Permit(auction.currency);
        require(block.timestamp > endTimestamp, Errors.INVALID_AUCTION_TIMESTAMPS);

        for (uint256 i = 0; i < toReceive.length; i++) {
            require(!_outbid[toReceive[i]][auctionId], Errors.RA_OUTBID);
            uint256 bidAmount = _bids[toReceive[i]][auctionId];
            require(bidAmount >= minPrice, Errors.RA_OUTBID);
            amountToTransfer = amountToTransfer.add(bidAmount);
            delete (_bids[toReceive[i]][auctionId]);
        }
        currency.safeTransfer(recipient, amountToTransfer);

        emit FundsReceived(auctionId, recipient, toReceive, amountToTransfer);
    }

    function whitelistCurrency(address toWhitelist) external onlyAdmin {

        _currencyWhitelisted[toWhitelist] = true;
        emit CurrencyWhitelisted(toWhitelist);
    }

    function removeCurrencyFromWhitelist(address toRemove) external onlyAdmin {

        _currencyWhitelisted[toRemove] = false;
        emit CurrencyUnwhitelisted(toRemove);
    }

    function emergencyEtherTransfer(address to, uint256 amount) external onlyAdmin {

        _safeTransferETH(to, amount);
    }

    function getAuctionData(uint256 auctionId)
        external
        view
        returns (DataTypes.RankedAuctionData memory)
    {

        return _auctionsById[auctionId];
    }

    function getBid(address bidder, uint256 auctionId) external view returns (uint256) {

        return _bids[bidder][auctionId];
    }

    function getOvertimeWindow() external view returns (uint256) {

        return _overtimeWindow;
    }

    function isWhitelisted(address query) external view returns (bool) {

        return _currencyWhitelisted[query];
    }

    function _bid(
        uint256 auctionId,
        address spender,
        address onBehalfOf,
        uint256 amount
    ) internal {

        DataTypes.RankedAuctionData storage auction = _auctionsById[auctionId];
        uint256 minPrice = auction.minPrice;
        IERC20Permit currency = IERC20Permit(auction.currency);
        uint40 startTimestamp = auction.startTimestamp;
        uint40 endTimestamp = auction.endTimestamp;
        require(onBehalfOf != address(0), Errors.INVALID_BIDDER);
        require(amount > minPrice, Errors.INVALID_BID_AMOUNT);
        require(
            block.timestamp > startTimestamp && block.timestamp < endTimestamp,
            Errors.INVALID_BID_TIMESTAMPS
        );
        if (_overtimeWindow > 0 && block.timestamp > endTimestamp - _overtimeWindow) {
            endTimestamp = endTimestamp + _overtimeWindow;
        }

        uint256 previousBid = _bids[onBehalfOf][auctionId];
        _bids[onBehalfOf][auctionId] = amount;
        if (amount > previousBid) {
            currency.safeTransferFrom(spender, address(this), amount - previousBid);
        } else {
            revert(Errors.INVALID_BID_AMOUNT);
        }

        emit BidSubmitted(auctionId, onBehalfOf, spender, amount);
    }

    function getRevision() internal pure override returns (uint256) {

        return RANKEDAUCTION_REVISION;
    }

    receive() external payable {
        require(msg.sender == address(WETH));
    }
}