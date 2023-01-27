
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

interface INft {



    function ownerOf(uint256 _tokenID) external view returns(address);


    function creatorOf(uint256 _tokenID) external view returns(address);


    function balanceOf(address _owner) external view returns(uint256);


    function totalSupply() external view returns(uint256);


    function isApprovedSpenderOf(
        address _owner, 
        address _spender, 
        uint256 _tokenID
    )
        external
        view
        returns(bool);


    function isMinter(
        address _minter
    ) 
        external 
        view 
        returns(
            bool isMinter, 
            bool isActiveMinter
        );


    function isActive() external view returns(bool);


    function isTokenBatch(uint256 _tokenID) external view returns(uint256);


    function getBatchInfo(
        uint256 _batchID
    ) 
        external 
        view
        returns(
            uint256 baseTokenID,
            uint256[] memory tokenIDs,
            bool limitedStock,
            uint256 totalMinted
        );



    function approveSpender(
        address _spender,
        uint256 _tokenID,
        bool _approvalSpender
    )
        external;



    function transfer(
        address _to,
        uint256 _tokenID
    )
        external;


    function batchTransfer(
        address _to,
        uint256[] memory _tokenIDs
    )
        external;


    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenID
    )
        external;


    function batchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _tokenIDs
    )
        external;



    function mint(
        address _tokenCreator, 
        address _mintTo,
        string calldata identifier,      
        string calldata location,
        bytes32 contentHash 
    ) external returns(uint256);


    function batchDuplicateMint(
        address _mintTo,
        uint256 _amount,
        uint256 _baseTokenID,
        bool _isLimitedStock
    )
        external
        returns(uint256[] memory);

}//MIT
pragma solidity 0.7.5;

interface IAuction {

    function isActive() external view returns (bool);


    function hasBiddingStarted(uint256 _lotID) external view returns (bool);


    function getAuctionID() external view returns (uint256);


    function init(uint256 _auctionID) external returns (bool);


    function cancelLot(uint256 _lotID) external;

}//MIT
pragma solidity 0.7.5;

interface IHub {

    enum LotStatus {
        NO_LOT,
        LOT_REQUESTED,
        LOT_CREATED,
        AUCTION_ACTIVE,
        AUCTION_RESOLVED,
        AUCTION_RESOLVED_AND_CLAIMED,
        AUCTION_CANCELED
    }


    function getLotInformation(uint256 _lotID)
        external
        view
        returns (
            address owner,
            uint256 tokenID,
            uint256 auctionID,
            LotStatus status
        );


    function getAuctionInformation(uint256 _auctionID)
        external
        view
        returns (
            bool active,
            string memory auctionName,
            address auctionContract,
            bool onlyPrimarySales
        );


    function getAuctionID(address _auction) external view returns (uint256);


    function isAuctionActive(uint256 _auctionID) external view returns (bool);


    function getAuctionCount() external view returns (uint256);


    function isAuctionHubImplementation() external view returns (bool);


    function isFirstSale(uint256 _tokenID) external view returns (bool);


    function getFirstSaleSplit()
        external
        view
        returns (uint256 creatorSplit, uint256 systemSplit);


    function getSecondarySaleSplits()
        external
        view
        returns (
            uint256 creatorSplit,
            uint256 sellerSplit,
            uint256 systemSplit
        );


    function getScalingFactor() external view returns (uint256);



    function requestAuctionLot(uint256 _auctionType, uint256 _tokenID)
        external
        returns (uint256 lotID);



    function firstSaleCompleted(uint256 _tokenID) external;


    function lotCreated(uint256 _auctionID, uint256 _lotID) external;


    function lotAuctionStarted(uint256 _auctionID, uint256 _lotID) external;


    function lotAuctionCompleted(uint256 _auctionID, uint256 _lotID) external;


    function lotAuctionCompletedAndClaimed(uint256 _auctionID, uint256 _lotID)
        external;


    function cancelLot(uint256 _auctionID, uint256 _lotID) external;



    function init() external returns (bool);

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
}//MIT
pragma solidity 0.7.5;

interface IRoyalties {


    function getBalance(address _user) external view returns (uint256);


    function getCollateral() external view returns (address);



    function deposit(address _to, uint256 _amount) external payable;


    function withdraw(uint256 _amount) external payable;



    function init() external returns (bool);

}//MIT
pragma solidity 0.7.5;


