
pragma solidity >=0.6.0 <0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

pragma solidity >=0.6.0 <0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}

pragma solidity >=0.6.2 <0.8.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}

pragma solidity >=0.6.0 <0.8.0;

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

pragma solidity >=0.6.0 <0.8.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
}
pragma solidity 0.7.4;


interface IERC1155 {



  event TransferSingle(address indexed _operator, address indexed _from, address indexed _to, uint256 _id, uint256 _amount);

  event TransferBatch(address indexed _operator, address indexed _from, address indexed _to, uint256[] _ids, uint256[] _amounts);

  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);



  function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _amount, bytes calldata _data) external;


  function safeBatchTransferFrom(address _from, address _to, uint256[] calldata _ids, uint256[] calldata _amounts, bytes calldata _data) external;


  function balanceOf(address _owner, uint256 _id) external view returns (uint256);


  function balanceOfBatch(address[] calldata _owners, uint256[] calldata _ids) external view returns (uint256[] memory);


  function setApprovalForAll(address _operator, bool _approved) external;


  function isApprovedForAll(address _owner, address _operator) external view returns (bool isOperator);

}

pragma solidity >=0.6.0 <0.8.0;


interface IERC1155Receiver is IERC165 {


    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    )
        external
        returns(bytes4);


    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    )
        external
        returns(bytes4);

}

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC165 is IERC165 {
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    mapping(bytes4 => bool) private _supportedInterfaces;

    constructor () {
        _registerInterface(_INTERFACE_ID_ERC165);
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return _supportedInterfaces[interfaceId];
    }

    function _registerInterface(bytes4 interfaceId) internal virtual {
        require(interfaceId != 0xffffffff, "ERC165: invalid interface id");
        _supportedInterfaces[interfaceId] = true;
    }
}

pragma solidity >=0.6.0 <0.8.0;


abstract contract ERC1155Receiver is ERC165, IERC1155Receiver {
    constructor() {
        _registerInterface(
            ERC1155Receiver(0).onERC1155Received.selector ^
            ERC1155Receiver(0).onERC1155BatchReceived.selector
        );
    }
}

pragma solidity >=0.6.0 <0.8.0;


