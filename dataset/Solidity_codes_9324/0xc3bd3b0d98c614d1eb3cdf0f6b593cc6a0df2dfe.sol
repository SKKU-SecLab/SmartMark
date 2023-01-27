
pragma solidity ^0.8.4;

interface IMOLOCH {


    function depositToken() external view returns (address);


    function tokenWhitelist(address token) external view returns (bool);


    function shamans(address token) external view returns (bool);


    function totalShares() external view returns (uint256);


    function getProposalFlags(uint256 proposalId)
        external
        view
        returns (bool[6] memory);


    function getUserTokenBalance(address user, address token)
        external
        view
        returns (uint256);


    function members(address user)
        external
        view
        returns (
            address,
            uint256,
            uint256,
            bool,
            uint256,
            uint256
        );


    function memberAddressByDelegateKey(address user)
        external
        view
        returns (address);


    function userTokenBalances(address user, address token)
        external
        view
        returns (uint256);


    function cancelProposal(uint256 proposalId) external;


    function submitProposal(
        address applicant,
        uint256 sharesRequested,
        uint256 lootRequested,
        uint256 tributeOffered,
        address tributeToken,
        uint256 paymentRequested,
        address paymentToken,
        string calldata details
    ) external returns (uint256);


    function withdrawBalance(address token, uint256 amount) external;


    function collectTokens(address) external;


    struct Proposal {
        address applicant; // the applicant who wishes to become a member - this key will be used for withdrawals (doubles as guild kick target for gkick proposals)
        address proposer; // the account that submitted the proposal (can be non-member)
        address sponsor; // the member that sponsored the proposal (moving it into the queue)
        uint256 sharesRequested; // the # of shares the applicant is requesting
        uint256 lootRequested; // the amount of loot the applicant is requesting
        uint256 tributeOffered; // amount of tokens offered as tribute
        address tributeToken; // tribute token contract reference
        uint256 paymentRequested; // amount of tokens requested as payment
        address paymentToken; // payment token contract reference
        uint256 startingPeriod; // the period in which voting can start for this proposal
        uint256 yesVotes; // the total number of YES votes for this proposal
        uint256 noVotes; // the total number of NO votes for this proposal
        bool[6] flags; // [sponsored, processed, didPass, cancelled, whitelist, guildkick]
        string details; // proposal details - could be IPFS hash, plaintext, or JSON
        uint256 maxTotalSharesAndLootAtYesVote; // the maximum # of total shares encountered at a yes vote on this proposal
    }

    function proposals(uint256 proposalId)
        external
        view
        returns (
            address,
            address,
            address,
            uint256,
            uint256,
            uint256,
            address,
            uint256,
            address,
            uint256,
            uint256,
            uint256
        );


    function setSharesLoot(
        address[] calldata,
        uint256[] calldata,
        uint256[] calldata,
        bool mint
    ) external;


    function setSingleSharesLoot(
        address,
        uint256,
        uint256,
        bool
    ) external;


    function setShaman(address, bool) external;

}

interface IWRAPPER {

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

}

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
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

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
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

