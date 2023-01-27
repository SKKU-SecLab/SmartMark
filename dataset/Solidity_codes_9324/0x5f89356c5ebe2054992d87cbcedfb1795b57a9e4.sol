pragma solidity ^0.5.16;



contract KineControllerInterface {

    bool public constant isController = true;

    function getOracle() external view returns (address);



    function enterMarkets(address[] calldata kTokens) external;


    function exitMarket(address kToken) external;



    function mintAllowed(address kToken, address minter, uint mintAmount) external returns (bool, string memory);


    function mintVerify(address kToken, address minter, uint mintAmount, uint mintTokens) external;


    function redeemAllowed(address kToken, address redeemer, uint redeemTokens) external returns (bool, string memory);


    function redeemVerify(address kToken, address redeemer, uint redeemTokens) external;


    function borrowAllowed(address kToken, address borrower, uint borrowAmount) external returns (bool, string memory);


    function borrowVerify(address kToken, address borrower, uint borrowAmount) external;


    function repayBorrowAllowed(
        address kToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (bool, string memory);


    function repayBorrowVerify(
        address kToken,
        address payer,
        address borrower,
        uint repayAmount) external;


    function liquidateBorrowAllowed(
        address kTokenBorrowed,
        address kTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (bool, string memory);


    function liquidateBorrowVerify(
        address kTokenBorrowed,
        address kTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount,
        uint seizeTokens) external;


    function seizeAllowed(
        address kTokenCollateral,
        address kTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (bool, string memory);


    function seizeVerify(
        address kTokenCollateral,
        address kTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external;


    function transferAllowed(address kToken, address src, address dst, uint transferTokens) external returns (bool, string memory);


    function transferVerify(address kToken, address src, address dst, uint transferTokens) external;



    function liquidateCalculateSeizeTokens(
        address target,
        address kTokenBorrowed,
        address kTokenCollateral,
        uint repayAmount) external view returns (uint);

}pragma solidity ^0.5.16;


contract KTokenStorage {

    bool internal _notEntered;

    bool public initialized;

    string public name;

    string public symbol;

    uint8 public decimals;

    address payable public admin;

    address payable public pendingAdmin;

    KineControllerInterface public controller;

    uint public totalSupply;

    mapping (address => uint) internal accountTokens;

    mapping (address => mapping (address => uint)) internal transferAllowances;

}

contract KTokenInterface is KTokenStorage {

    bool public constant isKToken = true;



    event Mint(address minter, uint mintAmount, uint mintTokens);

    event Redeem(address redeemer, uint redeemTokens);



    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    event NewController(KineControllerInterface oldController, KineControllerInterface newController);

    event Transfer(address indexed from, address indexed to, uint amount);

    event Approval(address indexed owner, address indexed spender, uint amount);



    function transfer(address dst, uint amount) external returns (bool);

    function transferFrom(address src, address dst, uint amount) external returns (bool);

    function approve(address spender, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function getAccountSnapshot(address account) external view returns (uint, uint);

    function getCash() external view returns (uint);

    function seize(address liquidator, address borrower, uint seizeTokens) external;




    function _setPendingAdmin(address payable newPendingAdmin) external;

    function _acceptAdmin() external;

    function _setController(KineControllerInterface newController) public;

}

contract KErc20Storage {

    address public underlying;
}

contract KErc20Interface is KErc20Storage {



    function mint(uint mintAmount) external returns (uint);

    function redeem(uint redeemTokens) external;


}

contract KDelegationStorage {

    address public implementation;
}

contract KDelegatorInterface is KDelegationStorage {

    event NewImplementation(address oldImplementation, address newImplementation);

    function _setImplementation(address implementation_, bool allowResign, bytes memory becomeImplementationData) public;

}

contract KDelegateInterface is KDelegationStorage {

    function _becomeImplementation(bytes memory data) public;


    function _resignImplementation() public;

}pragma solidity ^0.5.16;



contract ControllerErrorReporter {

    string internal constant MARKET_NOT_LISTED = "MARKET_NOT_LISTED";
    string internal constant MARKET_ALREADY_LISTED = "MARKET_ALREADY_LISTED";
    string internal constant MARKET_ALREADY_ADDED = "MARKET_ALREADY_ADDED";
    string internal constant EXIT_MARKET_BALANCE_OWED = "EXIT_MARKET_BALANCE_OWED";
    string internal constant EXIT_MARKET_REJECTION = "EXIT_MARKET_REJECTION";
    string internal constant MINT_PAUSED = "MINT_PAUSED";
    string internal constant BORROW_PAUSED = "BORROW_PAUSED";
    string internal constant SEIZE_PAUSED = "SEIZE_PAUSED";
    string internal constant TRANSFER_PAUSED = "TRANSFER_PAUSED";
    string internal constant MARKET_BORROW_CAP_REACHED = "MARKET_BORROW_CAP_REACHED";
    string internal constant MARKET_SUPPLY_CAP_REACHED = "MARKET_SUPPLY_CAP_REACHED";
    string internal constant REDEEM_TOKENS_ZERO = "REDEEM_TOKENS_ZERO";
    string internal constant INSUFFICIENT_LIQUIDITY = "INSUFFICIENT_LIQUIDITY";
    string internal constant INSUFFICIENT_SHORTFALL = "INSUFFICIENT_SHORTFALL";
    string internal constant TOO_MUCH_REPAY = "TOO_MUCH_REPAY";
    string internal constant CONTROLLER_MISMATCH = "CONTROLLER_MISMATCH";
    string internal constant INVALID_COLLATERAL_FACTOR = "INVALID_COLLATERAL_FACTOR";
    string internal constant INVALID_CLOSE_FACTOR = "INVALID_CLOSE_FACTOR";
    string internal constant INVALID_LIQUIDATION_INCENTIVE = "INVALID_LIQUIDATION_INCENTIVE";
}

contract KTokenErrorReporter {

    string internal constant BAD_INPUT = "BAD_INPUT";
    string internal constant TRANSFER_NOT_ALLOWED = "TRANSFER_NOT_ALLOWED";
    string internal constant TRANSFER_NOT_ENOUGH = "TRANSFER_NOT_ENOUGH";
    string internal constant TRANSFER_TOO_MUCH = "TRANSFER_TOO_MUCH";
    string internal constant MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED = "MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED";
    string internal constant MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED = "MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED";
    string internal constant REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED = "REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED";
    string internal constant REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED = "REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED";
    string internal constant BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED = "BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED";
    string internal constant BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED = "BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED";
    string internal constant REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED = "REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED";
    string internal constant REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED = "REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED";
    string internal constant INVALID_CLOSE_AMOUNT_REQUESTED = "INVALID_CLOSE_AMOUNT_REQUESTED";
    string internal constant LIQUIDATE_SEIZE_TOO_MUCH = "LIQUIDATE_SEIZE_TOO_MUCH";
    string internal constant TOKEN_INSUFFICIENT_CASH = "TOKEN_INSUFFICIENT_CASH";
    string internal constant INVALID_ACCOUNT_PAIR = "INVALID_ACCOUNT_PAIR";
    string internal constant LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED = "LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED";
    string internal constant LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED = "LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED";
    string internal constant TOKEN_TRANSFER_IN_FAILED = "TOKEN_TRANSFER_IN_FAILED";
    string internal constant TOKEN_TRANSFER_IN_OVERFLOW = "TOKEN_TRANSFER_IN_OVERFLOW";
    string internal constant TOKEN_TRANSFER_OUT_FAILED = "TOKEN_TRANSFER_OUT_FAILED";

}pragma solidity ^0.5.0;



library KineSafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function add(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, errorMessage);

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

    function mul(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, errorMessage);

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
}pragma solidity ^0.5.16;




contract Exponential {

    using KineSafeMath for uint;
    uint constant expScale = 1e18;
    uint constant doubleScale = 1e36;
    uint constant halfExpScale = expScale / 2;
    uint constant mantissaOne = expScale;

    struct Exp {
        uint mantissa;
    }

    struct Double {
        uint mantissa;
    }

    function getExp(uint num, uint denom) pure internal returns (Exp memory) {

        uint rational = num.mul(expScale).div(denom);
        return Exp({mantissa : rational});
    }

    function addExp(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        uint result = a.mantissa.add(b.mantissa);
        return Exp({mantissa : result});
    }

    function subExp(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        uint result = a.mantissa.sub(b.mantissa);
        return Exp({mantissa : result});
    }

    function mulScalar(Exp memory a, uint scalar) pure internal returns (Exp memory) {

        uint scaledMantissa = a.mantissa.mul(scalar);
        return Exp({mantissa : scaledMantissa});
    }

    function mulScalarTruncate(Exp memory a, uint scalar) pure internal returns (uint) {

        Exp memory product = mulScalar(a, scalar);
        return truncate(product);
    }

    function mulScalarTruncateAddUInt(Exp memory a, uint scalar, uint addend) pure internal returns (uint) {

        Exp memory product = mulScalar(a, scalar);
        return truncate(product).add(addend);
    }

    function divScalar(Exp memory a, uint scalar) pure internal returns (Exp memory) {

        uint descaledMantissa = a.mantissa.div(scalar);
        return Exp({mantissa : descaledMantissa});
    }

    function divScalarByExp(uint scalar, Exp memory divisor) pure internal returns (Exp memory) {

        uint numerator = expScale.mul(scalar);
        return getExp(numerator, divisor.mantissa);
    }

    function divScalarByExpTruncate(uint scalar, Exp memory divisor) pure internal returns (uint) {

        Exp memory fraction = divScalarByExp(scalar, divisor);
        return truncate(fraction);
    }

    function mulExp(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        uint doubleScaledProduct = a.mantissa.mul(b.mantissa);

        uint doubleScaledProductWithHalfScale = halfExpScale.add(doubleScaledProduct);
        uint product = doubleScaledProductWithHalfScale.div(expScale);
        return Exp({mantissa : product});
    }

    function mulExp(uint a, uint b) pure internal returns (Exp memory) {

        return mulExp(Exp({mantissa : a}), Exp({mantissa : b}));
    }

    function divExp(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return getExp(a.mantissa, b.mantissa);
    }

    function truncate(Exp memory exp) pure internal returns (uint) {

        return exp.mantissa / expScale;
    }

    function lessThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa < right.mantissa;
    }

    function lessThanOrEqualExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa <= right.mantissa;
    }

    function greaterThanExp(Exp memory left, Exp memory right) pure internal returns (bool) {

        return left.mantissa > right.mantissa;
    }

    function isZeroExp(Exp memory value) pure internal returns (bool) {

        return value.mantissa == 0;
    }

    function safe224(uint n, string memory errorMessage) pure internal returns (uint224) {

        require(n < 2 ** 224, errorMessage);
        return uint224(n);
    }

    function safe32(uint n, string memory errorMessage) pure internal returns (uint32) {

        require(n < 2 ** 32, errorMessage);
        return uint32(n);
    }

    function add_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa : add_(a.mantissa, b.mantissa)});
    }

    function add_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa : add_(a.mantissa, b.mantissa)});
    }

    function add_(uint a, uint b) pure internal returns (uint) {

        return add_(a, b, "addition overflow");
    }

    function add_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        uint c = a + b;
        require(c >= a, errorMessage);
        return c;
    }

    function sub_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa : sub_(a.mantissa, b.mantissa)});
    }

    function sub_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa : sub_(a.mantissa, b.mantissa)});
    }

    function sub_(uint a, uint b) pure internal returns (uint) {

        return sub_(a, b, "subtraction underflow");
    }

    function sub_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function mul_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa : mul_(a.mantissa, b.mantissa) / expScale});
    }

    function mul_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa : mul_(a.mantissa, b)});
    }

    function mul_(uint a, Exp memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / expScale;
    }

    function mul_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa : mul_(a.mantissa, b.mantissa) / doubleScale});
    }

    function mul_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa : mul_(a.mantissa, b)});
    }

    function mul_(uint a, Double memory b) pure internal returns (uint) {

        return mul_(a, b.mantissa) / doubleScale;
    }

    function mul_(uint a, uint b) pure internal returns (uint) {

        return mul_(a, b, "multiplication overflow");
    }

    function mul_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        if (a == 0 || b == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, errorMessage);
        return c;
    }

    function div_(Exp memory a, Exp memory b) pure internal returns (Exp memory) {

        return Exp({mantissa : div_(mul_(a.mantissa, expScale), b.mantissa)});
    }

    function div_(Exp memory a, uint b) pure internal returns (Exp memory) {

        return Exp({mantissa : div_(a.mantissa, b)});
    }

    function div_(uint a, Exp memory b) pure internal returns (uint) {

        return div_(mul_(a, expScale), b.mantissa);
    }

    function div_(Double memory a, Double memory b) pure internal returns (Double memory) {

        return Double({mantissa : div_(mul_(a.mantissa, doubleScale), b.mantissa)});
    }

    function div_(Double memory a, uint b) pure internal returns (Double memory) {

        return Double({mantissa : div_(a.mantissa, b)});
    }

    function div_(uint a, Double memory b) pure internal returns (uint) {

        return div_(mul_(a, doubleScale), b.mantissa);
    }

    function div_(uint a, uint b) pure internal returns (uint) {

        return div_(a, b, "divide by zero");
    }

    function div_(uint a, uint b, string memory errorMessage) pure internal returns (uint) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function fraction(uint a, uint b) pure internal returns (Double memory) {

        return Double({mantissa : div_(mul_(a, doubleScale), b)});
    }
}pragma solidity ^0.5.16;


