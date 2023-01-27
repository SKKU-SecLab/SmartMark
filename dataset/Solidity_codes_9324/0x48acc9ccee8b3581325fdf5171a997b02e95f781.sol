

pragma solidity ^0.5.11;


interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}


pragma solidity ^0.5.11;


contract IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed tokenOwner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed tokenOwner, address indexed operator, bool approved);

    function balanceOf(address tokenOwner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address tokenOwner);


    function safeTransferFrom(address from, address to, uint256 tokenId) public;

    function transferFrom(address from, address to, uint256 tokenId) public;

    function approve(address to, uint256 tokenId) public;

    function getApproved(uint256 tokenId) public view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;

    function isApprovedForAll(address tokenOwner, address operator) public view returns (bool);



    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;

}


pragma solidity ^0.5.11;


contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
    public returns (bytes4);

}


pragma solidity ^0.5.11;


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


pragma solidity ^0.5.11;


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
}


pragma solidity ^0.5.11;


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


pragma solidity ^0.5.11;


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


pragma solidity ^0.5.11;
pragma experimental ABIEncoderV2;









contract DeployedRegistry {

    function isContentIdRegisteredToCaller(uint32 federationId, string memory contentId) public view returns(bool);

    function isMinter(uint32 federationId, address account) public view returns (bool);

    function isAuthorizedTransferFrom(uint32 federationId, address from, address to, uint256 tokenId, address minter, address owner) public view returns(bool);

}


