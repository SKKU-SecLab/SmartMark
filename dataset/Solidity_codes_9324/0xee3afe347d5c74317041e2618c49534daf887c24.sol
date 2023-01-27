



pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;

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




pragma solidity ^0.8.0;


library SafeERC20 {

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

        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {

        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {


        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}




pragma solidity ^0.8.0;


library SafeMath {

    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {

        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        return a + b;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        return a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        return a * b;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {

        return a % b;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {

        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}




pragma solidity ^0.8.0;

library SignedSafeMath {

    function mul(int256 a, int256 b) internal pure returns (int256) {

        return a * b;
    }

    function div(int256 a, int256 b) internal pure returns (int256) {

        return a / b;
    }

    function sub(int256 a, int256 b) internal pure returns (int256) {

        return a - b;
    }

    function add(int256 a, int256 b) internal pure returns (int256) {

        return a + b;
    }
}




pragma solidity ^0.8.0;


library FixedPoint {

    using SafeMath for uint256;
    using SignedSafeMath for int256;

    uint256 private constant FP_SCALING_FACTOR = 10**18;

    struct Unsigned {
        uint256 rawValue;
    }

    function fromUnscaledUint(uint256 a) internal pure returns (Unsigned memory) {

        return Unsigned(a.mul(FP_SCALING_FACTOR));
    }

    function isEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue == fromUnscaledUint(b).rawValue;
    }

    function isEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue == b.rawValue;
    }

    function isGreaterThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue > b.rawValue;
    }

    function isGreaterThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue > fromUnscaledUint(b).rawValue;
    }

    function isGreaterThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue > b.rawValue;
    }

    function isGreaterThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue >= b.rawValue;
    }

    function isGreaterThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue >= fromUnscaledUint(b).rawValue;
    }

    function isGreaterThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue >= b.rawValue;
    }

    function isLessThan(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue < b.rawValue;
    }

    function isLessThan(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue < fromUnscaledUint(b).rawValue;
    }

    function isLessThan(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue < b.rawValue;
    }

    function isLessThanOrEqual(Unsigned memory a, Unsigned memory b) internal pure returns (bool) {

        return a.rawValue <= b.rawValue;
    }

    function isLessThanOrEqual(Unsigned memory a, uint256 b) internal pure returns (bool) {

        return a.rawValue <= fromUnscaledUint(b).rawValue;
    }

    function isLessThanOrEqual(uint256 a, Unsigned memory b) internal pure returns (bool) {

        return fromUnscaledUint(a).rawValue <= b.rawValue;
    }

    function min(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return a.rawValue < b.rawValue ? a : b;
    }

    function max(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return a.rawValue > b.rawValue ? a : b;
    }

    function add(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.add(b.rawValue));
    }

    function add(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return add(a, fromUnscaledUint(b));
    }

    function sub(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.sub(b.rawValue));
    }

    function sub(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return sub(a, fromUnscaledUint(b));
    }

    function sub(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return sub(fromUnscaledUint(a), b);
    }

    function mul(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b.rawValue) / FP_SCALING_FACTOR);
    }

    function mul(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b));
    }

    function mulCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        uint256 mulRaw = a.rawValue.mul(b.rawValue);
        uint256 mulFloor = mulRaw / FP_SCALING_FACTOR;
        uint256 mod = mulRaw.mod(FP_SCALING_FACTOR);
        if (mod != 0) {
            return Unsigned(mulFloor.add(1));
        } else {
            return Unsigned(mulFloor);
        }
    }

    function mulCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(b));
    }

    function div(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.mul(FP_SCALING_FACTOR).div(b.rawValue));
    }

    function div(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return Unsigned(a.rawValue.div(b));
    }

    function div(uint256 a, Unsigned memory b) internal pure returns (Unsigned memory) {

        return div(fromUnscaledUint(a), b);
    }

    function divCeil(Unsigned memory a, Unsigned memory b) internal pure returns (Unsigned memory) {

        uint256 aScaled = a.rawValue.mul(FP_SCALING_FACTOR);
        uint256 divFloor = aScaled.div(b.rawValue);
        uint256 mod = aScaled.mod(b.rawValue);
        if (mod != 0) {
            return Unsigned(divFloor.add(1));
        } else {
            return Unsigned(divFloor);
        }
    }

    function divCeil(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory) {

        return divCeil(a, fromUnscaledUint(b));
    }

    function pow(Unsigned memory a, uint256 b) internal pure returns (Unsigned memory output) {

        output = fromUnscaledUint(1);
        for (uint256 i = 0; i < b; i = i.add(1)) {
            output = mul(output, a);
        }
    }

    int256 private constant SFP_SCALING_FACTOR = 10**18;

    struct Signed {
        int256 rawValue;
    }

    function fromSigned(Signed memory a) internal pure returns (Unsigned memory) {

        require(a.rawValue >= 0, "Negative value provided");
        return Unsigned(uint256(a.rawValue));
    }

    function fromUnsigned(Unsigned memory a) internal pure returns (Signed memory) {

        require(a.rawValue <= uint256(type(int256).max), "Unsigned too large");
        return Signed(int256(a.rawValue));
    }

    function fromUnscaledInt(int256 a) internal pure returns (Signed memory) {

        return Signed(a.mul(SFP_SCALING_FACTOR));
    }

    function isEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue == fromUnscaledInt(b).rawValue;
    }

    function isEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue == b.rawValue;
    }

    function isGreaterThan(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue > b.rawValue;
    }

    function isGreaterThan(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue > fromUnscaledInt(b).rawValue;
    }

    function isGreaterThan(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue > b.rawValue;
    }

    function isGreaterThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue >= b.rawValue;
    }

    function isGreaterThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue >= fromUnscaledInt(b).rawValue;
    }

    function isGreaterThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue >= b.rawValue;
    }

    function isLessThan(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue < b.rawValue;
    }

    function isLessThan(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue < fromUnscaledInt(b).rawValue;
    }

    function isLessThan(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue < b.rawValue;
    }

    function isLessThanOrEqual(Signed memory a, Signed memory b) internal pure returns (bool) {

        return a.rawValue <= b.rawValue;
    }

    function isLessThanOrEqual(Signed memory a, int256 b) internal pure returns (bool) {

        return a.rawValue <= fromUnscaledInt(b).rawValue;
    }

    function isLessThanOrEqual(int256 a, Signed memory b) internal pure returns (bool) {

        return fromUnscaledInt(a).rawValue <= b.rawValue;
    }

    function min(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return a.rawValue < b.rawValue ? a : b;
    }

    function max(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return a.rawValue > b.rawValue ? a : b;
    }

    function add(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.add(b.rawValue));
    }

    function add(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return add(a, fromUnscaledInt(b));
    }

    function sub(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.sub(b.rawValue));
    }

    function sub(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return sub(a, fromUnscaledInt(b));
    }

    function sub(int256 a, Signed memory b) internal pure returns (Signed memory) {

        return sub(fromUnscaledInt(a), b);
    }

    function mul(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b.rawValue) / SFP_SCALING_FACTOR);
    }

    function mul(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b));
    }

    function mulAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        int256 mulRaw = a.rawValue.mul(b.rawValue);
        int256 mulTowardsZero = mulRaw / SFP_SCALING_FACTOR;
        int256 mod = mulRaw % SFP_SCALING_FACTOR;
        if (mod != 0) {
            bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
            int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
            return Signed(mulTowardsZero.add(valueToAdd));
        } else {
            return Signed(mulTowardsZero);
        }
    }

    function mulAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(b));
    }

    function div(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.mul(SFP_SCALING_FACTOR).div(b.rawValue));
    }

    function div(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return Signed(a.rawValue.div(b));
    }

    function div(int256 a, Signed memory b) internal pure returns (Signed memory) {

        return div(fromUnscaledInt(a), b);
    }

    function divAwayFromZero(Signed memory a, Signed memory b) internal pure returns (Signed memory) {

        int256 aScaled = a.rawValue.mul(SFP_SCALING_FACTOR);
        int256 divTowardsZero = aScaled.div(b.rawValue);
        int256 mod = aScaled % b.rawValue;
        if (mod != 0) {
            bool isResultPositive = isLessThan(a, 0) == isLessThan(b, 0);
            int256 valueToAdd = isResultPositive ? int256(1) : int256(-1);
            return Signed(divTowardsZero.add(valueToAdd));
        } else {
            return Signed(divTowardsZero);
        }
    }

    function divAwayFromZero(Signed memory a, int256 b) internal pure returns (Signed memory) {

        return divAwayFromZero(a, fromUnscaledInt(b));
    }

    function pow(Signed memory a, uint256 b) internal pure returns (Signed memory output) {

        output = fromUnscaledInt(1);
        for (uint256 i = 0; i < b; i = i.add(1)) {
            output = mul(output, a);
        }
    }
}




