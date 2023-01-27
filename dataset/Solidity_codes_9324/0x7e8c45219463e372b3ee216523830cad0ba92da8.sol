
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
}// MIT

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
}// MIT

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
}// MIT

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
}// MIT

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
}// AGPL-3.0-only
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
}// AGPL-3.0-only
pragma solidity ^0.8.0;


abstract contract ExpandedIERC20 is IERC20 {
    function burn(uint256 value) external virtual;

    function mint(address to, uint256 value) external virtual returns (bool);

    function addMinter(address account) external virtual;

    function addBurner(address account) external virtual;

    function resetOwner(address account) external virtual;
}// AGPL-3.0-only
pragma solidity ^0.8.0;


interface IERC20Standard is IERC20 {

    function decimals() external view returns (uint8);

}// AGPL-3.0-only
pragma solidity ^0.8.0;

abstract contract OracleInterface {
    function requestPrice(bytes32 identifier, uint256 time) public virtual;

    function hasPrice(bytes32 identifier, uint256 time) public view virtual returns (bool);

    function getPrice(bytes32 identifier, uint256 time) public view virtual returns (int256);
}// AGPL-3.0-only
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
}// AGPL-3.0-only
pragma solidity ^0.8.0;

interface IdentifierWhitelistInterface {

    function addSupportedIdentifier(bytes32 identifier) external;


    function removeSupportedIdentifier(bytes32 identifier) external;


    function isIdentifierSupported(bytes32 identifier) external view returns (bool);

}// AGPL-3.0-only
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
}// AGPL-3.0-only
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
}// AGPL-3.0-only
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
}// AGPL-3.0-only
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

    function getCurrentTime() public view returns (uint256) {
        if (timerAddress != address(0x0)) {
            return Timer(timerAddress).getCurrentTime();
        } else {
            return block.timestamp; // solhint-disable-line not-rely-on-time
        }
    }
}// AGPL-3.0-only
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

}// AGPL-3.0-only
pragma solidity ^0.8.0;

interface FinderInterface {

    function changeImplementationAddress(bytes32 interfaceName, address implementationAddress) external;


    function getImplementationAddress(bytes32 interfaceName) external view returns (address);

}// AGPL-3.0-only
pragma solidity ^0.8.0;


interface AdministrateeInterface {

    function emergencyShutdown() external;


    function remargin() external;


    function pfc() external view returns (FixedPoint.Unsigned memory);

}// AGPL-3.0-only
pragma solidity ^0.8.0;





