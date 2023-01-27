

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

    string private _baseURI;

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

        string memory _tokenURI = _tokenURIs[tokenId];

        if (bytes(_tokenURI).length == 0) {
            return "";
        } else {
            return string(abi.encodePacked(_baseURI, _tokenURI));
        }
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal {

        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _setBaseURI(string memory baseURI) internal {

        _baseURI = baseURI;
    }

    function baseURI() external view returns (string memory) {

        return _baseURI;
    }

    function _burn(address owner, uint256 tokenId) internal {

        super._burn(owner, tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }

    uint256[49] private ______gap;
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


pragma solidity 0.5.17;






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


pragma solidity 0.5.17;




contract MintManager_v2 is Initializable {

    using SafeMath for uint256;

    address public admin;
    address public steward;
    IERC20Mintable public token;

    modifier onlySteward() {

        require(msg.sender == steward, "Not steward");
        _;
    }

    function initialize(
        address _admin,
        address _steward,
        address _token
    ) public initializer {

        admin = _admin;
        steward = _steward;
        token = IERC20Mintable(_token);
    }

    function tokenMint(
        address receiverOfTokens,
        uint256 time,
        uint256 mintRate
    ) external onlySteward {

        uint256 amountToMintForUser = time.mul(mintRate);
        uint256 amountToMintForTreasury = amountToMintForUser.mul(20).div(100);
        token.mint(receiverOfTokens, amountToMintForUser);
        token.mint(admin, amountToMintForTreasury);
    }
}


pragma solidity 0.5.17;


contract WildcardSteward_v3 is Initializable {

    using SafeMath for uint256;
    mapping(uint256 => uint256) public price; //in wei
    ERC721Patronage_v1 public assetToken; // ERC721 NFT.

    mapping(uint256 => uint256) deprecated_totalCollected; // THIS VALUE IS DEPRECATED
    mapping(uint256 => uint256) deprecated_currentCollected; // THIS VALUE IS DEPRECATED
    mapping(uint256 => uint256) deprecated_timeLastCollected; // THIS VALUE IS DEPRECATED.
    mapping(address => uint256) public timeLastCollectedPatron;
    mapping(address => uint256) public deposit;
    mapping(address => uint256) public totalPatronOwnedTokenCost;

    mapping(uint256 => address) public benefactors; // non-profit benefactor
    mapping(address => uint256) public benefactorFunds;

    mapping(uint256 => address) deprecated_currentPatron; // Deprecate This is different to the current token owner.
    mapping(uint256 => mapping(address => bool)) deprecated_patrons; // Deprecate
    mapping(uint256 => mapping(address => uint256)) deprecated_timeHeld; // Deprecate

    mapping(uint256 => uint256) deprecated_timeAcquired; // deprecate

    mapping(uint256 => uint256) public patronageNumerator;
    uint256 public patronageDenominator;

    enum StewardState {Foreclosed, Owned}
    mapping(uint256 => StewardState) public state;

    address public admin;

    mapping(uint256 => uint256) deprecated_tokenGenerationRate; // we can reuse the patronage denominator

    MintManager_v2 public mintManager;
    uint256 public auctionStartPrice;
    uint256 public auctionEndPrice;
    uint256 public auctionLength;

    mapping(uint256 => address) public artistAddresses; //mapping from tokenID to the artists address
    mapping(uint256 => uint256) public wildcardsPercentages; // mapping from tokenID to the percentage sale cut of wildcards for each token
    mapping(uint256 => uint256) public artistPercentages; // tokenId to artist percetages. To make it configurable. 10 000 = 100%
    mapping(uint256 => uint256) public tokenAuctionBeginTimestamp;

    mapping(address => uint256) public totalPatronTokenGenerationRate; // The total token generation rate for all the tokens of the given address.
    mapping(address => uint256) public totalBenefactorTokenNumerator;
    mapping(address => uint256) public timeLastCollectedBenefactor; // make my name consistent please
    mapping(address => uint256) public benefactorCredit;
    address public withdrawCheckerAdmin;


    uint256 public constant globalTokenGenerationRate = 11574074074074;
    uint256 public constant yearTimePatronagDenominator = 31536000000000000000;

    event Buy(uint256 indexed tokenId, address indexed owner, uint256 price);
    event PriceChange(uint256 indexed tokenId, uint256 newPrice);
    event Foreclosure(address indexed prevOwner, uint256 foreclosureTime);
    event RemainingDepositUpdate(
        address indexed tokenPatron,
        uint256 remainingDeposit
    );

    event AddTokenV3(
        uint256 indexed tokenId,
        uint256 patronageNumerator,
        uint256 unixTimestampOfTokenAuctionStart
    );

    event CollectPatronage(
        uint256 indexed tokenId,
        address indexed patron,
        uint256 remainingDeposit,
        uint256 amountReceived
    );
    event CollectLoyalty(address indexed patron, uint256 amountRecieved);

    event ArtistCommission(
        uint256 indexed tokenId,
        address artist,
        uint256 artistCommission
    );
    event WithdrawBenefactorFundsWithSafetyDelay(
        address indexed benefactor,
        uint256 withdrawAmount
    );
    event WithdrawBenefactorFunds(
        address indexed benefactor,
        uint256 withdrawAmount
    );
    event UpgradeToV3();
    event ChangeAuctionParameters();

    modifier onlyPatron(uint256 tokenId) {

        require(msg.sender == assetToken.ownerOf(tokenId), "Not patron");
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

    modifier collectPatronageAndSettleBenefactor(uint256 tokenId) {

        _collectPatronageAndSettleBenefactor(tokenId);
        _;
    }

    modifier collectPatronagePatron(address tokenPatron) {

        _collectPatronagePatron(tokenPatron);
        _;
    }

    modifier youCurrentlyAreNotInDefault(address tokenPatron) {

        require(
            !(deposit[tokenPatron] == 0 &&
                totalPatronOwnedTokenCost[tokenPatron] > 0),
            "no deposit existing tokens"
        );
        _;
    }

    modifier updateBenefactorBalance(address benefactor) {

        _updateBenefactorBalance(benefactor);
        _;
    }

    modifier priceGreaterThanZero(uint256 _newPrice) {

        require(_newPrice > 0, "Price is zero");
        _;
    }
    modifier notNullAddress(address checkAddress) {

        require(checkAddress != address(0), "null address");
        _;
    }
    modifier notSameAddress(address firstAddress, address secondAddress) {

        require(firstAddress != secondAddress, "cannot be same address");
        _;
    }
    modifier validWildcardsPercentage(
        uint256 wildcardsPercentage,
        uint256 tokenID
    ) {

        require(
            wildcardsPercentage >= 50000 &&
                wildcardsPercentage <= (1000000 - artistPercentages[tokenID]), // not sub safemath. Is this okay?
            "wildcards commision not between 5% and 100%"
        );
        _;
    }

    function initialize(
        address _assetToken,
        address _admin,
        address _mintManager,
        address _withdrawCheckerAdmin,
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionLength
    ) public initializer {

        assetToken = ERC721Patronage_v1(_assetToken);
        admin = _admin;
        withdrawCheckerAdmin = _withdrawCheckerAdmin;
        mintManager = MintManager_v2(_mintManager);
        _changeAuctionParameters(
            _auctionStartPrice,
            _auctionEndPrice,
            _auctionLength
        );
    }

    function uintToStr(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {

        if (_i == 0) {
            return "0";
        }

        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }

        bytes memory bstr = new bytes(len);
        while (_i != 0) {
            bstr[--len] = bytes1(uint8(48 + (_i % 10)));
            _i /= 10;
        }
        return string(bstr);
    }

    function listNewTokens(
        uint256[] memory tokens,
        address payable[] memory _benefactors,
        uint256[] memory _patronageNumerator,
        address[] memory _artists,
        uint256[] memory _artistCommission,
        uint256[] memory _releaseDate
    ) public onlyAdmin {

        assert(tokens.length == _benefactors.length);
        assert(tokens.length == _patronageNumerator.length);
        assert(tokens.length == _releaseDate.length);
        assert(_artists.length == _artistCommission.length);

        for (uint8 i = 0; i < tokens.length; ++i) {
            address benefactor = _benefactors[i];
            require(_benefactors[i] != address(0), "null address");
            string memory idString = uintToStr(tokens[i]);
            string memory tokenUriBase = "https://wildcards.xyz/token/";
            string memory tokenUri = string(
                abi.encodePacked(tokenUriBase, idString)
            );
            assetToken.mintWithTokenURI(address(this), tokens[i], tokenUri);
            benefactors[tokens[i]] = _benefactors[i];
            state[tokens[i]] = StewardState.Foreclosed;
            patronageNumerator[tokens[i]] = _patronageNumerator[i];

            if (_releaseDate[i] < now) {
                tokenAuctionBeginTimestamp[tokens[i]] = now;
            } else {
                tokenAuctionBeginTimestamp[tokens[i]] = _releaseDate[i];
            }

            emit AddTokenV3(
                tokens[i],
                _patronageNumerator[i],
                tokenAuctionBeginTimestamp[tokens[i]]
            );
            if (_artists.length > i) {
                changeArtistAddressAndCommission(
                    tokens[i],
                    _artists[i],
                    _artistCommission[i]
                );
            }
        }
    }

    function upgradeToV3(
        uint256[] memory tokens,
        address _withdrawCheckerAdmin,
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionLength
    ) public notNullAddress(_withdrawCheckerAdmin) {

        emit UpgradeToV3();
        require(withdrawCheckerAdmin == address(0));
        withdrawCheckerAdmin = _withdrawCheckerAdmin;
        for (uint8 i = 0; i < tokens.length; ++i) {
            uint256 tokenId = tokens[i];
            address currentOwner = assetToken.ownerOf(tokenId);

            uint256 timeSinceTokenLastCollection = now.sub(
                deprecated_timeLastCollected[tokenId]
            );

            uint256 collection = price[tokenId]
                .mul(timeSinceTokenLastCollection)
                .mul(patronageNumerator[tokenId])
                .div(yearTimePatronagDenominator);

            if (timeLastCollectedPatron[currentOwner] < now) {
                deposit[currentOwner] = deposit[currentOwner].sub(
                    patronageOwedPatron(currentOwner)
                );

                timeLastCollectedPatron[currentOwner] = now;
            }

            benefactorFunds[benefactors[tokenId]] = benefactorFunds[benefactors[tokenId]]
                .add(collection);

            emit CollectPatronage(
                tokenId,
                currentOwner,
                deposit[currentOwner],
                collection
            );

            mintManager.tokenMint(
                currentOwner,
                timeSinceTokenLastCollection, // this should always be > 0
                globalTokenGenerationRate // instead of this -> tokenGenerationRate[tokenId] hard code to save gas
            );
            emit CollectLoyalty(
                currentOwner,
                timeSinceTokenLastCollection.mul(globalTokenGenerationRate)
            ); // OPTIMIZE ME

            totalPatronTokenGenerationRate[currentOwner] = totalPatronTokenGenerationRate[currentOwner]
                .add(globalTokenGenerationRate);

            address tokenBenefactor = benefactors[tokenId];
            totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
                .add(price[tokenId].mul(patronageNumerator[tokenId]));

            if (timeLastCollectedBenefactor[tokenBenefactor] == 0) {
                timeLastCollectedBenefactor[tokenBenefactor] = now;
            }
        }
        _changeAuctionParameters(
            _auctionStartPrice,
            _auctionEndPrice,
            _auctionLength
        );
    }

    function changeReceivingBenefactor(
        uint256 tokenId,
        address payable _newReceivingBenefactor
    )
        public
        onlyReceivingBenefactorOrAdmin(tokenId)
        updateBenefactorBalance(benefactors[tokenId])
        updateBenefactorBalance(_newReceivingBenefactor)
        notNullAddress(_newReceivingBenefactor)
    {

        address oldBenfactor = benefactors[tokenId];

        require(
            oldBenfactor != _newReceivingBenefactor,
            "cannot be same address"
        );

        uint256 scaledPrice = price[tokenId].mul(patronageNumerator[tokenId]);
        totalBenefactorTokenNumerator[oldBenfactor] = totalBenefactorTokenNumerator[oldBenfactor]
            .sub(scaledPrice);
        totalBenefactorTokenNumerator[_newReceivingBenefactor] = totalBenefactorTokenNumerator[_newReceivingBenefactor]
            .add(scaledPrice);

        benefactors[tokenId] = _newReceivingBenefactor;
    }

    function changeReceivingBenefactorDeposit(
        address oldBenfactor,
        address payable _newReceivingBenefactor
    )
        public
        onlyAdmin
        notNullAddress(_newReceivingBenefactor)
        notSameAddress(oldBenfactor, _newReceivingBenefactor)
    {

        require(benefactorFunds[oldBenfactor] > 0, "no funds");

        benefactorFunds[_newReceivingBenefactor] = benefactorFunds[_newReceivingBenefactor]
            .add(benefactorFunds[oldBenfactor]);
        benefactorFunds[oldBenfactor] = 0;
    }

    function changeAdmin(address _admin) public onlyAdmin {

        admin = _admin;
    }

    function changeWithdrawCheckerAdmin(address _withdrawCheckerAdmin)
        public
        onlyAdmin
        notNullAddress(_withdrawCheckerAdmin)
    {

        withdrawCheckerAdmin = _withdrawCheckerAdmin;
    }

    function changeArtistAddressAndCommission(
        uint256 tokenId,
        address artistAddress,
        uint256 percentage
    ) public onlyAdmin {

        require(percentage <= 200000, "not more than 20%");
        artistPercentages[tokenId] = percentage;
        artistAddresses[tokenId] = artistAddress;
        emit ArtistCommission(tokenId, artistAddress, percentage);
    }

    function _changeAuctionParameters(
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionLength
    ) internal {

        require(
            _auctionStartPrice >= _auctionEndPrice,
            "auction start < auction end"
        );
        require(_auctionLength >= 86400, "1 day min auction length");

        auctionStartPrice = _auctionStartPrice;
        auctionEndPrice = _auctionEndPrice;
        auctionLength = _auctionLength;
        emit ChangeAuctionParameters();
    }

    function changeAuctionParameters(
        uint256 _auctionStartPrice,
        uint256 _auctionEndPrice,
        uint256 _auctionLength
    ) external onlyAdmin {

        _changeAuctionParameters(
            _auctionStartPrice,
            _auctionEndPrice,
            _auctionLength
        );
    }

    function patronageOwedPatron(address tokenPatron)
        public
        view
        returns (uint256 patronageDue)
    {

        return
            totalPatronOwnedTokenCost[tokenPatron]
                .mul(now.sub(timeLastCollectedPatron[tokenPatron]))
                .div(yearTimePatronagDenominator);
    }

    function patronageDueBenefactor(address benefactor)
        public
        view
        returns (uint256 payoutDue)
    {

        return
            totalBenefactorTokenNumerator[benefactor]
                .mul(now.sub(timeLastCollectedBenefactor[benefactor]))
                .div(yearTimePatronagDenominator);
    }

    function foreclosedPatron(address tokenPatron) public view returns (bool) {

        if (patronageOwedPatron(tokenPatron) >= deposit[tokenPatron]) {
            return true;
        } else {
            return false;
        }
    }

    function foreclosed(uint256 tokenId) public view returns (bool) {

        address tokenPatron = assetToken.ownerOf(tokenId);
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

        uint256 pps = totalPatronOwnedTokenCost[tokenPatron].div(
            yearTimePatronagDenominator
        );
        return now.add(depositAbleToWithdraw(tokenPatron).div(pps));
    }

    function foreclosureTime(uint256 tokenId) public view returns (uint256) {

        address tokenPatron = assetToken.ownerOf(tokenId);
        return foreclosureTimePatron(tokenPatron);
    }

    function _collectLoyaltyPatron(
        address tokenPatron,
        uint256 timeSinceLastMint
    ) internal {

        if (timeSinceLastMint != 0) {
            mintManager.tokenMint(
                tokenPatron,
                timeSinceLastMint,
                totalPatronTokenGenerationRate[tokenPatron]
            );
            emit CollectLoyalty(
                tokenPatron,
                timeSinceLastMint.mul(
                    totalPatronTokenGenerationRate[tokenPatron]
                )
            );
        }
    }


    function _collectPatronageAndSettleBenefactor(uint256 tokenId) public {

        address tokenPatron = assetToken.ownerOf(tokenId);
        uint256 newTimeLastCollectedOnForeclosure = _collectPatronagePatron(
            tokenPatron
        );

        address benefactor = benefactors[tokenId];
        bool tokenIsOwned = state[tokenId] == StewardState.Owned;
        if (newTimeLastCollectedOnForeclosure > 0 && tokenIsOwned) {
            tokenAuctionBeginTimestamp[tokenId] =
                newTimeLastCollectedOnForeclosure +
                1;


                uint256 patronageDueBenefactorBeforeForeclosure
             = patronageDueBenefactor(benefactor);

            _foreclose(tokenId);

            uint256 amountOverCredited = price[tokenId]
                .mul(now.sub(newTimeLastCollectedOnForeclosure))
                .mul(patronageNumerator[tokenId])
                .div(yearTimePatronagDenominator);

            if (amountOverCredited < patronageDueBenefactorBeforeForeclosure) {
                _increaseBenefactorBalance(
                    benefactor,
                    patronageDueBenefactorBeforeForeclosure - amountOverCredited
                );
            } else {
                _decreaseBenefactorBalance(
                    benefactor,
                    amountOverCredited - patronageDueBenefactorBeforeForeclosure
                );
            }

            timeLastCollectedBenefactor[benefactor] = now;
        } else {
            _updateBenefactorBalance(benefactor);
        }
    }

    function safeSend(uint256 _wei, address payable recipient)
        internal
        returns (bool transferSuccess)
    {

        (transferSuccess, ) = recipient.call.gas(2300).value(_wei)("");
    }


    function _updateBenefactorBalance(address benefactor) public {

        uint256 patronageDueBenefactor = patronageDueBenefactor(benefactor);

        if (patronageDueBenefactor > 0) {
            _increaseBenefactorBalance(benefactor, patronageDueBenefactor);
        }

        timeLastCollectedBenefactor[benefactor] = now;
    }

    function _increaseBenefactorBalance(
        address benefactor,
        uint256 patronageDueBenefactor
    ) internal {

        if (benefactorCredit[benefactor] > 0) {
            if (patronageDueBenefactor < benefactorCredit[benefactor]) {
                benefactorCredit[benefactor] = benefactorCredit[benefactor].sub(
                    patronageDueBenefactor
                );
            } else {
                benefactorFunds[benefactor] = patronageDueBenefactor.sub(
                    benefactorCredit[benefactor]
                );
                benefactorCredit[benefactor] = 0;
            }
        } else {
            benefactorFunds[benefactor] = benefactorFunds[benefactor].add(
                patronageDueBenefactor
            );
        }
    }

    function _decreaseBenefactorBalance(
        address benefactor,
        uint256 amountOverCredited
    ) internal {

        if (benefactorFunds[benefactor] > 0) {
            if (amountOverCredited <= benefactorFunds[benefactor]) {
                benefactorFunds[benefactor] = benefactorFunds[benefactor].sub(
                    amountOverCredited
                );
            } else {
                benefactorCredit[benefactor] = amountOverCredited.sub(
                    benefactorFunds[benefactor]
                );
                benefactorFunds[benefactor] = 0;
            }
        } else {
            benefactorCredit[benefactor] = benefactorCredit[benefactor].add(
                amountOverCredited
            );
        }
    }

    function fundsDueForAuctionPeriodAtCurrentRate(address benefactor)
        internal
        view
        returns (uint256)
    {

        return
            totalBenefactorTokenNumerator[benefactor].mul(auctionLength).div(
                yearTimePatronagDenominator
            ); // 365 days * 1000000000000
    }

    function withdrawBenefactorFundsTo(address payable benefactor) public {

        _updateBenefactorBalance(benefactor);

        uint256 availableToWithdraw = benefactorFunds[benefactor];


            uint256 benefactorWithdrawalSafetyDiscount
         = fundsDueForAuctionPeriodAtCurrentRate(benefactor);

        require(
            availableToWithdraw > benefactorWithdrawalSafetyDiscount,
            "no funds"
        );

        uint256 amountToWithdraw = availableToWithdraw -
            benefactorWithdrawalSafetyDiscount;

        benefactorFunds[benefactor] = benefactorWithdrawalSafetyDiscount;
        if (safeSend(amountToWithdraw, benefactor)) {
            emit WithdrawBenefactorFundsWithSafetyDelay(
                benefactor,
                amountToWithdraw
            );
        } else {
            benefactorFunds[benefactor] = benefactorFunds[benefactor].add(
                amountToWithdraw
            );
        }
    }

    function hasher(
        address benefactor,
        uint256 maxAmount,
        uint256 expiry
    ) public view returns (bytes32) {

        return
            keccak256(
                abi.encodePacked(
                    "\x19Ethereum Signed Message:\n32",
                    keccak256(abi.encodePacked(benefactor, maxAmount, expiry))
                )
            );
    }

    function withdrawBenefactorFundsToValidated(
        address payable benefactor,
        uint256 maxAmount,
        uint256 expiry,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {

        require(
            ecrecover(hash, v, r, s) == withdrawCheckerAdmin,
            "no permission to withdraw"
        );
        require(
            hash == hasher(benefactor, maxAmount, expiry),
            "incorrect hash"
        );
        require(now < expiry, "coupon expired");

        _updateBenefactorBalance(benefactor);

        uint256 availableToWithdraw = benefactorFunds[benefactor];

        if (availableToWithdraw > 0) {
            if (availableToWithdraw > maxAmount) {
                if (safeSend(maxAmount, benefactor)) {
                    benefactorFunds[benefactor] = availableToWithdraw.sub(
                        maxAmount
                    );
                    emit WithdrawBenefactorFunds(
                        benefactor,
                        availableToWithdraw
                    );
                }
            } else {
                if (safeSend(availableToWithdraw, benefactor)) {
                    benefactorFunds[benefactor] = 0;
                    emit WithdrawBenefactorFunds(
                        benefactor,
                        availableToWithdraw
                    );
                }
            }
        }
    }

    function _collectPatronagePatron(address tokenPatron)
        public
        returns (uint256 newTimeLastCollectedOnForeclosure)
    {

        uint256 patronageOwedByTokenPatron = patronageOwedPatron(tokenPatron);

        uint256 timeSinceLastMint;

        if (
            patronageOwedByTokenPatron > 0 &&
            patronageOwedByTokenPatron > deposit[tokenPatron]
        ) {

                uint256 previousCollectionTime
             = timeLastCollectedPatron[tokenPatron];
            newTimeLastCollectedOnForeclosure = previousCollectionTime.add(
                (
                    (now.sub(previousCollectionTime))
                        .mul(deposit[tokenPatron])
                        .div(patronageOwedByTokenPatron)
                )
            );
            timeLastCollectedPatron[tokenPatron] = newTimeLastCollectedOnForeclosure;
            deposit[tokenPatron] = 0;
            timeSinceLastMint = (
                newTimeLastCollectedOnForeclosure.sub(previousCollectionTime)
            );
        } else {
            timeSinceLastMint = now.sub(timeLastCollectedPatron[tokenPatron]);
            timeLastCollectedPatron[tokenPatron] = now;
            deposit[tokenPatron] = deposit[tokenPatron].sub(
                patronageOwedByTokenPatron
            );
        }

        _collectLoyaltyPatron(tokenPatron, timeSinceLastMint);
        emit RemainingDepositUpdate(tokenPatron, deposit[tokenPatron]);
    }

    function depositWei() public payable {

        depositWeiPatron(msg.sender);
    }

    function depositWeiPatron(address patron) public payable {

        require(totalPatronOwnedTokenCost[patron] > 0, "no tokens");
        deposit[patron] = deposit[patron].add(msg.value);
        emit RemainingDepositUpdate(patron, deposit[patron]);
    }

    function _auctionPrice(uint256 tokenId) internal view returns (uint256) {

        uint256 auctionEnd = tokenAuctionBeginTimestamp[tokenId].add(
            auctionLength
        );

        uint256 _auctionStartPrice;
        if (price[tokenId] != 0 && price[tokenId] > auctionEndPrice) {
            _auctionStartPrice = price[tokenId];
        } else {
            _auctionStartPrice = auctionStartPrice;
        }

        if (now >= auctionEnd) {
            return auctionEndPrice;
        } else {
            return
                _auctionStartPrice.sub(
                    (_auctionStartPrice.sub(auctionEndPrice))
                        .mul(now.sub(tokenAuctionBeginTimestamp[tokenId]))
                        .div(auctionLength)
                );
        }
    }

    function buy(
        uint256 tokenId,
        uint256 _newPrice,
        uint256 previousPrice,
        uint256 wildcardsPercentage
    )
        public
        payable
        collectPatronageAndSettleBenefactor(tokenId)
        collectPatronagePatron(msg.sender)
        priceGreaterThanZero(_newPrice)
        youCurrentlyAreNotInDefault(msg.sender)
        validWildcardsPercentage(wildcardsPercentage, tokenId)
    {

        require(state[tokenId] == StewardState.Owned, "token on auction");
        require(
            price[tokenId] == previousPrice,
            "must specify current price accurately"
        );

        _distributePurchaseProceeds(tokenId);

        wildcardsPercentages[tokenId] = wildcardsPercentage;
        uint256 remainingValueForDeposit = msg.value.sub(price[tokenId]);
        deposit[msg.sender] = deposit[msg.sender].add(remainingValueForDeposit);
        transferAssetTokenTo(
            tokenId,
            assetToken.ownerOf(tokenId),
            msg.sender,
            _newPrice
        );
        emit Buy(tokenId, msg.sender, _newPrice);
    }

    function buyAuction(
        uint256 tokenId,
        uint256 _newPrice,
        uint256 wildcardsPercentage
    )
        public
        payable
        collectPatronageAndSettleBenefactor(tokenId)
        collectPatronagePatron(msg.sender)
        priceGreaterThanZero(_newPrice)
        youCurrentlyAreNotInDefault(msg.sender)
        validWildcardsPercentage(wildcardsPercentage, tokenId)
    {

        require(
            state[tokenId] == StewardState.Foreclosed,
            "token not foreclosed"
        );
        require(now >= tokenAuctionBeginTimestamp[tokenId], "not on auction");
        uint256 auctionTokenPrice = _auctionPrice(tokenId);
        uint256 remainingValueForDeposit = msg.value.sub(auctionTokenPrice);

        _distributeAuctionProceeds(tokenId);

        state[tokenId] = StewardState.Owned;

        wildcardsPercentages[tokenId] = wildcardsPercentage;
        deposit[msg.sender] = deposit[msg.sender].add(remainingValueForDeposit);
        transferAssetTokenTo(
            tokenId,
            assetToken.ownerOf(tokenId),
            msg.sender,
            _newPrice
        );
        emit Buy(tokenId, msg.sender, _newPrice);
    }

    function _distributeAuctionProceeds(uint256 tokenId) internal {

        uint256 totalAmount = price[tokenId];
        uint256 artistAmount;
        if (artistPercentages[tokenId] == 0) {
            artistAmount = 0;
        } else {
            artistAmount = totalAmount.mul(artistPercentages[tokenId]).div(
                1000000
            );
            deposit[artistAddresses[tokenId]] = deposit[artistAddresses[tokenId]]
                .add(artistAmount);
        }
        uint256 wildcardsAmount = totalAmount.sub(artistAmount);
        deposit[admin] = deposit[admin].add(wildcardsAmount);
    }

    function _distributePurchaseProceeds(uint256 tokenId) internal {

        uint256 totalAmount = price[tokenId];
        address tokenPatron = assetToken.ownerOf(tokenId);
        if (wildcardsPercentages[tokenId] == 0) {
            wildcardsPercentages[tokenId] = 50000;
        }
        uint256 wildcardsAmount = totalAmount
            .mul(wildcardsPercentages[tokenId])
            .div(1000000);

        uint256 artistAmount;
        if (artistPercentages[tokenId] == 0) {
            artistAmount = 0;
        } else {
            artistAmount = totalAmount.mul(artistPercentages[tokenId]).div(
                1000000
            );
            deposit[artistAddresses[tokenId]] = deposit[artistAddresses[tokenId]]
                .add(artistAmount);
        }

        uint256 previousOwnerProceedsFromSale = totalAmount
            .sub(wildcardsAmount)
            .sub(artistAmount);
        if (
            totalPatronOwnedTokenCost[tokenPatron] ==
            price[tokenId].mul(patronageNumerator[tokenId])
        ) {
            previousOwnerProceedsFromSale = previousOwnerProceedsFromSale.add(
                deposit[tokenPatron]
            );
            deposit[tokenPatron] = 0;
            address payable payableCurrentPatron = address(
                uint160(tokenPatron)
            );
            (bool transferSuccess, ) = payableCurrentPatron
                .call
                .gas(2300)
                .value(previousOwnerProceedsFromSale)("");
            if (!transferSuccess) {
                deposit[tokenPatron] = deposit[tokenPatron].add(
                    previousOwnerProceedsFromSale
                );
            }
        } else {
            deposit[tokenPatron] = deposit[tokenPatron].add(
                previousOwnerProceedsFromSale
            );
        }

        deposit[admin] = deposit[admin].add(wildcardsAmount);
    }

    function changePrice(uint256 tokenId, uint256 _newPrice)
        public
        onlyPatron(tokenId)
        collectPatronageAndSettleBenefactor(tokenId)
    {

        require(state[tokenId] != StewardState.Foreclosed, "foreclosed");
        require(_newPrice != 0, "incorrect price");
        require(_newPrice < 10000 ether, "exceeds max price");

        uint256 oldPriceScaled = price[tokenId].mul(
            patronageNumerator[tokenId]
        );
        uint256 newPriceScaled = _newPrice.mul(patronageNumerator[tokenId]);
        address tokenBenefactor = benefactors[tokenId];

        totalPatronOwnedTokenCost[msg.sender] = totalPatronOwnedTokenCost[msg
            .sender]
            .sub(oldPriceScaled)
            .add(newPriceScaled);

        totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
            .sub(oldPriceScaled)
            .add(newPriceScaled);

        price[tokenId] = _newPrice;
        emit PriceChange(tokenId, price[tokenId]);
    }

    function withdrawDeposit(uint256 _wei)
        public
        collectPatronagePatron(msg.sender)
        returns (uint256)
    {

        _withdrawDeposit(_wei);
    }

    function withdrawBenefactorFunds() public {

        withdrawBenefactorFundsTo(msg.sender);
    }

    function exit() public collectPatronagePatron(msg.sender) {

        _withdrawDeposit(deposit[msg.sender]);
    }

    function _withdrawDeposit(uint256 _wei) internal {

        require(deposit[msg.sender] >= _wei, "withdrawing too much");

        deposit[msg.sender] = deposit[msg.sender].sub(_wei);

        (bool transferSuccess, ) = msg.sender.call.gas(2300).value(_wei)("");
        if (!transferSuccess) {
            revert("withdrawal failed");
        }
    }

    function _foreclose(uint256 tokenId) internal {

        address currentOwner = assetToken.ownerOf(tokenId);
        resetTokenOnForeclosure(tokenId, currentOwner);
        state[tokenId] = StewardState.Foreclosed;

        emit Foreclosure(currentOwner, timeLastCollectedPatron[currentOwner]);
    }

    function transferAssetTokenTo(
        uint256 tokenId,
        address _currentOwner,
        address _newOwner,
        uint256 _newPrice
    ) internal {

        require(_newPrice < 10000 ether, "exceeds max price");

        uint256 scaledOldPrice = price[tokenId].mul(
            patronageNumerator[tokenId]
        );
        uint256 scaledNewPrice = _newPrice.mul(patronageNumerator[tokenId]);

        totalPatronOwnedTokenCost[_newOwner] = totalPatronOwnedTokenCost[_newOwner]
            .add(scaledNewPrice);
        totalPatronTokenGenerationRate[_newOwner] = totalPatronTokenGenerationRate[_newOwner]
            .add(globalTokenGenerationRate);

        address tokenBenefactor = benefactors[tokenId];
        totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
            .add(scaledNewPrice);

        if (_currentOwner != address(this) && _currentOwner != address(0)) {
            totalPatronOwnedTokenCost[_currentOwner] = totalPatronOwnedTokenCost[_currentOwner]
                .sub(scaledOldPrice);

            totalPatronTokenGenerationRate[_currentOwner] = totalPatronTokenGenerationRate[_currentOwner]
                .sub(globalTokenGenerationRate);

            totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
                .sub(scaledOldPrice);
        }

        assetToken.transferFrom(_currentOwner, _newOwner, tokenId);

        price[tokenId] = _newPrice;
    }

    function resetTokenOnForeclosure(uint256 tokenId, address _currentOwner)
        internal
    {

        uint256 scaledPrice = price[tokenId].mul(patronageNumerator[tokenId]);

        totalPatronOwnedTokenCost[_currentOwner] = totalPatronOwnedTokenCost[_currentOwner]
            .sub(scaledPrice);

        totalPatronTokenGenerationRate[_currentOwner] = totalPatronTokenGenerationRate[_currentOwner]
            .sub((globalTokenGenerationRate));

        address tokenBenefactor = benefactors[tokenId];
        totalBenefactorTokenNumerator[tokenBenefactor] = totalBenefactorTokenNumerator[tokenBenefactor]
            .sub(scaledPrice);

        assetToken.transferFrom(_currentOwner, address(this), tokenId);
    }
}