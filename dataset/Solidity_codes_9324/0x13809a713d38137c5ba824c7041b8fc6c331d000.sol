
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


interface INFTX {

    function mint(
        uint256 vaultId, 
        uint256[] memory nftIds, 
        uint256 d2Amount
    ) external payable;


}

interface IWrappedPunk {

    function mint(uint256 punkIndex) external;

    
    function registerProxy() external;


    function proxyInfo(address user) external view returns (address);

}

interface ICryptoPunks {

    function transferPunk(address to, uint punkIndex) external;

}

interface IMoonCatsWrapped {

    function wrap(bytes5 catId) external;

    function _catIDToTokenID(bytes5 catId) external view returns(uint256);

}

interface IMoonCatsRescue {

    function makeAdoptionOfferToAddress(bytes5 catId, uint price, address to) external;


    function rescueOrder(uint256 rescueIndex) external view returns(bytes5);

}

interface IMoonCatAcclimator {

    function batchUnwrap(uint256[] memory _rescueOrders) external;

}

library NftxV1Market {

    address public constant NFTX = 0xAf93fCce0548D3124A5fC3045adAf1ddE4e8Bf7e;

    function _approve(
        address _operator, 
        address _token, 
        uint256[] memory _tokenIds
    ) internal {

        if (_token == 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d) {
            for (uint256 i = 0; i < _tokenIds.length; i++) {
                IERC721(_token).approve(_operator, _tokenIds[i]);
            }
        }
        else if (!IERC721(_token).isApprovedForAll(address(this), _operator)) {
            IERC721(_token).setApprovalForAll(_operator, true);
        }
    }

    function sellERC721ForERC20Equivalent(
        uint256 vaultId,
        uint256[] memory tokenIds,
        address token
    ) external {

        _approve(NFTX, token, tokenIds);
        INFTX(NFTX).mint(vaultId, tokenIds, 0);
    }
}