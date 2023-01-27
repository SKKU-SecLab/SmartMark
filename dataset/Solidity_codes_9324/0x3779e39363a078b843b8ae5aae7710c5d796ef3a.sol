

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;


abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {

        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        uint256 c = a + b;
        if (c < a) return (false, 0);
        return (true, c);
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b > a) return (false, 0);
        return (true, a - b);
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (a == 0) return (true, 0);
        uint256 c = a * b;
        if (c / a != b) return (false, 0);
        return (true, c);
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a / b);
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        if (b == 0) return (false, 0);
        return (true, a % b);
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b <= a, "SafeMath: subtraction overflow");
        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) return 0;
        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: division by zero");
        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        require(b > 0, "SafeMath: modulo by zero");
        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b <= a, errorMessage);
        return a - b;
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a / b;
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        require(b > 0, errorMessage);
        return a % b;
    }
}

library SafeERC20 {

    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IBZx {


    function replaceContract(address target) external;


    function setTargets(
        string[] calldata sigsArr,
        address[] calldata targetsArr
    ) external;


    function getTarget(string calldata sig) external view returns (address);



    function setPriceFeedContract(address newContract) external;


    function setSwapsImplContract(address newContract) external;


    function setLoanPool(address[] calldata pools, address[] calldata assets)
        external;


    function setSupportedTokens(
        address[] calldata addrs,
        bool[] calldata toggles,
        bool withApprovals
    ) external;


    function setLendingFeePercent(uint256 newValue) external;


    function setTradingFeePercent(uint256 newValue) external;


    function setBorrowingFeePercent(uint256 newValue) external;


    function setAffiliateFeePercent(uint256 newValue) external;


    function setLiquidationIncentivePercent(
        address[] calldata loanTokens,
        address[] calldata collateralTokens,
        uint256[] calldata amounts
    ) external;


    function setMaxDisagreement(uint256 newAmount) external;


    function setSourceBufferPercent(uint256 newAmount) external;


    function setMaxSwapSize(uint256 newAmount) external;


    function setFeesController(address newController) external;


    function withdrawFees(
        address[] calldata tokens,
        address receiver,
        FeeClaimType feeType
    ) external returns (uint256[] memory amounts);


    function withdrawProtocolToken(address receiver, uint256 amount)
        external
        returns (address rewardToken, uint256 withdrawAmount);


    function depositProtocolToken(uint256 amount) external;


    function grantRewards(address[] calldata users, uint256[] calldata amounts)
        external
        returns (uint256 totalAmount);


    function queryFees(address[] calldata tokens, FeeClaimType feeType)
        external
        view
        returns (uint256[] memory amountsHeld, uint256[] memory amountsPaid);


    function priceFeeds() external view returns (address);


    function swapsImpl() external view returns (address);


    function logicTargets(bytes4) external view returns (address);


    function loans(bytes32) external view returns (Loan memory);


    function loanParams(bytes32) external view returns (LoanParams memory);



    function delegatedManagers(bytes32, address) external view returns (bool);


    function lenderInterest(address, address)
        external
        view
        returns (LenderInterest memory);


    function loanInterest(bytes32) external view returns (LoanInterest memory);


    function feesController() external view returns (address);


    function lendingFeePercent() external view returns (uint256);


    function lendingFeeTokensHeld(address) external view returns (uint256);


    function lendingFeeTokensPaid(address) external view returns (uint256);


    function borrowingFeePercent() external view returns (uint256);


    function borrowingFeeTokensHeld(address) external view returns (uint256);


    function borrowingFeeTokensPaid(address) external view returns (uint256);


    function protocolTokenHeld() external view returns (uint256);


    function protocolTokenPaid() external view returns (uint256);


    function affiliateFeePercent() external view returns (uint256);


    function liquidationIncentivePercent(address, address)
        external
        view
        returns (uint256);


    function loanPoolToUnderlying(address) external view returns (address);


    function underlyingToLoanPool(address) external view returns (address);


    function supportedTokens(address) external view returns (bool);


    function maxDisagreement() external view returns (uint256);


    function sourceBufferPercent() external view returns (uint256);


    function maxSwapSize() external view returns (uint256);


    function getLoanPoolsList(uint256 start, uint256 count)
        external
        view
        returns (address[] memory loanPoolsList);


    function isLoanPool(address loanPool) external view returns (bool);



    function setupLoanParams(LoanParams[] calldata loanParamsList)
        external
        returns (bytes32[] memory loanParamsIdList);


    function disableLoanParams(bytes32[] calldata loanParamsIdList) external;


    function getLoanParams(bytes32[] calldata loanParamsIdList)
        external
        view
        returns (LoanParams[] memory loanParamsList);


    function getLoanParamsList(
        address owner,
        uint256 start,
        uint256 count
    ) external view returns (bytes32[] memory loanParamsList);


    function getTotalPrincipal(address lender, address loanToken)
        external
        view
        returns (uint256);



    function borrowOrTradeFromPool(
        bytes32 loanParamsId,
        bytes32 loanId,
        bool isTorqueLoan,
        uint256 initialMargin,
        address[4] calldata sentAddresses,
        uint256[5] calldata sentValues,
        bytes calldata loanDataBytes
    ) external payable returns (LoanOpenData memory);


    function setDelegatedManager(
        bytes32 loanId,
        address delegated,
        bool toggle
    ) external;


    function getEstimatedMarginExposure(
        address loanToken,
        address collateralToken,
        uint256 loanTokenSent,
        uint256 collateralTokenSent,
        uint256 interestRate,
        uint256 newPrincipal
    ) external view returns (uint256);


    function getRequiredCollateral(
        address loanToken,
        address collateralToken,
        uint256 newPrincipal,
        uint256 marginAmount,
        bool isTorqueLoan
    ) external view returns (uint256 collateralAmountRequired);


    function getRequiredCollateralByParams(
        bytes32 loanParamsId,
        uint256 newPrincipal
    ) external view returns (uint256 collateralAmountRequired);


    function getBorrowAmount(
        address loanToken,
        address collateralToken,
        uint256 collateralTokenAmount,
        uint256 marginAmount,
        bool isTorqueLoan
    ) external view returns (uint256 borrowAmount);


    function getBorrowAmountByParams(
        bytes32 loanParamsId,
        uint256 collateralTokenAmount
    ) external view returns (uint256 borrowAmount);



    function liquidate(
        bytes32 loanId,
        address receiver,
        uint256 closeAmount
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 seizedAmount,
            address seizedToken
        );


    function rollover(bytes32 loanId, bytes calldata loanDataBytes)
        external
        returns (address rebateToken, uint256 gasRebate);


    function closeWithDeposit(
        bytes32 loanId,
        address receiver,
        uint256 depositAmount // denominated in loanToken
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );


    function closeWithSwap(
        bytes32 loanId,
        address receiver,
        uint256 swapAmount, // denominated in collateralToken
        bool returnTokenIsCollateral, // true: withdraws collateralToken, false: withdraws loanToken
        bytes calldata loanDataBytes
    )
        external
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );



    function liquidateWithGasToken(
        bytes32 loanId,
        address receiver,
        address gasTokenUser,
        uint256 closeAmount // denominated in loanToken
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 seizedAmount,
            address seizedToken
        );


    function rolloverWithGasToken(
        bytes32 loanId,
        address gasTokenUser,
        bytes calldata /*loanDataBytes*/
    ) external returns (address rebateToken, uint256 gasRebate);


    function closeWithDepositWithGasToken(
        bytes32 loanId,
        address receiver,
        address gasTokenUser,
        uint256 depositAmount
    )
        external
        payable
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );


    function closeWithSwapWithGasToken(
        bytes32 loanId,
        address receiver,
        address gasTokenUser,
        uint256 swapAmount,
        bool returnTokenIsCollateral,
        bytes calldata loanDataBytes
    )
        external
        returns (
            uint256 loanCloseAmount,
            uint256 withdrawAmount,
            address withdrawToken
        );



    function depositCollateral(bytes32 loanId, uint256 depositAmount)
        external
        payable;


    function withdrawCollateral(
        bytes32 loanId,
        address receiver,
        uint256 withdrawAmount
    ) external returns (uint256 actualWithdrawAmount);


    function withdrawAccruedInterest(address loanToken) external;


    function extendLoanDuration(
        bytes32 loanId,
        uint256 depositAmount,
        bool useCollateral,
        bytes calldata // for future use /*loanDataBytes*/
    ) external payable returns (uint256 secondsExtended);


    function reduceLoanDuration(
        bytes32 loanId,
        address receiver,
        uint256 withdrawAmount
    ) external returns (uint256 secondsReduced);


    function setDepositAmount(
        bytes32 loanId,
        uint256 depositValueAsLoanToken,
        uint256 depositValueAsCollateralToken
    ) external;


    function claimRewards(address receiver)
        external
        returns (uint256 claimAmount);


    function transferLoan(bytes32 loanId, address newOwner) external;


    function rewardsBalanceOf(address user)
        external
        view
        returns (uint256 rewardsBalance);


    function getLenderInterestData(address lender, address loanToken)
        external
        view
        returns (
            uint256 interestPaid,
            uint256 interestPaidDate,
            uint256 interestOwedPerDay,
            uint256 interestUnPaid,
            uint256 interestFeePercent,
            uint256 principalTotal
        );


    function getLoanInterestData(bytes32 loanId)
        external
        view
        returns (
            address loanToken,
            uint256 interestOwedPerDay,
            uint256 interestDepositTotal,
            uint256 interestDepositRemaining
        );


    function getUserLoans(
        address user,
        uint256 start,
        uint256 count,
        LoanType loanType,
        bool isLender,
        bool unsafeOnly
    ) external view returns (LoanReturnData[] memory loansData);


    function getUserLoansCount(address user, bool isLender)
        external
        view
        returns (uint256);


    function getLoan(bytes32 loanId)
        external
        view
        returns (LoanReturnData memory loanData);


    function getActiveLoans(
        uint256 start,
        uint256 count,
        bool unsafeOnly
    ) external view returns (LoanReturnData[] memory loansData);


    function getActiveLoansAdvanced(
        uint256 start,
        uint256 count,
        bool unsafeOnly,
        bool isLiquidatable
    ) external view returns (LoanReturnData[] memory loansData);


    function getActiveLoansCount() external view returns (uint256);



    function swapExternal(
        address sourceToken,
        address destToken,
        address receiver,
        address returnToSender,
        uint256 sourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes calldata swapData
    )
        external
        payable
        returns (
            uint256 destTokenAmountReceived,
            uint256 sourceTokenAmountUsed
        );


    function swapExternalWithGasToken(
        address sourceToken,
        address destToken,
        address receiver,
        address returnToSender,
        address gasTokenUser,
        uint256 sourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes calldata swapData
    )
        external
        payable
        returns (
            uint256 destTokenAmountReceived,
            uint256 sourceTokenAmountUsed
        );


    function getSwapExpectedReturn(
        address sourceToken,
        address destToken,
        uint256 sourceTokenAmount
    ) external view returns (uint256);


    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;


    struct LoanParams {
        bytes32 id;
        bool active;
        address owner;
        address loanToken;
        address collateralToken;
        uint256 minInitialMargin;
        uint256 maintenanceMargin;
        uint256 maxLoanTerm;
    }

    struct LoanOpenData {
        bytes32 loanId;
        uint256 principal;
        uint256 collateral;
    }

    enum LoanType {
        All,
        Margin,
        NonMargin
    }

    struct LoanReturnData {
        bytes32 loanId;
        uint96 endTimestamp;
        address loanToken;
        address collateralToken;
        uint256 principal;
        uint256 collateral;
        uint256 interestOwedPerDay;
        uint256 interestDepositRemaining;
        uint256 startRate;
        uint256 startMargin;
        uint256 maintenanceMargin;
        uint256 currentMargin;
        uint256 maxLoanTerm;
        uint256 maxLiquidatable;
        uint256 maxSeizable;
        uint256 depositValueAsLoanToken;
        uint256 depositValueAsCollateralToken;
    }

    enum FeeClaimType {
        All,
        Lending,
        Trading,
        Borrowing
    }

    struct Loan {
        bytes32 id; // id of the loan
        bytes32 loanParamsId; // the linked loan params id
        bytes32 pendingTradesId; // the linked pending trades id
        uint256 principal; // total borrowed amount outstanding
        uint256 collateral; // total collateral escrowed for the loan
        uint256 startTimestamp; // loan start time
        uint256 endTimestamp; // for active loans, this is the expected loan end time, for in-active loans, is the actual (past) end time
        uint256 startMargin; // initial margin when the loan opened
        uint256 startRate; // reference rate when the loan opened for converting collateralToken to loanToken
        address borrower; // borrower of this loan
        address lender; // lender of this loan
        bool active; // if false, the loan has been fully closed
    }

    struct LenderInterest {
        uint256 principalTotal; // total borrowed amount outstanding of asset
        uint256 owedPerDay; // interest owed per day for all loans of asset
        uint256 owedTotal; // total interest owed for all loans of asset (assuming they go to full term)
        uint256 paidTotal; // total interest paid so far for asset
        uint256 updatedTimestamp; // last update
    }

    struct LoanInterest {
        uint256 owedPerDay; // interest owed per day for loan
        uint256 depositTotal; // total escrowed interest for loan
        uint256 updatedTimestamp; // last update
    }
}

