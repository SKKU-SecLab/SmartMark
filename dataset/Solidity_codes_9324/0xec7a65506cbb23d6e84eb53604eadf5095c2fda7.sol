pragma solidity 0.8.13;

interface IERC165 {



    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function royaltyFee(uint256 tokenId) external view returns(uint256);

    function getCreator(uint256 tokenId) external view returns(address);



    function ownerOf(uint256 tokenId) external view returns (address owner);



    function lastTokenId()external returns(uint256);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function contractOwner() external view returns(address owner);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function mintAndTransfer(address from, address to, uint256 itemId, uint256 fee, string memory _tokenURI, bytes memory data)external returns(uint256);


}

interface IERC1155 is IERC165 {


    event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _value);
    event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _values);
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);
    event URI(string _value, uint256 indexed _id);
    

    
    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;

    function royaltyFee(uint256 tokenId) external view returns(uint256);

    function getCreator(uint256 tokenId) external view returns(address);

    function lastTokenId()external returns(uint256);

    function mintAndTransfer(address from, address to, uint256 itemId, uint256 fee, uint256 _supply, string memory _tokenURI, uint256 qty, bytes memory data)external returns(uint256);

}

interface IERC20 {



    function totalSupply() external view returns (uint256);



    function balanceOf(address account) external view returns (uint256);



    function transfer(address recipient, uint256 amount) external returns (bool);



    function allowance(address owner, address spender) external view returns (uint256);



    function approve(address spender, uint256 amount) external returns (bool);



    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
} 

contract TransferProxy {


    function erc721safeTransferFrom(IERC721 token, address from, address to, uint256 tokenId) external  {

        token.safeTransferFrom(from, to, tokenId);
    }

    function erc1155safeTransferFrom(IERC1155 token, address from, address to, uint256 id, uint256 value, bytes calldata data) external  {

        token.safeTransferFrom(from, to, id, value, data);
    }
    
    function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external  {

        require(token.transferFrom(from, to, value), "failure while transferring");
    }

    function erc721mintAndTransfer(IERC721 token, address from, address to, uint256 tokenId, uint256 fee, string memory tokenURI, bytes calldata data) external returns(uint256){

        return token.mintAndTransfer(from, to,tokenId, fee, tokenURI, data);
    }

    function erc1155mintAndTransfer(IERC1155 token, address from, address to, uint256 tokenId, uint256 fee , uint256 supply, string memory tokenURI, uint256 qty, bytes calldata data) external returns(uint256) {

        return token.mintAndTransfer(from, to, tokenId, fee, supply, tokenURI, qty, data);
    }  
}

