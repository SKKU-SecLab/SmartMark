pragma solidity ^0.8.0;

interface IERC20 {

    function transfer(address recipient, uint256 amount) external returns (bool);

}

interface ENS {

    function owner(bytes32 node) external view returns (address);

    function resolver(bytes32 node) external view returns (address);

}

interface ReverseRegistrar {

    function setName(string memory name) external returns (bytes32);

}

contract OrgV1 {

    struct Anchor {
        uint32 tag;
        bytes multihash;
    }

    bytes32 public constant ADDR_REVERSE_NODE =
        0x91d1777781884d03a6757a803996e38de2a42967fb37eeaca72729271025a9e2;

    address public owner;

    mapping (bytes32 => Anchor) public anchors;


    event Anchored(bytes32 id, uint32 tag, bytes multihash);

    event Unanchored(bytes32 id);

    event OwnerChanged(address newOwner);

    event NameChanged(string name);

    constructor(address _owner) {
        owner = _owner;
    }


    modifier ownerOnly {

        require(msg.sender == owner, "Org: Only the org owner can perform this action");
        _;
    }

    function setOwner(address newOwner) public ownerOnly {

        owner = newOwner;
        emit OwnerChanged(newOwner);
    }

    function anchor(
        bytes32 id,
        uint32 tag,
        bytes calldata multihash
    ) public ownerOnly {

        anchors[id] = Anchor(tag, multihash);
        emit Anchored(id, tag, multihash);
    }

    function unanchor(bytes32 id) public ownerOnly {

        delete anchors[id];
        emit Unanchored(id);
    }

    function recoverFunds(IERC20 token, uint256 amount) public ownerOnly returns (bool) {

        return token.transfer(msg.sender, amount);
    }

    function setName(string memory name, ENS ens) public ownerOnly returns (bytes32) {

        ReverseRegistrar registrar = ReverseRegistrar(ens.owner(ADDR_REVERSE_NODE));
        bytes32 node = registrar.setName(name);
        emit NameChanged(name);

        return node;
    }
}
pragma solidity ^0.8.0;


interface SafeFactory {

    function createProxy(address masterCopy, bytes memory data) external returns (Safe);

}

interface Safe {

    function setup(
        address[] calldata _owners,
        uint256 _threshold,
        address to,
        bytes calldata data,
        address fallbackHandler,
        address paymentToken,
        uint256 payment,
        address payable paymentReceiver
    ) external;


    function getThreshold() external returns (uint256);

    function isOwner(address owner) external returns (bool);

}

contract OrgV1Factory {

    SafeFactory immutable safeFactory;
    address immutable safeMasterCopy;

    event OrgCreated(address org, address safe);

    constructor(
        address _safeFactory,
        address _safeMasterCopy
    ) {
        safeFactory = SafeFactory(_safeFactory);
        safeMasterCopy = _safeMasterCopy;
    }

    function createOrg(address owner) public returns (OrgV1 org) {

        org = new OrgV1(address(owner));
        emit OrgCreated(address(org), address(owner));
    }

    function createOrg(address[] memory owners, uint256 threshold) public returns (OrgV1 org) {

        require(owners.length > 0, "OrgFactory: owners must not be empty");
        require(threshold > 0, "OrgFactory: threshold must be greater than zero");
        require(threshold <= owners.length, "OrgFactory: threshold must be lesser than or equal to owner count");

        Safe safe = safeFactory.createProxy(safeMasterCopy, new bytes(0));
        safe.setup(owners, threshold, address(0), new bytes(0), address(0), address(0), 0, payable(address(0)));

        org = new OrgV1(address(safe));
        emit OrgCreated(address(org), address(safe));
    }
}
