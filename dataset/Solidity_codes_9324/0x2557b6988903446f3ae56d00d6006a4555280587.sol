
pragma solidity ^0.8.7;

interface IENSTogetherNFT {

    function mint(
        address from,
        address to,
        string calldata ens1,
        string calldata ens2
    ) external;


    function tokenURI(uint256 tokenId) external view returns (string memory);


    function ownedNFTS(address _owner) external view returns (uint256[] memory);


    function burn(uint256 tokenId, address _add) external;

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
}// GPL-3.0

pragma solidity ^0.8.7;


interface IDefaultResolver {

    function name(bytes32 node) external view returns (string memory);

}

interface IReverseRegistrar {

    function node(address addr) external view returns (bytes32);

    function defaultResolver() external view returns (IDefaultResolver);

}

contract ENSTogether is ReentrancyGuard, Ownable {

    IReverseRegistrar ensReverseRegistrar;
    IENSTogetherNFT ensTogetherNFT;

    uint256 public cost = 0.08 ether;
    uint256 public updateStatusCost = 0.04 ether;
    uint256 public timeToRespond = 1 weeks;
    uint256 public proposalsCounter = 0;
    uint256 public registryCounter = 0;

    enum Proposal {
        NOTHING,
        PENDING,
        ACCEPTED,
        DECLINED
    }
    Proposal proposalStatus;
    enum Status {
        NOTHING,
        TOGETHER,
        PAUSED,
        SEPARATED
    }
    Status relationshipStatus;

    struct Union {
        address to;
        uint8 proposalStatus;
        address from;
        uint8 relationshipStatus;
        uint256 proposalNumber;
        uint256 registryNumber;
        uint256 createdAt;
        bool expired;
    }

    mapping(address => Union) public unionWith;

    constructor(address ensReverseRegistrar_) {
        ensReverseRegistrar = IReverseRegistrar(ensReverseRegistrar_);
    }

    event ProposalSubmitted(address indexed to, address indexed from);
    event ProposalResponded(
        address indexed to,
        address indexed from,
        uint256 indexed _status
    );
    event ProposalCancelled(address indexed to, address indexed from);
    event GotUnited(
        address indexed from,
        address indexed to,
        uint256 indexed _timestamp,
        uint256 _registrationNumber
    );
    event UnionStatusUpdated(
        address indexed from,
        address indexed to,
        uint256 _status,
        uint256 indexed _timestamp
    );
    error SenderPendingProposal();
    error ReceiverPendingProposal();
    event Burned(uint256 id, bool);

    function propose(address _to) external payable {

        require(msg.value == cost, "Insufficient amount");
        require(_to != msg.sender, "Can't registry with yourself as a partner");
        require(
            unionWith[msg.sender].relationshipStatus == uint8(Status.NOTHING) ||
                unionWith[msg.sender].relationshipStatus ==
                uint8(Status.SEPARATED),
            "You are already united"
        );
        require(
            unionWith[_to].relationshipStatus == uint8(Status.NOTHING) ||
                unionWith[_to].expired == true,
            "This address is already in a relationship"
        );
        string memory ensFrom = lookupENSName(msg.sender);
        string memory ensTo = lookupENSName(_to);
        require(bytes(ensFrom).length > 0, "Sender doesn't have ENS name");
        require(
            bytes(ensTo).length > 0,
            "The address you're proposing to doesnt have ENS name"
        );
        if (
            unionWith[msg.sender].to != address(0) &&
            block.timestamp < unionWith[msg.sender].createdAt + timeToRespond &&
            unionWith[msg.sender].expired == false
        ) {
            revert SenderPendingProposal();
        } else if (
            unionWith[_to].proposalStatus == uint8(Proposal.PENDING) &&
            block.timestamp < unionWith[_to].createdAt + timeToRespond
        ) {
            revert ReceiverPendingProposal();
        } else {
            Union memory request;
            request.to = _to;
            request.from = msg.sender;
            request.createdAt = block.timestamp;
            request.proposalNumber = proposalsCounter;
            request.proposalStatus = uint8(Proposal.PENDING);
            unionWith[_to] = request;
            unionWith[msg.sender] = request;
            proposalsCounter++;
        }
        emit ProposalSubmitted(_to, msg.sender);
    }

    function lookupENSName(address addr) public view returns (string memory) {

        bytes32 node = ensReverseRegistrar.node(addr);
        return ensReverseRegistrar.defaultResolver().name(node);
    }

    function respondToProposal(
        Proposal response,
        string calldata ens1,
        string calldata ens2
    ) external payable {

        require(
            uint8(response) != uint8(Proposal.NOTHING) &&
            uint8(response) != uint8(Proposal.PENDING),
            "Response not valid"
        );
        require(
            block.timestamp < unionWith[msg.sender].createdAt + timeToRespond,
            "Proposal expired"
        );
        require(
            unionWith[msg.sender].to == msg.sender,
            "You cant respond your own proposal, that's scary"
        );
        require(
            unionWith[msg.sender].proposalStatus == uint8(Proposal.PENDING),
            "This proposal has already been responded"
        );
        string memory ensFrom = lookupENSName(unionWith[msg.sender].from);
        string memory ensTo = lookupENSName(unionWith[msg.sender].to);
        require(
            keccak256(abi.encodePacked(ens1)) ==
                keccak256(abi.encodePacked(ensFrom)) ||
                keccak256(abi.encodePacked(ens1)) ==
                keccak256(abi.encodePacked(ensTo)),
            "First ENS name doesn't match with addresses involved"
        );
        require(
            keccak256(abi.encodePacked(ens2)) ==
                keccak256(abi.encodePacked(ensFrom)) ||
                keccak256(abi.encodePacked(ens2)) ==
                keccak256(abi.encodePacked(ensTo)),
            "Second ENS name doesn't match with addresses involved"
        );
        Union memory acceptOrDecline = unionWith[msg.sender];
        address from = acceptOrDecline.from;
        address to = acceptOrDecline.to;
        acceptOrDecline.createdAt = block.timestamp;
        if (uint8(response) == 3) {
            acceptOrDecline.expired = true;
            acceptOrDecline.proposalStatus = uint8(Proposal.DECLINED);
            unionWith[to] = acceptOrDecline;
            unionWith[from] = acceptOrDecline;
            emit ProposalCancelled(to, from);
            return;
        }
        else if (uint8(response) == 2) {
            acceptOrDecline.proposalStatus = uint8(Proposal.ACCEPTED);
            acceptOrDecline.relationshipStatus = uint8(Status.TOGETHER);
            acceptOrDecline.registryNumber = registryCounter;
            unionWith[to] = acceptOrDecline;
            unionWith[from] = acceptOrDecline;
            registryCounter++;
            emit ProposalResponded(to, from, uint8(Proposal.ACCEPTED));
            IENSTogetherNFT(ensTogetherNFT).mint(from, to, ens1, ens2);
            emit GotUnited(from, msg.sender, block.timestamp, acceptOrDecline.registryNumber);
        } else revert("Transaction failed");
    }

    function cancelOrResetProposal() public payable {

        Union memory currentProposal = unionWith[msg.sender];
        address to = currentProposal.to;
        address from = currentProposal.from;
        currentProposal.proposalStatus = uint8(Proposal.DECLINED);
        currentProposal.expired = true;
        unionWith[to] = currentProposal;
        unionWith[from] = currentProposal;
        emit ProposalCancelled(to, from);
    }
    function updateUnion(Status newStatus) external payable {

        require(msg.value >= updateStatusCost, "Insufficient amount");
        require(
            unionWith[msg.sender].relationshipStatus != uint8(Status.SEPARATED),
            "You are separated, make another proposal"
        );
        Union memory unionUpdated = unionWith[msg.sender];
        address from = unionUpdated.from;
        address to = unionUpdated.to;
        unionUpdated.relationshipStatus = uint8(newStatus);
        unionUpdated.createdAt = block.timestamp;
        if (uint8(newStatus) == 3) {
            unionUpdated.proposalStatus = uint8(Proposal.DECLINED);
            unionUpdated.expired = true;
        }
        unionWith[to] = unionUpdated;
        unionWith[from] = unionUpdated;
        emit UnionStatusUpdated(from, to, uint256(newStatus), block.timestamp);
    }

    function getTokenUri(uint256 _tokenId)
        external
        view
        returns (string memory)
    {

        string memory uri = IENSTogetherNFT(ensTogetherNFT).tokenURI(_tokenId);
        return uri;
    }

    function getTokenIDS(address _add)
        external
        view
        returns (uint256[] memory)
    {

        uint256[] memory ids = IENSTogetherNFT(ensTogetherNFT).ownedNFTS(_add);
        return ids;
    }

    function burn(uint256 tokenId) external {

        IENSTogetherNFT(ensTogetherNFT).burn(tokenId, msg.sender);
        emit Burned(tokenId, true);
    }

    function setNftContractAddress(address ensTogetherNFT_) public onlyOwner {

        ensTogetherNFT = IENSTogetherNFT(ensTogetherNFT_);
    }

    function modifyTimeToRespond(uint256 t) external onlyOwner {

        timeToRespond = t;
    }

    function modifyProposalCost(uint256 amount) external onlyOwner {

        cost = amount;
    }

    function modifyStatusUpdateCost(uint256 amount) external onlyOwner {

        updateStatusCost = amount;
    }

    function withdraw() external onlyOwner nonReentrant {

        uint256 amount = address(this).balance;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Failed to send Ether");
    }
}