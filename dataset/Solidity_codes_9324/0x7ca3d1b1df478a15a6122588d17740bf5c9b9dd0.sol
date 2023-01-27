
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

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
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
pragma solidity >=0.8.10 <=0.9.0;

contract ToyBoogersAirdrop is Context, ReentrancyGuard {

    IERC1155 public token;

    event AirdropDeployed();
    event AirdropFinished(uint256 tokenId, address[] recipients);

    constructor(IERC1155 _token) {
        require(address(_token) != address(0), "Invalid NFT");
        token = _token;
        emit AirdropDeployed();
    }

    function airdrop(uint256 _tokenId, address[] memory _recipients)
        external
        nonReentrant
    {

        require(token.balanceOf(_msgSender(), _tokenId) >= _recipients.length,"Not enough tokens to drop");
        require(token.isApprovedForAll(_msgSender(), address(this)),"Owner is not approved");
        require(_recipients.length >= 0,"Recipients must be greater than 0");
        require(_recipients.length <= 1000,"Recipients should be smaller than 1000");
        for (uint256 i = 0; i < _recipients.length; i++) {
            token.safeTransferFrom(
                _msgSender(),
                _recipients[i],
                _tokenId,
                1,
                ""
            );
        }
        emit AirdropFinished(_tokenId, _recipients);
    }
}