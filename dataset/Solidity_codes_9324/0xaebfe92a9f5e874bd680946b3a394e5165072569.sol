
pragma solidity ^0.8.0;


interface IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    
    function ownerOf(uint256 tokenId) external view returns (address);

    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


contract ERC721Helper {

    function tokenInfo(IERC721 token) external view returns(string memory _symbol, string memory _name, uint _totalSupply) {

        return (token.symbol(), token.name(), token.totalSupply());
    }

    function tokenURIs(IERC721 token, uint from, uint to) external view returns(uint[] memory _tokenIds, string[] memory _tokenURIs) {

        require(from < to && to < token.totalSupply());
        _tokenIds = new uint[](to - from);
        _tokenURIs = new string[](to - from);
        uint i = 0;
        for (uint index = from; index < to; index++) {
            uint tokenId = token.tokenByIndex(index);
            _tokenIds[i] = tokenId;    
            _tokenURIs[i] = token.tokenURI(tokenId);
            i++;
        }
    }

    function owners(IERC721 token, uint from, uint to) external view returns(uint[] memory _tokenIds, address[] memory _owners) {

        require(from < to && to < token.totalSupply());
        _tokenIds = new uint[](to - from);
        _owners = new address[](to - from);
        uint i = 0;
        for (uint index = from; index < to; index++) {
            uint tokenId = token.tokenByIndex(index);
            _tokenIds[i] = tokenId;
            _owners[i] = token.ownerOf(tokenId);
            i++;
        }
    }
}