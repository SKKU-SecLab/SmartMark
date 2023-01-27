
pragma solidity >=0.5.0 <0.6.0;


interface IWeth {

    function deposit() external payable;

    function withdraw(uint256 wad) external;

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
}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity >=0.5.0 <0.6.0;



contract IWethERC20 is IWeth, IERC20 {}/**

 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;



contract Constants {


    uint256 internal constant WEI_PRECISION = 10**18;
    uint256 internal constant WEI_PERCENT_PRECISION = 10**20;

    uint256 internal constant DAYS_IN_A_YEAR = 365;
    uint256 internal constant ONE_MONTH = 2628000; // approx. seconds in a month

    string internal constant LoanDepositValueID = "LoanDepositValue";

    IWethERC20 public constant wethToken = IWethERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2); // mainnet
    address public constant bzrxTokenAddress = 0x56d811088235F11C8920698a204A5010a788f4b3; // mainnet
    address public constant vbzrxTokenAddress = 0xB72B31907C1C95F3650b64b2469e08EdACeE5e8F; // mainnet
    address public constant OOKI = address(0x0De05F6447ab4D22c8827449EE4bA2D5C288379B); // mainnet

    




}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;


contract LoanStruct {

    struct Loan {
        bytes32 id;                 // id of the loan
        bytes32 loanParamsId;       // the linked loan params id
        bytes32 pendingTradesId;    // the linked pending trades id
        uint256 principal;          // total borrowed amount outstanding
        uint256 collateral;         // total collateral escrowed for the loan
        uint256 startTimestamp;     // loan start time
        uint256 endTimestamp;       // for active loans, this is the expected loan end time, for in-active loans, is the actual (past) end time
        uint256 startMargin;        // initial margin when the loan opened
        uint256 startRate;          // reference rate when the loan opened for converting collateralToken to loanToken
        address borrower;           // borrower of this loan
        address lender;             // lender of this loan
        bool active;                // if false, the loan has been fully closed
    }
}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;


contract LoanParamsStruct {

    struct LoanParams {
        bytes32 id;                 // id of loan params object
        bool active;                // if false, this object has been disabled by the owner and can't be used for future loans
        address owner;              // owner of this object
        address loanToken;          // the token being loaned
        address collateralToken;    // the required collateral token
        uint256 minInitialMargin;   // the minimum allowed initial margin
        uint256 maintenanceMargin;  // an unhealthy loan when current margin is at or below this value
        uint256 maxLoanTerm;        // the maximum term for new loans (0 means there's no max term)
    }
}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;


contract OrderStruct {

    struct Order {
        uint256 lockedAmount;           // escrowed amount waiting for a counterparty
        uint256 interestRate;           // interest rate defined by the creator of this order
        uint256 minLoanTerm;            // minimum loan term allowed
        uint256 maxLoanTerm;            // maximum loan term allowed
        uint256 createdTimestamp;       // timestamp when this order was created
        uint256 expirationTimestamp;    // timestamp when this order expires
    }
}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;


contract LenderInterestStruct {

    struct LenderInterest {
        uint256 principalTotal;     // total borrowed amount outstanding of asset (DEPRECIATED)
        uint256 owedPerDay;         // interest owed per day for all loans of asset (DEPRECIATED)
        uint256 owedTotal;          // total interest owed for all loans of asset (DEPRECIATED)
        uint256 paidTotal;          // total interest paid so far for asset (DEPRECIATED)
        uint256 updatedTimestamp;   // last update (DEPRECIATED)
    }
}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;


contract LoanInterestStruct {

    struct LoanInterest {
        uint256 owedPerDay;         // interest owed per day for loan (DEPRECIATED)
        uint256 depositTotal;       // total escrowed interest for loan (DEPRECIATED)
        uint256 updatedTimestamp;   // last update (DEPRECIATED)
    }
}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;



contract Objects is
    LoanStruct,
    LoanParamsStruct,
    OrderStruct,
    LenderInterestStruct,
    LoanInterestStruct
{}/**

 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;

library EnumerableBytes32Set {


    struct Bytes32Set {
        mapping (bytes32 => uint256) index;
        bytes32[] values;
    }

    function addAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return addBytes32(set, value);
    }

    function addBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        if (!contains(set, value)){
            set.index[value] = set.values.push(value);
            return true;
        } else {
            return false;
        }
    }

    function removeAddress(Bytes32Set storage set, address addrvalue)
        internal
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return removeBytes32(set, value);
    }

    function removeBytes32(Bytes32Set storage set, bytes32 value)
        internal
        returns (bool)
    {

        if (contains(set, value)){
            uint256 toDeleteIndex = set.index[value] - 1;
            uint256 lastIndex = set.values.length - 1;

            if (lastIndex != toDeleteIndex) {
                bytes32 lastValue = set.values[lastIndex];

                set.values[toDeleteIndex] = lastValue;
                set.index[lastValue] = toDeleteIndex + 1; // All indexes are 1-based
            }

            delete set.index[value];

            set.values.pop();

            return true;
        } else {
            return false;
        }
    }

    function contains(Bytes32Set storage set, bytes32 value)
        internal
        view
        returns (bool)
    {

        return set.index[value] != 0;
    }

    function containsAddress(Bytes32Set storage set, address addrvalue)
        internal
        view
        returns (bool)
    {

        bytes32 value;
        assembly {
            value := addrvalue
        }
        return set.index[value] != 0;
    }

    function enumerate(Bytes32Set storage set, uint256 start, uint256 count)
        internal
        view
        returns (bytes32[] memory output)
    {

        uint256 end = start + count;
        require(end >= start, "addition overflow");
        end = set.values.length < end ? set.values.length : end;
        if (end == 0 || start >= end) {
            return output;
        }

        output = new bytes32[](end-start);
        for (uint256 i = start; i < end; i++) {
            output[i-start] = set.values[i];
        }
        return output;
    }

    function length(Bytes32Set storage set)
        internal
        view
        returns (uint256)
    {

        return set.values.length;
    }

    function get(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (bytes32)
    {

        return set.values[index];
    }

    function getAddress(Bytes32Set storage set, uint256 index)
        internal
        view
        returns (address)
    {

        bytes32 value = set.values[index];
        address addrvalue;
        assembly {
            addrvalue := value
        }
        return addrvalue;
    }
}pragma solidity >=0.5.0 <0.6.0;


contract ReentrancyGuard {


    uint256 internal constant REENTRANCY_GUARD_FREE = 1;

    uint256 internal constant REENTRANCY_GUARD_LOCKED = 2;

    uint256 internal reentrancyLock = REENTRANCY_GUARD_FREE;

    modifier nonReentrant() {

        require(reentrancyLock == REENTRANCY_GUARD_FREE, "nonReentrant");
        reentrancyLock = REENTRANCY_GUARD_LOCKED;
        _;
        reentrancyLock = REENTRANCY_GUARD_FREE;
    }

}pragma solidity ^0.5.0;

library InterestOracle {

    struct Observation {
        uint32 blockTimestamp;
        int56 irCumulative;
        int24 tick;
    }

    function convert(
        Observation memory last,
        uint32 blockTimestamp,
        int24 tick
    ) private pure returns (Observation memory) {

        return
            Observation({
                blockTimestamp: blockTimestamp,
                irCumulative: last.irCumulative + int56(tick) * (blockTimestamp - last.blockTimestamp),
                tick: tick
            });
    }

    function write(
        Observation[256] storage self,
        uint8 index,
        uint32 blockTimestamp,
        int24 tick,
        uint8 cardinality,
        uint32 minDelta
    ) internal returns (uint8 indexUpdated) {

        Observation memory last = self[index];

        if (last.blockTimestamp + minDelta >= blockTimestamp) return index;

        indexUpdated = (index + 1) % cardinality;
        self[indexUpdated] = convert(last, blockTimestamp, tick);
    }

    function binarySearch(
        Observation[256] storage self,
        uint32 target,
        uint8 index,
        uint8 cardinality
    ) private view returns (Observation memory beforeOrAt, Observation memory atOrAfter) {

        uint256 l = (index + 1) % cardinality; // oldest observation
        uint256 r = l + cardinality - 1; // newest observation
        uint256 i;
        while (true) {
            i = (l + r) / 2;

            beforeOrAt = self[i % cardinality];

            if (beforeOrAt.blockTimestamp == 0) {
                l = 0;
                r = index;
                continue;
            }

            atOrAfter = self[(i + 1) % cardinality];

            bool targetAtOrAfter = beforeOrAt.blockTimestamp <= target;
            bool targetBeforeOrAt = atOrAfter.blockTimestamp >= target;
            if (!targetAtOrAfter) {
                r = i - 1;
                continue;
            } else if (!targetBeforeOrAt) {
                l = i + 1;
                continue;
            }
            break;
        }
    }

    function getSurroundingObservations(
        Observation[256] storage self,
        uint32 target,
        int24 tick,
        uint8 index,
        uint8 cardinality
    ) private view returns (Observation memory beforeOrAt, Observation memory atOrAfter) {


        beforeOrAt = self[index];

        if (beforeOrAt.blockTimestamp <= target) {
            if (beforeOrAt.blockTimestamp == target) {
                return (beforeOrAt, atOrAfter);
            } else {
                return (beforeOrAt, convert(beforeOrAt, target, tick));
            }
        }

        beforeOrAt = self[(index + 1) % cardinality];
        if (beforeOrAt.blockTimestamp == 0) beforeOrAt = self[0];
        require(beforeOrAt.blockTimestamp <= target && beforeOrAt.blockTimestamp != 0, "OLD");
        return binarySearch(self, target, index, cardinality);
    }

    function observeSingle(
        Observation[256] storage self,
        uint32 time,
        uint32 secondsAgo,
        int24 tick,
        uint8 index,
        uint8 cardinality
    ) internal view returns (int56 irCumulative) {

        if (secondsAgo == 0) {
            Observation memory last = self[index];
            if (last.blockTimestamp != time) {
                last = convert(last, time, tick);
            }
            return last.irCumulative;
        }

        uint32 target = time - secondsAgo;

        (Observation memory beforeOrAt, Observation memory atOrAfter) =
            getSurroundingObservations(self, target, tick, index, cardinality);

        if (target == beforeOrAt.blockTimestamp) {
            return beforeOrAt.irCumulative;
        } else if (target == atOrAfter.blockTimestamp) {
            return atOrAfter.irCumulative;
        } else {
            return
                beforeOrAt.irCumulative +
                    ((atOrAfter.irCumulative - beforeOrAt.irCumulative) / (atOrAfter.blockTimestamp - beforeOrAt.blockTimestamp)) *
                    (target - beforeOrAt.blockTimestamp);
        }
    }

    function arithmeticMean(
        Observation[256] storage self,
        uint32 time,
        uint32[2] memory secondsAgos,
        int24 tick,
        uint8 index,
        uint8 cardinality
    ) internal view returns (int24) {

        int56 firstPoint = observeSingle(self, time, secondsAgos[1], tick, index, cardinality);
        int56 secondPoint = observeSingle(self, time, secondsAgos[0], tick, index, cardinality);
        return int24((firstPoint-secondPoint) / (secondsAgos[0]-secondsAgos[1]));
    }
}pragma solidity ^0.5.0;

contract Context {

    constructor () internal { }

    function _msgSender() internal view returns (address payable) {

        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {

        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}pragma solidity ^0.5.0;

contract Ownable is Context {

    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {

        return _owner;
    }

    modifier onlyOwner() {

        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    function isOwner() public view returns (bool) {

        return _msgSender() == _owner;
    }

    function renounceOwnership() public onlyOwner {

        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {

        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {

        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
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
}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;




contract State is Constants, Objects, ReentrancyGuard, Ownable {

    using SafeMath for uint256;
    using EnumerableBytes32Set for EnumerableBytes32Set.Bytes32Set;
    address public priceFeeds;                                                              // handles asset reference price lookups
    address public swapsImpl;                                                               // handles asset swaps using dex liquidity

    mapping (bytes4 => address) public logicTargets;                                        // implementations of protocol functions

    mapping (bytes32 => Loan) public loans;                                                 // loanId => Loan
    mapping (bytes32 => LoanParams) public loanParams;                                      // loanParamsId => LoanParams

    mapping (address => mapping (bytes32 => Order)) public lenderOrders;                    // lender => orderParamsId => Order
    mapping (address => mapping (bytes32 => Order)) public borrowerOrders;                  // borrower => orderParamsId => Order

    mapping (bytes32 => mapping (address => bool)) public delegatedManagers;                // loanId => delegated => approved

    mapping (address => mapping (address => LenderInterest)) public lenderInterest;         // lender => loanToken => LenderInterest object (depreciated)
    mapping (bytes32 => LoanInterest) public loanInterest;                                  // loanId => LoanInterest object (depreciated)

    EnumerableBytes32Set.Bytes32Set internal logicTargetsSet;                               // implementations set
    EnumerableBytes32Set.Bytes32Set internal activeLoansSet;                                // active loans set

    mapping (address => EnumerableBytes32Set.Bytes32Set) internal lenderLoanSets;           // lender loans set
    mapping (address => EnumerableBytes32Set.Bytes32Set) internal borrowerLoanSets;         // borrow loans set
    mapping (address => EnumerableBytes32Set.Bytes32Set) internal userLoanParamSets;        // user loan params set

    address public feesController;                                                          // address controlling fee withdrawals

    uint256 public lendingFeePercent = 10 ether; // 10% fee                                 // fee taken from lender interest payments
    mapping (address => uint256) public lendingFeeTokensHeld;                               // total interest fees received and not withdrawn per asset
    mapping (address => uint256) public lendingFeeTokensPaid;                               // total interest fees withdraw per asset (lifetime fees = lendingFeeTokensHeld + lendingFeeTokensPaid)

    uint256 public tradingFeePercent = 0.15 ether; // 0.15% fee                             // fee paid for each trade
    mapping (address => uint256) public tradingFeeTokensHeld;                               // total trading fees received and not withdrawn per asset
    mapping (address => uint256) public tradingFeeTokensPaid;                               // total trading fees withdraw per asset (lifetime fees = tradingFeeTokensHeld + tradingFeeTokensPaid)

    uint256 public borrowingFeePercent = 0.09 ether; // 0.09% fee                           // origination fee paid for each loan
    mapping (address => uint256) public borrowingFeeTokensHeld;                             // total borrowing fees received and not withdrawn per asset
    mapping (address => uint256) public borrowingFeeTokensPaid;                             // total borrowing fees withdraw per asset (lifetime fees = borrowingFeeTokensHeld + borrowingFeeTokensPaid)

    uint256 public protocolTokenHeld;                                                       // current protocol token deposit balance
    uint256 public protocolTokenPaid;                                                       // lifetime total payout of protocol token

    uint256 public affiliateFeePercent = 30 ether; // 30% fee share                         // fee share for affiliate program

    mapping (address => mapping (address => uint256)) public liquidationIncentivePercent;   // percent discount on collateral for liquidators per loanToken and collateralToken

    mapping (address => address) public loanPoolToUnderlying;                               // loanPool => underlying
    mapping (address => address) public underlyingToLoanPool;                               // underlying => loanPool
    EnumerableBytes32Set.Bytes32Set internal loanPoolsSet;                                  // loan pools set

    mapping (address => bool) public supportedTokens;                                       // supported tokens for swaps

    uint256 public maxDisagreement = 5 ether;                                               // % disagreement between swap rate and reference rate

    uint256 public sourceBufferPercent = 5 ether;                                           // used to estimate kyber swap source amount

    uint256 public maxSwapSize = 1500 ether;                                                // maximum supported swap size in ETH


    mapping(address => uint256) public poolLastUpdateTime; // per itoken
    mapping(address => uint256) public poolPrincipalTotal; // per itoken
    mapping(address => uint256) public poolInterestTotal; // per itoken
    mapping(address => uint256) public poolRatePerTokenStored; // per itoken

    mapping(bytes32 => uint256) public loanInterestTotal; // per loan
    mapping(bytes32 => uint256) public loanRatePerTokenPaid; // per loan

    mapping(address => uint256) internal poolLastInterestRate; // per itoken
    mapping(address => InterestOracle.Observation[256]) internal poolInterestRateObservations; // per itoken
    mapping(address => uint8) internal poolLastIdx; // per itoken
    uint32 public timeDelta;
    uint32 public twaiLength;


    function _setTarget(
        bytes4 sig,
        address target)
        internal
    {

        logicTargets[sig] = target;

        if (target != address(0)) {
            logicTargetsSet.addBytes32(bytes32(sig));
        } else {
            logicTargetsSet.removeBytes32(bytes32(sig));
        }
    }
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
}/**
 * Copyright 2017-2022, OokiDao. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity >=0.5.17;

interface ISwapsImpl {

    function dexSwap(
        address sourceTokenAddress,
        address destTokenAddress,
        address receiverAddress,
        address returnToSenderAddress,
        uint256 minSourceTokenAmount,
        uint256 maxSourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes calldata payload
    )
        external
        returns (
            uint256 destTokenAmountReceived,
            uint256 sourceTokenAmountUsed
        );


    function dexExpectedRate(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount
    ) external view returns (uint256);


    function dexAmountOut(bytes calldata route, uint256 amountIn)
        external
        returns (uint256 amountOut, address midToken);


    function dexAmountOutFormatted(bytes calldata route, uint256 amountOut)
        external
        returns (uint256 amountIn, address midToken);


    function dexAmountIn(bytes calldata route, uint256 amountOut)
        external
        returns (uint256 amountIn, address midToken);


    function dexAmountInFormatted(bytes calldata route, uint256 amountOut)
        external
        returns (uint256 amountIn, address midToken);


    function setSwapApprovals(address[] calldata tokens) external;

	
    function revokeApprovals(address[] calldata tokens) external;

}pragma solidity >=0.5.0 <0.9.0;
pragma experimental ABIEncoderV2;

interface IUniswapV3SwapRouter {

    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }
    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }
    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    function exactInput(ExactInputParams calldata params)
        external
        returns (uint256 amountOut);


    function exactOutput(ExactOutputParams calldata params)
        external
        returns (uint256 amountIn);


    function multicall(bytes[] calldata data)
        external
        payable
        returns (bytes[] memory results);

}pragma solidity >=0.5.17;

interface IUniswapQuoter {

    function quoteExactInput(bytes calldata path, uint256 amountIn)
        external
        returns (uint256 amountOut);


    function quoteExactOutput(bytes calldata path, uint256 amountOut)
        external
        returns (uint256 amountIn);

}/**
 * Copyright 2017-2021, bZeroX, LLC. All Rights Reserved.
 * Licensed under the Apache License, Version 2.0.
 */