contract Yeeter is ReentrancyGuard {

    event YeetReceived(
        address indexed contributorAddress,
        uint256 amount,
        address moloch,
        uint256 lootToGive,
        uint256 lootToPlatform
    );
    mapping(address => uint256) public deposits;
    uint256 public maxTarget;
    uint256 public raiseEndTime;
    uint256 public raiseStartTime;
    uint256 public maxUnitsPerAddr;
    uint256 public pricePerUnit;
    uint256 public lootPerUnit;
    bool public initialized;

    uint256 public platformFee;

    uint256 public balance;
    IMOLOCH public moloch;
    IWRAPPER public wrapper;

    YeetSummoner factory;

    function init(
        address _moloch,
        address payable _wrapper,
        uint256 _maxTarget, // max raise target
        uint256 _raiseEndTime,
        uint256 _raiseStartTime,
        uint256 _maxUnits, // per individual
        uint256 _pricePerUnit
    ) public {

        require(!initialized, "already initialized");
        initialized = true;
        moloch = IMOLOCH(_moloch);
        wrapper = IWRAPPER(_wrapper);
        maxTarget = _maxTarget;
        raiseEndTime = _raiseEndTime;
        raiseStartTime = _raiseStartTime;
        maxUnitsPerAddr = _maxUnits;
        pricePerUnit = _pricePerUnit;

        factory = YeetSummoner(msg.sender);
    }

    function initTemplate() public {

        initialized = true;
    }

    function yeetyeet() public payable nonReentrant {

        require(address(moloch) != address(0), "!init");
        require(msg.value >= pricePerUnit, "< minimum");
        require(balance < maxTarget, "Max Target reached"); // balance plus newvalue
        require(block.timestamp < raiseEndTime, "Time is up");
        require(block.timestamp > raiseStartTime, "Not Started");
        require(moloch.shamans(address(this)), "Shaman not whitelisted");
        require(
            moloch.tokenWhitelist(address(wrapper)),
            "Wrapper not whitelisted"
        );
        uint256 numUnits = msg.value / pricePerUnit; // floor units
        uint256 newValue = numUnits * pricePerUnit;

        require(
            deposits[msg.sender] + newValue <= maxUnitsPerAddr * pricePerUnit,
            "Can not deposit more than max"
        );

        (bool success, ) = address(wrapper).call{value: newValue}("");
        require(success, "Wrap failed");
        require(wrapper.transfer(address(moloch), newValue), "Transfer failed");

        if (msg.value > newValue) {
            (bool success2, ) = msg.sender.call{value: msg.value - newValue}(
                ""
            );
            require(success2, "Transfer failed");
        }
        deposits[msg.sender] = deposits[msg.sender] + newValue;

        balance = balance + newValue;

        uint256 lootToGive = (numUnits * factory.lootPerUnit());
        uint256 lootToPlatform = (numUnits * factory.platformFee());

        moloch.setSingleSharesLoot(msg.sender, 0, lootToGive, true);
        if (lootToPlatform > 0) {
            moloch.setSingleSharesLoot(
                factory.owner(),
                0,
                lootToPlatform,
                true
            );
        }

        moloch.collectTokens(address(wrapper));

        emit YeetReceived(
            msg.sender,
            newValue,
            address(moloch),
            lootToGive,
            lootToPlatform
        );
    }

    receive() external payable {
        yeetyeet();
    }

    function goalReached() public view returns (bool) {

        return balance >= maxTarget;
    }
}

contract CloneFactory {

    function createClone(address target) internal returns (address result) {

        bytes20 targetBytes = bytes20(target);
        assembly {
            let clone := mload(0x40)
            mstore(
                clone,
                0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
            )
            mstore(add(clone, 0x14), targetBytes)
            mstore(
                add(clone, 0x28),
                0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000
            )
            result := create(0, clone, 0x37)
        }
    }
}

contract YeetSummoner is CloneFactory, Ownable {

    address payable public template;
    mapping(uint256 => address) public yeeters;
    uint256 public yeetIdx = 0;

    uint256 public platformFee = 3; // fee of 3.09%
    uint256 public lootPerUnit = 100;

    event PlatformFeeUpdate(uint256 platformFee, uint256 lootPerUnit);

    event SummonYeetComplete(
        address indexed moloch,
        address yeeter,
        address wrapper,
        uint256 maxTarget,
        uint256 raiseEndTime,
        uint256 raiseStartTime,
        uint256 maxUnits,
        uint256 pricePerUnit,
        string details
    );

    constructor(address payable _template) {
        template = _template;
        Yeeter _yeeter = Yeeter(_template);
        _yeeter.initTemplate();
    }

    function summonYeet(
        address _moloch,
        address payable _wrapper,
        uint256 _maxTarget,
        uint256 _raiseEndTime,
        uint256 _raiseStartTime,
        uint256 _maxUnits,
        uint256 _pricePerUnit,
        string calldata _details
    ) public returns (address) {

        Yeeter yeeter = Yeeter(payable(createClone(template)));

        yeeter.init(
            _moloch,
            _wrapper,
            _maxTarget,
            _raiseEndTime,
            _raiseStartTime,
            _maxUnits,
            _pricePerUnit
        );
        yeetIdx = yeetIdx + 1;
        yeeters[yeetIdx] = address(yeeter);

        emit SummonYeetComplete(
            _moloch,
            address(yeeter),
            _wrapper,
            _maxTarget,
            _raiseEndTime,
            _raiseStartTime,
            _maxUnits,
            _pricePerUnit,
            _details
        );

        return address(yeeter);
    }

    function setConfig(uint256 _platformFee, uint256 _lootPerUnit)
        public
        onlyOwner
    {

        require(_lootPerUnit > 0, "Can not be 0");
        platformFee = _platformFee;
        lootPerUnit = _lootPerUnit;
        emit PlatformFeeUpdate(platformFee, lootPerUnit);
    }
}