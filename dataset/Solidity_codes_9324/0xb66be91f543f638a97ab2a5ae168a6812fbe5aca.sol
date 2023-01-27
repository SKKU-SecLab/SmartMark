
pragma solidity ^0.5.0;

contract BuilderShop {

   address[] builderInstances;
   uint contractId = 0;

   address niftyRegistryContract = 0x6e53130dDfF21E3BC963Ee902005223b9A202106;

   modifier onlyValidSender() {

       NiftyRegistry nftg_registry = NiftyRegistry(niftyRegistryContract);
       bool is_valid = nftg_registry.isValidNiftySender(msg.sender);
       require(is_valid==true);
       _;
   }

   mapping (address => bool) public BuilderShops;

   function isValidBuilderShop(address builder_shop) public view returns (bool isValid) {

       return(BuilderShops[builder_shop]);
   }

   event BuilderInstanceCreated(address new_contract_address, uint contractId);

   function createNewBuilderInstance(
       string memory _name,
       string memory _symbol,
       uint num_nifties,
       string memory token_base_uri,
       string memory creator_name)
       public onlyValidSender returns (NiftyBuilderInstance tokenAddress) {


       contractId = contractId + 1;

       NiftyBuilderInstance new_contract = new NiftyBuilderInstance(
           _name,
           _symbol,
           contractId,
           num_nifties,
           token_base_uri,
           creator_name
       );

       address externalId = address(new_contract);

       BuilderShops[externalId] = true;

       emit BuilderInstanceCreated(externalId, contractId);

       return (new_contract);
    }
}

contract Context {

   constructor () internal { }

   function _msgSender() internal view returns (address payable) {

       return msg.sender;
   }

   function _msgData() internal view returns (bytes memory) {

       this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
       return msg.data;
   }
}

interface IERC165 {

   function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract ERC165 is IERC165 {

   bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

   mapping(bytes4 => bool) private _supportedInterfaces;

   constructor () internal {
       _registerInterface(_INTERFACE_ID_ERC165);
   }

   function supportsInterface(bytes4 interfaceId) external view returns (bool) {

       return _supportedInterfaces[interfaceId];
   }

   function _registerInterface(bytes4 interfaceId) internal {

       require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
       _supportedInterfaces[interfaceId] = true;
   }
}

contract IERC721 is IERC165 {

   event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
   event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
   event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

   function balanceOf(address owner) public view returns (uint256 balance);


   function ownerOf(uint256 tokenId) public view returns (address owner);


   function safeTransferFrom(address from, address to, uint256 tokenId) public;

   function transferFrom(address from, address to, uint256 tokenId) public;

   function approve(address to, uint256 tokenId) public;

   function getApproved(uint256 tokenId) public view returns (address operator);


   function setApprovalForAll(address operator, bool _approved) public;

   function isApprovedForAll(address owner, address operator) public view returns (bool);



   function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}

contract IERC721Receiver {

   function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
   public returns (bytes4);

}

contract ERC721 is Context, ERC165, IERC721 {

   using SafeMath for uint256;
   using Address for address;
   using Counters for Counters.Counter;

   bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

   mapping (uint256 => address) private _tokenOwner;

   mapping (uint256 => address) private _tokenApprovals;

   mapping (address => Counters.Counter) private _ownedTokensCount;

   mapping (address => mapping (address => bool)) private _operatorApprovals;

   bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

   constructor () public {
       _registerInterface(_INTERFACE_ID_ERC721);
   }

   function balanceOf(address owner) public view returns (uint256) {

       require(owner != address(0), "ERC721: balance query for the zero address");

       return _ownedTokensCount[owner].current();
   }

   function ownerOf(uint256 tokenId) public view returns (address) {

       address owner = _tokenOwner[tokenId];
       require(owner != address(0), "ERC721: owner query for nonexistent token");

       return owner;
   }

   function approve(address to, uint256 tokenId) public {

       address owner = ownerOf(tokenId);
       require(to != owner, "ERC721: approval to current owner");

       require(_msgSender() == owner || isApprovedForAll(owner, _msgSender()),
           "ERC721: approve caller is not owner nor approved for all"
       );

       _tokenApprovals[tokenId] = to;
       emit Approval(owner, to, tokenId);
   }

   function getApproved(uint256 tokenId) public view returns (address) {

       require(_exists(tokenId), "ERC721: approved query for nonexistent token");

       return _tokenApprovals[tokenId];
   }

   function setApprovalForAll(address to, bool approved) public {

       require(to != _msgSender(), "ERC721: approve to caller");

       _operatorApprovals[_msgSender()][to] = approved;
       emit ApprovalForAll(_msgSender(), to, approved);
   }

   function isApprovedForAll(address owner, address operator) public view returns (bool) {

       return _operatorApprovals[owner][operator];
   }

   function transferFrom(address from, address to, uint256 tokenId) public {

       require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");

       _transferFrom(from, to, tokenId);
   }

   function safeTransferFrom(address from, address to, uint256 tokenId) public {

       safeTransferFrom(from, to, tokenId, "");
   }

   function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

       require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
       _safeTransferFrom(from, to, tokenId, _data);
   }

