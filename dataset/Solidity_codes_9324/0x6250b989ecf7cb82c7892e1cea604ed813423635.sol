
pragma solidity ^0.8.0;

abstract contract AccessControl {
  address internal _admin;
  address internal _owner;

  modifier onlyAdmin() {
    require(msg.sender == _admin, "unauthorized");
    _;
  }

  modifier onlyOwner() {
    require(msg.sender == _owner, "unauthorized");
    _;
  }

  function changeAdmin(address newAdmin) external onlyOwner {
    _admin = newAdmin;
  }

  function changeOwner(address newOwner) external onlyOwner {
    _owner = newOwner;
  }

  function owner() external view returns (address) {
    return _owner;
  }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

  function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.8.0;

interface IERC721 {


  event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

  event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

  event ApprovalForAll(address indexed owner, address indexed operator, bool approved);


  function balanceOf(address owner) external view returns (uint256 balance);


  function getApproved(uint256 tokenId) external view returns (address operator);


  function isApprovedForAll(address owner, address operator) external view returns (bool);


  function ownerOf(uint256 tokenId) external view returns (address owner);



  function approve(address to, uint256 tokenId) external;


  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;


  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external;


  function setApprovalForAll(address operator, bool approved) external;


  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC721Metadata {

  function name() external view returns (string memory);


  function symbol() external view returns (string memory);


  function tokenURI(uint256 tokenId) external view returns (string memory);

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


abstract contract NFTCollectionV1 is AccessControl, IERC165, IERC721, IERC721Metadata {

  mapping(address => uint256) internal _balances;
  mapping(address => mapping(address => bool)) internal _operatorApprovals;
  mapping(uint256 => address) internal _owners;
  mapping(uint256 => address) internal _tokenApprovals;


  uint256 internal _totalSupply;
  uint256 internal _totalSupplyLimit;

  string internal _baseURI;


  function supportsInterface(bytes4 interfaceId) external pure override returns (bool) {
    return interfaceId == type(IERC721).interfaceId || interfaceId == type(IERC721Metadata).interfaceId;
  }


  function balanceOf(address owner_) external view override returns (uint256 balance) {
    return _balances[owner_];
  }

  function getApproved(uint256 tokenId) external view override returns (address operator) {
    return _tokenApprovals[tokenId];
  }

  function isApprovedForAll(address owner_, address operator) external view override returns (bool) {
    return _operatorApprovals[owner_][operator];
  }

  function ownerOf(uint256 tokenId) external view override returns (address) {
    return _owners[tokenId];
  }


  function approve(address to, uint256 tokenId) external override {
    address owner_ = _owners[tokenId];

    require(to != owner_, "caller may not approve themself");
    require(msg.sender == owner_ || _operatorApprovals[owner_][msg.sender], "unauthorized");

    _approve(to, tokenId);
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external override {
    _ensureApprovedOrOwner(msg.sender, tokenId);
    _transfer(from, to, tokenId);

    if (_isContract(to)) {
      IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, "");
    }
  }

  function safeTransferFrom(
    address from,
    address to,
    uint256 tokenId,
    bytes calldata data
  ) external override {
    _ensureApprovedOrOwner(msg.sender, tokenId);
    _transfer(from, to, tokenId);

    if (_isContract(to)) {
      IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data);
    }
  }

  function setApprovalForAll(address operator, bool approved) external override {
    require(operator != msg.sender, "caller may not approve themself");

    _operatorApprovals[msg.sender][operator] = approved;

    emit ApprovalForAll(msg.sender, operator, approved);
  }

  function transferFrom(
    address from,
    address to,
    uint256 tokenId
  ) external override {
    _ensureApprovedOrOwner(msg.sender, tokenId);
    _transfer(from, to, tokenId);
  }


  function tokenURI(uint256 tokenId) external view override returns (string memory) {
    return string(abi.encodePacked(_baseURI, _toString(tokenId), ".json"));
  }


  function changeBaseURI(string memory newURI) external onlyAdmin {
    _baseURI = newURI;
  }

  function totalSupply() external view returns (uint256) {
    return _totalSupply;
  }


  function _approve(address to, uint256 tokenId) private {
    _tokenApprovals[tokenId] = to;

    emit Approval(_owners[tokenId], to, tokenId);
  }

  function _ensureApprovedOrOwner(address spender, uint256 tokenId) private view {
    address owner_ = _owners[tokenId];

    require(
      spender == owner_ || spender == _tokenApprovals[tokenId] || _operatorApprovals[owner_][spender],
      "unauthorized"
    );
  }

  function _toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  function _isContract(address account) internal view returns (bool) {

    uint256 size;

    assembly {
      size := extcodesize(account)
    }

    return size > 0;
  }

  function _transfer(
    address from,
    address to,
    uint256 tokenId
  ) private {
    require(_owners[tokenId] == from, "transfer of token that is not own");
    require(to != address(0), "transfer to the zero address");

    _approve(address(0), tokenId);

    _balances[from] -= 1;
    _balances[to] += 1;
    _owners[tokenId] = to;

    emit Transfer(from, to, tokenId);
  }
}// MIT

pragma solidity ^0.8.0;

abstract contract Authorized {
  bytes32 internal immutable _domainSeparator;

  address internal _authority;

  constructor() {
    bytes32 typeHash = keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");

    _domainSeparator = keccak256(
      abi.encode(typeHash, keccak256(bytes("MetaFans")), keccak256(bytes("1.0.0")), block.chainid, address(this))
    );
  }

  modifier authorized(
    address account,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) {
    bytes32 hash = keccak256(abi.encode(keccak256("Presale(address to,uint256 deadline)"), account, deadline));

    require(verify(hash, v, r, s), "unauthorized");

    _;
  }

  function verify(
    bytes32 hash,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) internal view returns (bool) {
    return _authority == ecrecover(keccak256(abi.encodePacked("\x19\x01", _domainSeparator, hash)), v, r, s);
  }
}// MIT

pragma solidity 0.8.9;


contract MetafansCollection is NFTCollectionV1, Authorized {

  uint256 private constant _launchLimit = 10;
  uint256 private constant _mintCooldown = 10 minutes;
  uint256 private constant _presaleLimit = 3;

  address private immutable _partnerA;
  address private immutable _partnerB;
  uint256 private immutable _promoQuantity;


  uint256 private _launchAt;
  mapping(address => uint256) private _lastMintAt;
  uint256 private _partnerARevenue;
  uint256 private _partnerBRevenue;
  uint256 private _presaleAt;
  mapping(address => uint256) private _presaleClaimed;
  uint256 private _price;

  constructor(
    string memory baseURI_,
    uint256 launchAt_,
    address partnerA,
    address partnerB,
    uint256 presaleAt_,
    uint256 price,
    uint256 promoQuantity_,
    uint256 totalSupplyLimit_
  ) {
    _admin = msg.sender;
    _authority = msg.sender;
    _owner = msg.sender;

    _baseURI = baseURI_;
    _launchAt = launchAt_;
    _partnerA = partnerA;
    _partnerB = partnerB;
    _presaleAt = presaleAt_;
    _price = price;
    _promoQuantity = promoQuantity_;
    _totalSupplyLimit = totalSupplyLimit_;

    _totalSupply = _promoQuantity;
  }


  function name() external pure override returns (string memory) {

    return "Metafans Collection";
  }

  function symbol() external pure override returns (string memory) {

    return "MFC";
  }


  function lastMintAt(address wallet) external view returns (uint256) {

    return _lastMintAt[wallet];
  }

  function launchAt() external view returns (uint256) {

    return _launchAt;
  }

  function presaleAt() external view returns (uint256) {

    return _presaleAt;
  }

  function presaleClaimed(address wallet) external view returns (uint256) {

    return _presaleClaimed[wallet];
  }


  function changeLaunchAt(uint256 value) external onlyAdmin {

    _launchAt = value;
  }

  function changePresaleAt(uint256 value) external onlyAdmin {

    _presaleAt = value;
  }

  function changePrice(uint256 value) external onlyAdmin {

    _price = value;
  }


  function launchMint(uint256 quantity) external payable {

    require(_launchAt < block.timestamp, "launch has not begun");
    require(msg.value == _price * quantity, "incorrect ETH");
    require(quantity <= _launchLimit, "over limit");
    require(block.timestamp - _lastMintAt[msg.sender] > _mintCooldown, "cooling down");

    _partnerShare();
    _mint(quantity);
  }

  function presaleMint(
    uint256 quantity,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external payable authorized(msg.sender, deadline, v, r, s) {

    require(_presaleAt < block.timestamp, "presale has not begun");
    require(block.timestamp < _launchAt, "presale has ended");
    require(block.timestamp < deadline, "past deadline");
    require(msg.value == _price * quantity, "incorrect ETH");
    require((_presaleClaimed[msg.sender] += quantity) <= _presaleLimit, "over limit");

    _partnerShare();
    _mint(quantity);
  }

  function promoMint(uint256 tokenId, address to) external onlyAdmin {

    require(tokenId < _promoQuantity, "over promo limit");
    require(_owners[tokenId] == address(0), "already minted");

    _balances[to] += 1;
    _owners[tokenId] = to;

    emit Transfer(address(0), to, tokenId);
  }


  function partnerRevenue(address wallet) external view returns (uint256) {

    if (wallet == _partnerA) {
      return _partnerARevenue;
    }

    if (wallet == _partnerB) {
      return _partnerBRevenue;
    }

    return 0;
  }


  function claimRevenue() external {

    uint256 amount;

    if (msg.sender == _partnerA) {
      amount = _partnerARevenue;
      _partnerARevenue = 0;
    } else if (msg.sender == _partnerB) {
      amount = _partnerBRevenue;
      _partnerBRevenue = 0;
    } else {
      revert("unauthorized");
    }

    (bool send, ) = msg.sender.call{value: amount}("");

    require(send, "failed to send partner funds");
  }


  function _mint(uint256 quantity) private {

    require(_totalSupply + quantity <= _totalSupplyLimit, "over total supply limit");

    for (uint256 i = 0; i < quantity; i++) {
      _owners[_totalSupply + i] = msg.sender;

      emit Transfer(address(0), msg.sender, _totalSupply + i);
    }

    _balances[msg.sender] += quantity;
    _totalSupply += quantity;
    _lastMintAt[msg.sender] = block.timestamp;
  }

  function _partnerShare() private {

    uint256 shareB = msg.value / 10;
    uint256 shareA = msg.value - shareB;

    _partnerARevenue += shareA;
    _partnerBRevenue += shareB;
  }
}