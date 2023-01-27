
pragma solidity 0.6.8;

interface IENS {

    function owner(bytes32 _node) external view returns (address);

}

contract PublicationRoles {

    address public immutable ens;


    mapping(bytes32 => bytes32) public roles;


    modifier onlyPublicationOwner(bytes32 publicationNode) {

        require(
            ownsPublication(publicationNode, msg.sender),
            "Sender must be publication owner"
        );
        _;
    }

    event ModifiedRole(
        bytes32 indexed publicationNode,
        address indexed contributor,
        string roleName
    );


    constructor(address ens_) public {
        ens = ens_;
    }


    function modifyRole(
        address contributor,
        bytes32 publicationNode,
        string calldata roleName
    ) external onlyPublicationOwner(publicationNode) {

        bytes32 role = encodeRole(roleName);
        roles[getContributorId(contributor, publicationNode)] = role;

        emit ModifiedRole(publicationNode, contributor, roleName);
    }

    function getContributorId(
        address contributor,
        bytes32 publicationNode
    ) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(contributor, publicationNode));
    }

    function getRole(address contributor, bytes32 publicationNode)
        external
        view
        returns (bytes32)
    {

        return roles[getContributorId(contributor, publicationNode)];
    }

    function encodeRole(string memory roleName) public pure returns (bytes32) {

        return keccak256(abi.encodePacked(roleName));
    }

    function ownsPublication(bytes32 publicationNode, address account)
        public
        view
        returns (bool)
    {

        return publicationOwner(publicationNode) == account;
    }

    function publicationOwner(bytes32 publicationNode)
        public
        view
        returns (address)
    {

        return IENS(ens).owner(publicationNode);
    }
}