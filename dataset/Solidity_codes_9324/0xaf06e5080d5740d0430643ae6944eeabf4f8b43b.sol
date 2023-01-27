
pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

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
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor() {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}//Unlicense
pragma solidity ^0.8.0;


contract TradableNFTs is IERC721Receiver, Pausable, Ownable {

  struct Depositor {
    int256 principal;
    int256 deficit;
    int256 aux;
  }
  int256 public constant PRECISION = 10**15;
  address internal coreBlocksAddress;
  int256 public rendFactor = 0;
  int256 public totalPrincipal = 0;
  uint256 public totalDeposited = 0;
  uint256 public depositPrice = 1 * 10**16;
  uint256 public depositLimit = 250;
  uint256 public transactionLimit = 25;
  int256 public leftNFTs = 0;
  address public adminAddress;
  bool public tradePaused = false;
  bool public depositPaused = false;

  mapping(address => Depositor) public depositorList;
  mapping(address => uint256) public allowedList;
  event Received(
    address _operator,
    address _from,
    uint256 _tokenId,
    bytes _data,
    uint256 _gas
  );

  event Deposit(uint256 quantity);
  event Trade(uint256 quantity);
  event Withdraw(uint256 quantity);

  modifier onlyAdmin() {

    require(_msgSender() == adminAddress, 'Must be admin');
    _;
  }

  modifier notPausedOrAdmin() {

    require(!paused() || _msgSender() == adminAddress, 'Paused');
    _;
  }

  modifier reachedTransactionLimit(uint256 length) {

    require(
      length <= transactionLimit || _msgSender() == adminAddress,
      'Reached max per transaction'
    );
    _;
  }

  modifier transferIsApproved() {

    require(
      IERC721(coreBlocksAddress).isApprovedForAll(msg.sender, address(this)),
      'Need access to transfer the NFTs'
    );
    _;
  }

  modifier isNFTsOwner(uint256[] memory offeredNFTs) {

    for (uint8 i = 0; i < offeredNFTs.length; i++) {
      require(
        msg.sender == IERC721(coreBlocksAddress).ownerOf(offeredNFTs[i]),
        'Only owner can transfer the NFTs'
      );
    }
    _;
  }

  modifier hasRequestedNFTs(uint256[] memory requestedNFTs) {

    for (uint8 i = 0; i < requestedNFTs.length; i++) {
      require(
        address(this) == IERC721(coreBlocksAddress).ownerOf(requestedNFTs[i]),
        'Requested NFTs not found'
      );
    }
    _;
  }

  constructor(address _coreBlocksAddress, address _admin) {
    require(
      _coreBlocksAddress != address(0) && _admin != address(0),
      '0 address'
    );
    coreBlocksAddress = _coreBlocksAddress;
    adminAddress = _admin;
    transferOwnership(_admin);
  }

  function pause() external onlyAdmin {

    _pause();
  }

  function unpause() external onlyAdmin {

    _unpause();
  }

  function toggleTradePause() external onlyAdmin {

    tradePaused = !tradePaused;
  }

  function toggleDepositPause() external onlyAdmin {

    depositPaused = !depositPaused;
  }

  function setAdmin(address _adminAddress) external onlyAdmin {

    require(_adminAddress != address(0), '0 address');
    adminAddress = _adminAddress;
  }

  function _increaseNumber(int256 number) internal pure returns (int256) {

    return number * PRECISION;
  }

  function _decreaseNumber(int256 number) internal pure returns (int256) {

    return number / PRECISION;
  }

  function _calculateDeficit(int256 principal) internal view returns (int256) {

    if (rendFactor == 0) {
      return 0;
    }
    return _decreaseNumber(rendFactor * principal);
  }

  function _calculateRend() internal {

    if (totalPrincipal == 0) {
      rendFactor = 0;
    } else {
      rendFactor += _increaseNumber(PRECISION) / totalPrincipal;
    }
  }

  function _ceil(int256 a, int256 m) internal pure returns (int256) {

    return ((a + m - 1) * m) / m;
  }

  function getNFTBalance(address _depositorAddress)
    public
    view
    returns (int256)
  {

    Depositor memory depositor = depositorList[_depositorAddress];

    if (depositor.principal == 0) return 0 + _decreaseNumber(depositor.aux);

    return
      (depositor.principal +
        depositor.aux +
        _decreaseNumber(rendFactor * depositor.principal)) - depositor.deficit;
  }

  function getBalanceFormatted(address _depositorAddress)
    public
    view
    returns (int256)
  {

    return _decreaseNumber(getNFTBalance(_depositorAddress));
  }

  function getFullBalance(address _depositorAddress)
    external
    view
    returns (
      int256 balance,
      int256 balanceFormatted,
      int256 principal,
      int256 principalTotal
    )
  {

    Depositor memory depositor = depositorList[_depositorAddress];
    balance = getNFTBalance(_depositorAddress);
    balanceFormatted = getBalanceFormatted(_depositorAddress);
    principal = depositor.principal;
    principalTotal = totalPrincipal;
  }

  function getOwnerBalance() external view returns (int256) {

    return leftNFTs;
  }

  function setDepositPrice(uint256 price) external onlyAdmin {

    depositPrice = price;
  }

  function setDepositLimit(uint256 newLimit) external onlyAdmin {

    depositLimit = newLimit;
  }

  function setTransactionLimit(uint256 newLimit) external onlyAdmin {

    transactionLimit = newLimit;
  }

  function trade(uint256[] memory offeredNFTs, uint256[] memory requestedNFTs)
    external
    payable
    notPausedOrAdmin
    reachedTransactionLimit(offeredNFTs.length + requestedNFTs.length)
    isNFTsOwner(offeredNFTs)
    transferIsApproved
    hasRequestedNFTs(requestedNFTs)
  {

    require(!tradePaused, 'Trade paused');
    require(
      offeredNFTs.length - 1 == requestedNFTs.length,
      'Requested more than given NFTs'
    );

    _calculateRend();

    if (rendFactor == 0) {
      leftNFTs += _increaseNumber(1);
    }

    totalDeposited += 1;
    emit Trade(offeredNFTs.length);

    for (uint8 i = 0; i < offeredNFTs.length; i++) {
      IERC721(coreBlocksAddress).safeTransferFrom(
        msg.sender,
        address(this),
        offeredNFTs[i]
      );
    }
    for (uint8 i = 0; i < requestedNFTs.length; i++) {
      IERC721(coreBlocksAddress).safeTransferFrom(
        address(this),
        msg.sender,
        requestedNFTs[i]
      );
    }
  }

  function deposit(uint256[] memory depositIds)
    external
    payable
    notPausedOrAdmin
    reachedTransactionLimit(depositIds.length)
    isNFTsOwner(depositIds)
    transferIsApproved
  {

    require(!depositPaused, 'Deposit paused');
    Depositor memory depositor = depositorList[msg.sender];
    require(
      allowedList[msg.sender] > 0 || msg.value >= depositPrice,
      'Insufficient eth sent'
    );
    require(
      uint256(_decreaseNumber(depositor.principal)) + depositIds.length - 1 <=
        depositLimit,
      'Reached deposit limit'
    );
    require(depositIds.length > 1, 'You need to deposit more NFTs');

    int256 bPrincipal = _increaseNumber(int256(depositIds.length) - 1);
    _calculateRend();

    if (rendFactor == 0) {
      leftNFTs += _increaseNumber(1);
    }

    int256 bDeficit = _calculateDeficit(bPrincipal);
    totalDeposited += depositIds.length;
    totalPrincipal += bPrincipal;

    depositorList[msg.sender] = Depositor({
      principal: depositor.principal + bPrincipal,
      deficit: depositor.deficit + bDeficit,
      aux: depositor.aux
    });
    if (allowedList[msg.sender] > 0) {
      allowedList[msg.sender] -= 1;
    }
    emit Deposit(depositIds.length);

    for (uint8 i = 0; i < depositIds.length; i++) {
      IERC721(coreBlocksAddress).safeTransferFrom(
        msg.sender,
        address(this),
        depositIds[i]
      );
    }
  }

  function withdrawNFTs(uint256[] memory requestedNFTs)
    external
    payable
    notPausedOrAdmin
    reachedTransactionLimit(requestedNFTs.length)
    hasRequestedNFTs(requestedNFTs)
  {

    int256 _balance = getBalanceFormatted(msg.sender);
    Depositor memory depositor = depositorList[msg.sender];
    int256 _requestedLength = int256(requestedNFTs.length);
    if (_requestedLength < _balance) {
      require(
        _requestedLength < _decreaseNumber(depositor.principal),
        'Requested need to be < principal or = balance'
      );
    } else {
      require(_requestedLength == _balance, 'Balance doesnt match');
    }

    int256 bRequested = _increaseNumber(_requestedLength);

    if (_requestedLength == _balance) {
      leftNFTs += getNFTBalance(msg.sender) - bRequested;
      totalPrincipal -= depositor.principal;
      delete depositorList[msg.sender];
    } else {
      int256 newPrincipal = depositor.principal - bRequested;
      int256 bDeficit = _calculateDeficit(newPrincipal);
      depositorList[msg.sender].aux =
        getNFTBalance(msg.sender) -
        depositor.principal;
      depositorList[msg.sender].principal = newPrincipal;
      depositorList[msg.sender].deficit = bDeficit;
      totalPrincipal -= bRequested;
    }

    totalDeposited -= requestedNFTs.length;
    emit Withdraw(requestedNFTs.length);

    for (uint8 i = 0; i < requestedNFTs.length; i++) {
      IERC721(coreBlocksAddress).safeTransferFrom(
        address(this),
        msg.sender,
        requestedNFTs[i]
      );
    }
  }

  function withdrawAdminNFTs(uint256[] memory requestedNFTs)
    external
    onlyAdmin
    hasRequestedNFTs(requestedNFTs)
  {

    int256 bRequested = _increaseNumber(int256(requestedNFTs.length));
    if (totalPrincipal == 0) {
      require(bRequested <= _ceil(leftNFTs, PRECISION), 'Balance doesnt match');
    } else {
      require(bRequested <= leftNFTs, 'Balance doesnt match');
    }

    if (leftNFTs - bRequested <= 0) {
      leftNFTs = 0;
    } else {
      leftNFTs -= bRequested;
    }
    totalDeposited -= requestedNFTs.length;

    emit Withdraw(requestedNFTs.length);

    for (uint8 i = 0; i < requestedNFTs.length; i++) {
      IERC721(coreBlocksAddress).safeTransferFrom(
        address(this),
        adminAddress,
        requestedNFTs[i]
      );
    }
  }

  function addToAllowedList(address[] memory _addresses, uint256 _times)
    external
    onlyAdmin
  {

    for (uint8 i = 0; i < _addresses.length; i++) {
      allowedList[_addresses[i]] = _times;
    }
  }

  function withdrawEther() external onlyAdmin {

    uint256 balance = address(this).balance;
    payable(adminAddress).transfer(balance);
  }

  function onERC721Received(
    address operator,
    address from,
    uint256 tokenId,
    bytes memory data
  ) external override returns (bytes4) {

    emit Received(operator, from, tokenId, data, gasleft());
    return IERC721Receiver(address(this)).onERC721Received.selector;
  }
}