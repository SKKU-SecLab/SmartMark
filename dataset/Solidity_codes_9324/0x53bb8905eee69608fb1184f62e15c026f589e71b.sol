
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

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

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

pragma solidity >=0.6.0 <0.8.0;

library Clones {

    function clone(address master) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create(0, ptr, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    function cloneDeterministic(address master, bytes32 salt) internal returns (address instance) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
            instance := create2(0, ptr, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    function predictDeterministicAddress(address master, bytes32 salt, address deployer) internal pure returns (address predicted) {

        assembly {
            let ptr := mload(0x40)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(ptr, 0x14), shl(0x60, master))
            mstore(add(ptr, 0x28), 0x5af43d82803e903d91602b57fd5bf3ff00000000000000000000000000000000)
            mstore(add(ptr, 0x38), shl(0x60, deployer))
            mstore(add(ptr, 0x4c), salt)
            mstore(add(ptr, 0x6c), keccak256(ptr, 0x37))
            predicted := keccak256(add(ptr, 0x37), 0x55)
        }
    }

    function predictDeterministicAddress(address master, bytes32 salt) internal view returns (address predicted) {

        return predictDeterministicAddress(master, salt, address(this));
    }
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


abstract contract AuctionBase is AdminPausableUpgradeSafe {
    using SafeERC20 for IERC20Permit;
    using SafeMath for uint256;

    uint16 public constant BPS_MAX = 10000;

    address internal _treasury;
    uint40 internal _minimumAuctionDuration;
    uint40 internal _overtimeWindow;
    uint16 internal _treasuryFeeBps;
    uint8 internal _distributionCap;

    event TreasuryFeeChanged(uint16 newTreasuryFeeBps);
    event TreasuryAddressChanged(address newTreasury);
    event MinimumAuctionDurationChanged(uint40 newMinimumDuration);
    event OvertimeWindowChanged(uint40 newOvertimeWindow);
    event DistributionCapChanged(uint8 newDistributionCap);

    function setTreasuryFeeBps(uint16 newTreasuryFeeBps) external onlyAdmin {
        require(newTreasuryFeeBps < BPS_MAX, Errors.INVALID_INIT_PARAMS);
        _treasuryFeeBps = newTreasuryFeeBps;
        emit TreasuryFeeChanged(newTreasuryFeeBps);
    }

    function setTreasuryAddress(address newTreasury) external onlyAdmin {
        require(newTreasury != address(0), Errors.INVALID_INIT_PARAMS);
        _treasury = newTreasury;
        emit TreasuryAddressChanged(newTreasury);
    }

    function setMinimumAuctionDuration(uint40 newMinimumDuration) external onlyAdmin {
        require(newMinimumDuration > _overtimeWindow, Errors.INVALID_INIT_PARAMS);
        _minimumAuctionDuration = newMinimumDuration;
        emit MinimumAuctionDurationChanged(newMinimumDuration);
    }

    function setOvertimeWindow(uint40 newOvertimeWindow) external onlyAdmin {
        require(
            newOvertimeWindow < _minimumAuctionDuration && newOvertimeWindow < 2 days,
            Errors.INVALID_INIT_PARAMS
        );
        _overtimeWindow = newOvertimeWindow;
        emit OvertimeWindowChanged(newOvertimeWindow);
    }

    function setDistributionCap(uint8 newDistributionCap) external onlyAdmin {
        require(newDistributionCap > 0, Errors.INVALID_INIT_PARAMS);
        _distributionCap = newDistributionCap;
        emit DistributionCapChanged(newDistributionCap);
    }

    function bid(
        address onBehalfOf,
        address nft,
        uint256 nftId,
        uint256 amount
    ) external virtual whenNotPaused {
        _bid(msg.sender, onBehalfOf, nft, nftId, amount);
    }

    function _distribute(
        address currency,
        uint256 amount,
        DataTypes.DistributionData[] memory distribution
    ) internal {
        require(distribution.length > 0, Errors.INVALID_DISTRIBUTION_COUNT);
        IERC20Permit token = IERC20Permit(currency);
        uint256 leftover = amount;
        uint256 distributionAmount;
        for (uint256 i = 0; i < distribution.length; i++) {
            distributionAmount = amount.mul(distribution[i].bps).div(BPS_MAX);
            leftover = leftover.sub(distributionAmount);
            token.safeTransfer(distribution[i].recipient, distributionAmount);
        }

        if (leftover > 0) {
            token.safeTransfer(_treasury, leftover);
        }
    }

    function _bid(
        address spender,
        address onBehalfOf,
        address nft,
        uint256 nftId,
        uint256 amount
    ) internal virtual;
}// UNLICENSED
pragma solidity 0.7.6;


interface IStakedAave is IERC20 {

    function stake(address onBehalfOf, uint256 amount) external;


    function claimRewards(address to, uint256 amount) external;


    function getTotalRewardsBalance(address staker)
        external
        view
        returns (uint256);

}// UNLICENSED
pragma solidity 0.7.6;
pragma experimental ABIEncoderV2;


interface IVault {

    function execute(
        address[] calldata targets,
        bytes[] calldata datas,
        DataTypes.CallType[] calldata callTypes
    ) external;

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


contract StakingAuction is VersionedInitializable, AuctionBase, ReentrancyGuard {

    using SafeERC20 for IERC20Permit;
    using SafeERC20 for IStakedAave;
    using SafeMath for uint256;

    uint256 public constant STAKINGAUCTION_REVISION = 0x1;
    IERC20Permit public constant AAVE = IERC20Permit(0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9);
    IStakedAave public constant STKAAVE = IStakedAave(0x4da27a545c0c5B758a6BA100e3a049001de870f5);

    mapping(address => mapping(uint256 => DataTypes.StakingAuctionFullData)) internal _nftData;

    uint256 internal _auctionCounter;
    address internal _vaultLogic;
    uint16 internal _burnPenaltyBps;

    event Initialized(
        address treasury,
        uint16 treasuryFeeBps,
        uint16 burnPenaltyBps,
        uint40 overtimeWindow,
        uint40 minimumAuctionDuration,
        uint8 distributionCap
    );

    event AuctionCreated(
        address indexed nft,
        uint256 indexed nftId,
        uint256 auctionId,
        address auctioner,
        uint40 startTimestamp,
        uint40 endTimestamp,
        uint256 startPrice
    );

    event BidSubmitted(
        uint256 indexed auctionId,
        address bidder,
        address spender,
        uint256 amount
    );

    event AuctionExtended(
        uint256 indexed auctionId,
        uint40 newEndTimestamp
    );

    event WonNftClaimed(
        address indexed nft,
        uint256 indexed nftId,
        uint256 auctionId,
        address winner
    );

    event Redeemed(address indexed nft, uint256 indexed nftId, uint256 auctionId);

    event RewardsClaimed(address indexed nft, uint256 indexed nftId, uint256 auctionId);

    event Reclaimed(uint256 indexed auctionId, address indexed nft, uint256 indexed nftId);

    event BurnPenaltyChanged(uint16 newBurnPenaltyBps);

    event VaultImplementationChanged(address newVaultLogic);

    function initialize(
        address vaultLogic,
        address treasury,
        uint16 treasuryFeeBps,
        uint16 burnPenaltyBps,
        uint40 overtimeWindow,
        uint40 minimumAuctionDuration,
        address admin,
        uint8 distributionCap
    ) external initializer {

        require(
            admin != address(0) &&
                treasury != address(0) &&
                vaultLogic != address(0) &&
                treasuryFeeBps < BPS_MAX &&
                burnPenaltyBps < BPS_MAX &&
                overtimeWindow < minimumAuctionDuration &&
                overtimeWindow < 2 days &&
                distributionCap > 0 &&
                distributionCap < 6,
            Errors.INVALID_INIT_PARAMS
        );

        _vaultLogic = vaultLogic;
        _treasury = treasury;
        _treasuryFeeBps = treasuryFeeBps;
        _burnPenaltyBps = burnPenaltyBps;
        _overtimeWindow = overtimeWindow;
        _minimumAuctionDuration = minimumAuctionDuration;
        _admin = admin;
        _distributionCap = distributionCap;
        _paused = false;
        AAVE.safeApprove(address(STKAAVE), type(uint256).max);

        emit Initialized(
            treasury,
            treasuryFeeBps,
            burnPenaltyBps,
            overtimeWindow,
            minimumAuctionDuration,
            distributionCap
        );
    }

    function createAuction(
        address nft,
        uint256 nftId,
        uint40 startTimestamp,
        uint40 endTimestamp,
        uint256 startPrice,
        DataTypes.DistributionData[] calldata distribution
    ) external nonReentrant onlyAdmin whenNotPaused {

        DataTypes.StakingAuctionFullData storage nftData = _nftData[nft][nftId];
        require(nftData.auctioner == address(0), Errors.AUCTION_EXISTS);
        require(
            distribution.length <= _distributionCap && distribution.length >= 1,
            Errors.INVALID_DISTRIBUTION_COUNT
        );
        require(
            startTimestamp > block.timestamp && endTimestamp > startTimestamp,
            Errors.INVALID_AUCTION_TIMESTAMPS
        );
        require(
            endTimestamp - startTimestamp >= _minimumAuctionDuration,
            Errors.INVALID_AUCTION_DURATION
        );

        uint256 neededBps = uint256(BPS_MAX).sub(_treasuryFeeBps);
        uint256 totalBps;
        for (uint256 i = 0; i < distribution.length; i++) {
            totalBps = totalBps.add(distribution[i].bps);
        }
        require(totalBps == neededBps, Errors.INVALID_DISTRIBUTION_BPS);

        DataTypes.StakingAuctionData memory auctionData =
            DataTypes.StakingAuctionData(startPrice, address(0), startTimestamp, endTimestamp);

        _nftData[nft][nftId].auction = auctionData;
        _nftData[nft][nftId].auctionId = _auctionCounter;
        _nftData[nft][nftId].auctioner = msg.sender;

        for (uint256 i = 0; i < distribution.length; i++) {
            require(distribution[i].recipient != address(0), Errors.ZERO_RECIPIENT);
            _nftData[nft][nftId].distribution.push(distribution[i]);
        }

        IERC721(nft).transferFrom(msg.sender, address(this), nftId);
        emit AuctionCreated(
            nft,
            nftId,
            _auctionCounter++,
            msg.sender,
            startTimestamp,
            endTimestamp,
            startPrice
        );
    }

    function bidWithPermit(DataTypes.BidWithPermitParams calldata params)
        external
        nonReentrant
        whenNotPaused
    {

        AAVE.permit(
            msg.sender,
            address(this),
            params.amount,
            params.deadline,
            params.v,
            params.r,
            params.s
        );
        _bid(msg.sender, params.onBehalfOf, params.nft, params.nftId, params.amount);
    }

    function claimWonNFT(address nft, uint256 nftId) external nonReentrant whenNotPaused {

        DataTypes.StakingAuctionData storage auction = _nftData[nft][nftId].auction;

        address winner = auction.currentBidder;

        require(block.timestamp > auction.endTimestamp, Errors.AUCTION_ONGOING);
        require(winner != address(0), Errors.INVALID_BIDDER);

        address clone = Clones.clone(_vaultLogic);
        _nftData[nft][nftId].vault = clone;

        STKAAVE.stake(clone, auction.currentBid);

        delete (_nftData[nft][nftId].auction);
        IERC721(nft).safeTransferFrom(address(this), winner, nftId);

        emit WonNftClaimed(nft, nftId, _nftData[nft][nftId].auctionId, winner);
    }

    function reclaimEndedAuction(address nft, uint256 nftId) external nonReentrant whenNotPaused {

        DataTypes.StakingAuctionData storage auction = _nftData[nft][nftId].auction;
        address auctioner = _nftData[nft][nftId].auctioner;
        address currentBidder = auction.currentBidder;

        require(block.timestamp > auction.endTimestamp, Errors.AUCTION_ONGOING);
        require(currentBidder == address(0), Errors.VALID_BIDDER);

        uint256 auctionIdCached = _nftData[nft][nftId].auctionId;

        delete (_nftData[nft][nftId]);
        IERC721(nft).safeTransferFrom(address(this), auctioner, nftId);

        emit Reclaimed(auctionIdCached, nft, nftId);
    }

    function redeem(address nft, uint256 nftId) external nonReentrant whenNotPaused {

        IERC721 nftContract = IERC721(nft);
        DataTypes.StakingAuctionFullData storage nftData = _nftData[nft][nftId];
        address vault = nftData.vault;
        address auctioner = nftData.auctioner;
        DataTypes.DistributionData[] memory distribution = nftData.distribution;

        require(vault != address(0), Errors.NONEXISTANT_VAULT);

        uint256 rewardsBalance = STKAAVE.getTotalRewardsBalance(vault);
        uint256 stkAaveVaultBalance = STKAAVE.balanceOf(vault);
        uint256 auctionIdCached = nftData.auctionId;
        delete (_nftData[nft][nftId]);

        _claimAndRedeem(vault, stkAaveVaultBalance);

        uint256 penaltyAmount = uint256(_burnPenaltyBps).mul(stkAaveVaultBalance).div(BPS_MAX);
        STKAAVE.safeTransfer(msg.sender, stkAaveVaultBalance.sub(penaltyAmount));

        _distribute(address(AAVE), rewardsBalance, distribution);
        _distribute(address(STKAAVE), penaltyAmount, distribution);

        require(nftContract.ownerOf(nftId) == msg.sender, Errors.NOT_NFT_OWNER);
        nftContract.safeTransferFrom(msg.sender, auctioner, nftId);

        emit Redeemed(nft, nftId, auctionIdCached);
    }

    function claimRewards(address nft, uint256 nftId) external nonReentrant whenNotPaused {

        DataTypes.StakingAuctionFullData storage nftData = _nftData[nft][nftId];
        DataTypes.DistributionData[] storage distribution = _nftData[nft][nftId].distribution;
        address vault = nftData.vault;
        require(vault != address(0), Errors.NONEXISTANT_VAULT);

        uint256 rewardsBalance = STKAAVE.getTotalRewardsBalance(vault);
        bytes memory rewardFunctionData = _buildClaimRewardsParams(address(this));
        address[] memory targets = new address[](1);
        bytes[] memory params = new bytes[](1);
        DataTypes.CallType[] memory callTypes = new DataTypes.CallType[](1);

        targets[0] = address(STKAAVE);
        params[0] = rewardFunctionData;
        callTypes[0] = DataTypes.CallType.Call;
        IVault(vault).execute(targets, params, callTypes);

        _distribute(address(AAVE), rewardsBalance, distribution);

        emit RewardsClaimed(nft, nftId, nftData.auctionId);
    }

    function setBurnPenaltyBps(uint16 newBurnPenaltyBps) external onlyAdmin {

        require(newBurnPenaltyBps < BPS_MAX, Errors.INVALID_INIT_PARAMS);
        _burnPenaltyBps = newBurnPenaltyBps;

        emit BurnPenaltyChanged(newBurnPenaltyBps);
    }

    function setNewVaultLogic(address newVaultLogic) external onlyAdmin {

        require(newVaultLogic != address(0), Errors.INVALID_INIT_PARAMS);
        _vaultLogic = newVaultLogic;

        emit VaultImplementationChanged(newVaultLogic);
    }

    function getConfiguration()
        external
        view
        returns (DataTypes.StakingAuctionConfiguration memory)
    {

        return
            DataTypes.StakingAuctionConfiguration(
                _vaultLogic,
                _treasury,
                _minimumAuctionDuration,
                _overtimeWindow,
                _treasuryFeeBps,
                _burnPenaltyBps
            );
    }

    function getNftData(address nft, uint256 nftId)
        external
        view
        returns (DataTypes.StakingAuctionFullData memory)
    {

        return _nftData[nft][nftId];
    }

    function _bid(
        address spender,
        address onBehalfOf,
        address nft,
        uint256 nftId,
        uint256 amount
    ) internal override {

        require(onBehalfOf != address(0), Errors.INVALID_BIDDER);
        DataTypes.StakingAuctionData storage auction = _nftData[nft][nftId].auction;
        uint256 currentBid = auction.currentBid;
        address currentBidder = auction.currentBidder;
        uint40 endTimestamp = auction.endTimestamp;
        uint40 startTimestamp = auction.startTimestamp;

        require(
            block.timestamp > startTimestamp && block.timestamp < endTimestamp,
            Errors.INVALID_BID_TIMESTAMPS
        );
        require(amount > currentBid, Errors.INVALID_BID_AMOUNT);

        if (_overtimeWindow > 0 && block.timestamp > endTimestamp - _overtimeWindow) {
            uint40 newEndTimestamp = endTimestamp + _overtimeWindow;
            auction.endTimestamp = newEndTimestamp;

            emit AuctionExtended(_nftData[nft][nftId].auctionId, newEndTimestamp);
        }

        auction.currentBidder = onBehalfOf;
        auction.currentBid = amount;

        if (currentBidder != address(0)) {
            AAVE.safeTransfer(currentBidder, currentBid);
        }

        AAVE.safeTransferFrom(spender, address(this), amount);

        emit BidSubmitted(_nftData[nft][nftId].auctionId, onBehalfOf, spender, amount);
    }

    function _claimAndRedeem(address vault, uint256 stkAaveAmount) internal {

        bytes memory rewardFunctionData = _buildClaimRewardsParams(address(this));
        bytes memory transferFunctionData = _buildTransferParams(address(this), stkAaveAmount);

        address[] memory targets = new address[](2);
        bytes[] memory params = new bytes[](2);
        DataTypes.CallType[] memory callTypes = new DataTypes.CallType[](2);

        targets[0] = address(STKAAVE);
        targets[1] = address(STKAAVE);
        params[0] = rewardFunctionData;
        params[1] = transferFunctionData;
        callTypes[0] = DataTypes.CallType.Call;
        callTypes[1] = DataTypes.CallType.Call;

        IVault(vault).execute(targets, params, callTypes);
    }

    function _buildClaimRewardsParams(address to) internal pure returns (bytes memory) {

        bytes4 claimRewardsSelector = IStakedAave.claimRewards.selector;
        bytes memory rewardFunctionData =
            abi.encodeWithSelector(claimRewardsSelector, to, type(uint256).max);
        return rewardFunctionData;
    }

    function _buildTransferParams(address to, uint256 amount) internal pure returns (bytes memory) {

        bytes4 transferSelector = IERC20.transfer.selector;
        bytes memory transferFunctionData = abi.encodeWithSelector(transferSelector, to, amount);
        return transferFunctionData;
    }

    function getRevision() internal pure override returns (uint256) {

        return STAKINGAUCTION_REVISION;
    }
}