


pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.7.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}


pragma solidity 0.7.5;

interface GFarmNftInterface{

    function idToLeverage(uint id) external view returns(uint8);

    function transferFrom(address from, address to, uint256 tokenId) external;

}

interface GFarmBridgeableNftInterface{

    function ownerOf(uint256 tokenId) external view returns (address);

	function mint(address to, uint tokenId) external;

	function burn(uint tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;


}

contract GFarmNftSwap{


	GFarmNftInterface public nft;
	GFarmBridgeableNftInterface[5] public bridgeableNfts;
	address public gov;

	event NftToBridgeableNft(uint nftType, uint tokenId);
	event BridgeableNftToNft(uint nftType, uint tokenId);

	constructor(GFarmNftInterface _nft){
		nft = _nft;
		gov = msg.sender;
	}

	function setBridgeableNfts(GFarmBridgeableNftInterface[5] calldata _bridgeableNfts) external{

		require(msg.sender == gov, "ONLY_GOV");
		require(bridgeableNfts[0] == GFarmBridgeableNftInterface(0), "BRIDGEABLE_NFTS_ALREADY_SET");
		bridgeableNfts = _bridgeableNfts;
	}

	function leverageToType(uint leverage) pure private returns(uint){

		if(leverage == 150){ return 5; }
		
		return leverage / 25;
	}

	modifier correctNftType(uint nftType){

		require(nftType > 0 && nftType < 6, "NFT_TYPE_BETWEEN_1_AND_5");
		_;
	}

	function getBridgeableNft(uint nftType, uint tokenId) public correctNftType(nftType){

		require(leverageToType(nft.idToLeverage(tokenId)) == nftType, "WRONG_TYPE");

		nft.transferFrom(msg.sender, address(this), tokenId);

		bridgeableNfts[nftType-1].mint(msg.sender, tokenId);

		emit NftToBridgeableNft(nftType, tokenId);
	}

	function getBridgeableNfts(uint nftType, uint[] calldata ids) external correctNftType(nftType){

		require(ids.length <= 10, "MAX_10");

		for(uint i = 0; i < ids.length; i++){
			getBridgeableNft(nftType, ids[i]);
		}
	}

	function getNft(uint nftType, uint tokenId) public correctNftType(nftType){

		require(bridgeableNfts[nftType-1].ownerOf(tokenId) == msg.sender, "NOT_OWNER");

		bridgeableNfts[nftType-1].burn(tokenId);

		nft.transferFrom(address(this), msg.sender, tokenId);

		emit BridgeableNftToNft(nftType, tokenId);
	}

	function getNfts(uint nftType, uint[] calldata ids) external correctNftType(nftType){

		require(ids.length <= 10, "MAX_10");

		for(uint i = 0; i < ids.length; i++){
			getNft(nftType, ids[i]);
		}
	}

}