

pragma solidity >=0.4.24 <0.7.0;


contract Initializable {


  bool private initialized;

  bool private initializing;

  modifier initializer() {

    require(initializing || isConstructor() || !initialized, "Contract instance has already been initialized");

    bool isTopLevelCall = !initializing;
    if (isTopLevelCall) {
      initializing = true;
      initialized = true;
    }

    _;

    if (isTopLevelCall) {
      initializing = false;
    }
  }

  function isConstructor() private view returns (bool) {

    address self = address(this);
    uint256 cs;
    assembly { cs := extcodesize(self) }
    return cs == 0;
  }

  uint256[50] private ______gap;
}


pragma solidity ^0.5.0;


contract Context is Initializable {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}


pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.0;



contract IERC721 is Initializable, IERC165 {

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


pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.0;

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


pragma solidity ^0.5.5;

library Address {

    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(account) }
        return (codehash != accountHash && codehash != 0x0);
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


pragma solidity ^0.5.0;


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


pragma solidity ^0.5.0;



contract ERC165 is Initializable, IERC165 {

    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    function initialize() public initializer {

        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view returns (bool) {

        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal {

        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;









contract ERC721 is Initializable, Context, ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;

    mapping (uint256 => address) private _tokenOwner;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    function initialize() public initializer {

        ERC165.initialize();

        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function _hasBeenInitialized() internal view returns (bool) {

        return supportsInterface(_INTERFACE_ID_ERC721);
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
        (bool success, bytes memory returndata) = to.call(abi.encodeWithSelector(
            IERC721Receiver(to).onERC721Received.selector,
            _msgSender(),
            from,
            tokenId,
            _data
        ));
        if (!success) {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert("ERC721: transfer to non ERC721Receiver implementer");
            }
        } else {
            bytes4 retval = abi.decode(returndata, (bytes4));
            return (retval == _ERC721_RECEIVED);
        }
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;



contract IERC721Enumerable is Initializable, IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}


pragma solidity ^0.5.0;






contract ERC721Enumerable is Initializable, Context, ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    function initialize() public initializer {

        require(ERC721._hasBeenInitialized());
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function _hasBeenInitialized() internal view returns (bool) {

        return supportsInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
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






    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;



contract IERC721Metadata is Initializable, IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}


pragma solidity ^0.5.0;






contract ERC721Metadata is Initializable, Context, ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    function initialize(string memory name, string memory symbol) public initializer {

        require(ERC721._hasBeenInitialized());

        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function _hasBeenInitialized() internal view returns (bool) {

        return supportsInterface(_INTERFACE_ID_ERC721_METADATA);
    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

     


    uint256[50] private ______gap;
}


pragma solidity ^0.5.12;




interface AsyncArtwork_v1 {

    function getControlToken(uint256 controlTokenId) external view returns (int256[] memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}


contract AsyncArtwork_v2 is Initializable, ERC721, ERC721Enumerable, ERC721Metadata {

    event PlatformAddressUpdated(
        address platformAddress
    );

    event PermissionUpdated(
        uint256 tokenId,
        address tokenOwner,
        address permissioned
    );

    event CreatorWhitelisted(
        uint256 tokenId,
        uint256 layerCount,
        address creator
    );

    event PlatformSalePercentageUpdated (
        uint256 tokenId,
        uint256 platformFirstPercentage,
        uint256 platformSecondPercentage        
    );

    event ArtistSecondSalePercentUpdated (
        uint256 artistSecondPercentage
    );

    event BidProposed(
        uint256 tokenId,
        uint256 bidAmount,
        address bidder
    );

    event BidWithdrawn(
        uint256 tokenId
    );

    event BuyPriceSet(
        uint256 tokenId,
        uint256 price
    );

    event TokenSale(
        uint256 tokenId,
        uint256 salePrice,
        address buyer
    );

    event ControlLeverUpdated(
        uint256 tokenId,
        uint256 priorityTip,
        int256 numRemainingUpdates,
        uint256[] leverIds,        
        int256[] previousValues,
        int256[] updatedValues
    );

    struct ControlToken {
        uint256 numControlLevers;
        int256 numRemainingUpdates;
        bool exists;
        bool isSetup;
        mapping(uint256 => ControlLever) levers;
    }

    struct ControlLever {
        int256 minValue;
        int256 maxValue;
        int256 currentValue;
        bool exists;
    }

    struct PendingBid {
        address payable bidder;
        uint256 amount;
        bool exists;
    }

    struct WhitelistReservation {
        address creator;
        uint256 layerCount;
    }

    mapping(uint256 => bool) public tokenDidHaveFirstSale;
    mapping(uint256 => bool) public tokenURILocked;    
    mapping(uint256 => uint256) public buyPrices;    
    mapping(address => uint256) public failedTransferCredits;
    mapping(uint256 => uint256) public platformFirstSalePercentages;
    mapping(uint256 => uint256) public platformSecondSalePercentages;
    mapping(uint256 => WhitelistReservation) public creatorWhitelist;
    mapping(uint256 => address payable[]) public uniqueTokenCreators;    
    mapping(uint256 => PendingBid) public pendingBids;
    mapping(uint256 => ControlToken) public controlTokenMapping;    
    mapping(address => mapping(uint256 => address)) public permissionedControllers;
    uint256 public artistSecondSalePercentage;
    uint256 public expectedTokenSupply;
    uint256 public minBidIncreasePercent;
    address payable public platformAddress;
    address public upgraderAddress;
    address public minterAddress;

    function initialize(string memory name, string memory symbol, uint256 initialExpectedTokenSupply, address _upgraderAddress) public initializer {

        ERC721.initialize();
        ERC721Enumerable.initialize();
        ERC721Metadata.initialize(name, symbol);

        artistSecondSalePercentage = 10;

        minBidIncreasePercent = 1;

        platformAddress = msg.sender;

        upgraderAddress = _upgraderAddress;

        expectedTokenSupply = initialExpectedTokenSupply;

        require(expectedTokenSupply > 0);
    }

    modifier onlyPlatform() {

        require(msg.sender == platformAddress);
        _;
    }

    modifier onlyMinter() {

        require(msg.sender == minterAddress);
        _;
    }

    modifier onlyWhitelistedCreator(uint256 masterTokenId, uint256 layerCount) {

        require(creatorWhitelist[masterTokenId].creator == msg.sender);
        require(creatorWhitelist[masterTokenId].layerCount == layerCount);
        _;
    }

    function setExpectedTokenSupply(uint256 newExpectedTokenSupply) external onlyPlatform {

        expectedTokenSupply = newExpectedTokenSupply;
    }

    function whitelistTokenForCreator(address creator, uint256 masterTokenId, uint256 layerCount, 
        uint256 platformFirstSalePercentage, uint256 platformSecondSalePercentage) external onlyMinter {

        require(masterTokenId == expectedTokenSupply);
        creatorWhitelist[masterTokenId] = WhitelistReservation(creator, layerCount);
        expectedTokenSupply = masterTokenId.add(layerCount).add(1);
        platformFirstSalePercentages[masterTokenId] = platformFirstSalePercentage;
        platformSecondSalePercentages[masterTokenId] = platformSecondSalePercentage;

        emit CreatorWhitelisted(masterTokenId, layerCount, creator);
    }

    function updateMinterAddress(address newMinterAddress) external onlyPlatform {

        minterAddress = newMinterAddress;
    }

    function updatePlatformAddress(address payable newPlatformAddress) external onlyPlatform {

        platformAddress = newPlatformAddress;

        emit PlatformAddressUpdated(newPlatformAddress);
    }

    function waiveFirstSaleRequirement(uint256[] calldata tokenIds) external onlyPlatform {

        for (uint256 k = 0; k < tokenIds.length; k++) {
            tokenDidHaveFirstSale[tokenIds[k]] = true;
        }        
    }
    function updatePlatformSalePercentage(uint256 tokenId, uint256 platformFirstSalePercentage, 
        uint256 platformSecondSalePercentage) external onlyPlatform {

        platformFirstSalePercentages[tokenId] = platformFirstSalePercentage;
        platformSecondSalePercentages[tokenId] = platformSecondSalePercentage;
        emit PlatformSalePercentageUpdated(tokenId, platformFirstSalePercentage, platformSecondSalePercentage);
    }
    function updateMinimumBidIncreasePercent(uint256 _minBidIncreasePercent) external onlyPlatform {

        require((_minBidIncreasePercent > 0) && (_minBidIncreasePercent <= 50), "Bid increases must be within 0-50%");
        minBidIncreasePercent = _minBidIncreasePercent;
    }
    function updateTokenURI(uint256 tokenId, string calldata tokenURI) external onlyPlatform {

        require(_exists(tokenId));
        require(tokenURILocked[tokenId] == false);
        super._setTokenURI(tokenId, tokenURI);
    }

    function lockTokenURI(uint256 tokenId) external onlyPlatform {

        require(_exists(tokenId));
        tokenURILocked[tokenId] = true;
    }

    function updateArtistSecondSalePercentage(uint256 _artistSecondSalePercentage) external onlyPlatform {

        artistSecondSalePercentage = _artistSecondSalePercentage;
        emit ArtistSecondSalePercentUpdated(artistSecondSalePercentage);
    }

    function setupControlToken(uint256 controlTokenId, string calldata controlTokenURI,
        int256[] calldata leverMinValues,
        int256[] calldata leverMaxValues,
        int256[] calldata leverStartValues,
        int256 numAllowedUpdates,
        address payable[] calldata additionalCollaborators
    ) external {

        require (leverMinValues.length <= 500, "Too many control levers.");
        require (additionalCollaborators.length <= 50, "Too many collaborators.");
        require(controlTokenMapping[controlTokenId].exists, "No control token found");
        require(controlTokenMapping[controlTokenId].isSetup == false, "Already setup");
        require(uniqueTokenCreators[controlTokenId][0] == msg.sender, "Must be control token artist");
        require((leverMinValues.length == leverMaxValues.length) && (leverMaxValues.length == leverStartValues.length), "Values array mismatch");
        require((numAllowedUpdates == -1) || (numAllowedUpdates > 0), "Invalid allowed updates");
        super._safeMint(msg.sender, controlTokenId);
        super._setTokenURI(controlTokenId, controlTokenURI);        
        controlTokenMapping[controlTokenId] = ControlToken(leverStartValues.length, numAllowedUpdates, true, true);
        for (uint256 k = 0; k < leverStartValues.length; k++) {
            require(leverMaxValues[k] >= leverMinValues[k], "Max val must >= min");
            require((leverStartValues[k] >= leverMinValues[k]) && (leverStartValues[k] <= leverMaxValues[k]), "Invalid start val");
            controlTokenMapping[controlTokenId].levers[k] = ControlLever(leverMinValues[k],
                leverMaxValues[k], leverStartValues[k], true);
        }
        for (uint256 i = 0; i < additionalCollaborators.length; i++) {
            require(additionalCollaborators[i] != address(0));

            uniqueTokenCreators[controlTokenId].push(additionalCollaborators[i]);
        }
    }

    function upgradeV1Token(uint256 tokenId, address v1Address, bool isControlToken, address to, 
        uint256 platformFirstPercentageForToken, uint256 platformSecondPercentageForToken, bool hasTokenHadFirstSale,
        address payable[] calldata uniqueTokenCreatorsForToken) external {

        AsyncArtwork_v1 v1Token = AsyncArtwork_v1(v1Address);

        require(msg.sender == upgraderAddress, "Only upgrader can call.");

        uniqueTokenCreators[tokenId] = uniqueTokenCreatorsForToken;

        if (isControlToken) {
            int256[] memory controlToken = v1Token.getControlToken(tokenId);
            require(controlToken.length % 3 == 0, "Invalid control token.");
            require(controlToken.length > 0, "Control token must have levers");            
            controlTokenMapping[tokenId] = ControlToken(controlToken.length / 3, -1, true, true);

            for (uint256 k = 0; k < controlToken.length; k+=3) {
                controlTokenMapping[tokenId].levers[k / 3] = ControlLever(controlToken[k],
                    controlToken[k + 1], controlToken[k + 2], true);
            }
        }

        platformFirstSalePercentages[tokenId] = platformFirstPercentageForToken;

        platformSecondSalePercentages[tokenId] = platformSecondPercentageForToken;

        tokenDidHaveFirstSale[tokenId] = hasTokenHadFirstSale;

        super._safeMint(to, tokenId);

        super._setTokenURI(tokenId, v1Token.tokenURI(tokenId));
    }

    function mintArtwork(uint256 masterTokenId, string calldata artworkTokenURI, address payable[] calldata controlTokenArtists)
        external onlyWhitelistedCreator(masterTokenId, controlTokenArtists.length) {

        require(masterTokenId > 0);
        super._safeMint(msg.sender, masterTokenId);
        super._setTokenURI(masterTokenId, artworkTokenURI);
        uniqueTokenCreators[masterTokenId].push(msg.sender);
        for (uint256 i = 0; i < controlTokenArtists.length; i++) {
            require(controlTokenArtists[i] != address(0));
            uint256 controlTokenId = masterTokenId + i + 1;
            uniqueTokenCreators[controlTokenId].push(controlTokenArtists[i]);
            controlTokenMapping[controlTokenId] = ControlToken(0, 0, true, false);

            platformFirstSalePercentages[controlTokenId] = platformFirstSalePercentages[masterTokenId];

            platformSecondSalePercentages[controlTokenId] = platformSecondSalePercentages[masterTokenId];

            if (controlTokenArtists[i] != msg.sender) {
                bool containsControlTokenArtist = false;

                for (uint256 k = 0; k < uniqueTokenCreators[masterTokenId].length; k++) {
                    if (uniqueTokenCreators[masterTokenId][k] == controlTokenArtists[i]) {
                        containsControlTokenArtist = true;
                        break;
                    }
                }
                if (containsControlTokenArtist == false) {
                    uniqueTokenCreators[masterTokenId].push(controlTokenArtists[i]);
                }
            }
        }
    }
    function bid(uint256 tokenId) external payable {

        require(msg.value > 0);
        require(_isApprovedOrOwner(msg.sender, tokenId) == false);
        if (pendingBids[tokenId].exists) {
            require(msg.value >= (pendingBids[tokenId].amount.mul(minBidIncreasePercent.add(100)).div(100)), "Bid must increase by min %");
            safeFundsTransfer(pendingBids[tokenId].bidder, pendingBids[tokenId].amount);
        }
        pendingBids[tokenId] = PendingBid(msg.sender, msg.value, true);
        emit BidProposed(tokenId, msg.value, msg.sender);
    }
    function withdrawBid(uint256 tokenId) external {

        require((pendingBids[tokenId].bidder == msg.sender) || (msg.sender == platformAddress));
        _withdrawBid(tokenId);        
    }
    function _withdrawBid(uint256 tokenId) internal {

        require(pendingBids[tokenId].exists);
        safeFundsTransfer(pendingBids[tokenId].bidder, pendingBids[tokenId].amount);
        pendingBids[tokenId] = PendingBid(address(0), 0, false);
        emit BidWithdrawn(tokenId);
    }

    function takeBuyPrice(uint256 tokenId, int256 expectedRemainingUpdates) external payable {

        require(_isApprovedOrOwner(msg.sender, tokenId) == false);
        uint256 saleAmount = buyPrices[tokenId];
        require(saleAmount > 0);
        require(msg.value == saleAmount);
        if (controlTokenMapping[tokenId].exists) {
            require(controlTokenMapping[tokenId].numRemainingUpdates == expectedRemainingUpdates);
        }
        if (pendingBids[tokenId].exists) {
            safeFundsTransfer(pendingBids[tokenId].bidder, pendingBids[tokenId].amount);
            pendingBids[tokenId] = PendingBid(address(0), 0, false);
        }
        onTokenSold(tokenId, saleAmount, msg.sender);
    }

    function distributeFundsToCreators(uint256 amount, address payable[] memory creators) private {

        if (creators.length > 0) {
            uint256 creatorShare = amount.div(creators.length);

            for (uint256 i = 0; i < creators.length; i++) {
                safeFundsTransfer(creators[i], creatorShare);
            }
        }
    }

    function onTokenSold(uint256 tokenId, uint256 saleAmount, address to) private {

        if (tokenDidHaveFirstSale[tokenId]) {
            uint256 platformAmount = saleAmount.mul(platformSecondSalePercentages[tokenId]).div(100);
            safeFundsTransfer(platformAddress, platformAmount);
            uint256 creatorAmount = saleAmount.mul(artistSecondSalePercentage).div(100);
            distributeFundsToCreators(creatorAmount, uniqueTokenCreators[tokenId]);
            address payable payableOwner = address(uint160(ownerOf(tokenId)));
            safeFundsTransfer(payableOwner, saleAmount.sub(platformAmount).sub(creatorAmount));
        } else {
            tokenDidHaveFirstSale[tokenId] = true;
            uint256 platformAmount = saleAmount.mul(platformFirstSalePercentages[tokenId]).div(100);
            safeFundsTransfer(platformAddress, platformAmount);
            distributeFundsToCreators(saleAmount.sub(platformAmount), uniqueTokenCreators[tokenId]);
        }
        pendingBids[tokenId] = PendingBid(address(0), 0, false);
        _transferFrom(ownerOf(tokenId), to, tokenId);
        emit TokenSale(tokenId, saleAmount, to);
    }

    function acceptBid(uint256 tokenId, uint256 minAcceptedAmount) external {

        require(_isApprovedOrOwner(msg.sender, tokenId));
        require(pendingBids[tokenId].exists);
        require(pendingBids[tokenId].amount >= minAcceptedAmount);
        onTokenSold(tokenId, pendingBids[tokenId].amount, pendingBids[tokenId].bidder);
    }

    function makeBuyPrice(uint256 tokenId, uint256 amount) external {

        require(_isApprovedOrOwner(msg.sender, tokenId));
        buyPrices[tokenId] = amount;
        emit BuyPriceSet(tokenId, amount);
    }

    function getNumRemainingControlUpdates(uint256 controlTokenId) external view returns (int256) {

        require(controlTokenMapping[controlTokenId].exists, "Token does not exist.");

        return controlTokenMapping[controlTokenId].numRemainingUpdates;
    }

    function getControlToken(uint256 controlTokenId) external view returns(int256[] memory) {

        require(controlTokenMapping[controlTokenId].exists, "Token does not exist.");

        ControlToken storage controlToken = controlTokenMapping[controlTokenId];

        int256[] memory returnValues = new int256[](controlToken.numControlLevers.mul(3));
        uint256 returnValIndex = 0;

        for (uint256 i = 0; i < controlToken.numControlLevers; i++) {
            returnValues[returnValIndex] = controlToken.levers[i].minValue;
            returnValIndex = returnValIndex.add(1);

            returnValues[returnValIndex] = controlToken.levers[i].maxValue;
            returnValIndex = returnValIndex.add(1);

            returnValues[returnValIndex] = controlToken.levers[i].currentValue;
            returnValIndex = returnValIndex.add(1);
        }

        return returnValues;
    }

    function grantControlPermission(uint256 tokenId, address permissioned) external {

        permissionedControllers[msg.sender][tokenId] = permissioned;

        emit PermissionUpdated(tokenId, msg.sender, permissioned);
    }

    function useControlToken(uint256 controlTokenId, uint256[] calldata leverIds, int256[] calldata newValues) external payable {

        require(_isApprovedOrOwner(msg.sender, controlTokenId) || (permissionedControllers[ownerOf(controlTokenId)][controlTokenId] == msg.sender),
            "Owner or permissioned only");
        require(controlTokenMapping[controlTokenId].exists, "Token does not exist.");
        ControlToken storage controlToken = controlTokenMapping[controlTokenId];
        require((controlToken.numRemainingUpdates == -1) || (controlToken.numRemainingUpdates > 0), "No more updates allowed");        
        int256[] memory previousValues = new int256[](newValues.length);

        for (uint256 i = 0; i < leverIds.length; i++) {
            ControlLever storage lever = controlTokenMapping[controlTokenId].levers[leverIds[i]];

            require((newValues[i] >= lever.minValue) && (newValues[i] <= lever.maxValue), "Invalid val");

            require(newValues[i] != lever.currentValue, "Must provide different val");

            previousValues[i] = lever.currentValue;

            lever.currentValue = newValues[i];    
        }

        if (msg.value > 0) {
            safeFundsTransfer(platformAddress, msg.value);
        }

        if (controlToken.numRemainingUpdates > 0) {
            controlToken.numRemainingUpdates = controlToken.numRemainingUpdates - 1;

            if (pendingBids[controlTokenId].exists) {
                _withdrawBid(controlTokenId);
            }
        }

        emit ControlLeverUpdated(controlTokenId, msg.value, controlToken.numRemainingUpdates, leverIds, previousValues, newValues);
    }

    function withdrawAllFailedCredits() external {

        uint256 amount = failedTransferCredits[msg.sender];

        require(amount != 0);
        require(address(this).balance >= amount);

        failedTransferCredits[msg.sender] = 0;

        (bool successfulWithdraw, ) = msg.sender.call.value(amount)("");
        require(successfulWithdraw);
    }

    function safeFundsTransfer(address payable recipient, uint256 amount) internal {

        (bool success, ) = recipient.call.value(amount).gas(2300)("");
        if (success == false) {
            failedTransferCredits[recipient] = failedTransferCredits[recipient].add(amount);
        }
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        buyPrices[tokenId] = 0;
        super._transferFrom(from, to, tokenId);
    }
}