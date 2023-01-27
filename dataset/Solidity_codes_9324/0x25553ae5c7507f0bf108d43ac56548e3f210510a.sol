pragma solidity 0.5.16;

contract Storage {

    address public governance;
    address public controller;

    constructor() public {
        governance = msg.sender;
    }

    modifier onlyGovernance() {

        require(isGovernance(msg.sender), "Not governance");
        _;
    }

    function setGovernance(address _governance) public onlyGovernance {

        require(_governance != address(0), "new governance shouldn't be empty");
        governance = _governance;
    }

    function setController(address _controller) public onlyGovernance {

        require(_controller != address(0), "new controller shouldn't be empty");
        controller = _controller;
    }

    function isGovernance(address account) public view returns (bool) {

        return account == governance;
    }

    function isController(address account) public view returns (bool) {

        return account == controller;
    }
}pragma solidity 0.5.16;


contract Governable {

    Storage public store;

    constructor(address _store) public {
        require(_store != address(0), "new storage shouldn't be empty");
        store = Storage(_store);
    }

    modifier onlyGovernance() {

        require(store.isGovernance(msg.sender), "Not governance");
        _;
    }

    function setStorage(address _store) public onlyGovernance {

        require(_store != address(0), "new storage shouldn't be empty");
        store = Storage(_store);
    }

    function governance() public view returns (address) {

        return store.governance();
    }
}pragma solidity 0.5.16;


contract Controllable is Governable {

    constructor(address _storage) public Governable(_storage) {}

    modifier onlyController() {

        require(store.isController(msg.sender), "Not a controller");
        _;
    }

    modifier onlyControllerOrGovernance() {

        require(
            (store.isController(msg.sender) || store.isGovernance(msg.sender)),
            "The caller must be controller or governance"
        );
        _;
    }

    function controller() public view returns (address) {

        return store.controller();
    }
}pragma solidity ^0.5.16;

