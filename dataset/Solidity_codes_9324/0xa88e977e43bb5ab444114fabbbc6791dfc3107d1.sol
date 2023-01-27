

pragma solidity ^0.5.12;


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

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

contract ERC721 is ERC165, IERC721 {

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

        require(owner != address(0));

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(owner != address(0));

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner);

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {


        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender);

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));
        _safeTransferFrom(from, to, tokenId, _data);
    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) internal {

        _transferFrom(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, _data));
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {        

        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    function _safeMint(address to, uint256 tokenId) internal {

        _safeMint(to, tokenId, "");
    }

    function _safeMint(address to, uint256 tokenId, bytes memory _data) internal {

        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, _data));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0));
        require(!_exists(tokenId), "token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(address owner, uint256 tokenId) internal {

        require(ownerOf(tokenId) == owner);

        _clearApproval(tokenId);

        _ownedTokensCount[owner].decrement();
        _tokenOwner[tokenId] = address(0);

        emit Transfer(owner, address(0), tokenId);
    }

    function _burn(uint256 tokenId) internal {

        _burn(ownerOf(tokenId), tokenId);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {

        require(ownerOf(tokenId) == from, "not owner");
        require(to != address(0));

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

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
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

contract ERC721Enumerable is ERC165, ERC721, IERC721Enumerable {

    mapping(address => uint256[]) private _ownedTokens;

    mapping(uint256 => uint256) private _ownedTokensIndex;

    uint256[] private _allTokens;

    mapping(uint256 => uint256) private _allTokensIndex;

    bytes4 private constant _INTERFACE_ID_ERC721_ENUMERABLE = 0x780e9d63;

    constructor () public {
        _registerInterface(_INTERFACE_ID_ERC721_ENUMERABLE);
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256) {

        return _ownedTokens[owner][index];
    }

    function totalSupply() public view returns (uint256) {

        return _allTokens.length;
    }

    function tokenByIndex(uint256 index) public view returns (uint256) {

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

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    mapping(uint256 => string) private _tokenURIs;

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

    function tokenURI(uint256 tokenId) external view returns (string memory) {

        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId), "URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}

contract AsyncArtwork is ERC721, ERC721Enumerable, ERC721Metadata {

    event PlatformAddressUpdated (
        address platformAddress
    );

    event RoyaltyAmountUpdated (
        uint256 platformFirstPercentage,
        uint256 platformSecondPercentage,
        uint256 artistSecondPercentage
    );

	event BidProposed (
		uint256 tokenId,
        uint256 bidAmount,
        address bidder
    );

    event BidWithdrawn (
    	uint256 tokenId
    );

    event BuyPriceSet (
    	uint256 tokenId,
    	uint256 price
    );

    event TokenSale (
        uint256 tokenId,
        uint256 salePrice,
    	address buyer  	
    );

    event ControlLeverUpdated (
    	uint256 tokenId,
    	uint256 priorityTip,
        uint256[] leverIds,
    	int256[] previousValues,
    	int256[] updatedValues
	);

    struct ControlToken {        
        uint256 numControlLevers;
        bool exists;
        bool isSetup;
        mapping (uint256 => ControlLever) levers;
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

	mapping (address => bool) public whitelistedCreators;
    mapping (uint256 => address payable[]) public uniqueTokenCreators;
    mapping (uint256 => ControlToken) controlTokenMapping;
	mapping (uint256 => uint256) public buyPrices;	
	mapping (uint256 => PendingBid) public pendingBids;
    mapping (uint256 => bool) public tokenDidHaveFirstSale;    
    mapping (address => address) public permissionedControllers;
    uint256 public platformFirstSalePercentage;
    uint256 public platformSecondSalePercentage;
    uint256 public artistSecondSalePercentage;
    uint256 public expectedTokenSupply;
    address payable public platformAddress;

	constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
        platformFirstSalePercentage = 10;
        platformSecondSalePercentage = 1;
        artistSecondSalePercentage = 4;

        platformAddress = msg.sender;

        updateWhitelist(platformAddress, true);
  	}

    modifier onlyPlatform() {

        require(msg.sender == platformAddress);
        _;    
    }

    modifier onlyWhitelistedCreator() { 

    	require(whitelistedCreators[msg.sender] == true);
    	_; 
    }
    
    function updateWhitelist(address creator, bool state) public onlyPlatform {

    	whitelistedCreators[creator] = state;
    }

    function updatePlatformAddress(address payable newPlatformAddress) public onlyPlatform {

        platformAddress = newPlatformAddress;

        emit PlatformAddressUpdated(newPlatformAddress);
    }

    function updateRoyaltyPercentages(uint256 _platformFirstSalePercentage, uint256 _platformSecondSalePercentage, 
        uint256 _artistSecondSalePercentage) public onlyPlatform {

    	require (_platformFirstSalePercentage < 100);
    	require (_platformSecondSalePercentage.add(_artistSecondSalePercentage) < 100);
        platformFirstSalePercentage = _platformFirstSalePercentage;
        platformSecondSalePercentage = _platformSecondSalePercentage;
        artistSecondSalePercentage = _artistSecondSalePercentage;
        emit RoyaltyAmountUpdated(platformFirstSalePercentage, platformSecondSalePercentage, artistSecondSalePercentage);
    }
    function setupControlToken(uint256 controlTokenId, string memory controlTokenURI,
            int256[] memory leverMinValues, 
            int256[] memory leverMaxValues,
            int256[] memory leverStartValues,
            address payable[] memory additionalCollaborators
        ) public {

        require (controlTokenMapping[controlTokenId].exists, "No control token found");
        require (controlTokenMapping[controlTokenId].isSetup == false, "Already setup");        
        require(uniqueTokenCreators[controlTokenId][0] == msg.sender, "Must be control token artist");        
        require((leverMinValues.length == leverMaxValues.length) && (leverMaxValues.length == leverStartValues.length), "Values array mismatch");
        super._safeMint(msg.sender, controlTokenId);
        super._setTokenURI(controlTokenId, controlTokenURI);        
        controlTokenMapping[controlTokenId] = ControlToken(leverStartValues.length, true, true);
        for (uint256 k = 0; k < leverStartValues.length; k++) {
            require (leverMaxValues[k] >= leverMinValues[k], "Max val must >= min");
            require((leverStartValues[k] >= leverMinValues[k]) && (leverStartValues[k] <= leverMaxValues[k]), "Invalid start val");
            controlTokenMapping[controlTokenId].levers[k] = ControlLever(leverMinValues[k],
                leverMaxValues[k], leverStartValues[k], true);
        }
        for (uint256 i = 0; i < additionalCollaborators.length; i++) {
            require(additionalCollaborators[i] != address(0));

            uniqueTokenCreators[controlTokenId].push(additionalCollaborators[i]);
        }
    }

    function mintArtwork(uint256 artworkTokenId, string memory artworkTokenURI, address payable[] memory controlTokenArtists
    ) public onlyWhitelistedCreator {

        require (artworkTokenId == expectedTokenSupply, "ExpectedTokenSupply different");
        super._safeMint(msg.sender, artworkTokenId);
        expectedTokenSupply++;

        super._setTokenURI(artworkTokenId, artworkTokenURI);        
        uniqueTokenCreators[artworkTokenId].push(msg.sender);

        for (uint256 i = 0; i < controlTokenArtists.length; i++) {
            require(controlTokenArtists[i] != address(0));

            uint256 controlTokenId = expectedTokenSupply;
            expectedTokenSupply++;

            uniqueTokenCreators[controlTokenId].push(controlTokenArtists[i]);
            controlTokenMapping[controlTokenId] = ControlToken(0, true, false);

            if (controlTokenArtists[i] != msg.sender) {
                bool containsControlTokenArtist = false;

                for (uint256 k = 0; k < uniqueTokenCreators[artworkTokenId].length; k++) {
                    if (uniqueTokenCreators[artworkTokenId][k] == controlTokenArtists[i]) {
                        containsControlTokenArtist = true;
                        break;
                    }
                }
                if (containsControlTokenArtist == false) {
                    uniqueTokenCreators[artworkTokenId].push(controlTokenArtists[i]);
                }
            }
        }
    }
    function bid(uint256 tokenId) public payable {

        require(_isApprovedOrOwner(msg.sender, tokenId) == false);        
    	if (pendingBids[tokenId].exists) {
    		require(msg.value > pendingBids[tokenId].amount, "Bid must be > than current bid");
            pendingBids[tokenId].bidder.transfer(pendingBids[tokenId].amount);
    	}
    	pendingBids[tokenId] = PendingBid(msg.sender, msg.value, true);
    	emit BidProposed(tokenId, msg.value, msg.sender);
    }
    function withdrawBid(uint256 tokenId) public {

        require (pendingBids[tokenId].exists && (pendingBids[tokenId].bidder == msg.sender));
        pendingBids[tokenId].bidder.transfer(pendingBids[tokenId].amount);
		pendingBids[tokenId] = PendingBid(address(0), 0, false);
		emit BidWithdrawn(tokenId);
    }
    function takeBuyPrice(uint256 tokenId) public payable {

        require(_isApprovedOrOwner(msg.sender, tokenId) == false);
        uint256 saleAmount = buyPrices[tokenId];
        require(saleAmount > 0);
        require (msg.value >= saleAmount);
        if (pendingBids[tokenId].exists) {
            pendingBids[tokenId].bidder.transfer(pendingBids[tokenId].amount);
            pendingBids[tokenId] = PendingBid(address(0), 0, false);
        }        
        onTokenSold(tokenId, saleAmount, msg.sender);
    }

    function distributeFundsToCreators(uint256 amount, address payable[] memory creators) private {

        uint256 creatorShare = amount.div(creators.length);

        for (uint256 i = 0; i < creators.length; i++) {
            creators[i].transfer(creatorShare);
        }
    }

    function onTokenSold(uint256 tokenId, uint256 saleAmount, address to) private {

        if (tokenDidHaveFirstSale[tokenId]) {
        	uint256 platformAmount = saleAmount.mul(platformSecondSalePercentage).div(100);
        	platformAddress.transfer(platformAmount);
        	uint256 creatorAmount = saleAmount.mul(artistSecondSalePercentage).div(100);
        	distributeFundsToCreators(creatorAmount, uniqueTokenCreators[tokenId]);            
            address payable payableOwner = address(uint160(ownerOf(tokenId)));
            payableOwner.transfer(saleAmount.sub(platformAmount).sub(creatorAmount));
        } else {
        	tokenDidHaveFirstSale[tokenId] = true;
        	uint256 platformAmount = saleAmount.mul(platformFirstSalePercentage).div(100);
        	platformAddress.transfer(platformAmount);
            distributeFundsToCreators(saleAmount.sub(platformAmount), uniqueTokenCreators[tokenId]);
        }            
        _safeTransferFrom(ownerOf(tokenId), to, tokenId, "");
        pendingBids[tokenId] = PendingBid(address(0), 0, false);
        emit TokenSale(tokenId, saleAmount, to);
    }

    function acceptBid(uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId));
    	require (pendingBids[tokenId].exists);
        onTokenSold(tokenId, pendingBids[tokenId].amount, pendingBids[tokenId].bidder);
    }

    function makeBuyPrice(uint256 tokenId, uint256 amount) public {

    	require(_isApprovedOrOwner(msg.sender, tokenId));        
    	buyPrices[tokenId] = amount;
    	emit BuyPriceSet(tokenId, amount);
    }

    function getControlToken(uint256 controlTokenId) public view returns (int256[] memory) {

        require(controlTokenMapping[controlTokenId].exists);
        
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
    function grantControlPermission(address permissioned) public {

        permissionedControllers[msg.sender] = permissioned;
    }

    function useControlToken(uint256 controlTokenId, uint256[] memory leverIds, int256[] memory newValues) public payable {

        require(_isApprovedOrOwner(msg.sender, controlTokenId) || (permissionedControllers[ownerOf(controlTokenId)] == msg.sender),
            "Owner or permissioned only"); 
        int256[] memory previousValues = new int256[](newValues.length);

        for (uint256 i = 0; i < leverIds.length; i++) {
            ControlLever storage lever = controlTokenMapping[controlTokenId].levers[leverIds[i]];

            require((newValues[i] >= lever.minValue) && (newValues[i] <= lever.maxValue), "Invalid val");

            require(newValues[i] != lever.currentValue, "Must provide different val");

            int256 previousValue = lever.currentValue;
            
            lever.currentValue = newValues[i];

            previousValues[i] = previousValue;
        }

        if (msg.value > 0) {
        	platformAddress.transfer(msg.value);
        }
        
    	emit ControlLeverUpdated(controlTokenId, msg.value, leverIds, previousValues, newValues);
    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {        

        super._transferFrom(from, to, tokenId);        
        buyPrices[tokenId] = 0;
    }
}