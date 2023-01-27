pragma solidity 0.8.6;

interface ITributaryRegistry {

    function addRegistrar(address registrar) external;


    function removeRegistrar(address registrar) external;


    function addSingletonProducer(address producer) external;


    function removeSingletonProducer(address producer) external;


    function registerTributary(address producer, address tributary) external;


    function producerToTributary(address producer)
        external
        returns (address tributary);


    function singletonProducer(address producer) external returns (bool);


    function changeTributary(address producer, address newTributary) external;

}// GPL-3.0-or-later
pragma solidity 0.8.6;

contract Ownable {

    address public owner;
    address private nextOwner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );


    modifier onlyOwner() {

        require(isOwner(), "caller is not the owner.");
        _;
    }

    modifier onlyNextOwner() {

        require(isNextOwner(), "current owner must set caller as next owner.");
        _;
    }

    constructor(address owner_) {
        owner = owner_;
        emit OwnershipTransferred(address(0), owner);
    }

    function transferOwnership(address nextOwner_) external onlyOwner {

        require(nextOwner_ != address(0), "Next owner is the zero address.");

        nextOwner = nextOwner_;
    }

    function cancelOwnershipTransfer() external onlyOwner {

        delete nextOwner;
    }

    function acceptOwnership() external onlyNextOwner {

        delete nextOwner;

        owner = msg.sender;

        emit OwnershipTransferred(owner, msg.sender);
    }

    function renounceOwnership() external onlyOwner {

        owner = address(0);

        emit OwnershipTransferred(owner, address(0));
    }

    function isOwner() public view returns (bool) {

        return msg.sender == owner;
    }

    function isNextOwner() public view returns (bool) {

        return msg.sender == nextOwner;
    }
}// GPL-3.0-or-later
pragma solidity 0.8.6;

interface IGovernable {

    function changeGovernor(address governor_) external;


    function isGovernor() external view returns (bool);


    function governor() external view returns (address);

}// GPL-3.0-or-later
pragma solidity 0.8.6;


contract Governable is Ownable, IGovernable {


    address public override governor;


    modifier onlyGovernance() {

        require(isOwner() || isGovernor(), "caller is not governance");
        _;
    }

    modifier onlyGovernor() {

        require(isGovernor(), "caller is not governor");
        _;
    }


    constructor(address owner_) Ownable(owner_) {}


    function changeGovernor(address governor_) public override onlyGovernance {

        governor = governor_;
    }


    function isGovernor() public view override returns (bool) {

        return msg.sender == governor;
    }
}// GPL-3.0-or-later
pragma solidity 0.8.6;

interface IERC2309 {

    event ConsecutiveTransfer(
        uint256 indexed fromTokenId,
        uint256 toTokenId,
        address indexed fromAddress,
        address indexed toAddress
    );
}// GPL-3.0-or-later
pragma solidity 0.8.6;

contract AllocatedEditionsStorage {


    struct NFTMetadata {
        string name;
        string symbol;
        bytes32 contentHash;
    }

    struct EditionData {
        uint256 allocation;
        uint256 quantity;
        uint256 price;
    }

    struct AdminData {
        address operator;
        address tributary;
        address payable fundingRecipient;
        uint256 feePercentage;
    }


    string public baseURI;
    bytes32 contentHash;

    uint256 public allocation;
    uint256 public quantity;
    uint256 public price;

    address public operator;
    address public tributary;
    address payable public fundingRecipient;
    uint256 feePercentage;

    address treasuryConfig;


    uint256 internal nextTokenId;
    uint256 internal allocationsTransferred = 0;

    mapping(uint256 => bool) internal _burned;


    mapping(uint256 => address) internal _owners;
    mapping(address => uint256) internal _balances;
    mapping(uint256 => address) internal _tokenApprovals;
    mapping(address => mapping(address => bool)) internal _operatorApprovals;

    mapping(address => bool) internal purchased;

    address public logic;

    address public proxyRegistry;
}// GPL-3.0-or-later
pragma solidity 0.8.6;


interface IAllocatedEditionsFactory {

    function logic() external returns (address);


    function parameters()
        external
        returns (
            bytes memory nftMetaData,
            uint256 allocation,
            uint256 quantity,
            uint256 price,
            bytes memory configData
        );

}// GPL-3.0-or-later
pragma solidity 0.8.6;

interface IPausableEvents {

    event Paused(address account);

    event Unpaused(address account);
}

interface IPausable {

    function paused() external returns (bool);

}

contract Pausable is IPausable, IPausableEvents {

    bool public override paused;


    modifier whenNotPaused() {

        require(!paused, "Pausable: paused");
        _;
    }

    modifier whenPaused() {

        require(paused, "Pausable: not paused");
        _;
    }

    constructor(bool paused_) {
        paused = paused_;
    }


    function _pause() internal whenNotPaused {

        paused = true;

        emit Paused(msg.sender);
    }

    function _unpause() internal whenPaused {

        paused = false;

        emit Unpaused(msg.sender);
    }
}