contract ComptrollerInterface {

    function getAccountLiquidity(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function getHypotheticalAccountLiquidity(
        address account,
        address cTokenModify,
        uint256 redeemTokens,
        uint256 borrowAmount
    )
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function claimComp(address holder) external;


    bool public constant isComptroller = true;


    function enterMarkets(address[] calldata cTokens)
        external
        returns (uint256[] memory);


    function exitMarket(address cToken) external returns (uint256);



    function mintAllowed(
        address cToken,
        address minter,
        uint256 mintAmount
    ) external returns (uint256);


    function mintVerify(
        address cToken,
        address minter,
        uint256 mintAmount,
        uint256 mintTokens
    ) external;


    function redeemAllowed(
        address cToken,
        address redeemer,
        uint256 redeemTokens
    ) external returns (uint256);


    function redeemVerify(
        address cToken,
        address redeemer,
        uint256 redeemAmount,
        uint256 redeemTokens
    ) external;


    function borrowAllowed(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external returns (uint256);


    function borrowVerify(
        address cToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function repayBorrowAllowed(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function repayBorrowVerify(
        address cToken,
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 borrowerIndex
    ) external;


    function liquidateBorrowAllowed(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount
    ) external returns (uint256);


    function liquidateBorrowVerify(
        address cTokenBorrowed,
        address cTokenCollateral,
        address liquidator,
        address borrower,
        uint256 repayAmount,
        uint256 seizeTokens
    ) external;


    function seizeAllowed(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);


    function seizeVerify(
        address cTokenCollateral,
        address cTokenBorrowed,
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external;


    function transferAllowed(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external returns (uint256);


    function transferVerify(
        address cToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;



    function liquidateCalculateSeizeTokens(
        address cTokenBorrowed,
        address cTokenCollateral,
        uint256 repayAmount
    ) external view returns (uint256, uint256);


    function markets(address cToken) external view returns (bool, uint256);


    function compSpeeds(address cToken) external view returns (uint256);

}pragma solidity ^0.5.16;

contract InterestRateModel {

    bool public constant isInterestRateModel = true;

    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves
    ) external view returns (uint256);


    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 reserves,
        uint256 reserveFactorMantissa
    ) external view returns (uint256);

}pragma solidity ^0.5.16;


contract CTokenStorage {

    bool internal _notEntered;

    string public name;

    string public symbol;

    uint8 public decimals;


    uint256 internal constant borrowRateMaxMantissa = 0.0005e16;

    uint256 internal constant reserveFactorMaxMantissa = 1e18;

    address payable public admin;

    address payable public pendingAdmin;

    ComptrollerInterface public comptroller;

    InterestRateModel public interestRateModel;

    uint256 internal initialExchangeRateMantissa;

    uint256 public reserveFactorMantissa;

    uint256 public accrualBlockNumber;

    uint256 public borrowIndex;

    uint256 public totalBorrows;

    uint256 public totalReserves;

    uint256 public totalSupply;

    mapping(address => uint256) internal accountTokens;

    mapping(address => mapping(address => uint256)) internal transferAllowances;

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping(address => BorrowSnapshot) internal accountBorrows;
}

contract CTokenInterface is CTokenStorage {

    bool public constant isCToken = true;


    event AccrueInterest(
        uint256 cashPrior,
        uint256 interestAccumulated,
        uint256 borrowIndex,
        uint256 totalBorrows
    );

    event Mint(address minter, uint256 mintAmount, uint256 mintTokens);

    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens);

    event Borrow(
        address borrower,
        uint256 borrowAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

    event LiquidateBorrow(
        address liquidator,
        address borrower,
        uint256 repayAmount,
        address cTokenCollateral,
        uint256 seizeTokens
    );


    event NewPendingAdmin(address oldPendingAdmin, address newPendingAdmin);

    event NewAdmin(address oldAdmin, address newAdmin);

    event NewComptroller(
        ComptrollerInterface oldComptroller,
        ComptrollerInterface newComptroller
    );

    event NewMarketInterestRateModel(
        InterestRateModel oldInterestRateModel,
        InterestRateModel newInterestRateModel
    );

    event NewReserveFactor(
        uint256 oldReserveFactorMantissa,
        uint256 newReserveFactorMantissa
    );

    event ReservesAdded(
        address benefactor,
        uint256 addAmount,
        uint256 newTotalReserves
    );

    event ReservesReduced(
        address admin,
        uint256 reduceAmount,
        uint256 newTotalReserves
    );

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    event Failure(uint256 error, uint256 info, uint256 detail);


    function transfer(address dst, uint256 amount) external returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external returns (bool);


    function approve(address spender, uint256 amount) external returns (bool);


    function allowance(address owner, address spender)
        external
        view
        returns (uint256);


    function balanceOf(address owner) external view returns (uint256);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );


    function borrowRatePerBlock() external view returns (uint256);


    function supplyRatePerBlock() external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) public view returns (uint256);


    function exchangeRateCurrent() public returns (uint256);


    function exchangeRateStored() public view returns (uint256);


    function getCash() external view returns (uint256);


    function accrueInterest() public returns (uint256);


    function seize(
        address liquidator,
        address borrower,
        uint256 seizeTokens
    ) external returns (uint256);



    function _setPendingAdmin(address payable newPendingAdmin)
        external
        returns (uint256);


    function _acceptAdmin() external returns (uint256);


    function _setComptroller(ComptrollerInterface newComptroller)
        public
        returns (uint256);


    function _setReserveFactor(uint256 newReserveFactorMantissa)
        external
        returns (uint256);


    function _reduceReserves(uint256 reduceAmount) external returns (uint256);


    function _setInterestRateModel(InterestRateModel newInterestRateModel)
        public
        returns (uint256);

}

contract CErc20Storage {

    address public underlying;
}

contract CErc20Interface is CErc20Storage {


    function mint(uint256 mintAmount) external returns (uint256);


    function redeem(uint256 redeemTokens) external returns (uint256);


    function redeemUnderlying(uint256 redeemAmount) external returns (uint256);


    function borrow(uint256 borrowAmount) external returns (uint256);


    function repayBorrow(uint256 repayAmount) external returns (uint256);


    function repayBorrowBehalf(address borrower, uint256 repayAmount)
        external
        returns (uint256);


    function liquidateBorrow(
        address borrower,
        uint256 repayAmount,
        CTokenInterface cTokenCollateral
    ) external returns (uint256);



    function _addReserves(uint256 addAmount) external returns (uint256);

}

contract CDelegationStorage {

    address public implementation;
}

contract CDelegatorInterface is CDelegationStorage {

    event NewImplementation(
        address oldImplementation,
        address newImplementation
    );

    function _setImplementation(
        address implementation_,
        bool allowResign,
        bytes memory becomeImplementationData
    ) public;

}

contract CDelegateInterface is CDelegationStorage {

    function _becomeImplementation(bytes memory data) public;


    function _resignImplementation() public;

}pragma solidity 0.5.16;

interface IController {

    function greyList(address _target) external view returns (bool);


    function addVaultAndStrategy(address _vault, address _strategy) external;


    function forceUnleashed(address _vault) external;


    function hasVault(address _vault) external returns (bool);


    function salvage(address _token, uint256 amount) external;


    function salvageStrategy(
        address _strategy,
        address _token,
        uint256 amount
    ) external;


    function notifyFee(address _underlying, uint256 fee) external;


    function profitSharingNumerator() external view returns (uint256);


    function profitSharingDenominator() external view returns (uint256);


    function treasury() external view returns (address);

}pragma solidity 0.5.16;

interface IStrategy {

    function unsalvagableTokens(address tokens) external view returns (bool);


    function governance() external view returns (address);


    function controller() external view returns (address);


    function underlying() external view returns (address);


    function vault() external view returns (address);


    function withdrawAllToVault() external;


    function withdrawToVault(uint256 amount) external;


    function investedUnderlyingBalance() external view returns (uint256); // itsNotMuch()


    function salvage(
        address recipient,
        address token,
        uint256 amount
    ) external;


    function forceUnleashed() external;


    function depositArbCheck() external view returns (bool);

}pragma solidity 0.5.16;

interface IVault {

    function underlyingBalanceInVault() external view returns (uint256);


    function underlyingBalanceWithInvestment() external view returns (uint256);


    function governance() external view returns (address);


    function controller() external view returns (address);


    function underlying() external view returns (address);


    function strategy() external view returns (address);


    function setStrategy(address _strategy) external;


    function setVaultFractionToInvest(uint256 numerator, uint256 denominator)
        external;


    function deposit(uint256 amountWei) external;


    function depositFor(uint256 amountWei, address holder) external;


    function withdrawAll() external;


    function withdraw(uint256 numberOfShares) external;


    function getPricePerFullShare() external view returns (uint256);


    function underlyingBalanceWithInvestmentForHolder(address holder)
        external
        view
        returns (uint256);


    function forceUnleashed() external;


    function rebalance() external;

}pragma solidity ^0.5.0;

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
}pragma solidity ^0.5.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);


    function balanceOf(address account) external view returns (uint256);


    function transfer(address recipient, uint256 amount) external returns (bool);


    function allowance(address owner, address spender) external view returns (uint256);


    function approve(address spender, uint256 amount) external returns (bool);


    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);


    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}pragma solidity ^0.5.5;

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
}pragma solidity ^0.5.0;


