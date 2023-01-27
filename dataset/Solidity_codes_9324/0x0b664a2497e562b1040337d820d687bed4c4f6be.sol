

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

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;

library Roles {

    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {

        require(!has(role, account), "Roles: account already has role");
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {

        require(has(role, account), "Roles: account does not have role");
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {

        require(account != address(0), "Roles: account is the zero address");
        return role.bearer[account];
    }
}


pragma solidity ^0.5.0;




contract MinterRole is Initializable, Context {

    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    function initialize(address sender) public initializer {

        if (!isMinter(sender)) {
            _addMinter(sender);
        }
    }

    modifier onlyMinter() {

        require(isMinter(_msgSender()), "MinterRole: caller does not have the Minter role");
        _;
    }

    function isMinter(address account) public view returns (bool) {

        return _minters.has(account);
    }

    function addMinter(address account) public onlyMinter {

        _addMinter(account);
    }

    function renounceMinter() public {

        _removeMinter(_msgSender());
    }

    function _addMinter(address account) internal {

        _minters.add(account);
        emit MinterAdded(account);
    }

    function _removeMinter(address account) internal {

        _minters.remove(account);
        emit MinterRemoved(account);
    }

    uint256[50] private ______gap;
}


pragma solidity ^0.5.0;





contract ERC721MetadataMintable is Initializable, ERC721, ERC721Metadata, MinterRole {

    function initialize(address sender) public initializer {

        require(ERC721._hasBeenInitialized());
        require(ERC721Metadata._hasBeenInitialized());
        MinterRole.initialize(sender);
    }

    function mintWithTokenURI(address to, uint256 tokenId, string memory tokenURI) public onlyMinter returns (bool) {

        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    }

    uint256[50] private ______gap;
}


pragma solidity 0.5.16;





contract ERC721Patronage_v1 is
    Initializable,
    ERC721,
    ERC721Enumerable,
    ERC721Metadata,
    ERC721MetadataMintable
{

    address public steward;

    function setup(
        address _steward,
        string memory name,
        string memory symbol,
        address minter
    ) public initializer {

        steward = _steward;
        ERC721.initialize();
        ERC721Enumerable.initialize();
        ERC721Metadata.initialize(name, symbol);
        ERC721MetadataMintable.initialize(address(this));
        _removeMinter(address(this));
        _addMinter(minter);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {

        return (spender == steward);
    }





}


pragma solidity ^0.5.0;

contract IERC20Mintable {

    function mint(address account, uint256 amount) public returns (bool);

}


pragma solidity 0.5.16;



contract MintManager_v2 is Initializable {

    using SafeMath for uint256;

    address public admin;
    address public steward;
    IERC20Mintable public token;

    modifier onlySteward() {

        require(msg.sender == steward, "Not steward");
        _;
    }



    function initialize(address _admin, address _steward, address _token)
        public
        initializer
    {

        admin = _admin;
        steward = _steward;
        token = IERC20Mintable(_token);
    }

    function tokenMint(address receiverOfTokens, uint256 time, uint256 mintRate)
        external
        onlySteward
    {

        uint256 amountToMintForUser = time.mul(mintRate);
        uint256 amountToMintForTreasury = amountToMintForUser.mul(20).div(100);
        token.mint(receiverOfTokens, amountToMintForUser);
        token.mint(admin, amountToMintForTreasury);
    }
}


pragma solidity 0.5.16;




contract WildcardSteward_v2 is Initializable {

    using SafeMath for uint256;

    mapping(uint256 => uint256) public price; //in wei
    ERC721Patronage_v1 public assetToken; // ERC721 NFT.

    mapping(uint256 => uint256) public totalCollected; // all patronage ever collected
    mapping(uint256 => uint256) public currentCollected; // amount currently collected for patron
    mapping(uint256 => uint256) public timeLastCollected;
    mapping(address => uint256) public timeLastCollectedPatron;
    mapping(address => uint256) public deposit;
    mapping(address => uint256) public totalPatronOwnedTokenCost;

    mapping(uint256 => address) public benefactors; // non-profit benefactor
    mapping(address => uint256) public benefactorFunds;

    mapping(uint256 => address) public currentPatron; // This is different to the current token owner.
    mapping(uint256 => mapping(address => bool)) public patrons;
    mapping(uint256 => mapping(address => uint256)) public timeHeld;

    mapping(uint256 => uint256) public timeAcquired;

    mapping(uint256 => uint256) public patronageNumerator;
    uint256 public patronageDenominator;

    enum StewardState {Foreclosed, Owned}
    mapping(uint256 => StewardState) public state;

    address public admin;

    mapping(uint256 => uint256) public tokenGenerationRate; // we can reuse the patronage denominator

    MintManager_v2 public mintManager;

    event Buy(uint256 indexed tokenId, address indexed owner, uint256 price);
    event PriceChange(uint256 indexed tokenId, uint256 newPrice);
    event Foreclosure(address indexed prevOwner, uint256 foreclosureTime);
    event RemainingDepositUpdate(
        address indexed tokenPatron,
        uint256 remainingDeposit
    );

    event AddToken(
        uint256 indexed tokenId,
        uint256 patronageNumerator,
        uint256 tokenGenerationRate
    );
    event CollectPatronage(
        uint256 indexed tokenId,
        address indexed patron,
        uint256 remainingDeposit,
        uint256 amountReceived
    );
    event CollectLoyalty(
        uint256 indexed tokenId,
        address indexed patron,
        uint256 amountRecieved
    );

    modifier onlyPatron(uint256 tokenId) {

        require(msg.sender == currentPatron[tokenId], "Not patron");
        _;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "Not admin");
        _;
    }


    modifier onlyReceivingBenefactorOrAdmin(uint256 tokenId) {

        require(
            msg.sender == benefactors[tokenId] || msg.sender == admin,
            "Not benefactor or admin"
        );
        _;
    }

    modifier collectPatronage(uint256 tokenId) {

        _collectPatronage(tokenId);
        _;
    }

    modifier collectPatronageAddress(address tokenPatron) {

        _collectPatronagePatron(tokenPatron);
        _;
    }

    function initialize(
        address _assetToken,
        address _admin,
        uint256 _patronageDenominator
    ) public initializer {

        assetToken = ERC721Patronage_v1(_assetToken);
        admin = _admin;
        patronageDenominator = _patronageDenominator;
    }

    function listNewTokens(
        uint256[] memory tokens,
        address payable[] memory _benefactors,
        uint256[] memory _patronageNumerator,
        uint256[] memory _tokenGenerationRate
    ) public onlyAdmin {

        assert(tokens.length == _benefactors.length);
        assert(tokens.length == _patronageNumerator.length);
        assert(tokens.length == _tokenGenerationRate.length);

        for (uint8 i = 0; i < tokens.length; ++i) {
            assert(_benefactors[i] != address(0));
            benefactors[tokens[i]] = _benefactors[i];
            state[tokens[i]] = StewardState.Foreclosed; // TODO: Maybe Implement reverse dutch auction on intial sale
            patronageNumerator[tokens[i]] = _patronageNumerator[i];
            tokenGenerationRate[tokens[i]] = _tokenGenerationRate[i];
            emit AddToken(
                tokens[i],
                _patronageNumerator[i],
                _tokenGenerationRate[i]
            );
        }
    }

    function addTokenGenerationRateToExistingTokens(
        uint256[] memory tokens,
        uint256[] memory _tokenGenerationRate
    ) internal {

        assert(tokens.length == _tokenGenerationRate.length);
        for (uint8 i = 0; i < tokens.length; ++i) {
            assert(tokenGenerationRate[tokens[i]] == 0);

            tokenGenerationRate[tokens[i]] = _tokenGenerationRate[i];
        }
    }

    function setMintManager(address _mintManager) public {

        require(
            address(mintManager) == address(0),
            "Only set on initialisation"
        ); // This can only be called once!
        mintManager = MintManager_v2(_mintManager);
    }

    function updateToV2(
        address _mintManager,
        uint256[] memory tokens,
        uint256[] memory _tokenGenerationRate
    ) public {

        setMintManager(_mintManager);
        addTokenGenerationRateToExistingTokens(tokens, _tokenGenerationRate);
    }

    function changeReceivingBenefactor(
        uint256 tokenId,
        address payable _newReceivingBenefactor
    ) public onlyReceivingBenefactorOrAdmin(tokenId) {

        address oldBenfactor = benefactors[tokenId];
        benefactors[tokenId] = _newReceivingBenefactor;
        benefactorFunds[_newReceivingBenefactor] = benefactorFunds[oldBenfactor];
        benefactorFunds[oldBenfactor] = 0;
    }

    function changeAdmin(address _admin) public onlyAdmin {

        admin = _admin;
    }

    function patronageOwed(uint256 tokenId)
        public
        view
        returns (uint256 patronageDue)
    {

        if (timeLastCollected[tokenId] == 0) return 0;

        return
            price[tokenId]
                .mul(now.sub(timeLastCollected[tokenId]))
                .mul(patronageNumerator[tokenId])
                .div(patronageDenominator)
                .div(365 days);
    }

    function patronageOwedWithTimestamp(uint256 tokenId)
        public
        view
        returns (uint256 patronageDue, uint256 timestamp)
    {

        return (patronageOwed(tokenId), now);
    }

    function patronageOwedPatron(address tokenPatron)
        public
        view
        returns (uint256 patronageDue)
    {

        if (timeLastCollectedPatron[tokenPatron] == 0) return 0;

        return
            totalPatronOwnedTokenCost[tokenPatron]
                .mul(now.sub(timeLastCollectedPatron[tokenPatron]))
                .div(patronageDenominator)
                .div(365 days);
    }

    function patronageOwedPatronWithTimestamp(address tokenPatron)
        public
        view
        returns (uint256 patronageDue, uint256 timestamp)
    {

        return (patronageOwedPatron(tokenPatron), now);
    }

    function foreclosedPatron(address tokenPatron) public view returns (bool) {

        if (patronageOwedPatron(tokenPatron) >= deposit[tokenPatron]) {
            return true;
        } else {
            return false;
        }
    }

    function foreclosed(uint256 tokenId) public view returns (bool) {

        address tokenPatron = currentPatron[tokenId];
        return foreclosedPatron(tokenPatron);
    }

    function depositAbleToWithdraw(address tokenPatron)
        public
        view
        returns (uint256)
    {

        uint256 collection = patronageOwedPatron(tokenPatron);
        if (collection >= deposit[tokenPatron]) {
            return 0;
        } else {
            return deposit[tokenPatron].sub(collection);
        }
    }

    function foreclosureTimePatron(address tokenPatron)
        public
        view
        returns (uint256)
    {

        uint256 pps = totalPatronOwnedTokenCost[tokenPatron]
            .div(patronageDenominator)
            .div(365 days);
        return now.add(depositAbleToWithdraw(tokenPatron).div(pps)); // zero division if price is zero.
    }

    function foreclosureTime(uint256 tokenId) public view returns (uint256) {

        address tokenPatron = currentPatron[tokenId];
        return foreclosureTimePatron(tokenPatron);
    }

    function _collectLoyalty(uint256 tokenId) internal {

        address currentOwner = currentPatron[tokenId];
        uint256 previousTokenCollection = timeLastCollected[tokenId];
        uint256 patronageOwedByTokenPatron = patronageOwedPatron(currentOwner);
        uint256 timeSinceLastMint;

        if (patronageOwedByTokenPatron >= deposit[currentOwner]) {
            uint256 newTimeLastCollected = timeLastCollectedPatron[currentOwner]
                .add(
                (
                    (now.sub(timeLastCollectedPatron[currentOwner]))
                        .mul(deposit[currentOwner])
                        .div(patronageOwedByTokenPatron)
                )
            );
            timeSinceLastMint = (
                newTimeLastCollected.sub(previousTokenCollection)
            );
        } else {
            timeSinceLastMint = now.sub(timeLastCollected[tokenId]);
        }
        mintManager.tokenMint(
            currentOwner,
            timeSinceLastMint,
            tokenGenerationRate[tokenId]
        );
        emit CollectLoyalty(tokenId, currentOwner, timeSinceLastMint);
    }

    function _collectPatronage(uint256 tokenId) public {

        if (state[tokenId] == StewardState.Owned) {
            address currentOwner = currentPatron[tokenId];
            uint256 previousTokenCollection = timeLastCollected[tokenId];
            uint256 patronageOwedByTokenPatron = patronageOwedPatron(
                currentOwner
            );
            _collectLoyalty(tokenId); // This needs to be called before before the token may be foreclosed next section
            uint256 collection;
            if (patronageOwedByTokenPatron >= deposit[currentOwner]) {

                    uint256 newTimeLastCollected
                 = timeLastCollectedPatron[currentOwner].add(
                    (
                        (now.sub(timeLastCollectedPatron[currentOwner]))
                            .mul(deposit[currentOwner])
                            .div(patronageOwedByTokenPatron)
                    )
                );

                timeLastCollected[tokenId] = newTimeLastCollected;
                timeLastCollectedPatron[currentOwner] = newTimeLastCollected;
                collection = price[tokenId]
                    .mul(newTimeLastCollected.sub(previousTokenCollection))
                    .mul(patronageNumerator[tokenId])
                    .div(patronageDenominator)
                    .div(365 days);
                deposit[currentOwner] = 0;
                _foreclose(tokenId);
            } else {
                collection = price[tokenId]
                    .mul(now.sub(previousTokenCollection))
                    .mul(patronageNumerator[tokenId])
                    .div(patronageDenominator)
                    .div(365 days);

                timeLastCollected[tokenId] = now;
                timeLastCollectedPatron[currentOwner] = now;
                currentCollected[tokenId] = currentCollected[tokenId].add(
                    collection
                );
                deposit[currentOwner] = deposit[currentOwner].sub(
                    patronageOwedByTokenPatron
                );
            }
            totalCollected[tokenId] = totalCollected[tokenId].add(collection);
            address benefactor = benefactors[tokenId];
            benefactorFunds[benefactor] = benefactorFunds[benefactor].add(
                collection
            );
            emit CollectPatronage(
                tokenId,
                currentOwner,
                deposit[currentOwner],
                collection
            );
        }
    }

    function _collectPatronagePatron(address tokenPatron) public {

        uint256 patronageOwedByTokenPatron = patronageOwedPatron(tokenPatron);
        if (
            patronageOwedByTokenPatron > 0 &&
            patronageOwedByTokenPatron >= deposit[tokenPatron]
        ) {

                uint256 previousCollectionTime
             = timeLastCollectedPatron[tokenPatron];
            uint256 newTimeLastCollected = previousCollectionTime.add(
                (
                    (now.sub(previousCollectionTime))
                        .mul(deposit[tokenPatron])
                        .div(patronageOwedByTokenPatron)
                )
            );
            timeLastCollectedPatron[tokenPatron] = newTimeLastCollected;
            deposit[tokenPatron] = 0;
        } else {
            timeLastCollectedPatron[tokenPatron] = now;
            deposit[tokenPatron] = deposit[tokenPatron].sub(
                patronageOwedByTokenPatron
            );
        }

        emit RemainingDepositUpdate(tokenPatron, deposit[tokenPatron]);
    }

    function depositWei() public payable {

        depositWeiPatron(msg.sender);
    }

    function depositWeiPatron(address patron) public payable {

        require(totalPatronOwnedTokenCost[patron] > 0, "No tokens owned");
        deposit[patron] = deposit[patron].add(msg.value);
        emit RemainingDepositUpdate(patron, deposit[patron]);
    }

    function buy(uint256 tokenId, uint256 _newPrice)
        public
        payable
        collectPatronage(tokenId)
        collectPatronageAddress(msg.sender)
    {

        require(_newPrice > 0, "Price is zero");
        require(msg.value > price[tokenId], "Not enough"); // >, coz need to have at least something for deposit
        address currentOwner = assetToken.ownerOf(tokenId);
        address tokenPatron = currentPatron[tokenId];

        if (state[tokenId] == StewardState.Owned) {
            uint256 totalToPayBack = price[tokenId];
            if (
                totalPatronOwnedTokenCost[tokenPatron] ==
                price[tokenId].mul(patronageNumerator[tokenId])
            ) {
                totalToPayBack = totalToPayBack.add(deposit[tokenPatron]);
                deposit[tokenPatron] = 0;
            }

            address payable payableCurrentPatron = address(
                uint160(tokenPatron)
            );
            (bool transferSuccess, ) = payableCurrentPatron
                .call
                .gas(2300)
                .value(totalToPayBack)("");
            if (!transferSuccess) {
                deposit[tokenPatron] = deposit[tokenPatron].add(totalToPayBack);
            }
        } else if (state[tokenId] == StewardState.Foreclosed) {
            state[tokenId] = StewardState.Owned;
            timeLastCollected[tokenId] = now;
            timeLastCollectedPatron[msg.sender] = now;
        }

        deposit[msg.sender] = deposit[msg.sender].add(
            msg.value.sub(price[tokenId])
        );
        transferAssetTokenTo(
            tokenId,
            currentOwner,
            tokenPatron,
            msg.sender,
            _newPrice
        );
        emit Buy(tokenId, msg.sender, _newPrice);
    }

    function changePrice(uint256 tokenId, uint256 _newPrice)
        public
        onlyPatron(tokenId)
        collectPatronage(tokenId)
    {

        require(state[tokenId] != StewardState.Foreclosed, "Foreclosed");
        require(_newPrice != 0, "Incorrect Price");

        totalPatronOwnedTokenCost[msg.sender] = totalPatronOwnedTokenCost[msg
            .sender]
            .sub(price[tokenId].mul(patronageNumerator[tokenId]))
            .add(_newPrice.mul(patronageNumerator[tokenId]));

        price[tokenId] = _newPrice;
        emit PriceChange(tokenId, price[tokenId]);
    }

    function withdrawDeposit(uint256 _wei)
        public
        collectPatronageAddress(msg.sender)
        returns (uint256)
    {

        _withdrawDeposit(_wei);
    }

    function withdrawBenefactorFunds() public {

        withdrawBenefactorFundsTo(msg.sender);
    }

    function withdrawBenefactorFundsTo(address payable benefactor) public {

        require(benefactorFunds[benefactor] > 0, "No funds available");
        uint256 amountToWithdraw = benefactorFunds[benefactor];
        benefactorFunds[benefactor] = 0;

        (bool transferSuccess, ) = benefactor.call.gas(2300).value(
            amountToWithdraw
        )("");
        if (!transferSuccess) {
            revert("Unable to withdraw benefactor funds");
        }
    }

    function exit() public collectPatronageAddress(msg.sender) {

        _withdrawDeposit(deposit[msg.sender]);
    }

    function _withdrawDeposit(uint256 _wei) internal {

        require(deposit[msg.sender] >= _wei, "Withdrawing too much");

        deposit[msg.sender] = deposit[msg.sender].sub(_wei);

        (bool transferSuccess, ) = msg.sender.call.gas(2300).value(_wei)("");
        if (!transferSuccess) {
            revert("Unable to withdraw deposit");
        }
    }

    function _foreclose(uint256 tokenId) internal {

        address currentOwner = assetToken.ownerOf(tokenId);
        address tokenPatron = currentPatron[tokenId];
        transferAssetTokenTo(
            tokenId,
            currentOwner,
            tokenPatron,
            address(this),
            0
        );
        state[tokenId] = StewardState.Foreclosed;
        currentCollected[tokenId] = 0;

        emit Foreclosure(currentOwner, timeLastCollected[tokenId]);
    }

    function transferAssetTokenTo(
        uint256 tokenId,
        address _currentOwner,
        address _currentPatron,
        address _newOwner,
        uint256 _newPrice
    ) internal {

        totalPatronOwnedTokenCost[_newOwner] = totalPatronOwnedTokenCost[_newOwner]
            .add(_newPrice.mul(patronageNumerator[tokenId]));
        totalPatronOwnedTokenCost[_currentPatron] = totalPatronOwnedTokenCost[_currentPatron]
            .sub(price[tokenId].mul(patronageNumerator[tokenId]));

        timeHeld[tokenId][_currentPatron] = timeHeld[tokenId][_currentPatron]
            .add((timeLastCollected[tokenId].sub(timeAcquired[tokenId])));
        assetToken.transferFrom(_currentOwner, _newOwner, tokenId);
        currentPatron[tokenId] = _newOwner;

        price[tokenId] = _newPrice;
        timeAcquired[tokenId] = now;
        patrons[tokenId][_newOwner] = true;
    }
}