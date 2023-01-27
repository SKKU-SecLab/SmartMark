pragma solidity ^0.5.0;

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
pragma solidity ^0.5.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}
pragma solidity ^0.5.0;


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
pragma solidity ^0.5.0;

contract IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes memory data)
        public returns (bytes4);

}
pragma solidity ^0.5.0;

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
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
pragma solidity ^0.5.0;


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

        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
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

        require(to != msg.sender, "ERC721: approve to caller");

        _operatorApprovals[msg.sender][to] = approved;
        emit ApprovalForAll(msg.sender, to, approved);
    }

    function isApprovedForAll(address owner, address operator) public view returns (bool) {

        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {

        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        _transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) public {

        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory _data) public {

        transferFrom(from, to, tokenId);
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

        bytes4 retval = IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, _data);
        return (retval == _ERC721_RECEIVED);
    }

    function _clearApproval(uint256 tokenId) private {

        if (_tokenApprovals[tokenId] != address(0)) {
            _tokenApprovals[tokenId] = address(0);
        }
    }
}
pragma solidity ^0.5.0;


contract IERC721Enumerable is IERC721 {

    function totalSupply() public view returns (uint256);

    function tokenOfOwnerByIndex(address owner, uint256 index) public view returns (uint256 tokenId);


    function tokenByIndex(uint256 index) public view returns (uint256);

}
pragma solidity ^0.5.0;


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
pragma solidity ^0.5.0;


contract IERC721Metadata is IERC721 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);

}
pragma solidity ^0.5.0;


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

        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    function _setTokenURI(uint256 tokenId, string memory uri) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = uri;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
pragma solidity ^0.5.0;


contract ERC721Full is ERC721, ERC721Enumerable, ERC721Metadata {

    constructor (string memory name, string memory symbol) public ERC721Metadata(name, symbol) {
    }
}
pragma solidity >=0.5.0 <0.6.0;

contract Controlled {

    event NewController(address controller);
    modifier onlyController {

        require(msg.sender == controller, "Unauthorized");
        _;
    }

    address payable public controller;

    constructor() internal {
        controller = msg.sender;
    }

    function changeController(address payable _newController) public onlyController {

        controller = _newController;
        emit NewController(_newController);
    }
}
pragma solidity >=0.5.0 <0.6.0;


interface ERC20Token {


    function transfer(address _to, uint256 _value) external returns (bool success);


    function approve(address _spender, uint256 _value) external returns (bool success);


    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);


    function balanceOf(address _owner) external view returns (uint256 balance);


    function allowance(address _owner, address _spender) external view returns (uint256 remaining);


    function totalSupply() external view returns (uint256 supply);


    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity >=0.5.0 <0.6.0;


contract TokenClaimer {

    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);

    function claimTokens(address _token) external;

    function withdrawBalance(address _token, address payable _destination)
        internal
    {

        uint256 balance;
        if (_token == address(0)) {
            balance = address(this).balance;
            address(_destination).transfer(balance);
        } else {
            ERC20Token token = ERC20Token(_token);
            balance = token.balanceOf(address(this));
            token.transfer(_destination, balance);
        }
        emit ClaimedTokens(_token, _destination, balance);
    }
}
pragma solidity >=0.5.0 <0.6.0;


contract StickerPack is Controlled, TokenClaimer, ERC721Full("Status Sticker Pack","STKP") {


    mapping(uint256 => uint256) public tokenPackId; //packId
    uint256 public tokenCount; //tokens buys

    function generateToken(address _owner, uint256 _packId)
        external
        onlyController
        returns (uint256 tokenId)
    {

        tokenId = tokenCount++;
        tokenPackId[tokenId] = _packId;
        _mint(_owner, tokenId);
    }

    function claimTokens(address _token)
        external
        onlyController
    {

        withdrawBalance(_token, controller);
    }



}pragma solidity >=0.5.0 <0.6.0;


