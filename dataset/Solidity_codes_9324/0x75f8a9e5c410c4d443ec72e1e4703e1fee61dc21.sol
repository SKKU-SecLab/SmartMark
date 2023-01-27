


pragma solidity 0.8.11;
pragma abicoder v2;

interface IERC20Upgradeable {

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


}

contract INFT {


    function getTokenSaleInfo(uint256 tokenId) external view returns(bool isOnSale, bool exists, SaleInfo memory data, address owner) {}

    function mintAndDistribute(uint256[] memory tokenIds, address[] memory addresses) external {
    
    }
    struct SaleInfo { 
        uint64 onSaleUntil; 
        address currency;
        uint256 price;
    }
    struct CommissionData {
        uint64 value;
        address recipient;
    }

    struct SeriesInfo { 
        address payable author;
        uint32 limit;
        SaleInfo saleInfo;
        CommissionData commission;
        string baseURI;
        string suffix;
    }

    mapping (uint256 => INFT.SeriesInfo) public seriesInfo;  // seriesId => SeriesInfo
    
}

interface Ownable {

    function owner() external view returns (address);

}

contract NFTBulkSaleV1{

   
    function distribute(
        address nftAddress,
        uint256[] memory tokenIds, 
        address[] memory addresses
    ) 
        public 
        payable
    {



        require(tokenIds.length != 0 && tokenIds.length == addresses.length);
        
        uint256 tokenId = tokenIds[0];
        uint256 seriesId = uint256(tokenId >> 192);//getSeriesId(tokenId);

        address payable author;
        uint32 limit;
        INFT.SaleInfo memory saleInfo;
        INFT.CommissionData memory commission;
        string memory baseURI;
        string memory suffix;

        (author, limit, saleInfo, commission, baseURI, suffix)
        = INFT(nftAddress).seriesInfo(seriesId);
        
        require (author != address(0));

        bool transferSuccess;
        
        uint256 totalPrice = (saleInfo.price)*(tokenIds.length);
        if (saleInfo.currency == address(0)) {
            
            (transferSuccess, ) = (author).call{gas: 3000, value: (totalPrice)}(new bytes(0));
            require(transferSuccess, "TRANSFER_COMMISSION_FAILED");
        } else {
            IERC20Upgradeable(saleInfo.currency).transferFrom(msg.sender, author, totalPrice);
        }

        address owner = Ownable(nftAddress).owner();

        bytes memory returndata;

        (transferSuccess, returndata) = nftAddress.call(
                abi.encodePacked(
                    abi.encodeWithSelector(
                        INFT.mintAndDistribute.selector,
                        tokenIds, addresses
                    ),
                    owner
                )
            );
        _verifyCallResult(transferSuccess, returndata, "low level error");
        
    }
    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

}