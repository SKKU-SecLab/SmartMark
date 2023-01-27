

pragma solidity 0.6.6;




interface IERC20 {

    function symbol() external view returns(string memory);


    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


interface IMoonCats {


	function balanceOf(address) external view returns(uint256);

	function catOwners(bytes5) external view returns(address);

	function acceptAdoptionOffer(bytes5 catId) external payable;

	function makeAdoptionOfferToAddress(bytes5 catId, uint price, address to) external;

	function makeAdoptionRequest(bytes5 catId) external payable;

	function giveCat(bytes5 catId, address to) external;

	function addGenesisCatGroup() external;

	function getCatDetails(bytes5 catId) external view returns (bytes5 id,
                                                         address owner,
                                                         bytes32 name,
                                                         address onlyOfferTo,
                                                         uint offerPrice,
                                                         address requester,
                                                         uint requestPrice);

	event GenesisCatsAdded(bytes5[16] catIds);
	event CatRescued(address indexed to, bytes5 indexed catId);
}


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}



interface Uniswap {

	function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);


	function addLiquidity(
		address tokenA,
		address tokenB,
		uint amountADesired,
		uint amountBDesired,
		uint amountAMin,
		uint amountBMin,
		address to,
		uint deadline
	) external returns (uint amountA, uint amountB, uint liquidity);


	function swapExactTokensForTokens(
		uint amountIn,
		uint amountOutMin,
		address[] calldata path,
		address to,
		uint deadline
	) external returns (uint[] memory amounts);


	function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
  external
  returns (uint[] memory amounts);


  function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
  external
  payable
  returns (uint[] memory amounts);

}


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


interface cat20 is IERC20 {

	function multi721Deposit(uint256[] calldata _ids, address _referral) external;

}


interface ICatWrapper is IERC721 {

	function wrap(bytes5 catId) external;

	function totalSupply() external view returns (uint256);

	function unwrap(uint256 tokenID) external;

}


contract CatSeller {

	ICatWrapper constant wrapper = ICatWrapper(0x7C40c393DC0f283F318791d746d894DdD3693572);
	IMoonCats constant cats = IMoonCats(0x60cd862c9C687A9dE49aecdC3A99b74A4fc54aB6);

	cat20 constant tokenWrapper = cat20(0xf961A1Fa7C781Ecd23689fE1d0B7f3B6cBB2f972);
	Uniswap constant router = Uniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
	address constant weth = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

	constructor() public {
		tokenWrapper.approve(address(router), uint256(-1));
	}


	function nftsToEth(uint256[] calldata _tokenIds, uint256 _min, bytes calldata _data) external {

		address wrap = address(tokenWrapper);
		for (uint256 i = 0; i < _tokenIds.length; i++)
			wrapper.safeTransferFrom(msg.sender, wrap, _tokenIds[i], _data);
		_swapAll(_min);
	}

	function nftToEth(uint256 _tokenId, uint256 _min, bytes memory _data) public {

		wrapper.safeTransferFrom(msg.sender, address(tokenWrapper), _tokenId, _data);
		_swapAll(_min);
	}

	function _swapAll(uint256 _min) internal {

		address[] memory path = new address[](2);
		path[0] = address(tokenWrapper);
		path[1] = weth;

		router.swapExactTokensForETH(tokenWrapper.balanceOf(address(this)), _min, path, msg.sender, block.timestamp + 1);
	}
}