contract StickerType is Controlled, TokenClaimer, ERC721Full("Status Sticker Pack Authorship","STKA") {

    using SafeMath for uint256;
    event Register(uint256 indexed packId, uint256 dataPrice, bytes contenthash, bool mintable);
    event PriceChanged(uint256 indexed packId, uint256 dataPrice);
    event MintabilityChanged(uint256 indexed packId, bool mintable);
    event ContenthashChanged(uint256 indexed packid, bytes contenthash);
    event Categorized(bytes4 indexed category, uint256 indexed packId);
    event Uncategorized(bytes4 indexed category, uint256 indexed packId);
    event Unregister(uint256 indexed packId);

    struct Pack {
        bytes4[] category;
        bool mintable;
        uint256 timestamp;
        uint256 price; //in "wei"
        uint256 donate; //in "percent"
        bytes contenthash;
    }

    uint256 registerFee;
    uint256 burnRate;

    mapping(uint256 => Pack) public packs;
    uint256 public packCount; //pack registers


    mapping(bytes4 => uint256[]) private availablePacks; //array of available packs
    mapping(bytes4 => mapping(uint256 => uint256)) private availablePacksIndex; //position on array of available packs
    mapping(uint256 => mapping(bytes4 => uint256)) private packCategoryIndex;

    modifier packOwner(uint256 _packId) {

        address owner = ownerOf(_packId);
        require((msg.sender == owner) || (owner != address(0) && msg.sender == controller), "Unauthorized");
        _;
    }

    function generatePack(
        uint256 _price,
        uint256 _donate,
        bytes4[] calldata _category,
        address _owner,
        bytes calldata _contenthash
    )
        external
        onlyController
        returns(uint256 packId)
    {

        require(_donate <= 10000, "Bad argument, _donate cannot be more then 100.00%");
        packId = packCount++;
        _mint(_owner, packId);
        packs[packId] = Pack(new bytes4[](0), true, block.timestamp, _price, _donate, _contenthash);
        emit Register(packId, _price, _contenthash, true);
        for(uint i = 0;i < _category.length; i++){
            addAvailablePack(packId, _category[i]);
        }
    }

    function purgePack(uint256 _packId, uint256 _limit)
        external
        onlyController
    {

        bytes4[] memory _category = packs[_packId].category;
        uint limit;
        if(_limit == 0) {
            limit = _category.length;
        } else {
            require(_limit <= _category.length, "Bad limit");
            limit = _limit;
        }

        uint256 len = _category.length;
        if(len > 0){
            len--;
        }
        for(uint i = 0; i < limit; i++){
            removeAvailablePack(_packId, _category[len-i]);
        }

        if(packs[_packId].category.length == 0){
            _burn(ownerOf(_packId), _packId);
            delete packs[_packId];
            emit Unregister(_packId);
        }

    }

    function setPackContenthash(uint256 _packId, bytes calldata _contenthash)
        external
        onlyController
    {

        emit ContenthashChanged(_packId, _contenthash);
        packs[_packId].contenthash = _contenthash;
    }

    function claimTokens(address _token)
        external
        onlyController
    {

        withdrawBalance(_token, controller);
    }

    function setPackPrice(uint256 _packId, uint256 _price, uint256 _donate)
        external
        packOwner(_packId)
    {

        require(_donate <= 10000, "Bad argument, _donate cannot be more then 100.00%");
        emit PriceChanged(_packId, _price);
        packs[_packId].price = _price;
        packs[_packId].donate = _donate;
    }

    function addPackCategory(uint256 _packId, bytes4 _category)
        external
        packOwner(_packId)
    {

        addAvailablePack(_packId, _category);
    }

    function removePackCategory(uint256 _packId, bytes4 _category)
        external
        packOwner(_packId)
    {

        removeAvailablePack(_packId, _category);
    }

    function setPackState(uint256 _packId, bool _mintable)
        external
        packOwner(_packId)
    {

        emit MintabilityChanged(_packId, _mintable);
        packs[_packId].mintable = _mintable;
    }

    function getAvailablePacks(bytes4 _category)
        external
        view
        returns (uint256[] memory availableIds)
    {

        return availablePacks[_category];
    }

    function getCategoryLength(bytes4 _category)
        external
        view
        returns (uint256 size)
    {

        size = availablePacks[_category].length;
    }

    function getCategoryPack(bytes4 _category, uint256 _index)
        external
        view
        returns (uint256 packId)
    {

        packId = availablePacks[_category][_index];
    }

    function getPackData(uint256 _packId)
        external
        view
        returns (
            bytes4[] memory category,
            address owner,
            bool mintable,
            uint256 timestamp,
            uint256 price,
            bytes memory contenthash
        )
    {

        Pack memory pack = packs[_packId];
        return (
            pack.category,
            ownerOf(_packId),
            pack.mintable,
            pack.timestamp,
            pack.price,
            pack.contenthash
        );
    }

    function getPackSummary(uint256 _packId)
        external
        view
        returns (
            bytes4[] memory category,
            uint256 timestamp,
            bytes memory contenthash
        )
    {

        Pack memory pack = packs[_packId];
        return (
            pack.category,
            pack.timestamp,
            pack.contenthash
        );
    }

    function getPaymentData(uint256 _packId)
        external
        view
        returns (
            address owner,
            bool mintable,
            uint256 price,
            uint256 donate
        )
    {

        Pack memory pack = packs[_packId];
        return (
            ownerOf(_packId),
            pack.mintable,
            pack.price,
            pack.donate
        );
    }

    function addAvailablePack(uint256 _packId, bytes4 _category) private {

        require(packCategoryIndex[_packId][_category] == 0, "Duplicate categorization");
        availablePacksIndex[_category][_packId] = availablePacks[_category].push(_packId);
        packCategoryIndex[_packId][_category] = packs[_packId].category.push(_category);
        emit Categorized(_category, _packId);
    }

    function removeAvailablePack(uint256 _packId, bytes4 _category) private {

        uint pos = availablePacksIndex[_category][_packId];
        require(pos > 0, "Not categorized [1]");
        delete availablePacksIndex[_category][_packId];
        if(pos != availablePacks[_category].length){
            uint256 movedElement = availablePacks[_category][availablePacks[_category].length-1]; //tokenId;
            availablePacks[_category][pos-1] = movedElement;
            availablePacksIndex[_category][movedElement] = pos;
        }
        availablePacks[_category].length--;

        uint pos2 = packCategoryIndex[_packId][_category];
        require(pos2 > 0, "Not categorized [2]");
        delete packCategoryIndex[_packId][_category];
        if(pos2 != packs[_packId].category.length){
            bytes4 movedElement2 = packs[_packId].category[packs[_packId].category.length-1]; //tokenId;
            packs[_packId].category[pos2-1] = movedElement2;
            packCategoryIndex[_packId][movedElement2] = pos2;
        }
        packs[_packId].category.length--;
        emit Uncategorized(_category, _packId);

    }

}pragma solidity >=0.5.0 <0.6.0;