pragma solidity ^0.8.0;


interface StoreInterface {

    function payOracleFees() external payable;


    function payOracleFeesErc20(address erc20Address, FixedPoint.Unsigned calldata amount) external;


    function computeRegularFee(
        uint256 startTime,
        uint256 endTime,
        FixedPoint.Unsigned calldata pfc
    ) external view returns (FixedPoint.Unsigned memory regularFee, FixedPoint.Unsigned memory latePenalty);


    function computeFinalFee(address currency) external view returns (FixedPoint.Unsigned memory);

}




pragma solidity ^0.8.0;

abstract contract OracleAncillaryInterface {

    function requestPrice(
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) public virtual;

    function hasPrice(
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) public view virtual returns (bool);


    function getPrice(
        bytes32 identifier,
        uint256 time,
        bytes memory ancillaryData
    ) public view virtual returns (int256);
}




pragma solidity ^0.8.0;

abstract contract OptimisticOracleInterface {
    enum State {
        Invalid, // Never requested.
        Requested, // Requested, no other actions taken.
        Proposed, // Proposed, but not expired or disputed yet.
        Expired, // Proposed, not disputed, past liveness.
        Disputed, // Disputed, but no DVM price returned yet.
        Resolved, // Disputed and DVM price is available.
        Settled // Final price has been set in the contract (can get here from Expired or Resolved).
    }

    struct Request {
        address proposer; // Address of the proposer.
        address disputer; // Address of the disputer.
        IERC20 currency; // ERC20 token used to pay rewards and fees.
        bool settled; // True if the request is settled.
        bool refundOnDispute; // True if the requester should be refunded their reward on dispute.
        int256 proposedPrice; // Price that the proposer submitted.
        int256 resolvedPrice; // Price resolved once the request is settled.
        uint256 expirationTime; // Time at which the request auto-settles without a dispute.
        uint256 reward; // Amount of the currency to pay to the proposer on settlement.
        uint256 finalFee; // Final fee to pay to the Store upon request to the DVM.
        uint256 bond; // Bond that the proposer and disputer must pay on top of the final fee.
        uint256 customLiveness; // Custom liveness value set by the requester.
    }

    uint256 public constant ancillaryBytesLimit = 8192;

    function requestPrice(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward
    ) external virtual returns (uint256 totalBond);

    function setBond(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        uint256 bond
    ) external virtual returns (uint256 totalBond);

    function setRefundOnDispute(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external virtual;

    function setCustomLiveness(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        uint256 customLiveness
    ) external virtual;

    function proposePriceFor(
        address proposer,
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        int256 proposedPrice
    ) public virtual returns (uint256 totalBond);

    function proposePrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData,
        int256 proposedPrice
    ) external virtual returns (uint256 totalBond);

    function disputePriceFor(
        address disputer,
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) public virtual returns (uint256 totalBond);

    function disputePrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external virtual returns (uint256 totalBond);

    function settleAndGetPrice(
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external virtual returns (int256);

    function settle(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) external virtual returns (uint256 payout);

    function getRequest(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) public view virtual returns (Request memory);

    function getState(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) public view virtual returns (State);

    function hasPrice(
        address requester,
        bytes32 identifier,
        uint256 timestamp,
        bytes memory ancillaryData
    ) public view virtual returns (bool);

    function stampAncillaryData(bytes memory ancillaryData, address requester)
        public
        view
        virtual
        returns (bytes memory);
}




pragma solidity ^0.8.0;


abstract contract SkinnyOptimisticOracleInterface {
    struct Request {
        address proposer; // Address of the proposer.
        address disputer; // Address of the disputer.
        IERC20 currency; // ERC20 token used to pay rewards and fees.
        bool settled; // True if the request is settled.
        int256 proposedPrice; // Price that the proposer submitted.
        int256 resolvedPrice; // Price resolved once the request is settled.
        uint256 expirationTime; // Time at which the request auto-settles without a dispute.
        uint256 reward; // Amount of the currency to pay to the proposer on settlement.
        uint256 finalFee; // Final fee to pay to the Store upon request to the DVM.
        uint256 bond; // Bond that the proposer and disputer must pay on top of the final fee.
        uint256 customLiveness; // Custom liveness value set by the requester.
    }

    uint256 public constant ancillaryBytesLimit = 8192;

    function requestPrice(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward,
        uint256 bond,
        uint256 customLiveness
    ) external virtual returns (uint256 totalBond);

    function proposePriceFor(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        address proposer,
        int256 proposedPrice
    ) public virtual returns (uint256 totalBond);

    function proposePrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        int256 proposedPrice
    ) external virtual returns (uint256 totalBond);

    function requestAndProposePriceFor(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward,
        uint256 bond,
        uint256 customLiveness,
        address proposer,
        int256 proposedPrice
    ) external virtual returns (uint256 totalBond);

    function disputePriceFor(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        address disputer,
        address requester
    ) public virtual returns (uint256 totalBond);

    function disputePrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external virtual returns (uint256 totalBond);

    function settle(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external virtual returns (uint256 payout, int256 resolvedPrice);

    function getState(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external virtual returns (OptimisticOracleInterface.State);

    function hasPrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) public virtual returns (bool);

    function stampAncillaryData(bytes memory ancillaryData, address requester)
        public
        pure
        virtual
        returns (bytes memory);
}




pragma solidity ^0.8.0;

interface FinderInterface {

    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress) external;


    function getImplementationAddress(bytes32 interfaceName) external view returns (address);

}