   function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {

       _transferFrom(from, to, tokenId);
       require(_checkOnERC721Received(from, to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
   }

   function _exists(uint256 tokenId) internal view returns (bool) {

       address owner = _tokenOwner[tokenId];
       return owner != address(0);
   }

   function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {

       require(_exists(tokenId), "ERC721: operator query for nonexistent token");
       address owner = ownerOf(tokenId);
       return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
   }

   function _safeMint(address to, uint256 tokenId) internal {

       _safeMint(to, tokenId, "");
   }

   function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

       _mint(to, tokenId);
       require(_checkOnERC721Received(address(0), to, tokenId, _data), "ERC721: transfer to non ERC721Receiver implementer");
   }

   function _mint(address to, uint256 tokenId) internal {

       require(to != address(0), "ERC721: mint to the zero address");
       require(!_exists(tokenId), "ERC721: token already minted");

       _tokenOwner[tokenId] = to;
       _ownedTokensCount[to].increment();

       emit Transfer(address(0), to, tokenId);
   }

   function _burn(address owner, uint256 tokenId) internal {

       require(ownerOf(tokenId) == owner, "ERC721: burn of token that is not own");

       _clearApproval(tokenId);

       _ownedTokensCount[owner].decrement();
       _tokenOwner[tokenId] = address(0);

       emit Transfer(owner, address(0), tokenId);
   }

   function _burn(uint256 tokenId) internal {

       _burn(ownerOf(tokenId), tokenId);
   }

   function _transferFrom(address from, address to, uint256 tokenId) internal {

       require(ownerOf(tokenId) == from, "ERC721: transfer of token that is not own");
       require(to != address(0), "ERC721: transfer to the zero address");

       _clearApproval(tokenId);

       _ownedTokensCount[from].decrement();
       _ownedTokensCount[to].increment();

       _tokenOwner[tokenId] = to;

       emit Transfer(from, to, tokenId);
   }

   function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory _data)
       internal returns (bool)
   {

       if (!to.isContract()) {
           return true;
       }

       bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, _data);
       return (retval == _ERC721_RECEIVED);
   }

   function _clearApproval(uint256 tokenId) private {

       if (_tokenApprovals[tokenId] != address(0)) {
           _tokenApprovals[tokenId] = address(0);
       }
   }
}

contract IERC721Enumerable is IERC721 {

   function totalSupply() public view returns (uint256);

   function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


   function tokenByIndex(uint256 index) public view returns (uint256);

}

