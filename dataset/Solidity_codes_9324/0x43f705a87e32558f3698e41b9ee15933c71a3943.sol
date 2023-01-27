

pragma solidity 0.8.9;




interface IGMAccessControl {

    function isTrader(address user) external view returns (bool);


    function isCreator(address user) external view returns (bool);


    function userPermissions(address user) external view returns (bool userIsTrader, bool userIsCreator);


    function isAgent(address user) external view returns (bool);


    function isAgentOf(address agent, address user) external view returns (bool);


    function agentOf(address user) external view returns (address);

}


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
}


interface IBeaconUpgradeable {

    function implementation() external view returns (address);

}


interface IERC165Upgradeable {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IERC721ReceiverUpgradeable {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}


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

}


abstract contract Initializable {
    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || !_initialized, "Initializable: contract is already initialized");

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
}


library StorageSlotUpgradeable {

    struct AddressSlot {
        address value;
    }

    struct BooleanSlot {
        bool value;
    }

    struct Bytes32Slot {
        bytes32 value;
    }

    struct Uint256Slot {
        uint256 value;
    }

    function getAddressSlot(bytes32 slot) internal pure returns (AddressSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBooleanSlot(bytes32 slot) internal pure returns (BooleanSlot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getBytes32Slot(bytes32 slot) internal pure returns (Bytes32Slot storage r) {

        assembly {
            r.slot := slot
        }
    }

    function getUint256Slot(bytes32 slot) internal pure returns (Uint256Slot storage r) {

        assembly {
            r.slot := slot
        }
    }
}


interface IGMAuction {

    function scheduleAuction(uint256 artId_, uint256 startPrice_) external;


    function scheduleInitialAuction(address beneficiary_, uint256 artId_, uint256 startPrice_) external;


    function setDuration(uint256 duration_) external;


    function setMaxStartPrice(uint256 maxStartPrice_) external;


    function bid(uint256 artId, uint256 amount) external;


    function completeAuction(uint256 artId) external;


    function setMinter(address minter_) external;


    function setUser(IGMAccessControl user_) external;


    function isActive(uint256 artId) external view returns (bool);

}


abstract contract ContextUpgradeable is Initializable {
    function __Context_init() internal initializer {
        __Context_init_unchained();
    }

    function __Context_init_unchained() internal initializer {
    }
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
    uint256[50] private __gap;
}


abstract contract ERC1967UpgradeUpgradeable is Initializable {
    function __ERC1967Upgrade_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
    }

    function __ERC1967Upgrade_init_unchained() internal initializer {
    }
    bytes32 private constant _ROLLBACK_SLOT = 0x4910fdfa16fed3260ed0e7147f7cc6da11a60208b5b9406d12a635614ffd9143;

    bytes32 internal constant _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    event Upgraded(address indexed implementation);

    function _getImplementation() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value;
    }

    function _setImplementation(address newImplementation) private {
        require(AddressUpgradeable.isContract(newImplementation), "ERC1967: new implementation is not a contract");
        StorageSlotUpgradeable.getAddressSlot(_IMPLEMENTATION_SLOT).value = newImplementation;
    }

    function _upgradeTo(address newImplementation) internal {
        _setImplementation(newImplementation);
        emit Upgraded(newImplementation);
    }

    function _upgradeToAndCall(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        _upgradeTo(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }
    }

    function _upgradeToAndCallSecure(
        address newImplementation,
        bytes memory data,
        bool forceCall
    ) internal {
        address oldImplementation = _getImplementation();

        _setImplementation(newImplementation);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(newImplementation, data);
        }

        StorageSlotUpgradeable.BooleanSlot storage rollbackTesting = StorageSlotUpgradeable.getBooleanSlot(_ROLLBACK_SLOT);
        if (!rollbackTesting.value) {
            rollbackTesting.value = true;
            _functionDelegateCall(
                newImplementation,
                abi.encodeWithSignature("upgradeTo(address)", oldImplementation)
            );
            rollbackTesting.value = false;
            require(oldImplementation == _getImplementation(), "ERC1967Upgrade: upgrade breaks further upgrades");
            _upgradeTo(newImplementation);
        }
    }

    bytes32 internal constant _ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    event AdminChanged(address previousAdmin, address newAdmin);

    function _getAdmin() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value;
    }

    function _setAdmin(address newAdmin) private {
        require(newAdmin != address(0), "ERC1967: new admin is the zero address");
        StorageSlotUpgradeable.getAddressSlot(_ADMIN_SLOT).value = newAdmin;
    }

    function _changeAdmin(address newAdmin) internal {
        emit AdminChanged(_getAdmin(), newAdmin);
        _setAdmin(newAdmin);
    }

    bytes32 internal constant _BEACON_SLOT = 0xa3f0ad74e5423aebfd80d3ef4346578335a9a72aeaee59ff6cb3582b35133d50;

    event BeaconUpgraded(address indexed beacon);

    function _getBeacon() internal view returns (address) {
        return StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value;
    }

    function _setBeacon(address newBeacon) private {
        require(AddressUpgradeable.isContract(newBeacon), "ERC1967: new beacon is not a contract");
        require(
            AddressUpgradeable.isContract(IBeaconUpgradeable(newBeacon).implementation()),
            "ERC1967: beacon implementation is not a contract"
        );
        StorageSlotUpgradeable.getAddressSlot(_BEACON_SLOT).value = newBeacon;
    }

    function _upgradeBeaconToAndCall(
        address newBeacon,
        bytes memory data,
        bool forceCall
    ) internal {
        _setBeacon(newBeacon);
        emit BeaconUpgraded(newBeacon);
        if (data.length > 0 || forceCall) {
            _functionDelegateCall(IBeaconUpgradeable(newBeacon).implementation(), data);
        }
    }

    function _functionDelegateCall(address target, bytes memory data) private returns (bytes memory) {
        require(AddressUpgradeable.isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return AddressUpgradeable.verifyCallResult(success, returndata, "Address: low-level delegate call failed");
    }
    uint256[50] private __gap;
}