interface IERC20Burnable is IERC20 {

    function burn(uint256 amount) external;

}

contract Upgradeable is Ownable {

    address public implementation;
}

interface IWeth {

    function deposit() external payable;

    function withdraw(uint256 wad) external;

}

interface IWethERC20 is IWeth, IERC20 {}


interface IUniswapV2Router {

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline)
        external
        returns (uint256[] memory amounts);


    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline)
        external
        returns (uint256[] memory amounts);


    function getAmountsIn(
        uint256 amountOut,
        address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);


    function getAmountsOut(
        uint256 amountIn,
        address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

}

interface IMasterChefPartial {

    function addExternalReward(
        uint256 _amount)
        external;


    function addAltReward()
        external
        payable;


    event AddExternalReward(
        address indexed sender,
        uint256 indexed pid,
        uint256 amount
    );

    event AddAltReward(
        address indexed sender,
        uint256 indexed pid,
        uint256 amount
    );
}

interface IPriceFeeds {

    function queryRate(
        address sourceToken,
        address destToken)
        external
        view
        returns (uint256 rate, uint256 precision);


    function queryReturn(
        address sourceToken,
        address destToken,
        uint256 sourceAmount)
        external
        view
        returns (uint256 destAmount);

}

interface IStakingPartial {


    function pendingSushiRewards(address _user)
        external
        view
        returns (uint256);


