
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


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.8.0;
pragma abicoder v2;


contract BatchTransferHelper
{

    function batchTransferERC721(
        address[] calldata to,
        address[] calldata registry,
        uint256[] calldata id)
    external
    {

        require(to.length == registry.length);
        require(to.length == id.length);
        for (uint256 i = 0; i < to.length; ++i)
        {
            IERC721(registry[i]).transferFrom(msg.sender, to[i], id[i]);
        }
    }

    function batchTransferERC1155(
        address[]   calldata to,
        address[]   calldata registry,
        uint256[][] calldata id,
        uint256[][] calldata amount,
        bytes[]     calldata data)
    external
    {

        require(to.length == registry.length);
        require(to.length == id.length);
        require(to.length == amount.length);
        require(to.length == data.length);
        for (uint256 i = 0; i < to.length; ++i)
        {
            IERC1155(registry[i]).safeBatchTransferFrom(msg.sender, to[i], id[i], amount[i], data[i]);
        }
    }

}