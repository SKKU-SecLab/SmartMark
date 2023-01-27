
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


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address to, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// GNU
pragma solidity >=0.5.0;

interface IWETH is IERC20 {

    function deposit() external payable;


    function withdraw(uint256) external;

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
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
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

interface IRoyaltyFeeManager {

    function calculateRoyaltyFeeAndGetRecipient(
        address collection,
        uint256 tokenId,
        uint256 amount
    ) external view returns (address, uint256);


    function updateRoyaltyInfoForCollection(
        address collection,
        address setter,
        address receiver,
        uint256 fee
    ) external;


    function updateRoyaltyFeeLimit(uint256 _royaltyFeeLimit) external;


    function royaltyInfo(address collection, uint256 amount)
        external
        view
        returns (address, uint256);


    function royaltyFeeInfoCollection(address collection)
        external
        view
        returns (
            address,
            address,
            uint256
        );


    function setJumyTokenRoyalty(
        address collection,
        uint256 tokenId,
        address receiver,
        uint256 percentage
    ) external;

}pragma solidity 0.8.12;
interface ICollectionRegistry {

    function isJumyCollection(address collection) external view returns (bool);

}pragma solidity ^0.8.0;

interface IRewards {

    function purchaseEvent(
        address buyer,
        address seller,
        uint256 price,
        address collection,
        uint256 tokenId
    ) external;