    function getCurrentFeeTokens()
        external
        view
        returns (address[] memory);


    function maxUniswapDisagreement()
        external
        view
        returns (uint256);


    function stakingRewards(address)
        external
        view
        returns (uint256);


    function isPaused()
        external
        view
        returns (bool);


    function fundsWallet()
        external
        view
        returns (address);



    function callerRewardDivisor()
        external
        view
        returns (uint256);



    function maxCurveDisagreement()
        external
        view
        returns (uint256);


    function rewardPercent()
        external
        view
        returns (uint256);


    function addRewards(uint256 newBZRX, uint256 newStableCoin)
        external;


    function stake(
        address[] calldata tokens,
        uint256[] calldata values
    )
        external;


    function stake(
        address[] calldata tokens,
        uint256[] calldata values,
        bool claimSushi
    )
        external;


    function unstake(
        address[] calldata tokens,
        uint256[] calldata values
    )
        external;


    function unstake(
        address[] memory tokens,
        uint256[] memory values,
        bool claimSushi
    )
        external;


    function earned(address account)
        external
        view
        returns (
            uint256 bzrxRewardsEarned,
            uint256 stableCoinRewardsEarned,
            uint256 bzrxRewardsVesting,
            uint256 stableCoinRewardsVesting
        );


    function getVariableWeights()
        external
        view
        returns (uint256 vBZRXWeight, uint256 iBZRXWeight, uint256 LPTokenWeight);


