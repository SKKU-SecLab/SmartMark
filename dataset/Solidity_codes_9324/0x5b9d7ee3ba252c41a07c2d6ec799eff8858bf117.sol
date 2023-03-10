


pragma solidity ^0.5.7;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

contract IERC721 is IERC165 {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    function balanceOf(address owner) public view returns (uint256 balance);


    function ownerOf(uint256 tokenId) public view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public;


    function approve(address to, uint256 tokenId) public;


    function getApproved(uint256 tokenId)
        public
        view
        returns (address operator);


    function setApprovalForAll(address operator, bool _approved) public;


    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public;

}

contract IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public returns (bytes4);

}

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
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

        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {


        bytes32 codehash;
        bytes32 accountHash =
            0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {

        return address(uint160(account));
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

    constructor() internal {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId)
        external
        view
        returns (bool)
    {

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

    mapping(uint256 => address) private _tokenOwner;

    mapping(uint256 => address) private _tokenApprovals;

    mapping(address => Counters.Counter) private _ownedTokensCount;

    mapping(address => mapping(address => bool)) private _operatorApprovals;

    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;

    constructor() public {
        _registerInterface(_INTERFACE_ID_ERC721);
    }

    function balanceOf(address owner) public view returns (uint256) {

        require(
            owner != address(0),
            "ERC721: balance query for the zero address"
        );

        return _ownedTokensCount[owner].current();
    }

    function ownerOf(uint256 tokenId) public view returns (address) {

        address owner = _tokenOwner[tokenId];
        require(
            owner != address(0),
            "ERC721: owner query for nonexistent token"
        );

        return owner;
    }

    function approve(address to, uint256 tokenId) public {

        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: approval to current owner");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {

        require(
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address to, bool approved) public {

        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {

        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {

        transferFrom(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    function _exists(uint256 tokenId) internal view returns (bool) {

        address owner = _tokenOwner[tokenId];
        return owner != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {

        require(
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    function _mint(address to, uint256 tokenId) internal {

        require(to != address(0), "ERC721: mint to the zero address");
        require(!_exists(tokenId), "ERC721: token already minted");

        _tokenOwner[tokenId] = to;
        _ownedTokensCount[to].increment();

        emit Transfer(address(0), to, tokenId);
    }

    function _transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) internal {

        require(
            ownerOf(tokenId) == from,
            "ERC721: transfer of token that is not own"
        );
        require(to != address(0), "ERC721: transfer to the zero address");

        _clearApproval(tokenId);

        _ownedTokensCount[from].decrement();
        _ownedTokensCount[to].increment();

        _tokenOwner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal returns (bool) {

        if (!to.isContract()) {
            return true;
        }

        bytes4 retval =
            IERC721Receiver(to).onERC721Received(
                msg.sender,
                from,
                tokenId,
                _data
            );
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}

library Roles {

    struct Role {
        mapping(address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account)
        internal
        view
        returns (bool)
    {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}

contract MinterRole {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor() internal {
        _addMinter(msg.sender);
    }

    modifier onlyMinter() {

        require(
            isMinter(msg.sender),
            "MinterRole: caller does not have the Minter role"
        );
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(msg.sender);
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

contract ERC721Mintable is ERC721, MinterRole {


    bool public anyoneCanMint;
    

    function _setMintableOption(bool _anyoneCanMint) internal {

        anyoneCanMint = _anyoneCanMint;
    }

    function mint(address to, uint256 tokenId)
        public
        onlyMinter
        returns (bool)
    {

        _mint(to, tokenId);
        return true;
    }

    function canIMint() public view returns (bool) {

        return anyoneCanMint || isMinter(msg.sender);
    }

    modifier onlyMinter() {

        string memory mensaje;
        require(
            canIMint(),
            "MinterRole: caller does not have the Minter role"
        );
        _;
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

}

contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}

contract ERC721Metadata is ERC165, ERC721, IERC721Metadata {

    string private _name;

    string private _symbol;

    bool public opened;

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

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        if (opened) {
            return _tokenURIs[tokenId];
        } else {
            return "https://nftstorage.link/ipfs/bafkreibtcne3eh64i2qggvmwded2o3hn42xch34fwed5awxkkmd7a6vu24";
        }
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }
}

contract ERC721MetadataMintable is ERC721, ERC721Metadata, MinterRole {

    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public onlyMinter returns (bool) {

        return _mintWithTokenURI(to, tokenId, tokenURI);
    }

    function _mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) internal returns (bool) {

        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    } 
}


contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata, ERC721Mintable, ERC721MetadataMintable {


    uint256 autoTokenId;
    constructor (string memory name, string memory symbol, bool _anyoneCanMint) public 
        ERC721Mintable() 
        ERC721Metadata(name, symbol) {

        _setMintableOption(_anyoneCanMint);

    }

    function exists(uint256 tokenId) public view returns (bool) {

        return _exists(tokenId);
    }

    function tokensOfOwner(address owner) public view returns (uint256[] memory) {

        return _tokensOfOwner(owner);
    }

    function setTokenURI(uint256 tokenId, string memory uri) public {

        _setTokenURI(tokenId, uri);
    }

    function autoMint(string memory tokenURI, address to) public onlyMinter returns (uint256) {

        do {
            autoTokenId++;
        } while(_exists(autoTokenId));
        _mint(to, autoTokenId);
        _setTokenURI(autoTokenId, tokenURI);
        return autoTokenId;
    }

    function transfer(
        address to,
        uint256 tokenId
    ) public {

        _transferFrom(msg.sender, to, tokenId);
    }

}

contract ReentrancyGuard {

    uint256 private _guardCounter;

    constructor () internal {
        _guardCounter = 1;
    }

    modifier nonReentrant() {

        _guardCounter += 1;
        uint256 localCounter = _guardCounter;
        _;
        require(localCounter == _guardCounter, "ReentrancyGuard: reentrant call");
    }
}


contract BananaTaskForceApeNft is ERC721Full, ReentrancyGuard {


    using SafeMath for uint256;

    using Address for address payable;

    address payable admin;

    address public contract_owner;

    uint256 commissionRate;

    mapping(uint256 => uint256) public soldFor;
    
    mapping(uint256 => uint256) public sellBidPrice;

    mapping(uint256 => address payable) private _wallets;

    event Sale(uint256 indexed tokenId, address indexed from, address indexed to, uint256 value);
    event Commission(uint256 indexed tokenId, address indexed to, uint256 value, uint256 rate, uint256 total);


    struct Auction {

        address payable beneficiary;
        uint auctionEnd;

        address payable highestBidder;
        uint highestBid;

        bool open;

        uint256 reserve;

    }

    mapping(uint256 => Auction) public auctions;

    event Refund(address bidder, uint amount);
    event HighestBidIncreased(address indexed bidder, uint amount, uint256 tokenId);
    event AuctionEnded(address winner, uint amount);

    event LimitSell(address indexed from, address indexed to, uint256 amount);
    event LimitBuy(address indexed from, address indexed to, uint256 amount);
    event MarketSell(address indexed from, address indexed to, uint256 amount);
    event MarketBuy(address indexed from, address indexed to, uint256 amount);


    constructor() public 
        ERC721Full("Banana Task Force Ape", "BTFA", false) {
        admin = 0x024cd9a40a7f780d9F3582496A5f3c00bb22c3C6;
        contract_owner = msg.sender;
        commissionRate = 15;

        onlyWhitelist = true;
        whitelistLimit = 10;
        buyLimit = 5;
        reserveLimit = 500;

        cost = 99 * 10 ** 15;
        total = 10000;
        remaining = 10000;
    }

    function canSell(uint256 tokenId) public view returns (bool) {

        return (ownerOf(tokenId)==msg.sender && !auctions[tokenId].open);
    }

    function sell(uint256 tokenId, uint256 price, address payable wallet) public {


        require(ownerOf(tokenId)==msg.sender, "ERC721Matcha: Only owner can sell this item");

        require(!auctions[tokenId].open, "ERC721Matcha: Cannot sell an item which has an active auction");

        sellBidPrice[tokenId] = price;

        if (price>0) {

            approve(address(this), tokenId);
            
            _wallets[tokenId] = wallet;
            
        }

    }

    function getPrice(uint256 tokenId) public view returns (uint256, uint256, uint256) {

        if (sellBidPrice[tokenId]>0) return (sellBidPrice[tokenId], 0, 0);
        if (auctions[tokenId].highestBid>0) return (0, auctions[tokenId].highestBid, 0);
        return (0, 0, soldFor[tokenId]);
    }

    function canBuy(uint256 tokenId) public view returns (uint256) {

        if (!auctions[tokenId].open && sellBidPrice[tokenId]>0 && sellBidPrice[tokenId]>0 && getApproved(tokenId) == address(this)) {
            return sellBidPrice[tokenId];
        } else {
            return 0;
        }
    }

    function buy(uint256 tokenId) public payable nonReentrant {


        require(!auctions[tokenId].open && sellBidPrice[tokenId]>0, "ERC721Matcha: The collectible is not for sale");

        require(msg.value >= sellBidPrice[tokenId], "ERC721Matcha: Not enough funds");

        address owner = ownerOf(tokenId);

        require(msg.sender!=owner, "ERC721Matcha: The seller cannot buy his own collectible");

        callOptionalReturn(this, abi.encodeWithSelector(this.transferFrom.selector, owner, msg.sender, tokenId));

        uint256 amount4admin = msg.value.mul(commissionRate).div(100);
        uint256 amount4owner = msg.value.sub(amount4admin);

        (bool success, ) = _wallets[tokenId].call.value(amount4owner)("");
        require(success, "Transfer failed.");

        (bool success2, ) = admin.call.value(amount4admin)("");
        require(success2, "Transfer failed.");

        sellBidPrice[tokenId] = 0;
        _wallets[tokenId] = address(0);

        soldFor[tokenId] = msg.value;

        emit Sale(tokenId, owner, msg.sender, msg.value);
        emit Commission(tokenId, owner, msg.value, commissionRate, amount4admin);

    }

    function canAuction(uint256 tokenId) public view returns (bool) {

        return (ownerOf(tokenId)==msg.sender && !auctions[tokenId].open && sellBidPrice[tokenId]==0);
    }

    function createAuction(uint256 tokenId, uint _closingTime, address payable _beneficiary, uint256 _reservePrice) public {


        require(sellBidPrice[tokenId]==0, "ERC721Matcha: The selected NFT is open for sale, cannot be auctioned");
        require(!auctions[tokenId].open, "ERC721Matcha: The selected NFT already has an auction");
        require(ownerOf(tokenId)==msg.sender, "ERC721Matcha: Only owner can auction this item");

        auctions[tokenId].beneficiary = _beneficiary;
        auctions[tokenId].auctionEnd = _closingTime;
        auctions[tokenId].reserve = _reservePrice;
        auctions[tokenId].open = true;

        approve(address(this), tokenId);

    }

    function canBid(uint256 tokenId) public view returns (bool) {

        if (!msg.sender.isContract() &&
            auctions[tokenId].open &&
            now <= auctions[tokenId].auctionEnd &&
            msg.sender != ownerOf(tokenId) &&
            getApproved(tokenId) == address(this)
        ) {
            return true;
        } else {
            return false;
        }
    }

    function bid(uint256 tokenId) public payable nonReentrant {


        require(!msg.sender.isContract(), "No script kiddies");

        require(auctions[tokenId].open, "No opened auction found");

        require(getApproved(tokenId) == address(this), "Cannot complete the auction");

        require(
            now <= auctions[tokenId].auctionEnd,
            "Auction already ended."
        );

        require(
            msg.value > auctions[tokenId].highestBid,
            "There already is a higher bid."
        );

        address owner = ownerOf(tokenId);
        require(msg.sender!=owner, "ERC721Matcha: The owner cannot bid his own collectible");

        if (auctions[tokenId].highestBid>0) {
            (bool success, ) = auctions[tokenId].highestBidder.call.value(auctions[tokenId].highestBid)("");
            require(success, "Transfer failed.");
            emit Refund(auctions[tokenId].highestBidder, auctions[tokenId].highestBid);
        }

        auctions[tokenId].highestBidder = msg.sender;
        auctions[tokenId].highestBid = msg.value;
        emit HighestBidIncreased(msg.sender, msg.value, tokenId);

    }

    function canWithdraw(uint256 tokenId) public view returns (bool) {

        if (auctions[tokenId].open && 
            (
                (
                    now >= auctions[tokenId].auctionEnd &&
                    auctions[tokenId].highestBid > 0 &&
                    auctions[tokenId].highestBid<auctions[tokenId].reserve
                ) || 
                getApproved(tokenId) != address(this)
            )
        ) {
            return true;
        } else {
            return false;
        }
    }

    function withdraw(uint256 tokenId) public nonReentrant returns (bool) {


        require(canWithdraw(tokenId), "Conditions to withdraw are not met");

        if (auctions[tokenId].highestBid > 0) {
            (bool success, ) = auctions[tokenId].highestBidder.call.value(auctions[tokenId].highestBid)("");
            require(success, "Transfer failed.");
        }

        delete auctions[tokenId];

    }

    function canFinalize(uint256 tokenId) public view returns (bool) {

        if (auctions[tokenId].open && 
            now >= auctions[tokenId].auctionEnd &&
            (
                auctions[tokenId].highestBid>=auctions[tokenId].reserve || 
                auctions[tokenId].highestBid==0
            )
        ) {
            return true;
        } else {
            return false;
        }
    }

    function auctionFinalize(uint256 tokenId) public nonReentrant {


        require(canFinalize(tokenId), "Cannot finalize");

        if (auctions[tokenId].highestBid>0) {

            address payable highestBidder = auctions[tokenId].highestBidder;

            uint256 amount4admin = auctions[tokenId].highestBid.mul(commissionRate).div(100);
            uint256 amount4owner = auctions[tokenId].highestBid.sub(amount4admin);

            (bool success, ) = auctions[tokenId].beneficiary.call.value(amount4owner)("");
            require(success, "Transfer failed.");

            (bool success2, ) = admin.call.value(amount4admin)("");
            require(success2, "Transfer failed.");

            emit Sale(tokenId, auctions[tokenId].beneficiary, highestBidder, auctions[tokenId].highestBid);
            emit Commission(tokenId, auctions[tokenId].beneficiary, auctions[tokenId].highestBid, commissionRate, amount4admin);

            address owner = ownerOf(tokenId);

            callOptionalReturn(this, abi.encodeWithSelector(this.transferFrom.selector, owner, highestBidder, tokenId));

            soldFor[tokenId] = auctions[tokenId].highestBid;

        }

        emit AuctionEnded(auctions[tokenId].highestBidder, auctions[tokenId].highestBid);

        delete auctions[tokenId];

    }

    function highestBidder(uint256 tokenId) public view returns (address payable) {

        return auctions[tokenId].highestBidder;
    }

    function highestBid(uint256 tokenId) public view returns (uint256) {

        return auctions[tokenId].highestBid;
    }

    function callOptionalReturn(IERC721 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC721: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC721: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC721: ERC20 operation did not succeed");
        }
    }


    bool public enabled;
    uint256 public reserved;
    uint256 public reserveLimit;
    bool public onlyWhitelist;
    uint256 public whitelistLimit;
    uint256 public buyLimit;

    uint256 public totalCreated;
    mapping(address => uint256[]) private ownerBoxes;
    mapping(address => bool) public whitelist;

    uint private nonce = 0;

    uint256 cost;
    uint256 total;
    uint256 remaining;

    struct Blindbox {
        uint256 id;
        address purchaser;
        uint256 tokenID;
    }

    modifier onlyOwner() {

        require(msg.sender == contract_owner, "can only be called by the contract owner");
        _;
    }

    modifier isEnabled() {

        require(enabled, "Contract is currently disabled");
        _;
    }

    function status() public view returns (bool canPurchase, uint256 boxCost, uint256 boxRemaining, uint256 hasPurchased, uint256 purchaseLimit) {

        canPurchase = enabled && ((onlyWhitelist == false && ownerBoxes[msg.sender].length < buyLimit) || (whitelist[msg.sender] && ownerBoxes[msg.sender].length < whitelistLimit));
        boxCost = cost;
        boxRemaining = remaining;
        hasPurchased = ownerBoxes[msg.sender].length;
        purchaseLimit = whitelistLimit;
    }

    function purchaseBlindbox() public payable isEnabled {

        require (remaining > 0, "No more blindboxes available");
        require((onlyWhitelist == false && ownerBoxes[msg.sender].length < buyLimit) || (whitelist[msg.sender] && ownerBoxes[msg.sender].length < whitelistLimit), "You are not on the whitelist");
        require (msg.value == cost, "Incorrect BNB value.");

        admin.transfer(cost);

        mint(msg.sender);
    }



    function mint(address who) private {

        uint256 request = requestRandomWords();
        uint256 roll = request.mod(total).add(1);

        while (exists(roll)) {
            roll++;

            if (roll > total) {
                roll = 1;
            }
        }

        string memory uri = string(abi.encodePacked("https://nftstorage.link/ipfs/bafybeic2hzyfaxo7gvezfnllsgxusjpb6rj6s77vru34yhbnghdjkxv3xe/", uint2str(roll), ".json"));
        remaining--;
        require(_mintWithTokenURI(who, roll, uri), "Minting error");
        ownerBoxes[who].push(roll);
    }

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {

        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function requestRandomWords() private returns (uint256) {

        nonce += 1;
        return uint(keccak256(abi.encodePacked(nonce, msg.sender, blockhash(block.number - 1))));
    }



    function updateAdmin(address payable _admin, uint256 _commissionRate, bool _anyoneCanMint) public onlyOwner {

        admin=_admin;
        commissionRate=_commissionRate;
        anyoneCanMint=_anyoneCanMint;
    }

    function changeOwner(address who) external onlyOwner {

        contract_owner = who;
    } 

    function openBoxes() external onlyOwner {

        opened = true;
    } 

    function setPrice(uint256 price) external onlyOwner {

        cost = price;
    }

    function setEnabled(bool canPurchase) external onlyOwner {

        enabled = canPurchase;
    }

    function enableWhitelist(bool on) external onlyOwner {

        onlyWhitelist = on;
    }

    function setWhitelist(address who, bool whitelisted) external onlyOwner {

        whitelist[who] = whitelisted;
    }

    function setWhitelisted(address[] calldata who, bool whitelisted) external onlyOwner {

        for (uint256 i = 0; i < who.length; i++) {
            whitelist[who[i]] = whitelisted;
        }
    }

    function setBuyLimits(uint256 white, uint256 normal) external onlyOwner {

        whitelistLimit = white;
        buyLimit = normal;
    }

    function reserveNfts(address who, uint256 amount) external onlyOwner {

        require(reserved + amount <= reserveLimit, "NFTS have already been reserved");

        for (uint256 i = 0; i < amount; i++) {
            mint(who);
        }

        reserved += amount;
    }

}