pragma solidity ^0.8.0;

interface IdentifierWhitelistInterface {

    function addSupportedIdentifier(bytes32 identifier) external;


    function removeSupportedIdentifier(bytes32 identifier) external;


    function isIdentifierSupported(bytes32 identifier) external view returns (bool);

}




pragma solidity ^0.8.0;

library OracleInterfaces {

    bytes32 public constant Oracle = "Oracle";
    bytes32 public constant IdentifierWhitelist = "IdentifierWhitelist";
    bytes32 public constant Store = "Store";
    bytes32 public constant FinancialContractsAdmin = "FinancialContractsAdmin";
    bytes32 public constant Registry = "Registry";
    bytes32 public constant CollateralWhitelist = "CollateralWhitelist";
    bytes32 public constant OptimisticOracle = "OptimisticOracle";
    bytes32 public constant Bridge = "Bridge";
    bytes32 public constant GenericHandler = "GenericHandler";
    bytes32 public constant SkinnyOptimisticOracle = "SkinnyOptimisticOracle";
}




pragma solidity ^0.8.0;

contract Timer {

    uint256 private currentTime;

    constructor() {
        currentTime = block.timestamp; // solhint-disable-line not-rely-on-time
    }

    function setCurrentTime(uint256 time) external {

        currentTime = time;
    }

    function getCurrentTime() public view returns (uint256) {

        return currentTime;
    }
}