    function balanceOfByAsset(
        address token,
        address account)
        external
        view
        returns (uint256 balance);


    function balanceOfByAssets(
        address account)
        external
        view
        returns (
            uint256 bzrxBalance,
            uint256 iBZRXBalance,
            uint256 vBZRXBalance,
            uint256 LPTokenBalance,
            uint256 LPTokenBalanceOld
        );


    function balanceOfStored(
        address account)
        external
        view
        returns (uint256 vestedBalance, uint256 vestingBalance);


    function totalSupplyStored()
        external
        view
        returns (uint256 supply);


    function vestedBalanceForAmount(
        uint256 tokenBalance,
        uint256 lastUpdate,
        uint256 vestingEndTime)
        external
        view
        returns (uint256 vested);


    function votingBalanceOf(
        address account,
        uint256 proposalId)
        external
        view
        returns (uint256 totalVotes);


    function votingBalanceOfNow(
        address account)
        external
        view
        returns (uint256 totalVotes);


    function _setProposalVals(
        address account,
        uint256 proposalId)
        external
        returns (uint256);


    function exit()
        external;


    function addAltRewards(address token, uint256 amount)
        external;


    function pendingAltRewards(address token, address _user)
        external
        view
        returns (uint256);


}

interface ICurve3Pool {

    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount)
        external;


    function get_virtual_price()
        external
        view
        returns (uint256);

}