library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {


        require(address(token).isContract(), "SafeERC20: call to non-contract");

        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}pragma solidity >=0.5.0;

interface IUniswapV2Router01 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}pragma solidity >=0.5.0;


interface IUniswapV2Router02 {

    function factory() external pure returns (address);


    function WETH() external pure returns (address);


    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );


    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );


    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);


    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);


    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);


    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);


    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);


    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);


    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);


    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);


    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);


    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);


    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;


    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;


    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

}pragma solidity 0.5.16;


contract LiquidityRecipient is Controllable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event LiquidityProvided(uint256 forceIn, uint256 wethIn, uint256 lpOut);
    event LiquidityRemoved(uint256 lpIn, uint256 wethOut, uint256 forceOut);

    modifier onlyStrategy() {

        require(msg.sender == wethStrategy, "only the weth strategy");
        _;
    }

    modifier onlyStrategyOrGovernance() {

        require(
            msg.sender == wethStrategy || msg.sender == governance(),
            "only not the weth strategy or governance"
        );
        _;
    }

    address public weth;

    address public force;

    address public wethStrategy;

    address public treasury;

    address public uniswap;

    address public uniLp;

    mapping(address => bool) public unsalvagableTokens;

    constructor(
        address _storage,
        address _weth,
        address _force,
        address _treasury,
        address _uniswap,
        address _uniLp,
        address _wethStrategy
    ) public Controllable(_storage) {
        weth = _weth;
        force = _force;
        require(_treasury != address(0), "treasury cannot be address(0)");
        treasury = _treasury;
        uniswap = _uniswap;
        require(_uniLp != address(0), "uniLp cannot be address(0)");
        uniLp = _uniLp;
        unsalvagableTokens[_weth] = true;
        unsalvagableTokens[_uniLp] = true;
        wethStrategy = _wethStrategy;
    }

    function addLiquidity() internal {

        uint256 forceBalance = IERC20(force).balanceOf(address(this));
        uint256 wethBalance = IERC20(weth).balanceOf(address(this));

        IERC20(force).safeApprove(uniswap, 0);
        IERC20(force).safeApprove(uniswap, forceBalance);
        IERC20(weth).safeApprove(uniswap, 0);
        IERC20(weth).safeApprove(uniswap, wethBalance);

        (uint256 amountForce, uint256 amountWeth, uint256 liquidity) =
            IUniswapV2Router02(uniswap).addLiquidity(
                force,
                weth,
                forceBalance,
                wethBalance,
                0,
                0,
                address(this),
                block.timestamp
            );

        emit LiquidityProvided(amountForce, amountWeth, liquidity);
    }

    function removeLiquidity() internal {

        uint256 lpBalance = IERC20(uniLp).balanceOf(address(this));
        if (lpBalance > 0) {
            IERC20(uniLp).safeApprove(uniswap, 0);
            IERC20(uniLp).safeApprove(uniswap, lpBalance);
            (uint256 amountForce, uint256 amountWeth) =
                IUniswapV2Router02(uniswap).removeLiquidity(
                    force,
                    weth,
                    lpBalance,
                    0,
                    0,
                    address(this),
                    block.timestamp
                );
            emit LiquidityRemoved(lpBalance, amountWeth, amountForce);
        } else {
            emit LiquidityRemoved(0, 0, 0);
        }
    }

    function forceUnleashed() public onlyGovernance {

        addLiquidity();
    }

    function takeLoan(uint256 amount) public onlyStrategy {

        IERC20(weth).safeTransferFrom(wethStrategy, address(this), amount);
        addLiquidity();
    }

    function settleLoan() public onlyStrategyOrGovernance {

        removeLiquidity();
        IERC20(weth).safeApprove(wethStrategy, 0);
        IERC20(weth).safeApprove(wethStrategy, uint256(-1));
        IERC20(force).safeApprove(treasury, 0);
        IERC20(force).safeApprove(treasury, uint256(-1));
    }

    function wethOverdraft() external onlyStrategy {

        if (IERC20(weth).balanceOf(address(this)) > 0) {
            IERC20(weth).safeTransfer(
                treasury,
                IERC20(weth).balanceOf(address(this))
            );
        }
    }

    function salvage(
        address recipient,
        address token,
        uint256 amount
    ) external onlyGovernance {

        require(
            !unsalvagableTokens[token],
            "token is defined as not salvagable"
        );
        IERC20(token).safeTransfer(recipient, amount);
    }
}pragma solidity 0.5.16;


