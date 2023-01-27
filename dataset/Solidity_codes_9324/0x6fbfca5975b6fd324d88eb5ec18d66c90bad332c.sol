
contract Ownable
{


    mapping (address => bool) public isAuth;
    address tokenLinkAddress;

  string public constant NOT_CURRENT_OWNER = "018001";
  string public constant CANNOT_TRANSFER_TO_ZERO_ADDRESS = "018002";

  address public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  constructor()
  {
    owner = msg.sender;
    isAuth[owner] = true;
  }

  modifier onlyOwner()
  {

    require(msg.sender == owner, NOT_CURRENT_OWNER);
    _;
  }

  modifier onlyAuthorized()
  {

    require(isAuth[msg.sender] || msg.sender == owner, "Unauth");
    _;
  }
  function transferOwnership(
    address _newOwner
  )
    public
    onlyOwner
  {

    require(_newOwner != address(0), CANNOT_TRANSFER_TO_ZERO_ADDRESS);
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }

}



pragma solidity 0.8.6;

interface ERC721Metadata
{


  function name()
    external
    view
    returns (string memory _name);


  function symbol()
    external
    view
    returns (string memory _symbol);


  function tokenURI(uint256 _tokenId)
    external
    view
    returns (string memory);


}



pragma solidity 0.8.6;

library AddressUtils
{


  function isContract(
    address _addr
  )
    internal
    view
    returns (bool addressCheck)
  {


    bytes32 codehash;
    bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
    assembly { codehash := extcodehash(_addr) } // solhint-disable-line
    addressCheck = (codehash != 0x0 && codehash != accountHash);
  }

}



pragma solidity 0.8.6;

interface ERC165
{


  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    view
    returns (bool);


}



pragma solidity 0.8.6;


contract SupportsInterface is
  ERC165
{


  mapping(bytes4 => bool) internal supportedInterfaces;

  constructor()
  {
    supportedInterfaces[0x01ffc9a7] = true; // ERC165
  }

  function supportsInterface(
    bytes4 _interfaceID
  )
    external
    override
    view
    returns (bool)
  {

    return supportedInterfaces[_interfaceID];
  }

}



pragma solidity 0.8.6;

interface ERC721TokenReceiver
{


  function onERC721Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    returns(bytes4);


}



pragma solidity 0.8.6;

interface ERC721
{


  event Transfer(
    address indexed _from,
    address indexed _to,
    uint256 indexed _tokenId
  );

  event Approval(
    address indexed _owner,
    address indexed _approved,
    uint256 indexed _tokenId
  );

  event ApprovalForAll(
    address indexed _owner,
    address indexed _operator,
    bool _approved
  );

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external;


  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;


  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external;


  function approve(
    address _approved,
    uint256 _tokenId
  )
    external;


  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external;


  function balanceOf(
    address _owner
  )
    external
    view
    returns (uint256);


  function ownerOf(
    uint256 _tokenId
  )
    external
    view
    returns (address);


  function getApproved(
    uint256 _tokenId
  )
    external
    view
    returns (address);


  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    view
    returns (bool);


}



pragma solidity 0.8.6;