contract ERC721Enumerable is Context, ERC165, ERC721, IERC721Enumerable {

   mapping(address => uint256[]) private _ownedTokens;

   mapping(uint256 => uint256) private _ownedTokensIndex;

   uint256[] private _allTokens;

   mapping(uint256 => uint256) private _allTokensIndex;

   bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

   constructor () public {
       _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
   }

   function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

       require(index < balanceOf(owner), "ERC721Enumerable: owner index out of bounds");
       return _ownedTokens[owner][index];
   }

   function totalSupply() public view returns (uint256) {

       return _allTokens.length;
   }

   function tokenByIndex(uint256 index) public view returns (uint256) {

       require(index < totalSupply(), "ERC721Enumerable: global index out of bounds");
       return _allTokens[index];
   }

   function _transferFrom(address from, address to, uint256 tokenId) internal {

       super._transferFrom(from, to, tokenId);

       _removeTokenFromOwnerEnumeration(from, tokenId);

       _addTokenToOwnerEnumeration(to, tokenId);
   }

   function _mint(address to, uint256 tokenId) internal {

       super._mint(to, tokenId);

       _addTokenToOwnerEnumeration(to, tokenId);

       _addTokenToAllTokensEnumeration(tokenId);
   }

   function _burn(address owner, uint256 tokenId) internal {

       super._burn(owner, tokenId);

       _removeTokenFromOwnerEnumeration(owner, tokenId);
       _ownedTokensIndex[tokenId] = 0;

       _removeTokenFromAllTokensEnumeration(tokenId);
   }

   function _tokensOfOwner(address owner) internal view returns (uint256[] storage) {

       return _ownedTokens[owner];
   }

   function _addTokenToOwnerEnumeration(address to, uint256 tokenId) private {

       _ownedTokensIndex[tokenId] = _ownedTokens[to].length;
       _ownedTokens[to].push(tokenId);
   }

   function _addTokenToAllTokensEnumeration(uint256 tokenId) private {

       _allTokensIndex[tokenId] = _allTokens.length;
       _allTokens.push(tokenId);
   }

   function _removeTokenFromOwnerEnumeration(address from, uint256 tokenId) private {


       uint256 lastTokenIndex = _ownedTokens[from].length.sub(1);
       uint256 tokenIndex = _ownedTokensIndex[tokenId];

       if (tokenIndex != lastTokenIndex) {
           uint256 lastTokenId = _ownedTokens[from][lastTokenIndex];

           _ownedTokens[from][tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
           _ownedTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index
       }

       _ownedTokens[from].length--;

   }

   function _removeTokenFromAllTokensEnumeration(uint256 tokenId) private {


       uint256 lastTokenIndex = _allTokens.length.sub(1);
       uint256 tokenIndex = _allTokensIndex[tokenId];

       uint256 lastTokenId = _allTokens[lastTokenIndex];

       _allTokens[tokenIndex] = lastTokenId; // Move the last token to the slot of the to-delete token
       _allTokensIndex[lastTokenId] = tokenIndex; // Update the moved token's index

       _allTokens.length--;
       _allTokensIndex[tokenId] = 0;
   }
}

contract IERC721Metadata is IERC721 {

   function name() external view returns (string memory);

   function symbol() external view returns (string memory);

   function tokenURI(uint256 tokenId) external view returns (string memory);

}