interface ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 _amount, address _token, bytes calldata _data) external;

}
pragma solidity >=0.5.0 <0.6.0;


contract StickerMarket is Controlled, TokenClaimer, ApproveAndCallFallBack {

    using SafeMath for uint256;
    
    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);
    event MarketState(State state);
    event RegisterFee(uint256 value);
    event BurnRate(uint256 value);

    enum State { Invalid, Open, BuyOnly, Controlled, Closed }

    State public state = State.Open;
    uint256 registerFee;
    uint256 burnRate;
    
    ERC20Token public snt; //payment token
    StickerPack public stickerPack;
    StickerType public stickerType;
    
    modifier marketManagement {

        require(state == State.Open || (msg.sender == controller && state == State.Controlled), "Market Disabled");
        _;
    }

    modifier marketSell {

        require(state == State.Open || state == State.BuyOnly || (msg.sender == controller && state == State.Controlled), "Market Disabled");
        _;
    }

    constructor(
        ERC20Token _snt,
        StickerPack _stickerPack,
        StickerType _stickerType
    ) 
        public
    { 
        require(address(_snt) != address(0), "Bad _snt parameter");
        require(address(_stickerPack) != address(0), "Bad _stickerPack parameter");
        require(address(_stickerType) != address(0), "Bad _stickerType parameter");
        snt = _snt;
        stickerPack = _stickerPack;
        stickerType = _stickerType;
    }

    function buyToken(
        uint256 _packId,
        address _destination,
        uint256 _price
    ) 
        external  
        returns (uint256 tokenId)
    {

        return buy(msg.sender, _packId, _destination, _price);
    }

    function registerPack(
        uint256 _price,
        uint256 _donate,
        bytes4[] calldata _category, 
        address _owner,
        bytes calldata _contenthash,
        uint256 _fee
    ) 
        external  
        returns(uint256 packId)
    {

        packId = register(msg.sender, _category, _owner, _price, _donate, _contenthash, _fee);
    }

    function receiveApproval(
        address _from,
        uint256 _value,
        address _token,
        bytes calldata _data
    ) 
        external 
    {

        require(_token == address(snt), "Bad token");
        require(_token == address(msg.sender), "Bad call");
        bytes4 sig = abiDecodeSig(_data);
        bytes memory cdata = slice(_data,4,_data.length-4);
        if(sig == this.buyToken.selector){
            require(cdata.length == 96, "Bad data length");
            (uint256 packId, address owner, uint256 price) = abi.decode(cdata, (uint256, address, uint256));
            require(_value == price, "Bad price value");
            buy(_from, packId, owner, price);
        } else if(sig == this.registerPack.selector) {
            require(cdata.length >= 188, "Bad data length");
            (uint256 price, uint256 donate, bytes4[] memory category, address owner, bytes memory contenthash, uint256 fee) = abi.decode(cdata, (uint256,uint256,bytes4[],address,bytes,uint256));
            require(_value == fee, "Bad fee value");
            register(_from, category, owner, price, donate, contenthash, fee);
        } else {
            revert("Bad call");
        }
    }

    function setMarketState(State _state)
        external
        onlyController 
    {

        state = _state;
        emit MarketState(_state);
    }

    function setRegisterFee(uint256 _value)
        external
        onlyController 
    {

        registerFee = _value;
        emit RegisterFee(_value);
    }

    function setBurnRate(uint256 _value)
        external
        onlyController 
    {

        burnRate = _value;
        require(_value <= 10000, "cannot be more then 100.00%");
        emit BurnRate(_value);
    }
    
    function generatePack(
        uint256 _price,
        uint256 _donate,
        bytes4[] calldata _category, 
        address _owner,
        bytes calldata _contenthash
    ) 
        external  
        onlyController
        returns(uint256 packId)
    {

        packId = stickerType.generatePack(_price, _donate, _category, _owner, _contenthash);
    }

    function purgePack(uint256 _packId, uint256 _limit)
        external
        onlyController 
    {

        stickerType.purgePack(_packId, _limit);
    }

    function generateToken(address _owner, uint256 _packId) 
        external
        onlyController 
        returns (uint256 tokenId)
    {

        return stickerPack.generateToken(_owner, _packId);
    }

    function migrate(address payable _newController) 
        external
        onlyController 
    {

        require(_newController != address(0), "Cannot unset controller");
        stickerType.changeController(_newController);
        stickerPack.changeController(_newController);
    }

    function claimTokens(address _token) 
        external
        onlyController 
    {

        withdrawBalance(_token, controller);
    }

    function getTokenData(uint256 _tokenId) 
        external 
        view 
        returns (
            bytes4[] memory category,
            uint256 timestamp,
            bytes memory contenthash
        ) 
    {

        return stickerType.getPackSummary(stickerPack.tokenPackId(_tokenId));
    }

    function register(
        address _caller,
        bytes4[] memory _category,
        address _owner,
        uint256 _price,
        uint256 _donate,
        bytes memory _contenthash,
        uint256 _fee
    ) 
        internal 
        marketManagement
        returns(uint256 packId) 
    {

        require(_fee == registerFee, "Unexpected fee");
        if(registerFee > 0){
            require(snt.transferFrom(_caller, controller, registerFee), "Bad payment");
        }
        packId = stickerType.generatePack(_price, _donate, _category, _owner, _contenthash);
    }

    function buy(
        address _caller,
        uint256 _packId,
        address _destination,
        uint256 _price
    ) 
        internal 
        marketSell
        returns (uint256 tokenId)
    {

        (
            address pack_owner,
            bool pack_mintable,
            uint256 pack_price,
            uint256 pack_donate
        ) = stickerType.getPaymentData(_packId);
        require(pack_owner != address(0), "Bad pack");
        require(pack_mintable, "Disabled");
        uint256 amount = pack_price;
        require(_price == amount, "Wrong price");
        require(amount > 0, "Unauthorized");
        if(amount > 0 && burnRate > 0) {
            uint256 burned = amount.mul(burnRate).div(10000);
            amount = amount.sub(burned);
            require(snt.transferFrom(_caller, Controlled(address(snt)).controller(), burned), "Bad burn");
        }
        if(amount > 0 && pack_donate > 0) {
            uint256 donate = amount.mul(pack_donate).div(10000);
            amount = amount.sub(donate);
            require(snt.transferFrom(_caller, controller, donate), "Bad donate");
        } 
        if(amount > 0) {
            require(snt.transferFrom(_caller, pack_owner, amount), "Bad payment");
        }
        return stickerPack.generateToken(_destination, _packId);
    }

    function abiDecodeSig(bytes memory _data) private pure returns(bytes4 sig){

        assembly {
            sig := mload(add(_data, add(0x20, 0)))
        }
    }

    function slice(bytes memory _bytes, uint _start, uint _length) private pure returns (bytes memory) {

        require(_bytes.length >= (_start + _length));

        bytes memory tempBytes;

        assembly {
            switch iszero(_length)
            case 0 {
                tempBytes := mload(0x40)

                let lengthmod := and(_length, 31)

                let mc := add(add(tempBytes, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, _length)

                for {
                    let cc := add(add(add(_bytes, lengthmod), mul(0x20, iszero(lengthmod))), _start)
                } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } {
                    mstore(mc, mload(cc))
                }

                mstore(tempBytes, _length)

                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                tempBytes := mload(0x40)

                mstore(0x40, add(tempBytes, 0x20))
            }
        }

        return tempBytes;
    }


    event Register(uint256 indexed packId, uint256 dataPrice, bytes contenthash);
      event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed value
    );
}pragma solidity >=0.5.0 <0.6.0;