pragma solidity ^0.8.0;

abstract contract Testable {
    address public timerAddress;

    constructor(address _timerAddress) {
        timerAddress = _timerAddress;
    }

    modifier onlyIfTest {
        require(timerAddress != address(0x0));
        _;
    }

    function setCurrentTime(uint256 time) external onlyIfTest {
        Timer(timerAddress).setCurrentTime(time);
    }

    function getCurrentTime() public view virtual returns (uint256) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return block.timestamp; // solhint-disable-line not-rely-on-time
        }
    }
}




pragma solidity ^0.8.0;

contract Lockable {

    bool private _notEntered;

    constructor() {
        _notEntered = true;
    }

    modifier nonReentrant() {

        _preEntranceCheck();
        _preEntranceSet();
        _;
        _postEntranceReset();
    }

    modifier nonReentrantView() {

        _preEntranceCheck();
        _;
    }

    function _preEntranceCheck() internal view {

        require(_notEntered, "ReentrancyGuard: reentrant call");
    }

    function _preEntranceSet() internal {

        _notEntered = false;
    }

    function _postEntranceReset() internal {

        _notEntered = true;
    }
}




pragma solidity ^0.8.0;

library AncillaryData {

    function toUtf8Bytes32Bottom(bytes32 bytesIn) private pure returns (bytes32) {

        unchecked {
            uint256 x = uint256(bytesIn);

            x = x & 0x00000000000000000000000000000000ffffffffffffffffffffffffffffffff;
            x = (x | (x * 2**64)) & 0x0000000000000000ffffffffffffffff0000000000000000ffffffffffffffff;
            x = (x | (x * 2**32)) & 0x00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff;
            x = (x | (x * 2**16)) & 0x0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff;
            x = (x | (x * 2**8)) & 0x00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff;
            x = (x | (x * 2**4)) & 0x0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f0f;

            uint256 h = (x & 0x0808080808080808080808080808080808080808080808080808080808080808) / 8;
            uint256 i = (x & 0x0404040404040404040404040404040404040404040404040404040404040404) / 4;
            uint256 j = (x & 0x0202020202020202020202020202020202020202020202020202020202020202) / 2;
            x = x + (h & (i | j)) * 0x27 + 0x3030303030303030303030303030303030303030303030303030303030303030;

            return bytes32(x);
        }
    }

    function toUtf8Bytes(bytes32 bytesIn) internal pure returns (bytes memory) {

        return abi.encodePacked(toUtf8Bytes32Bottom(bytesIn >> 128), toUtf8Bytes32Bottom(bytesIn));
    }

    function toUtf8BytesAddress(address x) internal pure returns (bytes memory) {

        return
            abi.encodePacked(toUtf8Bytes32Bottom(bytes32(bytes20(x)) >> 128), bytes8(toUtf8Bytes32Bottom(bytes20(x))));
    }

    function toUtf8BytesUint(uint256 x) internal pure returns (bytes memory) {

        if (x == 0) {
            return "0";
        }
        uint256 j = x;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (x != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(x - (x / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            x /= 10;
        }
        return bstr;
    }

    function appendKeyValueBytes32(
        bytes memory currentAncillaryData,
        bytes memory key,
        bytes32 value
    ) internal pure returns (bytes memory) {

        bytes memory prefix = constructPrefix(currentAncillaryData, key);
        return abi.encodePacked(currentAncillaryData, prefix, toUtf8Bytes(value));
    }

    function appendKeyValueAddress(
        bytes memory currentAncillaryData,
        bytes memory key,
        address value
    ) internal pure returns (bytes memory) {

        bytes memory prefix = constructPrefix(currentAncillaryData, key);
        return abi.encodePacked(currentAncillaryData, prefix, toUtf8BytesAddress(value));
    }

    function appendKeyValueUint(
        bytes memory currentAncillaryData,
        bytes memory key,
        uint256 value
    ) internal pure returns (bytes memory) {

        bytes memory prefix = constructPrefix(currentAncillaryData, key);
        return abi.encodePacked(currentAncillaryData, prefix, toUtf8BytesUint(value));
    }

    function constructPrefix(bytes memory currentAncillaryData, bytes memory key) internal pure returns (bytes memory) {

        if (currentAncillaryData.length > 0) {
            return abi.encodePacked(",", key, ":");
        } else {
            return abi.encodePacked(key, ":");
        }
    }
}




pragma solidity ^0.8.0;

interface AddressWhitelistInterface {

    function addToWhitelist(address newElement) external;


    function removeFromWhitelist(address newElement) external;


    function isOnWhitelist(address newElement) external view returns (bool);


    function getWhitelist() external view returns (address[] memory);

}




pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}




pragma solidity ^0.8.0;

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
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




pragma solidity ^0.8.0;



contract AddressWhitelist is AddressWhitelistInterface, Ownable, Lockable {

    enum Status { None, In, Out }
    mapping(address => Status) public whitelist;

    address[] public whitelistIndices;

    event AddedToWhitelist(address indexed addedAddress);
    event RemovedFromWhitelist(address indexed removedAddress);

    function addToWhitelist(address newElement) external override nonReentrant() onlyOwner {

        if (whitelist[newElement] == Status.In) {
            return;
        }

        if (whitelist[newElement] == Status.None) {
            whitelistIndices.push(newElement);
        }

        whitelist[newElement] = Status.In;

        emit AddedToWhitelist(newElement);
    }

    function removeFromWhitelist(address elementToRemove) external override nonReentrant() onlyOwner {

        if (whitelist[elementToRemove] != Status.Out) {
            whitelist[elementToRemove] = Status.Out;
            emit RemovedFromWhitelist(elementToRemove);
        }
    }

    function isOnWhitelist(address elementToCheck) external view override nonReentrantView() returns (bool) {

        return whitelist[elementToCheck] == Status.In;
    }

    function getWhitelist() external view override nonReentrantView() returns (address[] memory activeWhitelist) {

        uint256 activeCount = 0;
        for (uint256 i = 0; i < whitelistIndices.length; i++) {
            if (whitelist[whitelistIndices[i]] == Status.In) {
                activeCount++;
            }
        }

        activeWhitelist = new address[](activeCount);
        activeCount = 0;
        for (uint256 i = 0; i < whitelistIndices.length; i++) {
            address addr = whitelistIndices[i];
            if (whitelist[addr] == Status.In) {
                activeWhitelist[activeCount] = addr;
                activeCount++;
            }
        }
    }
}




pragma solidity ^0.8.0;














interface OptimisticRequester {

    function priceProposed(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        SkinnyOptimisticOracleInterface.Request memory request
    ) external;


    function priceDisputed(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        SkinnyOptimisticOracleInterface.Request memory request
    ) external;


    function priceSettled(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        SkinnyOptimisticOracleInterface.Request memory request
    ) external;

}

contract SkinnyOptimisticOracle is SkinnyOptimisticOracleInterface, Testable, Lockable {

    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    event RequestPrice(
        address indexed requester,
        bytes32 indexed identifier,
        uint32 timestamp,
        bytes ancillaryData,
        Request request
    );
    event ProposePrice(
        address indexed requester,
        bytes32 indexed identifier,
        uint32 timestamp,
        bytes ancillaryData,
        Request request
    );
    event DisputePrice(
        address indexed requester,
        bytes32 indexed identifier,
        uint32 timestamp,
        bytes ancillaryData,
        Request request
    );
    event Settle(
        address indexed requester,
        bytes32 indexed identifier,
        uint32 timestamp,
        bytes ancillaryData,
        Request request
    );

    mapping(bytes32 => bytes32) public requests;

    FinderInterface public finder;

    uint256 public defaultLiveness;

    constructor(
        uint256 _liveness,
        address _finderAddress,
        address _timerAddress
    ) Testable(_timerAddress) {
        finder = FinderInterface(_finderAddress);
        _validateLiveness(_liveness);
        defaultLiveness = _liveness;
    }

    function requestPrice(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward,
        uint256 bond,
        uint256 customLiveness
    ) external override nonReentrant() returns (uint256 totalBond) {

        bytes32 requestId = _getId(msg.sender, identifier, timestamp, ancillaryData);
        require(requests[requestId] == bytes32(0), "Request already initialized");
        require(_getIdentifierWhitelist().isIdentifierSupported(identifier), "Unsupported identifier");
        require(_getCollateralWhitelist().isOnWhitelist(address(currency)), "Unsupported currency");
        require(timestamp <= getCurrentTime(), "Timestamp in future");
        require(
            _stampAncillaryData(ancillaryData, msg.sender).length <= ancillaryBytesLimit,
            "Ancillary Data too long"
        );
        uint256 finalFee = _getStore().computeFinalFee(address(currency)).rawValue;

        Request memory request;
        request.currency = currency;
        request.reward = reward;
        request.finalFee = finalFee;
        request.bond = bond != 0 ? bond : finalFee;
        request.customLiveness = customLiveness;
        _storeRequestHash(requestId, request);

        if (reward > 0) currency.safeTransferFrom(msg.sender, address(this), reward);

        emit RequestPrice(msg.sender, identifier, timestamp, ancillaryData, request);

        return request.bond.add(finalFee);
    }

    function proposePriceFor(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        address proposer,
        int256 proposedPrice
    ) public override nonReentrant() returns (uint256 totalBond) {

        require(proposer != address(0), "Proposer address must be non 0");
        require(
            _getState(requester, identifier, timestamp, ancillaryData, request) ==
                OptimisticOracleInterface.State.Requested,
            "Must be requested"
        );
        bytes32 requestId = _getId(requester, identifier, timestamp, ancillaryData);
        _validateRequestHash(requestId, request);

        Request memory proposedRequest =
            Request({
                proposer: proposer, // Modified
                disputer: request.disputer,
                currency: request.currency,
                settled: request.settled,
                proposedPrice: proposedPrice, // Modified
                resolvedPrice: request.resolvedPrice,
                expirationTime: getCurrentTime().add(
                    request.customLiveness != 0 ? request.customLiveness : defaultLiveness
                ), // Modified
                reward: request.reward,
                finalFee: request.finalFee,
                bond: request.bond,
                customLiveness: request.customLiveness
            });
        _storeRequestHash(requestId, proposedRequest);

        totalBond = request.bond.add(request.finalFee);
        if (totalBond > 0) request.currency.safeTransferFrom(msg.sender, address(this), totalBond);

        emit ProposePrice(requester, identifier, timestamp, ancillaryData, proposedRequest);

        if (address(requester).isContract())
            try
                OptimisticRequester(requester).priceProposed(identifier, timestamp, ancillaryData, proposedRequest)
            {} catch {}
    }

    function proposePrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        int256 proposedPrice
    ) external override returns (uint256 totalBond) {

        return proposePriceFor(requester, identifier, timestamp, ancillaryData, request, msg.sender, proposedPrice);
    }

    function requestAndProposePriceFor(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        IERC20 currency,
        uint256 reward,
        uint256 bond,
        uint256 customLiveness,
        address proposer,
        int256 proposedPrice
    ) external override nonReentrant() returns (uint256 totalBond) {

        bytes32 requestId = _getId(msg.sender, identifier, timestamp, ancillaryData);
        require(requests[requestId] == bytes32(0), "Request already initialized");
        require(proposer != address(0), "proposer address must be non 0");
        require(_getIdentifierWhitelist().isIdentifierSupported(identifier), "Unsupported identifier");
        require(_getCollateralWhitelist().isOnWhitelist(address(currency)), "Unsupported currency");
        require(timestamp <= getCurrentTime(), "Timestamp in future");
        require(
            _stampAncillaryData(ancillaryData, msg.sender).length <= ancillaryBytesLimit,
            "Ancillary Data too long"
        );
        uint256 finalFee = _getStore().computeFinalFee(address(currency)).rawValue;

        Request memory request;
        request.currency = currency;
        request.reward = reward;
        request.finalFee = finalFee;
        request.bond = bond != 0 ? bond : finalFee;
        request.customLiveness = customLiveness;
        request.proposer = proposer;
        request.proposedPrice = proposedPrice;
        request.expirationTime = getCurrentTime().add(customLiveness != 0 ? customLiveness : defaultLiveness);
        _storeRequestHash(requestId, request);

        if (reward > 0) currency.safeTransferFrom(msg.sender, address(this), reward);
        totalBond = request.bond.add(request.finalFee);
        if (totalBond > 0) currency.safeTransferFrom(msg.sender, address(this), totalBond);

        emit RequestPrice(msg.sender, identifier, timestamp, ancillaryData, request);
        emit ProposePrice(msg.sender, identifier, timestamp, ancillaryData, request);

        if (address(msg.sender).isContract())
            try OptimisticRequester(msg.sender).priceProposed(identifier, timestamp, ancillaryData, request) {} catch {}
    }

    function disputePriceFor(
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request,
        address disputer,
        address requester
    ) public override nonReentrant() returns (uint256 totalBond) {

        require(disputer != address(0), "disputer address must be non 0");
        require(
            _getState(requester, identifier, timestamp, ancillaryData, request) ==
                OptimisticOracleInterface.State.Proposed,
            "Must be proposed"
        );
        bytes32 requestId = _getId(requester, identifier, timestamp, ancillaryData);
        _validateRequestHash(requestId, request);

        Request memory disputedRequest =
            Request({
                proposer: request.proposer,
                disputer: disputer, // Modified
                currency: request.currency,
                settled: request.settled,
                proposedPrice: request.proposedPrice,
                resolvedPrice: request.resolvedPrice,
                expirationTime: request.expirationTime,
                reward: request.reward,
                finalFee: request.finalFee,
                bond: request.bond,
                customLiveness: request.customLiveness
            });
        _storeRequestHash(requestId, disputedRequest);

        totalBond = request.bond.add(request.finalFee);
        if (totalBond > 0) request.currency.safeTransferFrom(msg.sender, address(this), totalBond);

        StoreInterface store = _getStore();

        {
            uint256 burnedBond = _computeBurnedBond(disputedRequest);

            uint256 totalFee = request.finalFee.add(burnedBond);

            if (totalFee > 0) {
                request.currency.safeIncreaseAllowance(address(store), totalFee);
                _getStore().payOracleFeesErc20(address(request.currency), FixedPoint.Unsigned(totalFee));
            }
        }

        _getOracle().requestPrice(identifier, timestamp, _stampAncillaryData(ancillaryData, requester));

        emit DisputePrice(requester, identifier, timestamp, ancillaryData, disputedRequest);

        if (address(requester).isContract())
            try
                OptimisticRequester(requester).priceDisputed(identifier, timestamp, ancillaryData, disputedRequest)
            {} catch {}
    }

    function disputePrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external override returns (uint256 totalBond) {

        return disputePriceFor(identifier, timestamp, ancillaryData, request, msg.sender, requester);
    }

    function settle(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external override nonReentrant() returns (uint256 payout, int256 resolvedPrice) {

        return _settle(requester, identifier, timestamp, ancillaryData, request);
    }

    function getState(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) external override nonReentrant() returns (OptimisticOracleInterface.State) {

        return _getState(requester, identifier, timestamp, ancillaryData, request);
    }

    function hasPrice(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) public override nonReentrant() returns (bool) {

        bytes32 requestId = _getId(requester, identifier, timestamp, ancillaryData);
        _validateRequestHash(requestId, request);
        OptimisticOracleInterface.State state = _getState(requester, identifier, timestamp, ancillaryData, request);
        return
            state == OptimisticOracleInterface.State.Settled ||
            state == OptimisticOracleInterface.State.Resolved ||
            state == OptimisticOracleInterface.State.Expired;
    }

    function stampAncillaryData(bytes memory ancillaryData, address requester)
        public
        pure
        override
        returns (bytes memory)
    {

        return _stampAncillaryData(ancillaryData, requester);
    }

    function _getId(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData
    ) private pure returns (bytes32) {

        return keccak256(abi.encode(requester, identifier, timestamp, ancillaryData));
    }

    function _getRequestHash(Request memory request) private pure returns (bytes32) {

        return keccak256(abi.encode(request));
    }

    function _settle(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) private returns (uint256 payout, int256 resolvedPrice) {

        bytes32 requestId = _getId(requester, identifier, timestamp, ancillaryData);
        _validateRequestHash(requestId, request);

        Request memory settledRequest =
            Request({
                proposer: request.proposer,
                disputer: request.disputer,
                currency: request.currency,
                settled: true, // Modified
                proposedPrice: request.proposedPrice,
                resolvedPrice: request.resolvedPrice,
                expirationTime: request.expirationTime,
                reward: request.reward,
                finalFee: request.finalFee,
                bond: request.bond,
                customLiveness: request.customLiveness
            });

        OptimisticOracleInterface.State state = _getState(requester, identifier, timestamp, ancillaryData, request);
        if (state == OptimisticOracleInterface.State.Expired) {
            resolvedPrice = request.proposedPrice;
            settledRequest.resolvedPrice = resolvedPrice;
            payout = request.bond.add(request.finalFee).add(request.reward);
            request.currency.safeTransfer(request.proposer, payout);
        } else if (state == OptimisticOracleInterface.State.Resolved) {
            resolvedPrice = _getOracle().getPrice(identifier, timestamp, _stampAncillaryData(ancillaryData, requester));
            settledRequest.resolvedPrice = resolvedPrice;
            bool disputeSuccess = settledRequest.resolvedPrice != request.proposedPrice;

            payout = request.bond.add(request.bond.sub(_computeBurnedBond(settledRequest))).add(request.finalFee).add(
                request.reward
            );
            request.currency.safeTransfer(disputeSuccess ? request.disputer : request.proposer, payout);
        } else {
            revert("Already settled or not settleable");
        }

        _storeRequestHash(requestId, settledRequest);
        emit Settle(requester, identifier, timestamp, ancillaryData, settledRequest);

        if (address(requester).isContract())
            try
                OptimisticRequester(requester).priceSettled(identifier, timestamp, ancillaryData, settledRequest)
            {} catch {}
    }

    function _computeBurnedBond(Request memory request) private pure returns (uint256) {

        return request.bond.div(2);
    }

    function _validateLiveness(uint256 liveness) private pure {

        require(liveness < 5200 weeks, "Liveness too large");
        require(liveness > 0, "Liveness cannot be 0");
    }

    function _validateRequestHash(bytes32 requestId, Request memory request) private view {

        require(
            requests[requestId] == _getRequestHash(request),
            "Hashed request params do not match existing request hash"
        );
    }

    function _storeRequestHash(bytes32 requestId, Request memory request) internal {

        requests[requestId] = _getRequestHash(request);
    }

    function _getState(
        address requester,
        bytes32 identifier,
        uint32 timestamp,
        bytes memory ancillaryData,
        Request memory request
    ) internal view returns (OptimisticOracleInterface.State) {

        if (address(request.currency) == address(0)) return OptimisticOracleInterface.State.Invalid;

        if (request.proposer == address(0)) return OptimisticOracleInterface.State.Requested;

        if (request.settled) return OptimisticOracleInterface.State.Settled;

        if (request.disputer == address(0))
            return
                request.expirationTime <= getCurrentTime()
                    ? OptimisticOracleInterface.State.Expired
                    : OptimisticOracleInterface.State.Proposed;

        return
            _getOracle().hasPrice(identifier, timestamp, _stampAncillaryData(ancillaryData, requester))
                ? OptimisticOracleInterface.State.Resolved
                : OptimisticOracleInterface.State.Disputed;
    }

    function _getOracle() internal view returns (OracleAncillaryInterface) {

        return OracleAncillaryInterface(finder.getImplementationAddress(OracleInterfaces.Oracle));
    }

    function _getCollateralWhitelist() internal view returns (AddressWhitelist) {

        return AddressWhitelist(finder.getImplementationAddress(OracleInterfaces.CollateralWhitelist));
    }

    function _getStore() internal view returns (StoreInterface) {

        return StoreInterface(finder.getImplementationAddress(OracleInterfaces.Store));
    }

    function _getIdentifierWhitelist() internal view returns (IdentifierWhitelistInterface) {

        return IdentifierWhitelistInterface(finder.getImplementationAddress(OracleInterfaces.IdentifierWhitelist));
    }

    function _stampAncillaryData(bytes memory ancillaryData, address requester) internal pure returns (bytes memory) {

        return AncillaryData.appendKeyValueAddress(ancillaryData, "ooRequester", requester);
    }
}

contract SkinnyOptimisticOracleProd is SkinnyOptimisticOracle {

    constructor(
        uint256 _liveness,
        address _finderAddress,
        address _timerAddress
    ) SkinnyOptimisticOracle(_liveness, _finderAddress, _timerAddress) {}

    function getCurrentTime() public view virtual override returns (uint256) {

        return block.timestamp;
    }
}