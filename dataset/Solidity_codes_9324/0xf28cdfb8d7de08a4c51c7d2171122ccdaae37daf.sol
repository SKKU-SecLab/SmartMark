

pragma solidity 0.8.3;




interface IERC721 {

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external;

    
    function setApprovalForAll(address operator, bool approved) external;


    function approve(address to, uint256 tokenId) external;

    
    function isApprovedForAll(address owner, address operator) external returns (bool);

}


interface IERC721Sale {

    struct Sig {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }

    function buy(address token, uint256 tokenId, uint256 price, uint256 sellerFee, Sig memory signature) external payable;


    function buyerFee() external view returns(uint256);

}


library UniqueOneMarket {

    address public constant ERC721SALE = 0x06dB0695AD7A72b025a83a500C7E728d4a35297e;

    struct UniqueOneBuy {
        address token; 
        uint256 tokenId; 
        uint256 price; 
        uint256 sellerFee; 
        IERC721Sale.Sig signature;
    }

    function buyAssetsForEth(bytes memory data, address recipient) public {

        UniqueOneBuy[] memory uniqueOneBuys;

        (uniqueOneBuys) = abi.decode(
            data,
            (UniqueOneBuy[])
        );

        for (uint256 i = 0; i < uniqueOneBuys.length; i++) {
            _buyAssetForEth(
                uniqueOneBuys[i].tokenId, 
                uniqueOneBuys[i].price, 
                uniqueOneBuys[i].sellerFee, 
                uniqueOneBuys[i].signature, 
                uniqueOneBuys[i].token, 
                recipient);
        }
    }

    function estimateBatchAssetPriceInEth(bytes memory data) public view returns(uint256 totalCost) {

        uint256[] memory prices;

        (prices) = abi.decode(
            data,
            (uint256[])
        );

        for (uint256 i = 0; i < prices.length; i++) {
            totalCost += prices[i] = prices[i] + prices[i]*IERC721Sale(ERC721SALE).buyerFee()/10000;
        }
    }
 
    function _buyAssetForEth(uint256 _tokenId, uint256 _price, uint256 _sellerFee, IERC721Sale.Sig memory _signature, address _token, address _recipient) internal {

        bytes memory _data = abi.encodeWithSelector(IERC721Sale(ERC721SALE).buy.selector, _token, _tokenId, _price, _sellerFee, _signature);
        _price = _price + _price*IERC721Sale(ERC721SALE).buyerFee()/10000;
 
        (bool success, ) = ERC721SALE.call{value:_price}(_data);
        require(success, "_buyAssetForEth: uniqueone buy failed.");

        IERC721(_token).transferFrom(address(this), _recipient, _tokenId);               
    }
}