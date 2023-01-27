
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
pragma solidity 0.7.6;


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

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}

pragma solidity >=0.6.0 <0.8.0;


contract ERC721Holder is IERC721Receiver {


    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {

        return this.onERC721Received.selector;
    }
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
pragma solidity 0.7.6;

contract StaterTransfers is Ownable, ERC721Holder, ERC1155Holder {

    

    function transferTokens(
        address from,
        address payable to,
        address currency,
        uint256 qty1,
        uint256 qty2
    ) public {

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


    function transferItems(
        address from, 
        address to, 
        address[] memory nftAddressArray, 
        uint256[] memory nftTokenIdArray,
        uint8[] memory nftTokenTypeArray
    ) public {

        uint256 length = nftAddressArray.length;
        require(length == nftTokenIdArray.length && nftTokenTypeArray.length == length, "Token infos provided are invalid");
        for(uint256 i = 0; i < length; ++i) 
            if ( nftTokenTypeArray[i] == 0 )
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
pragma solidity 0.7.6;


interface IStaterDiscounts {

    function getDiscountTokenId(uint256 _discountId, uint256 tokenIdIndex) external view returns(uint256);

    function calculateDiscount(address requester) external view returns(uint256);

}// MIT
pragma solidity 0.7.6;

contract LendingCore is StaterTransfers {

    using SafeMath for uint256;
    using SafeMath for uint8;
    
    event NewLoan(
        address indexed owner,
        address indexed currency,
        uint256 indexed loanId,
        address[] nftAddressArray,
        uint256[] nftTokenIdArray,
        uint8[] nftTokenTypeArray
    );
    event EditLoan(
        address indexed currency,
        uint256 indexed loanId,
        uint256 loanAmount,
        uint256 amountDue,
        uint256 installmentAmount,
        uint256 assetsValue,
        uint256 frequencyTime,
        uint256 frequencyTimeUnit
    );
    event LoanApproved(
        address indexed lender,
        uint256 indexed loanId,
        uint256 loanPaymentEnd
    );
    event LoanCancelled(
        uint256 indexed loanId
    );
    event ItemsWithdrawn(
        address indexed requester,
        uint256 indexed loanId,
        Status status
    );
    event LoanPayment(
        uint256 indexed loanId,
        uint256 installmentAmount,
        uint256 amountPaidAsInstallmentToLender,
        uint256 interestPerInstallement,
        uint256 interestToStaterPerInstallement,
        Status status
    );
    
    address public promissoryNoteAddress;
    address public lendingMethodsAddress;
    IStaterDiscounts public discounts;
    uint256 public id = 1; // the loan ID
    uint256 public ltv = 60; // 60%
    uint256 public interestRate = 20;
    uint256 public interestRateToStater = 40;
    uint32 public lenderFee = 100;
    enum Status{ 
        LISTED, 
        APPROVED, 
        LIQUIDATED, 
        CANCELLED, 
        WITHDRAWN 
    }
    
    
    struct Loan {
        address[] nftAddressArray; // the adderess of the ERC721
        address payable borrower; // the address who receives the loan
        address payable lender; // the address who gives/offers the loan to the borrower
        address currency; // the token that the borrower lends, address(0) for ETH
        Status status; // the loan status
        uint256[] nftTokenIdArray; // the unique identifier of the NFT token that the borrower uses as collateral
        uint256 installmentTime; // the installment unix timestamp
        uint256 nrOfPayments; // the number of installments paid
        uint256 loanAmount; // the amount, denominated in tokens (see next struct entry), the borrower lends
        uint256 assetsValue; // important for determintng LTV which has to be under 50-60%
        uint256[2] startEnd; // startEnd[0] loan start date , startEnd[1] loan end date
        uint256 installmentAmount; // amount expected for each installment
        uint256 amountDue; // loanAmount + interest that needs to be paid back by borrower
        uint256 paidAmount; // the amount that has been paid back to the lender to date
        uint16 nrOfInstallments; // the number of installments that the borrower must pay.
        uint8 defaultingLimit; // the number of installments allowed to be missed without getting defaulted
        uint8[] nftTokenTypeArray; // the token types : ERC721 , ERC1155 , ...
    }
    
    mapping(uint256 => Loan) public loans;
    
    mapping(uint256 => address) public promissoryPermissions;
    
    modifier isPromissoryNote {

        require(msg.sender == promissoryNoteAddress, "Lending Methods: Access denied");
        _;
    }
    
    function canBeTerminated(uint256 loanId) public view returns(bool) {

        require(loans[loanId].status == Status.APPROVED || loans[loanId].status == Status.LIQUIDATED, "Loan is not yet approved");
        return loans[loanId].startEnd[0].add(loans[loanId].nrOfPayments.mul(loans[loanId].installmentTime)).add(loans[loanId].defaultingLimit.mul(loans[loanId].installmentTime)) <= min(block.timestamp,loans[loanId].startEnd[1]);
    }

    function checkLtv(uint256 loanValue, uint256 assetsValue) public view {

        require(loanValue <= assetsValue.div(100).mul(ltv), "LTV too high");
    }


    function min(uint256 a, uint256 b) internal pure returns(uint256) {

        return a < b ? a : b;
    }

    function getLoanStartEnd(uint256 loanId) external view returns(uint256[2] memory) {

        return loans[loanId].startEnd;
    }

    function getPromissoryPermission(uint256 loanId) external view returns(address) {

        require(loans[loanId].status == Status.APPROVED, "Loan is no longer approved");
        return promissoryPermissions[loanId];
    }

}
pragma solidity 0.7.6;


contract LendingMethods is Ownable, LendingCore {

    using SafeMath for uint256;
    using SafeMath for uint16;
    
    function createLoan(
        uint256 loanAmount,
        uint16 nrOfInstallments,
        address currency,
        uint256 assetsValue,
        address[] calldata nftAddressArray, 
        uint256[] calldata nftTokenIdArray,
        uint8[] calldata nftTokenTypeArray
    ) external {

        require(nrOfInstallments > 0 && loanAmount > 0 && nftAddressArray.length > 0);
        require(nftAddressArray.length == nftTokenIdArray.length && nftTokenIdArray.length == nftTokenTypeArray.length);
        
        loans[id].assetsValue = assetsValue;
        
        checkLtv(loanAmount, loans[id].assetsValue);
        
        if ( nrOfInstallments <= 3 )
            loans[id].defaultingLimit = 1;
        else if ( nrOfInstallments <= 5 )
            loans[id].defaultingLimit = 2;
        else if ( nrOfInstallments >= 6 )
            loans[id].defaultingLimit = 3;
        
        
        loans[id].nftTokenIdArray = nftTokenIdArray;
        loans[id].loanAmount = loanAmount;
        loans[id].amountDue = loanAmount.mul(interestRate.add(100)).div(100); // interest rate >> 20%
        loans[id].nrOfInstallments = nrOfInstallments;
        loans[id].installmentAmount = loans[id].amountDue.mod(nrOfInstallments) > 0 ? loans[id].amountDue.div(nrOfInstallments).add(1) : loans[id].amountDue.div(nrOfInstallments);
        loans[id].status = Status.LISTED;
        loans[id].nftAddressArray = nftAddressArray;
        loans[id].borrower = msg.sender;
        loans[id].currency = currency;
        loans[id].nftTokenTypeArray = nftTokenTypeArray;
        loans[id].installmentTime = 1 weeks;
        
        transferItems(
            msg.sender, 
            address(this), 
            nftAddressArray, 
            nftTokenIdArray,
            nftTokenTypeArray
        );
        
        emit NewLoan(
            msg.sender, 
            currency, 
            id,
            nftAddressArray,
            nftTokenIdArray,
            nftTokenTypeArray
        );
        ++id;
    }


    function editLoan(
        uint256 loanId,
        uint256 loanAmount,
        uint16 nrOfInstallments,
        address currency,
        uint256 assetsValue,
        uint256 installmentTime
    ) external {

        require(nrOfInstallments > 0 && loanAmount > 0);
        require(loans[loanId].borrower == msg.sender);
        require(loans[loanId].status < Status.APPROVED);
        checkLtv(loanAmount, assetsValue);
        

        loans[loanId].installmentTime = installmentTime;
        loans[loanId].loanAmount = loanAmount;
        loans[loanId].amountDue = loanAmount.mul(interestRate.add(100)).div(100);
        loans[loanId].installmentAmount = loans[loanId].amountDue.mod(nrOfInstallments) > 0 ? loans[loanId].amountDue.div(nrOfInstallments).add(1) : loans[loanId].amountDue.div(nrOfInstallments);
        loans[loanId].assetsValue = assetsValue;
        loans[loanId].nrOfInstallments = nrOfInstallments;
        loans[loanId].currency = currency;
        
        
        if ( nrOfInstallments <= 3 )
            loans[loanId].defaultingLimit = 1;
        else if ( nrOfInstallments <= 5 )
            loans[loanId].defaultingLimit = 2;
        else if ( nrOfInstallments >= 6 )
            loans[loanId].defaultingLimit = 3;

        emit EditLoan(
            currency, 
            loanId,
            loanAmount,
            loans[loanId].amountDue,
            loans[loanId].installmentAmount,
            loans[loanId].assetsValue,
            installmentTime,
            nrOfInstallments
        );

    }
    
    function approveLoan(uint256 loanId) external payable {

        require(loans[loanId].lender == address(0));
        require(loans[loanId].paidAmount == 0);
        require(loans[loanId].status == Status.LISTED);
        
        loans[loanId].lender = msg.sender;
        loans[loanId].startEnd[1] = block.timestamp.add(loans[loanId].nrOfInstallments.mul(loans[loanId].installmentTime));
        loans[loanId].status = Status.APPROVED;
        loans[loanId].startEnd[0] = block.timestamp;
        uint256 discount = discounts.calculateDiscount(msg.sender);
        
        if ( loans[loanId].currency == address(0) )
            require(msg.value >= loans[loanId].loanAmount.add(loans[loanId].loanAmount.div(lenderFee).div(discount)));
        
        transferTokens(
            msg.sender,
            payable(loans[loanId].borrower),
            loans[loanId].currency,
            loans[loanId].loanAmount,
            loans[loanId].loanAmount.div(lenderFee).div(discount)
        );
        
        emit LoanApproved(
            msg.sender,
            loanId,
            loans[loanId].startEnd[1]
        );

    }

    function cancelLoan(uint256 loanId) external {

        require(loans[loanId].lender == address(0));
        require(loans[loanId].borrower == msg.sender);
        require(loans[loanId].status != Status.CANCELLED);
        require(loans[loanId].status == Status.LISTED);
        loans[loanId].status = Status.CANCELLED;

        transferItems(
        address(this), 
            loans[loanId].borrower, 
            loans[loanId].nftAddressArray, 
            loans[loanId].nftTokenIdArray,
            loans[loanId].nftTokenTypeArray
        );

        emit LoanCancelled(
            loanId
        );
    }

    function payLoan(uint256 loanId,uint256 amount) external payable {

        require(loans[loanId].borrower == msg.sender);
        require(loans[loanId].status == Status.APPROVED);
        require(loans[loanId].startEnd[1] >= block.timestamp);
        require((msg.value > 0 && loans[loanId].currency == address(0) && msg.value == amount) || (loans[loanId].currency != address(0) && msg.value == 0 && amount > 0));
        
        uint256 paidByBorrower = msg.value > 0 ? msg.value : amount;
        uint256 amountPaidAsInstallmentToLender = paidByBorrower; // >> amount of installment that goes to lender
        uint256 interestPerInstallement = paidByBorrower.mul(interestRate).div(100); // entire interest for installment
        uint256 discount = discounts.calculateDiscount(msg.sender);
        uint256 interestToStaterPerInstallement = interestPerInstallement.mul(interestRateToStater).div(100);

        if ( discount != 1 ){
            if ( loans[loanId].currency == address(0) ){
                require(msg.sender.send(interestToStaterPerInstallement.div(discount)));
                amountPaidAsInstallmentToLender = amountPaidAsInstallmentToLender.sub(interestToStaterPerInstallement.div(discount));
            }
            interestToStaterPerInstallement = interestToStaterPerInstallement.sub(interestToStaterPerInstallement.div(discount));
        }
        amountPaidAsInstallmentToLender = amountPaidAsInstallmentToLender.sub(interestToStaterPerInstallement);

        loans[loanId].paidAmount = loans[loanId].paidAmount.add(paidByBorrower);
        loans[loanId].nrOfPayments = loans[loanId].nrOfPayments.add(paidByBorrower.div(loans[loanId].installmentAmount));

        if (loans[loanId].paidAmount >= loans[loanId].amountDue)
        loans[loanId].status = Status.LIQUIDATED;

        transferTokens(
            msg.sender,
            loans[loanId].lender,
            loans[loanId].currency,
            amountPaidAsInstallmentToLender,
            interestToStaterPerInstallement
        );

        emit LoanPayment(
            loanId,
            paidByBorrower,
            amountPaidAsInstallmentToLender,
            interestPerInstallement,
            interestToStaterPerInstallement,
            loans[loanId].status
        );
    }

    function terminateLoan(uint256 loanId) external {

        require(msg.sender == loans[loanId].borrower || msg.sender == loans[loanId].lender);
        require(loans[loanId].status != Status.WITHDRAWN);
        require((block.timestamp >= loans[loanId].startEnd[1] || loans[loanId].paidAmount >= loans[loanId].amountDue) || canBeTerminated(loanId));
        require(loans[loanId].status == Status.LIQUIDATED || loans[loanId].status == Status.APPROVED);

        if ( canBeTerminated(loanId) ) {
            loans[loanId].status = Status.WITHDRAWN;
            transferItems(
                address(this),
                loans[loanId].lender,
                loans[loanId].nftAddressArray,
                loans[loanId].nftTokenIdArray,
                loans[loanId].nftTokenTypeArray
            );
        } else {
            if ( block.timestamp >= loans[loanId].startEnd[1] && loans[loanId].paidAmount < loans[loanId].amountDue ) {
                loans[loanId].status = Status.WITHDRAWN;
                transferItems(
                    address(this),
                    loans[loanId].lender,
                    loans[loanId].nftAddressArray,
                    loans[loanId].nftTokenIdArray,
                    loans[loanId].nftTokenTypeArray
                );
            } else if ( loans[loanId].paidAmount >= loans[loanId].amountDue ){
                loans[loanId].status = Status.WITHDRAWN;
                transferItems(
                    address(this),
                    loans[loanId].borrower,
                    loans[loanId].nftAddressArray,
                    loans[loanId].nftTokenIdArray,
                    loans[loanId].nftTokenTypeArray
                );
            }
        }
        
        emit ItemsWithdrawn(
            msg.sender,
            loanId,
            loans[loanId].status
        );
    }
    
    function promissoryExchange(address from, address payable to, uint256[] calldata loanIds) external isPromissoryNote {

        for (uint256 i = 0; i < loanIds.length; ++i) {
            require(loans[loanIds[i]].lender == from);
            require(loans[loanIds[i]].status == Status.APPROVED);
            require(promissoryPermissions[loanIds[i]] == from);
            loans[loanIds[i]].lender = to;
            promissoryPermissions[loanIds[i]] = to;
        }
    }
  
     function setPromissoryPermissions(uint256[] calldata loanIds, address allowed) external {

        require(allowed != address(0));
        for (uint256 i = 0; i < loanIds.length; ++i) {
            require(loans[loanIds[i]].lender == msg.sender);
            require(loans[loanIds[i]].status == Status.APPROVED);
            promissoryPermissions[loanIds[i]] = allowed;
        }
    }
}
