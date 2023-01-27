
pragma solidity ^0.8.4;

interface IERC165 {



    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


interface IERC721 is IERC165 {

    function royaltyFee(uint256 tokenId) external view returns(address[] memory, uint256[] memory);

    function getCreator(uint256 tokenId) external view returns(address);


    function contractOwner() external view returns(address owner);



    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function createCollectible(address from, string memory tokenURI, address[] memory royalty, uint256[] memory _royaltyFee) external returns(uint256);

    function mintAndTransfer(address from, address to, address[] memory _royaltyAddress, uint256[] memory _royaltyfee, string memory _tokenURI, bytes memory data)external returns(uint256);

}

interface IERC1155 is IERC165 {


    function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes calldata _data) external;


    function royaltyFee(uint256 tokenId) external view returns(address[] memory, uint256[] memory);

    function getCreator(uint256 tokenId) external view returns(address);

    function mint(address from, string memory uri, uint256 supply, address[] memory royaltyAddress, uint256[] memory _royaltyFee) external;

    function mintAndTransfer(address from, address to, address[] memory _royaltyAddress, uint256[] memory _royaltyfee, uint256 _supply, string memory _tokenURI, uint256 qty, bytes memory data)external returns(uint256);

}


interface IERC20 {



    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

}



   

contract TransferProxy {


    function erc721mint(IERC721 token, address from, string memory tokenURI, address[] memory royalty, uint256[] memory royaltyFee) external {

        token.createCollectible(from, tokenURI, royalty, royaltyFee);
    }

    function erc1155mint(IERC1155 token, address from, string memory tokenURI, address[] memory royalty, uint256[] memory royaltyFee, uint256 supply) external {

        token.mint(from, tokenURI, supply, royalty, royaltyFee);
    }

    function erc721safeTransferFrom(IERC721 token, address from, address to, uint256 tokenId) external  {

        token.safeTransferFrom(from, to, tokenId);
    }

    function erc1155safeTransferFrom(IERC1155 token, address from, address to, uint256 id, uint256 value, bytes calldata data) external  {

        token.safeTransferFrom(from, to, id, value, data);
    }
    
    function erc20safeTransferFrom(IERC20 token, address from, address to, uint256 value) external  {

        require(token.transferFrom(from, to, value), "failure while transferring");
    }   

    function erc721mintAndTransfer(IERC721 token, address from, address to, address[] memory _royaltyAddress, uint256[] memory _royaltyfee, string memory tokenURI, bytes calldata data) external {

        token.mintAndTransfer(from, to, _royaltyAddress, _royaltyfee, tokenURI, data);
    }

    function erc1155mintAndTransfer(IERC1155 token, address from, address to, address[] memory _royaltyAddress, uint256[] memory _royaltyfee, uint256 supply, string memory tokenURI, uint256 qty, bytes calldata data) external {

        token.mintAndTransfer(from, to, _royaltyAddress, _royaltyfee, supply, tokenURI, qty, data);
    }
}