contract RewardTokenProfitNotifier is Controllable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    uint256 public profitSharingNumerator;
    uint256 public profitSharingDenominator;
    address public rewardToken;

    constructor(address _storage, address _rewardToken)
        public
        Controllable(_storage)
    {
        rewardToken = _rewardToken;
        profitSharingNumerator = 0;
        profitSharingDenominator = 100;
        require(
            profitSharingNumerator < profitSharingDenominator,
            "invalid profit share"
        );
    }

    event ProfitLogInReward(
        uint256 profitAmount,
        uint256 feeAmount,
        uint256 timestamp
    );

    function notifyProfitInRewardToken(uint256 _rewardBalance) internal {

        if (_rewardBalance > 0 && profitSharingNumerator > 0) {
            uint256 feeAmount =
                _rewardBalance.mul(profitSharingNumerator).div(
                    profitSharingDenominator
                );
            emit ProfitLogInReward(_rewardBalance, feeAmount, block.timestamp);
            IERC20(rewardToken).safeApprove(controller(), 0);
            IERC20(rewardToken).safeApprove(controller(), feeAmount);

            IController(controller()).notifyFee(rewardToken, feeAmount);
        } else {
            emit ProfitLogInReward(0, 0, block.timestamp);
        }
    }

    function setProfitSharingNumerator(uint256 _profitSharingNumerator)
        external
        onlyGovernance
    {

        profitSharingNumerator = _profitSharingNumerator;
    }
}pragma solidity 0.5.16;