contract ERC721Metadata is Context, ERC165, ERC721, IERC721Metadata {

   string private _name;

   string private _symbol;

   string private _baseURI;

   mapping(uint256 => string) private _tokenURIs;
  
   mapping(uint256 => string) private _tokenIPFSHashes;

   mapping(uint256 => string) private _niftyTypeName;

   mapping(uint256 => string) private _niftyTypeIPFSHashes;

   mapping(uint256 => string) private _tokenName;

   bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

   constructor (string memory name, string memory symbol) public {
       _name = name;
       _symbol = symbol;

       _registerInterface(_INTERFACE_ID_ERC721_METADATA);
   }

   function name() external view returns (string memory) {

       return _name;
   }

   function symbol() external view returns (string memory) {

       return _symbol;
   }

   address public masterBuilderContract = 0x6EFB06cF568253a53C7511BD3c31AB28BecB0192;

   function tokenURI(uint256 tokenId) external view returns (string memory) {

      require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
      BuilderMaster bm = BuilderMaster(masterBuilderContract);
      string memory tokenIdStr = bm.uint2str(tokenId);
      string memory tokenURIStr = bm.strConcat(_baseURI, tokenIdStr);
      return tokenURIStr;
   }
   
   function tokenIPFSHash(uint256 tokenId) external view returns (string memory) {

       require(_exists(tokenId), "ERC721Metadata: IPFS hash query for nonexistent token");
       BuilderMaster bm = BuilderMaster(masterBuilderContract);
       uint nifty_type = bm.getNiftyTypeId(tokenId);
       return _niftyTypeIPFSHashes[nifty_type];
   }

   function tokenName(uint256 tokenId) external view returns (string memory) {

       require(_exists(tokenId), "ERC721Metadata: Name query for nonexistent token");
       BuilderMaster bm = BuilderMaster(masterBuilderContract);
       uint nifty_type = bm.getNiftyTypeId(tokenId);
       return _niftyTypeName[nifty_type];
   }

   function _setTokenURI(uint256 tokenId, string memory uri) internal {

       require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
       _tokenURIs[tokenId] = uri;
   }
   
   function _setTokenIPFSHash(uint256 tokenId, string memory ipfs_hash) internal {

       require(_exists(tokenId), "ERC721Metadata: IPFS hash set of nonexistent token");
       _tokenIPFSHashes[tokenId] = ipfs_hash;
   }
   
   function _setTokenIPFSHashNiftyType(uint256 nifty_type, string memory ipfs_hash) internal {

       _niftyTypeIPFSHashes[nifty_type] = ipfs_hash;
   }

   function _setNiftyTypeName(uint256 nifty_type, string memory nifty_type_name) internal {

       _niftyTypeName[nifty_type] = nifty_type_name;
   }

   function _setBaseURIParent(string memory newBaseURI) internal {

       _baseURI = newBaseURI;
   }

   function _burn(address owner, uint256 tokenId) internal {

       super._burn(owner, tokenId);

       if (bytes(_tokenURIs[tokenId]).length != 0) {
           delete _tokenURIs[tokenId];
       }
   }
}


contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

   constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
   }
}


contract NiftyBuilderInstance is ERC721Full {



   modifier onlyValidSender() {

       NiftyRegistry nftg_registry = NiftyRegistry(niftyRegistryContract);
       bool is_valid = nftg_registry.isValidNiftySender(msg.sender);
       require(is_valid==true);
       _;
   }


   uint public numNiftiesCurrentlyInContract;

   uint public contractId;

   string public baseURI;

   string public nameOfCreator;

   address public niftyRegistryContract = 0x6e53130dDfF21E3BC963Ee902005223b9A202106;

   address public masterBuilderContract = 0x6EFB06cF568253a53C7511BD3c31AB28BecB0192;

   using Counters for Counters.Counter;


   mapping (uint => Counters.Counter) public _numNiftyMinted;
   mapping (uint => uint) public _numNiftyPermitted;
   mapping (uint => uint) public _niftyPrice;
   mapping (uint => bool) public _IPFSHashHasBeenSet;


   event NiftyPurchased(address _buyer, uint256 _amount, uint _tokenId);
   event NiftyCreated(address new_owner, uint _niftyType, uint _tokenId);


   constructor(
       string memory _name,
       string memory _symbol,
       uint contract_id,
       uint num_nifties,
       string memory base_uri,
       string memory name_of_creator) ERC721Full(_name, _symbol) onlyValidSender public {

       contractId = contract_id;
       numNiftiesCurrentlyInContract = num_nifties;
       baseURI = base_uri;
       nameOfCreator = name_of_creator;
   }

   function setNiftyName(uint nifty_type, string memory nifty_name) onlyValidSender public {

       _setNiftyTypeName(nifty_type, nifty_name);
   }
   
   function setBaseURI(string memory new_base_URI) onlyValidSender public {

       _setBaseURIParent(new_base_URI);
   }
   
   function setNiftyIPFSHash(uint nifty_type, string memory ipfs_hash) onlyValidSender public {

       if (_IPFSHashHasBeenSet[nifty_type] == true) { 
           revert("IPFS hash already set for this NFT");
       }
       _setTokenIPFSHashNiftyType(nifty_type, ipfs_hash);
       _IPFSHashHasBeenSet[nifty_type] = true;
   }
    
   function isNiftySoldOut(uint nifty_type) public view returns (bool) {

       if (nifty_type > numNiftiesCurrentlyInContract) {
           return true;
       }
       if (_numNiftyMinted[nifty_type].current() > _numNiftyPermitted[nifty_type]) {
           return (true);
       }
       return (false);
   }

   function giftNifty(address collector_address, 
                      uint nifty_type) onlyValidSender public {

       BuilderMaster bm = BuilderMaster(masterBuilderContract);
       _numNiftyMinted[nifty_type].increment();
       if (isNiftySoldOut(nifty_type)==true) {
           revert("Nifty sold out!");
       }
       uint specificTokenId = _numNiftyMinted[nifty_type].current();
       uint tokenId = bm.encodeTokenId(contractId, nifty_type, specificTokenId);
       _mint(collector_address, tokenId);
       emit NiftyCreated(collector_address, nifty_type, tokenId);
   }

   function massMintNFTs(address collector_address, uint num_to_mint, uint nifty_type) onlyValidSender public {

      for (uint i=0; i < num_to_mint; i++) {
          giftNifty(collector_address, nifty_type);
      } 
   }
}

