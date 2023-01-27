
pragma solidity 0.8.4;

interface IERC20 {

    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);

}// BUSL-1.1

pragma solidity 0.8.4;

interface IERC721 {

    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) external;

    
    function setApprovalForAll(address operator, bool approved) external;


    function approve(address to, uint256 tokenId) external;

    
    function isApprovedForAll(address owner, address operator) external view returns (bool);

}// BUSL-1.1

pragma solidity 0.8.4;
interface IERC1155 {

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) external;

}// BUSL-1.1

pragma solidity 0.8.4;


interface IExchangeV2Core {

    struct AssetType {
        bytes4 assetClass;
        bytes data;
    }
    
    struct Asset {
        AssetType assetType;
        uint value;
    }

    struct Order {
        address maker;
        Asset makeAsset;
        address taker;
        Asset takeAsset;
        uint salt;
        uint start;
        uint end;
        bytes4 dataType;
        bytes data;
    }
    
    function matchOrders(
        Order memory orderLeft,
        bytes memory signatureLeft,
        Order memory orderRight,
        bytes memory signatureRight
    ) external payable;

}

library RaribleV2Market {

    address public constant RARIBLE = 0x9757F2d2b135150BBeb65308D4a91804107cd8D6;

    struct RaribleBuy {
        IExchangeV2Core.Order orderLeft;
        bytes signatureLeft;
        IExchangeV2Core.Order orderRight;
        bytes signatureRight;
        uint256 price;
    }

    function buyAssetsForEth(RaribleBuy[] memory raribleBuys, address recipient, bool revertIfTrxFails) external {

        for (uint256 i = 0; i < raribleBuys.length; i++) {
            _buyAssetForEth(raribleBuys[i], recipient, revertIfTrxFails);
        }
    }

    function _buyAssetForEth(RaribleBuy memory raribleBuy, address recipient, bool revertIfTrxFails) internal {

        bytes memory _data = abi.encodeWithSelector(
            IExchangeV2Core(RARIBLE).matchOrders.selector, 
            raribleBuy.orderLeft,
            raribleBuy.signatureLeft,
            raribleBuy.orderRight,
            raribleBuy.signatureRight
        );
        (bool success, ) = RARIBLE.call{value:raribleBuy.price}(_data);
        if (!success && revertIfTrxFails) {
            assembly {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
        if (success) {
            if (raribleBuy.orderLeft.takeAsset.assetType.assetClass == bytes4(keccak256("ETH"))) {
                (bool _success, ) = recipient.call{value: raribleBuy.orderLeft.takeAsset.value}('');
                require(_success, "_buyAssetForEth: Rarible market eth transfer failed");
            }
            else if (raribleBuy.orderLeft.takeAsset.assetType.assetClass == bytes4(keccak256("ERC20"))) {
                (address addr) = abi.decode(raribleBuy.orderLeft.takeAsset.assetType.data, (address));
                IERC20(addr).transfer(recipient, raribleBuy.orderLeft.takeAsset.value);
            }
            else if (raribleBuy.orderLeft.takeAsset.assetType.assetClass == bytes4(keccak256("ERC721"))) {
                (address addr, uint256 tokenId) = abi.decode(raribleBuy.orderLeft.takeAsset.assetType.data, (address, uint256));
                IERC721(addr).transferFrom(address(this), recipient, tokenId);
            }
            else if (raribleBuy.orderLeft.takeAsset.assetType.assetClass == bytes4(keccak256("ERC1155"))) {
                (address addr, uint256 tokenId) = abi.decode(raribleBuy.orderLeft.takeAsset.assetType.data, (address, uint256));
                IERC1155(addr).safeTransferFrom(address(this), recipient, tokenId, raribleBuy.orderLeft.takeAsset.value, "");
            }
        }
    }
}