contract ERC1155Holder is ERC1155Receiver {

    function onERC1155Received(address, address, uint256, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory) public virtual override returns (bytes4) {

        return this.onERC1155BatchReceived.selector;
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

pragma solidity >=0.6.0 <0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

pragma solidity >=0.6.0 <0.8.0;

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
pragma solidity 0.7.4;
interface Geyser{ function totalStakedFor(address addr) external view returns(uint256); }


contract LendingData is ERC721Holder, ERC1155Holder, Ownable {


  using SafeMath for uint256;
  enum TimeScale{ MINUTES, HOURS, DAYS, WEEKS }

  address public nftAddress; //0xcb13DC836C2331C669413352b836F1dA728ce21c

  address[] public geyserAddressArray; //[0xf1007ACC8F0229fCcFA566522FC83172602ab7e3]

  address public promissoryNoteContractAddress;
  
  uint256[] public staterNftTokenIdArray; //[0, 1]
  
  uint32 public discountNft = 50;
  
  uint32 public discountGeyser = 50;
  
  uint32 public lenderFee = 100;
  
  uint256 public loanID;

  uint256 public ltv = 600;
  
  uint256 public installmentFrequency = 1;
  TimeScale public installmentTimeScale = TimeScale.WEEKS;
  
  uint256 public interestRate = 20;
  
  uint256 public interestRateToStater = 40;

  enum Status{
      UNINITIALIZED, // will be removed in the future -- not used
      LISTED, // after the loan have been created --> the next status will be APPROVED
      APPROVED, // in this status the loan has a lender -- will be set after approveLoan()
      DEFAULTED, // will be removed in the future -- not used
      LIQUIDATED, // the loan will have this status after all installments have been paid
      CANCELLED, // only if loan is LISTED 
      WITHDRAWN // the final status, the collateral returned to the borrower or to the lender
  }
  enum TokenType{ ERC721, ERC1155 }

  event NewLoan(
    uint256 indexed loanId, 
    address indexed owner, 
    uint256 creationDate, 
    address indexed currency, 
    Status status, 
    address[] nftAddressArray, 
    uint256[] nftTokenIdArray,
    TokenType[] nftTokenTypeArray
  );
  event LoanApproved(
    uint256 indexed loanId, 
    address indexed lender, 
    uint256 approvalDate, 
    uint256 loanPaymentEnd, 
    Status status
  );
  event LoanCancelled(
    uint256 indexed loanId, 
    uint256 cancellationDate, 
    Status status
  );
  event ItemsWithdrawn(
    uint256 indexed loanId, 
    address indexed requester, 
    Status status
  );
  event LoanPayment(
    uint256 indexed loanId, 
    uint256 paymentDate, 
    uint256 installmentAmount, 
    uint256 amountPaidAsInstallmentToLender, 
    uint256 interestPerInstallement, 
    uint256 interestToStaterPerInstallement, 
    Status status
  );

  struct Loan {
    address[] nftAddressArray; // the adderess of the ERC721
    address payable borrower; // the address who receives the loan
    address payable lender; // the address who gives/offers the loan to the borrower
    address currency; // the token that the borrower lends, address(0) for ETH
    Status status; // the loan status
    uint256[] nftTokenIdArray; // the unique identifier of the NFT token that the borrower uses as collateral
    uint256 loanAmount; // the amount, denominated in tokens (see next struct entry), the borrower lends
    uint256 assetsValue; // important for determintng LTV which has to be under 50-60%
    uint256 loanStart; // the point when the loan is approved
    uint256 loanEnd; // the point when the loan is approved to the point when it must be paid back to the lender
    uint256 nrOfInstallments; // the number of installments that the borrower must pay.
    uint256 installmentAmount; // amount expected for each installment
    uint256 amountDue; // loanAmount + interest that needs to be paid back by borrower
    uint256 paidAmount; // the amount that has been paid back to the lender to date
    uint256 defaultingLimit; // the number of installments allowed to be missed without getting defaulted
    uint256 nrOfPayments; // the number of installments paid
    TokenType[] nftTokenTypeArray; // the token types : ERC721 , ERC1155 , ...
  }

  mapping(uint256 => Loan) public loans;

  mapping(uint256 => address) public promissoryPermissions;

  constructor(address _nftAddress, address _promissoryNoteContractAddress, address[] memory _geyserAddressArray, uint256[] memory _staterNftTokenIdArray) {
    nftAddress = _nftAddress;
    geyserAddressArray = _geyserAddressArray;
    staterNftTokenIdArray = _staterNftTokenIdArray;
    promissoryNoteContractAddress = _promissoryNoteContractAddress;
  }

  function createLoan(
    uint256 loanAmount,
    uint256 nrOfInstallments,
    address currency,
    uint256 assetsValue, 
    address[] calldata nftAddressArray, 
    uint256[] calldata nftTokenIdArray,
    TokenType[] memory nftTokenTypeArray
  ) external {

    require(nrOfInstallments > 0, "Loan must have at least 1 installment");
    require(loanAmount > 0, "Loan amount must be higher than 0");
    require(nftAddressArray.length > 0, "Loan must have atleast 1 NFT");
    require(nftAddressArray.length == nftTokenIdArray.length && nftTokenIdArray.length == nftTokenTypeArray.length, "NFT provided informations are missing or incomplete");

    require(_percent(loanAmount, assetsValue) <= ltv, "LTV exceeds maximum limit allowed");

    if ( nrOfInstallments <= 3 )
        loans[loanID].defaultingLimit = 1;
    else if ( nrOfInstallments <= 5 )
        loans[loanID].defaultingLimit = 2;
    else if ( nrOfInstallments >= 6 )
        loans[loanID].defaultingLimit = 3;

    loans[loanID].nftTokenIdArray = nftTokenIdArray;
    loans[loanID].loanAmount = loanAmount;
    loans[loanID].assetsValue = assetsValue;
    loans[loanID].amountDue = loanAmount.mul(interestRate.add(100)).div(100); // interest rate >> 20%
    loans[loanID].nrOfInstallments = nrOfInstallments;
    loans[loanID].installmentAmount = loans[loanID].amountDue.mod(nrOfInstallments) > 0 ? loans[loanID].amountDue.div(nrOfInstallments).add(1) : loans[loanID].amountDue.div(nrOfInstallments);
    loans[loanID].status = Status.LISTED;
    loans[loanID].nftAddressArray = nftAddressArray;
    loans[loanID].borrower = msg.sender;
    loans[loanID].currency = currency;
    loans[loanID].nftTokenTypeArray = nftTokenTypeArray;
 
    _transferItems(
        msg.sender, 
        address(this), 
        nftAddressArray, 
        nftTokenIdArray,
        nftTokenTypeArray
    );

    emit NewLoan(loanID, msg.sender, block.timestamp, currency, Status.LISTED, nftAddressArray, nftTokenIdArray, nftTokenTypeArray);
    ++loanID;
  }

  function approveLoan(uint256 loanId) external payable {

    require(loans[loanId].lender == address(0), "Someone else payed for this loan before you");
    require(loans[loanId].paidAmount == 0, "This loan is currently not ready for lenders");
    require(loans[loanId].status == Status.LISTED, "This loan is not currently ready for lenders, check later");
    
    uint256 discount = calculateDiscount(msg.sender);
    
    if ( loans[loanId].currency == address(0) )
      require(msg.value >= loans[loanId].loanAmount.add(loans[loanId].loanAmount.div(lenderFee).div(discount)),"Not enough currency");

    loans[loanId].lender = msg.sender;
    loans[loanId].loanEnd = block.timestamp.add(loans[loanId].nrOfInstallments.mul(generateInstallmentFrequency()));
    loans[loanId].status = Status.APPROVED;
    loans[loanId].loanStart = block.timestamp;

    _transferTokens(msg.sender,loans[loanId].borrower,loans[loanId].currency,loans[loanId].loanAmount,loans[loanId].loanAmount.div(lenderFee).div(discount));

    emit LoanApproved(
      loanId,
      msg.sender,
      block.timestamp,
      loans[loanId].loanEnd,
      Status.APPROVED
    );
  }

  function cancelLoan(uint256 loanId) external {

    require(loans[loanId].lender == address(0), "The loan has a lender , it cannot be cancelled");
    require(loans[loanId].borrower == msg.sender, "You're not the borrower of this loan");
    require(loans[loanId].status != Status.CANCELLED, "This loan is already cancelled");
    require(loans[loanId].status == Status.LISTED, "This loan is no longer cancellable");
    
    loans[loanId].loanEnd = block.timestamp;
    loans[loanId].status = Status.CANCELLED;

    _transferItems(
      address(this), 
      loans[loanId].borrower, 
      loans[loanId].nftAddressArray, 
      loans[loanId].nftTokenIdArray,
      loans[loanId].nftTokenTypeArray
    );

    emit LoanCancelled(
      loanId,
      block.timestamp,
      Status.CANCELLED
    );
  }
  
  function payLoan(uint256 loanId) external payable {

    require(loans[loanId].borrower == msg.sender, "You're not the borrower of this loan");
    require(loans[loanId].status == Status.APPROVED, "This loan is no longer in the approval phase, check its status");
    require(loans[loanId].loanEnd >= block.timestamp, "Loan validity expired");
    require((msg.value > 0 && loans[loanId].currency == address(0) ) || ( loans[loanId].currency != address(0) && msg.value == 0), "Insert the correct tokens");
    
    uint256 paidByBorrower = msg.value > 0 ? msg.value : loans[loanId].installmentAmount;
    uint256 amountPaidAsInstallmentToLender = paidByBorrower; // >> amount of installment that goes to lender
    uint256 interestPerInstallement = paidByBorrower.mul(interestRate).div(100); // entire interest for installment
    uint256 discount = calculateDiscount(msg.sender);
    uint256 interestToStaterPerInstallement = interestPerInstallement.mul(interestRateToStater).div(100);

    if ( discount != 1 ){
        if ( loans[loanId].currency == address(0) ){
            require(msg.sender.send(interestToStaterPerInstallement.div(discount)), "Discount returnation failed");
            amountPaidAsInstallmentToLender = amountPaidAsInstallmentToLender.sub(interestToStaterPerInstallement.div(discount));
        }
        interestToStaterPerInstallement = interestToStaterPerInstallement.sub(interestToStaterPerInstallement.div(discount));
    }
    amountPaidAsInstallmentToLender = amountPaidAsInstallmentToLender.sub(interestToStaterPerInstallement);

    loans[loanId].paidAmount = loans[loanId].paidAmount.add(paidByBorrower);
    loans[loanId].nrOfPayments = loans[loanId].nrOfPayments.add(paidByBorrower.div(loans[loanId].installmentAmount));

    if (loans[loanId].paidAmount >= loans[loanId].amountDue)
      loans[loanId].status = Status.LIQUIDATED;

    _transferTokens(msg.sender,loans[loanId].lender,loans[loanId].currency,amountPaidAsInstallmentToLender,interestToStaterPerInstallement);

    emit LoanPayment(
      loanId,
      block.timestamp,
      msg.value,
      amountPaidAsInstallmentToLender,
      interestPerInstallement,
      interestToStaterPerInstallement,
      loans[loanId].status
    );
  }

  function terminateLoan(uint256 loanId) external {

    require(msg.sender == loans[loanId].borrower || msg.sender == loans[loanId].lender, "You can't access this loan");
    require((block.timestamp >= loans[loanId].loanEnd || loans[loanId].paidAmount >= loans[loanId].amountDue) || lackOfPayment(loanId), "Not possible to finish this loan yet");
    require(loans[loanId].status == Status.LIQUIDATED || loans[loanId].status == Status.APPROVED, "Incorrect state of loan");
    require(loans[loanId].status != Status.WITHDRAWN, "Loan NFTs already withdrawn");

    if ( lackOfPayment(loanId) ) {
      loans[loanId].status = Status.WITHDRAWN;
      loans[loanId].loanEnd = block.timestamp;
      _transferItems(
        address(this),
        loans[loanId].lender,
        loans[loanId].nftAddressArray,
        loans[loanId].nftTokenIdArray,
        loans[loanId].nftTokenTypeArray
      );
    } else {
      if ( block.timestamp >= loans[loanId].loanEnd && loans[loanId].paidAmount < loans[loanId].amountDue ) {
        loans[loanId].status = Status.WITHDRAWN;
        _transferItems(
          address(this),
          loans[loanId].lender,
          loans[loanId].nftAddressArray,
          loans[loanId].nftTokenIdArray,
          loans[loanId].nftTokenTypeArray
        );
      } else if ( loans[loanId].paidAmount >= loans[loanId].amountDue ){
        loans[loanId].status = Status.WITHDRAWN;
        _transferItems(
          address(this),
          loans[loanId].borrower,
          loans[loanId].nftAddressArray,
          loans[loanId].nftTokenIdArray,
          loans[loanId].nftTokenTypeArray
        );
      }
    }
    
    emit ItemsWithdrawn(
      loanId,
      msg.sender,
      loans[loanId].status
    );
  }
  
  function promissoryExchange(uint256[] calldata loanIds, address payable newOwner) external {

      require(msg.sender == promissoryNoteContractAddress, "You're not whitelisted to access this method");
      for (uint256 i = 0; i < loanIds.length; ++i) {
        require(loans[loanIds[i]].lender != address(0), "One of the loans is not approved yet");
        require(promissoryPermissions[loanIds[i]] == msg.sender, "You're not allowed to perform this operation on loan");
        loans[loanIds[i]].lender = newOwner;
      }
  }
  
  function setPromissoryPermissions(uint256[] calldata loanIds) external {

      for (uint256 i = 0; i < loanIds.length; ++i) {
          require(loans[loanIds[i]].lender == msg.sender, "You're not the lender of this loan");
          promissoryPermissions[loanIds[i]] = promissoryNoteContractAddress;
      }
  }

  function calculateDiscount(address requester) public view returns(uint256){

    for (uint i = 0; i < staterNftTokenIdArray.length; ++i)
	    if ( IERC1155(nftAddress).balanceOf(requester,staterNftTokenIdArray[i]) > 0 )
		    return uint256(100).div(discountNft);
	  for (uint256 i = 0; i < geyserAddressArray.length; ++i)
	    if ( Geyser(geyserAddressArray[i]).totalStakedFor(requester) > 0 )
		    return uint256(100).div(discountGeyser);
	  return 1;
  }

  function getLoanApprovalCost(uint256 loanId) external view returns(uint256) {

    return loans[loanId].loanAmount.add(loans[loanId].loanAmount.div(lenderFee).div(calculateDiscount(msg.sender)));
  }
  
  
  function getLoanRemainToPay(uint256 loanId) external view returns(uint256) {

    return loans[loanId].amountDue.sub(loans[loanId].paidAmount);
  }
  
  
  function getLoanInstallmentCost(
      uint256 loanId,
      uint256 nrOfInstallments
  ) external view returns(
      uint256 overallInstallmentAmount,
      uint256 interestPerInstallement,
      uint256 interestDiscounted,
      uint256 interestToStaterPerInstallement,
      uint256 amountPaidAsInstallmentToLender
  ) {

    require(nrOfInstallments <= loans[loanId].nrOfInstallments, "Number of installments too high");
    uint256 discount = calculateDiscount(msg.sender);
    interestDiscounted = 0;
    
    overallInstallmentAmount = uint256(loans[loanId].installmentAmount.mul(nrOfInstallments));
    interestPerInstallement = uint256(overallInstallmentAmount.mul(interestRate).div(100).div(loans[loanId].nrOfInstallments));
    interestDiscounted = interestPerInstallement.mul(interestRateToStater).div(100).div(discount); // amount of interest saved per installment
    interestToStaterPerInstallement = interestPerInstallement.mul(interestRateToStater).div(100).sub(interestDiscounted);
    amountPaidAsInstallmentToLender = interestPerInstallement.mul(uint256(100).sub(interestRateToStater)).div(100); 
  }
  
  function lackOfPayment(uint256 loanId) public view returns(bool) {

    return loans[loanId].status == Status.APPROVED && loans[loanId].loanStart.add(loans[loanId].nrOfPayments.mul(generateInstallmentFrequency())) <= block.timestamp.sub(loans[loanId].defaultingLimit.mul(generateInstallmentFrequency()));
  }

  function generateInstallmentFrequency() public view returns(uint256){

    if (installmentTimeScale == TimeScale.MINUTES) {
      return 1 minutes;  
    } else if (installmentTimeScale == TimeScale.HOURS) {
      return 1 hours;
    } else if (installmentTimeScale == TimeScale.DAYS) {
      return 1 days;
    }
    return 1 weeks;
  }

  function setDiscounts(uint32 _discountNft, uint32 _discountGeyser, address[] calldata _geyserAddressArray, uint256[] calldata _staterNftTokenIdArray, address _nftAddress) external onlyOwner {

    discountNft = _discountNft;
    discountGeyser = _discountGeyser;
    geyserAddressArray = _geyserAddressArray;
    staterNftTokenIdArray = _staterNftTokenIdArray;
    nftAddress = _nftAddress;
  }
  
  function setGlobalVariables(address _promissoryNoteContractAddress, uint256 _ltv, uint256 _installmentFrequency, TimeScale _installmentTimeScale, uint256 _interestRate, uint256 _interestRateToStater, uint32 _lenderFee) external onlyOwner {

    ltv = _ltv;
    installmentFrequency = _installmentFrequency;
    installmentTimeScale = _installmentTimeScale;
    interestRate = _interestRate;
    interestRateToStater = _interestRateToStater;
    lenderFee = _lenderFee;
    promissoryNoteContractAddress = _promissoryNoteContractAddress;
  }
  
  function addGeyserAddress(address geyserAddress) external onlyOwner {

      geyserAddressArray.push(geyserAddress);
  }
  
  function addNftTokenId(uint256 nftId) external onlyOwner {

      staterNftTokenIdArray.push(nftId);
  }

  function _percent(uint256 numerator, uint256 denominator) internal pure returns(uint256) {

    return numerator.mul(10000).div(denominator).add(5).div(10);
  }

  function _transferItems(
    address from, 
    address to, 
    address[] memory nftAddressArray, 
    uint256[] memory nftTokenIdArray,
    TokenType[] memory nftTokenTypeArray
  ) internal {

    uint256 length = nftAddressArray.length;
    require(length == nftTokenIdArray.length && nftTokenTypeArray.length == length, "Token infos provided are invalid");
    for(uint256 i = 0; i < length; ++i) 
        if ( nftTokenTypeArray[i] == TokenType.ERC721 )
            IERC721(nftAddressArray[i]).safeTransferFrom(
                from,
                to,
                nftTokenIdArray[i]
            );
        else
            IERC1155(nftAddressArray[i]).safeTransferFrom(
                from,
                to,
                nftTokenIdArray[i],
                1,
                '0x00'
            );
  }
  
  function _transferTokens(
      address from,
      address payable to,
      address currency,
      uint256 qty1,
      uint256 qty2
  ) internal {

      if ( currency != address(0) ){
          require(IERC20(currency).transferFrom(
              from,
              to, 
              qty1
          ), "Transfer of tokens to receiver failed");
          require(IERC20(currency).transferFrom(
              from,
              owner(), 
              qty2
          ), "Transfer of tokens to Stater failed");
      }else{
          require(to.send(qty1), "Transfer of ETH to receiver failed");
          require(payable(owner()).send(qty2), "Transfer of ETH to Stater failed");
      }
  }

}
