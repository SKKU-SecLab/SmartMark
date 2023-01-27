
pragma solidity ^0.8.0;

library AddressUpgradeable {

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


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing ? _isConstructor() : !_initialized, "Initializable: contract is already initialized");

        bool isTopLevelCall = !_initializing;
        if (isTopLevelCall) {
            _initializing = true;
            _initialized = true;
        }

        _;

        if (isTopLevelCall) {
            _initializing = false;
        }
    }

    modifier onlyInitializing() {
        require(_initializing, "Initializable: contract is not initializing");
        _;
    }

    function _isConstructor() private view returns (bool) {
        return !AddressUpgradeable.isContract(address(this));
    }
}// MIT OR Apache-2.0

pragma solidity 0.8.4;


abstract contract WethioTreasuryNode is Initializable {
    using AddressUpgradeable for address payable;

    address payable private treasury;

    function _initializeWethioTreasuryNode(address payable _treasury)
        internal
        initializer
    {
        require(
            _treasury.isContract(),
            "WethioTreasuryNode: Address is not a contract"
        );
        treasury = _treasury;
    }

    function getWethioTreasury() public view returns (address payable) {
        return treasury;
    }

    function _updateWethioTreasury(address payable _treasury) internal {
        require(
            _treasury.isContract(),
            "WethioTreasuryNode: Address is not a contract"
        );
        treasury = _treasury;
    }

    uint256[2000] private __gap;
}// MIT OR Apache-2.0

pragma solidity 0.8.4;

interface IAdminRole {

    function isAdmin(address account) external view returns (bool);

}// MIT OR Apache-2.0

pragma solidity 0.8.4;



abstract contract WethioAdminRole is WethioTreasuryNode {

    modifier onlyWethioAdmin() {
        require(
            IAdminRole(getWethioTreasury()).isAdmin(msg.sender),
            "WethioAdminRole: caller does not have the Admin role"
        );
        _;
    }

    function _isWethioAdmin() internal view returns (bool) {
        return IAdminRole(getWethioTreasury()).isAdmin(msg.sender);
    }
}// MIT

pragma solidity ^0.8.0;


