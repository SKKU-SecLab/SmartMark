
pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity >=0.6.2 <0.8.0;


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

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}pragma solidity ^0.6.0;


contract ExchangeFromEthereum is IERC1155Receiver, ReentrancyGuard {

    address payable private backend;
    uint256 private gasUnlock;

    constructor(address payable _back) public {
        require(_back != address(0), "Wrong address");
        backend = _back;
        gasUnlock = 44800;
    }

    modifier onlyBackend {

        require(msg.sender == backend, "Only backend can call this function.");
        _;
    }

    struct NftTokenInfo {
        address tokenAddress;
        uint256 id;
        bool locked;
    }

    mapping(address => NftTokenInfo[]) public deposits;

    event DepositNFT(address owner, address nftAddress, uint256 nftId);
    event WithdrawNFT(address nftAddress, uint256 nftId, address to);
    event Log(uint256 fee);

    function depositNft(address nftAddress, uint256 nftId) external payable nonReentrant{

        uint256 gasPrice = tx.gasprice;
        uint256 fee = gasUnlock * gasPrice;
        require(nftAddress != address(0), "Wrong NFT contract address");
        require(msg.value >= fee);
        NftTokenInfo memory token = NftTokenInfo(nftAddress, nftId, true);
        IERC1155(nftAddress).safeTransferFrom(
            msg.sender,
            address(this),
            nftId,
            1,
            ""
        );
        backend.transfer(msg.value);
        deposits[msg.sender].push(token);
        emit DepositNFT(msg.sender, nftAddress, nftId);
        emit Log(fee);
    }

    function withdrawNft(address nftAddress, uint256 nftId, address to) external nonReentrant {

        require(nftAddress != address(0));
        uint256 index = deposits[msg.sender].length;
        for(uint256 i=0; i<deposits[msg.sender].length; i++){
            if(deposits[msg.sender][i].tokenAddress == nftAddress && deposits[msg.sender][i].id == nftId){
                index = i;
            }
        }
        require(index != deposits[msg.sender].length, "Wrong initial values");
        require(!deposits[msg.sender][index].locked, "Unable to withdraw. Deposit all BEP20 tokens on the contract in Binance Smaert Chain");
        IERC1155(nftAddress).safeTransferFrom(
            address(this),
            to,
            nftId,
            1,
            ""
        );
        deposits[msg.sender][index].locked = true;
        emit WithdrawNFT(nftAddress, nftId, msg.sender);
    }

    function unlock (address owner, address nftAddress, uint256 nftId) external onlyBackend {
        require(nftAddress != address(0));
        uint256 index = deposits[owner].length;
        for(uint256 i=0; i<deposits[owner].length; i++){
            if(deposits[owner][i].tokenAddress == nftAddress && deposits[owner][i].id == nftId){
                index = i;
            }
        }
        require(index != deposits[owner].length, "Wrong initial values");
        deposits[owner][index].locked = false;
    }

    function changeBackAddress(address payable _back) external onlyBackend {

        require(_back != address(0));
        backend = _back;
    }

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes calldata
    )
    external 
    override 
    returns (bytes4) {

        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] calldata,
        uint256[] calldata,
        bytes calldata
    )
    external 
    override 
    returns (bytes4) {

        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4) external view override returns (bool){

        return false;
    }

    receive() external payable { }
}