contract FeeExtractAndDistribute_ETH is Upgradeable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IStakingPartial public constant STAKING = IStakingPartial(0xe95Ebce2B02Ee07dEF5Ed6B53289801F7Fc137A4);

    address public constant BZRX = 0x56d811088235F11C8920698a204A5010a788f4b3;
    address public constant vBZRX = 0xB72B31907C1C95F3650b64b2469e08EdACeE5e8F;
    address public constant iBZRX = 0x18240BD9C07fA6156Ce3F3f61921cC82b2619157;
    address public constant LPToken = 0xa30911e072A0C88D55B5D0A0984B66b0D04569d0; // sushiswap
    address public constant LPTokenOld = 0xe26A220a341EAca116bDa64cF9D5638A935ae629; // balancer
    IERC20 public constant curve3Crv = IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;

    IUniswapV2Router public constant uniswapRouter = IUniswapV2Router(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // sushiswap
    ICurve3Pool public constant curve3pool = ICurve3Pool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    IBZx public constant bZx = IBZx(0xD8Ee69652E4e4838f2531732a46d1f7F584F0b7f);

    mapping(address => address[]) public swapPaths;
    mapping(address => uint256) public stakingRewards;

    event ExtractAndDistribute();

    event WithdrawFees(
        address indexed sender
    );

    event DistributeFees(
        address indexed sender,
        uint256 bzrxRewards,
        uint256 stableCoinRewards
    );

    event ConvertFees(
        address indexed sender,
        uint256 bzrxOutput,
        uint256 stableCoinOutput
    );

    modifier onlyEOA() {

        require(msg.sender == tx.origin, "unauthorized");
        _;
    }

    modifier checkPause() {

        require(!STAKING.isPaused() || msg.sender == owner(), "paused");
        _;
    }




    function sweepFees()
        public
        returns (uint256 bzrxRewards, uint256 crv3Rewards)
    {

        return sweepFeesByAsset(STAKING.getCurrentFeeTokens());
    }

    function sweepFeesByAsset(address[] memory assets)
        public
        checkPause
        onlyEOA
        returns (uint256 bzrxRewards, uint256 crv3Rewards)
    {

        uint256[] memory amounts = _withdrawFees(assets);
        _convertFees(assets, amounts);
        (bzrxRewards, crv3Rewards) = _distributeFees();
    }

    function _withdrawFees(address[] memory assets)
        internal
        returns (uint256[] memory)
    {

        uint256[] memory amounts = bZx.withdrawFees(assets, address(this), IBZx.FeeClaimType.All);

        for (uint256 i = 0; i < assets.length; i++) {
            stakingRewards[assets[i]] = stakingRewards[assets[i]].add(amounts[i]);
        }

        emit WithdrawFees(
            msg.sender
        );

        return amounts;
    }

    function _convertFees(
        address[] memory assets,
        uint256[] memory amounts)
        internal
        returns (uint256 bzrxOutput, uint256 crv3Output)
    {

        require(assets.length == amounts.length, "count mismatch");

        IPriceFeeds priceFeeds = IPriceFeeds(bZx.priceFeeds());
        (uint256 bzrxRate,) = priceFeeds.queryRate(
            BZRX,
            WETH
        );
        uint256 maxDisagreement = STAKING.maxUniswapDisagreement();

        address asset;
        uint256 daiAmount;
        uint256 usdcAmount;
        uint256 usdtAmount;
        for (uint256 i = 0; i < assets.length; i++) {
            asset = assets[i];
            if (asset == BZRX) {
                continue;
            } else if (asset == DAI) {
                daiAmount = daiAmount.add(amounts[i]);
                continue;
            } else if (asset == USDC) {
                usdcAmount = usdcAmount.add(amounts[i]);
                continue;
            } else if (asset == USDT) {
                usdtAmount = usdtAmount.add(amounts[i]);
                continue;
            }

            if (amounts[i] != 0) {
                bzrxOutput += _convertFeeWithUniswap(asset, amounts[i], priceFeeds, bzrxRate, maxDisagreement);
            }
        }
        if (bzrxOutput != 0) {
            stakingRewards[BZRX] = stakingRewards[BZRX].add(bzrxOutput);
        }

        if (daiAmount != 0 || usdcAmount != 0 || usdtAmount != 0) {
            crv3Output = _convertFeesWithCurve(
                daiAmount,
                usdcAmount,
                usdtAmount
            );
            stakingRewards[address(curve3Crv)] = stakingRewards[address(curve3Crv)].add(crv3Output);
        }

        emit ConvertFees(
            msg.sender,
            bzrxOutput,
            crv3Output
        );
    }

    function _distributeFees()
        internal
        returns (uint256 bzrxRewards, uint256 crv3Rewards)
    {

        bzrxRewards = stakingRewards[BZRX];
        crv3Rewards = stakingRewards[address(curve3Crv)];
        if (bzrxRewards != 0 || crv3Rewards != 0) {
            address _fundsWallet = STAKING.fundsWallet();
            uint256 rewardAmount;
            uint256 callerReward;
            if (bzrxRewards != 0) {
                stakingRewards[BZRX] = 0;
                rewardAmount = bzrxRewards
                    .mul(STAKING.rewardPercent())
                    .div(1e20);
                IERC20(BZRX).transfer(
                    _fundsWallet,
                    bzrxRewards - rewardAmount
                );
                bzrxRewards = rewardAmount;

                callerReward = bzrxRewards / STAKING.callerRewardDivisor();
                IERC20(BZRX).transfer(
                    msg.sender,
                    callerReward
                );
                bzrxRewards = bzrxRewards
                    .sub(callerReward);
            }
            if (crv3Rewards != 0) {
                stakingRewards[address(curve3Crv)] = 0;

                rewardAmount = crv3Rewards
                    .mul(STAKING.rewardPercent())
                    .div(1e20);
                curve3Crv.transfer(
                    _fundsWallet,
                    crv3Rewards - rewardAmount
                );
                crv3Rewards = rewardAmount;

                callerReward = crv3Rewards / STAKING.callerRewardDivisor();
                curve3Crv.transfer(
                    msg.sender,
                    callerReward
                );
                crv3Rewards = crv3Rewards
                    .sub(callerReward);
            }
            STAKING.addRewards(bzrxRewards, crv3Rewards);
        }

        emit DistributeFees(
            msg.sender,
            bzrxRewards,
            crv3Rewards
        );
    }

    function _convertFeeWithUniswap(
        address asset,
        uint256 amount,
        IPriceFeeds priceFeeds,
        uint256 bzrxRate,
        uint256 maxDisagreement)
        internal
        returns (uint256 returnAmount)
    {

        uint256 stakingReward = stakingRewards[asset];
        if (stakingReward != 0) {
            if (amount > stakingReward) {
                amount = stakingReward;
            }
            stakingRewards[asset] = stakingReward.sub(amount);

            uint256[] memory amounts = uniswapRouter.swapExactTokensForTokens(
                amount,
                1, // amountOutMin
                swapPaths[asset],
                address(this),
                block.timestamp
            );

            returnAmount = amounts[amounts.length - 1];

            _checkUniDisagreement(
                asset,
                amount,
                returnAmount,
                priceFeeds,
                bzrxRate,
                maxDisagreement
            );
        }
    }

    function _convertFeesWithCurve(
        uint256 daiAmount,
        uint256 usdcAmount,
        uint256 usdtAmount)
        internal
        returns (uint256 returnAmount)
    {

        uint256[3] memory curveAmounts;
        uint256 curveTotal;
        uint256 stakingReward;

        if (daiAmount != 0) {
            stakingReward = stakingRewards[DAI];
            if (stakingReward != 0) {
                if (daiAmount > stakingReward) {
                    daiAmount = stakingReward;
                }
                stakingRewards[DAI] = stakingReward.sub(daiAmount);
                curveAmounts[0] = daiAmount;
                curveTotal = daiAmount;
            }
        }
        if (usdcAmount != 0) {
            stakingReward = stakingRewards[USDC];
            if (stakingReward != 0) {
                if (usdcAmount > stakingReward) {
                    usdcAmount = stakingReward;
                }
                stakingRewards[USDC] = stakingReward.sub(usdcAmount);
                curveAmounts[1] = usdcAmount;
                curveTotal = curveTotal.add(usdcAmount.mul(1e12)); // normalize to 18 decimals
            }
        }
        if (usdtAmount != 0) {
            stakingReward = stakingRewards[USDT];
            if (stakingReward != 0) {
                if (usdtAmount > stakingReward) {
                    usdtAmount = stakingReward;
                }
                stakingRewards[USDT] = stakingReward.sub(usdtAmount);
                curveAmounts[2] = usdtAmount;
                curveTotal = curveTotal.add(usdtAmount.mul(1e12)); // normalize to 18 decimals
            }
        }

        uint256 beforeBalance = curve3Crv.balanceOf(address(this));
        curve3pool.add_liquidity(curveAmounts, 0);

        returnAmount = curve3Crv.balanceOf(address(this)) - beforeBalance;

        _checkCurveDisagreement(
            curveTotal,
            returnAmount,
            STAKING.maxCurveDisagreement()
        );
    }

    function _checkUniDisagreement(
        address asset,
        uint256 assetAmount,
        uint256 bzrxAmount,
        IPriceFeeds priceFeeds,
        uint256 bzrxRate,
        uint256 maxDisagreement)
        internal
        view
    {

        (uint256 rate, uint256 precision) = priceFeeds.queryRate(
            asset,
            WETH
        );

        rate = rate
            .mul(1e36)
            .div(precision)
            .div(bzrxRate);

        uint256 sourceToDestSwapRate = bzrxAmount
            .mul(1e18)
            .div(assetAmount);

        uint256 spreadValue = sourceToDestSwapRate > rate ?
            sourceToDestSwapRate - rate :
            rate - sourceToDestSwapRate;

        if (spreadValue != 0) {
            spreadValue = spreadValue
                .mul(1e20)
                .div(sourceToDestSwapRate);

            require(
                spreadValue <= maxDisagreement,
                "uniswap price disagreement"
            );
        }
    }

    function _checkCurveDisagreement(
        uint256 sendAmount, // deposit tokens
        uint256 actualReturn, // returned lp token
        uint256 maxDisagreement)
        internal
        view
    {

        uint256 expectedReturn = sendAmount
            .mul(1e18)
            .div(curve3pool.get_virtual_price());

        uint256 spreadValue = actualReturn > expectedReturn ?
            actualReturn - expectedReturn :
            expectedReturn - actualReturn;

        if (spreadValue != 0) {
            spreadValue = spreadValue
                .mul(1e20)
                .div(actualReturn);

            require(
                spreadValue <= maxDisagreement,
                "curve price disagreement"
            );
        }
    }

    function setApprovals()
        external
        onlyOwner
    {

        IERC20(DAI).safeApprove(address(curve3pool), uint256(-1));
        IERC20(USDC).safeApprove(address(curve3pool), uint256(-1));
        IERC20(USDT).safeApprove(address(curve3pool), uint256(-1));

        IERC20(BZRX).safeApprove(address(STAKING), uint256(-1));
        curve3Crv.safeApprove(address(STAKING), uint256(-1));
    }

    function setPaths(
        address[][] calldata paths)
        external
        onlyOwner
    {

        address[] memory path;
        for (uint256 i = 0; i < paths.length; i++) {
            path = paths[i];
            require(path.length >= 2 &&
            path[0] != path[path.length - 1] &&
            path[path.length - 1] == BZRX,
                "invalid path"
            );

            uint256[] memory amountsOut = uniswapRouter.getAmountsOut(1e10, path);
            require(amountsOut[amountsOut.length - 1] != 0, "path does not exist");

            swapPaths[path[0]] = path;
            IERC20(path[0]).safeApprove(address(uniswapRouter), 0);
            IERC20(path[0]).safeApprove(address(uniswapRouter), uint256(-1));
        }
    }
}