contract NiftyRegistry {

   function isValidNiftySender(address sending_key) public view returns (bool);

   function isOwner(address owner_key) public view returns (bool);

}

contract BuilderMaster {

   function getContractId(uint tokenId) public view returns (uint);

   function getNiftyTypeId(uint tokenId) public view returns (uint);

   function getSpecificNiftyNum(uint tokenId) public view returns (uint);

   function encodeTokenId(uint contractId, uint niftyType, uint specificNiftyNum) public view returns (uint);

   function strConcat(string memory _a, string memory _b, string memory _c, string memory _d, string memory _e) public view returns (string memory);

   function strConcat(string memory _a, string memory _b, string memory _c, string memory _d) public view returns (string memory);

   function strConcat(string memory _a, string memory _b, string memory _c) public view returns (string memory);

   function strConcat(string memory _a, string memory _b) public view returns (string memory);

   function uint2str(uint _i) public view returns (string memory _uintAsString);

}



library SafeMath {

   function add(uint256 a, uint256 b) internal pure returns (uint256) {

       uint256 c = a + b;
       require(c >= a, "SafeMath: addition overflow");

       return c;
   }

   function sub(uint256 a, uint256 b) internal pure returns (uint256) {

       return sub(a, b, "SafeMath: subtraction overflow");
   }

   function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

       require(b <= a, errorMessage);
       uint256 c = a - b;

       return c;
   }

   function mul(uint256 a, uint256 b) internal pure returns (uint256) {

       if (a == 0) {
           return 0;
       }

       uint256 c = a * b;
       require(c / a == b, "SafeMath: multiplication overflow");

       return c;
   }

   function div(uint256 a, uint256 b) internal pure returns (uint256) {

       return div(a, b, "SafeMath: division by zero");
   }

   function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

       require(b > 0, errorMessage);
       uint256 c = a / b;

       return c;
   }

   function mod(uint256 a, uint256 b) internal pure returns (uint256) {

       return mod(a, b, "SafeMath: modulo by zero");
   }

   function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

       require(b != 0, errorMessage);
       return a % b;
   }
}

library Address {

   function isContract(address account) internal view returns (bool) {


       bytes32 codehash;
       bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
       assembly { codehash := extcodehash(account) }
       return (codehash != 0x0 && codehash != accountHash);
   }

   function toPayable(address account) internal pure returns (address payable) {

       return address(uint160(account));
   }

   function sendValue(address payable recipient, uint256 amount) internal {

       require(address(this).balance >= amount, "Address: insufficient balance");

       (bool success, ) = recipient.call.value(amount)("");
       require(success, "Address: unable to send value, recipient may have reverted");
   }
}

library Counters {

   using SafeMath for uint256;

   struct Counter {
       uint256 _value; // default: 0
   }

   function current(Counter storage counter) internal view returns (uint256) {

       return counter._value;
   }

   function increment(Counter storage counter) internal {

       counter._value += 1;
   }

   function decrement(Counter storage counter) internal {

       counter._value = counter._value.sub(1);
   }
}