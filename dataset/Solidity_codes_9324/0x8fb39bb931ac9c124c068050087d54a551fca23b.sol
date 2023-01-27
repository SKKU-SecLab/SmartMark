
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
pragma solidity 0.8.10;

interface IERC721Consumable {

    event ConsumerChanged(
        address indexed owner,
        address indexed consumer,
        uint256 indexed tokenId
    );

    function consumerOf(uint256 _tokenId) external view returns (address);


    function changeConsumer(address _consumer, uint256 _tokenId) external;

}// MIT
pragma solidity 0.8.10;



contract ConsumableAdapterV1 is IERC165, IERC721Consumable {

    address public immutable landworks;
    IERC721 public immutable token;

    mapping(uint256 => address) private consumers;

    constructor(address _landworks, address _token) {
        landworks = _landworks;
        token = IERC721(_token);
    }

    function consumerOf(uint256 tokenId) public view returns (address) {

        return consumers[tokenId];
    }

    function changeConsumer(address consumer, uint256 tokenId) public {

        require(
            msg.sender == landworks,
            "ConsumableAdapter: sender is not LandWorks"
        );
        require(
            msg.sender == token.ownerOf(tokenId),
            "ConsumableAdapter: sender is not owner of tokenId"
        );

        consumers[tokenId] = consumer;
        emit ConsumerChanged(msg.sender, consumer, tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        returns (bool)
    {

        return interfaceId == type(IERC721Consumable).interfaceId;
    }
}// MIT
pragma solidity 0.8.10;

interface IMetaverseAdditionFacet {

    event SetMetaverseName(uint256 indexed _metaverseId, string _name);

    event SetRegistry(
        uint256 indexed _metaverseId,
        address _registry,
        bool _status
    );

    event ConsumableAdapterUpdated(
        address indexed _metaverseRegistry,
        address indexed _adapter
    );

    event AdministrativeConsumerUpdated(
        address indexed _metaverseRegistry,
        address indexed _administrativeConsumer
    );

    function addMetaverseWithAdapters(
        uint256 _metaverseId,
        string calldata _name,
        address[] calldata _metaverseRegistries,
        address[] calldata _administrativeConsumers
    ) external;


    function addMetaverseWithoutAdapters(
        uint256 _metaverseId,
        string calldata _name,
        address[] calldata _metaverseRegistries,
        address[] calldata _administrativeConsumers
    ) external;

}