library SafeMathUpgradeable {

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

abstract contract ReentrancyGuardUpgradeable is Initializable {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal onlyInitializing {
        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal onlyInitializing {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}// MIT OR Apache-2.0

pragma solidity 0.8.4;


abstract contract SendValueWithFallbackWithdraw is ReentrancyGuardUpgradeable {
    using AddressUpgradeable for address payable;
    using SafeMathUpgradeable for uint256;

    mapping(address => uint256) private pendingWithdrawals;

    event WithdrawPending(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);

    function getPendingWithdrawal(address user) public view returns (uint256) {
        return pendingWithdrawals[user];
    }

    function withdraw() public {
        withdrawFor(payable(msg.sender));
    }

    function withdrawFor(address payable user) public nonReentrant {
        uint256 amount = pendingWithdrawals[user];
        require(amount > 0, "No funds are pending withdrawal");
        pendingWithdrawals[user] = 0;
        user.sendValue(amount);
        emit Withdrawal(user, amount);
    }

    function _sendValueWithFallbackWithdrawWithLowGasLimit(
        address user,
        uint256 amount
    ) internal {
        _sendValueWithFallbackWithdraw(user, amount, 20000);
    }

    function _sendValueWithFallbackWithdrawWithMediumGasLimit(
        address user,
        uint256 amount
    ) internal {
        _sendValueWithFallbackWithdraw(user, amount, 210000);
    }

    function _sendValueWithFallbackWithdraw(
        address user,
        uint256 amount,
        uint256 gasLimit
    ) private {
        if (amount == 0 || user == address(0)) {
            return;
        }
        (bool success, ) = payable(user).call{value: amount, gas: gasLimit}("");
        if (!success) {
            pendingWithdrawals[user] = pendingWithdrawals[user].add(amount);
            emit WithdrawPending(user, amount);
        }
    }

    uint256[499] private ______gap;
}// MIT OR Apache-2.0

pragma solidity 0.8.4;

abstract contract NFTMarketAuction {
    uint256 private nextAuctionId;

    function _initializeNFTMarketAuction() internal {
        nextAuctionId = 1;
    }

    function _getNextAndIncrementAuctionId() internal returns (uint256) {
        return nextAuctionId++;
    }

    uint256[1000] private ______gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC721Upgradeable is IERC165Upgradeable {

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

}// MIT OR Apache-2.0

pragma solidity 0.8.4;

abstract contract Constants {
    uint256 internal constant BASIS_POINTS = 10000;
}// MIT OR Apache-2.0

pragma solidity 0.8.4;
pragma abicoder v2; // solhint-disable-line



abstract contract NFTMarketReserveAuction is
    Constants,
    WethioAdminRole,
    ReentrancyGuardUpgradeable,
    SendValueWithFallbackWithdraw,
    NFTMarketAuction
{
    using SafeMathUpgradeable for uint256;

    struct ReserveAuction {
        address nftContract;
        uint256[] tokenId;
        address seller;
        uint256 duration;
        uint256 extensionDuration;
        uint256 endTime;
        address bidder;
        uint256 amount;
        bool canAuction;
    }

    mapping(uint256 => ReserveAuction) private auctionIdToAuction;

    uint256 private _minPercentIncrementInBasisPoints;

    uint256 private _duration;

    uint256 private constant MAX_MAX_DURATION = 1000 days;

    uint256 private constant EXTENSION_DURATION = 15 minutes;

    event ReserveAuctionConfigUpdated(
        uint256 minPercentIncrementInBasisPoints,
        uint256 maxBidIncrementRequirement,
        uint256 duration,
        uint256 extensionDuration,
        uint256 goLiveDate
    );

    event ReserveAuctionCreated(
        address indexed seller,
        address indexed nftContract,
        uint256[] tokenId,
        uint256 duration,
        uint256 extensionDuration,
        uint256 reservePrice,
        uint256 auctionId,
        bool canAuction
    );
    event ReserveAuctionUpdated(
        uint256 indexed auctionId,
        uint256 reservePrice
    );

    event ReserveAuctionCanceled(uint256 indexed auctionId);
    event ReserveAuctionBidPlaced(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 amount,
        uint256 endTime
    );
    event ReserveAuctionFinalized(
        uint256 indexed auctionId,
        address indexed seller,
        address indexed bidder,
        uint256 amount
    );
    event ReserveAuctionCanceledByAdmin(
        uint256 indexed auctionId,
        string reason
    );

    modifier onlyValidAuctionConfig(uint256 reservePrice) {
        require(
            reservePrice > 0,
            "NFTMarketReserveAuction: Reserve price must be at least 1 wei"
        );
        _;
    }

    function getReserveAuction(uint256 auctionId)
        public
        view
        returns (ReserveAuction memory)
    {
        return auctionIdToAuction[auctionId];
    }

    function getReserveAuctionConfig()
        public
        view
        returns (uint256 minPercentIncrementInBasisPoints, uint256 duration)
    {
        minPercentIncrementInBasisPoints = _minPercentIncrementInBasisPoints;
        duration = _duration;
    }

    function _initializeNFTMarketReserveAuction() internal {
        _duration = 21 days; // A sensible default value
    }

    function _updateReserveAuctionConfig(
        uint256 minPercentIncrementInBasisPoints,
        uint256 duration
    ) internal {
        require(
            minPercentIncrementInBasisPoints <= BASIS_POINTS,
            "NFTMarketReserveAuction: Min increment must be <= 100%"
        );
        require(
            duration <= MAX_MAX_DURATION,
            "NFTMarketReserveAuction: Duration must be <= 1000 days"
        );
        require(
            duration >= EXTENSION_DURATION,
            "NFTMarketReserveAuction: Duration must be >= EXTENSION_DURATION"
        );
        _minPercentIncrementInBasisPoints = minPercentIncrementInBasisPoints;
        _duration = duration;

        emit ReserveAuctionConfigUpdated(
            minPercentIncrementInBasisPoints,
            0,
            duration,
            EXTENSION_DURATION,
            0
        );
    }

    function createReserveAuction(
        address nftContract,
        uint256[] memory tokenIds,
        uint256 reservePrice
    ) external onlyValidAuctionConfig(reservePrice) nonReentrant {
        require(tokenIds.length > 0, "Token id list can't be empty");
        uint256 auctionId = _getNextAndIncrementAuctionId();
        auctionIdToAuction[auctionId].nftContract = nftContract;
        auctionIdToAuction[auctionId].tokenId = tokenIds;
        auctionIdToAuction[auctionId].seller = address(msg.sender);
        auctionIdToAuction[auctionId].duration = _duration;
        auctionIdToAuction[auctionId].extensionDuration = EXTENSION_DURATION;
        auctionIdToAuction[auctionId].amount = reservePrice;
        if (_isWethioAdmin()) {
            auctionIdToAuction[auctionId].canAuction = true;
        }

        for (uint256 i = 0; i < tokenIds.length; i++) {
            IERC721Upgradeable(nftContract).transferFrom(
                msg.sender,
                address(this),
                tokenIds[i]
            );
        }

        emit ReserveAuctionCreated(
            msg.sender,
            nftContract,
            tokenIds,
            _duration,
            EXTENSION_DURATION,
            reservePrice,
            auctionId,
            auctionIdToAuction[auctionId].canAuction
        );
    }

    function updateReserveAuction(uint256 auctionId, uint256 reservePrice)
        external
        onlyValidAuctionConfig(reservePrice)
    {
        ReserveAuction storage auction = auctionIdToAuction[auctionId];
        require(
            auction.seller == msg.sender,
            "NFTMarketReserveAuction: Not your auction"
        );
        require(
            auction.endTime == 0,
            "NFTMarketReserveAuction: Auction in progress"
        );

        auction.amount = reservePrice;

        emit ReserveAuctionUpdated(auctionId, reservePrice);
    }

    function cancelReserveAuction(uint256 auctionId) external nonReentrant {
        ReserveAuction memory auction = auctionIdToAuction[auctionId];
        require(
            auction.seller == msg.sender,
            "NFTMarketReserveAuction: Not your auction"
        );
        require(
            auction.endTime == 0,
            "NFTMarketReserveAuction: Auction in progress"
        );

        delete auctionIdToAuction[auctionId];

        for (uint256 k = 0; k < auction.tokenId.length; k++) {
            IERC721Upgradeable(auction.nftContract).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId[k]
            );
        }

        emit ReserveAuctionCanceled(auctionId);
    }

    function placeBid(uint256 auctionId) external payable nonReentrant {
        ReserveAuction storage auction = auctionIdToAuction[auctionId];
        require(
            auction.canAuction == true,
            "NFTMarketReserveAuction: Auction not found"
        );

        if (auction.endTime == 0) {
            require(
                auction.amount <= msg.value,
                "NFTMarketReserveAuction: Bid must be at least the reserve price"
            );
        } else {
            require(
                auction.endTime >= block.timestamp,
                "NFTMarketReserveAuction: Auction is over"
            );
            require(
                auction.bidder != msg.sender,
                "NFTMarketReserveAuction: You already have an outstanding bid"
            );
            uint256 minAmount = _getMinBidAmountForReserveAuction(
                auction.amount
            );
            require(
                msg.value >= minAmount,
                "NFTMarketReserveAuction: Bid amount too low"
            );
        }

        if (auction.endTime == 0) {
            auction.amount = msg.value;
            auction.bidder = msg.sender;
            auction.endTime = block.timestamp + auction.duration;
        } else {
            uint256 originalAmount = auction.amount;
            address originalBidder = auction.bidder;
            auction.amount = msg.value;
            auction.bidder = msg.sender;

            if (auction.endTime - block.timestamp < auction.extensionDuration) {
                auction.endTime = block.timestamp + auction.extensionDuration;
            }

            _sendValueWithFallbackWithdrawWithLowGasLimit(
                originalBidder,
                originalAmount
            );
        }

        emit ReserveAuctionBidPlaced(
            auctionId,
            msg.sender,
            msg.value,
            auction.endTime
        );
    }

    function finalizeReserveAuction(uint256 auctionId) external nonReentrant {
        ReserveAuction memory auction = auctionIdToAuction[auctionId];
        require(
            auction.endTime > 0,
            "NFTMarketReserveAuction: Auction was already settled"
        );
        require(
            auction.endTime < block.timestamp,
            "NFTMarketReserveAuction: Auction still in progress"
        );

        delete auctionIdToAuction[auctionId];

        for (uint256 j = 0; j < auction.tokenId.length; j++) {
            IERC721Upgradeable(auction.nftContract).transferFrom(
                address(this),
                auction.bidder,
                auction.tokenId[j]
            );
        }

        _sendValueWithFallbackWithdrawWithMediumGasLimit(
            auction.seller,
            auction.amount
        );

        emit ReserveAuctionFinalized(
            auctionId,
            auction.seller,
            auction.bidder,
            auction.amount
        );
    }

    function getMinBidAmount(uint256 auctionId) public view returns (uint256) {
        ReserveAuction storage auction = auctionIdToAuction[auctionId];
        if (auction.endTime == 0) {
            return auction.amount;
        }
        return _getMinBidAmountForReserveAuction(auction.amount);
    }

    function _getMinBidAmountForReserveAuction(uint256 currentBidAmount)
        private
        view
        returns (uint256)
    {
        uint256 minIncrement = currentBidAmount.mul(
            _minPercentIncrementInBasisPoints
        ) / BASIS_POINTS;
        if (minIncrement == 0) {
            return currentBidAmount.add(1);
        }
        return minIncrement.add(currentBidAmount);
    }

    function adminCancelReserveAuction(uint256 auctionId, string memory reason)
        public
        onlyWethioAdmin
    {
        require(
            bytes(reason).length > 0,
            "NFTMarketReserveAuction: Include a reason for this cancellation"
        );
        ReserveAuction memory auction = auctionIdToAuction[auctionId];
        require(
            auction.amount > 0,
            "NFTMarketReserveAuction: Auction not found"
        );

        delete auctionIdToAuction[auctionId];

        for (uint256 k = 0; k < auction.tokenId.length; k++) {
            IERC721Upgradeable(auction.nftContract).transferFrom(
                address(this),
                auction.seller,
                auction.tokenId[k]
            );
        }
        if (auction.endTime > 0) {
            _sendValueWithFallbackWithdrawWithMediumGasLimit(
                auction.bidder,
                auction.amount
            );
        }

        emit ReserveAuctionCanceledByAdmin(auctionId, reason);
    }

    function approveAuctionByAdmin(
        uint256 auctionId,
        bool status,
        string memory reason
    ) external onlyWethioAdmin {
        ReserveAuction memory auction = auctionIdToAuction[auctionId];
        require(
            auction.canAuction == false && auction.amount > 0,
            "Already approved or auction don't exist"
        );
        require(auction.endTime == 0, "Auction already started");

        if (status) {
            auctionIdToAuction[auctionId].canAuction = true;
        } else {
            adminCancelReserveAuction(auctionId, reason);
        }
    }

    uint256[1000] private ______gap;
}// MIT OR Apache-2.0

pragma solidity 0.8.4;



contract WethioMarket is
    WethioTreasuryNode,
    WethioAdminRole,
    ReentrancyGuardUpgradeable,
    SendValueWithFallbackWithdraw,
    NFTMarketAuction,
    NFTMarketReserveAuction
{

    function initialize(address payable treasury) public initializer {

        WethioTreasuryNode._initializeWethioTreasuryNode(treasury);
        NFTMarketAuction._initializeNFTMarketAuction();
        NFTMarketReserveAuction._initializeNFTMarketReserveAuction();
    }

    function adminUpdateConfig(
        uint256 minPercentIncrementInBasisPoints,
        uint256 duration
    ) public onlyWethioAdmin {

        _updateReserveAuctionConfig(minPercentIncrementInBasisPoints, duration);
    }

    function adminUpdateContract(address payable treasury)
        external
        onlyWethioAdmin
    {

        _updateWethioTreasury(treasury);
    }
}