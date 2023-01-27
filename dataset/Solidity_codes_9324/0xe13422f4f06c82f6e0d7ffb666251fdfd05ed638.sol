
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}// MIT

pragma solidity ^0.8.0;


interface IMarketplaceTokenReceiver {

    function decrementERC1155(address owner, address tokenAddress, uint256 tokenId, uint256 value) external;


    function transferERC1155(address tokenAddress, uint256 tokenId, uint256 value, address to) external;


    function withdrawERC1155(address tokenAddress, uint256 tokenId, uint256 value) external;


    function onERC1155Received(address, address from, uint256 id, uint256 value, bytes calldata) external returns(bytes4);

}// MIT

pragma solidity ^0.8.0;




contract MarketplaceTokenReceiver is IMarketplaceTokenReceiver {

    
    address private _marketplace;
    
    mapping (address => mapping(uint256 => mapping(address => uint256))) private _erc1155balances;

    constructor(address marketplace) {
        _marketplace = marketplace;
    }

    function decrementERC1155(address owner, address tokenAddress, uint256 tokenId, uint256 value) external virtual override {

        require(msg.sender == _marketplace, "Invalid caller");
        require(_erc1155balances[tokenAddress][tokenId][owner] >= value, "Invalid token amount");
        _erc1155balances[tokenAddress][tokenId][owner] -= value;
    }

    function transferERC1155(address tokenAddress, uint256 tokenId, uint256 value, address to) external virtual override {

        require(msg.sender == _marketplace, "Invalid caller");
        IERC1155(tokenAddress).safeTransferFrom(address(this), to, tokenId, value, "");
    }

    function withdrawERC1155(address tokenAddress, uint256 tokenId, uint256 value) external virtual override {

        require(_erc1155balances[tokenAddress][tokenId][msg.sender] >= value, "Invalid token amount");
        _erc1155balances[tokenAddress][tokenId][msg.sender] -= value;
        IERC1155(tokenAddress).safeTransferFrom(address(this), msg.sender, tokenId, value, "");
    }

    function onERC1155Received(address, address from, uint256 id, uint256 value, bytes calldata) external virtual override returns(bytes4) {

        _erc1155balances[msg.sender][id][from] += value;
        return this.onERC1155Received.selector;
    }
}