interface EIP20Interface {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);


    function transfer(address dst, uint256 amount) external returns (bool success);


    function transferFrom(address src, address dst, uint256 amount) external returns (bool success);


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}pragma solidity ^0.5.16;


interface EIP20NonStandardInterface {


    function totalSupply() external view returns (uint256);


    function balanceOf(address owner) external view returns (uint256 balance);



    function transfer(address dst, uint256 amount) external;



    function transferFrom(address src, address dst, uint256 amount) external;


    function approve(address spender, uint256 amount) external returns (bool success);


    function allowance(address owner, address spender) external view returns (uint256 remaining);


    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
}pragma solidity ^0.5.16;




contract KToken is KTokenInterface, Exponential, KTokenErrorReporter {

    modifier onlyAdmin(){

        require(msg.sender == admin, "only admin can call this function");
        _;
    }

    function initialize(KineControllerInterface controller_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_) public {

        require(msg.sender == admin, "only admin may initialize the market");
        require(initialized == false, "market may only be initialized once");

        _setController(controller_);

        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        _notEntered = true;
        initialized = true;
    }

    function transferTokens(address spender, address src, address dst, uint tokens) internal {

        (bool allowed, string memory reason) = controller.transferAllowed(address(this), src, dst, tokens);
        require(allowed, reason);

        require(src != dst, BAD_INPUT);

        uint startingAllowance = 0;
        if (spender == src) {
            startingAllowance = uint(- 1);
        } else {
            startingAllowance = transferAllowances[src][spender];
        }

        uint allowanceNew = startingAllowance.sub(tokens, TRANSFER_NOT_ALLOWED);
        uint srcTokensNew = accountTokens[src].sub(tokens, TRANSFER_NOT_ENOUGH);
        uint dstTokensNew = accountTokens[dst].add(tokens, TRANSFER_TOO_MUCH);

        accountTokens[src] = srcTokensNew;
        accountTokens[dst] = dstTokensNew;

        if (startingAllowance != uint(- 1)) {
            transferAllowances[src][spender] = allowanceNew;
        }

        emit Transfer(src, dst, tokens);

        controller.transferVerify(address(this), src, dst, tokens);
    }

    function transfer(address dst, uint256 amount) external nonReentrant returns (bool) {

        transferTokens(msg.sender, msg.sender, dst, amount);
        return true;
    }

    function transferFrom(address src, address dst, uint256 amount) external nonReentrant returns (bool) {

        transferTokens(msg.sender, src, dst, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool) {

        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view returns (uint256) {

        return transferAllowances[owner][spender];
    }

    function balanceOf(address owner) external view returns (uint256) {

        return accountTokens[owner];
    }


    function getAccountSnapshot(address account) external view returns (uint, uint) {

        return (accountTokens[account], 0);
    }

    function getBlockNumber() internal view returns (uint) {

        return block.number;
    }

    function getCash() external view returns (uint) {

        return getCashPrior();
    }

    function mintInternal(uint mintAmount) internal nonReentrant returns (uint) {

        return mintFresh(msg.sender, mintAmount);
    }

    struct MintLocalVars {
        uint mintTokens;
        uint totalSupplyNew;
        uint accountTokensNew;
        uint actualMintAmount;
    }

    function mintFresh(address minter, uint mintAmount) internal returns (uint) {

        (bool allowed, string memory reason) = controller.mintAllowed(address(this), minter, mintAmount);
        require(allowed, reason);

        MintLocalVars memory vars;


        vars.actualMintAmount = doTransferIn(minter, mintAmount);

        vars.mintTokens = vars.actualMintAmount;

        vars.totalSupplyNew = totalSupply.add(vars.mintTokens, MINT_NEW_TOTAL_SUPPLY_CALCULATION_FAILED);
        vars.accountTokensNew = accountTokens[minter].add(vars.mintTokens, MINT_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED);

        totalSupply = vars.totalSupplyNew;
        accountTokens[minter] = vars.accountTokensNew;

        emit Mint(minter, vars.actualMintAmount, vars.mintTokens);
        emit Transfer(address(this), minter, vars.mintTokens);

        controller.mintVerify(address(this), minter, vars.actualMintAmount, vars.mintTokens);

        return vars.actualMintAmount;
    }

    function redeemInternal(uint redeemTokens) internal nonReentrant {

        redeemFresh(msg.sender, redeemTokens);
    }

    struct RedeemLocalVars {
        uint totalSupplyNew;
        uint accountTokensNew;
    }

    function redeemFresh(address payable redeemer, uint redeemTokensIn) internal {

        require(redeemTokensIn != 0, "redeemTokensIn must not be zero");

        RedeemLocalVars memory vars;

        (bool allowed, string memory reason) = controller.redeemAllowed(address(this), redeemer, redeemTokensIn);
        require(allowed, reason);

        vars.totalSupplyNew = totalSupply.sub(redeemTokensIn, REDEEM_NEW_TOTAL_SUPPLY_CALCULATION_FAILED);

        vars.accountTokensNew = accountTokens[redeemer].sub(redeemTokensIn, REDEEM_NEW_ACCOUNT_BALANCE_CALCULATION_FAILED);

        require(getCashPrior() >= redeemTokensIn, TOKEN_INSUFFICIENT_CASH);


        totalSupply = vars.totalSupplyNew;
        accountTokens[redeemer] = vars.accountTokensNew;
        doTransferOut(redeemer, redeemTokensIn);

        emit Transfer(redeemer, address(this), redeemTokensIn);
        emit Redeem(redeemer, redeemTokensIn);

        controller.redeemVerify(address(this), redeemer, redeemTokensIn);
    }

    function seize(address liquidator, address borrower, uint seizeTokens) external nonReentrant {

        seizeInternal(msg.sender, liquidator, borrower, seizeTokens);
    }

    function seizeInternal(address seizerToken, address liquidator, address borrower, uint seizeTokens) internal {

        (bool allowed, string memory reason) = controller.seizeAllowed(address(this), seizerToken, liquidator, borrower, seizeTokens);
        require(allowed, reason);

        require(borrower != liquidator, INVALID_ACCOUNT_PAIR);

        uint borrowerTokensNew = accountTokens[borrower].sub(seizeTokens, LIQUIDATE_SEIZE_BALANCE_DECREMENT_FAILED);

        uint liquidatorTokensNew = accountTokens[liquidator].add(seizeTokens, LIQUIDATE_SEIZE_BALANCE_INCREMENT_FAILED);


        accountTokens[borrower] = borrowerTokensNew;
        accountTokens[liquidator] = liquidatorTokensNew;

        emit Transfer(borrower, liquidator, seizeTokens);

        controller.seizeVerify(address(this), seizerToken, liquidator, borrower, seizeTokens);
    }



    function _setPendingAdmin(address payable newPendingAdmin) external onlyAdmin() {

        address oldPendingAdmin = pendingAdmin;
        pendingAdmin = newPendingAdmin;
        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function _acceptAdmin() external {

        require(msg.sender == pendingAdmin && msg.sender != address(0), "unauthorized");

        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        admin = pendingAdmin;

        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function _setController(KineControllerInterface newController) public onlyAdmin() {

        KineControllerInterface oldController = controller;
        require(newController.isController(), "marker method returned false");

        controller = newController;

        emit NewController(oldController, newController);
    }

    function getCashPrior() internal view returns (uint);


    function doTransferIn(address from, uint amount) internal returns (uint);


    function doTransferOut(address payable to, uint amount) internal;




    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}pragma solidity ^0.5.16;


contract KMCDStorage {

    bool internal _notEntered;

    bool public initialized;

    address public minter;

    string public name;

    string public symbol;

    uint8 public decimals;

    address payable public admin;

    address payable public pendingAdmin;

    KineControllerInterface public controller;

    mapping(address => mapping(address => uint)) internal transferAllowances;

    uint public totalBorrows;

    mapping(address => uint) internal accountBorrows;
}

contract KMCDInterface is KMCDStorage {

    bool public constant isKToken = true;



    event Borrow(address borrower, uint borrowAmount, uint accountBorrows, uint totalBorrows);

    event RepayBorrow(address payer, address borrower, uint repayAmount, uint accountBorrows, uint totalBorrows);

    event LiquidateBorrow(address liquidator, address borrower, uint repayAmount, address kTokenCollateral, uint seizeTokens);



    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    event NewController(KineControllerInterface oldController, KineControllerInterface newController);

    event NewMinter(address oldMinter, address newMinter);



    function getAccountSnapshot(address account) external view returns (uint, uint);


    function borrowBalance(address account) public view returns (uint);



    function _setPendingAdmin(address payable newPendingAdmin) external;


    function _acceptAdmin() external;


    function _setController(KineControllerInterface newController) public;

}pragma solidity ^0.5.16;




contract KMCD is KMCDInterface, Exponential, KTokenErrorReporter {

    modifier onlyAdmin(){

        require(msg.sender == admin, "only admin can call this function");
        _;
    }

    modifier onlyMinter {

        require(
            msg.sender == minter,
            "Only minter can call this function."
        );
        _;
    }

    function initialize(KineControllerInterface controller_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        address minter_) public {

        require(msg.sender == admin, "only admin may initialize the market");
        require(initialized == false, "market may only be initialized once");

        _setController(controller_);

        minter = minter_;
        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        _notEntered = true;
        initialized = true;
    }


    function borrowBehalf(address payable borrower, uint borrowAmount) onlyMinter external {

        borrowInternal(borrower, borrowAmount);
    }

    function repayBorrowBehalf(address borrower, uint repayAmount) onlyMinter external {

        repayBorrowBehalfInternal(borrower, repayAmount);
    }

    function liquidateBorrowBehalf(address liquidator, address borrower, uint repayAmount, KTokenInterface kTokenCollateral, uint minSeizeKToken) onlyMinter external {

        liquidateBorrowInternal(liquidator, borrower, repayAmount, kTokenCollateral, minSeizeKToken);
    }

    function getAccountSnapshot(address account) external view returns (uint, uint) {

        return (0, accountBorrows[account]);
    }

    function getBlockNumber() internal view returns (uint) {

        return block.number;
    }

    function borrowBalance(address account) public view returns (uint) {

        return accountBorrows[account];
    }

    function borrowInternal(address payable borrower, uint borrowAmount) internal nonReentrant {

        borrowFresh(borrower, borrowAmount);
    }

    struct BorrowLocalVars {
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
    }

    function borrowFresh(address payable borrower, uint borrowAmount) internal {

        (bool allowed, string memory reason) = controller.borrowAllowed(address(this), borrower, borrowAmount);
        require(allowed, reason);

        BorrowLocalVars memory vars;

        vars.accountBorrows = accountBorrows[borrower];

        vars.accountBorrowsNew = vars.accountBorrows.add(borrowAmount, BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED);
        vars.totalBorrowsNew = totalBorrows.add(borrowAmount, BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED);

        accountBorrows[borrower] = vars.accountBorrowsNew;
        totalBorrows = vars.totalBorrowsNew;

        emit Borrow(borrower, borrowAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

        controller.borrowVerify(address(this), borrower, borrowAmount);
    }

    function repayBorrowBehalfInternal(address borrower, uint repayAmount) internal nonReentrant returns (uint) {

        return repayBorrowFresh(msg.sender, borrower, repayAmount);
    }

    struct RepayBorrowLocalVars {
        uint accountBorrows;
        uint accountBorrowsNew;
        uint totalBorrowsNew;
    }

    function repayBorrowFresh(address payer, address borrower, uint repayAmount) internal returns (uint) {

        (bool allowed, string memory reason) = controller.repayBorrowAllowed(address(this), payer, borrower, repayAmount);
        require(allowed, reason);

        RepayBorrowLocalVars memory vars;

        vars.accountBorrows = accountBorrows[borrower];

        vars.accountBorrowsNew = vars.accountBorrows.sub(repayAmount, REPAY_BORROW_NEW_ACCOUNT_BORROW_BALANCE_CALCULATION_FAILED);
        vars.totalBorrowsNew = totalBorrows.sub(repayAmount, REPAY_BORROW_NEW_TOTAL_BALANCE_CALCULATION_FAILED);

        accountBorrows[borrower] = vars.accountBorrowsNew;
        totalBorrows = vars.totalBorrowsNew;

        emit RepayBorrow(payer, borrower, repayAmount, vars.accountBorrowsNew, vars.totalBorrowsNew);

        controller.repayBorrowVerify(address(this), payer, borrower, repayAmount);

        return repayAmount;
    }

    function liquidateBorrowInternal(address liquidator, address borrower, uint repayAmount, KTokenInterface kTokenCollateral, uint minSeizeKToken) internal nonReentrant returns (uint) {

        return liquidateBorrowFresh(liquidator, borrower, repayAmount, kTokenCollateral, minSeizeKToken);
    }

    function liquidateBorrowFresh(address liquidator, address borrower, uint repayAmount, KTokenInterface kTokenCollateral, uint minSeizeKToken) internal returns (uint) {

        require(address(kTokenCollateral) != address(this), "Kine MCD can't be seized");

        (bool allowed, string memory reason) = controller.liquidateBorrowAllowed(address(this), address(kTokenCollateral), liquidator, borrower, repayAmount);
        require(allowed, reason);

        require(borrower != liquidator, INVALID_ACCOUNT_PAIR);

        require(repayAmount != 0, INVALID_CLOSE_AMOUNT_REQUESTED);

        require(repayAmount != uint(- 1), INVALID_CLOSE_AMOUNT_REQUESTED);


        uint seizeTokens = controller.liquidateCalculateSeizeTokens(borrower, address(this), address(kTokenCollateral), repayAmount);

        require(seizeTokens >= minSeizeKToken, "Reach minSeizeKToken limit");

        require(kTokenCollateral.balanceOf(borrower) >= seizeTokens, LIQUIDATE_SEIZE_TOO_MUCH);

        repayBorrowFresh(liquidator, borrower, repayAmount);

        kTokenCollateral.seize(liquidator, borrower, seizeTokens);

        emit LiquidateBorrow(liquidator, borrower, repayAmount, address(kTokenCollateral), seizeTokens);

        controller.liquidateBorrowVerify(address(this), address(kTokenCollateral), liquidator, borrower, repayAmount, seizeTokens);

        return repayAmount;
    }


    function _setPendingAdmin(address payable newPendingAdmin) external onlyAdmin() {

        address oldPendingAdmin = pendingAdmin;

        pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function _acceptAdmin() external {

        require(msg.sender == pendingAdmin && msg.sender != address(0), "unauthorized");

        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        admin = pendingAdmin;

        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function _setController(KineControllerInterface newController) public onlyAdmin() {

        KineControllerInterface oldController = controller;
        require(newController.isController(), "marker method returned false");

        controller = newController;

        emit NewController(oldController, newController);
    }

    function _setMinter(address newMinter) public onlyAdmin() {

        address oldMinter = minter;
        minter = newMinter;

        emit NewMinter(oldMinter, newMinter);
    }


    modifier nonReentrant() {

        require(_notEntered, "re-entered");
        _notEntered = false;
        _;
        _notEntered = true;
    }
}pragma solidity ^0.5.16;
pragma experimental ABIEncoderV2;

interface KineOracleInterface {


    function getUnderlyingPrice(address kToken) external view returns (uint);


    function postPrices(bytes[] calldata messages, bytes[] calldata signatures, string[] calldata symbols) external;


    function postMcdPrice(uint mcdPrice) external;


    function reporter() external returns (address);

}pragma solidity ^0.5.16;




contract UnitrollerAdminStorage {

    address public admin;

    address public pendingAdmin;

    address public controllerImplementation;

    address public pendingControllerImplementation;
}

contract ControllerStorage is UnitrollerAdminStorage {


    struct Market {
        bool isListed;

        uint collateralFactorMantissa;

        mapping(address => bool) accountMembership;
    }

    KineOracleInterface public oracle;

    uint public closeFactorMantissa;

    uint public liquidationIncentiveMantissa;

    uint public maxAssets;

    mapping(address => KToken[]) public accountAssets;

    mapping(address => Market) public markets;

    KToken[] public allMarkets;

    address public pauseGuardian;
    address public capGuardian;
    bool public transferGuardianPaused;
    bool public seizeGuardianPaused;
    mapping(address => bool) public mintGuardianPaused;
    mapping(address => bool) public borrowGuardianPaused;

    mapping(address => uint) public borrowCaps;
    mapping(address => uint) public supplyCaps;

    bool public redemptionPaused;

    uint public redemptionInitialPunishmentMantissa;

    mapping(address => bool) public redemptionPausedPerAsset;
}pragma solidity ^0.5.16;



contract Unitroller is UnitrollerAdminStorage {


    event NewPendingImplementation(address oldPendingImplementation, address newPendingImplementation);

    event NewImplementation(address oldImplementation, address newImplementation);

    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    constructor() public {
        admin = msg.sender;
    }

    function _setPendingImplementation(address newPendingImplementation) public {

        require(msg.sender == admin, "unauthorized");

        address oldPendingImplementation = pendingControllerImplementation;

        pendingControllerImplementation = newPendingImplementation;

        emit NewPendingImplementation(oldPendingImplementation, pendingControllerImplementation);
    }

    function _acceptImplementation() public {

        require(pendingControllerImplementation != address(0) && msg.sender == pendingControllerImplementation, "unauthorized");

        address oldImplementation = controllerImplementation;
        address oldPendingImplementation = pendingControllerImplementation;

        controllerImplementation = pendingControllerImplementation;

        pendingControllerImplementation = address(0);

        emit NewImplementation(oldImplementation, controllerImplementation);
        emit NewPendingImplementation(oldPendingImplementation, pendingControllerImplementation);
    }


    function _setPendingAdmin(address newPendingAdmin) public {

        require(msg.sender == admin, "unauthorized");

        address oldPendingAdmin = pendingAdmin;

        pendingAdmin = newPendingAdmin;

        emit NewPendingAdmin(oldPendingAdmin, newPendingAdmin);
    }

    function _acceptAdmin() public {

        require(msg.sender == pendingAdmin && msg.sender != address(0), "unauthorized");

        address oldAdmin = admin;
        address oldPendingAdmin = pendingAdmin;

        admin = pendingAdmin;

        pendingAdmin = address(0);

        emit NewAdmin(oldAdmin, admin);
        emit NewPendingAdmin(oldPendingAdmin, pendingAdmin);
    }

    function () payable external {
        (bool success, ) = controllerImplementation.delegatecall(msg.data);

        assembly {
              let free_mem_ptr := mload(0x40)
              returndatacopy(free_mem_ptr, 0, returndatasize)

              switch success
              case 0 { revert(free_mem_ptr, returndatasize) }
              default { return(free_mem_ptr, returndatasize) }
        }
    }
}pragma solidity ^0.5.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
    }
}pragma solidity ^0.5.16;




contract ControllerV2 is ControllerStorage, KineControllerInterface, Exponential, ControllerErrorReporter {

    event MarketListed(KToken kToken);

    event MarketEntered(KToken kToken, address account);

    event MarketExited(KToken kToken, address account);

    event NewCloseFactor(uint oldCloseFactorMantissa, uint newCloseFactorMantissa);

    event NewCollateralFactor(KToken kToken, uint oldCollateralFactorMantissa, uint newCollateralFactorMantissa);

    event NewLiquidationIncentive(uint oldLiquidationIncentiveMantissa, uint newLiquidationIncentiveMantissa);

    event NewRedemptionInitialPunishment(uint oldRedemptionInitialPunishmentMantissa, uint newRedemptionInitialPunishmentMantissa);

    event NewPriceOracle(KineOracleInterface oldPriceOracle, KineOracleInterface newPriceOracle);

    event NewPauseGuardian(address oldPauseGuardian, address newPauseGuardian);

    event ActionPaused(string action, bool pauseState);

    event ActionPaused(KToken kToken, string action, bool pauseState);

    event NewBorrowCap(KToken indexed kToken, uint newBorrowCap);

    event NewSupplyCap(KToken indexed kToken, uint newSupplyCap);

    event NewCapGuardian(address oldCapGuardian, address newCapGuardian);

    uint internal constant closeFactorMinMantissa = 0.05e18; // 0.05

    uint internal constant closeFactorMaxMantissa = 0.9e18; // 0.9

    uint internal constant liquidationIncentiveMinMantissa = 1.0e18; // 1.0

    uint internal constant liquidationIncentiveMaxMantissa = 1.5e18; // 1.5

    uint internal constant collateralFactorMaxMantissa = 0.9e18; // 0.9

    constructor() public {
        admin = msg.sender;
    }

    modifier onlyAdmin() {

        require(msg.sender == admin, "only admin can call this function");
        _;
    }


    function getAssetsIn(address account) external view returns (KToken[] memory) {

        KToken[] memory assetsIn = accountAssets[account];

        return assetsIn;
    }

    function checkMembership(address account, KToken kToken) external view returns (bool) {

        return markets[address(kToken)].accountMembership[account];
    }

    function enterMarkets(address[] memory kTokens) public {

        uint len = kTokens.length;
        for (uint i = 0; i < len; i++) {
            KToken kToken = KToken(kTokens[i]);
            addToMarketInternal(kToken, msg.sender);
        }
    }

    function addToMarketInternal(KToken kToken, address borrower) internal {

        Market storage marketToJoin = markets[address(kToken)];

        require(marketToJoin.isListed, MARKET_NOT_LISTED);

        if (marketToJoin.accountMembership[borrower] == true) {
            return;
        }

        marketToJoin.accountMembership[borrower] = true;
        accountAssets[borrower].push(kToken);

        emit MarketEntered(kToken, borrower);
    }

    function exitMarket(address kTokenAddress) external {

        KToken kToken = KToken(kTokenAddress);
        (uint tokensHeld, uint amountOwed) = kToken.getAccountSnapshot(msg.sender);

        require(amountOwed == 0, EXIT_MARKET_BALANCE_OWED);

        (bool allowed,) = redeemAllowedInternal(kTokenAddress, msg.sender, tokensHeld);
        require(allowed, EXIT_MARKET_REJECTION);

        Market storage marketToExit = markets[address(kToken)];

        if (!marketToExit.accountMembership[msg.sender]) {
            return;
        }

        delete marketToExit.accountMembership[msg.sender];

        KToken[] memory userAssetList = accountAssets[msg.sender];
        uint len = userAssetList.length;
        uint assetIndex = len;
        for (uint i = 0; i < len; i++) {
            if (userAssetList[i] == kToken) {
                assetIndex = i;
                break;
            }
        }

        require(assetIndex < len, "accountAssets array broken");

        KToken[] storage storedList = accountAssets[msg.sender];
        if (assetIndex != storedList.length - 1) {
            storedList[assetIndex] = storedList[storedList.length - 1];
        }
        storedList.length--;

        emit MarketExited(kToken, msg.sender);
    }


    function mintAllowed(address kToken, address minter, uint mintAmount) external returns (bool allowed, string memory reason) {

        if (mintGuardianPaused[kToken]) {
            allowed = false;
            reason = MINT_PAUSED;
            return (allowed, reason);
        }

        uint supplyCap = supplyCaps[kToken];
        if (supplyCap != 0) {
            uint totalSupply = KToken(kToken).totalSupply();
            uint nextTotalSupply = totalSupply.add(mintAmount);
            if (nextTotalSupply > supplyCap) {
                allowed = false;
                reason = MARKET_SUPPLY_CAP_REACHED;
                return (allowed, reason);
            }
        }

        minter;

        if (!markets[kToken].isListed) {
            allowed = false;
            reason = MARKET_NOT_LISTED;
            return (allowed, reason);
        }

        allowed = true;
        return (allowed, reason);
    }

    function mintVerify(address kToken, address minter, uint actualMintAmount, uint mintTokens) external {

        kToken;
        minter;
        actualMintAmount;
        mintTokens;

        if (false) {
            maxAssets = maxAssets;
        }
    }

    function redeemAllowed(address kToken, address redeemer, uint redeemTokens) external returns (bool allowed, string memory reason) {

        return redeemAllowedInternal(kToken, redeemer, redeemTokens);
    }

    function redeemAllowedInternal(address kToken, address redeemer, uint redeemTokens) internal view returns (bool allowed, string memory reason) {

        if (!markets[kToken].isListed) {
            allowed = false;
            reason = MARKET_NOT_LISTED;
            return (allowed, reason);
        }

        if (!markets[kToken].accountMembership[redeemer]) {
            allowed = true;
            return (allowed, reason);
        }

        (, uint shortfall,,) = getHypotheticalAccountLiquidityInternal(redeemer, KToken(kToken), redeemTokens, 0);
        if (shortfall > 0) {
            allowed = false;
            reason = INSUFFICIENT_LIQUIDITY;
            return (allowed, reason);
        }

        allowed = true;
        return (allowed, reason);
    }

    function redeemVerify(address kToken, address redeemer, uint redeemTokens) external {

        kToken;
        redeemer;

        require(redeemTokens != 0, REDEEM_TOKENS_ZERO);
    }

    function borrowAllowed(address kToken, address borrower, uint borrowAmount) external returns (bool allowed, string memory reason) {

        if (borrowGuardianPaused[kToken]) {
            allowed = false;
            reason = BORROW_PAUSED;
            return (allowed, reason);
        }

        if (!markets[kToken].isListed) {
            allowed = false;
            reason = MARKET_NOT_LISTED;
            return (allowed, reason);
        }

        if (!markets[kToken].accountMembership[borrower]) {
            require(msg.sender == kToken, "sender must be kToken");

            addToMarketInternal(KToken(msg.sender), borrower);

            assert(markets[kToken].accountMembership[borrower]);
        }

        require(oracle.getUnderlyingPrice(kToken) != 0, "price error");

        uint borrowCap = borrowCaps[kToken];
        if (borrowCap != 0) {
            uint totalBorrows = KMCD(kToken).totalBorrows();
            uint nextTotalBorrows = totalBorrows.add(borrowAmount);
            if (nextTotalBorrows > borrowCap) {
                allowed = false;
                reason = MARKET_BORROW_CAP_REACHED;
                return (allowed, reason);
            }
        }

        (, uint shortfall,,) = getHypotheticalAccountLiquidityInternal(borrower, KToken(kToken), 0, borrowAmount);
        if (shortfall > 0) {
            allowed = false;
            reason = INSUFFICIENT_LIQUIDITY;
            return (allowed, reason);
        }

        allowed = true;
        return (allowed, reason);
    }

    function borrowVerify(address kToken, address borrower, uint borrowAmount) external {

        kToken;
        borrower;
        borrowAmount;

        if (false) {
            maxAssets = maxAssets;
        }
    }

    function repayBorrowAllowed(
        address kToken,
        address payer,
        address borrower,
        uint repayAmount) external returns (bool allowed, string memory reason) {

        payer;
        borrower;
        repayAmount;

        if (!markets[kToken].isListed) {
            allowed = false;
            reason = MARKET_NOT_LISTED;
        }

        allowed = true;
        return (allowed, reason);
    }

    function repayBorrowVerify(
        address kToken,
        address payer,
        address borrower,
        uint actualRepayAmount) external {

        kToken;
        payer;
        borrower;
        actualRepayAmount;

        if (false) {
            maxAssets = maxAssets;
        }
    }

    function liquidateBorrowAllowed(
        address kTokenBorrowed,
        address kTokenCollateral,
        address liquidator,
        address borrower,
        uint repayAmount) external returns (bool allowed, string memory reason) {

        liquidator;

        if (!markets[kTokenBorrowed].isListed || !markets[kTokenCollateral].isListed) {
            allowed = false;
            reason = MARKET_NOT_LISTED;
            return (allowed, reason);
        }

        if (KToken(kTokenCollateral).controller() != KToken(kTokenBorrowed).controller()) {
            allowed = false;
            reason = CONTROLLER_MISMATCH;
            return (allowed, reason);
        }

        uint borrowBalance = KMCD(kTokenBorrowed).borrowBalance(borrower);
        uint maxClose = mulScalarTruncate(Exp({mantissa : closeFactorMantissa}), borrowBalance);
        if (repayAmount > maxClose) {
            allowed = false;
            reason = TOO_MUCH_REPAY;
            return (allowed, reason);
        }

        allowed = true;
        return (allowed, reason);
    }

    function liquidateBorrowVerify(
        address kTokenBorrowed,
        address kTokenCollateral,
        address liquidator,
        address borrower,
        uint actualRepayAmount,
        uint seizeTokens) external {

        kTokenBorrowed;
        kTokenCollateral;
        liquidator;
        borrower;
        actualRepayAmount;
        seizeTokens;

        if (false) {
            maxAssets = maxAssets;
        }
    }

    function seizeAllowed(
        address kTokenCollateral,
        address kTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external returns (bool allowed, string memory reason) {

        if (seizeGuardianPaused) {
            allowed = false;
            reason = SEIZE_PAUSED;
            return (allowed, reason);
        }

        seizeTokens;
        liquidator;
        borrower;

        if (!markets[kTokenCollateral].isListed || !markets[kTokenBorrowed].isListed) {
            allowed = false;
            reason = MARKET_NOT_LISTED;
            return (allowed, reason);
        }

        if (KToken(kTokenCollateral).controller() != KToken(kTokenBorrowed).controller()) {
            allowed = false;
            reason = CONTROLLER_MISMATCH;
            return (allowed, reason);
        }

        allowed = true;
        return (allowed, reason);
    }

    function seizeVerify(
        address kTokenCollateral,
        address kTokenBorrowed,
        address liquidator,
        address borrower,
        uint seizeTokens) external {

        kTokenCollateral;
        kTokenBorrowed;
        liquidator;
        borrower;
        seizeTokens;

        if (false) {
            maxAssets = maxAssets;
        }
    }

    function transferAllowed(address kToken, address src, address dst, uint transferTokens) external returns (bool allowed, string memory reason) {

        if (transferGuardianPaused) {
            allowed = false;
            reason = TRANSFER_PAUSED;
            return (allowed, reason);
        }

        dst;

        return redeemAllowedInternal(kToken, src, transferTokens);
    }

    function transferVerify(address kToken, address src, address dst, uint transferTokens) external {

        kToken;
        src;
        dst;
        transferTokens;

        if (false) {
            maxAssets = maxAssets;
        }
    }


    struct AccountLiquidityLocalVars {
        uint sumStaking;
        uint sumCollateral;
        uint sumBorrowPlusEffects;
        uint kTokenBalance;
        uint borrowBalance;
        uint oraclePriceMantissa;
        Exp collateralFactor;
        Exp oraclePrice;
        Exp tokensToDenom;
    }

    function getAccountLiquidity(address account) public view returns (uint, uint, uint, uint) {

        return getHypotheticalAccountLiquidityInternal(account, KToken(0), 0, 0);
    }

    function getAccountLiquidityInternal(address account) internal view returns (uint, uint, uint, uint) {

        return getHypotheticalAccountLiquidityInternal(account, KToken(0), 0, 0);
    }

    function getHypotheticalAccountLiquidity(
        address account,
        address kTokenModify,
        uint redeemTokens,
        uint borrowAmount) public view returns (uint, uint) {

        (uint liquidity, uint shortfall,,) = getHypotheticalAccountLiquidityInternal(account, KToken(kTokenModify), redeemTokens, borrowAmount);
        return (liquidity, shortfall);
    }

    function getHypotheticalAccountLiquidityInternal(
        address account,
        KToken kTokenModify,
        uint redeemTokens,
        uint borrowAmount) internal view returns (uint, uint, uint, uint) {


        AccountLiquidityLocalVars memory vars;

        KToken[] memory assets = accountAssets[account];
        for (uint i = 0; i < assets.length; i++) {
            KToken asset = assets[i];

            (vars.kTokenBalance, vars.borrowBalance) = asset.getAccountSnapshot(account);
            vars.collateralFactor = Exp({mantissa : markets[address(asset)].collateralFactorMantissa});

            vars.oraclePriceMantissa = oracle.getUnderlyingPrice(address(asset));
            require(vars.oraclePriceMantissa != 0, "price error");
            vars.oraclePrice = Exp({mantissa : vars.oraclePriceMantissa});

            vars.tokensToDenom = mulExp(vars.collateralFactor, vars.oraclePrice);

            vars.sumStaking = mulScalarTruncateAddUInt(vars.oraclePrice, vars.kTokenBalance, vars.sumStaking);

            vars.sumCollateral = mulScalarTruncateAddUInt(vars.tokensToDenom, vars.kTokenBalance, vars.sumCollateral);

            vars.sumBorrowPlusEffects = mulScalarTruncateAddUInt(vars.oraclePrice, vars.borrowBalance, vars.sumBorrowPlusEffects);

            if (asset == kTokenModify) {
                vars.sumBorrowPlusEffects = mulScalarTruncateAddUInt(vars.tokensToDenom, redeemTokens, vars.sumBorrowPlusEffects);

                vars.sumBorrowPlusEffects = mulScalarTruncateAddUInt(vars.oraclePrice, borrowAmount, vars.sumBorrowPlusEffects);
            }
        }

        if (vars.sumCollateral > vars.sumBorrowPlusEffects) {
            return (vars.sumCollateral - vars.sumBorrowPlusEffects, 0, vars.sumStaking, vars.sumCollateral);
        } else {
            return (0, vars.sumBorrowPlusEffects - vars.sumCollateral, vars.sumStaking, vars.sumCollateral);
        }
    }

    function liquidateCalculateSeizeTokens(address target, address kTokenBorrowed, address kTokenCollateral, uint actualRepayAmount) external view returns (uint) {

        uint priceBorrowedMantissa = oracle.getUnderlyingPrice(kTokenBorrowed);
        uint priceCollateralMantissa = oracle.getUnderlyingPrice(kTokenCollateral);
        require(priceBorrowedMantissa != 0 && priceCollateralMantissa != 0, "price error");

        uint cf = markets[address(kTokenCollateral)].collateralFactorMantissa;

        (uint liquidity, uint shortfall, uint stakingValue, uint collateralValue) = getAccountLiquidityInternal(target);

        uint incentiveOrPunishment;
        if (shortfall > 0) {
            uint r = shortfall.mul(expScale).div(collateralValue).mul(expScale).div(cf);
            incentiveOrPunishment = Math.min(mantissaOne.sub(cf).div(2).add(mantissaOne), r.mul(r).div(expScale).add(liquidationIncentiveMantissa));
        } else {
            require(!redemptionPaused, "Redemption paused");
            require(!redemptionPausedPerAsset[kTokenCollateral], "Asset Redemption paused");
            incentiveOrPunishment = redemptionInitialPunishmentMantissa;
        }

        Exp memory ratio = divExp(mulExp(incentiveOrPunishment, priceBorrowedMantissa), Exp({mantissa : priceCollateralMantissa}));
        return mulScalarTruncate(ratio, actualRepayAmount);
    }


    function _setPriceOracle(KineOracleInterface newOracle) external onlyAdmin() {

        KineOracleInterface oldOracle = oracle;
        oracle = newOracle;
        emit NewPriceOracle(oldOracle, newOracle);
    }

    function _setCloseFactor(uint newCloseFactorMantissa) external onlyAdmin() {

        require(newCloseFactorMantissa <= closeFactorMaxMantissa, INVALID_CLOSE_FACTOR);
        require(newCloseFactorMantissa >= closeFactorMinMantissa, INVALID_CLOSE_FACTOR);

        uint oldCloseFactorMantissa = closeFactorMantissa;
        closeFactorMantissa = newCloseFactorMantissa;
        emit NewCloseFactor(oldCloseFactorMantissa, closeFactorMantissa);
    }

    function _setCollateralFactor(KToken kToken, uint newCollateralFactorMantissa) external onlyAdmin() {

        Market storage market = markets[address(kToken)];
        require(market.isListed, MARKET_NOT_LISTED);

        Exp memory newCollateralFactorExp = Exp({mantissa : newCollateralFactorMantissa});

        Exp memory highLimit = Exp({mantissa : collateralFactorMaxMantissa});
        require(!lessThanExp(highLimit, newCollateralFactorExp), INVALID_COLLATERAL_FACTOR);

        require(newCollateralFactorMantissa == 0 || oracle.getUnderlyingPrice(address(kToken)) != 0, "price error");

        uint oldCollateralFactorMantissa = market.collateralFactorMantissa;
        market.collateralFactorMantissa = newCollateralFactorMantissa;

        emit NewCollateralFactor(kToken, oldCollateralFactorMantissa, newCollateralFactorMantissa);
    }

    function _setLiquidationIncentive(uint newLiquidationIncentiveMantissa) external onlyAdmin() {

        require(newLiquidationIncentiveMantissa <= liquidationIncentiveMaxMantissa, INVALID_LIQUIDATION_INCENTIVE);
        require(newLiquidationIncentiveMantissa >= liquidationIncentiveMinMantissa, INVALID_LIQUIDATION_INCENTIVE);

        uint oldLiquidationIncentiveMantissa = liquidationIncentiveMantissa;
        liquidationIncentiveMantissa = newLiquidationIncentiveMantissa;
        emit NewLiquidationIncentive(oldLiquidationIncentiveMantissa, newLiquidationIncentiveMantissa);
    }

    function _supportMarket(KToken kToken) external onlyAdmin() {

        require(!markets[address(kToken)].isListed, MARKET_ALREADY_LISTED);

        kToken.isKToken();

        markets[address(kToken)] = Market({isListed : true, collateralFactorMantissa : 0});

        _addMarketInternal(address(kToken));

        emit MarketListed(kToken);
    }

    function _addMarketInternal(address kToken) internal {

        for (uint i = 0; i < allMarkets.length; i ++) {
            require(allMarkets[i] != KToken(kToken), MARKET_ALREADY_ADDED);
        }
        allMarkets.push(KToken(kToken));
    }


    function _setMarketBorrowCaps(KToken[] calldata kTokens, uint[] calldata newBorrowCaps) external {

        require(msg.sender == admin || msg.sender == capGuardian, "only admin or cap guardian can set borrow caps");

        uint numMarkets = kTokens.length;
        uint numBorrowCaps = newBorrowCaps.length;

        require(numMarkets != 0 && numMarkets == numBorrowCaps, "invalid input");

        for (uint i = 0; i < numMarkets; i++) {
            borrowCaps[address(kTokens[i])] = newBorrowCaps[i];
            emit NewBorrowCap(kTokens[i], newBorrowCaps[i]);
        }
    }

    function _setMarketSupplyCaps(KToken[] calldata kTokens, uint[] calldata newSupplyCaps) external {

        require(msg.sender == admin || msg.sender == capGuardian, "only admin or cap guardian can set supply caps");

        uint numMarkets = kTokens.length;
        uint numSupplyCaps = newSupplyCaps.length;

        require(numMarkets != 0 && numMarkets == numSupplyCaps, "invalid input");

        for (uint i = 0; i < numMarkets; i++) {
            supplyCaps[address(kTokens[i])] = newSupplyCaps[i];
            emit NewSupplyCap(kTokens[i], newSupplyCaps[i]);
        }
    }

    function _setCapGuardian(address newCapGuardian) external onlyAdmin() {

        address oldCapGuardian = capGuardian;
        capGuardian = newCapGuardian;
        emit NewCapGuardian(oldCapGuardian, newCapGuardian);
    }

    function _setPauseGuardian(address newPauseGuardian) external onlyAdmin() {

        address oldPauseGuardian = pauseGuardian;
        pauseGuardian = newPauseGuardian;
        emit NewPauseGuardian(oldPauseGuardian, pauseGuardian);
    }

    function _setMintPaused(KToken kToken, bool state) public returns (bool) {

        require(markets[address(kToken)].isListed, "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause/unpause");

        mintGuardianPaused[address(kToken)] = state;
        emit ActionPaused(kToken, "Mint", state);
        return state;
    }

    function _setBorrowPaused(KToken kToken, bool state) public returns (bool) {

        require(markets[address(kToken)].isListed, "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause/unpause");

        borrowGuardianPaused[address(kToken)] = state;
        emit ActionPaused(kToken, "Borrow", state);
        return state;
    }

    function _setTransferPaused(bool state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause/unpause");

        transferGuardianPaused = state;
        emit ActionPaused("Transfer", state);
        return state;
    }

    function _setSeizePaused(bool state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause/unpause");

        seizeGuardianPaused = state;
        emit ActionPaused("Seize", state);
        return state;
    }

    function _setRedemptionPaused(bool state) public returns (bool) {

        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause/unpause");

        redemptionPaused = state;
        emit ActionPaused("Redemption", state);
        return state;
    }

    function _setRedemptionPausedPerAsset(KToken kToken, bool state) public returns (bool) {

        require(markets[address(kToken)].isListed, "cannot pause a market that is not listed");
        require(msg.sender == pauseGuardian || msg.sender == admin, "only pause guardian and admin can pause/unpause");

        redemptionPausedPerAsset[address(kToken)] = state;
        emit ActionPaused(kToken, "Redemption", state);
        return state;
    }

    function _setRedemptionInitialPunishment(uint newRedemptionInitialPunishmentMantissa) external onlyAdmin() {

        uint oldRedemptionInitialPunishmentMantissa = redemptionInitialPunishmentMantissa;
        redemptionInitialPunishmentMantissa = newRedemptionInitialPunishmentMantissa;
        emit NewRedemptionInitialPunishment(oldRedemptionInitialPunishmentMantissa, newRedemptionInitialPunishmentMantissa);
    }

    function _become(Unitroller unitroller) public {

        require(msg.sender == unitroller.admin(), "only unitroller admin can change brains");
        unitroller._acceptImplementation();
    }

    function getAllMarkets() public view returns (KToken[] memory) {

        return allMarkets;
    }

    function getBlockNumber() public view returns (uint) {

        return block.number;
    }

    function getOracle() external view returns (address) {

        return address(oracle);
    }

}