    function purchaseEvent(
        address buyer,
        address seller,
        uint256 price,
        address collection,
        uint256 tokenId,
        uint256 amount
    ) external;

}pragma solidity 0.8.12;

abstract contract Errors {
    error RejectedNullishAddress();
    error RejectedAlreadyInState();
    error InvalidArg(string message);
    error BlacklistedUser();

    error Exchange_Not_The_Token_Owner();
    error Exchange_UnAuthorized_Collection();
    error Exchange_Insufficient_Operator_Privilege();
    error Exchange_Invalid_Nullish_Price();
    error Exchange_Not_Sale_Owner();
    error Exchange_Wrong_Price_Value();
    error Exchange_Listing_Not_Found();
    error Exchange_Rejected_Nullish_Duration();
    error Exchange_Rejected_Nullish_Offer_Value();
    error Exchange_Insufficient_WETH_Allowance(uint256 minAllowance);
    error Exchange_Wrong_Offer_Value(uint256 offerValue);
    error Exchange_Expired_Offer(uint256 expiredAt);
    error Exchange_Unmatched_Quantity(uint256 expected, uint256 received);
    error Exchange_Rejected_Nullish_Quantity();

    error Exchange_Rejected_Genesis_Collection_Only();

    error Exchange_Invalid_Start_Price(uint256 expected, uint256 received);
    error Exchange_Rejected_Ended_Auction(uint256 endsAt, uint256 current);
    error Exchange_Rejected_Must_Be_5_Percent_Higher(
        uint256 expected,
        uint256 received
    );
    error Exchange_Rejected_Not_Auction_Owner();
    error Exchange_Rejected_Auction_In_Progress();
    error Exchange_Auction_Not_Found();
    error Exchange_Rejected_Auction_Not_Started_Yet();

    error Exchange_Starts_At_Must_Be_In_Future();
    error Exchange_Starts_At_Too_Far();
    error Exchange_Drop_Not_Started_Yet();
}pragma solidity 0.8.12;



contract ExchangeCore is Ownable, Pausable, ReentrancyGuard, Errors {

    address public immutable WETH;
    address public immutable JUMY_COLLECTION;

    IRoyaltyFeeManager public royaltyManager;

    ICollectionRegistry public collectionRegistry;

    IRewards public rewardsManager;

    address public protocolFeesRecipient;
    uint256 public protocolFeesPercentage = 500; // 5%, {100_00}Base

    mapping(address => bool) public whitelistedCustomCollection;

    mapping(address => bool) public blackListedCollection;

    mapping(address => bool) public blackListedUser;

    mapping(address => uint256) public specialProtocolFeesPercentage;

    mapping(address => uint256) public failedEthTransfer;

    event RoyaltySent(
        address indexed to,
        address collection,
        uint256 tokenId,
        uint256 amount
    );

    event ServiceFeesCollected(address indexed to, uint256 amount);

    event FailedToSendEth(address to, uint256 amount);

    event FailedEthWithdrawn(address from, address to, uint256 amount);

    event StuckEthWithdrawn(uint256 amount);

    event StuckERC721Transferred(
        address collection,
        uint256 tokenId,
        address to
    );

    event StuckERC1155Transferred(
        address collection,
        uint256 tokenId,
        uint256 amount,
        address to
    );

    modifier onlyNonBlacklistedUsers() {

        if (blackListedUser[msg.sender]) revert BlacklistedUser();
        _;
    }

    modifier onlyAllowedToBeListed(address collection) {

        if (!_isAllowedToBeListed(collection))
            revert Exchange_UnAuthorized_Collection();
        _;
    }

    constructor(
        address weth,
        address jumyNftCollection,
        address royaltyManagerContract,
        address collectionRegistryContract,
        address protocolFeesRecipientWallet
    ) {
        if (protocolFeesRecipientWallet == address(0))
            revert RejectedNullishAddress();

        if (weth == address(0)) revert RejectedNullishAddress();

        if (jumyNftCollection == address(0)) revert RejectedNullishAddress();

        WETH = weth;
        JUMY_COLLECTION = jumyNftCollection;
        royaltyManager = IRoyaltyFeeManager(royaltyManagerContract);
        collectionRegistry = ICollectionRegistry(collectionRegistryContract);
        protocolFeesRecipient = protocolFeesRecipientWallet;
    }

    function isAllowedToBeListed(address collection)
        external
        view
        returns (bool)
    {

        return _isAllowedToBeListed(collection);
    }

    function getProtocolFeesPercentage(address collection)
        external
        view
        returns (uint256)
    {

        return _getProtocolFeesPercentage(collection);
    }

    function _getProtocolFeesPercentage(address collection)
        internal
        view
        returns (uint256)
    {

        uint256 percentage = specialProtocolFeesPercentage[collection];

        if (percentage == 0) return protocolFeesPercentage;
        return percentage;
    }

    function _calculateProtocolFeesAmount(uint256 amount, address collection)
        internal
        view
        returns (uint256)
    {

        return (amount * _getProtocolFeesPercentage(collection)) / 10_000;
    }

    function _isAllowedToBeListed(address collection)
        internal
        view
        returns (bool)
    {

        return ((!blackListedCollection[collection] &&
            (collection == JUMY_COLLECTION)) ||
            collectionRegistry.isJumyCollection(collection) ||
            whitelistedCustomCollection[collection]);
    }

    function _executeETHPayment(
        address collection,
        uint256 tokenId,
        address to,
        uint256 amount
    ) internal {

        (address royaltyFeesRecipient, uint256 royaltyCut) = royaltyManager
            .calculateRoyaltyFeeAndGetRecipient(collection, tokenId, amount);

        uint256 serviceCut = _calculateProtocolFeesAmount(amount, collection);

        uint256 recipientCut = amount - serviceCut - royaltyCut;

        payable(to).transfer(recipientCut);
        payable(protocolFeesRecipient).transfer(serviceCut);

        if (royaltyFeesRecipient != address(0)) {
            payable(royaltyFeesRecipient).transfer(royaltyCut);
            emit RoyaltySent(
                royaltyFeesRecipient,
                collection,
                tokenId,
                royaltyCut
            );
        }
    }

    function _executeETHPaymentWithFallback(
        address collection,
        uint256 tokenId,
        address to,
        uint256 amount
    ) internal {

        (address royaltyFeesRecipient, uint256 royaltyCut) = royaltyManager
            .calculateRoyaltyFeeAndGetRecipient(collection, tokenId, amount);

        uint256 serviceCut = _calculateProtocolFeesAmount(amount, collection);

        uint256 recipientCut = amount - serviceCut - royaltyCut;

        payable(protocolFeesRecipient).transfer(serviceCut);

        if (!payable(to).send(recipientCut)) {
            failedEthTransfer[to] = recipientCut;
            emit FailedToSendEth(to, recipientCut);
        }

        if (royaltyFeesRecipient != address(0)) {
            if (!payable(royaltyFeesRecipient).send(royaltyCut)) {
                failedEthTransfer[royaltyFeesRecipient] = royaltyCut;
                emit FailedToSendEth(royaltyFeesRecipient, royaltyCut);
                return;
            }
            emit RoyaltySent(
                royaltyFeesRecipient,
                collection,
                tokenId,
                royaltyCut
            );
        }
    }

    function _executeWETHPayment(
        address collection,
        uint256 tokenId,
        address from,
        address to,
        uint256 amount
    ) internal {

        (address royaltyFeesRecipient, uint256 royaltyCut) = royaltyManager
            .calculateRoyaltyFeeAndGetRecipient(collection, tokenId, amount);

        uint256 serviceCut = _calculateProtocolFeesAmount(amount, collection);

        uint256 recipientCut = amount - serviceCut - royaltyCut;

        IWETH(WETH).transferFrom(from, address(this), amount);

        IWETH(WETH).withdraw(amount);

        payable(to).transfer(recipientCut);
        payable(protocolFeesRecipient).transfer(serviceCut);

        if (royaltyFeesRecipient != address(0)) {
            payable(royaltyFeesRecipient).transfer(royaltyCut);
            emit RoyaltySent(
                royaltyFeesRecipient,
                collection,
                tokenId,
                royaltyCut
            );
        }
    }

    function _sendEthWithFallback(address to, uint256 amount) internal {

        if (!payable(to).send(amount)) {
            failedEthTransfer[to] = amount;
            emit FailedToSendEth(to, amount);
            return;
        }
    }

    function withdrawETH(address to) external nonReentrant {

        uint256 amount = failedEthTransfer[msg.sender];

        if (amount == 0) revert();

        delete failedEthTransfer[msg.sender];

        payable(to).transfer(amount);

        emit FailedEthWithdrawn(msg.sender, to, amount);
    }
}pragma solidity 0.8.12;



abstract contract ExchangeManager is ExchangeCore {
    event ProtocolFeesRecipientUpdated(address indexed recipient);
    event ProtocolFeesPercentageUpdated(uint256 percentage);
    event SpecialCollectionProtocolFeesUpdated(
        address collection,
        uint256 percentage
    );
    event RoyaltyManagerUpdated(address indexed royaltyManager);
    event CollectionRegistryUpdated(address indexed collectionRegistry);
    event WhitelistedCustomCollectionUpdated(address collection, bool state);
    event BlackListedCollectionUpdated(address collection, bool state);
    event BlackListedUserUpdated(address account, bool state);

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function updateProtocolFeesPercentage(uint256 newPercentage)
        external
        onlyOwner
        returns (uint256)
    {
        if (newPercentage > 5_000) revert InvalidArg("max newPercentage");

        if (newPercentage == protocolFeesPercentage)
            revert RejectedAlreadyInState();

        protocolFeesPercentage = newPercentage;
        emit ProtocolFeesPercentageUpdated(newPercentage);
        return newPercentage;
    }

    function updateSpecialProtocolFeesPercentage(
        address collection,
        uint256 percentage
    ) external onlyOwner returns (uint256) {
        if (percentage > 5_000) revert InvalidArg("max newPercentage");

        if (collection == address(0)) revert RejectedNullishAddress();

        if (specialProtocolFeesPercentage[collection] == percentage)
            revert RejectedAlreadyInState();

        specialProtocolFeesPercentage[collection] = percentage;
        emit SpecialCollectionProtocolFeesUpdated(collection, percentage);
        return percentage;
    }

    function updateProtocolFeesRecipient(address newRecipient)
        external
        onlyOwner
        returns (address)
    {
        if (newRecipient == address(0)) revert RejectedNullishAddress();
        protocolFeesRecipient = newRecipient;
        emit ProtocolFeesRecipientUpdated(newRecipient);
        return newRecipient;
    }

    function updateRoyaltyManager(address newRoyaltyManager)
        external
        onlyOwner
        returns (address)
    {
        if (newRoyaltyManager == address(0)) revert RejectedNullishAddress();
        royaltyManager = IRoyaltyFeeManager(newRoyaltyManager);
        emit RoyaltyManagerUpdated(newRoyaltyManager);
        return newRoyaltyManager;
    }

    function updateRewardsManager(address newRewardsManager)
        external
        onlyOwner
        returns (address)
    {
        if (newRewardsManager == address(0)) revert RejectedNullishAddress();
        rewardsManager = IRewards(newRewardsManager);
        emit RoyaltyManagerUpdated(newRewardsManager);
        return newRewardsManager;
    }

    function updateCollectionRegistry(address newCollectionRegistry)
        external
        onlyOwner
        returns (address)
    {
        if (newCollectionRegistry == address(0))
            revert RejectedNullishAddress();
        collectionRegistry = ICollectionRegistry(newCollectionRegistry);
        emit CollectionRegistryUpdated(newCollectionRegistry);
        return newCollectionRegistry;
    }

    function updateWhitelistedCustomCollection(address collection, bool state)
        external
        onlyOwner
        returns (bool)
    {
        if (collection == address(0)) revert RejectedNullishAddress();

        if (whitelistedCustomCollection[collection] == state)
            revert RejectedAlreadyInState();

        whitelistedCustomCollection[collection] = state;
        emit WhitelistedCustomCollectionUpdated(collection, state);
        return true;
    }

    function updateBlacklistedUser(address account, bool state)
        external
        onlyOwner
        returns (bool)
    {
        if (account == address(0)) revert RejectedNullishAddress();

        if (blackListedUser[account] == state) revert RejectedAlreadyInState();

        blackListedUser[account] = state;
        emit BlackListedUserUpdated(account, state);
        return true;
    }

    function updateBlackListedCollection(address collection, bool state)
        external
        onlyOwner
        returns (bool)
    {
        if (collection == address(0)) revert RejectedNullishAddress();

        if (blackListedCollection[collection] == state)
            revert RejectedAlreadyInState();

        blackListedCollection[collection] = state;
        emit BlackListedCollectionUpdated(collection, state);
        return true;
    }

    function withdrawStuckETH(uint256 amount, address to)
        external
        onlyOwner
        nonReentrant
    {
        payable(to).transfer(amount);
        emit StuckEthWithdrawn(amount);
    }

    function withdrawStuckETHFrom(address from, address to)
        external
        onlyOwner
        nonReentrant
    {
        uint256 amount = failedEthTransfer[from];

        if (amount == 0) revert();

        delete failedEthTransfer[from];

        payable(to).transfer(amount);

        emit StuckEthWithdrawn(amount);
        emit FailedEthWithdrawn(from, to, amount);
    }

    function transferStuckERC721(
        address collection,
        uint256 tokenId,
        address to
    ) external onlyOwner nonReentrant {
        IERC721(collection).safeTransferFrom(address(this), to, tokenId);

        emit StuckERC721Transferred(collection, tokenId, to);
    }

    function transferStuckERC1155(
        address collection,
        uint256 tokenId,
        uint256 amount,
        address to
    ) external onlyOwner nonReentrant {
        IERC1155(collection).safeTransferFrom(
            address(this),
            to,
            tokenId,
            amount,
            ""
        );

        emit StuckERC1155Transferred(collection, tokenId, amount, to);
    }
}