library SafeERC20Upgradeable {

    using AddressUpgradeable for address;

    function safeTransfer(
        IERC20Upgradeable token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20Upgradeable token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20Upgradeable token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20Upgradeable token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


abstract contract OwnableUpgradeable is Initializable, ContextUpgradeable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function __Ownable_init() internal initializer {
        __Context_init_unchained();
        __Ownable_init_unchained();
    }

    function __Ownable_init_unchained() internal initializer {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    uint256[49] private __gap;
}


abstract contract PausableUpgradeable is Initializable, ContextUpgradeable {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    function __Pausable_init() internal initializer {
        __Context_init_unchained();
        __Pausable_init_unchained();
    }

    function __Pausable_init_unchained() internal initializer {
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
    uint256[49] private __gap;
}


abstract contract UUPSUpgradeable is Initializable, ERC1967UpgradeUpgradeable {
    function __UUPSUpgradeable_init() internal initializer {
        __ERC1967Upgrade_init_unchained();
        __UUPSUpgradeable_init_unchained();
    }

    function __UUPSUpgradeable_init_unchained() internal initializer {
    }
    address private immutable __self = address(this);

    modifier onlyProxy() {
        require(address(this) != __self, "Function must be called through delegatecall");
        require(_getImplementation() == __self, "Function must be called through active proxy");
        _;
    }

    function upgradeTo(address newImplementation) external virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, new bytes(0), false);
    }

    function upgradeToAndCall(address newImplementation, bytes memory data) external payable virtual onlyProxy {
        _authorizeUpgrade(newImplementation);
        _upgradeToAndCallSecure(newImplementation, data, true);
    }

    function _authorizeUpgrade(address newImplementation) internal virtual;
    uint256[50] private __gap;
}


abstract contract GMAgentPaymentProcessor is OwnableUpgradeable {
    IERC20Upgradeable internal stablecoin;
    IGMAccessControl user;
    address internal treasury;
    uint8 serviceCommissionPercent;
    uint8 agentCommissionPercent;


    function __GMAgentPaymentProcessor_init(
        IERC20Upgradeable stablecoin_,
        IGMAccessControl user_,
        address treasury_,
        uint8 serviceCommissionPercent_,
        uint8 agentCommissionPercent_
    ) internal initializer {
        __Ownable_init();
        stablecoin = stablecoin_;
        user = user_;
        treasury = treasury_;
        serviceCommissionPercent = serviceCommissionPercent_;
        agentCommissionPercent = agentCommissionPercent_;
    }

    function processPayment(uint256 amount, address beneficiary, bool isSubjectToAgentFee) internal virtual {
        uint256 serviceCommission = amount * serviceCommissionPercent / 100;
        uint256 paidToBeneficiary = amount - serviceCommission;
        uint256 sentToTreasury = serviceCommission;

        stablecoin.transfer(beneficiary, paidToBeneficiary);
        if (isSubjectToAgentFee) {
            address agent = user.agentOf(beneficiary);
            if (agent != address(0)) {
                uint256 agentCommission = serviceCommission * agentCommissionPercent / 100;
                sentToTreasury -= agentCommission;
                stablecoin.transfer(agent, agentCommission);
            }
        }
        stablecoin.transfer(treasury, sentToTreasury);
    }

    function setTreasury(address treasury_) public onlyOwner {
        treasury = treasury_;
    }

    function setServiceCommissionPercent(uint8 percent_) external onlyOwner {
        require(percent_ < 100, "GMPaymentProcessor: don't be that greedy");
        serviceCommissionPercent = percent_;
    }

    function setAgentCommissionPercent(uint8 percent_) external onlyOwner {
        require(percent_ <= 100, "GMPaymentProcessor: percent, you know, up to 100");
        agentCommissionPercent = percent_;
    }
}


contract GMAuction is IGMAuction, IERC721ReceiverUpgradeable, GMAgentPaymentProcessor, PausableUpgradeable, UUPSUpgradeable {

    event Bid(uint256 artId, uint256 price, address bidder, uint256 minNextBid);
    event AuctionScheduled(uint256 artId, address beneficiary, uint256 startPrice);
    event AuctionStart(uint256 artId, uint256 startPrice, uint256 startTime, uint256 endTime);
    event AuctionEndTimeChanged(uint256 artId, uint256 endTime);
    event AuctionComplete(uint256 artId, uint256 price, address winner, uint256 endTime);
    event AuctionAcquiredToken(uint256 tokenId);


    uint256 public duration;
    uint256 public maxStartPrice; //USDT has 6 decimals
    uint256 constant MIN_DURATION = 1 hours;
    uint256 constant MAX_DURATION = 30 days;
    uint256 constant DEFAULT_DURATION = 2 days;
    uint256 constant AUCTION_PROLONGATION = 15 minutes;
    uint256 constant BID_STEP_PERCENT_MULTIPLIER = 110;

    IERC721Upgradeable public nft;
    address public minter;

    struct Auction {
        address beneficiary;
        uint256 startTime;
        uint256 endTime;
        uint256 startPrice;
        address highestBidder;
        uint256 highestBid;
    }

    mapping(uint256 => Auction) public auctions;
    mapping(uint256 => bool) public isSubjectToAgentFee;

    function initialize(
        IERC721Upgradeable nft_,
        IERC20Upgradeable stablecoin_,
        IGMAccessControl user_,
        address treasury_,
        uint8 serviceCommissionPercent_,
        uint8 agentCommissionPercent_
    ) public initializer {

        __UUPSUpgradeable_init();
        __Pausable_init();
        __GMAgentPaymentProcessor_init(
            stablecoin_,
            user_,
            treasury_,
            serviceCommissionPercent_,
            agentCommissionPercent_);
        nft = nft_;
        duration = 7 days;
        maxStartPrice = 1000 * 10 ** 6;
    }

    function _authorizeUpgrade(address) internal override onlyOwner whenPaused {}


    function scheduleAuction(
        uint256 artId_,
        uint256 startPrice_
    ) external whenNotScheduled(artId_) whenNotPaused onlyHolder(artId_) onlyTrader virtual {

        _checkAuctionParams(
            artId_,
            startPrice_
        );
        address beneficiary = nft.ownerOf(artId_);
        auctions[artId_] = Auction(
            nft.ownerOf(artId_),
            0,
            0,
            startPrice_,
            address(0),
            0
        );
        nft.transferFrom(beneficiary, address(this), artId_);
        _logAuctionScheduled(artId_, auctions[artId_]);
    }

    function scheduleInitialAuction(
        address beneficiary_,
        uint256 artId_,
        uint256 startPrice_
    ) external whenNotScheduled(artId_) whenNotPaused onlyMinter virtual {

        _checkAuctionParams(
            artId_,
            startPrice_
        );
        auctions[artId_] = Auction(
            beneficiary_,
            0,
            0,
            startPrice_,
            address(0),
            0
        );
        isSubjectToAgentFee[artId_] = true;
        require(nft.ownerOf(artId_) == address(this));
        _logAuctionScheduled(artId_, auctions[artId_]);
    }

    function bid(uint256 artId, uint256 amount) external onlyTrader whenScheduled(artId) whenNotFinished(artId) virtual {

        _startAuction(artId);
        Auction storage a = auctions[artId];
        require(amount >= minimumBid(artId), "GMAuction: bid amount must >= 110% of the current hightest bid");
        require(a.highestBidder != msg.sender, "GMAuction: you're the highest bidder already");

        stablecoin.transferFrom(msg.sender, address(this), amount);
        _refundBid(artId);
        a.highestBidder = msg.sender;
        a.highestBid = amount;
        _adjustAuctionEndTime(artId);
        emit Bid(artId, a.highestBid, msg.sender, minimumBid(artId));
    }

    function setDuration(uint256 duration_) external onlyOwner virtual {

        require(duration_ >= MIN_DURATION && duration_ <= MAX_DURATION, "GMAuction: Wrong auction duration length");
        duration = duration_;
    }

    function setMaxStartPrice(uint256 maxStartPrice_) external onlyOwner virtual {

        require(maxStartPrice_ > 0, "GMAuction: start price could not be zero");
        maxStartPrice = maxStartPrice_;
    }

    function pause() external onlyOwner {

        _pause();
    }

    function unpause() external onlyOwner {

        _unpause();
    }

    function completeAuction(uint256 artId) external whenFinished(artId) override {

        Auction storage a = auctions[artId];

        address highestBidder = auctions[artId].highestBidder;
        uint256 highestBid = auctions[artId].highestBid;

        nft.transferFrom(address(this), highestBidder, artId);

        processPayment(highestBid, auctions[artId].beneficiary, isSubjectToAgentFee[artId]);

        emit AuctionComplete(artId, highestBid, highestBidder, auctions[artId].endTime);

        _markNotScheduled(artId);
    }

    function setMinter(address minter_) public onlyOwner override {

        minter = minter_;
    }


    function setUser(IGMAccessControl user_) external onlyOwner override {

        user = user_;
    }

    modifier onlyTrader {

        require(user.isTrader(msg.sender), "GMAuction: only traders are allowed to participate in auctions");
        _;
    }

    modifier onlyMinter {

        require(msg.sender == minter, "GMAuction: action is allowed only to the minter");
        _;
    }

    modifier onlyHolder(uint256 artId) {

        require(msg.sender == nft.ownerOf(artId), "GMAuction: you can't sell what you don't own");
        _;
    }

    modifier whenFinished(uint256 artId) {

        require(started(artId), "GMAuction: action is allowed only for auction that actually happened");
        require(_isFinished(artId), "GMAuction: action is only allowed after the auction end time");
        _;
    }

    modifier whenNotFinished(uint256 artId) {

        require(!_isFinished(artId), "GMAuction: action is only allowed before the auction end time");
        _;
    }

    modifier whenActive(uint256 artId) {

        require(_isActive(artId), "GMAuction: action is allowed when the auction for the item is active");
        _;
    }

    modifier whenNotActive(uint256 artId) {

        require(!_isActive(artId), "GMAuction: action is allowed when there is no active auction for the item");
        _;
    }

    modifier whenScheduled(uint256 artId) {

        require(isScheduled(artId), "GMAuction: action is allowed when an auction is scheduled for the item");
        _;
    }

    modifier whenNotScheduled(uint256 artId) {

        require(!isScheduled(artId), "GMAuction: action is allowed when there is no scheduled auction for the item");
        _;
    }

    function isActive(uint256 artId) external view override returns (bool){

        return _isActive(artId);
    }

    function isScheduled(uint256 artId) public view returns (bool){

        return auctions[artId].startPrice != 0;
    }

    function started(uint256 artId) public view returns (bool) {

        return auctions[artId].highestBid != 0;
    }

    function isFinished(uint256 artId) external view returns (bool) {

        return _isFinished(artId);
    }

    function minimumBid(uint256 artId) public view returns (uint256 minBid){

        if (auctions[artId].highestBid != 0) {
            minBid = auctions[artId].highestBid * BID_STEP_PERCENT_MULTIPLIER / 100;
        } else {
            minBid = auctions[artId].startPrice;
        }
    }

    function _checkAuctionParams(
        uint256 artId_,
        uint256 startPrice_
    ) internal virtual {

        require(nft.ownerOf(artId_) != address(0), "GMAuction constructor: the token must exist");
        require(startPrice_ <= maxStartPrice, "GMAuction constructor: start price too high");
    }

    function _logAuctionScheduled(uint256 artId, Auction storage a) internal virtual {

        emit AuctionScheduled(artId, a.beneficiary, a.startPrice);
    }

    function _refundBid(uint256 artId) private {

        address highestBidder = auctions[artId].highestBidder;
        if (highestBidder != address(0))
            stablecoin.transfer(highestBidder, auctions[artId].highestBid);
    }

    function _adjustAuctionEndTime(uint256 artId) internal virtual {

        uint256 adjustedTime = AUCTION_PROLONGATION + block.timestamp;
        if (auctions[artId].endTime < adjustedTime) {
            auctions[artId].endTime = adjustedTime;
            emit AuctionEndTimeChanged(artId, adjustedTime);
        }
    }

    function _startAuction(uint256 artId) internal virtual {

        if (!started(artId)) {
            auctions[artId].startTime = block.timestamp;
            auctions[artId].endTime = block.timestamp + duration;
            emit AuctionStart(artId, auctions[artId].startPrice, auctions[artId].startTime, auctions[artId].endTime);
        }
    }

    function _markNotScheduled(uint256 artId) internal virtual {

        delete auctions[artId];
        delete isSubjectToAgentFee[artId];
    }

    function _isActive(uint256 artId) internal virtual view returns (bool){

        uint256 startTime = auctions[artId].startTime;
        return startTime > 0 && startTime <= block.timestamp && auctions[artId].endTime > block.timestamp;
    }

    function _isFinished(uint256 artId) internal virtual view returns (bool){

        uint256 startTime = auctions[artId].startTime;
        return startTime > 0 && auctions[artId].endTime < block.timestamp;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4){

        emit AuctionAcquiredToken(tokenId);
        return IERC721ReceiverUpgradeable.onERC721Received.selector;
    }
}


contract GMAuctionSafeERC20 is GMAuction {


    function bid(uint256 artId, uint256 amount) external onlyTrader whenScheduled(artId) whenNotFinished(artId) virtual override {

        _startAuction(artId);
        Auction storage a = auctions[artId];
        require(amount >= minimumBid(artId), "GMAuction: bid amount must >= 110% of the current hightest bid");
        require(a.highestBidder != msg.sender, "GMAuction: you're the highest bidder already");

        safeTransferFrom(msg.sender, address(this), amount);
        refundBid(artId);
        a.highestBidder = msg.sender;
        a.highestBid = amount;
        _adjustAuctionEndTime(artId);
        emit Bid(artId, a.highestBid, msg.sender, minimumBid(artId));
    }

    function processPayment(uint256 amount, address beneficiary, bool isSubjectToAgentFee) internal virtual override {

        uint256 serviceCommission = amount * serviceCommissionPercent / 100;
        uint256 paidToBeneficiary = amount - serviceCommission;
        uint256 sentToTreasury = serviceCommission;

        safeTransfer(beneficiary, paidToBeneficiary);
        if (isSubjectToAgentFee) {
            address agent = user.agentOf(beneficiary);
            if (agent != address(0)) {
                uint256 agentCommission = serviceCommission * agentCommissionPercent / 100;
                sentToTreasury -= agentCommission;
                safeTransfer(agent, agentCommission);
            }
        }
        safeTransfer(treasury, sentToTreasury);
    }

    function refundBid(uint256 artId) internal virtual {

        address highestBidder = auctions[artId].highestBidder;
        if (highestBidder != address(0))
            safeTransfer(highestBidder, auctions[artId].highestBid);
    }

    function safeTransferFrom(address from, address to, uint256 amount) internal virtual {

        SafeERC20Upgradeable.safeTransferFrom(stablecoin, from, to, amount);
    }

    function safeTransfer(address to, uint256 amount) internal virtual {

        SafeERC20Upgradeable.safeTransfer(stablecoin, to, amount);
    }
}