contract Registry is Ownable, ReentrancyGuard {


    IHub internal hubInstance_;
    IRoyalties internal royaltiesInstance_;
    INft internal nftInstance_;


    constructor(address _nft) Ownable() {
        require(INft(_nft).isActive(), "REG: Address invalid NFT");
        nftInstance_ = INft(_nft);
    }


    function getHub() external view returns (address) {

        return address(hubInstance_);
    }

    function getRoyalties() external view returns (address) {

        return address(royaltiesInstance_);
    }

    function getNft() external view returns (address) {

        return address(nftInstance_);
    }

    function isActive() external view returns (bool) {

        return true;
    }


    function updateHub(address _newHub) external onlyOwner nonReentrant {

        IHub newHub = IHub(_newHub);
        require(_newHub != address(0), "REG: cannot set HUB to 0x");
        require(
            address(hubInstance_) != _newHub,
            "REG: Cannot set HUB to existing"
        );
        require(
            newHub.isAuctionHubImplementation(),
            "REG: HUB implementation error"
        );
        require(IHub(_newHub).init(), "REG: HUB could not be init");
        hubInstance_ = IHub(_newHub);
    }

    function updateRoyalties(address _newRoyalties)
        external
        onlyOwner
        nonReentrant
    {

        require(_newRoyalties != address(0), "REG: cannot set ROY to 0x");
        require(
            address(royaltiesInstance_) != _newRoyalties,
            "REG: Cannot set ROY to existing"
        );
        require(IRoyalties(_newRoyalties).init(), "REG: ROY could not be init");
        royaltiesInstance_ = IRoyalties(_newRoyalties);
    }
}//MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;


