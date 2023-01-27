
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
pragma solidity ^0.8.0;


contract BatchTransfer {

  function transferTokens(
    address tokenAddress,
    address to,
    uint256[] calldata tokenIds
  ) external {

    IERC721 tokenContract = IERC721(tokenAddress);

    uint256 numTokens = tokenIds.length;
    for (uint256 i; i < numTokens; ++i) {
      address owner = tokenContract.ownerOf(tokenIds[i]);
      tokenContract.transferFrom(owner, to, tokenIds[i]);
    }
  }

  function safeTransferTokens(
    address tokenAddress,
    address to,
    uint256[] calldata tokenIds
  ) external {

    IERC721 tokenContract = IERC721(tokenAddress);

    uint256 numTokens = tokenIds.length;
    for (uint256 i; i < numTokens; ++i) {
      address owner = tokenContract.ownerOf(tokenIds[i]);
      tokenContract.safeTransferFrom(owner, to, tokenIds[i]);
    }
  }

  function safeTransferTokens(
    address tokenAddress,
    address to,
    uint256[] calldata tokenIds,
    bytes calldata data
  ) external {

    IERC721 tokenContract = IERC721(tokenAddress);

    uint256 numTokens = tokenIds.length;
    for (uint256 i; i < numTokens; ++i) {
      address owner = tokenContract.ownerOf(tokenIds[i]);
      tokenContract.safeTransferFrom(owner, to, tokenIds[i], data);
    }
  }
}