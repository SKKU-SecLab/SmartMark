

pragma solidity 0.6.12;


abstract contract Initializable {

    bool private _initialized;

    bool private _initializing;

    modifier initializer() {
        require(_initializing || _isConstructor() || !_initialized, "Initializable: contract is already initialized");

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

    function _isConstructor() private view returns (bool) {
        address self = address(this);
        uint256 cs;
        assembly { cs := extcodesize(self) }
        return cs == 0;
    }
}

contract ReentrancyGuardUpgradeable is Initializable {


    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    function __ReentrancyGuard_init() internal initializer {

        __ReentrancyGuard_init_unchained();
    }

    function __ReentrancyGuard_init_unchained() internal initializer {

        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {

        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
    uint256[49] private __gap;
}

library SafeMath128 {

    function add(uint128 a, uint128 b) internal pure returns (uint128) {

        uint128 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint128 a, uint128 b) internal pure returns (uint128) {

        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {

        require(b <= a, errorMessage);
        uint128 c = a - b;

        return c;
    }

    function mul(uint128 a, uint128 b) internal pure returns (uint128) {

        if (a == 0) {
            return 0;
        }

        uint128 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint128 a, uint128 b) internal pure returns (uint128) {

        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {

        require(b > 0, errorMessage);
        uint128 c = a / b;

        return c;
    }

    function mod(uint128 a, uint128 b) internal pure returns (uint128) {

        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint128 a,
        uint128 b,
        string memory errorMessage
    ) internal pure returns (uint128) {

        require(b != 0, errorMessage);
        return a % b;
    }
}

interface ILXTToken {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transfer(address recipient, uint256 amount)
        external
        returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    function burn(uint256 value) external returns (bool);


    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

}

interface ILitexAuctionProtocol {

    function getSlotDeadline() external view returns (uint8);


    function setSlotDeadline(uint8 newDeadline) external;


    function getOpenAuctionSlots() external view returns (uint16);


    function setOpenAuctionSlots(uint16 newOpenAuctionSlots) external;


    function getClosedAuctionSlots() external view returns (uint16);


    function setClosedAuctionSlots(uint16 newClosedAuctionSlots) external;


    function getOutbidding() external view returns (uint16);


    function setOutbidding(uint16 newOutbidding) external;


    function getAllocationRatio() external view returns (uint16[3] memory);


    function setAllocationRatio(uint16[3] memory newAllocationRatio) external;


    function getDonationAddress() external view returns (address);


    function setDonationAddress(address newDonationAddress) external;


    function getBootCoordinator() external view returns (address);


    function setBootCoordinator(
        address newBootCoordinator,
        string memory newBootCoordinatorURL
    ) external;


    function changeDefaultSlotSetBid(uint128 slotSet, uint128 newInitialMinBid)
        external;


    function setCoordinator(address forger, string memory coordinatorURL)
        external;


    function processBid(
        uint128 amount,
        uint128 slot,
        uint128 bidAmount,
        bytes calldata permit
    ) external;


    function processMultiBid(
        uint128 amount,
        uint128 startingSlot,
        uint128 endingSlot,
        bool[6] memory slotSets,
        uint128 maxBid,
        uint128 minBid,
        bytes calldata permit
    ) external;


    function forge(address forger) external;


    function canForge(address forger, uint256 blockNumber)
        external
        view
        returns (bool);

}





contract LitexAuctionProtocol is
    Initializable,
    ReentrancyGuardUpgradeable,
    ILitexAuctionProtocol
{

    using SafeMath128 for uint128;

    struct Coordinator {
        address forger; // Address allowed by the bidder to forge a batch
        string coordinatorURL;
    }

    struct SlotState {
        address bidder;
        bool fulfilled;
        bool forgerCommitment;
        uint128 bidAmount; // Since the total supply of LXT will be less than 100M, with 128 bits it is enough to
        uint128 closedMinBid; // store the bidAmount and closed minBid. bidAmount is the bidding for an specific slot.
    }

    bytes4 private constant _PERMIT_SIGNATURE = 0xd505accf;

    uint8 public constant BLOCKS_PER_SLOT = 40;
    uint128 public constant INITIAL_MINIMAL_BIDDING = 1000000 * (1e18);

    ILXTToken public tokenLXT;
    address public litexRollup;
    address public governanceAddress;
    address private _donationAddress;
    address private _bootCoordinator;
    string public bootCoordinatorURL;
    uint128[6] private _defaultSlotSetBid;
    uint128 public genesisBlock;
    uint16 private _closedAuctionSlots;
    uint16 private _openAuctionSlots;
    uint16[3] private _allocationRatio; // Two decimal precision
    uint16 private _outbidding; // Two decimal precision
    uint8 private _slotDeadline;

    mapping(uint128 => SlotState) public slots;
    mapping(address => uint128) public pendingBalances;
    mapping(address => Coordinator) public coordinators;

    event NewBid(
        uint128 indexed slot,
        uint128 bidAmount,
        address indexed bidder
    );
    event NewSlotDeadline(uint8 newSlotDeadline);
    event NewClosedAuctionSlots(uint16 newClosedAuctionSlots);
    event NewOutbidding(uint16 newOutbidding);
    event NewDonationAddress(address indexed newDonationAddress);
    event NewBootCoordinator(
        address indexed newBootCoordinator,
        string newBootCoordinatorURL
    );
    event NewOpenAuctionSlots(uint16 newOpenAuctionSlots);
    event NewAllocationRatio(uint16[3] newAllocationRatio);
    event SetCoordinator(
        address indexed bidder,
        address indexed forger,
        string coordinatorURL
    );
    event NewForgeAllocated(
        address indexed bidder,
        address indexed forger,
        uint128 indexed slotToForge,
        uint128 burnAmount,
        uint128 donationAmount,
        uint128 governanceAmount
    );
    event NewDefaultSlotSetBid(uint128 slotSet, uint128 newInitialMinBid);
    event NewForge(address indexed forger, uint128 indexed slotToForge);
    event LXTClaimed(address indexed owner, uint128 amount);

    event InitializeLitexAuctionProtocolEvent(
        address donationAddress,
        address bootCoordinatorAddress,
        string bootCoordinatorURL,
        uint16 outbidding,
        uint8 slotDeadline,
        uint16 closedAuctionSlots,
        uint16 openAuctionSlots,
        uint16[3] allocationRatio
    );

    modifier onlyGovernance() {

        require(
            governanceAddress == msg.sender,
            "LitexAuctionProtocol::onlyGovernance: ONLY_GOVERNANCE"
        );
        _;
    }

    function litexAuctionProtocolInitializer(
        address token,
        uint128 genesis,
        address litexRollupAddress,
        address _governanceAddress,
        address donationAddress,
        address bootCoordinatorAddress,
        string memory _bootCoordinatorURL
    ) public initializer {

        __ReentrancyGuard_init_unchained();

        require(
            litexRollupAddress != address(0),
            "LitexAuctionProtocol::litexAuctionProtocolInitializer ADDRESS_0_NOT_VALID"
        );

        _outbidding = 1000;
        _slotDeadline = 20;
        _closedAuctionSlots = 2;
        _openAuctionSlots = 4320;
        _allocationRatio = [4000, 4000, 2000];
        _defaultSlotSetBid = [
            INITIAL_MINIMAL_BIDDING,
            INITIAL_MINIMAL_BIDDING,
            INITIAL_MINIMAL_BIDDING,
            INITIAL_MINIMAL_BIDDING,
            INITIAL_MINIMAL_BIDDING,
            INITIAL_MINIMAL_BIDDING
        ];

        require(
            genesis >= block.number,
            "LitexAuctionProtocol::litexAuctionProtocolInitializer GENESIS_BELOW_MINIMAL"
        );

        tokenLXT = ILXTToken(token);

        genesisBlock = genesis;
        litexRollup = litexRollupAddress;
        governanceAddress = _governanceAddress;
        _donationAddress = donationAddress;
        _bootCoordinator = bootCoordinatorAddress;
        bootCoordinatorURL = _bootCoordinatorURL;

        emit InitializeLitexAuctionProtocolEvent(
            donationAddress,
            bootCoordinatorAddress,
            _bootCoordinatorURL,
            _outbidding,
            _slotDeadline,
            _closedAuctionSlots,
            _openAuctionSlots,
            _allocationRatio
        );
    }

    function getSlotDeadline() external override view returns (uint8) {

        return _slotDeadline;
    }

    function setSlotDeadline(uint8 newDeadline)
        external
        override
        onlyGovernance
    {

        require(
            newDeadline <= BLOCKS_PER_SLOT,
            "LitexAuctionProtocol::setSlotDeadline: GREATER_THAN_BLOCKS_PER_SLOT"
        );
        _slotDeadline = newDeadline;
        emit NewSlotDeadline(_slotDeadline);
    }

    function getOpenAuctionSlots() external override view returns (uint16) {

        return _openAuctionSlots;
    }

    function setOpenAuctionSlots(uint16 newOpenAuctionSlots)
        external
        override
        onlyGovernance
    {

        _openAuctionSlots = newOpenAuctionSlots;
        emit NewOpenAuctionSlots(_openAuctionSlots);
    }

    function getClosedAuctionSlots() external override view returns (uint16) {

        return _closedAuctionSlots;
    }

    function setClosedAuctionSlots(uint16 newClosedAuctionSlots)
        external
        override
        onlyGovernance
    {

        _closedAuctionSlots = newClosedAuctionSlots;
        emit NewClosedAuctionSlots(_closedAuctionSlots);
    }

    function getOutbidding() external override view returns (uint16) {

        return _outbidding;
    }

    function setOutbidding(uint16 newOutbidding)
        external
        override
        onlyGovernance
    {

        require(
            newOutbidding > 1 && newOutbidding < 10000,
            "LitexAuctionProtocol::setOutbidding: OUTBIDDING_NOT_VALID"
        );
        _outbidding = newOutbidding;
        emit NewOutbidding(_outbidding);
    }

    function getAllocationRatio()
        external
        override
        view
        returns (uint16[3] memory)
    {

        return _allocationRatio;
    }

    function setAllocationRatio(uint16[3] memory newAllocationRatio)
        external
        override
        onlyGovernance
    {

        require(
            newAllocationRatio[0] <= 10000 &&
                newAllocationRatio[1] <= 10000 &&
                newAllocationRatio[2] <= 10000 &&
                newAllocationRatio[0] +
                    newAllocationRatio[1] +
                    newAllocationRatio[2] ==
                10000,
            "LitexAuctionProtocol::setAllocationRatio: ALLOCATION_RATIO_NOT_VALID"
        );
        _allocationRatio = newAllocationRatio;
        emit NewAllocationRatio(_allocationRatio);
    }

    function getDonationAddress() external override view returns (address) {

        return _donationAddress;
    }

    function setDonationAddress(address newDonationAddress)
        external
        override
        onlyGovernance
    {

        require(
            newDonationAddress != address(0),
            "LitexAuctionProtocol::setDonationAddress: NOT_VALID_ADDRESS"
        );
        _donationAddress = newDonationAddress;
        emit NewDonationAddress(_donationAddress);
    }

    function getBootCoordinator() external override view returns (address) {

        return _bootCoordinator;
    }

    function setBootCoordinator(
        address newBootCoordinator,
        string memory newBootCoordinatorURL
    ) external override onlyGovernance {

        _bootCoordinator = newBootCoordinator;
        bootCoordinatorURL = newBootCoordinatorURL;
        emit NewBootCoordinator(_bootCoordinator, newBootCoordinatorURL);
    }

    function getDefaultSlotSetBid(uint8 slotSet) public view returns (uint128) {

        return _defaultSlotSetBid[slotSet];
    }

    function changeDefaultSlotSetBid(uint128 slotSet, uint128 newInitialMinBid)
        external
        override
        onlyGovernance
    {

        require(
            slotSet < _defaultSlotSetBid.length,
            "LitexAuctionProtocol::changeDefaultSlotSetBid: NOT_VALID_SLOT_SET"
        );
        require(
            _defaultSlotSetBid[slotSet] != 0,
            "LitexAuctionProtocol::changeDefaultSlotSetBid: SLOT_DECENTRALIZED"
        );

        uint128 current = getCurrentSlotNumber();
        for (uint128 i = current; i <= current + _closedAuctionSlots; i++) {
            if (slots[i].closedMinBid == 0) {
                slots[i].closedMinBid = _defaultSlotSetBid[getSlotSet(i)];
            }
        }
        _defaultSlotSetBid[slotSet] = newInitialMinBid;
        emit NewDefaultSlotSetBid(slotSet, newInitialMinBid);
    }

    function setCoordinator(address forger, string memory coordinatorURL)
        external
        override
    {

        require(
            keccak256(abi.encodePacked(coordinatorURL)) !=
                keccak256(abi.encodePacked("")),
            "LitexAuctionProtocol::setCoordinator: NOT_VALID_URL"
        );
        coordinators[msg.sender].forger = forger;
        coordinators[msg.sender].coordinatorURL = coordinatorURL;
        emit SetCoordinator(msg.sender, forger, coordinatorURL);
    }

    function getCurrentSlotNumber() public view returns (uint128) {

        return getSlotNumber(uint128(block.number));
    }

    function getSlotNumber(uint128 blockNumber) public view returns (uint128) {

        return
            (blockNumber >= genesisBlock)
                ? ((blockNumber - genesisBlock) / BLOCKS_PER_SLOT)
                : uint128(0);
    }

    function getSlotSet(uint128 slot) public view returns (uint128) {

        return slot.mod(uint128(_defaultSlotSetBid.length));
    }

    function getMinBidBySlot(uint128 slot) public view returns (uint128) {

        require(
            slot > (getCurrentSlotNumber() + _closedAuctionSlots),
            "LitexAuctionProtocol::getMinBidBySlot: AUCTION_CLOSED"
        );
        uint128 slotSet = getSlotSet(slot);
        return
            (slots[slot].bidAmount == 0)
                ? _defaultSlotSetBid[slotSet].add(
                    _defaultSlotSetBid[slotSet].mul(_outbidding).div(
                        uint128(10000) // two decimal precision
                    )
                )
                : slots[slot].bidAmount.add(
                    slots[slot].bidAmount.mul(_outbidding).div(uint128(10000)) // two decimal precision
                );
    }

    function processBid(
        uint128 amount,
        uint128 slot,
        uint128 bidAmount,
        bytes calldata permit
    ) external override {

        require(
            coordinators[msg.sender].forger != address(0),
            "LitexAuctionProtocol::processBid: COORDINATOR_NOT_REGISTERED"
        );
        require(
            slot > (getCurrentSlotNumber() + _closedAuctionSlots),
            "LitexAuctionProtocol::processBid: AUCTION_CLOSED"
        );
        require(
            bidAmount >= getMinBidBySlot(slot),
            "LitexAuctionProtocol::processBid: BELOW_MINIMUM"
        );

        require(
            slot <=
                (getCurrentSlotNumber() +
                    _closedAuctionSlots +
                    _openAuctionSlots),
            "LitexAuctionProtocol::processBid: AUCTION_NOT_OPEN"
        );

        if (permit.length != 0) {
            _permit(amount, permit);
        }

        require(
            tokenLXT.transferFrom(msg.sender, address(this), amount),
            "LitexAuctionProtocol::processBid: TOKEN_TRANSFER_FAILED"
        );
        pendingBalances[msg.sender] = pendingBalances[msg.sender].add(amount);

        require(
            pendingBalances[msg.sender] >= bidAmount,
            "LitexAuctionProtocol::processBid: NOT_ENOUGH_BALANCE"
        );
        _doBid(slot, bidAmount, msg.sender);
    }

    function processMultiBid(
        uint128 amount,
        uint128 startingSlot,
        uint128 endingSlot,
        bool[6] memory slotSets,
        uint128 maxBid,
        uint128 minBid,
        bytes calldata permit
    ) external override {

        require(
            startingSlot > (getCurrentSlotNumber() + _closedAuctionSlots),
            "LitexAuctionProtocol::processMultiBid AUCTION_CLOSED"
        );
        require(
            endingSlot <=
                (getCurrentSlotNumber() +
                    _closedAuctionSlots +
                    _openAuctionSlots),
            "LitexAuctionProtocol::processMultiBid AUCTION_NOT_OPEN"
        );
        require(
            maxBid >= minBid,
            "LitexAuctionProtocol::processMultiBid MAXBID_GREATER_THAN_MINBID"
        );
        require(
            coordinators[msg.sender].forger != address(0),
            "LitexAuctionProtocol::processMultiBid COORDINATOR_NOT_REGISTERED"
        );

        if (permit.length != 0) {
            _permit(amount, permit);
        }

        require(
            tokenLXT.transferFrom(msg.sender, address(this), amount),
            "LitexAuctionProtocol::processMultiBid: TOKEN_TRANSFER_FAILED"
        );
        pendingBalances[msg.sender] = pendingBalances[msg.sender].add(amount);

        uint128 bidAmount;
        for (uint128 slot = startingSlot; slot <= endingSlot; slot++) {
            uint128 minBidBySlot = getMinBidBySlot(slot);
            if (minBidBySlot <= minBid) {
                bidAmount = minBid;
            } else if (minBidBySlot > minBid && minBidBySlot <= maxBid) {
                bidAmount = minBidBySlot;
            } else {
                continue;
            }

            if (slotSets[getSlotSet(slot)]) {
                require(
                    pendingBalances[msg.sender] >= bidAmount,
                    "LitexAuctionProtocol::processMultiBid NOT_ENOUGH_BALANCE"
                );
                _doBid(slot, bidAmount, msg.sender);
            }
        }
    }

    function _permit(uint256 _amount, bytes calldata _permitData) internal {

        bytes4 sig = abi.decode(_permitData, (bytes4));

        require(
            sig == _PERMIT_SIGNATURE,
            "LitexAuctionProtocol::_permit: NOT_VALID_CALL"
        );
        (
            address owner,
            address spender,
            uint256 value,
            uint256 deadline,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = abi.decode(
            _permitData[4:],
            (address, address, uint256, uint256, uint8, bytes32, bytes32)
        );
        require(
            owner == msg.sender,
            "LitexAuctionProtocol::_permit: OWNER_NOT_EQUAL_SENDER"
        );
        require(
            spender == address(this),
            "LitexAuctionProtocol::_permit: SPENDER_NOT_EQUAL_THIS"
        );
        require(
            value == _amount,
            "LitexAuctionProtocol::_permit: WRONG_AMOUNT"
        );

        address(tokenLXT).call(
            abi.encodeWithSelector(
                _PERMIT_SIGNATURE,
                owner,
                spender,
                value,
                deadline,
                v,
                r,
                s
            )
        );
    }

    function _doBid(
        uint128 slot,
        uint128 bidAmount,
        address bidder
    ) private {

        address prevBidder = slots[slot].bidder;
        uint128 prevBidValue = slots[slot].bidAmount;
        require(
            bidAmount > prevBidValue,
            "LitexAuctionProtocol::_doBid: BID_MUST_BE_HIGHER"
        );

        pendingBalances[bidder] = pendingBalances[bidder].sub(bidAmount);

        slots[slot].bidder = bidder;
        slots[slot].bidAmount = bidAmount;

        if (prevBidder != address(0) && prevBidValue != 0) {
            pendingBalances[prevBidder] = pendingBalances[prevBidder].add(
                prevBidValue
            );
        }
        emit NewBid(slot, bidAmount, bidder);
    }

    function canForge(address forger, uint256 blockNumber)
        external
        override
        view
        returns (bool)
    {

        return _canForge(forger, blockNumber);
    }

    function _canForge(address forger, uint256 blockNumber)
        internal
        view
        returns (bool)
    {

        require(
            blockNumber < 2**128,
            "LitexAuctionProtocol::canForge WRONG_BLOCKNUMBER"
        );
        require(
            blockNumber >= genesisBlock,
            "LitexAuctionProtocol::canForge AUCTION_NOT_STARTED"
        );

        uint128 slotToForge = getSlotNumber(uint128(blockNumber));
        uint128 relativeBlock = uint128(blockNumber).sub(
            (slotToForge.mul(BLOCKS_PER_SLOT)).add(genesisBlock)
        );
        uint128 minBid = (slots[slotToForge].closedMinBid == 0)
            ? _defaultSlotSetBid[getSlotSet(slotToForge)]
            : slots[slotToForge].closedMinBid;

        if (
            !slots[slotToForge].forgerCommitment &&
            (relativeBlock >= _slotDeadline)
        ) {
            return true;
        } else if (
            (coordinators[slots[slotToForge].bidder].forger == forger) &&
            (slots[slotToForge].bidAmount >= minBid)
        ) {
            return true;
        } else if (
            (_bootCoordinator == forger) &&
            ((slots[slotToForge].bidAmount < minBid) ||
                (slots[slotToForge].bidAmount == 0))
        ) {
            return true;
        } else {
            return false;
        }
    }

    function forge(address forger) external override {

        require(
            msg.sender == litexRollup,
            "LitexAuctionProtocol::forge: ONLY_HERMEZ_ROLLUP"
        );
        require(
            _canForge(forger, block.number),
            "LitexAuctionProtocol::forge: CANNOT_FORGE"
        );
        uint128 slotToForge = getCurrentSlotNumber();

        if (!slots[slotToForge].forgerCommitment) {
            uint128 relativeBlock = uint128(block.number).sub(
                (slotToForge.mul(BLOCKS_PER_SLOT)).add(genesisBlock)
            );
            if (relativeBlock < _slotDeadline) {
                slots[slotToForge].forgerCommitment = true;
            }
        }

        if (!slots[slotToForge].fulfilled) {
            slots[slotToForge].fulfilled = true;

            if (slots[slotToForge].bidAmount != 0) {
                uint128 minBid = (slots[slotToForge].closedMinBid == 0)
                    ? _defaultSlotSetBid[getSlotSet(slotToForge)]
                    : slots[slotToForge].closedMinBid;

                if (slots[slotToForge].bidAmount < minBid) {
                    pendingBalances[slots[slotToForge]
                        .bidder] = pendingBalances[slots[slotToForge].bidder]
                        .add(slots[slotToForge].bidAmount);
                } else {
                    uint128 bidAmount = slots[slotToForge].bidAmount;

                    uint128 amountToBurn = bidAmount
                        .mul(_allocationRatio[0])
                        .div(uint128(10000)); // Two decimal precision
                    uint128 donationAmount = bidAmount
                        .mul(_allocationRatio[1])
                        .div(uint128(10000)); // Two decimal precision
                    uint128 governanceAmount = bidAmount
                        .mul(_allocationRatio[2])
                        .div(uint128(10000)); // Two decimal precision

                    require(
                        tokenLXT.burn(amountToBurn),
                        "LitexAuctionProtocol::forge: TOKEN_BURN_FAILED"
                    );

                    pendingBalances[_donationAddress] = pendingBalances[_donationAddress]
                        .add(donationAmount);
                    pendingBalances[governanceAddress] = pendingBalances[governanceAddress]
                        .add(governanceAmount);

                    emit NewForgeAllocated(
                        slots[slotToForge].bidder,
                        forger,
                        slotToForge,
                        amountToBurn,
                        donationAmount,
                        governanceAmount
                    );
                }
            }
        }
        emit NewForge(forger, slotToForge);
    }

    function claimPendingLXT(uint128 slot) public {

        require(
            slot < getCurrentSlotNumber(),
            "LitexAuctionProtocol::claimPendingLXT: ONLY_IF_PREVIOUS_SLOT"
        );
        require(
            !slots[slot].fulfilled,
            "LitexAuctionProtocol::claimPendingLXT: ONLY_IF_NOT_FULFILLED"
        );
        uint128 minBid = (slots[slot].closedMinBid == 0)
            ? _defaultSlotSetBid[getSlotSet(slot)]
            : slots[slot].closedMinBid;

        require(
            slots[slot].bidAmount < minBid,
            "LitexAuctionProtocol::claimPendingLXT: ONLY_IF_NOT_FULFILLED"
        );

        slots[slot].closedMinBid = minBid;
        slots[slot].fulfilled = true;

        pendingBalances[slots[slot].bidder] = pendingBalances[slots[slot]
            .bidder]
            .add(slots[slot].bidAmount);
    }

    function getClaimableLXT(address bidder) public view returns (uint128) {

        return pendingBalances[bidder];
    }

    function claimLXT() public nonReentrant {

        uint128 pending = getClaimableLXT(msg.sender);
        require(
            pending > 0,
            "LitexAuctionProtocol::claimLXT: NOT_ENOUGH_BALANCE"
        );
        pendingBalances[msg.sender] = 0;
        require(
            tokenLXT.transfer(msg.sender, pending),
            "LitexAuctionProtocol::claimLXT: TOKEN_TRANSFER_FAILED"
        );
        emit LXTClaimed(msg.sender, pending);
    }
}