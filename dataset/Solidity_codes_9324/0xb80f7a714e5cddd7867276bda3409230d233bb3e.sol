
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

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

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

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
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
}// MIT

pragma solidity ^0.8.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
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

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
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

pragma solidity ^0.8.0;


contract Escrow is Ownable {

    using Address for address payable;

    event Deposited(address indexed payee, uint256 weiAmount);
    event Withdrawn(address indexed payee, uint256 weiAmount);

    mapping(address => uint256) private _deposits;

    function depositsOf(address payee) public view returns (uint256) {

        return _deposits[payee];
    }

    function deposit(address payee) public payable virtual onlyOwner {

        uint256 amount = msg.value;
        _deposits[payee] += amount;
        emit Deposited(payee, amount);
    }

    function withdraw(address payable payee) public virtual onlyOwner {

        uint256 payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract PullPayment {
    Escrow private immutable _escrow;

    constructor() {
        _escrow = new Escrow();
    }

    function withdrawPayments(address payable payee) public virtual {
        _escrow.withdraw(payee);
    }

    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    function _asyncTransfer(address dest, uint256 amount) internal virtual {
        _escrow.deposit{value: amount}(dest);
    }
}// MIT

pragma solidity ^0.8.0;

interface IOwnable {

    function owner() external view returns (address);

}//Unlicensed
pragma solidity 0.8.13;

interface IFirstDibsMarketSettingsV2 {

    function globalBuyerPremium() external view returns (uint32);


    function globalMarketCommission() external view returns (uint32);


    function globalMinimumBidIncrement() external view returns (uint32);


    function globalTimeBuffer() external view returns (uint32);


    function globalAuctionDuration() external view returns (uint32);


    function commissionAddress() external view returns (address);

}// MIT

pragma solidity 0.8.13;



interface IRoyaltyEngineV1 is IERC165 {

    function getRoyalty(
        address tokenAddress,
        uint256 tokenId,
        uint256 value
    ) external returns (address payable[] memory recipients, uint256[] memory amounts);


    function getRoyaltyView(
        address tokenAddress,
        uint256 tokenId,
        uint256 value
    ) external view returns (address payable[] memory recipients, uint256[] memory amounts);

}//Unlicensed
pragma solidity 0.8.13;

library BidUtils {

    function _getSentBidAndPremium(uint256 _amount, uint64 _buyerPremiumRate)
        private
        pure
        returns (
            uint256, /*sentBid*/
            uint256 /*sentPremium*/
        )
    {

        uint256 bpRate = _buyerPremiumRate + 10000;
        uint256 _sentBid = uint256((_amount * 10000) / bpRate);
        uint256 _sentPremium = uint256(_amount - _sentBid);
        return (_sentBid, _sentPremium);
    }

    function validateAndGetBid(
        uint256 _totalAmount,
        uint64 _buyerPremium,
        uint256 _reservePrice,
        uint256 _currentBidAmount,
        uint256 _minimumBidIncrement,
        address _currentBidder
    )
        internal
        pure
        returns (
            uint256, /*sentBid*/
            uint256 /*sentPremium*/
        )
    {

        (uint256 _sentBid, uint256 _sentPremium) = _getSentBidAndPremium(
            _totalAmount,
            _buyerPremium
        );
        if (_currentBidder == address(0)) {
            require(_sentBid >= _reservePrice, 'reserve not met');
        } else {
            require(
                _sentBid >= _currentBidAmount + (_currentBidAmount * _minimumBidIncrement) / 10000,
                'minimum bid not met'
            );
        }
        return (_sentBid, _sentPremium);
    }
}// MIT

pragma solidity 0.8.13;


abstract contract FirstDibsERC2771Context is Context, Ownable {
    address private _trustedForwarder;

    constructor(address trustedForwarder) {
        _trustedForwarder = trustedForwarder;
    }

    function setTrustedForwarder(address trustedForwarder) external onlyOwner {
        _trustedForwarder = trustedForwarder;
    }

    function isTrustedForwarder(address forwarder) public view virtual returns (bool) {
        return forwarder == _trustedForwarder;
    }

    function _msgSender() internal view virtual override returns (address sender) {
        if (isTrustedForwarder(msg.sender)) {
            assembly {
                sender := shr(96, calldataload(sub(calldatasize(), 20)))
            }
        } else {
            return super._msgSender();
        }
    }

    function _msgData() internal view virtual override returns (bytes calldata) {
        if (isTrustedForwarder(msg.sender)) {
            return msg.data[:msg.data.length - 20];
        } else {
            return super._msgData();
        }
    }
}//BSD 3-Clause
pragma solidity 0.8.13;

interface IERC721TokenCreatorV2 {

    function tokenCreator(address _nftAddress, uint256 _tokenId)
        external
        view
        returns (address payable);

}//Unlicensed
pragma solidity 0.8.13;



contract FirstDibsAuctionV2 is
    PullPayment,
    AccessControl,
    ReentrancyGuard,
    IERC721Receiver,
    FirstDibsERC2771Context
{

    using BidUtils for uint256;

    bytes32 public constant BIDDER_ROLE = keccak256('BIDDER_ROLE');
    bool public bidderRoleRequired; // if true, bids require bidder having BIDDER_ROLE role
    bool public globalPaused; // flag for pausing all auctions
    IFirstDibsMarketSettingsV2 public iFirstDibsMarketSettings;
    IERC721TokenCreatorV2 public iERC721TokenCreatorRegistry;
    address public manifoldRoyaltyEngineAddress; // address of the manifold royalty engine https://royaltyregistry.xyz
    address public auctionV1Address; // address of the V1 auction contract, used as the source of bidder role truth

    mapping(uint256 => Auction) public auctions;
    mapping(address => mapping(uint256 => uint256)) public auctionIds;

    uint256 private auctionIdsCounter;

    struct AuctionSettings {
        uint32 buyerPremium; // RBS; added on top of current bid
        uint32 duration; // defaults to globalDuration
        uint32 minimumBidIncrement; // defaults to globalMinimumBidIncrement
        uint32 commissionRate; // percent; defaults to globalMarketCommission
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
        address tokenOwner; // address of the owner of the token
        address payable fundsRecipient; // address of auction proceeds recipient
        address payable currentBidder; // current winning bidder of the auction
        address auctionCreator; // address of the creator of the auction (whoever called the createAuction method)
        AuctionSettings settings;
        Bid currentBid;
    }

    function onlyAdmin() internal view {

        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), 'caller is not an admin');
    }

    function notPaused(uint256 auctionId) internal view {

        require(!globalPaused && !auctions[auctionId].paused, 'auction paused');
    }

    function auctionExists(uint256 auctionId) internal view {

        require(auctions[auctionId].fundsRecipient != address(0), "auction doesn't exist");
    }

    function hasBid(uint256 auctionId) internal view {

        if (!hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            require(
                auctions[auctionId].currentBidder == address(0),
                'only admin can update state of auction with bids'
            );
        }
    }

    function senderIsAuctionCreatorOrAdmin(uint256 auctionId) internal view {

        require(
            _msgSender() == auctions[auctionId].auctionCreator ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            'must be auction creator or admin'
        );
    }

    function checkZeroAddress(address addr) internal pure {

        require(addr != address(0), '0 address not allowed');
    }

    event AuctionCreated(
        uint256 indexed auctionId,
        address indexed nftAddress,
        uint256 indexed tokenId,
        address tokenSeller,
        address fundsRecipient,
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

    event TransferFailed(address to, uint256 amount);

    constructor(
        address _marketSettings,
        address _creatorRegistry,
        address _trustedForwarder,
        address _manifoldRoyaltyEngineAddress,
        address _auctionV1Address
    ) FirstDibsERC2771Context(_trustedForwarder) {
        require(
            _marketSettings != address(0) &&
                _creatorRegistry != address(0) &&
                _manifoldRoyaltyEngineAddress != address(0) &&
                _auctionV1Address != address(0),
            '0 address for contract ref'
        );
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender()); // deployer of the contract gets admin permissions
        iFirstDibsMarketSettings = IFirstDibsMarketSettingsV2(_marketSettings);
        iERC721TokenCreatorRegistry = IERC721TokenCreatorV2(_creatorRegistry);
        manifoldRoyaltyEngineAddress = _manifoldRoyaltyEngineAddress;
        auctionV1Address = _auctionV1Address;
        bidderRoleRequired = true;
        auctionIdsCounter = 0;
    }

    function setManifoldRoyaltyEngineAddress(address _manifoldRoyaltyEngineAddress) external {

        onlyAdmin();
        checkZeroAddress(_manifoldRoyaltyEngineAddress);
        manifoldRoyaltyEngineAddress = _manifoldRoyaltyEngineAddress;
    }

    function setIFirstDibsMarketSettings(address _iFirstDibsMarketSettings) external {

        onlyAdmin();
        checkZeroAddress(_iFirstDibsMarketSettings);
        iFirstDibsMarketSettings = IFirstDibsMarketSettingsV2(_iFirstDibsMarketSettings);
    }

    function setIERC721TokenCreatorRegistry(address _iERC721TokenCreatorRegistry) external {

        onlyAdmin();
        checkZeroAddress(_iERC721TokenCreatorRegistry);
        iERC721TokenCreatorRegistry = IERC721TokenCreatorV2(_iERC721TokenCreatorRegistry);
    }

    function setBidderRoleRequired(bool _bidderRole) external {

        onlyAdmin();
        bidderRoleRequired = _bidderRole;
    }

    function setGlobalPaused(bool _paused) external {

        onlyAdmin();
        globalPaused = _paused;
    }

    function createAuction(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _reservePrice,
        bool _pausedArg,
        uint64 _startTimeArg,
        uint32 _auctionDurationArg,
        address _fundsRecipient
    ) external {

        adminCreateAuction(
            _nftAddress,
            _tokenId,
            _reservePrice,
            _pausedArg,
            _startTimeArg,
            _auctionDurationArg,
            _fundsRecipient,
            10001 // adminCreateAuction function ignores values > 10000
        );
    }

    function adminCreateAuction(
        address _nftAddress,
        uint256 _tokenId,
        uint256 _reservePrice,
        bool _pausedArg,
        uint64 _startTimeArg,
        uint32 _auctionDurationArg,
        address _fundsRecipient,
        uint16 _commissionRateArg
    ) public {

        notPaused(0);
        address tokenOwner = IERC721(_nftAddress).ownerOf(_tokenId);
        require(
            _msgSender() == tokenOwner ||
                hasRole(DEFAULT_ADMIN_ROLE, _msgSender()) ||
                IERC721(_nftAddress).getApproved(_tokenId) == _msgSender() ||
                IERC721(_nftAddress).isApprovedForAll(tokenOwner, _msgSender()),
            'must be token owner, admin, or approved'
        );

        require(_fundsRecipient != address(0), 'must pass funds recipient');

        require(auctionIds[_nftAddress][_tokenId] == 0, 'auction already exists');

        require(_reservePrice > 0, 'Reserve must be > 0');

        Auction memory auction = Auction({
            currentBid: Bid({ amount: 0, buyerPremiumAmount: 0 }),
            nftAddress: _nftAddress,
            tokenId: _tokenId,
            tokenOwner: tokenOwner,
            fundsRecipient: payable(_fundsRecipient), // pass in the fundsRecipient
            auctionCreator: _msgSender(),
            reservePrice: _reservePrice, // minimum bid threshold for auction to begin
            startTime: 0,
            currentBidder: payable(address(0)), // there is no bidder at auction creation
            paused: _pausedArg, // is individual auction paused
            pausedTime: 0, // when the auction was paused
            settings: AuctionSettings({ // Defaults to global market settings; admins may override
                buyerPremium: iFirstDibsMarketSettings.globalBuyerPremium(),
                duration: iFirstDibsMarketSettings.globalAuctionDuration(),
                minimumBidIncrement: iFirstDibsMarketSettings.globalMinimumBidIncrement(),
                commissionRate: iFirstDibsMarketSettings.globalMarketCommission()
            })
        });
        if (_auctionDurationArg > 0) {
            require(
                _auctionDurationArg >= iFirstDibsMarketSettings.globalTimeBuffer(),
                'duration must be >= time buffer'
            );
            auction.settings.duration = _auctionDurationArg;
        }

        if (_startTimeArg > 0) {
            require(block.timestamp < _startTimeArg, 'start time must be in the future');
            auction.startTime = _startTimeArg;
            auction.paused = false;
        }

        if (hasRole(DEFAULT_ADMIN_ROLE, _msgSender())) {
            if (_commissionRateArg <= 10000) {
                auction.settings.commissionRate = _commissionRateArg;
            }
        }

        auctionIdsCounter++;
        auctions[auctionIdsCounter] = auction;
        auctionIds[_nftAddress][_tokenId] = auctionIdsCounter;

        IERC721(_nftAddress).safeTransferFrom(tokenOwner, address(this), _tokenId);

        emit AuctionCreated(
            auctionIdsCounter,
            _nftAddress,
            _tokenId,
            tokenOwner,
            _fundsRecipient,
            _reservePrice,
            auction.paused,
            _msgSender(),
            auction.settings.duration
        );
    }

    function bid(uint256 _auctionId, uint256 _amount) external payable nonReentrant {

        auctionExists(_auctionId);
        notPaused(_auctionId);

        if (bidderRoleRequired == true) {
            require(
                IAccessControl(auctionV1Address).hasRole(BIDDER_ROLE, _msgSender()),
                'bidder role required'
            );
        }
        require(msg.value > 0 && _amount == msg.value, 'invalid bid value');
        require(block.timestamp >= auctions[_auctionId].startTime, 'auction not started');
        require(
            auctions[_auctionId].startTime == 0 || block.timestamp < _endTime(_auctionId),
            'auction expired'
        );
        require(
            auctions[_auctionId].currentBidder != _msgSender() &&
                auctions[_auctionId].fundsRecipient != _msgSender() &&
                auctions[_auctionId].tokenOwner != _msgSender(),
            'invalid bidder'
        );

        (uint256 _sentBid, uint256 _sentPremium) = _amount.validateAndGetBid(
            auctions[_auctionId].settings.buyerPremium,
            auctions[_auctionId].reservePrice,
            auctions[_auctionId].currentBid.amount,
            auctions[_auctionId].settings.minimumBidIncrement,
            auctions[_auctionId].currentBidder
        );

        if (auctions[_auctionId].startTime == 0) {
            auctions[_auctionId].startTime = uint64(block.timestamp);
        } else if (auctions[_auctionId].currentBidder != address(0)) {
            _tryTransferThenEscrow(
                auctions[_auctionId].currentBidder, // prior
                auctions[_auctionId].currentBid.amount +
                    auctions[_auctionId].currentBid.buyerPremiumAmount // refund amount
            );
        }
        auctions[_auctionId].currentBid.amount = _sentBid;
        auctions[_auctionId].currentBid.buyerPremiumAmount = _sentPremium;
        auctions[_auctionId].currentBidder = payable(_msgSender());

        if (
            _endTime(_auctionId) < block.timestamp + iFirstDibsMarketSettings.globalTimeBuffer()
        ) {
            auctions[_auctionId].settings.duration += uint32(
                block.timestamp + iFirstDibsMarketSettings.globalTimeBuffer() - _endTime(_auctionId)
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

    function endAuction(uint256 _auctionId) external nonReentrant {

        auctionExists(_auctionId);
        notPaused(_auctionId);
        require(auctions[_auctionId].currentBidder != address(0), 'no bidders; use cancelAuction');

        require(
            auctions[_auctionId].startTime > 0 && //  auction has started
                block.timestamp >= _endTime(_auctionId), // past the endtime of the auction,
            'auction is not complete'
        );

        Auction memory auction = auctions[_auctionId];
        _delete(_auctionId);

        uint256 commissionFee = (auction.currentBid.amount * auction.settings.commissionRate) /
            10000;
        if (commissionFee + auction.currentBid.buyerPremiumAmount > 0) {
            _tryTransferThenEscrow(
                iFirstDibsMarketSettings.commissionAddress(),
                commissionFee + auction.currentBid.buyerPremiumAmount
            );
        }

        address nftCreator = iERC721TokenCreatorRegistry.tokenCreator(
            auction.nftAddress,
            auction.tokenId
        );

        if (nftCreator == address(0)) {
            try IOwnable(auction.nftAddress).owner() returns (address owner) {
                nftCreator = owner;
            } catch {}
        }

        uint256 royaltyAmount = 0;
        if (nftCreator != auction.tokenOwner && nftCreator != address(0)) {
            (
                address payable[] memory royaltyRecipients,
                uint256[] memory amounts
            ) = IRoyaltyEngineV1(manifoldRoyaltyEngineAddress).getRoyalty(
                    auction.nftAddress,
                    auction.tokenId,
                    auction.currentBid.amount
                );
            uint256 arrLength = royaltyRecipients.length;
            for (uint256 i = 0; i < arrLength; ) {
                if (amounts[i] != 0 && royaltyRecipients[i] != address(0)) {
                    royaltyAmount += amounts[i];
                    _sendFunds(royaltyRecipients[i], amounts[i]);
                }
                unchecked {
                    ++i;
                }
            }
        }
        uint256 sellerFee = auction.currentBid.amount - royaltyAmount - commissionFee;
        _sendFunds(auction.fundsRecipient, sellerFee);

        IERC721(auction.nftAddress).safeTransferFrom(
            address(this), // from
            auction.currentBidder, // to
            auction.tokenId
        );
        emit AuctionEnded(
            _auctionId,
            auction.tokenOwner,
            auction.currentBidder,
            auction.currentBid.amount,
            auction.currentBid.buyerPremiumAmount,
            commissionFee,
            royaltyAmount,
            sellerFee
        );
    }

    function cancelAuction(uint256 _auctionId) external nonReentrant {
        senderIsAuctionCreatorOrAdmin(_auctionId);
        auctionExists(_auctionId);
        hasBid(_auctionId);

        Auction memory auction = auctions[_auctionId];
        _delete(_auctionId);

        IERC721(auction.nftAddress).safeTransferFrom(
            address(this),
            auction.tokenOwner,
            auction.tokenId
        );

        uint256 refundAmount = 0;
        if (auction.currentBidder != address(0)) {
            refundAmount = auction.currentBid.amount + auction.currentBid.buyerPremiumAmount;
            _tryTransferThenEscrow(auction.currentBidder, refundAmount);
        }

        emit AuctionCanceled(_auctionId, _msgSender(), refundAmount);
    }

    function setAuctionPause(uint256 _auctionId, bool _paused) external {
        senderIsAuctionCreatorOrAdmin(_auctionId);
        auctionExists(_auctionId);
        hasBid(_auctionId);

        if (_paused == auctions[_auctionId].paused) {
            revert('auction paused state not updated');
        }
        if (_paused) {
            auctions[_auctionId].pausedTime = uint64(block.timestamp);
        } else if (
            !_paused && auctions[_auctionId].pausedTime > 0 && auctions[_auctionId].startTime > 0
        ) {
            if (auctions[_auctionId].currentBidder != address(0)) {
                auctions[_auctionId].settings.duration += uint32(
                    block.timestamp - auctions[_auctionId].pausedTime
                );
            }
            auctions[_auctionId].pausedTime = 0;
        }
        auctions[_auctionId].paused = _paused;
        emit AuctionPaused(
            _auctionId,
            auctions[_auctionId].tokenOwner,
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
    ) external view override returns (bytes4) {
        return IERC721Receiver(address(this)).onERC721Received.selector;
    }

    function _endTime(uint256 _auctionId) private view returns (uint256) {
        return auctions[_auctionId].startTime + auctions[_auctionId].settings.duration;
    }

    function _delete(uint256 _auctionId) private {
        delete auctionIds[auctions[_auctionId].nftAddress][auctions[_auctionId].tokenId];
        delete auctions[_auctionId];
    }

    function _tryTransferThenEscrow(address _to, uint256 _amount) private {
        (bool success, ) = _to.call{ value: _amount, gas: 30000 }('');
        if (!success) {
            emit TransferFailed(_to, _amount);
            _asyncTransfer(_to, _amount);
        }
    }

    function _sendFunds(address _to, uint256 _amount) private {
        if (_to.code.length > 0) {
            _tryTransferThenEscrow(_to, _amount);
        } else {
            _asyncTransfer(_to, _amount);
        }
    }

    function _msgSender()
        internal
        view
        override(Context, FirstDibsERC2771Context)
        returns (address sender)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        override(Context, FirstDibsERC2771Context)
        returns (bytes calldata)
    {
        return super._msgData();
    }
}