contract ERC721 is ERC165, IERC721 {

    using SafeMath for uint256;
    using Address for address;
    using Counters for Counters.Counter;




    address public owner1;
    address public owner2;

    bool public paused = false;

    uint256 public mintFee = 100000000000000;

    DeployedRegistry public registry;

    Counters.Counter _tokenIds;

    mapping (uint256 => address) private _tokenOwner;

    mapping (address => Counters.Counter) private _ownedTokensCount;

    mapping (address => Counters.Counter) private _mintedTokensCount;

    mapping (uint256 => uint32) public tokenToFederationId;

    struct TimeSlot {
        address minter; // the address of the user who mint()'ed this time slot
        string contentId; // the users' registered contentId containing the Property
        string propertyName; // describes the Property within the contentId that is tokenized into time slots
        uint48 startTime; // min timestamp (when time slot begins)
        uint48 endTime; // max timestamp (when time slot ends)
        uint48 auctionEndTime; // max timestamp (when auction for time slot ends)
        uint16 category; // integer that represents the category (see Microsponsors utils.js)
        bool isSecondaryTradingEnabled; // if true, first buyer can trade to others
    }
    mapping(uint256 => TimeSlot) private _tokenToTimeSlot;

    struct PropertyNameStruct {
        string propertyName;
    }
    mapping(address => mapping(string => PropertyNameStruct[])) private _tokenMinterToPropertyNames;

    struct ContentIdStruct {
        string contentId;
    }
    mapping(address => ContentIdStruct[]) private _tokenMinterToContentIds;

    mapping(uint256 => string) private _tokenURIs;

    mapping (uint256 => address) private _tokenApprovals;

    mapping (address => mapping (address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;


    constructor () public {

        _registerInterface(_INTERFACE_ID_ERC721);

        owner1 = _msgSender();
        owner2 = _msgSender();

    }



    function _msgSender() internal view returns (address) {


        return msg.sender;

    }

    function _msgData() internal view returns (bytes memory) {


        this; // silence state mutability warning without generating bytecode -
        return msg.data;

    }




    modifier onlyOwner() {

        require(
            (_msgSender() == owner1) || (_msgSender() == owner2),
            "ONLY_CONTRACT_OWNER"
        );
        _;
    }

    function transferOwnership1(address newOwner)
        public
        onlyOwner
    {

        if (newOwner != address(0)) {
            owner1 = newOwner;
        }
    }


    function transferOwnership2(address newOwner)
        public
        onlyOwner
    {

        if (newOwner != address(0)) {
            owner2 = newOwner;
        }
    }

    function updateRegistryAddress(address newAddress)
        public
        onlyOwner
    {

        registry = DeployedRegistry(newAddress);
    }

    function updateMintFee(uint256 val)
        public
        onlyOwner
    {


        mintFee = val;

    }

    modifier whenNotPaused() {

        require(!paused);
        _;
    }

    modifier whenPaused {

        require(paused);
        _;
    }

    function pause() public onlyOwner whenNotPaused {

        paused = true;
    }

    function unpause() public onlyOwner whenPaused {

        paused = false;
    }

    function withdrawBalance() external onlyOwner {


        uint balance = address(this).balance;
        (bool success, ) = msg.sender.call.value(balance)("");
        require(success, "WITHDRAW_FAILED");

    }




    function mint(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        bool isSecondaryTradingEnabled,
        uint32 federationId
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {


        require(msg.value >= mintFee);

        require(federationId > 0, "INVALID_FEDERATION_ID");

        require(
            registry.isMinter(federationId, _msgSender()),
            "CALLER_NOT_AUTHORIZED_FOR_MINTER_ROLE"
        );

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime, federationId),
            "INVALID_TIME_SLOT"
        );

        uint256 tokenId = _mint(_msgSender());
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category, isSecondaryTradingEnabled);
        tokenToFederationId[tokenId] = federationId;

        return tokenId;

    }

    function mintWithTokenURI(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        bool isSecondaryTradingEnabled,
        uint32 federationId,
        string memory tokenURI
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {


        require(msg.value >= mintFee);

        require(federationId > 0, "INVALID_FEDERATION_ID");

        require(
            registry.isMinter(federationId, _msgSender()),
            "CALLER_NOT_AUTHORIZED_FOR_MINTER_ROLE"
        );

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime, federationId),
            "INVALID_TIME_SLOT"
        );

        uint256 tokenId = _mint(_msgSender());
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category, isSecondaryTradingEnabled);
        _setTokenURI(tokenId, tokenURI);
        tokenToFederationId[tokenId] = federationId;

        return tokenId;

    }

    function safeMint(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        bool isSecondaryTradingEnabled,
        uint32 federationId
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {


        require(msg.value >= mintFee);

        require(federationId > 0, "INVALID_FEDERATION_ID");

        require(
            registry.isMinter(federationId, _msgSender()),
            "CALLER_NOT_AUTHORIZED_FOR_MINTER_ROLE"
        );

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime, federationId),
            "INVALID_TIME_SLOT"
        );

        uint256 tokenId = _safeMint(_msgSender());
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category, isSecondaryTradingEnabled);
        tokenToFederationId[tokenId] = federationId;

        return tokenId;

    }

    function safeMint(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        bool isSecondaryTradingEnabled,
        uint32 federationId,
        bytes memory data
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {


        require(msg.value >= mintFee);

        require(federationId > 0, "INVALID_FEDERATION_ID");

        require(
            registry.isMinter(federationId, _msgSender()),
            "CALLER_NOT_AUTHORIZED_FOR_MINTER_ROLE"
        );

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime, federationId),
            "INVALID_TIME_SLOT"
        );

        uint256 tokenId = _safeMint(_msgSender(), data);
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category, isSecondaryTradingEnabled);
        tokenToFederationId[tokenId] = federationId;

        return tokenId;

    }

    function safeMintWithTokenURI(
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        bool isSecondaryTradingEnabled,
        uint32 federationId,
        string memory tokenURI
    )
        public
        payable
        whenNotPaused
        returns (uint256)
    {


        require(msg.value >= mintFee);

        require(federationId > 0, "INVALID_FEDERATION_ID");

        require(
            registry.isMinter(federationId, _msgSender()),
            "CALLER_NOT_AUTHORIZED_FOR_MINTER_ROLE"
        );

        require(
            _isValidTimeSlot(contentId, startTime, endTime, auctionEndTime, federationId),
            "INVALID_TIME_SLOT"
        );

        uint256 tokenId = _safeMint(_msgSender());
        _setTokenTimeSlot(tokenId, contentId, propertyName, startTime, endTime, auctionEndTime, category, isSecondaryTradingEnabled);
        _setTokenURI(tokenId, tokenURI);
        tokenToFederationId[tokenId] = federationId;

        return tokenId;

    }

    function _safeMint(address to) internal returns (uint256) {


        uint256 tokenId = _safeMint(to, "");
        return tokenId;

    }

    function _safeMint(address to, bytes memory data) internal returns (uint256) {


        uint256 tokenId = _mint(to);

        require(
            _checkOnERC721Received(address(0), to, tokenId, data),
            "TRANSFER_TO_NON_ERC721RECEIVER_IMPLEMENTER"
        );

        return tokenId;

    }

    function _mint(address to) internal returns (uint256) {


        require(to != address(0), "MINT_TO_ZERO_ADDRESS");

        _tokenIds.increment();
        uint256 tokenId = _tokenIds.current();

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();
        _mintedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);

        return tokenId;

    }




    function _setTokenURI(uint256 tokenId, string memory uri) internal {


        require(
            _exists(tokenId),
            "NON_EXISTENT_TOKEN"
        );

        _tokenURIs[tokenId] = uri;

    }

    function tokenURI(uint256 tokenId) external view returns (string memory) {


        require(
            _exists(tokenId),
            "NON_EXISTENT_TOKEN"
        );

        return _tokenURIs[tokenId];

    }




    function _isValidTimeSlot(
        string memory contentId,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint32 federationId
    ) internal view returns (bool) {


        require(
            registry.isContentIdRegisteredToCaller(federationId, contentId),
            "CONTENT_ID_NOT_REGISTERED_TO_CALLER"
        );

        require(
            startTime > auctionEndTime,
            "START_TIME_AFTER_AUCTION_END_TIME"
        );

        require(
            endTime > startTime,
            "START_TIME_AFTER_END_TIME"
        );

        return true;

    }


    function _isContentIdMappedToMinter(
        string memory contentId
    )  internal view returns (bool) {


        ContentIdStruct[] memory a = _tokenMinterToContentIds[msg.sender];
        bool foundMatch = false;
        for (uint i = 0; i < a.length; i++) {
            if (stringsMatch(contentId, a[i].contentId)) {
                foundMatch = true;
            }
        }

        return foundMatch;
    }


    function _isPropertyNameMappedToMinter(
        string memory contentId,
        string memory propertyName
    )  internal view returns (bool) {


        PropertyNameStruct[] memory a = _tokenMinterToPropertyNames[msg.sender][contentId];
        bool foundMatch = false;
        for (uint i = 0; i < a.length; i++) {
            if (stringsMatch(propertyName, a[i].propertyName)) {
                foundMatch = true;
            }
        }

        return foundMatch;
    }


    function _setTokenTimeSlot(
        uint256 tokenId,
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        bool isSecondaryTradingEnabled
    ) internal {


        require(
            _exists(tokenId),
            "NON_EXISTENT_TOKEN"
        );

        TimeSlot memory _timeSlot = TimeSlot({
            minter: address(_msgSender()),
            contentId: string(contentId),
            propertyName: string(propertyName),
            startTime: uint48(startTime),
            endTime: uint48(endTime),
            auctionEndTime: uint48(auctionEndTime),
            category: uint16(category),
            isSecondaryTradingEnabled: bool(isSecondaryTradingEnabled)

        });

        _tokenToTimeSlot[tokenId] = _timeSlot;

        if (!_isContentIdMappedToMinter(contentId)) {
            _tokenMinterToContentIds[_msgSender()].push( ContentIdStruct(contentId) );
        }

        if (!_isPropertyNameMappedToMinter(contentId, propertyName)) {
            _tokenMinterToPropertyNames[_msgSender()][contentId].push( PropertyNameStruct(propertyName) );
        }

    }


    function tokenTimeSlot(uint256 tokenId) public view returns (
        address minter,
        address owner,
        string memory contentId,
        string memory propertyName,
        uint48 startTime,
        uint48 endTime,
        uint48 auctionEndTime,
        uint16 category,
        bool isSecondaryTradingEnabled,
        uint32 federationId
    ) {


        require(
            _exists(tokenId),
            "NON_EXISTENT_TOKEN"
        );

        TimeSlot memory _timeSlot = _tokenToTimeSlot[tokenId];
        uint32 _federationId = tokenToFederationId[tokenId];

        return (
            _timeSlot.minter,
            ownerOf(tokenId),
            _timeSlot.contentId,
            _timeSlot.propertyName,
            _timeSlot.startTime,
            _timeSlot.endTime,
            _timeSlot.auctionEndTime,
            _timeSlot.category,
            _timeSlot.isSecondaryTradingEnabled,
            _federationId
        );

    }




    function tokenMinterContentIds(address minter) external view returns (string[] memory) {


        ContentIdStruct[] memory m = _tokenMinterToContentIds[minter];
        string[] memory r = new string[](m.length);

        for (uint i = 0; i < m.length; i++) {
            r[i] = m[i].contentId;
        }

        return r;

    }

    function tokenMinterPropertyNames(
        address minter,
        string calldata contentId
    ) external view returns (string[] memory) {


        PropertyNameStruct[] memory m = _tokenMinterToPropertyNames[minter][contentId];
        string[] memory r = new string[](m.length);

        for (uint i = 0; i < m.length; i++) {
            r[i] =  m[i].propertyName;
        }

        return r;

    }


    function tokensMintedBy(address minter) external view returns (uint256[] memory) {


        require(
            minter != address(0),
            "CANNOT_QUERY_ZERO_ADDRESS"
        );

        uint256 tokenCount = _mintedTokensCount[minter].current();
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = totalSupply();
            uint256 resultIndex = 0;

            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (_tokenToTimeSlot[tokenId].minter == minter) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }

    }




    function totalSupply() public view returns (uint256) {


        return _tokenIds.current();

    }

    function balanceOf(address tokenOwner) public view returns (uint256) {


        require(
            tokenOwner != address(0),
            "CANNOT_QUERY_ZERO_ADDRESS"
        );

        return _ownedTokensCount[tokenOwner].current();

    }

    function ownerOf(uint256 tokenId) public view returns (address) {


        address tokenOwner = _tokenOwner[tokenId];

        return tokenOwner;

    }

    function tokensOfOwner(address tokenOwner) external view returns(uint256[] memory) {

        uint256 tokenCount = balanceOf(tokenOwner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTokens = totalSupply();
            uint256 resultIndex = 0;

            uint256 tokenId;

            for (tokenId = 1; tokenId <= totalTokens; tokenId++) {
                if (_tokenOwner[tokenId] == tokenOwner) {
                    result[resultIndex] = tokenId;
                    resultIndex++;
                }
            }

            return result;
        }
    }




    function approve(address to, uint256 tokenId)
        public
        whenNotPaused
    {


        address tokenOwner = ownerOf(tokenId);

        require(
            to != tokenOwner,
            "APPROVAL_IS_REDUNDANT"
        );

        require(
            _msgSender() == tokenOwner || isApprovedForAll(tokenOwner, _msgSender()),
            "CALLER_NOT_AUTHORIZED"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);

    }

    function getApproved(uint256 tokenId) public view returns (address) {


        require(
            _exists(tokenId),
            "NON_EXISTENT_TOKEN"
        );

        return _tokenApprovals[tokenId];

    }

    function setApprovalForAll(address to, bool approved)
        public
        whenNotPaused
    {


        require(to != _msgSender(), "CALLER_CANNOT_APPROVE_SELF");

        _operatorApprovals[_msgSender()][to] = approved;
        emit ApprovalForAll(_msgSender(), to, approved);

    }

    function isApprovedForAll(address tokenOwner, address operator)
        public
        view
        returns (bool)
    {


        return _operatorApprovals[tokenOwner][operator];

    }

    function transferFrom(address from, address to, uint256 tokenId)
        public
        whenNotPaused
    {


        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "UNAUTHORIZED_TRANSFER"
        );

        address minter = _tokenToTimeSlot[tokenId].minter;
        address owner = ownerOf(tokenId);
        uint32 federationId = tokenToFederationId[tokenId];

        if (_tokenToTimeSlot[tokenId].isSecondaryTradingEnabled == false) {
            require(
                isSecondaryTrade(from, to, tokenId) == false,
                "SECONDARY_TRADING_DISABLED"
            );
        }

        require(
            registry.isAuthorizedTransferFrom(federationId, from, to, tokenId, minter, owner),
            "UNAUTHORIZED_TRANSFER"
        );

        _transferFrom(from, to, tokenId);

    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {


        safeTransferFrom(from, to, tokenId, "");

    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        public
        whenNotPaused
    {


        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "UNAUTHORIZED_TRANSFER"
        );

        address minter = _tokenToTimeSlot[tokenId].minter;
        address owner = ownerOf(tokenId);
        uint32 federationId = tokenToFederationId[tokenId];

        if (_tokenToTimeSlot[tokenId].isSecondaryTradingEnabled == false) {
            require(
                isSecondaryTrade(from, to, tokenId) == false,
                "SECONDARY_TRADING_DISABLED"
            );
        }

        require(
            registry.isAuthorizedTransferFrom(federationId, from, to, tokenId, minter, owner),
            "UNAUTHORIZED_TRANSFER"
        );

        _safeTransferFrom(from, to, tokenId, data);

    }

    function _safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data)
        internal
    {


        _transferFrom(from, to, tokenId);

        require(
            _checkOnERC721Received(from, to, tokenId, data),
            "TRANSFER_TO_NON_ERC721RECEIVER_IMPLEMENTER"
        );

    }

    function _exists(uint256 tokenId) internal view returns (bool) {


        address tokenOwner = _tokenOwner[tokenId];

        return tokenOwner != address(0);

    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {


        require(
            _exists(tokenId),
            "NON_EXISTENT_TOKEN"
        );

        address tokenOwner = ownerOf(tokenId);

        return (spender == tokenOwner || getApproved(tokenId) == spender || isApprovedForAll(tokenOwner, spender));

    }

    function _transferFrom(address from, address to, uint256 tokenId) internal {


        require(
            ownerOf(tokenId) == from,
            "UNAUTHORIZED_TRANSFER"
        );

        require(
            to != address(0),
            "TRANSFER_TO_ZERO_ADDRESS"
        );

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);

    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data)
        internal
        returns (bool)
    {


        if (!to.isContract()) {
            return true;
        }

        bytes4 retval = IERC721Receiver(to).onERC721Received(_msgSender(), from, tokenId, data);
        return (retval == _ERC721_RECEIVED);

    }

    function _clearApproval(uint256 tokenId) private {


        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }

    }




    function burn(uint256 tokenId) public whenNotPaused {


        address minter = _tokenToTimeSlot[tokenId].minter;
        address tokenOwner = ownerOf(tokenId);
        uint32 federationId = tokenToFederationId[tokenId];

        if (tokenOwner == minter) {
            require(
                registry.isMinter(federationId, _msgSender()),
                "UNAUTHORIZED_BURN"
            );
        }

        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "UNAUTHORIZED_BURN"
        );

        _burn(tokenId);

    }


    function _burn(address tokenOwner, uint256 tokenId) internal {


        require(
            ownerOf(tokenId) == tokenOwner,
            "UNAUTHORIZED_BURN"
        );

        _clearApproval(tokenId);

        _ownedTokensCount[tokenOwner].decrement();
        _tokenOwner[tokenId] = address(0);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }

        delete _tokenToTimeSlot[tokenId];

        emit Transfer(tokenOwner, address(0), tokenId);

    }

    function _burn(uint256 tokenId) internal {


        _burn(ownerOf(tokenId), tokenId);

    }



    function stringsMatch (
        string memory a,
        string memory b
    )
        private
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))) );
    }

    function isSecondaryTrade (
        address from,
        address to,
        uint256 tokenId
    )
        internal
        view
        returns (bool)
    {

        address minter = _tokenToTimeSlot[tokenId].minter;

        if (from == minter || to == minter) {
            return false;
        } else {
            return true;
        }

    }

}




contract Microsponsors is ERC721 {


    string private _name;

    string private _symbol;


    bytes4 private constant _INTERFACE_ID_ERC721_METADATA = 0x5b5e139f;

    constructor (string memory name, string memory symbol, address registryAddress) public {

        _name = name;
        _symbol = symbol;

        _registerInterface(_INTERFACE_ID_ERC721_METADATA);

        super.updateRegistryAddress(registryAddress);

    }

    function name() external view returns (string memory) {

        return _name;
    }

    function symbol() external view returns (string memory) {

        return _symbol;
    }

}