contract AuctionHub is Ownable, IHub {

    using SafeMath for uint256;

    struct LotRequest {
        address owner;              // Owner of token
        uint256 tokenID;            // ID of the token
        uint256 auctionID;          // ID of the auction
        LotStatus status;           // Status of the auction
    }
    enum AuctionStatus { INACTIVE, ACTIVE, PAUSED }
    struct Auctions {
        AuctionStatus status;       // If the auction type is valid for requests
        string auctionName;         // Name of the auction 
        address auctionContract;    // Address of auction implementation
        bool onlyPrimarySales;      // If the auction can only do primary sales
    }

    uint256 constant internal SPLIT_SCALING_FACTOR = 10000;

    mapping(uint256 => LotRequest) internal lotRequests_;
    mapping(uint256 => Auctions) internal auctions_;
    mapping(address => uint256) internal auctionAddress_;
    mapping(uint256 => bool) internal isSecondarySale_;
    INft internal nftInstance_;
    Registry internal registryInstance_;
    uint256 internal auctionCounter_;
    uint256 internal lotCounter_;
    uint256 internal creatorSplitFirstSale_;
    uint256 internal systemSplitFirstSale_;
    uint256 internal creatorSplitSecondary_;
    uint256 internal sellerSplitSecondary_;
    uint256 internal systemSplitSecondary_;


    event AuctionRegistered(
        address owner,
        uint256 indexed auctionID,
        string auctionName,
        address auctionContract    
    );

    event AuctionUpdated(
        address owner,
        uint256 indexed auctionID,
        address oldAuctionContract,
        address newAuctionContract
    );

    event AuctionRemoved(
        address owner,
        uint256 indexed auctionID
    );

    event LotStatusChange(
        uint256 indexed lotID,
        uint256 indexed auctionID,
        address indexed auction,
        LotStatus status
    );

    event FirstSaleSplitUpdated(
        uint256 oldCreatorSplit,
        uint256 newCreatorSplit,
        uint256 oldSystemSplit,
        uint256 newSystemSplit
    );

    event SecondarySalesSplitUpdated(
        uint256 oldCreatorSplit,
        uint256 newCreatorSplit,
        uint256 oldSellerSplit,
        uint256 newSellerSplit,
        uint256 oldSystemSplit,
        uint256 newSystemSplit
    );

    event LotRequested(
        address indexed requester,
        uint256 indexed tokenID,
        uint256 indexed lotID
    );


    modifier onlyAuction() {

        uint256 auctionID = this.getAuctionID(msg.sender);
        require(
            auctions_[auctionID].auctionContract == msg.sender &&
            auctions_[auctionID].status != AuctionStatus.INACTIVE,
            "Invalid auction"
        );
        _;
    }

    modifier onlyTokenOwner(uint256 _lotID) {

        require(
            msg.sender == lotRequests_[_lotID].owner,
            "Address not original owner"
        );
        _;
    }  

    modifier onlyRegistry() {

        require(
            msg.sender == address(registryInstance_),
            "Caller can only be registry"
        );
        _;
    }


    constructor(
        address _registry,
        uint256 _primaryCreatorSplit,
        uint256 _primarySystemSplit,
        uint256 _secondaryCreatorSplit,
        uint256 _secondarySellerSplit,
        uint256 _secondarySystemSplit
    ) 
        Ownable() 
    {
        registryInstance_ = Registry(_registry);
        nftInstance_ = INft(registryInstance_.getNft());
        require(
            nftInstance_.isActive(),
            "NFT contract not active"
        );
        _updateFirstSaleSplit(
            _primaryCreatorSplit,
            _primarySystemSplit
        );
        _updateSecondarySalesSplit(
            _secondaryCreatorSplit,
            _secondarySellerSplit,
            _secondarySystemSplit
        );
    }


    function getLotInformation(
        uint256 _lotID
    ) 
        external 
        view 
        override
        returns(
            address owner,
            uint256 tokenID,
            uint256 auctionID,
            LotStatus status
        ) 
    {

        owner= lotRequests_[_lotID].owner;
        tokenID= lotRequests_[_lotID].tokenID;
        auctionID= lotRequests_[_lotID].auctionID;
        status= lotRequests_[_lotID].status;
    }

    function getAuctionInformation(
        uint256 _auctionID
    )
        external
        view
        override
        returns(
            bool active,
            string memory auctionName,
            address auctionContract,
            bool onlyPrimarySales
        )
    {

        active = auctions_[_auctionID].status == AuctionStatus.ACTIVE ? true : false;
        auctionName = auctions_[_auctionID].auctionName;
        auctionContract = auctions_[_auctionID].auctionContract;
        onlyPrimarySales = auctions_[_auctionID].onlyPrimarySales;
    }

    function getAuctionID(
        address _auction
    ) 
        external 
        view 
        override 
        returns(uint256) 
    {

        return auctionAddress_[_auction];
    }

    function isAuctionActive(uint256 _auctionID) external view override returns(bool) {

        return auctions_[_auctionID].status == AuctionStatus.ACTIVE ? true : false;
    }

    function getAuctionCount() external view override returns(uint256) {

        return auctionCounter_;
    }

    function isAuctionHubImplementation() external view override returns(bool) {

        return true;
    }

    function isFirstSale(uint256 _tokenID) external view override returns(bool) {

        return !isSecondarySale_[_tokenID];
    }

    function getFirstSaleSplit() 
        external 
        view 
        override
        returns(
            uint256 creatorSplit,
            uint256 systemSplit
        )
    {

        creatorSplit = creatorSplitFirstSale_;
        systemSplit = systemSplitFirstSale_;
    }

    function getSecondarySaleSplits()
        external
        view
        override
        returns(
            uint256 creatorSplit,
            uint256 sellerSplit,
            uint256 systemSplit
        )
    {

        creatorSplit = creatorSplitSecondary_;
        sellerSplit = sellerSplitSecondary_;
        systemSplit = systemSplitSecondary_;
    }

    function getScalingFactor() external view override returns(uint256) {

        return SPLIT_SCALING_FACTOR;
    }


    function requestAuctionLot(
        uint256 _auctionType,
        uint256 _tokenID
    )
        external 
        override
        returns(uint256 lotID)
    {

        require(
            auctions_[_auctionType].status == AuctionStatus.ACTIVE,
            "Auction is inactive"
        );
        require(
            nftInstance_.ownerOf(_tokenID) == msg.sender,
            "Only owner can request lot"
        );
        if(auctions_[_auctionType].onlyPrimarySales) {
            require(
                this.isFirstSale(_tokenID),
                "Auction can only do first sales"
            );
        }
        lotCounter_ = lotCounter_.add(1);
        lotID = lotCounter_;

        lotRequests_[lotID] = LotRequest(
            msg.sender,
            _tokenID,
            _auctionType,
            LotStatus.LOT_REQUESTED
        );
        require(
            nftInstance_.isApprovedSpenderOf(
                msg.sender,
                address(this),
                _tokenID
            ),
            "Approve hub as spender first"
        );
        nftInstance_.transferFrom(
            msg.sender,
            address(this),
            _tokenID
        );
        nftInstance_.approveSpender(
            auctions_[_auctionType].auctionContract,
            _tokenID,
            true
        );

        emit LotRequested(
            msg.sender,
            _tokenID,
            lotID
        );
    }

    function init() external override onlyRegistry() returns(bool) {

        return true;
    }
    


    function firstSaleCompleted(uint256 _tokenID) external override onlyAuction() {

        isSecondarySale_[_tokenID] = true;
    }

    function lotCreated(
        uint256 _auctionID, 
        uint256 _lotID
    ) 
        external 
        override
        onlyAuction() 
    {

        lotRequests_[_lotID].status = LotStatus.LOT_CREATED;
        
        emit LotStatusChange(
            _lotID,
            _auctionID,
            msg.sender,
            LotStatus.LOT_CREATED
        );
    }

    function lotAuctionStarted(
        uint256 _auctionID, 
        uint256 _lotID
    ) 
        external 
        override
        onlyAuction() 
    {

        lotRequests_[_lotID].status = LotStatus.AUCTION_ACTIVE;

        emit LotStatusChange(
            _lotID,
            _auctionID,
            msg.sender,
            LotStatus.AUCTION_ACTIVE
        );
    }

    function lotAuctionCompleted(
        uint256 _auctionID, 
        uint256 _lotID
    ) 
        external 
        override
        onlyAuction() 
    {

        lotRequests_[_lotID].status = LotStatus.AUCTION_RESOLVED;

        emit LotStatusChange(
            _lotID,
            _auctionID,
            msg.sender,
            LotStatus.AUCTION_RESOLVED
        );
    }    

    function lotAuctionCompletedAndClaimed(
        uint256 _auctionID, 
        uint256 _lotID
    ) 
        external 
        override
        onlyAuction() 
    {

        lotRequests_[_lotID].status = LotStatus.AUCTION_RESOLVED_AND_CLAIMED;

        emit LotStatusChange(
            _lotID,
            _auctionID,
            msg.sender,
            LotStatus.AUCTION_RESOLVED_AND_CLAIMED
        );
    }    

    function cancelLot(
        uint256 _auctionID, 
        uint256 _lotID
    ) 
        external 
        override
        onlyTokenOwner(_lotID)
    {

        address currentHolder = nftInstance_.ownerOf(
            lotRequests_[_lotID].tokenID
        );
        IAuction auction = IAuction(
            auctions_[lotRequests_[_lotID].auctionID].auctionContract
        );

        require(
            lotRequests_[_lotID].status == LotStatus.LOT_REQUESTED ||
            lotRequests_[_lotID].status == LotStatus.LOT_CREATED ||
            lotRequests_[_lotID].status == LotStatus.AUCTION_ACTIVE,
            "State invalid for cancellation"
        );
        require(
            !auction.hasBiddingStarted(_lotID),
            "Bidding has started, cannot cancel"
        );
        require(
            lotRequests_[_lotID].owner != currentHolder,
            "Token already with owner"
        );
        if(auctions_[lotRequests_[_lotID].auctionID].onlyPrimarySales) {
            require(
            lotRequests_[_lotID].status != LotStatus.AUCTION_ACTIVE,
            "Cant cancel active primary sales"
            );
        }
        if(currentHolder == address(this)) {
            nftInstance_.transfer(
                lotRequests_[_lotID].owner,
                lotRequests_[_lotID].tokenID
            );
        } else if(
            auctions_[lotRequests_[_lotID].auctionID].auctionContract ==
            currentHolder
        ) {
            auction.cancelLot(_lotID);
        } else {
            revert("Owner is not auction or hub");
        }
        lotRequests_[_lotID].status = LotStatus.AUCTION_CANCELED;

        emit LotStatusChange(
            _lotID,
            _auctionID,
            msg.sender,
            LotStatus.AUCTION_CANCELED
        );
    }


    function updateFirstSaleSplit(
        uint256 _newCreatorSplit,
        uint256 _newSystemSplit
    )
        external
        onlyOwner()
    {

        _updateFirstSaleSplit(
            _newCreatorSplit,
            _newSystemSplit
        );
    }

    function updateSecondarySalesSplit(
        uint256 _newCreatorSplit,
        uint256 _newSellerSplit,
        uint256 _newSystemSplit
    )
        external
        onlyOwner()
    {

        _updateSecondarySalesSplit(
            _newCreatorSplit,
            _newSellerSplit,
            _newSystemSplit
        );
    }

    function registerAuction(
        string memory _name,
        address _auctionInstance,
        bool _onlyPrimarySales
    )
        external
        onlyOwner()
        returns(uint256 auctionID)
    {

        auctionCounter_ = auctionCounter_.add(1);
        auctionID = auctionCounter_;
        auctionAddress_[_auctionInstance] = auctionID;
        auctions_[auctionID] = Auctions(
            AuctionStatus.INACTIVE,
            _name,
            _auctionInstance,
            _onlyPrimarySales
        );
        require(
            IAuction(_auctionInstance).init(auctionID),
            "Auction initialisation failed"
        );
        auctions_[auctionID].status = AuctionStatus.ACTIVE;

        emit AuctionRegistered(
            msg.sender,
            auctionID,
            _name,
            _auctionInstance    
        );
    }

    function pauseAuction(uint256 _auctionID) external onlyOwner() {

        require(
            auctions_[_auctionID].status == AuctionStatus.ACTIVE,
            "Cannot pause inactive auction"
        );

        auctions_[_auctionID].status = AuctionStatus.PAUSED;
    }

    function updateAuctionInstance(
        uint256 _auctionID,
        address _newImplementation
    )
        external 
        onlyOwner()
    {

        require(
            auctions_[_auctionID].status == AuctionStatus.PAUSED,
            "Auction must be paused before update"
        );
        require(
            auctions_[_auctionID].auctionContract != _newImplementation,
            "Auction address already set"
        );

        IAuction newAuction = IAuction(_newImplementation);

        require(
            newAuction.isActive() == false,
            "Auction has been activated"
        );

        newAuction.init(_auctionID);

        address oldAuctionContract = auctions_[_auctionID].auctionContract;
        auctionAddress_[oldAuctionContract] = 0;
        auctions_[_auctionID].auctionContract = _newImplementation;
        auctionAddress_[_newImplementation] = _auctionID;

        emit AuctionUpdated(
            msg.sender,
            _auctionID,
            oldAuctionContract,
            _newImplementation
        );
    }

    function removeAuction(
        uint256 _auctionID
    )
        external 
        onlyOwner()
    {

        require(
            auctions_[_auctionID].status == AuctionStatus.PAUSED,
            "Auction must be paused before update"
        );

        auctions_[_auctionID].status = AuctionStatus.INACTIVE;
        auctions_[_auctionID].auctionName = "";
        auctionAddress_[auctions_[_auctionID].auctionContract] = 0;
        auctions_[_auctionID].auctionContract = address(0);

        emit AuctionRemoved(
            msg.sender,
            _auctionID
        );
    } 


    function _updateSecondarySalesSplit(
        uint256 _newCreatorSplit,
        uint256 _newSellerSplit,
        uint256 _newSystemSplit
    )
        internal
    {

        uint256 total = _newCreatorSplit
            .add(_newSellerSplit)
            .add(_newSystemSplit);

        require(
            total == SPLIT_SCALING_FACTOR,
            "New split not equal to 100%"
        );

        emit SecondarySalesSplitUpdated(
            creatorSplitSecondary_,
            _newCreatorSplit,
            sellerSplitSecondary_,
            _newSellerSplit,
            systemSplitSecondary_,
            _newSystemSplit
        );

        creatorSplitSecondary_ = _newCreatorSplit;
        sellerSplitSecondary_ = _newSellerSplit;
        systemSplitSecondary_ = _newSystemSplit;
    }

    function _updateFirstSaleSplit(
        uint256 _newCreatorSplit,
        uint256 _newSystemSplit
    )
        internal
    {

        uint256 total = _newCreatorSplit.add(_newSystemSplit);

        require(
            total == SPLIT_SCALING_FACTOR,
            "New split not equal to 100%"
        );
        
        emit FirstSaleSplitUpdated(
            creatorSplitFirstSale_,
            _newCreatorSplit,
            systemSplitFirstSale_,
            _newSystemSplit
        );

        creatorSplitFirstSale_ = _newCreatorSplit;
        systemSplitFirstSale_ = _newSystemSplit;
    }
}