contract NFToken is
  ERC721,
  SupportsInterface
{

  using AddressUtils for address;

  string constant ZERO_ADDRESS = "003001";
  string constant NOT_VALID_NFT = "003002";
  string constant NOT_OWNER_OR_OPERATOR = "003003";
  string constant NOT_OWNER_APPROVED_OR_OPERATOR = "003004";
  string constant NOT_ABLE_TO_RECEIVE_NFT = "003005";
  string constant NFT_ALREADY_EXISTS = "003006";
  string constant NOT_OWNER = "003007";
  string constant IS_OWNER = "003008";

  bytes4 internal constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  mapping (uint256 => address) internal idToOwner;

  mapping (uint256 => address) internal idToApproval;

  mapping (address => uint256) private ownerToNFTokenCount;

  mapping (address => mapping (address => bool)) internal ownerToOperators;

  modifier canOperate(
    uint256 _tokenId
  )
  {

    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_OR_OPERATOR
    );
    _;
  }

  modifier canTransfer(
    uint256 _tokenId
  )
  {

    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender
      || idToApproval[_tokenId] == msg.sender
      || ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_APPROVED_OR_OPERATOR
    );
    _;
  }

  modifier validNFToken(
    uint256 _tokenId
  )
  {

    require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
    _;
  }

  constructor()
  {
    supportedInterfaces[0x80ac58cd] = true; // ERC721
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    override
  {

    _safeTransferFrom(_from, _to, _tokenId, _data);
  }

  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
  {

    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {

    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);

    _transfer(_to, _tokenId);
  }

  function approve(
    address _approved,
    uint256 _tokenId
  )
    external
    override
    canOperate(_tokenId)
    validNFToken(_tokenId)
  {

    address tokenOwner = idToOwner[_tokenId];
    require(_approved != tokenOwner, IS_OWNER);

    idToApproval[_tokenId] = _approved;
    emit Approval(tokenOwner, _approved, _tokenId);
  }

  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external
    override
  {

    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  function balanceOf(
    address _owner
  )
    external
    override
    view
    returns (uint256)
  {

    require(_owner != address(0), ZERO_ADDRESS);
    return _getOwnerNFTCount(_owner);
  }

  function ownerOf(
    uint256 _tokenId
  )
    external
    override
    view
    returns (address _owner)
  {

    _owner = idToOwner[_tokenId];
    require(_owner != address(0), NOT_VALID_NFT);
  }

  function getApproved(
    uint256 _tokenId
  )
    external
    override
    view
    validNFToken(_tokenId)
    returns (address)
  {

    return idToApproval[_tokenId];
  }

  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    override
    view
    returns (bool)
  {

    return ownerToOperators[_owner][_operator];
  }

  function _transfer(
    address _to,
    uint256 _tokenId
  )
    internal
  {

    address from = idToOwner[_tokenId];
    _clearApproval(_tokenId);

    _removeNFToken(from, _tokenId);
    _addNFToken(_to, _tokenId);

    emit Transfer(from, _to, _tokenId);
  }

  function _mint(
    address _to,
    uint256 _tokenId
  )
    internal
    virtual
  {

    require(_to != address(0), ZERO_ADDRESS);
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);

    _addNFToken(_to, _tokenId);

    emit Transfer(address(0), _to, _tokenId);
  }

  function _burn(
    uint256 _tokenId
  )
    internal
    virtual
    validNFToken(_tokenId)
  {

    address tokenOwner = idToOwner[_tokenId];
    _clearApproval(_tokenId);
    _removeNFToken(tokenOwner, _tokenId);
    emit Transfer(tokenOwner, address(0), _tokenId);
  }

  function _removeNFToken(
    address _from,
    uint256 _tokenId
  )
    internal
    virtual
  {

    require(idToOwner[_tokenId] == _from, NOT_OWNER);
    ownerToNFTokenCount[_from] -= 1;
    delete idToOwner[_tokenId];
  }

  function _addNFToken(
    address _to,
    uint256 _tokenId
  )
    internal
    virtual
  {

    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);

    idToOwner[_tokenId] = _to;
    ownerToNFTokenCount[_to] += 1;
  }

  function _getOwnerNFTCount(
    address _owner
  )
    internal
    virtual
    view
    returns (uint256)
  {

    return ownerToNFTokenCount[_owner];
  }

  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    private
    canTransfer(_tokenId)
    validNFToken(_tokenId)
  {

    address tokenOwner = idToOwner[_tokenId];
    require(tokenOwner == _from, NOT_OWNER);
    require(_to != address(0), ZERO_ADDRESS);

    _transfer(_to, _tokenId);

    if (_to.isContract())
    {
      bytes4 retval = ERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
      require(retval == MAGIC_ON_ERC721_RECEIVED, NOT_ABLE_TO_RECEIVE_NFT);
    }
  }

  function _clearApproval(
    uint256 _tokenId
  )
    private
  {

    delete idToApproval[_tokenId];
  }

}



pragma solidity 0.8.6;



contract NFTokenMetadata is
  NFToken,
  ERC721Metadata
{


  string internal nftName;

  string internal nftSymbol;

  mapping (uint256 => string) internal idToUri;

  constructor()
  {
    supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
  }

  function name()
    external
    override
    view
    returns (string memory _name)
  {

    _name = nftName;
  }

  function symbol()
    external
    override
    view
    returns (string memory _symbol)
  {

    _symbol = nftSymbol;
  }

  function tokenURI(
    uint256 _tokenId
  )
    external
    override
    view
    validNFToken(_tokenId)
    returns (string memory)
  {

    return idToUri[_tokenId];
  }

  function _burn(
    uint256 _tokenId
  )
    internal
    override
    virtual
  {

    super._burn(_tokenId);

    delete idToUri[_tokenId];
  }

  function _setTokenUri(
    uint256 _tokenId,
    string memory _uri
  )
    internal
    validNFToken(_tokenId)
  {

    idToUri[_tokenId] = _uri;
  }

}



pragma solidity ^0.8.6;