contract CompleteCToken is CErc20Interface, CTokenInterface {}pragma solidity ^0.5.0;


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
}pragma solidity ^0.5.0;

contract ReentrancyGuard {

    bool private _notEntered;

    constructor () internal {
        _notEntered = true;
    }

    modifier nonReentrant() {

        require(_notEntered, "ReentrancyGuard: reentrant call");

        _notEntered = false;

        _;

        _notEntered = true;
    }
}// based on https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code






pragma solidity 0.5.16;

contract WETH9 {

    function balanceOf(address target) public view returns (uint256);


    function deposit() public payable;


    function withdraw(uint256 wad) public;


    function totalSupply() public view returns (uint256);


    function approve(address guy, uint256 wad) public returns (bool);


    function transfer(address dst, uint256 wad) public returns (bool);


    function transferFrom(
        address src,
        address dst,
        uint256 wad
    ) public returns (bool);

}


contract ICEther {

    function mint() external payable;

    function borrow(uint borrowAmount) external returns (uint);

    function redeem(uint redeemTokens) external returns (uint);

    function redeemUnderlying(uint redeemAmount) external returns (uint);

    function repayBorrow() external payable;

    function repayBorrowBehalf(address borrower) external payable;

    function borrowBalanceCurrent(address account) external returns (uint);

    function borrowBalanceStored(address account) external view returns (uint256);

    function balanceOfUnderlying(address account) external returns (uint);

    function balanceOf(address owner) external view returns (uint256);

    function getAccountSnapshot(address account) external view returns (uint, uint, uint, uint);

}pragma solidity 0.5.16;


contract CompoundInteractor is ReentrancyGuard {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public underlying;
    IERC20 public _weth = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    CompleteCToken public ctoken;
    ComptrollerInterface public comptroller;

    constructor(
        address _underlying,
        address _ctoken,
        address _comptroller
    ) public {
        comptroller = ComptrollerInterface(_comptroller);

        underlying = IERC20(_underlying);
        ctoken = CompleteCToken(_ctoken);

        address[] memory cTokens = new address[](1);
        cTokens[0] = _ctoken;
        comptroller.enterMarkets(cTokens);
    }

    function _supplyEtherInWETH(uint256 amountInWETH) internal nonReentrant {

        uint256 balance = underlying.balanceOf(address(this)); // supply at most "balance"
        if (amountInWETH < balance) {
            balance = amountInWETH; // only supply the "amount" if its less than what we have
        }
        WETH9 weth = WETH9(address(_weth));
        weth.withdraw(balance); // Unwrapping
        ICEther(address(ctoken)).mint.value(balance)();
    }

    function _redeemEtherInCTokens(uint256 amountCTokens)
        internal
        nonReentrant
    {

        _redeemInCTokens(amountCTokens);
        WETH9 weth = WETH9(address(_weth));
        weth.deposit.value(address(this).balance)();
    }

    function _supply(uint256 amount) internal returns (uint256) {

        uint256 balance = underlying.balanceOf(address(this));
        if (amount < balance) {
            balance = amount;
        }
        underlying.safeApprove(address(ctoken), 0);
        underlying.safeApprove(address(ctoken), balance);
        uint256 mintResult = ctoken.mint(balance);
        require(mintResult == 0, "Supplying failed");
        return balance;
    }

    function _borrow(uint256 amountUnderlying) internal {

        uint256 result = ctoken.borrow(amountUnderlying);
        require(result == 0, "Borrow failed");
    }

    function _borrowInWETH(uint256 amountUnderlying) internal {

        uint256 result = ctoken.borrow(amountUnderlying);
        require(result == 0, "Borrow failed");
        WETH9 weth = WETH9(address(_weth));
        weth.deposit.value(address(this).balance)();
    }

    function _repay(uint256 amountUnderlying) internal {

        underlying.safeApprove(address(ctoken), 0);
        underlying.safeApprove(address(ctoken), amountUnderlying);
        ctoken.repayBorrow(amountUnderlying);
        underlying.safeApprove(address(ctoken), 0);
    }

    function _repayInWETH(uint256 amountUnderlying) internal {

        WETH9 weth = WETH9(address(_weth));
        weth.withdraw(amountUnderlying); // Unwrapping
        ICEther(address(ctoken)).repayBorrow.value(amountUnderlying)();
    }

    function _redeemInCTokens(uint256 amountCTokens) internal {

        if (amountCTokens > 0) {
            ctoken.redeem(amountCTokens);
        }
    }

    function _redeemUnderlying(uint256 amountUnderlying) internal {

        if (amountUnderlying > 0) {
            ctoken.redeemUnderlying(amountUnderlying);
        }
    }

    function redeemUnderlyingInWeth(uint256 amountUnderlying) internal {

        if (amountUnderlying > 0) {
            _redeemUnderlying(amountUnderlying);
            WETH9 weth = WETH9(address(_weth));
            weth.deposit.value(address(this).balance)();
        }
    }

    function claimComp() public {

        comptroller.claimComp(address(this));
    }

    function redeemMaximumWeth() internal {

        uint256 available = ctoken.getCash();
        uint256 owned = ctoken.balanceOfUnderlying(address(this));

        redeemUnderlyingInWeth(available < owned ? available : owned);
    }

    function redeemMaximumWethWithLoan(
        uint256 collateralFactorNumerator,
        uint256 collateralFactorDenominator,
        uint256 borrowMinThreshold
    ) internal {

        uint256 available = ctoken.getCash();
        uint256 supplied = ctoken.balanceOfUnderlying(address(this));
        uint256 borrowed = ctoken.borrowBalanceCurrent(address(this));

        while (borrowed > borrowMinThreshold) {
            uint256 requiredCollateral =
                borrowed
                    .mul(collateralFactorDenominator)
                    .add(collateralFactorNumerator.div(2))
                    .div(collateralFactorNumerator);

            uint256 wantToRedeem = supplied.sub(requiredCollateral);
            redeemUnderlyingInWeth(Math.min(wantToRedeem, available));

            uint256 balance = underlying.balanceOf(address(this));
            _repayInWETH(Math.min(borrowed, balance));

            available = ctoken.getCash();
            borrowed = ctoken.borrowBalanceCurrent(address(this));
            supplied = ctoken.balanceOfUnderlying(address(this));
        }

        redeemUnderlyingInWeth(Math.min(available, supplied));
    }

    function getLiquidity() external view returns (uint256) {

        return ctoken.getCash();
    }

    function redeemMaximumToken() internal {

        uint256 available = ctoken.getCash();
        uint256 owned = ctoken.balanceOfUnderlying(address(this));

        _redeemUnderlying(available < owned ? available : owned);
    }

    function() external payable {} // this is needed for the WETH unwrapping
}pragma solidity ^0.5.0;