contract Trade {


    enum BuyingAssetType {ERC1155, ERC721 , LazyMintERC1155, LazyMintERC721}

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SellerFee(uint8 sellerFee);
    event BuyerFee(uint8 buyerFee);
    event BuyAsset(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event ExecuteBid(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);

    uint8 private buyerFeePermille;
    uint8 private sellerFeePermille;
    TransferProxy public transferProxy;
    TransferProxy public DeprecatedProxy;
    address public owner;
    mapping(uint256 => bool) private usedNonce;

    struct Fee {
        uint platformFee;
        uint assetFee;
        uint royaltyFee;
        uint price;
        address tokenCreator;
    }



    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
        uint256 nonce;
    }

    struct Order {
        address seller;
        address buyer;
        address erc20Address;
        address nftAddress;
        BuyingAssetType nftType;
        uint unitPrice;
        uint amount;
        uint tokenId;
        uint256 supply;
        string tokenURI;
        uint256 fee;
        uint qty;
        bool isDeprecatedProxy;
    }

    modifier onlyOwner() {

        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    constructor (uint8 _buyerFee, uint8 _sellerFee, TransferProxy _transferProxy, TransferProxy _deprecatedProxy) {
        buyerFeePermille = _buyerFee;
        sellerFeePermille = _sellerFee;
        transferProxy = _transferProxy;
        DeprecatedProxy = _deprecatedProxy;
        owner = msg.sender;
    }

    function buyerServiceFee() external view virtual returns (uint8) {

        return buyerFeePermille;
    }

    function sellerServiceFee() external view virtual returns (uint8) {

        return sellerFeePermille;
    }

    function setBuyerServiceFee(uint8 _buyerFee) external onlyOwner returns(bool) {

        buyerFeePermille = _buyerFee;
        emit BuyerFee(buyerFeePermille);
        return true;
    }

    function setSellerServiceFee(uint8 _sellerFee) external onlyOwner returns(bool) {

        sellerFeePermille = _sellerFee;
        emit SellerFee(sellerFeePermille);
        return true;
    }

    function transferOwnership(address newOwner) external onlyOwner returns(bool){

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        return true;
    }

    function getSigner(bytes32 hash, Sign memory sign) internal pure returns(address) {

        return ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)), sign.v, sign.r, sign.s); 
    }

    function verifySellerSign(address seller, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, Sign memory sign) internal pure {

        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount, sign.nonce));
        require(seller == getSigner(hash, sign), "seller sign verification failed");
    }

    function verifyBuyerSign(address buyer, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, uint qty, Sign memory sign) internal pure {

        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount,qty, sign.nonce));
        require(buyer == getSigner(hash, sign), "buyer sign verification failed");
    }


    function verifyOwnerSign(address buyingAssetAddress,address seller,string memory tokenURI, Sign memory sign) internal view {

        address _owner = IERC721(buyingAssetAddress).contractOwner();
        bytes32 hash = keccak256(abi.encodePacked(this, seller, tokenURI, sign.nonce));
        require(_owner == getSigner(hash, sign), "Owner sign verification failed");
    }


    function getFees( Order memory order, bool _import) internal view returns(Fee memory){

        address tokenCreator;
        uint platformFee;
        uint royaltyFee;
        uint assetFee;
        uint royaltyPermille;
        uint price = order.amount * 1000 / (1000 + buyerFeePermille);
        uint buyerFee = order.amount - price;
        uint sellerFee = price * sellerFeePermille / 1000;
        platformFee = buyerFee + sellerFee;
        if(order.nftType == BuyingAssetType.ERC721 && ! _import) {
            royaltyPermille = ((IERC721(order.nftAddress).royaltyFee(order.tokenId)));
            tokenCreator = ((IERC721(order.nftAddress).getCreator(order.tokenId)));
        }
        if(order.nftType == BuyingAssetType.ERC1155 && ! _import)  {
            royaltyPermille = ((IERC1155(order.nftAddress).royaltyFee(order.tokenId)));
            tokenCreator = ((IERC1155(order.nftAddress).getCreator(order.tokenId)));
        }
        if(order.nftType == BuyingAssetType.LazyMintERC721) {
            royaltyPermille = order.fee;
            tokenCreator = order.seller;
        }
        if(order.nftType == BuyingAssetType.LazyMintERC1155) {
            royaltyPermille = order.fee;
            tokenCreator = order.seller;
        }
        if(_import) {
            royaltyPermille = 0;
            tokenCreator = address(0);
        }
        royaltyFee = price * royaltyPermille / 1000;
        assetFee = price - (royaltyFee + sellerFee);
        return Fee(platformFee, assetFee, royaltyFee, price, tokenCreator);
    }

    function tradeAsset(Order memory order, Fee memory fee) internal virtual {

        TransferProxy previousTransferProxy = transferProxy;
        
        if(order.isDeprecatedProxy){
            transferProxy = DeprecatedProxy;
        }
        if(order.nftType == BuyingAssetType.ERC721) {
            transferProxy.erc721safeTransferFrom(IERC721(order.nftAddress), order.seller, order.buyer, order.tokenId);
        }
        if(order.nftType == BuyingAssetType.ERC1155)  {
            transferProxy.erc1155safeTransferFrom(IERC1155(order.nftAddress), order.seller, order.buyer, order.tokenId, order.qty, ""); 
        }
        if(order.nftType == BuyingAssetType.LazyMintERC721){
            transferProxy.erc721mintAndTransfer(IERC721(order.nftAddress), order.seller, order.buyer, order.tokenId, order.fee,order.tokenURI,"" );
        }
        if(order.nftType == BuyingAssetType.LazyMintERC1155){
            transferProxy.erc1155mintAndTransfer(IERC1155(order.nftAddress), order.seller, order.buyer, order.tokenId, order.fee, order.supply,order.tokenURI,order.qty,"" );
        }
        if(fee.platformFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), order.buyer, owner, fee.platformFee);
        }
        if(fee.royaltyFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), order.buyer, fee.tokenCreator, fee.royaltyFee);
        }
        transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), order.buyer, order.seller, fee.assetFee);

        if(order.isDeprecatedProxy){
            transferProxy = previousTransferProxy;
        }
    }

    function mintAndBuyAsset(Order memory order, Sign memory ownerSign, Sign memory sign, bool isShared) external returns(bool){

        require(!usedNonce[sign.nonce] && !usedNonce[ownerSign.nonce],"Nonce: Invalid Nonce");
        usedNonce[sign.nonce] = true;
        usedNonce[ownerSign.nonce] = true;
        Fee memory fee = getFees(order, false);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        if(isShared) {
            verifyOwnerSign(order.nftAddress, order.seller, order.tokenURI, ownerSign);
        }
        verifySellerSign(order.seller, order.tokenId, order.unitPrice, order.erc20Address, order.nftAddress, sign);
        order.buyer = msg.sender;
        tradeAsset(order, fee);
        emit BuyAsset(order.seller , order.tokenId, order.qty, msg.sender);
        return true;

    }

    function mintAndExecuteBid(Order memory order, Sign memory ownerSign, Sign memory sign, bool isShared) external returns(bool){

        require(!usedNonce[sign.nonce] && !usedNonce[ownerSign.nonce],"Nonce: Invalid Nonce");
        usedNonce[sign.nonce] = true;
        usedNonce[ownerSign.nonce] = true;
        Fee memory fee = getFees(order, false);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        if(isShared) {
            verifyOwnerSign(order.nftAddress,order.seller, order.tokenURI, ownerSign);
        }
        verifyBuyerSign(order.buyer, order.tokenId, order.amount, order.erc20Address, order.nftAddress, order.qty,sign);
        order.seller = msg.sender;
        tradeAsset(order, fee);
        emit ExecuteBid(order.seller , order.tokenId, order.qty, msg.sender);
        return true;

    }

    function buyAsset(Order memory order, bool _import, Sign memory sign) external returns(bool) {

        require(!usedNonce[sign.nonce],"Nonce: Invalid Nonce");
        usedNonce[sign.nonce] = true;
        Fee memory fee = getFees(order, _import);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        verifySellerSign(order.seller, order.tokenId, order.unitPrice, order.erc20Address, order.nftAddress, sign);
        order.buyer = msg.sender;
        tradeAsset(order, fee);
        emit BuyAsset(order.seller , order.tokenId, order.qty, msg.sender);
        return true;
    }

    function executeBid(Order memory order, bool _import, Sign memory sign) external returns(bool) {

        require(!usedNonce[sign.nonce],"Nonce: Invalid Nonce");
        usedNonce[sign.nonce] = true;
        Fee memory fee = getFees(order, _import);
        verifyBuyerSign(order.buyer, order.tokenId, order.amount, order.erc20Address, order.nftAddress, order.qty, sign);
        order.seller = msg.sender;
        tradeAsset(order, fee);
        emit ExecuteBid(msg.sender , order.tokenId, order.qty, order.buyer);
        return true;
    }

}