
pragma solidity ^0.8.1;

library AddressUpgradeable {

    function isContract(address account) internal view returns (bool) {


        return account.code.length > 0;
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
}// MIT

pragma solidity ^0.8.0;

abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal onlyInitializing {
    }

    function __Context_init_unchained() internal onlyInitializing {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    uint256[50] private __gap;
}// MIT

pragma solidity ^0.8.0;


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal onlyInitializing {
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal onlyInitializing {
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

    uint256[49] private __gap;
}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

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
}// MIT

pragma solidity ^0.8.0;

library EnumerableSetUpgradeable {


    struct Set {
        bytes32[] _values;
        mapping(bytes32 => uint256) _indexes;
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

        if (valueIndex != 0) {

            uint256 toDeleteIndex = valueIndex - 1;
            uint256 lastIndex = set._values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastvalue = set._values[lastIndex];

                set._values[toDeleteIndex] = lastvalue;
                set._indexes[lastvalue] = valueIndex; // Replace lastvalue's index to valueIndex
            }

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

        return set._values[index];
    }

    function _values(Set storage set) private view returns (bytes32[] memory) {

        return set._values;
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

    function values(Bytes32Set storage set) internal view returns (bytes32[] memory) {

        return _values(set._inner);
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

    function values(AddressSet storage set) internal view returns (address[] memory) {

        bytes32[] memory store = _values(set._inner);
        address[] memory result;

        assembly {
            result := store
        }

        return result;
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

    function values(UintSet storage set) internal view returns (uint256[] memory) {

        bytes32[] memory store = _values(set._inner);
        uint256[] memory result;

        assembly {
            result := store
        }

        return result;
    }
}// GPL-3.0
pragma solidity ^0.8.4;

interface IJPEGCardsCigStaking {

    function isUserStaking(address _user) external view returns (bool);

}// GPL-3.0
pragma solidity ^0.8.4;



contract JPEGAuction is OwnableUpgradeable, ReentrancyGuardUpgradeable {

    using EnumerableSetUpgradeable for EnumerableSetUpgradeable.UintSet;

    event NewAuction(
        IERC721Upgradeable indexed nft,
        uint256 indexed index,
        uint256 startTime
    );
    event NewBid(
        uint256 indexed auctionId,
        address indexed bidder,
        uint256 bidValue
    );
    event JPEGDeposited(address indexed account, uint256 currentAmount);
    event CardDeposited(address indexed account, uint256 index);
    event JPEGWithdrawn(address indexed account, uint256 amount);
    event CardWithdrawn(address indexed account, uint256 index);
    event NFTClaimed(uint256 indexed auctionId);
    event BidWithdrawn(
        uint256 indexed auctionId,
        address indexed account,
        uint256 bidValue
    );
    event BidTimeIncrementChanged(uint256 newTime, uint256 oldTime);
    event JPEGLockAmountChanged(uint256 newLockAmount, uint256 oldLockAmount);
    event LockDurationChanged(uint256 newDuration, uint256 oldDuration);
    event MinimumIncrementRateChanged(
        Rate newIncrementRate,
        Rate oldIncrementRate
    );

    struct Rate {
        uint128 numerator;
        uint128 denominator;
    }

    enum StakeMode {
        CIG,
        JPEG,
        CARD,
        LEGACY
    }

    struct UserInfo {
        StakeMode stakeMode;
        uint256 stakeArgument; //unused for CIG
        uint256 unlockTime; //unused for CIG
    }

    struct Auction {
        IERC721Upgradeable nftAddress;
        uint256 nftIndex;
        uint256 startTime;
        uint256 endTime;
        uint256 minBid;
        address highestBidOwner;
        bool ownerClaimed;
        mapping(address => uint256) bids;
    }

    IERC20Upgradeable public jpeg;
    IERC721Upgradeable public cards;
    IJPEGCardsCigStaking public cigStaking;
    JPEGAuction public legacyAuction;

    uint256 public lockDuration;
    uint256 public jpegAmountNeeded;
    uint256 public bidTimeIncrement;
    uint256 public auctionsLength;

    Rate public minIncrementRate;

    mapping(address => UserInfo) public userInfo;
    mapping(address => EnumerableSetUpgradeable.UintSet) internal userAuctions;
    mapping(uint256 => Auction) public auctions;

    function initialize(
        IERC20Upgradeable _jpeg,
        IERC721Upgradeable _cards,
        IJPEGCardsCigStaking _cigStaking,
        JPEGAuction _legacyAuction,
        uint256 _jpegLockAmount,
        uint256 _lockDuration,
        uint256 _bidTimeIncrement,
        Rate memory _incrementRate
    ) external initializer {

        __Ownable_init();
        __ReentrancyGuard_init();

        jpeg = _jpeg;
        cards = _cards;
        cigStaking = _cigStaking;
        legacyAuction = _legacyAuction;

        setJPEGLockAmount(_jpegLockAmount);
        setLockDuration(_lockDuration);
        setBidTimeIncrement(_bidTimeIncrement);
        setMinimumIncrementRate(_incrementRate);
    }

    function newAuction(
        IERC721Upgradeable _nft,
        uint256 _idx,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _minBid
    ) external onlyOwner {

        require(address(_nft) != address(0), "INVALID_NFT");
        require(_startTime > block.timestamp, "INVALID_START_TIME");
        require(_endTime > _startTime, "INVALID_END_TIME");
        require(_minBid > 0, "INVALID_MIN_BID");

        Auction storage auction = auctions[auctionsLength++];
        auction.nftAddress = _nft;
        auction.nftIndex = _idx;
        auction.startTime = _startTime;
        auction.endTime = _endTime;
        auction.minBid = _minBid;

        _nft.transferFrom(msg.sender, address(this), _idx);

        emit NewAuction(_nft, _idx, _startTime);
    }

    function correctDepositedJPEG() public nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        require(user.stakeMode != StakeMode.CARD, "STAKING_CARD");

        uint256 stakedAmount = user.stakeArgument;
        uint256 amountNeeded = jpegAmountNeeded;

        require(stakedAmount != amountNeeded, "ALREADY_CORRECT");

        user.stakeMode = StakeMode.JPEG;
        user.stakeArgument = amountNeeded;

        if (user.unlockTime == 0)
            user.unlockTime = block.timestamp + lockDuration;

        if (stakedAmount > amountNeeded)
            jpeg.transfer(msg.sender, stakedAmount - amountNeeded);
        else
            jpeg.transferFrom(
                msg.sender,
                address(this),
                amountNeeded - stakedAmount
            );

        emit JPEGDeposited(msg.sender, amountNeeded);
    }

    function depositCard(uint256 _idx) public nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        StakeMode stakeMode = user.stakeMode;
        require(
            stakeMode == StakeMode.CIG || stakeMode == StakeMode.LEGACY,
            "ALREADY_STAKING"
        );

        user.stakeMode = StakeMode.CARD;
        user.stakeArgument = _idx;
        user.unlockTime = block.timestamp + lockDuration;

        cards.transferFrom(msg.sender, address(this), _idx);

        emit CardDeposited(msg.sender, _idx);
    }

    function bid(uint256 _auctionIndex) public payable nonReentrant {

        Auction storage auction = auctions[_auctionIndex];
        uint256 endTime = auction.endTime;

        require(block.timestamp >= auction.startTime, "NOT_STARTED");
        require(block.timestamp < endTime, "ENDED_OR_INVALID");

        require(isAuthorized(msg.sender), "NOT_AUTHORIZED");

        uint256 previousBid = auction.bids[msg.sender];
        uint256 totalBid = msg.value + previousBid;
        uint256 currentMinBid = auction.bids[auction.highestBidOwner];
        currentMinBid +=
            (currentMinBid * minIncrementRate.numerator) /
            minIncrementRate.denominator;

        require(
            totalBid >= currentMinBid && totalBid >= auction.minBid,
            "INVALID_BID"
        );

        auction.highestBidOwner = msg.sender;
        auction.bids[msg.sender] = totalBid;

        if (previousBid == 0)
            assert(userAuctions[msg.sender].add(_auctionIndex));

        uint256 bidIncrement = bidTimeIncrement;
        if (bidIncrement > endTime - block.timestamp)
            auction.endTime = block.timestamp + bidIncrement;

        emit NewBid(_auctionIndex, msg.sender, totalBid);
    }

    function claimNFT(uint256 _auctionIndex) external nonReentrant {

        Auction storage auction = auctions[_auctionIndex];

        require(auction.highestBidOwner == msg.sender, "NOT_WINNER");
        require(block.timestamp >= auction.endTime, "NOT_ENDED");
        require(
            userAuctions[msg.sender].remove(_auctionIndex),
            "ALREADY_CLAIMED"
        );

        auction.nftAddress.transferFrom(
            address(this),
            msg.sender,
            auction.nftIndex
        );

        emit NFTClaimed(_auctionIndex);
    }

    function depositJPEGAndBid(uint256 _auctionIndex) external payable {

        correctDepositedJPEG();
        bid(_auctionIndex);
    }

    function depositCardAndBid(uint256 _auctionIndex, uint256 _idx)
        external
        payable
    {

        depositCard(_idx);
        bid(_auctionIndex);
    }

    function withdrawBid(uint256 _auctionIndex) public nonReentrant {

        Auction storage auction = auctions[_auctionIndex];

        require(auction.highestBidOwner != msg.sender, "HIGHEST_BID_OWNER");

        uint256 bidAmount = auction.bids[msg.sender];
        require(bidAmount > 0, "NO_BID");

        auction.bids[msg.sender] = 0;
        assert(userAuctions[msg.sender].remove(_auctionIndex));

        (bool sent, ) = payable(msg.sender).call{value: bidAmount}("");
        require(sent, "ETH_TRANSFER_FAILED");

        emit BidWithdrawn(_auctionIndex, msg.sender, bidAmount);
    }

    function withdrawBids(uint256[] calldata _indexes) external {

        for (uint256 i; i < _indexes.length; i++) {
            withdrawBid(_indexes[i]);
        }
    }

    function withdrawCard() external nonReentrant {

        UserInfo memory user = userInfo[msg.sender];
        require(user.stakeMode == StakeMode.CARD, "CARD_NOT_DEPOSITED");
        require(block.timestamp >= user.unlockTime, "LOCKED");

        require(userAuctions[msg.sender].length() == 0, "ACTIVE_BIDS");

        delete userInfo[msg.sender];

        uint256 cardIndex = user.stakeArgument;

        cards.transferFrom(address(this), msg.sender, cardIndex);

        emit CardWithdrawn(msg.sender, cardIndex);
    }

    function withdrawJPEG() external nonReentrant {

        UserInfo memory user = userInfo[msg.sender];
        require(user.stakeMode == StakeMode.JPEG, "JPEG_NOT_DEPOSITED");
        require(block.timestamp >= user.unlockTime, "LOCKED");

        require(userAuctions[msg.sender].length() == 0, "ACTIVE_BIDS");

        delete userInfo[msg.sender];

        uint256 jpegAmount = user.stakeArgument;

        jpeg.transfer(msg.sender, jpegAmount);

        emit JPEGWithdrawn(msg.sender, jpegAmount);
    }

    function renounceLegacyStakeMode() external nonReentrant {

        UserInfo storage user = userInfo[msg.sender];
        require(user.stakeMode == StakeMode.LEGACY, "NOT_LEGACY");

        delete userInfo[msg.sender];
    }

    function isAuthorized(address _account) public view returns (bool) {

        StakeMode stakeMode = userInfo[_account].stakeMode;

        if (stakeMode == StakeMode.CARD) return true;
        else if (stakeMode == StakeMode.JPEG)
            return userInfo[_account].stakeArgument >= jpegAmountNeeded;
        else if (stakeMode == StakeMode.CIG)
            return cigStaking.isUserStaking(_account);
        else return legacyAuction.isAuthorized(_account);
    }

    function getActiveBids(address _account)
        external
        view
        returns (uint256[] memory)
    {

        return userAuctions[_account].values();
    }

    function getAuctionBid(uint256 _auctionIndex, address _account)
        external
        view
        returns (uint256)
    {

        return auctions[_auctionIndex].bids[_account];
    }

    function withdrawETH(uint256 _auctionIndex) external onlyOwner {

        Auction storage auction = auctions[_auctionIndex];

        require(block.timestamp >= auction.endTime, "NOT_ENDED");
        address highestBidder = auction.highestBidOwner;
        require(highestBidder != address(0), "NFT_UNSOLD");
        require(!auction.ownerClaimed, "ALREADY_CLAIMED");

        auction.ownerClaimed = true;

        (bool sent, ) = payable(msg.sender).call{
            value: auction.bids[highestBidder]
        }("");
        require(sent, "ETH_TRANSFER_FAILED");
    }

    function withdrawUnsoldNFT(uint256 _auctionIndex) external onlyOwner {

        Auction storage auction = auctions[_auctionIndex];

        require(block.timestamp >= auction.endTime, "NOT_ENDED");
        address highestBidder = auction.highestBidOwner;
        require(highestBidder == address(0), "NFT_SOLD");
        require(!auction.ownerClaimed, "ALREADY_CLAIMED");

        auction.ownerClaimed = true;

        auction.nftAddress.transferFrom(
            address(this),
            msg.sender,
            auction.nftIndex
        );
    }

    function addLegacyAccounts(address[] calldata _accounts)
        external
        onlyOwner
    {

        for (uint256 i; i < _accounts.length; ++i) {
            address account = _accounts[i];
            require(
                userInfo[account].stakeMode == StakeMode.CIG,
                "ACCOUNT_ALREADY_STAKING"
            );

            userInfo[account].stakeMode = StakeMode.LEGACY;
        }
    }

    function setBidTimeIncrement(uint256 _newTime) public onlyOwner {

        require(_newTime > 0, "INVALID_TIME");

        emit BidTimeIncrementChanged(_newTime, bidTimeIncrement);

        bidTimeIncrement = _newTime;
    }

    function setJPEGLockAmount(uint256 _lockAmount) public onlyOwner {

        require(_lockAmount > 0, "INVALID_LOCK_AMOUNT");

        emit JPEGLockAmountChanged(_lockAmount, jpegAmountNeeded);

        jpegAmountNeeded = _lockAmount;
    }

    function setLockDuration(uint256 _newDuration) public onlyOwner {

        require(_newDuration > 0, "INVALID_LOCK_DURATION");

        emit LockDurationChanged(_newDuration, lockDuration);

        lockDuration = _newDuration;
    }

    function setMinimumIncrementRate(Rate memory _newIncrementRate)
        public
        onlyOwner
    {

        require(
            _newIncrementRate.denominator != 0 &&
                _newIncrementRate.denominator >= _newIncrementRate.numerator,
            "INVALID_RATE"
        );

        emit MinimumIncrementRateChanged(_newIncrementRate, minIncrementRate);

        minIncrementRate = _newIncrementRate;
    }
}