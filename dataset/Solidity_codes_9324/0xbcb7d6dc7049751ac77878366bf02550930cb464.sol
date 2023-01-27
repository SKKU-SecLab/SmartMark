
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;


interface IERC1155Receiver is IERC165 {

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external returns (bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }
}// MIT

pragma solidity ^0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(
        address,
        address,
        uint256,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address,
        address,
        uint256[] memory,
        uint256[] memory,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC721Receiver {

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);

}// MIT

pragma solidity ^0.8.0;


contract ERC721Holder is IERC721Receiver {

    function onERC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _setOwner(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _setOwner(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _setOwner(newOwner);
    }

    function _setOwner(address newOwner) private {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256[] ids,
        uint256[] values
    );

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids)
        external
        view
        returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes calldata data
    ) external;


    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts,
        bytes calldata data
    ) external;

}//MIT
pragma solidity ^0.8.4;


abstract contract OpenSeaIERC1155 is IERC1155 {}// MIT

pragma solidity ^0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

}//CC-BY-NC-ND-4.0
pragma solidity ^0.8.6;

abstract contract BadCacheI is IERC721, Ownable {
  function setTokenUri(uint256 _tokenId, string memory _tokenURI) public virtual;

  function mint(address _owner, uint256 _tokenId) public virtual;

  function exists(uint256 _tokenId) public view virtual returns (bool);

  function getMaxId() public view virtual returns (uint256);

  function setMaxId(uint256 _newMaxId) public virtual;
}//CC-BY-NC-ND-4.0
pragma solidity ^0.8.6;



