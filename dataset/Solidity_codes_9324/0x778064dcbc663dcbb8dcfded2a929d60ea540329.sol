
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
}// MIT

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

pragma solidity 0.8.9;


abstract contract Sunsetable is Context {
    event Sunset(address account);

    event Sunrise(address account);

    bool private _sunsetModeActive;

    constructor() {
        _sunsetModeActive = false;
    }

    function sunsetModeActive() public view virtual returns (bool) {
        return _sunsetModeActive;
    }

    modifier whenSun() {
        require(!sunsetModeActive(), "Sunset: Sun has set on this contract");
        _;
    }

    modifier whenMoon() {
        require(sunsetModeActive(), "Sunset: Sun has not set on this contract");
        _;
    }

    function _sunset() internal virtual whenSun {
        _sunsetModeActive = true;
        emit Sunset(_msgSender());
    }

    function _sunrise() internal virtual whenMoon {
        _sunsetModeActive = false;
        emit Sunrise(_msgSender());
    }
}// MIT

pragma solidity 0.8.9;

library Constants {

    uint256 constant TXNCODE_LOAN_ADVANCED = 1000;
    uint256 constant TXNCODE_LOAN_PAYMENT_MADE = 2000;
    uint256 constant TXNCODE_ASSET_REDEEMED = 3000;
    uint256 constant TXNCODE_ASSET_EXTENDED = 4000;
    uint256 constant TXNCODE_ASSET_REPOSSESSED = 5000;
    uint32 constant SECONDS_TO_DAYS_FACTOR = 86400;
    uint128 constant LOAN_AMOUNT_MAX_INCREMENT = 300000000000000000;
    uint64 constant FEE_MAX_INCREMENT = 30000000000000000;
    uint16 constant LOAN_TERM_MAX = 180;
    uint16 constant LOAN_TERM_MIN = 14;
}// BUSL-1.1

pragma solidity 0.8.9;


