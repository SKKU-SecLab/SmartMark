
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
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
pragma solidity 0.8.10;


interface IFinancialInstrument is IERC721 {

    function principal(uint256 instrumentId) external view returns (uint256);


    function underlyingToken(uint256 instrumentId) external view returns (IERC20);


    function recipient(uint256 instrumentId) external view returns (address);

}// MIT
pragma solidity 0.8.10;


interface IDebtInstrument is IFinancialInstrument {

    function endDate(uint256 instrumentId) external view returns (uint256);


    function repay(uint256 instrumentId, uint256 amount) external;

}// MIT
pragma solidity 0.8.10;


enum BulletLoanStatus {
    Issued,
    FullyRepaid,
    Defaulted,
    Resolved
}

interface IBulletLoans is IDebtInstrument {

    struct LoanMetadata {
        IERC20 underlyingToken;
        BulletLoanStatus status;
        uint256 principal;
        uint256 totalDebt;
        uint256 amountRepaid;
        uint256 duration;
        uint256 repaymentDate;
        address recipient;
    }

    function loans(uint256 id)
        external
        view
        returns (
            IERC20,
            BulletLoanStatus,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );


    function createLoan(
        IERC20 _underlyingToken,
        uint256 principal,
        uint256 totalDebt,
        uint256 duration,
        address recipient
    ) external returns (uint256);


    function markLoanAsDefaulted(uint256 instrumentId) external;


    function markLoanAsResolved(uint256 instrumentId) external;


    function updateLoanParameters(
        uint256 instrumentId,
        uint256 newTotalDebt,
        uint256 newRepaymentDate
    ) external;


    function updateLoanParameters(
        uint256 instrumentId,
        uint256 newTotalDebt,
        uint256 newRepaymentDate,
        bytes memory borrowerSignature
    ) external;

}// MIT
pragma solidity 0.8.10;


interface IERC20WithDecimals is IERC20 {

    function decimals() external view returns (uint256);

}// MIT
pragma solidity 0.8.10;

interface IProtocolConfig {

    function protocolFee() external view returns (uint256);


    function protocolAddress() external view returns (address);

}// MIT

pragma solidity ^0.8.0;

interface IERC20Upgradeable {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}// MIT
pragma solidity 0.8.10;


interface IPortfolio is IERC20Upgradeable {

    function endDate() external view returns (uint256);


    function underlyingToken() external view returns (IERC20WithDecimals);


    function value() external view returns (uint256);


    function deposit(uint256 amount, bytes memory metadata) external;


    function withdraw(uint256 amount, bytes memory metadata) external returns (uint256 withdrawnAmount);

}// MIT
pragma solidity 0.8.10;

interface ILenderVerifier {

    function isAllowed(
        address lender,
        uint256 amount,
        bytes memory signature
    ) external view returns (bool);

}// MIT
pragma solidity 0.8.10;


enum ManagedPortfolioStatus {
    Open,
    Frozen,
    Closed
}

interface IManagedPortfolio is IPortfolio {

    function initialize(
        string memory __name,
        string memory __symbol,
        address _manager,
        IERC20WithDecimals _underlyingToken,
        IBulletLoans _bulletLoans,
        IProtocolConfig _protocolConfig,
        ILenderVerifier _lenderVerifier,
        uint256 _duration,
        uint256 _maxSize,
        uint256 _managerFee
    ) external;


    function managerFee() external view returns (uint256);


    function maxSize() external view returns (uint256);


    function createBulletLoan(
        uint256 loanDuration,
        address borrower,
        uint256 principalAmount,
        uint256 repaymentAmount
    ) external;


    function setEndDate(uint256 newEndDate) external;


    function markLoanAsDefaulted(uint256 instrumentId) external;


    function getStatus() external view returns (ManagedPortfolioStatus);


    function getOpenLoanIds() external view returns (uint256[] memory);

}// MIT
pragma solidity 0.8.10;


struct LoanFrontendData {
    IERC20 token;
    BulletLoanStatus status;
    uint256 principal;
    uint256 totalDebt;
    uint256 amountRepaid;
    uint256 duration;
    uint256 repaymentDate;
    address recipient;
    uint256 loanId;
}

contract LoansReader {

    function getLoans(address bulletLoans, address portfolio) external view returns (LoanFrontendData[] memory) {

        uint256[] memory ids = IManagedPortfolio(portfolio).getOpenLoanIds();
        LoanFrontendData[] memory _loans = new LoanFrontendData[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            (
                IERC20 token,
                BulletLoanStatus status,
                uint256 principal,
                uint256 totalDebt,
                uint256 amountRepaid,
                uint256 duration,
                uint256 repaymentDate,
                address recipient
            ) = IBulletLoans(bulletLoans).loans(ids[i]);
            _loans[i] = LoanFrontendData(
                token,
                status,
                principal,
                totalDebt,
                amountRepaid,
                duration,
                repaymentDate,
                recipient,
                ids[i]
            );
        }
        return _loans;
    }
}