contract BadCacheBridge is ReentrancyGuard, Ownable, ERC1155Holder, ERC721Holder {

  address internal openseaToken = 0x495f947276749Ce646f68AC8c248420045cb7b5e;

  uint32 internal totalTransfers = 0;

  address[] internal senders;

  mapping(uint32 => mapping(address => uint256)) internal transfers;

  address internal badCache721 = 0x0000000000000000000000000000000000000000;

  string private baseUri = "https://ipfs.io/ipfs/QmYSUKeq5Dt8M2RBt7u9f63QwWvdPNawr6Gjc47jdaUr5C/";

  uint256[] internal allowedTokens;

  mapping(uint256 => uint16) internal oldNewTokenIdPairs;

  mapping(uint16 => uint256) internal newOldTokenIdPairs;

  uint16[] internal newTokenIds;

  uint16[] internal custom721Ids;

  event ReceivedTransferFromOpenSea(
    address indexed _sender,
    address indexed _receiver,
    uint256 indexed _tokenId,
    uint256 _amount
  );

  event ReceivedTransferFromBadCache721(address indexed _sender, address indexed _receiver, uint256 indexed _tokenId);

  event MintedBadCache721(address indexed _sender, uint256 indexed _tokenId);

  constructor() onlyOwner {
    initAllowedTokens();
  }

  function mintBasedOnReceiving(address _sender, uint256 _tokenId) internal isTokenAllowed(_tokenId) returns (bool) {

    require(_sender != address(0), "BadCacheBridge: can not mint a new token to the zero address");

    uint256 newTokenId = oldNewTokenIdPairs[_tokenId];
    if (BadCacheI(badCache721).exists(newTokenId) && BadCacheI(badCache721).ownerOf(newTokenId) == address(this)) {
      BadCacheI(badCache721).safeTransferFrom(address(this), _sender, newTokenId);
      return true;
    }
    require(!BadCacheI(badCache721).exists(newTokenId), "BadCacheBridge: token already minted");
    require(newTokenId != 0, "BadCacheBridge: new token id does not exists");

    string memory uri = getURIById(newTokenId);
    _mint721(newTokenId, _sender, uri);

    return true;
  }

  function checkBalance(address _account, uint256 _tokenId) public view isTokenAllowed(_tokenId) returns (uint256) {

    require(_account != address(0), "BadCacheBridge: can not check balance for address zero");
    return OpenSeaIERC1155(openseaToken).balanceOf(_account, _tokenId);
  }

  function setOpenSeaProxiedToken(address _token) public onlyOwner {

    require(_token != address(0), "BadCacheBridge: can not set as proxy the address zero");
    openseaToken = _token;
  }

  function setBadCache721ProxiedToken(address _token) public onlyOwner {

    require(_token != address(0), "BadCacheBridge: can not set as BadCache721 the address zero");
    badCache721 = _token;
  }

  function setBaseUri(string memory _baseUri) public onlyOwner {

    baseUri = _baseUri;
  }

  function getBaseUri() public view returns (string memory) {

    return baseUri;
  }

  function transferBadCache721(uint256 _tokenId, address _owner) public onlyOwner isNewTokenAllowed(_tokenId) {

    require(_owner != address(0), "BadCacheBridge: can not send a BadCache721 to the address zero");

    BadCacheI(badCache721).safeTransferFrom(address(this), _owner, _tokenId);
  }

  function transferBadCache1155(uint256 _tokenId, address _owner) public onlyOwner isTokenAllowed(_tokenId) {

    require(_owner != address(0), "BadCacheBridge: can not send a BadCache1155 to the address zero");

    OpenSeaIERC1155(openseaToken).safeTransferFrom(address(this), _owner, _tokenId, 1, "");
  }

  function ownerOf1155(uint256 _tokenId) public view returns (bool) {

    return OpenSeaIERC1155(openseaToken).balanceOf(msg.sender, _tokenId) != 0;
  }

  function onERC1155Received(
    address _sender,
    address _receiver,
    uint256 _tokenId,
    uint256 _amount,
    bytes memory _data
  ) public override returns (bytes4) {

    onReceiveTransfer1155(_sender, _tokenId);
    mintBasedOnReceiving(_sender, _tokenId);
    emit ReceivedTransferFromOpenSea(_sender, _receiver, _tokenId, _amount);
    return super.onERC1155Received(_sender, _receiver, _tokenId, _amount, _data);
  }

  function onERC721Received(
    address _sender,
    address _receiver,
    uint256 _tokenId,
    bytes memory _data
  ) public override returns (bytes4) {

    require(_sender != address(0), "BadCacheBridge: can not update from the zero address");
    if (_sender == address(this)) return super.onERC721Received(_sender, _receiver, _tokenId, _data);
    require(_tokenId <= type(uint16).max, "BadCacheBridge: Token id overflows");
    if (_sender != address(this)) onReceiveTransfer721(_sender, _tokenId);
    emit ReceivedTransferFromBadCache721(_sender, _receiver, _tokenId);
    return super.onERC721Received(_sender, _receiver, _tokenId, _data);
  }

  function getTransferCount() public view returns (uint128) {

    return totalTransfers;
  }

  function getAddressesThatTransferedIds() public view returns (address[] memory) {

    return senders;
  }

  function getIds() public view returns (uint256[] memory) {

    uint256[] memory ids = new uint256[](totalTransfers);
    for (uint32 i = 0; i < totalTransfers; i++) {
      ids[i] = transfers[i][senders[i]];
    }
    return ids;
  }

  function getCustomIds() public view returns (uint256[] memory) {

    uint256[] memory ids = new uint256[](custom721Ids.length);
    for (uint128 i = 0; i < custom721Ids.length; i++) {
      ids[i] = custom721Ids[i];
    }
    return ids;
  }

  function getOpenSeaProxiedtoken() public view returns (address) {

    return openseaToken;
  }

  function getBadCache721ProxiedToken() public view returns (address) {

    return badCache721;
  }

  function onReceiveTransfer1155(address _sender, uint256 _tokenId) internal isTokenAllowed(_tokenId) returns (uint32 count) {

    require(_sender != address(0), "BadCacheBridge: can not update from the zero address");
    require(OpenSeaIERC1155(openseaToken).balanceOf(address(this), _tokenId) > 0, "BadCacheBridge: This is not an OpenSea token");

    senders.push(_sender);
    transfers[totalTransfers][_sender] = _tokenId;
    totalTransfers++;
    return totalTransfers;
  }

  function onReceiveTransfer721(address _sender, uint256 _tokenId) internal isNewTokenAllowed(_tokenId) {

    for (uint120 i; i < senders.length; i++) {
      if (senders[i] == _sender) delete senders[i];
    }

    OpenSeaIERC1155(openseaToken).safeTransferFrom(address(this), _sender, newOldTokenIdPairs[uint16(_tokenId)], 1, "");
  }

  function addAllowedToken(uint256 _tokenId, uint16 _newTokenId) public onlyOwner {

    allowedTokens.push(_tokenId);
    oldNewTokenIdPairs[_tokenId] = _newTokenId;
    newTokenIds.push(_newTokenId);
    newOldTokenIdPairs[_newTokenId] = _tokenId;
  }

  function mintBadCache721(
    uint16 _tokenId,
    string memory _uri,
    address _owner
  ) public onlyOwner {

    require(_owner != address(0), "BadCacheBridge: can not mint a new token to the zero address");

    if (BadCacheI(badCache721).exists(_tokenId) && BadCacheI(badCache721).ownerOf(_tokenId) == address(this)) {
      BadCacheI(badCache721).safeTransferFrom(address(this), _owner, _tokenId);
      return;
    }
    require(!BadCacheI(badCache721).exists(_tokenId), "BadCacheBridge: token already minted");
    _mint721(_tokenId, _owner, _uri);
    custom721Ids.push(_tokenId);
  }

  function transferOwnershipOf721(address _newOwner) public onlyOwner {

    require(_newOwner != address(0), "BadCacheBridge: new owner can not be the zero address");
    BadCacheI(badCache721).transferOwnership(_newOwner);
  }

  function getURIById(uint256 _tokenId) private view isNewTokenAllowed(_tokenId) returns (string memory) {

    return string(abi.encodePacked(baseUri, uint2str(_tokenId), ".json"));
  }

  function _mint721(
    uint256 _tokenId,
    address _owner,
    string memory _tokenURI
  ) private {

    BadCacheI(badCache721).mint(address(this), _tokenId);

    BadCacheI(badCache721).setTokenUri(_tokenId, _tokenURI);
    BadCacheI(badCache721).safeTransferFrom(address(this), _owner, _tokenId);
    emit MintedBadCache721(_owner, _tokenId);
  }

  function initAllowedTokens() private {

    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680203063263232001, 1);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680204162774859777, 2);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680205262286487553, 3);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680206361798115329, 4);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680207461309743105, 5);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680208560821370881, 6);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680209660332998657, 7);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680210759844626433, 8);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680211859356254209, 9);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680212958867881985, 10);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680214058379509761, 11);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680215157891137537, 12);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680216257402765313, 13);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680217356914393089, 14);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680218456426020865, 15);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680219555937648641, 16);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680220655449276417, 17);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680221754960904193, 18);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680222854472531969, 19);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680223953984159745, 20);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680225053495787521, 21);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680226153007415297, 22);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680227252519043073, 23);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680228352030670849, 24);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680229451542298625, 25);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680230551053926401, 26);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680231650565554177, 27);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680232750077181953, 28);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680233849588809729, 29);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680234949100437505, 30);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680236048612065281, 31);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680237148123693057, 32);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680238247635320833, 33);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680239347146948609, 34);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680240446658576385, 35);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680241546170204161, 36);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680242645681831937, 37);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680243745193459713, 38);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680244844705087489, 39);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680245944216715265, 40);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680247043728343041, 41);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680248143239970817, 42);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680249242751598593, 43);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680250342263226369, 44);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680251441774854145, 45);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680252541286481921, 46);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680253640798109697, 47);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680254740309737473, 48);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680255839821365249, 49);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680256939332993025, 50);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680258038844620801, 51);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680259138356248577, 52);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680260237867876353, 53);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680261337379504129, 54);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680262436891131905, 55);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680263536402759681, 56);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680264635914387457, 57);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680265735426015233, 58);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680266834937643009, 59);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680267934449270785, 60);
  }

  function initTheRestOfTheTokens() public onlyOwner {

    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680269033960898561, 61);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680270133472526337, 62);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680271232984154113, 63);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680272332495781889, 64);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680273432007409665, 65);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680274531519037441, 66);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680275631030665217, 67);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680276730542292993, 68);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680277830053920769, 69);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680278929565548545, 70);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680280029077176321, 71);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680281128588804097, 72);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680282228100431873, 73);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680283327612059649, 74);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680284427123687425, 75);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680285526635315201, 76);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680286626146942977, 77);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680287725658570753, 78);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680288825170198529, 79);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680289924681826305, 80);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680291024193454081, 81);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680292123705081857, 82);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680293223216709633, 83);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680294322728337409, 84);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680295422239965185, 85);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680296521751592961, 86);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680297621263220737, 87);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680298720774848513, 88);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680299820286476289, 89);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680300919798104065, 90);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680302019309731841, 91);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680303118821359617, 92);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680304218332987393, 93);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680305317844615169, 94);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680306417356242945, 95);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680307516867870721, 96);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680308616379498497, 97);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680309715891126273, 98);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680310815402754049, 99);
    addAllowedToken(85601406272210854214775655996269203562327957411057160318308680311914914381825, 100);
  }

  modifier isTokenAllowed(uint256 _tokenId) {

    bool found = false;
    for (uint128 i = 0; i < allowedTokens.length; i++) {
      if (allowedTokens[i] == _tokenId) found = true;
    }
    require(found, "BadCacheBridge: token id does not exists");
    _;
  }

  modifier isNewTokenAllowed(uint256 _tokenId) {

    bool found = false;

    for (uint128 i = 0; i < newTokenIds.length; i++) {
      if (newTokenIds[i] == _tokenId) found = true;
    }
    require(found, "BadCacheBridge: new token id does not exists");
    _;
  }

  function uint2str(uint256 _i) internal pure returns (string memory _uintAsString) {

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
    uint256 k = len;
    while (_i != 0) {
      k = k - 1;
      uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
      bytes1 b1 = bytes1(temp);
      bstr[k] = b1;
      _i /= 10;
    }
    return string(bstr);
  }
}