contract Metalend is IERC721Receiver, Ownable, Pausable, Sunsetable {

  struct LoanItem {
    uint128 loanId;
    uint128 currentBalance;
    bool isCurrent;
    address payable borrower;
    uint32 startDate;
    uint32 endDate;
    uint16 tokenId;
  }

  IERC721 public tokenContract;
  uint16 public termInDays;
  uint16 public extensionHorizon;

  uint128 public loanAmount;
  uint64 public lendingFee;
  uint64 public extensionFee;

  address public repoAddress;

  LoanItem[] public itemsUnderLoan;

  event lendingTransaction(
    uint128 indexed loanId,
    uint256 indexed transactionCode,
    address indexed borrower,
    uint16 tokenId,
    uint256 transactionValue,
    uint256 transactionFee,
    uint256 loanEndDate,
    uint256 effectiveDate
  );
  event eligibleNFTAddressSet(address indexed nftAddress);
  event repoAddressSet(address indexed repoAddress);
  event loanAmountSet(uint128 indexed loanAmount);
  event lendingFeeSet(uint64 indexed lendingFee);
  event extensionFeeSet(uint64 indexed extensionFee);
  event termInDaysSet(uint16 indexed termInDays);
  event extensionHorizonSet(uint16 indexed extensionHorizon);
  event ethWithdrawn(uint256 indexed withdrawal, uint256 effectiveDate);
  event ethDeposited(uint256 indexed deposit, uint256 effectiveDate);

  constructor(
    address _tokenAddress,
    uint128 _loanAmount,
    uint16 _termInDays,
    address _repoAddress,
    uint64 _lendingFee,
    uint64 _extensionFee,
    uint16 _extensionHorizon
  ) {
    tokenContract = IERC721(_tokenAddress);
    loanAmount = _loanAmount;
    termInDays = _termInDays;
    repoAddress = _repoAddress;
    lendingFee = _lendingFee;
    extensionFee = _extensionFee;
    extensionHorizon = _extensionHorizon;
    pause();
  }


  modifier OnlyItemBorrower(uint128 _loanId) {

    require(
      itemsUnderLoan[_loanId].borrower == msg.sender,
      "Payments can only be made by the borrower"
    );
    _;
  }

  modifier IsUnderLoan(uint128 _loanId) {

    require(
      itemsUnderLoan[_loanId].isCurrent == true,
      "Item is not currently under loan"
    );
    _;
  }

  modifier LoanEligibleForExtension(uint128 _loanId) {

    require(
      extensionsAllowed() == true,
      "Extensions currently not allowed"
    );
    require(
      isWithinExtensionHorizon(_loanId) == true,
      "Loan is not within extension horizon"
    );
    _;
  }

  modifier LoanWithinLoanTerm(uint128 _loanId) {

    require(
      isWithinLoanTerm(_loanId) == true,
      "Loan term has expired");
    _;
  }


  function setRepoAddress(address _repoAddress)
    external
    onlyOwner
    returns (bool)
  {

    repoAddress = _repoAddress;
    emit repoAddressSet(_repoAddress);
    return true;
  }

  function setLoanAmount(uint128 _loanAmount)
    external
    onlyOwner
    returns (bool)
  {

    require(_loanAmount != loanAmount, "No change to loan amount");
    if (_loanAmount > loanAmount) {
        require(
            (_loanAmount - loanAmount) <=
                Constants.LOAN_AMOUNT_MAX_INCREMENT,
            "Change exceeds max increment"
        );
    } else {
        require(
            (loanAmount - _loanAmount) <=
                Constants.LOAN_AMOUNT_MAX_INCREMENT,
            "Change exceeds max increment"
        );
    }
    loanAmount = _loanAmount;
    emit loanAmountSet(_loanAmount);
    return true;
  }

  function setLendingFee(uint64 _lendingFee) external onlyOwner returns (bool) {

    require(_lendingFee != lendingFee, "No change to lending fee");
    if (_lendingFee > lendingFee) {
      require(
        (_lendingFee - lendingFee) <= Constants.FEE_MAX_INCREMENT,
        "Change exceeds max increment"
      );
      } else {
        require(
          (lendingFee - _lendingFee) <= Constants.FEE_MAX_INCREMENT,
          "Change exceeds max increment"
          );
      }
    lendingFee = _lendingFee;
    emit lendingFeeSet(_lendingFee);
    return true;
  }

  function setExtensionFee(uint64 _extensionFee)
    external
    onlyOwner
    returns (bool)
  {

    require(_extensionFee != extensionFee, "No change to extension fee");
    if (_extensionFee > extensionFee) {
        require(
            (_extensionFee - extensionFee) <= Constants.FEE_MAX_INCREMENT,
            "Change exceeds max increment"
        );
    } else {
        require(
            (extensionFee - _extensionFee) <= Constants.FEE_MAX_INCREMENT,
            "Change exceeds max increment"
        );
    }
    extensionFee = _extensionFee;
    emit extensionFeeSet(_extensionFee);
    return true;
  }

  function setTermInDays(uint16 _termInDays) external onlyOwner returns (bool) {

    require(_termInDays != termInDays, "No change to term");
    require(
      _termInDays <= Constants.LOAN_TERM_MAX,
      "Change is more than max term"
    );
    require(
      _termInDays >= Constants.LOAN_TERM_MIN,
      "Change is less than min term"
    );
    require(
      _termInDays >= extensionHorizon,
      "Term must be greater than or equal to extension horizon"
    );
    termInDays = _termInDays;
    emit termInDaysSet(_termInDays);
    return true;
  }

  function setExtensionHorizon(uint16 _extensionHorizon)
    external
    onlyOwner
    returns (bool)
  {

    require(_extensionHorizon != extensionHorizon, "No change to horizon");
    require(
      _extensionHorizon <= Constants.LOAN_TERM_MAX,
      "Change is more than max term"
    );
    require(
      _extensionHorizon >= Constants.LOAN_TERM_MIN,
      "Change is less than min term"
    );
    require(
      _extensionHorizon <= termInDays,
      "Extension horizon must be less than or equal to term"
    );
    extensionHorizon = _extensionHorizon;
    emit extensionHorizonSet(_extensionHorizon);
    return true;
  }

  function onERC721Received(
    address,
    address,
    uint256,
    bytes memory
  ) external virtual override returns (bytes4) {

    return this.onERC721Received.selector;
  }

  receive() external payable {
    require(msg.sender == owner(), "Only owner can fund contract.");
    require(msg.value > 0, "No ether was sent.");
    emit ethDeposited(msg.value, block.timestamp);
  }

  fallback() external payable {
    revert();
  }

  function getParameters()
    external
    view
    returns (
      address _tokenAddress,
      uint32 _loanTerm,
      uint128 _loanAmount,
      uint128 _loanFee,
      uint64 _extensionHorizon,
      uint128 _extensionFee,
      bool _isPaused,
      bool _isSunset
    )
  {

    return (
      address(tokenContract),
      termInDays,
      loanAmount,
      lendingFee,
      extensionHorizon,
      extensionFee,
      paused(),
      sunsetModeActive()
    );
  }

  function getLoans() external view returns (LoanItem[] memory) {

    return itemsUnderLoan;
  }

  function pause() public onlyOwner {

    _pause();
  }

  function unpause() external onlyOwner {

    _unpause();
  }

  function sunset() external onlyOwner {

    _sunset();
  }

  function sunrise() external onlyOwner {

    _sunrise();
  }

  function extensionsAllowed() public view returns (bool) {

    return (extensionFee > 0);
  }

  function isWithinExtensionHorizon(uint128 _loanId) public view returns (bool) {

    return
      (block.timestamp +
      (extensionHorizon * Constants.SECONDS_TO_DAYS_FACTOR) >=
      itemsUnderLoan[_loanId].endDate);
  }

  function isWithinLoanTerm(uint128 _loanId) public view returns (bool) {

    return (block.timestamp <= itemsUnderLoan[_loanId].endDate);
  }

  function withdraw(uint256 _withdrawal) external onlyOwner returns (bool) {

    (bool success, ) = msg.sender.call{value: _withdrawal}("");
    require(success, "Transfer failed.");
    emit ethWithdrawn(_withdrawal, block.timestamp);
    return true;
  }

  function takeLoan(uint16 tokenId) external whenNotPaused whenSun {

    uint256 newItemId = itemsUnderLoan.length;
    uint32 endDate = uint32(block.timestamp) +
      (termInDays * Constants.SECONDS_TO_DAYS_FACTOR);
    itemsUnderLoan.push(
      LoanItem(
        uint128(newItemId),
        loanAmount + lendingFee,
        true,
        payable(msg.sender),
        uint32(block.timestamp),
        endDate,
        tokenId
      )
    );
    tokenContract.safeTransferFrom(msg.sender, address(this), tokenId);
    payable(msg.sender).transfer(loanAmount);
    emit lendingTransaction(
      uint128(newItemId),
      Constants.TXNCODE_LOAN_ADVANCED,
      msg.sender,
      tokenId,
      loanAmount,
      lendingFee,
      endDate,
      block.timestamp
    );
  }

  function makeLoanPayment(uint128 _loanId)
    external
    payable
    IsUnderLoan(_loanId)
    OnlyItemBorrower(_loanId)
    LoanWithinLoanTerm(_loanId)
    whenNotPaused
  {

    require(
      msg.value <= itemsUnderLoan[_loanId].currentBalance,
      "Payment exceeds current balance"
    );
    itemsUnderLoan[_loanId].currentBalance -= uint128(msg.value);

    if (itemsUnderLoan[_loanId].currentBalance == 0) {
      _closeLoan(_loanId, msg.sender);

      emit lendingTransaction(
        _loanId,
        Constants.TXNCODE_ASSET_REDEEMED,
        msg.sender,
        itemsUnderLoan[_loanId].tokenId,
        msg.value,
        0,
        itemsUnderLoan[_loanId].endDate,
        block.timestamp
      );
    } else {
      emit lendingTransaction(
        _loanId,
        Constants.TXNCODE_LOAN_PAYMENT_MADE,
        msg.sender,
        itemsUnderLoan[_loanId].tokenId,
        msg.value,
        0,
        itemsUnderLoan[_loanId].endDate,
        block.timestamp
      );
    }
  }

  function extendLoan(uint128 _loanId)
    external
    payable
    IsUnderLoan(_loanId)
    OnlyItemBorrower(_loanId)
    LoanWithinLoanTerm(_loanId)
    LoanEligibleForExtension(_loanId)
    whenNotPaused
    whenSun
  {

    require(msg.value == extensionFee, "Payment must equal the extension fee");
    itemsUnderLoan[_loanId].endDate += (termInDays *
      Constants.SECONDS_TO_DAYS_FACTOR);
    emit lendingTransaction(
      _loanId,
      Constants.TXNCODE_ASSET_EXTENDED,
      msg.sender,
      itemsUnderLoan[_loanId].tokenId,
      msg.value,
      msg.value,
      itemsUnderLoan[_loanId].endDate,
      block.timestamp
    );
  }

  function repossessItem(uint128 _loanId) public IsUnderLoan(_loanId) {

    require(
      itemsUnderLoan[_loanId].endDate < block.timestamp,
      "Loan term has not yet elapsed"
    );

    _closeLoan(_loanId, repoAddress);

    emit lendingTransaction(
      _loanId,
      Constants.TXNCODE_ASSET_REPOSSESSED,
      itemsUnderLoan[_loanId].borrower,
      itemsUnderLoan[_loanId].tokenId,
      itemsUnderLoan[_loanId].currentBalance,
      0,
      itemsUnderLoan[_loanId].endDate,
      block.timestamp
    );
  }

  function repossessItems(uint128[] calldata repoItems) external {

    for (uint256 i = 0; i < repoItems.length; i++) {
      repossessItem(repoItems[i]);
    }
  }

  function _closeLoan(uint128 _closeLoanId, address _tokenTransferTo) internal {

    itemsUnderLoan[_closeLoanId].isCurrent = false;
    tokenContract.safeTransferFrom(
      address(this),
      _tokenTransferTo,
      itemsUnderLoan[_closeLoanId].tokenId
    );
  }
}