contract Trade {


    enum BuyingAssetType {ERC1155, ERC721 , LazyMintERC1155, LazyMintERC721}

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event SellerFee(uint8 sellerFee);
    event BuyerFee(uint8 buyerFee);
    event BuyAsset(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event ExecuteBid(address indexed assetOwner , uint256 indexed tokenId, uint256 quantity, address indexed buyer);
    event MintersAdded(address indexed minters);
    event MintersRemoved(address indexed minters);

    uint8 private buyerFeePermille;
    uint8 private sellerFeePermille;
    TransferProxy public transferProxy;
    address public owner;
    mapping (address => bool) internal minters;

    struct Fee {
        uint platformFee;
        uint assetFee;
        address[] royaltyAddress;
        uint[] royaltyFee;
        uint price;
    }

    struct Sign {
        uint8 v;
        bytes32 r;
        bytes32 s;
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
        address[] royaltyAddress;
        uint256[] royaltyfee;
        uint qty;
    }

    modifier onlyOwner() {

        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyMinter() {

        require(minters[msg.sender], "Minter : caller is not the minter");
        _;
    }

    constructor (uint8 _buyerFee, uint8 _sellerFee, TransferProxy _transferProxy) {
        buyerFeePermille = _buyerFee;
        sellerFeePermille = _sellerFee;
        transferProxy = _transferProxy;
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

        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount));
        require(seller == getSigner(hash, sign), "seller sign verification failed");
    }

    function verifyBuyerSign(address buyer, uint256 tokenId, uint amount, address paymentAssetAddress, address assetAddress, uint qty, Sign memory sign) internal pure {

        bytes32 hash = keccak256(abi.encodePacked(assetAddress, tokenId, paymentAssetAddress, amount,qty));
        require(buyer == getSigner(hash, sign), "buyer sign verification failed");
    }

    function getFees(Order memory order) internal view returns(Fee memory){

        uint platformFee;
        uint fee;
        address[] memory royaltyAddress;
        uint[] memory royaltyPermille;
        uint assetFee;
        uint price = order.amount * 1000 / (1000 + buyerFeePermille);
        uint buyerFee = order.amount - price;
        uint sellerFee = price * sellerFeePermille / 1000;
        platformFee = buyerFee + sellerFee;
        if(order.nftType == BuyingAssetType.ERC721) {
            (royaltyAddress, royaltyPermille) = ((IERC721(order.nftAddress).royaltyFee(order.tokenId)));
        }
        if(order.nftType == BuyingAssetType.ERC1155)  {
            (royaltyAddress, royaltyPermille) = ((IERC1155(order.nftAddress).royaltyFee(order.tokenId)));
        }
        if(order.nftType == BuyingAssetType.LazyMintERC721) {
            royaltyAddress = order.royaltyAddress;
            royaltyPermille = order.royaltyfee;
        }
        if(order.nftType == BuyingAssetType.LazyMintERC1155) {
            royaltyAddress = order.royaltyAddress;
            royaltyPermille = order.royaltyfee;
        }

        uint[] memory royaltyFee =  new uint[](royaltyAddress.length);

        for(uint i = 0; i < royaltyAddress.length; i++) {
            fee += price * royaltyPermille[i] / 1000;
            royaltyFee[i] = price * royaltyPermille[i] / 1000;
        }

        assetFee = price - fee - sellerFee;
        return Fee(platformFee, assetFee, royaltyAddress, royaltyFee, price);
    }


    function tradeAsset(Order calldata order, Fee memory fee, address buyer, address seller) internal virtual {

        if(order.nftType == BuyingAssetType.ERC721) {
            transferProxy.erc721safeTransferFrom(IERC721(order.nftAddress), seller, buyer, order.tokenId);
        }
        if(order.nftType == BuyingAssetType.ERC1155)  {
            transferProxy.erc1155safeTransferFrom(IERC1155(order.nftAddress), seller, buyer, order.tokenId, order.qty, ""); 
        }
        if(order.nftType == BuyingAssetType.LazyMintERC721){
            transferProxy.erc721mintAndTransfer(IERC721(order.nftAddress), order.seller, order.buyer, order.royaltyAddress, order.royaltyfee, order.tokenURI,"" );
        }
        if(order.nftType == BuyingAssetType.LazyMintERC1155){
            transferProxy.erc1155mintAndTransfer(IERC1155(order.nftAddress), order.seller, order.buyer, order.royaltyAddress, order.royaltyfee, order.supply, order.tokenURI, order.qty, "");
        }
        if(fee.platformFee > 0) {
            transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, owner, fee.platformFee);
        }
        for(uint i = 0; i < fee.royaltyAddress.length; i++) {
            if(fee.royaltyFee[i] > 0) {
                transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, fee.royaltyAddress[i], fee.royaltyFee[i]);
            }
        }
        transferProxy.erc20safeTransferFrom(IERC20(order.erc20Address), buyer, seller, fee.assetFee);
    }

    function mint(address nftAddress, BuyingAssetType nftType, string memory tokenURI, uint256 supply, address[] memory recipient, uint256[] memory royaltyFee ) external onlyMinter returns(bool) {

        if(nftType == BuyingAssetType.ERC721) {
            transferProxy.erc721mint(IERC721(nftAddress), msg.sender, tokenURI, recipient, royaltyFee);
        }
        else if(nftType == BuyingAssetType.ERC1155) {
            transferProxy.erc1155mint(IERC1155(nftAddress), msg.sender, tokenURI, recipient, royaltyFee, supply);
        }
        return true;
    }

    function addMinters(address account) external onlyOwner returns(bool) {

        require(account != address(0), "Minters: Given address is zero address");
        require(!minters[account],"account already added in minters");
        minters[account] = true;
        emit MintersAdded(account); 
        return true;
    }

    function removeMinters(address account) external onlyOwner returns(bool) {

        require(account != address(0), "Minters: Given address is zero address");
        require(minters[account],"account already remived in minters");
        minters[account] = false;
        emit MintersRemoved(account); 
        return true;
    }

    function minter(address account) external view returns(bool) {

        return minters[account];
    }

    function mintAndBuyAsset(Order calldata order, Sign calldata sign) external returns(bool){

        require(minters[order.seller], "Minters: seller is not minter");
        Fee memory fee = getFees(order);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        verifySellerSign(order.seller, order.tokenId, order.unitPrice, order.erc20Address, order.nftAddress, sign);
        address buyer = msg.sender;
        tradeAsset(order, fee, buyer, order.seller);
        emit BuyAsset(order.seller , order.tokenId, order.qty, msg.sender);
        return true;
    }

    function mintAndExecuteBid(Order calldata order, Sign calldata sign) external returns(bool){

        require(minters[msg.sender], "Minters: User is not minter");
        Fee memory fee = getFees(order);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        verifyBuyerSign(order.buyer, order.tokenId, order.amount, order.erc20Address, order.nftAddress, order.qty,sign);
        address seller = msg.sender;
        tradeAsset(order, fee, order.buyer, seller);
        emit ExecuteBid(order.seller , order.tokenId, order.qty, msg.sender);
        return true;

    }

    function buyAsset(Order calldata order, Sign calldata sign) external returns(Fee memory) {

        Fee memory fee = getFees(order);
        require((fee.price >= order.unitPrice * order.qty), "Paid invalid amount");
        verifySellerSign(order.seller, order.tokenId, order.unitPrice, order.erc20Address, order.nftAddress, sign);
        address buyer = msg.sender;
        tradeAsset(order, fee, buyer, order.seller);
        emit BuyAsset(order.seller, order.tokenId, order.qty, msg.sender);
        return fee;
    }

    function executeBid(Order calldata order, Sign calldata sign) external returns(bool) {

        Fee memory fee = getFees(order);
        verifyBuyerSign(order.buyer, order.tokenId, order.amount, order.erc20Address, order.nftAddress, order.qty, sign);
        address seller = msg.sender;
        tradeAsset(order, fee, order.buyer, seller);
        emit ExecuteBid(msg.sender , order.tokenId, order.qty, order.buyer);
        return true;
    }
}