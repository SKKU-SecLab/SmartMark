
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;

interface IZoraMarket {

    struct ZoraDecimal {
        uint256 value;
    }

    struct ZoraBidShares {
        ZoraDecimal prevOwner;
        ZoraDecimal creator;
        ZoraDecimal owner;
    }

    function bidSharesForToken(uint256 tokenId) external view returns (ZoraBidShares memory);

}

interface IZoraMedia {

    function marketContract() external view returns (address);


    function previousTokenOwners(uint256 tokenId) external view returns (address);


    function tokenCreators(uint256 tokenId) external view returns (address);


    function ownerOf(uint256 tokenId) external view returns (address owner);

}

interface IZoraOverride {

    function convertBidShares(address media, uint256 tokenId) external view returns (address payable[] memory, uint256[] memory);

}// MIT

pragma solidity ^0.8.0;



contract ZoraOverride is IZoraOverride, ERC165 {

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165) returns (bool) {

        return interfaceId == type(IZoraOverride).interfaceId || super.supportsInterface(interfaceId);
    }

    function convertBidShares(address media, uint256 tokenId) public view override returns (address payable[] memory receivers, uint256[] memory bps) {

        IZoraMarket.ZoraBidShares memory bidShares = IZoraMarket(IZoraMedia(media).marketContract()).bidSharesForToken(tokenId);

        uint256 totalLength = 0;


        if (bidShares.creator.value != 0) totalLength++;


        receivers = new address payable[](totalLength);
        bps = new uint256[](totalLength);

        if (bidShares.creator.value != 0) {
            receivers[0] = payable(IZoraMedia(media).tokenCreators(tokenId));
            bps[0] = bidShares.creator.value / (10**(18 - 2));
        }

        return (receivers, bps);
    }
}