pragma solidity 0.5.17;

contract SwapsImplUniswapV3_ETH is State, ISwapsImpl {

    using SafeERC20 for IERC20;
    IUniswapV3SwapRouter public constant uniswapSwapRouter =
        IUniswapV3SwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564); //mainnet
    IUniswapQuoter public constant uniswapQuoteContract =
        IUniswapQuoter(0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6); //mainnet

    function dexSwap(
        address sourceTokenAddress,
        address destTokenAddress,
        address receiverAddress,
        address returnToSenderAddress,
        uint256 minSourceTokenAmount,
        uint256 maxSourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes memory payload
    )
        public
        returns (uint256 destTokenAmountReceived, uint256 sourceTokenAmountUsed)
    {

        require(sourceTokenAddress != destTokenAddress, "source == dest");
        require(
            supportedTokens[sourceTokenAddress] &&
                supportedTokens[destTokenAddress],
            "invalid tokens"
        );

        IERC20 sourceToken = IERC20(sourceTokenAddress);
        address _thisAddress = address(this);
        (sourceTokenAmountUsed, destTokenAmountReceived) = _swapWithUni(
            sourceTokenAddress,
            destTokenAddress,
            receiverAddress,
            minSourceTokenAmount,
            maxSourceTokenAmount,
            requiredDestTokenAmount,
            payload
        );

        if (
            returnToSenderAddress != _thisAddress &&
            sourceTokenAmountUsed < maxSourceTokenAmount
        ) {
            sourceToken.safeTransfer(
                returnToSenderAddress,
                maxSourceTokenAmount - sourceTokenAmountUsed
            );
        }
    }

    function dexExpectedRate(
        address sourceTokenAddress,
        address destTokenAddress,
        uint256 sourceTokenAmount
    ) public view returns (uint256 expectedRate) {

        revert("unsupported");
    }

    function dexAmountOut(bytes memory route, uint256 amountIn)
        public
        returns (uint256 amountOut, address midToken)
    {

        if (amountIn != 0) {
            amountOut = _getAmountOut(amountIn, route);
        }
    }

    function dexAmountOutFormatted(bytes memory payload, uint256 amountIn)
        public
        returns (uint256 amountOut, address midToken)
    {

        IUniswapV3SwapRouter.ExactInputParams[] memory exactParams = abi.decode(
            payload,
            (IUniswapV3SwapRouter.ExactInputParams[])
        );
        uint256 totalAmounts = 0;
        for (
            uint256 uniqueInputParam = 0;
            uniqueInputParam < exactParams.length;
            uniqueInputParam++
        ) {
            totalAmounts = totalAmounts.add(
                exactParams[uniqueInputParam].amountIn
            );
        }
        if (totalAmounts < amountIn) {
            exactParams[0].amountIn = exactParams[0].amountIn.add(
                amountIn.sub(totalAmounts)
            ); //adds displacement to first swap set
        } else {
            return dexAmountOut(exactParams[0].path, amountIn); //this else intentionally ignores the other swap impls. It is specifically designed to avoid edge cases
        }
        uint256 tempAmountOut;
        for (uint256 i = 0; i < exactParams.length; i++) {
            (tempAmountOut, ) = dexAmountOut(
                exactParams[i].path,
                exactParams[i].amountIn
            );
            amountOut = amountOut.add(tempAmountOut);
        }
    }

    function dexAmountIn(bytes memory route, uint256 amountOut)
        public
        returns (uint256 amountIn, address midToken)
    {

        if (amountOut != 0) {
            amountIn = _getAmountIn(amountOut, route);
        }
    }

    function dexAmountInFormatted(bytes memory payload, uint256 amountOut)
        public
        returns (uint256 amountIn, address midToken)
    {

        IUniswapV3SwapRouter.ExactOutputParams[] memory exactParams = abi
            .decode(payload, (IUniswapV3SwapRouter.ExactOutputParams[]));
        uint256 totalAmounts = 0;
        for (
            uint256 uniqueOutputParam = 0;
            uniqueOutputParam < exactParams.length;
            uniqueOutputParam++
        ) {
            totalAmounts = totalAmounts.add(
                exactParams[uniqueOutputParam].amountOut
            );
        }
        if (totalAmounts < amountOut) {
            exactParams[0].amountOut = exactParams[0].amountOut.add(
                amountOut.sub(totalAmounts)
            ); //adds displacement to first swap set
        } else {
            return dexAmountIn(exactParams[0].path, amountOut); //this else intentionally ignores the other swap impls. It is specifically designed to avoid edge cases
        }
        uint256 tempAmountIn;
        for (uint256 i = 0; i < exactParams.length; i++) {
            (tempAmountIn, ) = dexAmountIn(
                exactParams[i].path,
                exactParams[i].amountOut
            );
            amountOut.add(tempAmountIn);
        }
    }

    function _getAmountOut(uint256 amountIn, bytes memory path)
        public
        returns (uint256)
    {

        return uniswapQuoteContract
            .quoteExactInput(path, amountIn);
    }

    function _getAmountIn(uint256 amountOut, bytes memory path)
        public
        returns (uint256)
    {

        return uniswapQuoteContract
            .quoteExactOutput(path, amountOut);
    }

    function setSwapApprovals(address[] memory tokens) public {

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeApprove(address(uniswapSwapRouter), 0);
            IERC20(tokens[i]).safeApprove(
                address(uniswapSwapRouter),
                uint256(-1)
            );
        }
    }

    function revokeApprovals(address[] memory tokens) public {

        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeApprove(address(uniswapSwapRouter), 0);
        }
    }

    function _swapWithUni(
        address sourceTokenAddress,
        address destTokenAddress,
        address receiverAddress,
        uint256 minSourceTokenAmount,
        uint256 maxSourceTokenAmount,
        uint256 requiredDestTokenAmount,
        bytes memory payload
    )
        internal
        returns (uint256 sourceTokenAmountUsed, uint256 destTokenAmountReceived)
    {

        if (requiredDestTokenAmount != 0) {
            IUniswapV3SwapRouter.ExactOutputParams[] memory exactParams = abi
                .decode(payload, (IUniswapV3SwapRouter.ExactOutputParams[]));
            bytes[] memory encodedTXs = new bytes[](exactParams.length);
            uint256 totalAmountsOut = 0;
            uint256 totalAmountsInMax = 0;
            for (
                uint256 uniqueOutputParam = 0;
                uniqueOutputParam < exactParams.length;
                uniqueOutputParam++
            ) {
                exactParams[uniqueOutputParam].recipient = receiverAddress; //sets receiver to this protocol
                require(
                    _toAddress(exactParams[uniqueOutputParam].path, 0) ==
                        destTokenAddress &&
                        _toAddress(
                            exactParams[uniqueOutputParam].path,
                            exactParams[uniqueOutputParam].path.length - 20
                        ) ==
                        sourceTokenAddress,
                    "improper route"
                );
                totalAmountsOut = totalAmountsOut.add(
                    exactParams[uniqueOutputParam].amountOut
                );
                totalAmountsInMax = totalAmountsInMax.add(
                    exactParams[uniqueOutputParam].amountInMaximum
                );
                encodedTXs[uniqueOutputParam] = abi.encodeWithSelector(
                    uniswapSwapRouter.exactOutput.selector,
                    exactParams[uniqueOutputParam]
                );
            }
            require(
                totalAmountsInMax <= maxSourceTokenAmount,
                "Amount In Max too high"
            );
            if (totalAmountsOut < requiredDestTokenAmount) {
                uint256 displace = _numberAdjustment(
                    totalAmountsOut,
                    requiredDestTokenAmount
                );
                exactParams[0].amountOut += displace; //adds displacement to first swap set
                totalAmountsOut = requiredDestTokenAmount;
                encodedTXs[0] = abi.encodeWithSelector(
                    uniswapSwapRouter.exactOutput.selector,
                    exactParams[0]
                );
            }
            if (totalAmountsOut > requiredDestTokenAmount) {
                uint256 displace = _numberAdjustment(
                    totalAmountsOut,
                    requiredDestTokenAmount
                );
                exactParams[0].amountOut = exactParams[0].amountOut.sub(
                    displace
                ); //adds displacement to first swap set
                totalAmountsOut = requiredDestTokenAmount;
                encodedTXs[0] = abi.encodeWithSelector(
                    uniswapSwapRouter.exactOutput.selector,
                    exactParams[0]
                );
            }
            uint256 balanceBefore = IERC20(sourceTokenAddress).balanceOf(
                address(this)
            );
            uniswapSwapRouter.multicall(encodedTXs);
            sourceTokenAmountUsed =
                balanceBefore.sub(IERC20(sourceTokenAddress).balanceOf(address(this)));
            destTokenAmountReceived = requiredDestTokenAmount;
        } else {
            IUniswapV3SwapRouter.ExactInputParams[] memory exactParams = abi
                .decode(payload, (IUniswapV3SwapRouter.ExactInputParams[]));
            bytes[] memory encodedTXs = new bytes[](exactParams.length);
            for (
                uint256 uniqueInputParam = 0;
                uniqueInputParam < exactParams.length;
                uniqueInputParam++
            ) {
                exactParams[uniqueInputParam].recipient = receiverAddress; //sets receiver to this protocol
                require(
                    _toAddress(exactParams[uniqueInputParam].path, 0) ==
                        sourceTokenAddress &&
                        _toAddress(
                            exactParams[uniqueInputParam].path,
                            exactParams[uniqueInputParam].path.length - 20
                        ) ==
                        destTokenAddress,
                    "improper route"
                );
                sourceTokenAmountUsed = sourceTokenAmountUsed.add(
                    exactParams[uniqueInputParam].amountIn
                );
                encodedTXs[uniqueInputParam] = abi.encodeWithSelector(
                    uniswapSwapRouter.exactInput.selector,
                    exactParams[uniqueInputParam]
                );
            }
            if (sourceTokenAmountUsed < minSourceTokenAmount) {
                uint256 displace = _numberAdjustment(
                    sourceTokenAmountUsed,
                    minSourceTokenAmount
                );
                exactParams[0].amountIn += displace;
                sourceTokenAmountUsed = minSourceTokenAmount;
                encodedTXs[0] = abi.encodeWithSelector(
                    uniswapSwapRouter.exactInput.selector,
                    exactParams[0]
                );
            }
            if (sourceTokenAmountUsed > minSourceTokenAmount) {
                uint256 displace = _numberAdjustment(
                    sourceTokenAmountUsed,
                    minSourceTokenAmount
                );
                exactParams[0].amountIn = exactParams[0].amountIn.sub(displace);
                sourceTokenAmountUsed = minSourceTokenAmount; //does not need safe math as it cannot underflow
                encodedTXs[0] = abi.encodeWithSelector(
                    uniswapSwapRouter.exactInput.selector,
                    exactParams[0]
                );
            }
            uint256 balanceBefore = IERC20(destTokenAddress).balanceOf(
                receiverAddress
            );
            uniswapSwapRouter.multicall(encodedTXs);
            destTokenAmountReceived =
                IERC20(destTokenAddress).balanceOf(receiverAddress).sub(balanceBefore);
        }
    }

    function _toAddress(bytes memory _bytes, uint256 _start)
        internal
        pure
        returns (address)
    {

        require(_start + 20 >= _start, "toAddress_overflow");
        require(_bytes.length >= _start + 20, "toAddress_outOfBounds");
        address tempAddress;

        assembly {
            tempAddress := div(
                mload(add(add(_bytes, 0x20), _start)),
                0x1000000000000000000000000
            )
        }

        return tempAddress;
    }

    function _numberAdjustment(uint256 current, uint256 target)
        internal
        pure
        returns (uint256)
    {

        if (current > target) {
            return (current - target); //cannot overflow or underflow
        } else {
            return target - current;
        }
    }
}