contract ERC20Detailed is IERC20 {

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    constructor (string memory name, string memory symbol, uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }

    function name() public view returns (string memory) {

        return _name;
    }

    function symbol() public view returns (string memory) {

        return _symbol;
    }

    function decimals() public view returns (uint8) {

        return _decimals;
    }
}pragma solidity 0.5.16;


contract CompoundWETHFoldStrategy is
    IStrategy,
    RewardTokenProfitNotifier,
    CompoundInteractor
{

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event ProfitNotClaimed();
    event TooLowBalance();

    ERC20Detailed public underlying;
    CompleteCToken public ctoken;
    ComptrollerInterface public comptroller;

    address public vault;
    ERC20Detailed public comp; // this will be Cream or Comp

    address public uniswapRouterV2;
    uint256 public suppliedInUnderlying;
    uint256 public borrowedInUnderlying;
    bool public liquidationAllowed = true;
    uint256 public sellFloor = 0;
    bool public allowEmergencyLiquidityShortage = false;
    uint256 public collateralFactorNumerator = 100;
    uint256 public collateralFactorDenominator = 1000;
    uint256 public folds = 0;

    address public liquidityRecipient;
    uint256 public liquidityLoanCurrent;
    uint256 public liquidityLoanTarget;

    uint256 public constant tenWeth = 10 * 1e18;

    uint256 public borrowMinThreshold = 0;

    mapping(address => bool) public unsalvagableTokens;

    modifier restricted() {

        require(
            msg.sender == vault ||
                msg.sender == address(controller()) ||
                msg.sender == address(governance()),
            "The sender has to be the controller or vault"
        );
        _;
    }

    event Liquidated(uint256 amount);

    constructor(
        address _storage,
        address _underlying,
        address _ctoken,
        address _vault,
        address _comptroller,
        address _comp,
        address _uniswap
    )
        public
        RewardTokenProfitNotifier(_storage, _comp)
        CompoundInteractor(_underlying, _ctoken, _comptroller)
    {
        require(
            IVault(_vault).underlying() == _underlying,
            "vault does not support underlying"
        );
        comptroller = ComptrollerInterface(_comptroller);
        comp = ERC20Detailed(_comp);
        underlying = ERC20Detailed(_underlying);
        ctoken = CompleteCToken(_ctoken);
        vault = _vault;
        uniswapRouterV2 = _uniswap;

        unsalvagableTokens[_underlying] = true;
        unsalvagableTokens[_ctoken] = true;
        unsalvagableTokens[_comp] = true;
    }

    modifier updateSupplyInTheEnd() {

        _;
        suppliedInUnderlying = ctoken.balanceOfUnderlying(address(this));
        borrowedInUnderlying = ctoken.borrowBalanceCurrent(address(this));
    }

    function depositArbCheck() public view returns (bool) {

        return true;
    }

    function investAllUnderlying() public restricted updateSupplyInTheEnd {

        uint256 balance = underlying.balanceOf(address(this));
        _supplyEtherInWETH(balance);
        for (uint256 i = 0; i < folds; i++) {
            uint256 borrowAmount =
                balance.mul(collateralFactorNumerator).div(
                    collateralFactorDenominator
                );
            _borrowInWETH(borrowAmount);
            balance = underlying.balanceOf(address(this));
            _supplyEtherInWETH(balance);
        }
    }

    function withdrawAllToVault() external restricted updateSupplyInTheEnd {

        if (allowEmergencyLiquidityShortage) {
            withdrawMaximum();
        } else {
            withdrawAllWeInvested();
        }
        if (underlying.balanceOf(address(this)) > 0) {
            IERC20(address(underlying)).safeTransfer(
                vault,
                underlying.balanceOf(address(this))
            );
        }
    }

    function emergencyExit() external onlyGovernance updateSupplyInTheEnd {

        withdrawMaximum();
    }

    function withdrawMaximum() internal updateSupplyInTheEnd {

        if (liquidationAllowed) {
            claimComp();
            liquidateComp();
        } else {
            emit ProfitNotClaimed();
        }
        redeemMaximum();
    }

    function withdrawAllWeInvested() internal updateSupplyInTheEnd {

        require(
            liquidityLoanCurrent == 0,
            "Liquidity loan must be settled first"
        );
        if (liquidationAllowed) {
            claimComp();
            liquidateComp();
        } else {
            emit ProfitNotClaimed();
        }
        uint256 _currentSuppliedBalance =
            ctoken.balanceOfUnderlying(address(this));
        uint256 _currentBorrowedBalance =
            ctoken.borrowBalanceCurrent(address(this));

        mustRedeemPartial(_currentSuppliedBalance.sub(_currentBorrowedBalance));
    }

    function withdrawToVault(uint256 amountUnderlying)
        external
        restricted
        updateSupplyInTheEnd
    {

        if (amountUnderlying <= underlying.balanceOf(address(this))) {
            IERC20(address(underlying)).safeTransfer(vault, amountUnderlying);
            return;
        }

        mustRedeemPartial(amountUnderlying);

        IERC20(address(underlying)).safeTransfer(vault, amountUnderlying);

        investAllUnderlying();
    }

    function forceUnleashed() public restricted {

        if (liquidationAllowed) {
            claimComp();
            liquidateComp();
        } else {
            emit ProfitNotClaimed();
        }
        investAllUnderlying();
    }

    function redeemMaximum() internal {

        redeemMaximumWethWithLoan(
            collateralFactorNumerator,
            collateralFactorDenominator,
            borrowMinThreshold
        );
    }

    function mustRedeemPartial(uint256 amountUnderlying) internal {

        require(
            ctoken.getCash() >= amountUnderlying,
            "market cash cannot cover liquidity"
        );
        redeemMaximum();
        require(
            underlying.balanceOf(address(this)) >= amountUnderlying,
            "Unable to withdraw the entire amountUnderlying"
        );
    }

    function salvage(
        address recipient,
        address token,
        uint256 amount
    ) public onlyGovernance {

        require(
            !unsalvagableTokens[token],
            "token is defined as not salvagable"
        );
        IERC20(token).safeTransfer(recipient, amount);
    }

    function liquidateComp() internal {

        uint256 balance = comp.balanceOf(address(this));
        if (balance < sellFloor || balance == 0) {
            emit TooLowBalance();
            return;
        }

        notifyProfitInRewardToken(balance);

        balance = comp.balanceOf(address(this));

        emit Liquidated(balance);
        uint256 amountOutMin = 1;
        IERC20(address(comp)).safeApprove(address(uniswapRouterV2), 0);
        IERC20(address(comp)).safeApprove(address(uniswapRouterV2), balance);
        address[] memory path = new address[](2);
        path[0] = address(comp);
        path[1] = address(underlying);

        uint256 wethBefore = underlying.balanceOf(address(this));
        IUniswapV2Router02(uniswapRouterV2).swapExactTokensForTokens(
            balance,
            amountOutMin,
            path,
            address(this),
            block.timestamp
        );
    }

    function investedUnderlyingBalance() public view returns (uint256) {

        return
            underlying
                .balanceOf(address(this))
                .add(suppliedInUnderlying)
                .sub(borrowedInUnderlying)
                .add(liquidityLoanCurrent);
    }

    function setLiquidationAllowed(bool allowed) external restricted {

        liquidationAllowed = allowed;
    }

    function setAllowLiquidityShortage(bool allowed) external restricted {

        allowEmergencyLiquidityShortage = allowed;
    }

    function setSellFloor(uint256 value) external restricted {

        sellFloor = value;
    }

    function provideLoan() public onlyGovernance updateSupplyInTheEnd {

        withdrawMaximum();
        if (
            liquidityLoanCurrent < liquidityLoanTarget &&
            IERC20(underlying).balanceOf(address(this)) > 0 &&
            liquidityRecipient != address(0)
        ) {
            uint256 diff =
                Math.min(
                    liquidityLoanTarget.sub(liquidityLoanCurrent),
                    IERC20(underlying).balanceOf(address(this))
                );
            IERC20(underlying).safeApprove(liquidityRecipient, 0);
            IERC20(underlying).safeApprove(liquidityRecipient, diff);
            LiquidityRecipient(liquidityRecipient).takeLoan(diff);
            liquidityLoanCurrent = liquidityLoanCurrent.add(diff);
        }
        investAllUnderlying();
    }

    function settleLoan(uint256 amount) public updateSupplyInTheEnd {

        require(
            investedUnderlyingBalance() <= liquidityLoanCurrent.add(tenWeth) ||
                msg.sender == governance(),
            "Buffer exists and the caller is not governance"
        );
        require(tx.origin == msg.sender, "no smart contracts");

        if (liquidityLoanCurrent == 0) {
            return;
        }

        LiquidityRecipient(liquidityRecipient).settleLoan();
        IERC20(underlying).safeTransferFrom(
            liquidityRecipient,
            address(this),
            amount
        );
        liquidityLoanCurrent = liquidityLoanCurrent.sub(amount);
        if (liquidityLoanCurrent == 0) {
            LiquidityRecipient(liquidityRecipient).wethOverdraft();
        }
    }

    function setLiquidityRecipient(address recipient) public onlyGovernance {

        require(
            liquidityRecipient == address(0) || liquidityLoanCurrent == 0,
            "Liquidity recipient was already set, and has a loan"
        );
        liquidityRecipient = recipient;
    }

    function setBorrowMinThreshold(uint256 threshold) public onlyGovernance {

        borrowMinThreshold = threshold;
    }

    function setCollateralFactorNumerator(uint256 numerator)
        public
        onlyGovernance
    {

        require(numerator <= 740, "Collateral factor cannot be this high");
        collateralFactorNumerator = numerator;
    }

    function setLiquidityLoanTarget(uint256 target) public onlyGovernance {

        liquidityLoanTarget = target;
    }

    function setFolds(uint256 _folds) public onlyGovernance {

        folds = _folds;
    }
}pragma solidity 0.5.16;


contract CompoundWETHFoldStrategyMainnet is CompoundWETHFoldStrategy {

    address public constant __underlying =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address public constant __ctoken =
        address(0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5);
    address public constant __comptroller =
        address(0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B);
    address public constant __comp =
        address(0xc00e94Cb662C3520282E6f5717214004A7f26888);
    address public constant __uniswap =
        address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);

    constructor(address _storage, address _vault)
        public
        CompoundWETHFoldStrategy(
            _storage,
            __underlying,
            __ctoken,
            _vault,
            __comptroller,
            __comp,
            __uniswap
        )
    {}
}