abstract contract FeePayer is AdministrateeInterface, Testable, Lockable {
    using SafeMath for uint256;
    using FixedPoint for FixedPoint.Unsigned;
    using SafeERC20 for IERC20;


    IERC20 public collateralCurrency;

    FinderInterface public finder;

    uint256 private lastPaymentTime;

    FixedPoint.Unsigned public cumulativeFeeMultiplier;


    event RegularFeesPaid(uint256 indexed regularFee, uint256 indexed lateFee);
    event FinalFeesPaid(uint256 indexed amount);


    modifier fees virtual {
        payRegularFees();
        _;
    }

    constructor(
        address _collateralAddress,
        address _finderAddress,
        address _timerAddress
    ) Testable(_timerAddress) {
        collateralCurrency = IERC20(_collateralAddress);
        finder = FinderInterface(_finderAddress);
        lastPaymentTime = getCurrentTime();
        cumulativeFeeMultiplier = FixedPoint.fromUnscaledUint(1);
    }


    function payRegularFees() public nonReentrant() returns (FixedPoint.Unsigned memory) {
        uint256 time = getCurrentTime();
        FixedPoint.Unsigned memory collateralPool = _pfc();

        (
            FixedPoint.Unsigned memory regularFee,
            FixedPoint.Unsigned memory latePenalty,
            FixedPoint.Unsigned memory totalPaid
        ) = getOutstandingRegularFees(time);
        lastPaymentTime = time;

        if (totalPaid.isEqual(0)) {
            return totalPaid;
        }

        emit RegularFeesPaid(regularFee.rawValue, latePenalty.rawValue);

        _adjustCumulativeFeeMultiplier(totalPaid, collateralPool);

        if (regularFee.isGreaterThan(0)) {
            StoreInterface store = _getStore();
            collateralCurrency.safeIncreaseAllowance(address(store), regularFee.rawValue);
            store.payOracleFeesErc20(address(collateralCurrency), regularFee);
        }

        if (latePenalty.isGreaterThan(0)) {
            collateralCurrency.safeTransfer(msg.sender, latePenalty.rawValue);
        }
        return totalPaid;
    }

    function getOutstandingRegularFees(uint256 time)
        public
        view
        returns (
            FixedPoint.Unsigned memory regularFee,
            FixedPoint.Unsigned memory latePenalty,
            FixedPoint.Unsigned memory totalPaid
        )
    {
        StoreInterface store = _getStore();
        FixedPoint.Unsigned memory collateralPool = _pfc();

        if (collateralPool.isEqual(0) || lastPaymentTime == time) {
            return (regularFee, latePenalty, totalPaid);
        }

        (regularFee, latePenalty) = store.computeRegularFee(lastPaymentTime, time, collateralPool);

        totalPaid = regularFee.add(latePenalty);
        if (totalPaid.isEqual(0)) {
            return (regularFee, latePenalty, totalPaid);
        }
        if (totalPaid.isGreaterThan(collateralPool)) {
            FixedPoint.Unsigned memory deficit = totalPaid.sub(collateralPool);
            FixedPoint.Unsigned memory latePenaltyReduction = FixedPoint.min(latePenalty, deficit);
            latePenalty = latePenalty.sub(latePenaltyReduction);
            deficit = deficit.sub(latePenaltyReduction);
            regularFee = regularFee.sub(FixedPoint.min(regularFee, deficit));
            totalPaid = collateralPool;
        }
    }

    function pfc() external view override nonReentrantView() returns (FixedPoint.Unsigned memory) {
        return _pfc();
    }

    function gulp() external nonReentrant() {
        _gulp();
    }


    function _payFinalFees(address payer, FixedPoint.Unsigned memory amount) internal {
        if (amount.isEqual(0)) {
            return;
        }

        if (payer != address(this)) {
            collateralCurrency.safeTransferFrom(payer, address(this), amount.rawValue);
        } else {
            FixedPoint.Unsigned memory collateralPool = _pfc();

            require(collateralPool.isGreaterThan(amount));

            _adjustCumulativeFeeMultiplier(amount, collateralPool);
        }

        emit FinalFeesPaid(amount.rawValue);

        StoreInterface store = _getStore();
        collateralCurrency.safeIncreaseAllowance(address(store), amount.rawValue);
        store.payOracleFeesErc20(address(collateralCurrency), amount);
    }

    function _gulp() internal {
        FixedPoint.Unsigned memory currentPfc = _pfc();
        FixedPoint.Unsigned memory currentBalance = FixedPoint.Unsigned(collateralCurrency.balanceOf(address(this)));
        if (currentPfc.isLessThan(currentBalance)) {
            cumulativeFeeMultiplier = cumulativeFeeMultiplier.mul(currentBalance.div(currentPfc));
        }
    }

    function _pfc() internal view virtual returns (FixedPoint.Unsigned memory);

    function _getStore() internal view returns (StoreInterface) {
        return StoreInterface(finder.getImplementationAddress(OracleInterfaces.Store));
    }

    function _computeFinalFees() internal view returns (FixedPoint.Unsigned memory finalFees) {
        StoreInterface store = _getStore();
        return store.computeFinalFee(address(collateralCurrency));
    }

    function _getFeeAdjustedCollateral(FixedPoint.Unsigned memory rawCollateral)
        internal
        view
        returns (FixedPoint.Unsigned memory collateral)
    {
        return rawCollateral.mul(cumulativeFeeMultiplier);
    }

    function _getPendingRegularFeeAdjustedCollateral(FixedPoint.Unsigned memory rawCollateral)
        internal
        view
        returns (FixedPoint.Unsigned memory)
    {
        (, , FixedPoint.Unsigned memory currentTotalOutstandingRegularFees) =
            getOutstandingRegularFees(getCurrentTime());
        if (currentTotalOutstandingRegularFees.isEqual(FixedPoint.fromUnscaledUint(0))) return rawCollateral;

        FixedPoint.Unsigned memory effectiveOutstandingFee = currentTotalOutstandingRegularFees.divCeil(_pfc());

        return rawCollateral.mul(FixedPoint.fromUnscaledUint(1).sub(effectiveOutstandingFee));
    }

    function _convertToRawCollateral(FixedPoint.Unsigned memory collateral)
        internal
        view
        returns (FixedPoint.Unsigned memory rawCollateral)
    {
        return collateral.div(cumulativeFeeMultiplier);
    }

    function _removeCollateral(FixedPoint.Unsigned storage rawCollateral, FixedPoint.Unsigned memory collateralToRemove)
        internal
        returns (FixedPoint.Unsigned memory removedCollateral)
    {
        FixedPoint.Unsigned memory initialBalance = _getFeeAdjustedCollateral(rawCollateral);
        FixedPoint.Unsigned memory adjustedCollateral = _convertToRawCollateral(collateralToRemove);
        rawCollateral.rawValue = rawCollateral.sub(adjustedCollateral).rawValue;
        removedCollateral = initialBalance.sub(_getFeeAdjustedCollateral(rawCollateral));
    }

    function _addCollateral(FixedPoint.Unsigned storage rawCollateral, FixedPoint.Unsigned memory collateralToAdd)
        internal
        returns (FixedPoint.Unsigned memory addedCollateral)
    {
        FixedPoint.Unsigned memory initialBalance = _getFeeAdjustedCollateral(rawCollateral);
        FixedPoint.Unsigned memory adjustedCollateral = _convertToRawCollateral(collateralToAdd);
        rawCollateral.rawValue = rawCollateral.add(adjustedCollateral).rawValue;
        addedCollateral = _getFeeAdjustedCollateral(rawCollateral).sub(initialBalance);
    }

    function _adjustCumulativeFeeMultiplier(FixedPoint.Unsigned memory amount, FixedPoint.Unsigned memory currentPfc)
        internal
    {
        FixedPoint.Unsigned memory effectiveFee = amount.divCeil(currentPfc);
        cumulativeFeeMultiplier = cumulativeFeeMultiplier.mul(FixedPoint.fromUnscaledUint(1).sub(effectiveFee));
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;

interface ExpiringContractInterface {

    function expirationTimestamp() external view returns (uint256);

}

abstract contract FinancialProductLibrary {
    using FixedPoint for FixedPoint.Unsigned;

    function transformPrice(FixedPoint.Unsigned memory oraclePrice, uint256 requestTime)
        public
        view
        virtual
        returns (FixedPoint.Unsigned memory)
    {
        return oraclePrice;
    }

    function transformCollateralRequirement(
        FixedPoint.Unsigned memory oraclePrice,
        FixedPoint.Unsigned memory collateralRequirement
    ) public view virtual returns (FixedPoint.Unsigned memory) {
        return collateralRequirement;
    }

    function transformPriceIdentifier(bytes32 priceIdentifier, uint256 requestTime)
        public
        view
        virtual
        returns (bytes32)
    {
        return priceIdentifier;
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;
pragma abicoder v2;






contract PricelessPositionManager is FeePayer {

    using SafeMath for uint256;
    using FixedPoint for FixedPoint.Unsigned;
    using SafeERC20 for IERC20;
    using SafeERC20 for ExpandedIERC20;
    using Address for address;


    enum ContractState { Open, ExpiredPriceRequested, ExpiredPriceReceived }
    ContractState public contractState;

    struct PositionData {
        FixedPoint.Unsigned tokensOutstanding;
        uint256 withdrawalRequestPassTimestamp;
        FixedPoint.Unsigned withdrawalRequestAmount;
        FixedPoint.Unsigned rawCollateral;
        uint256 transferPositionRequestPassTimestamp;
    }

    mapping(address => PositionData) public positions;

    FixedPoint.Unsigned public totalTokensOutstanding;

    FixedPoint.Unsigned public rawTotalPositionCollateral;

    ExpandedIERC20 public tokenCurrency;

    bytes32 public priceIdentifier;
    uint256 public expirationTimestamp;
    uint256 public updateTimestamp;
    uint256 public withdrawalLiveness;

    FixedPoint.Unsigned public minSponsorTokens;

    FixedPoint.Unsigned public expiryPrice;

    FinancialProductLibrary public financialProductLibrary;

    address externalVariableExpirationDAOAddress;


    event RequestTransferPosition(address indexed oldSponsor);
    event RequestTransferPositionExecuted(address indexed oldSponsor, address indexed newSponsor);
    event RequestTransferPositionCanceled(address indexed oldSponsor);
    event Deposit(address indexed sponsor, uint256 indexed collateralAmount);
    event Withdrawal(address indexed sponsor, uint256 indexed collateralAmount);
    event RequestWithdrawal(address indexed sponsor, uint256 indexed collateralAmount);
    event RequestWithdrawalExecuted(address indexed sponsor, uint256 indexed collateralAmount);
    event RequestWithdrawalCanceled(address indexed sponsor, uint256 indexed collateralAmount);
    event PositionCreated(address indexed sponsor, uint256 indexed collateralAmount, uint256 indexed tokenAmount);
    event NewSponsor(address indexed sponsor);
    event EndedSponsorPosition(address indexed sponsor);
    event Repay(address indexed sponsor, uint256 indexed numTokensRepaid, uint256 indexed newTokenCount);
    event Redeem(address indexed sponsor, uint256 indexed collateralAmount, uint256 indexed tokenAmount);
    event ContractExpired(address indexed caller);
    event SettleExpiredPosition(
        address indexed caller,
        uint256 indexed collateralReturned,
        uint256 indexed tokensBurned
    );
    event EmergencyShutdown(address indexed caller, uint256 originalExpirationTimestamp, uint256 shutdownTimestamp);
    event VariableExpiration(address indexed caller, uint256 originalExpirationTimestamp, uint256 shutdownTimestamp);
    event UpdateDAOAddress(address indexed previousAddress, address indexed newAddress, uint256 updateTimestamp);


    modifier onlyPreExpiration() {

        _onlyPreExpiration();
        _;
    }

    modifier onlyPostExpiration() {

        _onlyPostExpiration();
        _;
    }

    modifier onlyCollateralizedPosition(address sponsor) {

        _onlyCollateralizedPosition(sponsor);
        _;
    }

    modifier onlyOpenState() {

        _onlyOpenState();
        _;
    }

    modifier noPendingWithdrawal(address sponsor) {

        _positionHasNoPendingWithdrawal(sponsor);
        _;
    }

    constructor(
        uint256 _expirationTimestamp,
        uint256 _withdrawalLiveness,
        address _collateralAddress,
        address _tokenAddress,
        address _finderAddress,
        bytes32 _priceIdentifier,
        FixedPoint.Unsigned memory _minSponsorTokens,
        address _timerAddress,
        address _financialProductLibraryAddress,
        address _externalVariableExpirationDAOAddress
    ) FeePayer(_collateralAddress, _finderAddress, _timerAddress) nonReentrant() {
        require(_expirationTimestamp > getCurrentTime());
        require(_getIdentifierWhitelist().isIdentifierSupported(_priceIdentifier));

        expirationTimestamp = _expirationTimestamp;
        withdrawalLiveness = _withdrawalLiveness;
        tokenCurrency = ExpandedIERC20(_tokenAddress);
        minSponsorTokens = _minSponsorTokens;
        priceIdentifier = _priceIdentifier;
        externalVariableExpirationDAOAddress = _externalVariableExpirationDAOAddress;

        financialProductLibrary = FinancialProductLibrary(_financialProductLibraryAddress);
    }


    function requestTransferPosition() public onlyPreExpiration() nonReentrant() {

        PositionData storage positionData = _getPositionData(msg.sender);
        require(positionData.transferPositionRequestPassTimestamp == 0);

        uint256 requestPassTime = getCurrentTime().add(withdrawalLiveness);
        require(requestPassTime < expirationTimestamp);

        positionData.transferPositionRequestPassTimestamp = requestPassTime;

        emit RequestTransferPosition(msg.sender);
    }

    function transferPositionPassedRequest(address newSponsorAddress)
        public
        onlyPreExpiration()
        noPendingWithdrawal(msg.sender)
        nonReentrant()
    {

        require(
            _getFeeAdjustedCollateral(positions[newSponsorAddress].rawCollateral).isEqual(
                FixedPoint.fromUnscaledUint(0)
            )
        );
        PositionData storage positionData = _getPositionData(msg.sender);
        require(
            positionData.transferPositionRequestPassTimestamp != 0 &&
                positionData.transferPositionRequestPassTimestamp <= getCurrentTime()
        );

        positionData.transferPositionRequestPassTimestamp = 0;

        positions[newSponsorAddress] = positionData;
        delete positions[msg.sender];

        emit RequestTransferPositionExecuted(msg.sender, newSponsorAddress);
        emit NewSponsor(newSponsorAddress);
        emit EndedSponsorPosition(msg.sender);
    }

    function cancelTransferPosition() external onlyPreExpiration() nonReentrant() {

        PositionData storage positionData = _getPositionData(msg.sender);
        require(positionData.transferPositionRequestPassTimestamp != 0);

        emit RequestTransferPositionCanceled(msg.sender);

        positionData.transferPositionRequestPassTimestamp = 0;
    }

    function depositTo(address sponsor, FixedPoint.Unsigned memory collateralAmount)
        public
        onlyPreExpiration()
        noPendingWithdrawal(sponsor)
        fees()
        nonReentrant()
    {

        require(collateralAmount.isGreaterThan(0));
        PositionData storage positionData = _getPositionData(sponsor);

        _incrementCollateralBalances(positionData, collateralAmount);

        emit Deposit(sponsor, collateralAmount.rawValue);

        collateralCurrency.safeTransferFrom(msg.sender, address(this), collateralAmount.rawValue);
    }

    function deposit(FixedPoint.Unsigned memory collateralAmount) public {

        depositTo(msg.sender, collateralAmount);
    }

    function withdraw(FixedPoint.Unsigned memory collateralAmount)
        public
        onlyPreExpiration()
        noPendingWithdrawal(msg.sender)
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {

        require(collateralAmount.isGreaterThan(0));
        PositionData storage positionData = _getPositionData(msg.sender);

        amountWithdrawn = _decrementCollateralBalancesCheckGCR(positionData, collateralAmount);

        emit Withdrawal(msg.sender, amountWithdrawn.rawValue);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);
    }

    function requestWithdrawal(FixedPoint.Unsigned memory collateralAmount)
        public
        onlyPreExpiration()
        noPendingWithdrawal(msg.sender)
        nonReentrant()
    {

        PositionData storage positionData = _getPositionData(msg.sender);
        require(
            collateralAmount.isGreaterThan(0) &&
                collateralAmount.isLessThanOrEqual(_getFeeAdjustedCollateral(positionData.rawCollateral))
        );

        uint256 requestPassTime = getCurrentTime().add(withdrawalLiveness);
        require(requestPassTime < expirationTimestamp);

        positionData.withdrawalRequestPassTimestamp = requestPassTime;
        positionData.withdrawalRequestAmount = collateralAmount;

        emit RequestWithdrawal(msg.sender, collateralAmount.rawValue);
    }

    function withdrawPassedRequest()
        external
        onlyPreExpiration()
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {

        PositionData storage positionData = _getPositionData(msg.sender);
        require(
            positionData.withdrawalRequestPassTimestamp != 0 &&
                positionData.withdrawalRequestPassTimestamp <= getCurrentTime()
        );

        FixedPoint.Unsigned memory amountToWithdraw = positionData.withdrawalRequestAmount;
        if (positionData.withdrawalRequestAmount.isGreaterThan(_getFeeAdjustedCollateral(positionData.rawCollateral))) {
            amountToWithdraw = _getFeeAdjustedCollateral(positionData.rawCollateral);
        }

        amountWithdrawn = _decrementCollateralBalances(positionData, amountToWithdraw);

        _resetWithdrawalRequest(positionData);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);

        emit RequestWithdrawalExecuted(msg.sender, amountWithdrawn.rawValue);
    }

    function cancelWithdrawal() external nonReentrant() {

        PositionData storage positionData = _getPositionData(msg.sender);
        require(positionData.withdrawalRequestPassTimestamp != 0);

        emit RequestWithdrawalCanceled(msg.sender, positionData.withdrawalRequestAmount.rawValue);

        _resetWithdrawalRequest(positionData);
    }

    function create(FixedPoint.Unsigned memory collateralAmount, FixedPoint.Unsigned memory numTokens)
        public
        onlyPreExpiration()
        fees()
        nonReentrant()
    {

        PositionData storage positionData = positions[msg.sender];

        require(
            (_checkCollateralization(
                _getFeeAdjustedCollateral(positionData.rawCollateral).add(collateralAmount),
                positionData.tokensOutstanding.add(numTokens)
            ) || _checkCollateralization(collateralAmount, numTokens)),
            "Insufficient collateral"
        );

        require(positionData.withdrawalRequestPassTimestamp == 0, "Pending withdrawal");
        if (positionData.tokensOutstanding.isEqual(0)) {
            require(numTokens.isGreaterThanOrEqual(minSponsorTokens), "Below minimum sponsor position");
            emit NewSponsor(msg.sender);
        }

        _incrementCollateralBalances(positionData, collateralAmount);

        positionData.tokensOutstanding = positionData.tokensOutstanding.add(numTokens);

        totalTokensOutstanding = totalTokensOutstanding.add(numTokens);

        emit PositionCreated(msg.sender, collateralAmount.rawValue, numTokens.rawValue);

        collateralCurrency.safeTransferFrom(msg.sender, address(this), collateralAmount.rawValue);
        require(tokenCurrency.mint(msg.sender, numTokens.rawValue));
    }

    function repay(FixedPoint.Unsigned memory numTokens)
        public
        onlyPreExpiration()
        noPendingWithdrawal(msg.sender)
        fees()
        nonReentrant()
    {

        PositionData storage positionData = _getPositionData(msg.sender);
        require(numTokens.isLessThanOrEqual(positionData.tokensOutstanding));

        FixedPoint.Unsigned memory newTokenCount = positionData.tokensOutstanding.sub(numTokens);
        require(newTokenCount.isGreaterThanOrEqual(minSponsorTokens));
        positionData.tokensOutstanding = newTokenCount;

        totalTokensOutstanding = totalTokensOutstanding.sub(numTokens);

        emit Repay(msg.sender, numTokens.rawValue, newTokenCount.rawValue);

        tokenCurrency.safeTransferFrom(msg.sender, address(this), numTokens.rawValue);
        tokenCurrency.burn(numTokens.rawValue);
    }

    function redeem(FixedPoint.Unsigned memory numTokens)
        public
        noPendingWithdrawal(msg.sender)
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {

        PositionData storage positionData = _getPositionData(msg.sender);
        require(!numTokens.isGreaterThan(positionData.tokensOutstanding));

        FixedPoint.Unsigned memory fractionRedeemed = numTokens.div(positionData.tokensOutstanding);
        FixedPoint.Unsigned memory collateralRedeemed =
            fractionRedeemed.mul(_getFeeAdjustedCollateral(positionData.rawCollateral));

        if (positionData.tokensOutstanding.isEqual(numTokens)) {
            amountWithdrawn = _deleteSponsorPosition(msg.sender);
        } else {
            amountWithdrawn = _decrementCollateralBalances(positionData, collateralRedeemed);

            FixedPoint.Unsigned memory newTokenCount = positionData.tokensOutstanding.sub(numTokens);
            require(newTokenCount.isGreaterThanOrEqual(minSponsorTokens), "Below minimum sponsor position");
            positionData.tokensOutstanding = newTokenCount;

            totalTokensOutstanding = totalTokensOutstanding.sub(numTokens);
        }

        emit Redeem(msg.sender, amountWithdrawn.rawValue, numTokens.rawValue);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);
        tokenCurrency.safeTransferFrom(msg.sender, address(this), numTokens.rawValue);
        tokenCurrency.burn(numTokens.rawValue);
    }

    function settleExpired()
        external
        onlyPostExpiration()
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory amountWithdrawn)
    {

        require(contractState != ContractState.Open, "Unexpired position");

        if (contractState != ContractState.ExpiredPriceReceived) {
            expiryPrice = _getOraclePriceExpiration(expirationTimestamp);
            contractState = ContractState.ExpiredPriceReceived;
        }

        FixedPoint.Unsigned memory tokensToRedeem = FixedPoint.Unsigned(tokenCurrency.balanceOf(msg.sender));
        FixedPoint.Unsigned memory totalRedeemableCollateral = tokensToRedeem.mul(expiryPrice);

        PositionData storage positionData = positions[msg.sender];
        if (_getFeeAdjustedCollateral(positionData.rawCollateral).isGreaterThan(0)) {
            FixedPoint.Unsigned memory tokenDebtValueInCollateral = positionData.tokensOutstanding.mul(expiryPrice);
            FixedPoint.Unsigned memory positionCollateral = _getFeeAdjustedCollateral(positionData.rawCollateral);

            FixedPoint.Unsigned memory positionRedeemableCollateral =
                tokenDebtValueInCollateral.isLessThan(positionCollateral)
                    ? positionCollateral.sub(tokenDebtValueInCollateral)
                    : FixedPoint.Unsigned(0);

            totalRedeemableCollateral = totalRedeemableCollateral.add(positionRedeemableCollateral);

            delete positions[msg.sender];
            emit EndedSponsorPosition(msg.sender);
        }

        FixedPoint.Unsigned memory payout =
            FixedPoint.min(_getFeeAdjustedCollateral(rawTotalPositionCollateral), totalRedeemableCollateral);

        amountWithdrawn = _removeCollateral(rawTotalPositionCollateral, payout);
        totalTokensOutstanding = totalTokensOutstanding.sub(tokensToRedeem);

        emit SettleExpiredPosition(msg.sender, amountWithdrawn.rawValue, tokensToRedeem.rawValue);

        collateralCurrency.safeTransfer(msg.sender, amountWithdrawn.rawValue);
        tokenCurrency.safeTransferFrom(msg.sender, address(this), tokensToRedeem.rawValue);
        tokenCurrency.burn(tokensToRedeem.rawValue);
    }


    function expire() external onlyPostExpiration() onlyOpenState() fees() nonReentrant() {

        contractState = ContractState.ExpiredPriceRequested;

        _requestOraclePriceExpiration(expirationTimestamp);

        emit ContractExpired(msg.sender);
    }

    function updateDAOAddress(address DAOAddress) public {

        require(msg.sender == _getFinancialContractsAdminAddress() || msg.sender == externalVariableExpirationDAOAddress, 'Caller must be the authorized DAO or the UMA governor');
        updateTimestamp = getCurrentTime();
        emit UpdateDAOAddress(externalVariableExpirationDAOAddress, DAOAddress, updateTimestamp);
        externalVariableExpirationDAOAddress = DAOAddress;
    }

    function variableExpiration() external onlyPreExpiration() onlyOpenState() nonReentrant() {

        require(msg.sender == _getFinancialContractsAdminAddress() || msg.sender == externalVariableExpirationDAOAddress, 'Caller must be the authorized DAO or the UMA governor');

        contractState = ContractState.ExpiredPriceRequested;
        uint256 oldExpirationTimestamp = expirationTimestamp;
        expirationTimestamp = getCurrentTime();
        _requestOraclePriceExpiration(expirationTimestamp);

        emit VariableExpiration(msg.sender, oldExpirationTimestamp, expirationTimestamp);
    }

    function emergencyShutdown() external override onlyPreExpiration() onlyOpenState() nonReentrant() {

        require(msg.sender == _getFinancialContractsAdminAddress());

        contractState = ContractState.ExpiredPriceRequested;
        uint256 oldExpirationTimestamp = expirationTimestamp;
        expirationTimestamp = getCurrentTime();
        _requestOraclePriceExpiration(expirationTimestamp);

        emit EmergencyShutdown(msg.sender, oldExpirationTimestamp, expirationTimestamp);
    }

    function remargin() external override onlyPreExpiration() nonReentrant() {

        return;
    }

    function getCollateral(address sponsor) external view nonReentrantView() returns (FixedPoint.Unsigned memory) {

        return _getPendingRegularFeeAdjustedCollateral(_getFeeAdjustedCollateral(positions[sponsor].rawCollateral));
    }

    function totalPositionCollateral() external view nonReentrantView() returns (FixedPoint.Unsigned memory) {

        return _getPendingRegularFeeAdjustedCollateral(_getFeeAdjustedCollateral(rawTotalPositionCollateral));
    }


    function transformPrice(FixedPoint.Unsigned memory price, uint256 requestTime)
        public
        view
        nonReentrantView()
        returns (FixedPoint.Unsigned memory)
    {

        return _transformPrice(price, requestTime);
    }

    function transformPriceIdentifier(uint256 requestTime) public view nonReentrantView() returns (bytes32) {

        return _transformPriceIdentifier(requestTime);
    }


    function _reduceSponsorPosition(
        address sponsor,
        FixedPoint.Unsigned memory tokensToRemove,
        FixedPoint.Unsigned memory collateralToRemove,
        FixedPoint.Unsigned memory withdrawalAmountToRemove
    ) internal {

        PositionData storage positionData = _getPositionData(sponsor);

        if (
            tokensToRemove.isEqual(positionData.tokensOutstanding) &&
            _getFeeAdjustedCollateral(positionData.rawCollateral).isEqual(collateralToRemove)
        ) {
            _deleteSponsorPosition(sponsor);
            return;
        }

        _decrementCollateralBalances(positionData, collateralToRemove);

        FixedPoint.Unsigned memory newTokenCount = positionData.tokensOutstanding.sub(tokensToRemove);
        require(newTokenCount.isGreaterThanOrEqual(minSponsorTokens), "Below minimum sponsor position");
        positionData.tokensOutstanding = newTokenCount;

        positionData.withdrawalRequestAmount = positionData.withdrawalRequestAmount.sub(withdrawalAmountToRemove);

        totalTokensOutstanding = totalTokensOutstanding.sub(tokensToRemove);
    }

    function _deleteSponsorPosition(address sponsor) internal returns (FixedPoint.Unsigned memory) {

        PositionData storage positionToLiquidate = _getPositionData(sponsor);

        FixedPoint.Unsigned memory startingGlobalCollateral = _getFeeAdjustedCollateral(rawTotalPositionCollateral);

        FixedPoint.Unsigned memory remainingRawCollateral = positionToLiquidate.rawCollateral;
        rawTotalPositionCollateral = rawTotalPositionCollateral.sub(remainingRawCollateral);
        totalTokensOutstanding = totalTokensOutstanding.sub(positionToLiquidate.tokensOutstanding);

        delete positions[sponsor];

        emit EndedSponsorPosition(sponsor);

        return startingGlobalCollateral.sub(_getFeeAdjustedCollateral(rawTotalPositionCollateral));
    }

    function _pfc() internal view virtual override returns (FixedPoint.Unsigned memory) {

        return _getFeeAdjustedCollateral(rawTotalPositionCollateral);
    }

    function _getPositionData(address sponsor)
        internal
        view
        onlyCollateralizedPosition(sponsor)
        returns (PositionData storage)
    {

        return positions[sponsor];
    }

    function _getIdentifierWhitelist() internal view returns (IdentifierWhitelistInterface) {

        return IdentifierWhitelistInterface(finder.getImplementationAddress(OracleInterfaces.IdentifierWhitelist));
    }

    function _getOracle() internal view returns (OracleInterface) {

        return OracleInterface(finder.getImplementationAddress(OracleInterfaces.Oracle));
    }

    function _getOptimisticOracle() internal view returns (OptimisticOracleInterface) {

        return OptimisticOracleInterface(finder.getImplementationAddress(OracleInterfaces.OptimisticOracle));
    }

    function _getFinancialContractsAdminAddress() internal view returns (address) {

        return finder.getImplementationAddress(OracleInterfaces.FinancialContractsAdmin);
    }

    function _requestOraclePriceExpiration(uint256 requestedTime) internal {

        OptimisticOracleInterface optimisticOracle = _getOptimisticOracle();

        FixedPoint.Unsigned memory reward = _computeFinalFees();
        collateralCurrency.safeIncreaseAllowance(address(optimisticOracle), reward.rawValue);
        optimisticOracle.requestPrice(
            _transformPriceIdentifier(requestedTime),
            requestedTime,
            _getAncillaryData(),
            collateralCurrency,
            reward.rawValue // Reward is equal to the final fee
        );

        _adjustCumulativeFeeMultiplier(reward, _pfc());
    }

    function _getOraclePriceExpiration(uint256 requestedTime) internal returns (FixedPoint.Unsigned memory) {

        OptimisticOracleInterface optimisticOracle = _getOptimisticOracle();
        require(
            optimisticOracle.hasPrice(
                address(this),
                _transformPriceIdentifier(requestedTime),
                requestedTime,
                _getAncillaryData()
            )
        );
        int256 optimisticOraclePrice =
            optimisticOracle.settleAndGetPrice(
                _transformPriceIdentifier(requestedTime),
                requestedTime,
                _getAncillaryData()
            );

        if (optimisticOraclePrice < 0) {
            optimisticOraclePrice = 0;
        }
        return _transformPrice(FixedPoint.Unsigned(uint256(optimisticOraclePrice)), requestedTime);
    }

    function _requestOraclePriceLiquidation(uint256 requestedTime) internal {

        OracleInterface oracle = _getOracle();
        oracle.requestPrice(_transformPriceIdentifier(requestedTime), requestedTime);
    }

    function _getOraclePriceLiquidation(uint256 requestedTime) internal view returns (FixedPoint.Unsigned memory) {

        OracleInterface oracle = _getOracle();
        require(oracle.hasPrice(_transformPriceIdentifier(requestedTime), requestedTime), "Unresolved oracle price");
        int256 oraclePrice = oracle.getPrice(_transformPriceIdentifier(requestedTime), requestedTime);

        if (oraclePrice < 0) {
            oraclePrice = 0;
        }
        return _transformPrice(FixedPoint.Unsigned(uint256(oraclePrice)), requestedTime);
    }

    function _resetWithdrawalRequest(PositionData storage positionData) internal {

        positionData.withdrawalRequestAmount = FixedPoint.fromUnscaledUint(0);
        positionData.withdrawalRequestPassTimestamp = 0;
    }

    function _incrementCollateralBalances(
        PositionData storage positionData,
        FixedPoint.Unsigned memory collateralAmount
    ) internal returns (FixedPoint.Unsigned memory) {

        _addCollateral(positionData.rawCollateral, collateralAmount);
        return _addCollateral(rawTotalPositionCollateral, collateralAmount);
    }

    function _decrementCollateralBalances(
        PositionData storage positionData,
        FixedPoint.Unsigned memory collateralAmount
    ) internal returns (FixedPoint.Unsigned memory) {

        _removeCollateral(positionData.rawCollateral, collateralAmount);
        return _removeCollateral(rawTotalPositionCollateral, collateralAmount);
    }

    function _decrementCollateralBalancesCheckGCR(
        PositionData storage positionData,
        FixedPoint.Unsigned memory collateralAmount
    ) internal returns (FixedPoint.Unsigned memory) {

        _removeCollateral(positionData.rawCollateral, collateralAmount);
        require(_checkPositionCollateralization(positionData), "CR below GCR");
        return _removeCollateral(rawTotalPositionCollateral, collateralAmount);
    }

    function _onlyOpenState() internal view {

        require(contractState == ContractState.Open, "Contract state is not OPEN");
    }

    function _onlyPreExpiration() internal view {

        require(getCurrentTime() < expirationTimestamp, "Only callable pre-expiry");
    }

    function _onlyPostExpiration() internal view {

        require(getCurrentTime() >= expirationTimestamp, "Only callable post-expiry");
    }

    function _onlyCollateralizedPosition(address sponsor) internal view {

        require(
            _getFeeAdjustedCollateral(positions[sponsor].rawCollateral).isGreaterThan(0),
            "Position has no collateral"
        );
    }

    function _positionHasNoPendingWithdrawal(address sponsor) internal view {

        require(_getPositionData(sponsor).withdrawalRequestPassTimestamp == 0, "Pending withdrawal");
    }


    function _checkPositionCollateralization(PositionData storage positionData) private view returns (bool) {

        return
            _checkCollateralization(
                _getFeeAdjustedCollateral(positionData.rawCollateral),
                positionData.tokensOutstanding
            );
    }

    function _checkCollateralization(FixedPoint.Unsigned memory collateral, FixedPoint.Unsigned memory numTokens)
        private
        view
        returns (bool)
    {

        FixedPoint.Unsigned memory global =
            _getCollateralizationRatio(_getFeeAdjustedCollateral(rawTotalPositionCollateral), totalTokensOutstanding);
        FixedPoint.Unsigned memory thisChange = _getCollateralizationRatio(collateral, numTokens);
        return !global.isGreaterThan(thisChange);
    }

    function _getCollateralizationRatio(FixedPoint.Unsigned memory collateral, FixedPoint.Unsigned memory numTokens)
        private
        pure
        returns (FixedPoint.Unsigned memory ratio)
    {

        if (!numTokens.isGreaterThan(0)) {
            return FixedPoint.fromUnscaledUint(0);
        } else {
            return collateral.div(numTokens);
        }
    }

    function _getSyntheticDecimals(address _collateralAddress) public view returns (uint8 decimals) {

        try IERC20Standard(_collateralAddress).decimals() returns (uint8 _decimals) {
            return _decimals;
        } catch {
            return 18;
        }
    }

    function _transformPrice(FixedPoint.Unsigned memory price, uint256 requestTime)
        internal
        view
        returns (FixedPoint.Unsigned memory)
    {

        if (!address(financialProductLibrary).isContract()) return price;
        try financialProductLibrary.transformPrice(price, requestTime) returns (
            FixedPoint.Unsigned memory transformedPrice
        ) {
            return transformedPrice;
        } catch {
            return price;
        }
    }

    function _transformPriceIdentifier(uint256 requestTime) internal view returns (bytes32) {

        if (!address(financialProductLibrary).isContract()) return priceIdentifier;
        try financialProductLibrary.transformPriceIdentifier(priceIdentifier, requestTime) returns (
            bytes32 transformedIdentifier
        ) {
            return transformedIdentifier;
        } catch {
            return priceIdentifier;
        }
    }

    function _getAncillaryData() internal view returns (bytes memory) {

        return abi.encodePacked(address(tokenCurrency));
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;




contract Liquidatable is PricelessPositionManager {

    using FixedPoint for FixedPoint.Unsigned;
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using SafeERC20 for ExpandedIERC20;
    using Address for address;


    enum Status { Uninitialized, NotDisputed, Disputed, DisputeSucceeded, DisputeFailed }

    struct LiquidationData {
        address sponsor; // Address of the liquidated position's sponsor
        address liquidator; // Address who created this liquidation
        Status state; // Liquidated (and expired or not), Pending a Dispute, or Dispute has resolved
        uint256 liquidationTime; // Time when liquidation is initiated, needed to get price from Oracle
        FixedPoint.Unsigned tokensOutstanding; // Synthetic tokens required to be burned by liquidator to initiate dispute
        FixedPoint.Unsigned lockedCollateral; // Collateral locked by contract and released upon expiry or post-dispute
        FixedPoint.Unsigned liquidatedCollateral;
        FixedPoint.Unsigned rawUnitCollateral;
        address disputer; // Person who is disputing a liquidation
        FixedPoint.Unsigned settlementPrice; // Final price as determined by an Oracle following a dispute
        FixedPoint.Unsigned finalFee;
    }

    struct ConstructorParams {
        uint256 expirationTimestamp;
        uint256 withdrawalLiveness;
        address collateralAddress;
        address tokenAddress;
        address finderAddress;
        address timerAddress;
        address financialProductLibraryAddress;
        address externalVariableExpirationDAOAddress;
        bytes32 priceFeedIdentifier;
        FixedPoint.Unsigned minSponsorTokens;
        uint256 liquidationLiveness;
        FixedPoint.Unsigned collateralRequirement;
        FixedPoint.Unsigned disputeBondPercentage;
        FixedPoint.Unsigned sponsorDisputeRewardPercentage;
        FixedPoint.Unsigned disputerDisputeRewardPercentage;
    }

    struct RewardsData {
        FixedPoint.Unsigned payToSponsor;
        FixedPoint.Unsigned payToLiquidator;
        FixedPoint.Unsigned payToDisputer;
        FixedPoint.Unsigned paidToSponsor;
        FixedPoint.Unsigned paidToLiquidator;
        FixedPoint.Unsigned paidToDisputer;
    }

    mapping(address => LiquidationData[]) public liquidations;

    FixedPoint.Unsigned public rawLiquidationCollateral;

    uint256 public liquidationLiveness;
    FixedPoint.Unsigned public collateralRequirement;
    FixedPoint.Unsigned public disputeBondPercentage;
    FixedPoint.Unsigned public sponsorDisputeRewardPercentage;
    FixedPoint.Unsigned public disputerDisputeRewardPercentage;


    event LiquidationCreated(
        address indexed sponsor,
        address indexed liquidator,
        uint256 indexed liquidationId,
        uint256 tokensOutstanding,
        uint256 lockedCollateral,
        uint256 liquidatedCollateral,
        uint256 liquidationTime
    );
    event LiquidationDisputed(
        address indexed sponsor,
        address indexed liquidator,
        address indexed disputer,
        uint256 liquidationId,
        uint256 disputeBondAmount
    );
    event DisputeSettled(
        address indexed caller,
        address indexed sponsor,
        address indexed liquidator,
        address disputer,
        uint256 liquidationId,
        bool disputeSucceeded
    );
    event LiquidationWithdrawn(
        address indexed caller,
        uint256 paidToLiquidator,
        uint256 paidToDisputer,
        uint256 paidToSponsor,
        Status indexed liquidationStatus,
        uint256 settlementPrice
    );


    modifier disputable(uint256 liquidationId, address sponsor) {

        _disputable(liquidationId, sponsor);
        _;
    }

    modifier withdrawable(uint256 liquidationId, address sponsor) {

        _withdrawable(liquidationId, sponsor);
        _;
    }

    constructor(ConstructorParams memory params)
        PricelessPositionManager(
            params.expirationTimestamp,
            params.withdrawalLiveness,
            params.collateralAddress,
            params.tokenAddress,
            params.finderAddress,
            params.priceFeedIdentifier,
            params.minSponsorTokens,
            params.timerAddress,
            params.financialProductLibraryAddress,
            params.externalVariableExpirationDAOAddress
        )
        nonReentrant()
    {
        require(params.collateralRequirement.isGreaterThan(1));
        require(params.sponsorDisputeRewardPercentage.add(params.disputerDisputeRewardPercentage).isLessThan(1));

        liquidationLiveness = params.liquidationLiveness;
        collateralRequirement = params.collateralRequirement;
        disputeBondPercentage = params.disputeBondPercentage;
        sponsorDisputeRewardPercentage = params.sponsorDisputeRewardPercentage;
        disputerDisputeRewardPercentage = params.disputerDisputeRewardPercentage;
    }


    function createLiquidation(
        address sponsor,
        FixedPoint.Unsigned calldata minCollateralPerToken,
        FixedPoint.Unsigned calldata maxCollateralPerToken,
        FixedPoint.Unsigned calldata maxTokensToLiquidate,
        uint256 deadline
    )
        external
        fees()
        onlyPreExpiration()
        nonReentrant()
        returns (
            uint256 liquidationId,
            FixedPoint.Unsigned memory tokensLiquidated,
            FixedPoint.Unsigned memory finalFeeBond
        )
    {

        require(getCurrentTime() <= deadline, "Mined after deadline");

        PositionData storage positionToLiquidate = _getPositionData(sponsor);

        tokensLiquidated = FixedPoint.min(maxTokensToLiquidate, positionToLiquidate.tokensOutstanding);
        require(tokensLiquidated.isGreaterThan(0));

        FixedPoint.Unsigned memory startCollateral = _getFeeAdjustedCollateral(positionToLiquidate.rawCollateral);
        FixedPoint.Unsigned memory startCollateralNetOfWithdrawal = FixedPoint.fromUnscaledUint(0);
        if (positionToLiquidate.withdrawalRequestAmount.isLessThanOrEqual(startCollateral)) {
            startCollateralNetOfWithdrawal = startCollateral.sub(positionToLiquidate.withdrawalRequestAmount);
        }

        {
            FixedPoint.Unsigned memory startTokens = positionToLiquidate.tokensOutstanding;

            require(
                maxCollateralPerToken.mul(startTokens).isGreaterThanOrEqual(startCollateralNetOfWithdrawal),
                "CR is more than max liq. price"
            );
            require(
                minCollateralPerToken.mul(startTokens).isLessThanOrEqual(startCollateralNetOfWithdrawal),
                "CR is less than min liq. price"
            );
        }

        finalFeeBond = _computeFinalFees();

        FixedPoint.Unsigned memory lockedCollateral;
        FixedPoint.Unsigned memory liquidatedCollateral;

        {
            FixedPoint.Unsigned memory ratio = tokensLiquidated.div(positionToLiquidate.tokensOutstanding);

            lockedCollateral = startCollateral.mul(ratio);

            liquidatedCollateral = startCollateralNetOfWithdrawal.mul(ratio);

            FixedPoint.Unsigned memory withdrawalAmountToRemove =
                positionToLiquidate.withdrawalRequestAmount.mul(ratio);
            _reduceSponsorPosition(sponsor, tokensLiquidated, lockedCollateral, withdrawalAmountToRemove);
        }

        _addCollateral(rawLiquidationCollateral, lockedCollateral.add(finalFeeBond));

        liquidationId = liquidations[sponsor].length;
        liquidations[sponsor].push(
            LiquidationData({
                sponsor: sponsor,
                liquidator: msg.sender,
                state: Status.NotDisputed,
                liquidationTime: getCurrentTime(),
                tokensOutstanding: tokensLiquidated,
                lockedCollateral: lockedCollateral,
                liquidatedCollateral: liquidatedCollateral,
                rawUnitCollateral: _convertToRawCollateral(FixedPoint.fromUnscaledUint(1)),
                disputer: address(0),
                settlementPrice: FixedPoint.fromUnscaledUint(0),
                finalFee: finalFeeBond
            })
        );


        FixedPoint.Unsigned memory griefingThreshold = minSponsorTokens;
        if (
            positionToLiquidate.withdrawalRequestPassTimestamp > 0 && // The position is undergoing a slow withdrawal.
            positionToLiquidate.withdrawalRequestPassTimestamp > getCurrentTime() && // The slow withdrawal has not yet expired.
            tokensLiquidated.isGreaterThanOrEqual(griefingThreshold) // The liquidated token count is above a "griefing threshold".
        ) {
            positionToLiquidate.withdrawalRequestPassTimestamp = getCurrentTime().add(withdrawalLiveness);
        }

        emit LiquidationCreated(
            sponsor,
            msg.sender,
            liquidationId,
            tokensLiquidated.rawValue,
            lockedCollateral.rawValue,
            liquidatedCollateral.rawValue,
            getCurrentTime()
        );

        tokenCurrency.safeTransferFrom(msg.sender, address(this), tokensLiquidated.rawValue);
        tokenCurrency.burn(tokensLiquidated.rawValue);

        collateralCurrency.safeTransferFrom(msg.sender, address(this), finalFeeBond.rawValue);
    }

    function dispute(uint256 liquidationId, address sponsor)
        external
        disputable(liquidationId, sponsor)
        fees()
        nonReentrant()
        returns (FixedPoint.Unsigned memory totalPaid)
    {

        LiquidationData storage disputedLiquidation = _getLiquidationData(sponsor, liquidationId);

        FixedPoint.Unsigned memory disputeBondAmount =
            disputedLiquidation.lockedCollateral.mul(disputeBondPercentage).mul(
                _getFeeAdjustedCollateral(disputedLiquidation.rawUnitCollateral)
            );
        _addCollateral(rawLiquidationCollateral, disputeBondAmount);

        disputedLiquidation.state = Status.Disputed;
        disputedLiquidation.disputer = msg.sender;

        _requestOraclePriceLiquidation(disputedLiquidation.liquidationTime);

        emit LiquidationDisputed(
            sponsor,
            disputedLiquidation.liquidator,
            msg.sender,
            liquidationId,
            disputeBondAmount.rawValue
        );
        totalPaid = disputeBondAmount.add(disputedLiquidation.finalFee);

        _payFinalFees(msg.sender, disputedLiquidation.finalFee);

        collateralCurrency.safeTransferFrom(msg.sender, address(this), disputeBondAmount.rawValue);
    }

    function withdrawLiquidation(uint256 liquidationId, address sponsor)
        public
        withdrawable(liquidationId, sponsor)
        fees()
        nonReentrant()
        returns (RewardsData memory)
    {

        LiquidationData storage liquidation = _getLiquidationData(sponsor, liquidationId);

        _settle(liquidationId, sponsor);

        FixedPoint.Unsigned memory feeAttenuation = _getFeeAdjustedCollateral(liquidation.rawUnitCollateral);
        FixedPoint.Unsigned memory settlementPrice = liquidation.settlementPrice;
        FixedPoint.Unsigned memory tokenRedemptionValue =
            liquidation.tokensOutstanding.mul(settlementPrice).mul(feeAttenuation);
        FixedPoint.Unsigned memory collateral = liquidation.lockedCollateral.mul(feeAttenuation);
        FixedPoint.Unsigned memory disputerDisputeReward = disputerDisputeRewardPercentage.mul(tokenRedemptionValue);
        FixedPoint.Unsigned memory sponsorDisputeReward = sponsorDisputeRewardPercentage.mul(tokenRedemptionValue);
        FixedPoint.Unsigned memory disputeBondAmount = collateral.mul(disputeBondPercentage);
        FixedPoint.Unsigned memory finalFee = liquidation.finalFee.mul(feeAttenuation);

        RewardsData memory rewards;
        if (liquidation.state == Status.DisputeSucceeded) {

            rewards.payToDisputer = disputerDisputeReward.add(disputeBondAmount).add(finalFee);

            rewards.payToSponsor = sponsorDisputeReward.add(collateral.sub(tokenRedemptionValue));

            rewards.payToLiquidator = tokenRedemptionValue.sub(sponsorDisputeReward).sub(disputerDisputeReward);

            rewards.paidToLiquidator = _removeCollateral(rawLiquidationCollateral, rewards.payToLiquidator);
            rewards.paidToSponsor = _removeCollateral(rawLiquidationCollateral, rewards.payToSponsor);
            rewards.paidToDisputer = _removeCollateral(rawLiquidationCollateral, rewards.payToDisputer);

            collateralCurrency.safeTransfer(liquidation.disputer, rewards.paidToDisputer.rawValue);
            collateralCurrency.safeTransfer(liquidation.liquidator, rewards.paidToLiquidator.rawValue);
            collateralCurrency.safeTransfer(liquidation.sponsor, rewards.paidToSponsor.rawValue);

        } else if (liquidation.state == Status.DisputeFailed) {
            rewards.payToLiquidator = collateral.add(disputeBondAmount).add(finalFee);

            rewards.paidToLiquidator = _removeCollateral(rawLiquidationCollateral, rewards.payToLiquidator);

            collateralCurrency.safeTransfer(liquidation.liquidator, rewards.paidToLiquidator.rawValue);

        } else if (liquidation.state == Status.NotDisputed) {
            rewards.payToLiquidator = collateral.add(finalFee);

            rewards.paidToLiquidator = _removeCollateral(rawLiquidationCollateral, rewards.payToLiquidator);

            collateralCurrency.safeTransfer(liquidation.liquidator, rewards.paidToLiquidator.rawValue);
        }

        emit LiquidationWithdrawn(
            msg.sender,
            rewards.paidToLiquidator.rawValue,
            rewards.paidToDisputer.rawValue,
            rewards.paidToSponsor.rawValue,
            liquidation.state,
            settlementPrice.rawValue
        );

        delete liquidations[sponsor][liquidationId];

        return rewards;
    }

    function getLiquidations(address sponsor)
        external
        view
        nonReentrantView()
        returns (LiquidationData[] memory liquidationData)
    {

        return liquidations[sponsor];
    }

    function transformCollateralRequirement(FixedPoint.Unsigned memory price)
        public
        view
        nonReentrantView()
        returns (FixedPoint.Unsigned memory)
    {

        return _transformCollateralRequirement(price);
    }


    function _settle(uint256 liquidationId, address sponsor) internal {

        LiquidationData storage liquidation = _getLiquidationData(sponsor, liquidationId);

        if (liquidation.state != Status.Disputed) {
            return;
        }

        liquidation.settlementPrice = _getOraclePriceLiquidation(liquidation.liquidationTime);

        FixedPoint.Unsigned memory tokenRedemptionValue =
            liquidation.tokensOutstanding.mul(liquidation.settlementPrice);

        FixedPoint.Unsigned memory requiredCollateral =
            tokenRedemptionValue.mul(_transformCollateralRequirement(liquidation.settlementPrice));

        bool disputeSucceeded = liquidation.liquidatedCollateral.isGreaterThanOrEqual(requiredCollateral);
        liquidation.state = disputeSucceeded ? Status.DisputeSucceeded : Status.DisputeFailed;

        emit DisputeSettled(
            msg.sender,
            sponsor,
            liquidation.liquidator,
            liquidation.disputer,
            liquidationId,
            disputeSucceeded
        );
    }

    function _pfc() internal view override returns (FixedPoint.Unsigned memory) {

        return super._pfc().add(_getFeeAdjustedCollateral(rawLiquidationCollateral));
    }

    function _getLiquidationData(address sponsor, uint256 liquidationId)
        internal
        view
        returns (LiquidationData storage liquidation)
    {

        LiquidationData[] storage liquidationArray = liquidations[sponsor];

        require(
            liquidationId < liquidationArray.length && liquidationArray[liquidationId].state != Status.Uninitialized,
            "Invalid liquidation ID"
        );
        return liquidationArray[liquidationId];
    }

    function _getLiquidationExpiry(LiquidationData storage liquidation) internal view returns (uint256) {

        return liquidation.liquidationTime.add(liquidationLiveness);
    }

    function _disputable(uint256 liquidationId, address sponsor) internal view {

        LiquidationData storage liquidation = _getLiquidationData(sponsor, liquidationId);
        require(
            (getCurrentTime() < _getLiquidationExpiry(liquidation)) && (liquidation.state == Status.NotDisputed),
            "Liquidation not disputable"
        );
    }

    function _withdrawable(uint256 liquidationId, address sponsor) internal view {

        LiquidationData storage liquidation = _getLiquidationData(sponsor, liquidationId);
        Status state = liquidation.state;

        require(
            (state > Status.NotDisputed) ||
                ((_getLiquidationExpiry(liquidation) <= getCurrentTime()) && (state == Status.NotDisputed)),
            "Liquidation not withdrawable"
        );
    }

    function _transformCollateralRequirement(FixedPoint.Unsigned memory price)
        internal
        view
        returns (FixedPoint.Unsigned memory)
    {

        if (!address(financialProductLibrary).isContract()) return collateralRequirement;
        try financialProductLibrary.transformCollateralRequirement(price, collateralRequirement) returns (
            FixedPoint.Unsigned memory transformedCollateralRequirement
        ) {
            return transformedCollateralRequirement;
        } catch {
            return collateralRequirement;
        }
    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;


contract VariableExpiringMultiParty is Liquidatable {

    constructor(ConstructorParams memory params)
        Liquidatable(params)
    {

    }
}// AGPL-3.0-only
pragma solidity ^0.8.0;


library VariableExpiringMultiPartyLib {

    function deploy(VariableExpiringMultiParty.ConstructorParams memory params) public returns (address) {

        VariableExpiringMultiParty derivative = new VariableExpiringMultiParty(params);
        return address(derivative);
    }
}