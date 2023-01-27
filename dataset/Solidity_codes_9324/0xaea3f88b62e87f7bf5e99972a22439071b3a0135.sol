

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity >=0.6.2 <0.8.0;

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

pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity 0.7.4;

interface IERC1155 {



  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;


  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;


  function balanceOf(address _owner, uint256 _id) external view returns (uint256);


  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

}

pragma solidity 0.7.4;

contract PortionExchangeV2 {

	struct ERC1155Offer {
		uint tokenId;
		uint quantity;
		uint price;
		address seller;
	}

	event TokenPriceListed (uint indexed _tokenId, address indexed _owner, uint _price);
	event TokenPriceDeleted (uint indexed _tokenId);
	event TokenSold (uint indexed _tokenId, uint _price, bool _soldForPRT);
	event TokenOwned (uint indexed _tokenId, address indexed _previousOwner, address indexed _newOwner);
	event Token1155OfferListed (uint indexed _tokenId, uint indexed _offerId, address indexed _owner, uint _quantity, uint _price);
	event Token1155OfferDeleted (uint indexed _tokenId, uint indexed _offerId);
	event Token1155Sold(uint indexed _tokenId, uint indexed _offerId, uint _quantity, uint _price, bool _soldForPRT);
	event Token1155Owned (uint indexed _tokenId, address indexed _previousOwner, address indexed _newOwner, uint _quantity);

	address public signerAddress;
	address owner;

	bytes32 public name = "PortionExchangeV2";

	uint public offerIdCounter;
	uint public safeVolatilityPeriod;

	IERC20 public portionTokenContract;
	IERC721 public artTokenContract;
	IERC1155 public artToken1155Contract;

	mapping(address => uint) public nonces;
	mapping(uint => uint) public ERC721Prices;
	mapping(uint => ERC1155Offer) public ERC1155Offers;
	mapping(address => mapping(uint => uint)) public tokensListed;

	constructor (
		address _signerAddress,
		address _artTokenAddress,
		address _artToken1155Address,
		address _portionTokenAddress
	)
	{
		require (_signerAddress != address(0));
		require (_artTokenAddress != address(0));
		require (_artToken1155Address != address(0));
		require (_portionTokenAddress != address(0));

		owner = msg.sender;
		signerAddress = _signerAddress;
		artTokenContract = IERC721(_artTokenAddress);
		artToken1155Contract = IERC1155(_artToken1155Address);
		portionTokenContract = IERC20(_portionTokenAddress);

		safeVolatilityPeriod = 4 hours;
	}

	function listToken(
		uint _tokenId,
		uint _price
	)
	external
	{

		require(_price > 0);
		require(artTokenContract.ownerOf(_tokenId) == msg.sender);
		require(ERC721Prices[_tokenId] == 0);
		ERC721Prices[_tokenId] = _price;
		emit TokenPriceListed(_tokenId, msg.sender, _price);
	}

	function listToken1155(
		uint _tokenId,
		uint _quantity,
		uint _price
	)
	external
	{

		require(_price > 0);
		require(artToken1155Contract.balanceOf(msg.sender, _tokenId) >= tokensListed[msg.sender][_tokenId] + _quantity);

		uint offerId = offerIdCounter++;
		ERC1155Offers[offerId] = ERC1155Offer({
			tokenId: _tokenId,
			quantity: _quantity,
			price: _price,
			seller: msg.sender
		});

		tokensListed[msg.sender][_tokenId] += _quantity;
		emit Token1155OfferListed(_tokenId, offerId, msg.sender, _quantity, _price);
	}

	function removeListToken(
		uint _tokenId
	)
	external
	{

		require(artTokenContract.ownerOf(_tokenId) == msg.sender);
		deleteTokenPrice(_tokenId);
	}

	function removeListToken1155(
		uint _offerId
	)
	external
	{

		require(ERC1155Offers[_offerId].seller == msg.sender);
		deleteToken1155Offer(_offerId);
	}

	function deleteTokenPrice(
		uint _tokenId
	)
	internal
	{

		delete ERC721Prices[_tokenId];
		emit TokenPriceDeleted(_tokenId);
	}

	function deleteToken1155Offer(
		uint _offerId
	)
	internal
	{

		ERC1155Offer memory offer = ERC1155Offers[_offerId];
		tokensListed[offer.seller][offer.tokenId] -= offer.quantity;

		delete ERC1155Offers[_offerId];
		emit Token1155OfferDeleted(offer.tokenId, _offerId);
	}

	function buyToken(
		uint _tokenId
	)
	external
	payable
	{

		require(ERC721Prices[_tokenId] > 0, "token is not for sale");
		require(ERC721Prices[_tokenId] <= msg.value);

		address tokenOwner = artTokenContract.ownerOf(_tokenId);

		address payable payableTokenOwner = payable(tokenOwner);
		(bool sent, ) = payableTokenOwner.call{value: msg.value}("");
		require(sent);

		artTokenContract.safeTransferFrom(tokenOwner, msg.sender, _tokenId);

		emit TokenSold(_tokenId, msg.value, false);
		emit TokenOwned(_tokenId, tokenOwner, msg.sender);

		deleteTokenPrice(_tokenId);
	}

	function buyToken1155(
		uint _offerId,
		uint _quantity
	)
	external
	payable
	{

		ERC1155Offer memory offer = ERC1155Offers[_offerId];

		require(offer.price > 0, "offer does not exist");
		require(offer.quantity >= _quantity);
		require(offer.price * _quantity <= msg.value);

		address payable payableSeller = payable(offer.seller);
		(bool sent, ) = payableSeller.call{value: msg.value}("");
		require(sent);

		artToken1155Contract.safeTransferFrom(offer.seller, msg.sender, offer.tokenId, _quantity, "");

		emit Token1155Sold(offer.tokenId, _offerId, _quantity, offer.price, false);
		emit Token1155Owned(offer.tokenId, offer.seller, msg.sender, _quantity);

		if (offer.quantity == _quantity) {
			deleteToken1155Offer(_offerId);
		} else {
			ERC1155Offers[_offerId].quantity -= _quantity;
		}
	}

	function buyTokenForPRT(
		uint _tokenId,
		uint _priceInPRT,
		uint _nonce,
		bytes calldata _signature,
		uint _timestamp
	)
	external
	{

		bytes32 hash = keccak256(abi.encodePacked(_tokenId, _priceInPRT, _nonce, _timestamp));
		bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
		require(recoverSignerAddress(ethSignedMessageHash, _signature) == signerAddress, "invalid secret signer");

		require(nonces[msg.sender] < _nonce, "invalid nonce");
		if (safeVolatilityPeriod > 0) {
			require(_timestamp + safeVolatilityPeriod >= block.timestamp, "safe volatility period exceeded");
		}
		require(ERC721Prices[_tokenId] > 0, "token is not for sale");

		nonces[msg.sender] = _nonce;

		address tokenOwner = artTokenContract.ownerOf(_tokenId);

		bool sent = portionTokenContract.transferFrom(msg.sender, tokenOwner, _priceInPRT);
		require(sent);

		artTokenContract.safeTransferFrom(tokenOwner, msg.sender, _tokenId);

		emit TokenSold(_tokenId, _priceInPRT, true);
		emit TokenOwned(_tokenId, tokenOwner, msg.sender);

		deleteTokenPrice(_tokenId);
	}

	function buyToken1155ForPRT(
		uint _offerId,
		uint _quantity,
		uint _priceInPRT,
		uint _nonce,
		bytes calldata _signature,
		uint _timestamp
	)
	external
	{

		bytes32 hash = keccak256(abi.encodePacked(_offerId, _quantity, _priceInPRT, _nonce, _timestamp));
		bytes32 ethSignedMessageHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
		require(recoverSignerAddress(ethSignedMessageHash, _signature) == signerAddress, "invalid secret signer");

		ERC1155Offer memory offer = ERC1155Offers[_offerId];

		require(nonces[msg.sender] < _nonce, "invalid nonce");
		if (safeVolatilityPeriod > 0) {
			require(_timestamp + safeVolatilityPeriod >= block.timestamp, "safe volatility period exceeded");
		}
		require(offer.price > 0, "offer does not exist");
		require(offer.quantity >= _quantity);

		nonces[msg.sender] = _nonce;

		portionTokenContract.transferFrom(msg.sender, offer.seller, _priceInPRT * _quantity);
		artToken1155Contract.safeTransferFrom(offer.seller, msg.sender, offer.tokenId, _quantity, "");

		emit Token1155Sold(offer.tokenId, _offerId, _quantity, _priceInPRT, true);
		emit Token1155Owned(offer.tokenId, offer.seller, msg.sender, _quantity);

		if (offer.quantity == _quantity) {
			deleteToken1155Offer(_offerId);
		} else {
			ERC1155Offers[_offerId].quantity -= _quantity;
		}
	}

	function setSigner(
		address _newSignerAddress
	)
	external
	{

		require(msg.sender == owner);
		signerAddress = _newSignerAddress;
	}

	function setSafeVolatilityPeriod(
		uint _newSafeVolatilityPeriod
	)
	external
	{

		require(msg.sender == owner);
		safeVolatilityPeriod = _newSafeVolatilityPeriod;
	}

	function recoverSignerAddress(
		bytes32 _hash,
		bytes memory _signature
	)
	internal
	pure
	returns (address)
	{

		require(_signature.length == 65, "invalid signature length");

		bytes32 r;
		bytes32 s;
		uint8 v;

		assembly {
			r := mload(add(_signature, 32))
			s := mload(add(_signature, 64))
			v := and(mload(add(_signature, 65)), 255)
		}

		if (v < 27) {
			v += 27;
		}

		if (v != 27 && v != 28) {
			return address(0);
		}

		return ecrecover(_hash, v, r, s);
	}
}