contract Wildcard is NFTokenMetadata, Ownable {


  mapping  (uint256 => bool) public IdList;
  uint256 _lastTokenId = 0;

  address payout = 0x0000000000000000000000000000000000000000;

  bool openMinting = false;
  bool whitelistMode = false;

  mapping (address => bool) public whitelistedAddress;
  mapping (uint256 => uint256) public tieredIDs;
  mapping (address => bool) public whitelistHasBought;
  mapping (address => bool) public isAuthorized;

  uint256 public _bronzeCount = 0;
  uint256 public _silverCount = 0;
  uint256 public _goldCount = 0;
  uint256 public _platinumCount = 0;
  uint256 public _extraPlatinumCount = 0;


  uint256 public _bronzePrice = 190000000000000000;
  uint256 public _silverPrice = 290000000000000000;
  uint256 public _goldPrice = 420000000000000000;
  uint256 public _platinumPrice = 560000000000000000;

  uint256 public _bronzeLimit = 1600;
  uint256 public _silverLimit = 1400;
  uint256 public _goldLimit = 1200;
  uint256 public _platinumLimit = 1000;
  uint256 public _extraPlatinumLimit = 60;


  string bronzeUri = "https://wildcard.mypinata.cloud/ipfs/QmUBZUwA2Csiu2tp5a55dvYgWQrRMU4vSkih6XAtBCbJMD";
  string silverUri = "https://wildcard.mypinata.cloud/ipfs/QmRQmDphd65cHWRPTCKUWLWC8CnYJhnW4tXXs1NwSDDM8k";
  string goldUri = "https://wildcard.mypinata.cloud/ipfs/QmWWVPYWTjtREtqBVrURx8WsbtxTUhpK4DbyULKGRE5MvA";
  string platinumUri = "https://wildcard.mypinata.cloud/ipfs/QmStohEk1rVKVMgteYxCPzufFdHVWv6xoLa7o534kr9tCQ";


  constructor() {
    nftName = "WILDCARD P2E";
    nftSymbol = "WILDCARD";

  }

  function setWhitelistMode (bool _whitelistMode) public onlyOwner {
	whitelistMode = _whitelistMode;
  }

  function setPayoutAddress (address addy) public onlyOwner {
	payout = addy;
  }

  function setPriceBronzeWei(uint256 price) public onlyOwner {

      _bronzePrice = price;
  }

  function setPriceSilverWei(uint256 price) public onlyOwner {

      _silverPrice = price;
  }

  function setPriceGoldWei(uint256 price) public onlyOwner {

      _goldPrice = price;
  }

  function setPricePlatinumWei(uint256 price) public onlyOwner {

      _platinumPrice = price;
  }
  
  function setAuthorized(address addy, bool isit) public onlyOwner {

      isAuthorized[addy] = isit;
  }

  function setMaxExtra(uint256 limit) public onlyOwner {

	  _extraPlatinumLimit = limit;
  }

  function whitelisteAddy(address addy, bool status) public onlyOwner {

      whitelistedAddress[addy] = status;
  }

  function isWhitelisted(address addy) public view onlyOwner returns(bool)  {

      return whitelistedAddress[addy];
  }

  function getAuthorized(address addy) public view onlyOwner returns(bool)  {

      return isAuthorized[addy];   
  }


  function isMintingOpen(bool status) public onlyOwner {

      openMinting = status;
  }

  function withdrawAll() public payable onlyOwner {

        uint256 balance = address(this).balance;
        require(balance > 0);
        _withdraw(payout, address(this).balance);
    }

  function _withdraw(address _address, uint256 _amount) private {

      (bool success, ) = _address.call{value: _amount}("");
      require(success, "Transfer failed.");
  }



  function whichTier(uint256 id) private returns (string memory)  {

		uint256 tier = tieredIDs[id];
		if (tier==1) {
			return "Bronze";
		} else if (tier==2) {
			return "Silver";
		} else if (tier==3) {
			return "Gold";
		} else if (tier==4) {
			return "Platinum";
		} else {
			return "No tier";
		}
  }


  function mintNFT(address _to, uint256 tier, bool extra, bool premint) payable public {


	if(openMinting) {
		require(!premint, "Premint cant be done in public mint");
		require(!extra, "Extra minting cant be done in public mint");
	}

	if(!premint && !extra) {
	    require(openMinting, "Minting is closed");
	}
    
    if(premint || extra) {
        require(isAuthorized[msg.sender] || msg.sender == owner);
    }
    
	if(whitelistMode) {
		require(whitelistedAddress[msg.sender], "Sorry, you are not in the whitelist");
		require(!whitelistHasBought[msg.sender], "You already bought");
		whitelistHasBought[msg.sender] = true;
	}


	uint256 actualPrice = _bronzePrice;
	string memory _uri = bronzeUri;

    if(tier==1) {
		require(_bronzeCount < _bronzeLimit);
		 actualPrice = _bronzePrice;
		_bronzeCount += 1;
		 _uri = bronzeUri;
	} else if (tier==2) {
		require(_silverCount < _silverLimit);
		 actualPrice = _silverPrice;
		_silverCount += 1;
		 _uri = silverUri;
	} else if (tier==3) {
		require(_goldCount < _goldLimit);
		 actualPrice = _goldPrice;
		_goldCount += 1;
		 _uri = goldUri;
	} else if (tier==4) {
		if (!extra) {
			require(_platinumCount < _platinumLimit);
			_platinumCount += 1;

		} else {
			require(_extraPlatinumCount < _extraPlatinumLimit);
			_extraPlatinumCount += 1;
		}
		 actualPrice = _platinumPrice;
		 _uri = platinumUri;
	} else {
		require(true==false); // Throw an error to save gas
	}

    require(msg.value == actualPrice);


    uint256 _tokenId = _lastTokenId + 1;
	tieredIDs[_tokenId] = tier;
    super._mint(_to, _tokenId);
    super._setTokenUri(_tokenId, _uri);
    _lastTokenId = _tokenId;
  }

}