contract ERC20Receiver {


    event TokenDeposited(address indexed token, address indexed sender, uint256 amount);
    event TokenWithdrawn(address indexed token, address indexed sender, uint256 amount);

    mapping (address => mapping(address => uint256)) tokenBalances;

    constructor() public {
    }

    function depositToken(
        ERC20Token _token
    )
        external
    {

        _depositToken(
            msg.sender,
            _token,
            _token.allowance(
                msg.sender,
                address(this)
            )
        );
    }

    function withdrawToken(
        ERC20Token _token,
        uint256 _amount
    )
        external
    {

        _withdrawToken(msg.sender, _token, _amount);
    }

    function depositToken(
        ERC20Token _token,
        uint256 _amount
    )
        external
    {

        require(_token.allowance(msg.sender, address(this)) >= _amount, "Bad argument");
        _depositToken(msg.sender, _token, _amount);
    }

    function tokenBalanceOf(
        ERC20Token _token,
        address _from
    )
        external
        view
        returns(uint256 fromTokenBalance)
    {

        return tokenBalances[address(_token)][_from];
    }

    function _depositToken(
        address _from,
        ERC20Token _token,
        uint256 _amount
    )
        private
    {

        require(_amount > 0, "Bad argument");
        if (_token.transferFrom(_from, address(this), _amount)) {
            tokenBalances[address(_token)][_from] += _amount;
            emit TokenDeposited(address(_token), _from, _amount);
        }
    }

    function _withdrawToken(
        address _from,
        ERC20Token _token,
        uint256 _amount
    )
        private
    {

        require(_amount > 0, "Bad argument");
        require(tokenBalances[address(_token)][_from] >= _amount, "Insufficient funds");
        tokenBalances[address(_token)][_from] -= _amount;
        require(_token.transfer(_from, _amount), "Transfer fail");
        emit TokenWithdrawn(address(_token), _from, _amount);
    }

}pragma solidity ^0.5.0;


contract IERC721Full is IERC721, IERC721Enumerable, IERC721Metadata {

}
