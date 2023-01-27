

pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;




library Address {

    function isContract(address account) internal view returns (bool) {


        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {

        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {

        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {

        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {

        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {

        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {

        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {

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


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
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


    function setTokenApprovals(
        address[] calldata tokens,
        address spender
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


    function getPoolPrincipalStored(address pool)
        external
        view
        returns (uint256);


    function getPoolLastInterestRate(address pool)
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


    function settleInterest(bytes32 loanId) external;





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


    function getInterestModelValues(
        address pool,
        bytes32 loanId)
        external
        view
        returns (
        uint256 _poolLastUpdateTime,
        uint256 _poolPrincipalTotal,
        uint256 _poolInterestTotal,
        uint256 _poolRatePerTokenStored,
        uint256 _poolLastInterestRate,
        uint256 _loanPrincipalTotal,
        uint256 _loanInterestTotal,
        uint256 _loanRatePerTokenPaid
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


    function getLoanPrincipal(bytes32 loanId)
        external
        view
        returns (uint256 principal);


    function getLoanInterestOutstanding(bytes32 loanId)
        external
        view
        returns (uint256 interest);



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
        uint256 sourceTokenAmount,
        bytes calldata swapData
    ) external view returns (uint256);


    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;




    function _isPaused(bytes4 sig) external view returns (bool isPaused);


    function toggleFunctionPause(bytes4 sig) external;


    function toggleFunctionUnPause(bytes4 sig) external;


    function changeGuardian(address newGuardian) external;


    function getGuardian() external view returns (address guardian);



    function cleanupLoans(
        address loanToken,
        bytes32[] calldata loanIds)
        external
        payable
        returns (uint256 totalPrincipalIn);


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

    function payFlashBorrowFees(
        address user,
        uint256 borrowAmount,
        uint256 flashBorrowFeePercent)
        external;

}


interface IBridge {

    function send(
        address _receiver,
        address _token,
        uint256 _amount,
        uint64 _dstChainId,
        uint64 _nonce,
        uint32 _maxSlippage
    ) external;


    function relay(
        bytes calldata _relayRequest,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;


    function transfers(bytes32 transferId) external view returns (bool);


    function withdraws(bytes32 withdrawId) external view returns (bool);


    function withdraw(
        bytes calldata _wdmsg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external;


    function verifySigs(
        bytes memory _msg,
        bytes[] calldata _sigs,
        address[] calldata _signers,
        uint256[] calldata _powers
    ) external view;

}


interface ICurve3Pool {

    function add_liquidity(
        uint256[3] calldata amounts,
        uint256 min_mint_amount)
        external;


    function remove_liquidity_one_coin(
        uint256 token_amount,
        int128 i,
        uint256 min_amount
    ) external;


    function get_virtual_price()
        external
        view
        returns (uint256);

}


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


interface IStakingV2 {

    struct ProposalState {
        uint256 proposalTime;
        uint256 iOOKIWeight;
        uint256 lpOOKIBalance;
        uint256 lpTotalSupply;
    }

    struct AltRewardsUserInfo {
        uint256 rewardsPerShare;
        uint256 pendingRewards;
    }

    function getCurrentFeeTokens() external view returns (address[] memory);


    function maxUniswapDisagreement() external view returns (uint256);


    function fundsWallet() external view returns (address);


    function callerRewardDivisor() external view returns (uint256);


    function maxCurveDisagreement() external view returns (uint256);


    function rewardPercent() external view returns (uint256);


    function addRewards(uint256 newOOKI, uint256 newStableCoin) external;


    function stake(address[] calldata tokens, uint256[] calldata values) external;


    function unstake(address[] calldata tokens, uint256[] calldata values) external;


    function earned(address account)
        external
        view
        returns (
            uint256 bzrxRewardsEarned,
            uint256 stableCoinRewardsEarned,
            uint256 bzrxRewardsVesting,
            uint256 stableCoinRewardsVesting,
            uint256 sushiRewardsEarned
        );


    function pendingCrvRewards(address account)
        external
        view
        returns (
            uint256 bzrxRewardsEarned,
            uint256 stableCoinRewardsEarned,
            uint256 bzrxRewardsVesting,
            uint256 stableCoinRewardsVesting,
            uint256 sushiRewardsEarned
        );


    function getVariableWeights()
        external
        view
        returns (
            uint256 vBZRXWeight,
            uint256 iOOKIWeight,
            uint256 LPTokenWeight
        );


    function balanceOfByAsset(address token, address account) external view returns (uint256 balance);


    function balanceOfByAssets(address account)
        external
        view
        returns (
            uint256 bzrxBalance,
            uint256 iOOKIBalance,
            uint256 vBZRXBalance,
            uint256 LPTokenBalance
        );


    function balanceOfStored(address account) external view returns (uint256 vestedBalance, uint256 vestingBalance);


    function totalSupplyStored() external view returns (uint256 supply);


    function vestedBalanceForAmount(
        uint256 tokenBalance,
        uint256 lastUpdate,
        uint256 vestingEndTime
    ) external view returns (uint256 vested);


    function votingBalanceOf(address account, uint256 proposalId) external view returns (uint256 totalVotes);


    function votingBalanceOfNow(address account) external view returns (uint256 totalVotes);


    function votingFromStakedBalanceOf(address account) external view returns (uint256 totalVotes);


    function _setProposalVals(address account, uint256 proposalId) external returns (uint256);


    function exit() external;


    function addAltRewards(address token, uint256 amount) external;


    function governor() external view returns (address);


    function owner() external view returns (address);


    function transferOwnership(address newOwner) external;


    function claim(bool restake) external;


    function claimAltRewards() external;


    function _totalSupplyPerToken(address) external view returns(uint256);




    function _isPaused(bytes4 sig) external view returns (bool isPaused);


    function toggleFunctionPause(bytes4 sig) external;


    function toggleFunctionUnPause(bytes4 sig) external;


    function changeGuardian(address newGuardian) external;


    function getGuardian() external view returns (address guardian);



    function exitSushi() external;


    function setGovernor(address _governor) external;


    function setApprovals(
        address _token,
        address _spender,
        uint256 _value
    ) external;


    function setVoteDelegator(address stakingGovernance) external;


    function updateSettings(address settingsTarget, bytes calldata callData) external;


    function claimSushi() external returns (uint256 sushiRewardsEarned);


    function totalSupplyByAsset(address token)
        external
        view
        returns (uint256);


    function vestingLastSync(address user) external view returns(uint256);

}


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
}


library SafeERC20 {

    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {

        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}


contract PausableGuardian_0_8 is Ownable {

    bytes32 internal constant Pausable_FunctionPause = 0xa7143c84d793a15503da6f19bf9119a2dac94448ca45d77c8bf08f57b2e91047;

    bytes32 internal constant Pausable_GuardianAddress = 0x80e6706973d0c59541550537fd6a33b971efad732635e6c3b99fb01006803cdf;

    modifier pausable() {

        require(!_isPaused(msg.sig) || msg.sender == getGuardian(), "paused");
        _;
    }

    function _isPaused(bytes4 sig) public view returns (bool isPaused) {

        bytes32 slot = keccak256(abi.encodePacked(sig, Pausable_FunctionPause));
        assembly {
            isPaused := sload(slot)
        }
    }

    function toggleFunctionPause(bytes4 sig) public {

        require(msg.sender == getGuardian() || msg.sender == owner(), "unauthorized");
        bytes32 slot = keccak256(abi.encodePacked(sig, Pausable_FunctionPause));
        assembly {
            sstore(slot, 1)
        }
    }

    function toggleFunctionUnPause(bytes4 sig) public {

        require(msg.sender == getGuardian() || msg.sender == owner(), "unauthorized");
        bytes32 slot = keccak256(abi.encodePacked(sig, Pausable_FunctionPause));
        assembly {
            sstore(slot, 0)
        }
    }

    function changeGuardian(address newGuardian) public {

        require(msg.sender == getGuardian() || msg.sender == owner(), "unauthorized");
        assembly {
            sstore(Pausable_GuardianAddress, newGuardian)
        }
    }

    function getGuardian() public view returns (address guardian) {

        assembly {
            guardian := sload(Pausable_GuardianAddress)
        }
    }
}


contract FeeExtractAndDistribute_ETH is PausableGuardian_0_8 {

    using SafeERC20 for IERC20;
    address public implementation;
    IStakingV2 public constant STAKING =
        IStakingV2(0x16f179f5C344cc29672A58Ea327A26F64B941a63);

    address public constant OOKI = 0x0De05F6447ab4D22c8827449EE4bA2D5C288379B;
    IERC20 public constant CURVE_3CRV =
        IERC20(0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490);

    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;

    address public constant BUYBACK =
        0x12EBd8263A54751Aaf9d8C2c74740A8e62C0AfBe;
    address public constant BRIDGE = 0x5427FEFA711Eff984124bFBB1AB6fbf5E3DA1820;
    uint64 public constant DEST_CHAINID = 137; //polygon

    IUniswapV2Router public constant UNISWAP_ROUTER =
        IUniswapV2Router(0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F); // sushiswap
    ICurve3Pool public constant CURVE_3POOL =
        ICurve3Pool(0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7);
    IBZx public constant BZX = IBZx(0xD8Ee69652E4e4838f2531732a46d1f7F584F0b7f);

    mapping(address => address[]) public swapPaths;
    mapping(address => uint256) public stakingRewards;
    address[] public feeTokens;
    uint256 public buybackPercent;

    event ExtractAndDistribute();

    event WithdrawFees(address indexed sender);

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


    function sweepFees()
        public
        pausable
        returns (uint256 bzrxRewards, uint256 crv3Rewards)
    {

        uint256[] memory amounts = _withdrawFees(feeTokens);
        _convertFees(feeTokens, amounts);
        (bzrxRewards, crv3Rewards) = _distributeFees();
    }

    function sweepFees(address[] memory assets)
        public
        pausable
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

        uint256[] memory amounts = BZX.withdrawFees(
            assets,
            address(this),
            IBZx.FeeClaimType.All
        );

        for (uint256 i = 0; i < assets.length; i++) {
            stakingRewards[assets[i]] += amounts[i];
        }

        emit WithdrawFees(msg.sender);
        return amounts;
    }

    function _convertFees(address[] memory assets, uint256[] memory amounts)
        internal
        returns (uint256 bzrxOutput, uint256 crv3Output)
    {

        require(assets.length == amounts.length, "count mismatch");

        IPriceFeeds priceFeeds = IPriceFeeds(BZX.priceFeeds());
        uint256 maxDisagreement = 1e18;
        address asset;
        uint256 daiAmount;
        uint256 usdcAmount;
        uint256 usdtAmount;
        for (uint256 i = 0; i < assets.length; i++) {
            asset = assets[i];
            if (asset == OOKI) {
                continue;
            } else if (asset == DAI) {
                daiAmount += amounts[i];
                continue;
            } else if (asset == USDC) {
                usdcAmount += amounts[i];
                continue;
            } else if (asset == USDT) {
                usdtAmount += amounts[i];
                continue;
            }

            if (amounts[i] != 0) {
                bzrxOutput += _convertFeeWithUniswap(
                    asset,
                    amounts[i],
                    priceFeeds,
                    0, /*bzrxRate*/
                    maxDisagreement
                );
            }
        }
        if (bzrxOutput != 0) {
            stakingRewards[OOKI] += bzrxOutput;
        }

        if (daiAmount != 0 || usdcAmount != 0 || usdtAmount != 0) {
            crv3Output = _convertFeesWithCurve(
                daiAmount,
                usdcAmount,
                usdtAmount
            );
            stakingRewards[address(CURVE_3CRV)] += crv3Output;
        }

        emit ConvertFees(msg.sender, bzrxOutput, crv3Output);
    }

    function _distributeFees()
        internal
        returns (uint256 bzrxRewards, uint256 crv3Rewards)
    {

        bzrxRewards = stakingRewards[OOKI];
        crv3Rewards = stakingRewards[address(CURVE_3CRV)];
        uint256 USDCBridge = 0;
        if (bzrxRewards != 0 || crv3Rewards != 0) {
            address _fundsWallet = 0xfedC4dD5247B93feb41e899A09C44cFaBec29Cbc;
            uint256 rewardAmount;
            uint256 callerReward;
            uint256 bridgeRewards;
            if (bzrxRewards != 0) {
                stakingRewards[OOKI] = 0;
                callerReward = bzrxRewards / 100;
                IERC20(OOKI).transfer(msg.sender, callerReward);
                bzrxRewards = bzrxRewards - (callerReward);
                bridgeRewards = (bzrxRewards * (buybackPercent)) / (1e20);
                USDCBridge = _convertToUSDCUniswap(bridgeRewards);
                rewardAmount = (bzrxRewards * (50e18)) / (1e20);
                IERC20(OOKI).transfer(
                    _fundsWallet,
                    bzrxRewards - rewardAmount - bridgeRewards
                );
                bzrxRewards = rewardAmount;
            }
            if (crv3Rewards != 0) {
                stakingRewards[address(CURVE_3CRV)] = 0;
                callerReward = crv3Rewards / 100;
                CURVE_3CRV.transfer(msg.sender, callerReward);
                crv3Rewards = crv3Rewards - (callerReward);
                bridgeRewards = (crv3Rewards * (buybackPercent)) / (1e20);
                USDCBridge += _convertToUSDCCurve(bridgeRewards);
                rewardAmount = (crv3Rewards * (50e18)) / (1e20);
                CURVE_3CRV.transfer(
                    _fundsWallet,
                    crv3Rewards - rewardAmount - bridgeRewards
                );
                crv3Rewards = rewardAmount;
            }
            STAKING.addRewards(bzrxRewards, crv3Rewards);
            _bridgeFeesToPolygon(USDCBridge);
        }

        emit DistributeFees(msg.sender, bzrxRewards, crv3Rewards);
    }

    function _bridgeFeesToPolygon(uint256 bridgeAmount) internal {

        IBridge(BRIDGE).send(
            BUYBACK,
            USDC,
            bridgeAmount,
            DEST_CHAINID,
            uint64(block.timestamp),
            10000
        );
    }

    function _convertToUSDCUniswap(uint256 amount)
        internal
        returns (uint256 returnAmount)
    {

        address[] memory path = new address[](3);
        path[0] = OOKI;
        path[1] = WETH;
        path[2] = USDC;
        uint256[] memory amounts = UNISWAP_ROUTER.swapExactTokensForTokens(
            amount,
            1, // amountOutMin
            path,
            address(this),
            block.timestamp
        );

        returnAmount = amounts[amounts.length - 1];
        IPriceFeeds priceFeeds = IPriceFeeds(BZX.priceFeeds());
    }

    function _convertFeeWithUniswap(
        address asset,
        uint256 amount,
        IPriceFeeds priceFeeds,
        uint256 bzrxRate,
        uint256 maxDisagreement
    ) internal returns (uint256 returnAmount) {

        uint256 stakingReward = stakingRewards[asset];
        if (stakingReward != 0) {
            if (amount > stakingReward) {
                amount = stakingReward;
            }
            stakingRewards[asset] = stakingReward - (amount);

            uint256[] memory amounts = UNISWAP_ROUTER.swapExactTokensForTokens(
                amount,
                1, // amountOutMin
                swapPaths[asset],
                address(this),
                block.timestamp
            );

            returnAmount = amounts[amounts.length - 1];

        }
    }

    function _convertToUSDCCurve(uint256 amount)
        internal
        returns (uint256 returnAmount)
    {

        uint256 beforeBalance = IERC20(USDC).balanceOf(address(this));
        CURVE_3POOL.remove_liquidity_one_coin(amount, 1, 1); //does not need to be checked for disagreement as liquidity add handles that
        returnAmount = IERC20(USDC).balanceOf(address(this)) - beforeBalance; //does not underflow as USDC is not being transferred out
    }

    function _convertFeesWithCurve(
        uint256 daiAmount,
        uint256 usdcAmount,
        uint256 usdtAmount
    ) internal returns (uint256 returnAmount) {

        uint256[3] memory curveAmounts;
        uint256 curveTotal;
        uint256 stakingReward;

        if (daiAmount != 0) {
            stakingReward = stakingRewards[DAI];
            if (stakingReward != 0) {
                if (daiAmount > stakingReward) {
                    daiAmount = stakingReward;
                }
                stakingRewards[DAI] = stakingReward - (daiAmount);
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
                stakingRewards[USDC] = stakingReward - (usdcAmount);
                curveAmounts[1] = usdcAmount;
                curveTotal += usdcAmount * 1e12; // normalize to 18 decimals
            }
        }
        if (usdtAmount != 0) {
            stakingReward = stakingRewards[USDT];
            if (stakingReward != 0) {
                if (usdtAmount > stakingReward) {
                    usdtAmount = stakingReward;
                }
                stakingRewards[USDT] = stakingReward - (usdtAmount);
                curveAmounts[2] = usdtAmount;
                curveTotal += usdtAmount * 1e12; // normalize to 18 decimals
            }
        }

        uint256 beforeBalance = CURVE_3CRV.balanceOf(address(this));
        CURVE_3POOL.add_liquidity(
            curveAmounts,
            (curveTotal * 1e18 / CURVE_3POOL.get_virtual_price())*995/1000
        );
        returnAmount = CURVE_3CRV.balanceOf(address(this)) - beforeBalance;
    }

    function _checkUniDisagreement(
        address asset,
        address recvAsset,
        uint256 assetAmount,
        uint256 recvAmount,
        uint256 maxDisagreement
    ) internal view {

        uint256 estAmountOut = IPriceFeeds(BZX.priceFeeds()).queryReturn(
            asset,
            recvAsset,
            assetAmount
        );

        uint256 spreadValue = estAmountOut > recvAmount
            ? estAmountOut - recvAmount
            : recvAmount - estAmountOut;
        if (spreadValue != 0) {
            spreadValue = (spreadValue * 1e20) / estAmountOut;

            require(
                spreadValue <= maxDisagreement,
                "uniswap price disagreement"
            );
        }
    }

    function setApprovals() external onlyOwner {

        IERC20(DAI).safeApprove(address(CURVE_3POOL), type(uint256).max);
        IERC20(USDC).safeApprove(address(CURVE_3POOL), type(uint256).max);
        IERC20(USDC).safeApprove(BRIDGE, type(uint256).max);
        IERC20(USDT).safeApprove(address(CURVE_3POOL), 0);
        IERC20(USDT).safeApprove(address(CURVE_3POOL), type(uint256).max);


        IERC20(OOKI).safeApprove(address(STAKING), type(uint256).max);
        IERC20(OOKI).safeApprove(address(UNISWAP_ROUTER), type(uint256).max);
        CURVE_3CRV.safeApprove(address(STAKING), type(uint256).max);
    }

    function setPaths(address[][] calldata paths) external onlyOwner {

        address[] memory path;
        for (uint256 i = 0; i < paths.length; i++) {
            path = paths[i];
            require(
                path.length >= 2 &&
                    path[0] != path[path.length - 1] &&
                    path[path.length - 1] == OOKI,
                "invalid path"
            );

            uint256[] memory amountsOut = UNISWAP_ROUTER.getAmountsOut(
                1e10,
                path
            );
            require(
                amountsOut[amountsOut.length - 1] != 0,
                "path does not exist"
            );

            swapPaths[path[0]] = path;
            IERC20(path[0]).safeApprove(address(UNISWAP_ROUTER), 0);
            IERC20(path[0]).safeApprove(address(UNISWAP_ROUTER), type(uint256).max);
        }
    }

    function setBuybackSettings(uint256 amount) external onlyOwner {

        buybackPercent = amount;
    }

    function setFeeTokens(address[] calldata tokens) external onlyOwner {

        feeTokens = tokens;
    }
}