
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

pragma solidity >=0.6.0 <0.8.0;


library Counters {

    using SafeMath for uint256;

    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {

        return counter._value;
    }

    function increment(Counter storage counter) internal {

        counter._value += 1;
    }

    function decrement(Counter storage counter) internal {

        counter._value = counter._value.sub(1);
    }
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

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

library EnumerableSet {


    struct Set {
        bytes32[] _values;

        mapping (bytes32 => uint256) _indexes;
    }

    function _add(Set storage set, bytes32 value) private returns (bool) {

        if (!_contains(set, value)) {
            set._values.push(value);
            set._indexes[value] = set._values.length;
            return true;
        } else {
            return false;
        }
    }

    function _remove(Set storage set, bytes32 value) private returns (bool) {

        uint256 valueIndex = set._indexes[value];

        if (valueIndex != 0) { // Equivalent to contains(set, value)

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;


            bytes32 lastvalue = set._values[lastIndex];

            set._values[toDeleteIndex] = lastvalue;
            set._indexes[lastvalue] = toDeleteIndex + 1; // All indexes are 1-based

            set._values.pop();

            delete set._indexes[value];

            return true;
        } else {
            return false;
        }
    }

    function _contains(Set storage set, bytes32 value) private view returns (bool) {

        return set._indexes[value] != 0;
    }

    function _length(Set storage set) private view returns (uint256) {

        return set._values.length;
    }

    function _at(Set storage set, uint256 index) private view returns (bytes32) {

        require(set._values.length > index, "EnumerableSet: index out of bounds");
        return set._values[index];
    }


    struct Bytes32Set {
        Set _inner;
    }

    function add(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _add(set._inner, value);
    }

    function remove(Bytes32Set storage set, bytes32 value) internal returns (bool) {

        return _remove(set._inner, value);
    }

    function contains(Bytes32Set storage set, bytes32 value) internal view returns (bool) {

        return _contains(set._inner, value);
    }

    function length(Bytes32Set storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(Bytes32Set storage set, uint256 index) internal view returns (bytes32) {

        return _at(set._inner, index);
    }


    struct AddressSet {
        Set _inner;
    }

    function add(AddressSet storage set, address value) internal returns (bool) {

        return _add(set._inner, bytes32(uint256(uint160(value))));
    }

    function remove(AddressSet storage set, address value) internal returns (bool) {

        return _remove(set._inner, bytes32(uint256(uint160(value))));
    }

    function contains(AddressSet storage set, address value) internal view returns (bool) {

        return _contains(set._inner, bytes32(uint256(uint160(value))));
    }

    function length(AddressSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(AddressSet storage set, uint256 index) internal view returns (address) {

        return address(uint160(uint256(_at(set._inner, index))));
    }



    struct UintSet {
        Set _inner;
    }

    function add(UintSet storage set, uint256 value) internal returns (bool) {

        return _add(set._inner, bytes32(value));
    }

    function remove(UintSet storage set, uint256 value) internal returns (bool) {

        return _remove(set._inner, bytes32(value));
    }

    function contains(UintSet storage set, uint256 value) internal view returns (bool) {

        return _contains(set._inner, bytes32(value));
    }

    function length(UintSet storage set) internal view returns (uint256) {

        return _length(set._inner);
    }

    function at(UintSet storage set, uint256 index) internal view returns (uint256) {

        return uint256(_at(set._inner, index));
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


abstract contract AccessControl is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using Address for address;

    struct RoleData {
        EnumerableSet.AddressSet members;
        bytes32 adminRole;
    }

    mapping (bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) public view returns (bool) {
        return _roles[role].members.contains(account);
    }

    function getRoleMemberCount(bytes32 role) public view returns (uint256) {
        return _roles[role].members.length();
    }

    function getRoleMember(bytes32 role, uint256 index) public view returns (address) {
        return _roles[role].members.at(index);
    }

    function getRoleAdmin(bytes32 role) public view returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to grant");

        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual {
        require(hasRole(_roles[role].adminRole, _msgSender()), "AccessControl: sender must be an admin to revoke");

        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        emit RoleAdminChanged(role, _roles[role].adminRole, adminRole);
        _roles[role].adminRole = adminRole;
    }

    function _grantRole(bytes32 role, address account) private {
        if (_roles[role].members.add(account)) {
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) private {
        if (_roles[role].members.remove(account)) {
            emit RoleRevoked(role, account, _msgSender());
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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}// MIT

pragma solidity >=0.6.0 <0.8.0;


contract Escrow is Ownable {

    using SafeMath for uint256;
    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {

        return _deposits[payee];
    }

    function deposit(address payee) public payable virtual onlyOwner {

        uint256 amount = msg.value;
        _deposits[payee] = _deposits[payee].add(amount);

        emit Deposited(payee, amount);
    }

    function withdraw(address payable payee) public virtual onlyOwner {

        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
}// MIT

pragma solidity >=0.6.2 <0.8.0;


abstract contract PullPayment {
    Escrow private _escrow;

    constructor () internal {
        _escrow = new Escrow();
    }

    function withdrawPayments(address payable payee) public virtual {
        _escrow.withdraw(payee);
    }

    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{ value: amount }(dest);
    }
}//BSD 3-Clause
pragma solidity 0.6.12;

interface IERC721TokenCreator {

    function tokenCreator(address _nftAddress, uint256 _tokenId)
        external
        view
        returns (address payable);

}//Unlicensed
pragma solidity 0.6.12;

interface IFirstDibsMarketSettings {

    function globalBuyerPremium() external view returns (uint32);


    function globalMarketCommission() external view returns (uint32);


    function globalCreatorRoyaltyRate() external view returns (uint32);


    function globalMinimumBidIncrement() external view returns (uint32);


    function globalTimeBuffer() external view returns (uint32);


    function globalAuctionDuration() external view returns (uint32);


    function commissionAddress() external view returns (address);

}//Unlicensed
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;



contract FirstDibsAuction is PullPayment, AccessControl, ReentrancyGuard, IERC721Receiver {

    using SafeMath for uint256;
    using SafeMath for uint64;
    using Counters for Counters.Counter;

    bytes32 public constant BIDDER_ROLE = keccak256('BIDDER_ROLE');
    bytes32 public constant BIDDER_ROLE_ADMIN = keccak256('BIDDER_ROLE_ADMIN');

    bool public bidderRoleRequired; // if true, bids require bidder having BIDDER_ROLE role
    bool public globalPaused; // flag for pausing all auctions
    IERC721TokenCreator public iERC721TokenCreatorRegistry;
    IFirstDibsMarketSettings public iFirstDibsMarketSettings;
    mapping(uint256 => Auction) public auctions;
    mapping(address => mapping(uint256 => uint256)) public auctionIds;

    Counters.Counter private auctionIdsCounter;

    struct AuctionSettings {
        uint32 buyerPremium; // percent; added on top of current bid
        uint32 duration; // defaults to globalDuration
        uint32 minimumBidIncrement; // defaults to globalMinimumBidIncrement
        uint32 commissionRate; // percent; defaults to globalMarketCommission
        uint128 creatorRoyaltyRate; // percent; defaults to globalCreatorRoyaltyRate
    }

    struct Bid {
        uint256 amount; // current winning bid of the auction
        uint256 buyerPremiumAmount; // current buyer premium associated with current bid
    }

    struct Auction {
        uint256 startTime; // auction start timestamp
        uint256 pausedTime; // when was the auction paused
        uint256 reservePrice; // minimum bid threshold for auction to begin
        uint256 tokenId; // id of the token
        bool paused; // is individual auction paused
        address nftAddress; // address of the token
        address payable payee; // address of auction proceeds recipient. NFT creator until secondary market is introduced.
        address payable currentBidder; // current winning bidder of the auction
        address auctionCreator; // address of the creator of the auction (whoever called the createAuction method)
        AuctionSettings settings;
        Bid currentBid;
    }

    modifier onlyAdmin() {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'caller is not an admin');
        _;
    }

    modifier onlyBidder() {

        if (bidderRoleRequired == true) {
            require(hasRole(BIDDER_ROLE, _msgSender()), 'bidder role required');
        }
        _;
    }

    modifier notPaused(uint256 auctionId) {

        require(!globalPaused, 'Auctions are globally paused');
        require(!auctions[auctionId].paused, 'Auction is paused.');
        _;
    }

    modifier auctionExists(uint256 auctionId) {

        require(auctions[auctionId].payee != address(0), "Auction doesn't exist");
        _;
    }

    modifier senderIsAuctionCreatorOrAdmin(uint256 auctionId) {

        require(
            _msgSender() == auctions[auctionId].auctionCreator ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            'Must be auction creator or admin'
        );
        _;
    }

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address tokenSeller,
        uint256 reservePrice,
        bool isPaused,
        address auctionCreator,
        uint64 duration
    );

    event AuctionBid(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 bidAmount,
        uint256 bidBuyerPremium,
        uint64 duration,
        uint256 startTime
    );

    event AuctionEnded(
        uint256 indexed auctionId,
        address indexed tokenSeller,
        address indexed winningBidder,
        uint256 winningBid,
        uint256 winningBidBuyerPremium,
        uint256 adminCommissionFee,
        uint256 royaltyFee,
        uint256 sellerPayment
    );

    event AuctionPaused(
        uint256 indexed auctionId,
        address indexed tokenSeller,
        address toggledBy,
        bool isPaused,
        uint64 duration
    );

    event AuctionCanceled(uint256 indexed auctionId, address canceledBy, uint256 refundedAmount);

    constructor(address _marketSettings, address _creatorRegistry) public {
        require(
            _marketSettings != address(0),
            'constructor: 0 address not allowed for _marketSettings'
        );
        require(
            _creatorRegistry != address(0),
            'constructor: 0 address not allowed for _creatorRegistry'
        );
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender()); // deployer of the contract gets admin permissions
        _setupRole(BIDDER_ROLE, _msgSender());
        _setupRole(BIDDER_ROLE_ADMIN, _msgSender());
        _setRoleAdmin(BIDDER_ROLE, BIDDER_ROLE_ADMIN);
        iERC721TokenCreatorRegistry = IERC721TokenCreator(_creatorRegistry);
        iFirstDibsMarketSettings = IFirstDibsMarketSettings(_marketSettings);
        bidderRoleRequired = true;
    }

    function setIERC721TokenCreatorRegistry(address _iERC721TokenCreatorRegistry)
        external
        onlyAdmin
    {

        require(
            _iERC721TokenCreatorRegistry != address(0),
            'setIERC721TokenCreatorRegistry: 0 address not allowed'
        );
        iERC721TokenCreatorRegistry = IERC721TokenCreator(_iERC721TokenCreatorRegistry);
    }

    function setIFirstDibsMarketSettings(address _iFirstDibsMarketSettings) external onlyAdmin {

        require(
            _iFirstDibsMarketSettings != address(0),
            'setIFirstDibsMarketSettings: 0 address not allowed'
        );
        iFirstDibsMarketSettings = IFirstDibsMarketSettings(_iFirstDibsMarketSettings);
    }

    function setBidderRoleRequired(bool _bidderRole) external onlyAdmin {

        bidderRoleRequired = _bidderRole;
    }

    function setGlobalPaused(bool _paused) external onlyAdmin {

        globalPaused = _paused;
    }

    function createAuction(
        address _nftAddress,
        uint256 _tokenId,
        uint64 _reservePrice,
        bool _pausedArg,
        uint64 _startTimeArg,
        uint32 _auctionDurationArg,
        uint8 _minimumBidIncrementArg
    ) external {

        adminCreateAuction(
            _nftAddress,
            _tokenId,
            _reservePrice,
            _pausedArg,
            _startTimeArg,
            _auctionDurationArg,
            _minimumBidIncrementArg,
            101, // adminCreateAuction function ignores values > 100
            101 // adminCreateAuction function ignores values > 100
        );
    }

    function adminCreateAuction(
        address _nftAddress,
        uint256 _tokenId,
        uint64 _reservePrice,
        bool _pausedArg,
        uint64 _startTimeArg,
        uint32 _auctionDurationArg,
        uint8 _minimumBidIncrementArg,
        uint8 _commissionRateArg,
        uint8 _creatorRoyaltyRateArg
    ) public nonReentrant {

        require(!globalPaused, 'adminCreateAuction: auctions are globally paused');

        require(
            _msgSender() == IERC721(_nftAddress).ownerOf(_tokenId) ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            'adminCreateAuction: must be token owner or admin'
        );

        require(
            auctionIds[_nftAddress][_tokenId] == 0,
            'adminCreateAuction: auction already exists'
        );

        require(_reservePrice > 0, 'adminCreateAuction: Reserve must be > 0');

        Auction memory auction = Auction({
            currentBid: Bid({ amount: 0, buyerPremiumAmount: 0 }),
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            payee: payable(IERC721(_nftAddress).ownerOf(_tokenId)), // payee is the token owner
            auctionCreator: _msgSender(),
            reservePrice: _reservePrice, // minimum bid threshold for auction to begin
            startTime: 0,
            currentBidder: address(0), // there is no bidder at auction creation
            paused: _pausedArg, // is individual auction paused
            pausedTime: 0, // when the auction was paused
            settings: AuctionSettings({ // Defaults to global market settings; admins may override
                buyerPremium: iFirstDibsMarketSettings.globalBuyerPremium(),
                duration: iFirstDibsMarketSettings.globalAuctionDuration(),
                minimumBidIncrement: iFirstDibsMarketSettings.globalMinimumBidIncrement(),
                commissionRate: iFirstDibsMarketSettings.globalMarketCommission(),
                creatorRoyaltyRate: iFirstDibsMarketSettings.globalCreatorRoyaltyRate()
            })
        });

        if (hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            if (_auctionDurationArg > 0) {
                require(
                    _auctionDurationArg >= iFirstDibsMarketSettings.globalTimeBuffer(),
                    'adminCreateAuction: duration must be >= time buffer'
                );
                auction.settings.duration = _auctionDurationArg;
            }

            if (_startTimeArg > 0) {
                require(
                    block.timestamp < _startTimeArg,
                    'adminCreateAuction: start time must be in the future'
                );
                auction.startTime = _startTimeArg;
                auction.paused = false;
            }

            if (_minimumBidIncrementArg > 0) {
                auction.settings.minimumBidIncrement = _minimumBidIncrementArg;
            }

            if (_commissionRateArg <= 100) {
                auction.settings.commissionRate = _commissionRateArg;
            }

            if (_creatorRoyaltyRateArg <= 100) {
                auction.settings.creatorRoyaltyRate = _creatorRoyaltyRateArg;
            }
        }

        require(
            uint256(auction.settings.commissionRate).add(auction.settings.creatorRoyaltyRate) <=
                100,
            'adminCreateAuction: commission rate + royalty rate must be <= 100'
        );

        auctionIdsCounter.increment();
        auctions[auctionIdsCounter.current()] = auction;
        auctionIds[_nftAddress][_tokenId] = auctionIdsCounter.current();

        IERC721(_nftAddress).safeTransferFrom(auction.payee, address(this), _tokenId);

        emit AuctionCreated(
            auctionIdsCounter.current(),
            _nftAddress,
            _tokenId,
            auction.payee,
            _reservePrice,
            auction.paused,
            _msgSender(),
            auction.settings.duration
        );
    }

    function getSentBidAndPremium(uint64 _amount, uint64 _buyerPremiumRate)
        public
        pure
        returns (
            uint64, /*sentBid*/
            uint64 /*sentPremium*/
        )
    {

        uint256 bpRate = _buyerPremiumRate.add(100);
        uint64 _sentBid = uint64(_amount.mul(100).div(bpRate));
        uint64 _sentPremium = uint64(_amount.sub(_sentBid));
        return (_sentBid, _sentPremium);
    }

    function _validateAndGetBid(uint256 _auctionId, uint64 _totalAmount)
        internal
        view
        returns (
            uint64, /*sentBid*/
            uint64 /*sentPremium*/
        )
    {

        (uint64 _sentBid, uint64 _sentPremium) = getSentBidAndPremium(
            _totalAmount,
            auctions[_auctionId].settings.buyerPremium
        );
        if (auctions[_auctionId].currentBidder == address(0)) {
            require(
                _sentBid >= auctions[_auctionId].reservePrice,
                '_validateAndGetBid: reserve not met'
            );
        } else {
            require(
                _sentBid >=
                    auctions[_auctionId].currentBid.amount.add(
                        auctions[_auctionId]
                        .currentBid
                        .amount
                        .mul(auctions[_auctionId].settings.minimumBidIncrement)
                        .div(100)
                    ),
                '_validateAndGetBid: minimum bid not met'
            );
        }
        return (_sentBid, _sentPremium);
    }

    function bid(uint256 _auctionId, uint64 _amount)
        external
        payable
        nonReentrant
        onlyBidder
        auctionExists(_auctionId)
        notPaused(_auctionId)
    {

        require(msg.value > 0, 'bid: value must be > 0');
        require(_amount == msg.value, 'bid: amount/value mismatch');
        require(
            auctions[_auctionId].startTime == 0 ||
                block.timestamp >= auctions[_auctionId].startTime,
            'bid: auction not started'
        );
        require(
            auctions[_auctionId].startTime == 0 || block.timestamp < _endTime(_auctionId),
            'bid: auction expired'
        );
        require(
            auctions[_auctionId].payee != _msgSender(),
            'bid: token owner may not bid on own auction'
        );
        require(
            auctions[_auctionId].currentBidder != _msgSender(),
            'bid: sender is current highest bidder'
        );

        (uint64 _sentBid, uint64 _sentPremium) = _validateAndGetBid(_auctionId, _amount);

        if (auctions[_auctionId].startTime == 0) {
            auctions[_auctionId].startTime = uint64(block.timestamp);
        } else if (auctions[_auctionId].currentBidder != address(0)) {
            uint256 refundAmount = auctions[_auctionId].currentBid.amount.add(
                auctions[_auctionId].currentBid.buyerPremiumAmount
            );
            address priorBidder = auctions[_auctionId].currentBidder;
            _tryTransferThenEscrow(priorBidder, refundAmount);
        }
        auctions[_auctionId].currentBid.amount = _sentBid;
        auctions[_auctionId].currentBid.buyerPremiumAmount = _sentPremium;
        auctions[_auctionId].currentBidder = _msgSender();

        if (
            _endTime(_auctionId) < block.timestamp.add(iFirstDibsMarketSettings.globalTimeBuffer())
        ) {
            auctions[_auctionId].settings.duration += uint32(
                block.timestamp.add(iFirstDibsMarketSettings.globalTimeBuffer()).sub(
                    _endTime(_auctionId)
                )
            );
        }

        emit AuctionBid(
            _auctionId,
            _msgSender(),
            _sentBid,
            _sentPremium,
            auctions[_auctionId].settings.duration,
            auctions[_auctionId].startTime
        );
    }

    function endAuction(uint256 _auctionId)
        external
        nonReentrant
        auctionExists(_auctionId)
        notPaused(_auctionId)
    {

        require(
            auctions[_auctionId].currentBidder != address(0),
            'endAuction: no bidders; use cancelAuction'
        );

        require(
            auctions[_auctionId].startTime > 0 && //  auction has started
                block.timestamp >= _endTime(_auctionId), // past the endtime of the auction,
            'endAuction: auction is not complete'
        );

        Auction memory auction = auctions[_auctionId];

        uint256 commissionFee = auction.currentBid.amount.mul(auction.settings.commissionRate).div(
            100
        );
        if (commissionFee.add(auction.currentBid.buyerPremiumAmount) > 0) {
            _tryTransferThenEscrow(
                iFirstDibsMarketSettings.commissionAddress(),
                commissionFee.add(auction.currentBid.buyerPremiumAmount)
            );
        }

        address nftCreator = iERC721TokenCreatorRegistry.tokenCreator(
            auction.nftAddress,
            auction.tokenId
        );

        uint256 creatorRoyaltyFee = 0;
        if (nftCreator == auction.payee) {
            _asyncTransfer(auction.payee, auction.currentBid.amount.sub(commissionFee));
        } else {
            creatorRoyaltyFee = auction
            .currentBid
            .amount
            .mul(auction.settings.creatorRoyaltyRate)
            .div(100);
            _asyncTransfer(nftCreator, creatorRoyaltyFee);

            _asyncTransfer(
                auction.payee,
                auction.currentBid.amount.sub(creatorRoyaltyFee).sub(commissionFee)
            );
        }

        IERC721(auction.nftAddress).safeTransferFrom(
            address(this), // from
            auction.currentBidder, // to
            auction.tokenId
        );

        _delete(_auctionId);

        emit AuctionEnded(
            _auctionId,
            auction.payee,
            auction.currentBidder,
            auction.currentBid.amount,
            auction.currentBid.buyerPremiumAmount,
            commissionFee,
            creatorRoyaltyFee,
            auction.currentBid.amount.sub(creatorRoyaltyFee).sub(commissionFee) // seller payment
        );
    }

    function cancelAuction(uint256 _auctionId)
        external
        nonReentrant
        auctionExists(_auctionId)
        senderIsAuctionCreatorOrAdmin(_auctionId)
    {

        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            require(
                auctions[_auctionId].currentBidder == address(0),
                'cancelAuction: auction with bids may not be canceled'
            );
        }

        IERC721(auctions[_auctionId].nftAddress).safeTransferFrom(
            address(this),
            auctions[_auctionId].payee,
            auctions[_auctionId].tokenId
        );

        uint256 refundAmount = 0;
        if (auctions[_auctionId].currentBidder != address(0)) {
            refundAmount = auctions[_auctionId].currentBid.amount.add(
                auctions[_auctionId].currentBid.buyerPremiumAmount
            );
            _tryTransferThenEscrow(auctions[_auctionId].currentBidder, refundAmount);
        }

        _delete(_auctionId);
        emit AuctionCanceled(_auctionId, _msgSender(), refundAmount);
    }

    function setAuctionPause(uint256 _auctionId, bool _paused)
        external
        auctionExists(_auctionId)
        senderIsAuctionCreatorOrAdmin(_auctionId)
    {

        if (_paused == auctions[_auctionId].paused) {
            return;
        }
        if (_paused) {
            auctions[_auctionId].pausedTime = uint64(block.timestamp);
        } else if (
            !_paused && auctions[_auctionId].pausedTime > 0 && auctions[_auctionId].startTime > 0
        ) {
            auctions[_auctionId].settings.duration += uint32(
                block.timestamp.sub(auctions[_auctionId].pausedTime)
            );
            auctions[_auctionId].pausedTime = 0;
        }
        auctions[_auctionId].paused = _paused;
        emit AuctionPaused(
            _auctionId,
            auctions[_auctionId].payee,
            _msgSender(),
            _paused,
            auctions[_auctionId].settings.duration
        );
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external override returns (bytes4) {

        return IERC721Receiver(address(this)).onERC721Received.selector;
    }

    function _endTime(uint256 _auctionId) private view returns (uint256) {

        return auctions[_auctionId].startTime + auctions[_auctionId].settings.duration;
    }

    function _delete(uint256 _auctionId) private {

        address nftAddress = auctions[_auctionId].nftAddress;
        uint256 tokenId = auctions[_auctionId].tokenId;
        delete auctionIds[nftAddress][tokenId];
        delete auctions[_auctionId];
    }

    function _tryTransferThenEscrow(address _to, uint256 _amount) private {

        (bool success, ) = _to.call{ value: _amount, gas: 30000 }('');
        if (!success) {
            _asyncTransfer(_to, _amount);
        }
    }
}