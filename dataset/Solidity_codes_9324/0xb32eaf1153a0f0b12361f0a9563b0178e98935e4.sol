

pragma solidity 0.8.3;




interface IOpenSea {

    function atomicMatch_(
        address[14] memory addrs,
        uint[18] memory uints,
        uint8[8] memory feeMethodsSidesKindsHowToCalls,
        bytes memory calldataBuy,
        bytes memory calldataSell,
        bytes memory replacementPatternBuy,
        bytes memory replacementPatternSell,
        bytes memory staticExtradataBuy,
        bytes memory staticExtradataSell,
        uint8[2] memory vs,
        bytes32[5] memory rssMetadata
    ) external payable;

}


library OpenSeaMarket {


    address public constant OPENSEA = 0x7Be8076f4EA4A4AD08075C2508e481d6C946D12b;

    struct OpenSeaBuy {
        address[14] addrs;
        uint[18] uints;
        uint8[8] feeMethodsSidesKindsHowToCalls;
        bytes calldataBuy;
        bytes calldataSell;
        bytes replacementPatternBuy;
        bytes replacementPatternSell;
        bytes staticExtradataBuy;
        bytes staticExtradataSell;
        uint8[2] vs;
        bytes32[5] rssMetadata;
    }

    function buyAssetsForEth(bytes memory data) public {

        OpenSeaBuy[] memory openSeaBuys;
        (openSeaBuys) = abi.decode(
            data,
            (OpenSeaBuy[])
        );

        for (uint256 i = 0; i < openSeaBuys.length; i++) {
            _buyAssetForEth(openSeaBuys[i]);
        }
    }

    function estimateBatchAssetPriceInEth(bytes memory data) public view returns(uint256 totalCost) {

        OpenSeaBuy[] memory openSeaBuys;
        (openSeaBuys) = abi.decode(
            data,
            (OpenSeaBuy[])
        );

        for (uint256 i = 0; i < openSeaBuys.length; i++) {
            totalCost += openSeaBuys[i].uints[4];
        }
    }

    function _buyAssetForEth(OpenSeaBuy memory _openSeaBuy) internal {

        bytes memory _data = abi.encodeWithSelector(IOpenSea(OPENSEA).atomicMatch_.selector, _openSeaBuy.addrs, _openSeaBuy.uints, _openSeaBuy.feeMethodsSidesKindsHowToCalls, _openSeaBuy.calldataBuy, _openSeaBuy.calldataSell, _openSeaBuy.replacementPatternBuy, _openSeaBuy.replacementPatternSell, _openSeaBuy.staticExtradataBuy, _openSeaBuy.staticExtradataSell, _openSeaBuy.vs, _openSeaBuy.rssMetadata);

        (bool success, ) = OPENSEA.call{value:_openSeaBuy.uints[4]}(_data);
        require(success, "_buyAssetForEth: opensea buy failed.");
    }
}