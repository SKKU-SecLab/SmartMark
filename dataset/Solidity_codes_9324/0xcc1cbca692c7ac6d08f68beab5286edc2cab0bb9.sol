
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
}// MIT

pragma solidity ^0.8.0;


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
}// MIT

pragma solidity ^0.8.0;

library Math {

    function max(uint256 a, uint256 b) internal pure returns (uint256) {

        return a >= b ? a : b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {

        return a < b ? a : b;
    }

    function average(uint256 a, uint256 b) internal pure returns (uint256) {

        return (a & b) + (a ^ b) / 2;
    }

    function ceilDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b + (a % b == 0 ? 0 : 1);
    }
}// MIT

pragma solidity ^0.8.0;

library SafeCast {

    function toUint224(uint256 value) internal pure returns (uint224) {

        require(value <= type(uint224).max, "SafeCast: value doesn't fit in 224 bits");
        return uint224(value);
    }

    function toUint128(uint256 value) internal pure returns (uint128) {

        require(value <= type(uint128).max, "SafeCast: value doesn't fit in 128 bits");
        return uint128(value);
    }

    function toUint96(uint256 value) internal pure returns (uint96) {

        require(value <= type(uint96).max, "SafeCast: value doesn't fit in 96 bits");
        return uint96(value);
    }

    function toUint64(uint256 value) internal pure returns (uint64) {

        require(value <= type(uint64).max, "SafeCast: value doesn't fit in 64 bits");
        return uint64(value);
    }

    function toUint32(uint256 value) internal pure returns (uint32) {

        require(value <= type(uint32).max, "SafeCast: value doesn't fit in 32 bits");
        return uint32(value);
    }

    function toUint16(uint256 value) internal pure returns (uint16) {

        require(value <= type(uint16).max, "SafeCast: value doesn't fit in 16 bits");
        return uint16(value);
    }

    function toUint8(uint256 value) internal pure returns (uint8) {

        require(value <= type(uint8).max, "SafeCast: value doesn't fit in 8 bits");
        return uint8(value);
    }

    function toUint256(int256 value) internal pure returns (uint256) {

        require(value >= 0, "SafeCast: value must be positive");
        return uint256(value);
    }

    function toInt128(int256 value) internal pure returns (int128) {

        require(value >= type(int128).min && value <= type(int128).max, "SafeCast: value doesn't fit in 128 bits");
        return int128(value);
    }

    function toInt64(int256 value) internal pure returns (int64) {

        require(value >= type(int64).min && value <= type(int64).max, "SafeCast: value doesn't fit in 64 bits");
        return int64(value);
    }

    function toInt32(int256 value) internal pure returns (int32) {

        require(value >= type(int32).min && value <= type(int32).max, "SafeCast: value doesn't fit in 32 bits");
        return int32(value);
    }

    function toInt16(int256 value) internal pure returns (int16) {

        require(value >= type(int16).min && value <= type(int16).max, "SafeCast: value doesn't fit in 16 bits");
        return int16(value);
    }

    function toInt8(int256 value) internal pure returns (int8) {

        require(value >= type(int8).min && value <= type(int8).max, "SafeCast: value doesn't fit in 8 bits");
        return int8(value);
    }

    function toInt256(uint256 value) internal pure returns (int256) {

        require(value <= uint256(type(int256).max), "SafeCast: value doesn't fit in an int256");
        return int256(value);
    }
}// MIT

pragma solidity ^0.8.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// BSD-3-Clause
pragma solidity 0.8.9;


interface SupervisorInterface is IERC165 {


    function enableAsCollateral(address[] calldata mTokens) external;


    function disableAsCollateral(address mToken) external;



    function beforeLend(
        address mToken,
        address lender,
        uint256 wrapBalance
    ) external;


    function beforeRedeem(
        address mToken,
        address redeemer,
        uint256 redeemTokens
    ) external;


    function redeemVerify(uint256 redeemAmount, uint256 redeemTokens) external;


    function beforeBorrow(
        address mToken,
        address borrower,
        uint256 borrowAmount
    ) external;


    function beforeRepayBorrow(address mToken, address borrower) external;


    function beforeAutoLiquidationSeize(
        address mToken,
        address liquidator_,
        address borrower
    ) external;


    function beforeAutoLiquidationRepay(
        address liquidator,
        address borrower,
        address mToken,
        uint224 borrowIndex
    ) external;


    function beforeTransfer(
        address mToken,
        address src,
        address dst,
        uint256 transferTokens
    ) external;


    function beforeFlashLoan(
        address mToken,
        address receiver,
        uint256 amount,
        uint256 fee
    ) external;


    function isLiquidator(address liquidator) external;

}// MIT

pragma solidity ^0.8.0;

interface IERC3156FlashBorrower {

    function onFlashLoan(
        address initiator,
        address token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32);

}// MIT

pragma solidity ^0.8.0;


interface IERC3156FlashLender {

    function maxFlashLoan(address token) external view returns (uint256);


    function flashFee(address token, uint256 amount) external view returns (uint256);


    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external returns (bool);

}// MIT

pragma solidity ^0.8.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.8.0;

interface IAccessControl {

    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    function hasRole(bytes32 role, address account) external view returns (bool);


    function getRoleAdmin(bytes32 role) external view returns (bytes32);


    function grantRole(bytes32 role, address account) external;


    function revokeRole(bytes32 role, address account) external;


    function renounceRole(bytes32 role, address account) external;

}// MIT

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}// MIT

pragma solidity ^0.8.0;

library Strings {

    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {


        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function toHexString(uint256 value) internal pure returns (string memory) {

        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {

        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract ERC165 is IERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}// MIT

pragma solidity ^0.8.0;


abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    function hasRole(bytes32 role, address account) public view override returns (bool) {
        return _roles[role].members[account];
    }

    function _checkRole(bytes32 role, address account) internal view {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    function getRoleAdmin(bytes32 role) public view override returns (bytes32) {
        return _roles[role].adminRole;
    }

    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}// BSD-3-Clause
pragma solidity 0.8.9;


interface InterestRateModel is IERC165 {

    function getBorrowRate(
        uint256 cash,
        uint256 borrows,
        uint256 protocolInterest
    ) external view returns (uint256);


    function getSupplyRate(
        uint256 cash,
        uint256 borrows,
        uint256 protocolInterest,
        uint256 protocolInterestFactorMantissa
    ) external view returns (uint256);

}// BSD-3-Clause
pragma solidity 0.8.9;


interface WhitelistInterface is IERC165 {

    function addMember(address _newAccount) external;


    function removeMember(address _accountToRemove) external;


    function turnOffWhitelistMode() external;


    function setMaxMembers(uint256 _newThreshold) external;


    function isWhitelisted(address _who) external view returns (bool);

}// BSD-3-Clause
pragma solidity 0.8.9;



abstract contract MTokenStorage is AccessControl, ReentrancyGuard {
    uint256 internal constant EXP_SCALE = 1e18;
    bytes32 internal constant FLASH_LOAN_SUCCESS = keccak256("ERC3156FlashBorrower.onFlashLoan");

    bytes32 public constant TIMELOCK = bytes32(0xaefebe170cbaff0af052a32795af0e1b8afff9850f946ad2869be14f35534371);

    IERC20 public underlying;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 internal constant borrowRateMaxMantissa = 0.0005e16;

    uint256 internal constant protocolInterestFactorMaxMantissa = 1e18;

    SupervisorInterface public supervisor;

    InterestRateModel public interestRateModel;

    uint256 public initialExchangeRateMantissa;

    uint256 public protocolInterestFactorMantissa;

    uint256 public accrualBlockNumber;

    uint256 public borrowIndex;

    uint256 public totalBorrows;

    uint256 public totalProtocolInterest;

    uint256 internal totalTokenSupply;

    mapping(address => uint256) internal accountTokens;

    mapping(address => mapping(address => uint256)) internal transferAllowances;

    struct BorrowSnapshot {
        uint256 principal;
        uint256 interestIndex;
    }

    mapping(address => BorrowSnapshot) internal accountBorrows;

    uint256 public maxFlashLoanShare;

    uint256 public flashLoanFeeShare;
}

interface MTokenInterface is IERC20, IERC3156FlashLender, IERC165 {


    event AccrueInterest(
        uint256 cashPrior,
        uint256 interestAccumulated,
        uint256 borrowIndex,
        uint256 totalBorrows,
        uint256 totalProtocolInterest
    );

    event Lend(address lender, uint256 lendAmount, uint256 lendTokens, uint256 newTotalTokenSupply);

    event Redeem(address redeemer, uint256 redeemAmount, uint256 redeemTokens, uint256 newTotalTokenSupply);

    event Borrow(address borrower, uint256 borrowAmount, uint256 accountBorrows, uint256 totalBorrows);

    event Seize(
        address borrower,
        address receiver,
        uint256 seizeTokens,
        uint256 accountsTokens,
        uint256 totalSupply,
        uint256 seizeUnderlyingAmount
    );

    event RepayBorrow(
        address payer,
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrows,
        uint256 totalBorrows
    );

    event AutoLiquidationRepayBorrow(
        address borrower,
        uint256 repayAmount,
        uint256 accountBorrowsNew,
        uint256 totalBorrowsNew,
        uint256 TotalProtocolInterestNew
    );

    event FlashLoanExecuted(address receiver, uint256 amount, uint256 fee);


    event NewSupervisor(SupervisorInterface oldSupervisor, SupervisorInterface newSupervisor);

    event NewMarketInterestRateModel(InterestRateModel oldInterestRateModel, InterestRateModel newInterestRateModel);

    event NewProtocolInterestFactor(
        uint256 oldProtocolInterestFactorMantissa,
        uint256 newProtocolInterestFactorMantissa
    );

    event NewFlashLoanMaxShare(uint256 oldMaxShare, uint256 newMaxShare);

    event NewFlashLoanFee(uint256 oldFee, uint256 newFee);

    event ProtocolInterestAdded(address benefactor, uint256 addAmount, uint256 newTotalProtocolInterest);

    event ProtocolInterestReduced(address admin, uint256 reduceAmount, uint256 newTotalProtocolInterest);


    function balanceOfUnderlying(address owner) external returns (uint256);


    function getAccountSnapshot(address account)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function borrowRatePerBlock() external view returns (uint256);


    function supplyRatePerBlock() external view returns (uint256);


    function totalBorrowsCurrent() external returns (uint256);


    function borrowBalanceCurrent(address account) external returns (uint256);


    function borrowBalanceStored(address account) external view returns (uint256);


    function exchangeRateCurrent() external returns (uint256);


    function exchangeRateStored() external view returns (uint256);


    function getCash() external view returns (uint256);


    function accrueInterest() external;


    function lend(uint256 lendAmount) external;


    function redeem(uint256 redeemTokens) external;


    function redeemUnderlying(uint256 redeemAmount) external;


    function borrow(uint256 borrowAmount) external;


    function repayBorrow(uint256 repayAmount) external;


    function repayBorrowBehalf(address borrower, uint256 repayAmount) external;


    function autoLiquidationRepayBorrow(address borrower, uint256 repayAmount) external;


    function sweepToken(IERC20 token, address admin_) external;


    function addProtocolInterestBehalf(address payer, uint256 addAmount) external;



    function setSupervisor(SupervisorInterface newSupervisor) external;


    function setProtocolInterestFactor(uint256 newProtocolInterestFactorMantissa) external;


    function reduceProtocolInterest(uint256 reduceAmount, address admin_) external;


    function setInterestRateModel(InterestRateModel newInterestRateModel) external;


    function addProtocolInterest(uint256 addAmount) external;

}

interface MntLike {

    function delegate(address delegatee) external;

}// BSD-3-Clause
pragma solidity 0.8.9;

library ErrorCodes {

    string internal constant ADMIN_ONLY = "E101";
    string internal constant UNAUTHORIZED = "E102";
    string internal constant OPERATION_PAUSED = "E103";
    string internal constant WHITELISTED_ONLY = "E104";

    string internal constant ADMIN_ADDRESS_CANNOT_BE_ZERO = "E201";
    string internal constant INVALID_REDEEM = "E202";
    string internal constant REDEEM_TOO_MUCH = "E203";
    string internal constant WITHDRAW_NOT_ALLOWED = "E204";
    string internal constant MARKET_NOT_LISTED = "E205";
    string internal constant INSUFFICIENT_LIQUIDITY = "E206";
    string internal constant INVALID_SENDER = "E207";
    string internal constant BORROW_CAP_REACHED = "E208";
    string internal constant BALANCE_OWED = "E209";
    string internal constant UNRELIABLE_LIQUIDATOR = "E210";
    string internal constant INVALID_DESTINATION = "E211";
    string internal constant CONTRACT_DOES_NOT_SUPPORT_INTERFACE = "E212";
    string internal constant INSUFFICIENT_STAKE = "E213";
    string internal constant INVALID_DURATION = "E214";
    string internal constant INVALID_PERIOD_RATE = "E215";
    string internal constant EB_TIER_LIMIT_REACHED = "E216";
    string internal constant INVALID_DEBT_REDEMPTION_RATE = "E217";
    string internal constant LQ_INVALID_SEIZE_DISTRIBUTION = "E218";
    string internal constant EB_TIER_DOES_NOT_EXIST = "E219";
    string internal constant EB_ZERO_TIER_CANNOT_BE_ENABLED = "E220";
    string internal constant EB_ALREADY_ACTIVATED_TIER = "E221";
    string internal constant EB_END_BLOCK_MUST_BE_LARGER_THAN_CURRENT = "E222";
    string internal constant EB_CANNOT_MINT_TOKEN_FOR_ACTIVATED_TIER = "E223";
    string internal constant EB_EMISSION_BOOST_IS_NOT_IN_RANGE = "E224";
    string internal constant TARGET_ADDRESS_CANNOT_BE_ZERO = "E225";
    string internal constant INSUFFICIENT_TOKEN_IN_VESTING_CONTRACT = "E226";
    string internal constant VESTING_SCHEDULE_ALREADY_EXISTS = "E227";
    string internal constant INSUFFICIENT_TOKENS_TO_CREATE_SCHEDULE = "E228";
    string internal constant NO_VESTING_SCHEDULE = "E229";
    string internal constant SCHEDULE_IS_IRREVOCABLE = "E230";
    string internal constant SCHEDULE_START_IS_ZERO = "E231";
    string internal constant MNT_AMOUNT_IS_ZERO = "E232";
    string internal constant RECEIVER_ALREADY_LISTED = "E233";
    string internal constant RECEIVER_ADDRESS_CANNOT_BE_ZERO = "E234";
    string internal constant CURRENCY_ADDRESS_CANNOT_BE_ZERO = "E235";
    string internal constant INCORRECT_AMOUNT = "E236";
    string internal constant RECEIVER_NOT_IN_APPROVED_LIST = "E237";
    string internal constant MEMBERSHIP_LIMIT = "E238";
    string internal constant MEMBER_NOT_EXIST = "E239";
    string internal constant MEMBER_ALREADY_ADDED = "E240";
    string internal constant MEMBERSHIP_LIMIT_REACHED = "E241";
    string internal constant REPORTED_PRICE_SHOULD_BE_GREATER_THAN_ZERO = "E242";
    string internal constant MTOKEN_ADDRESS_CANNOT_BE_ZERO = "E243";
    string internal constant TOKEN_ADDRESS_CANNOT_BE_ZERO = "E244";
    string internal constant REDEEM_TOKENS_OR_REDEEM_AMOUNT_MUST_BE_ZERO = "E245";
    string internal constant FL_TOKEN_IS_NOT_UNDERLYING = "E246";
    string internal constant FL_AMOUNT_IS_TOO_LARGE = "E247";
    string internal constant FL_CALLBACK_FAILED = "E248";
    string internal constant DD_UNSUPPORTED_TOKEN = "E249";
    string internal constant DD_MARKET_ADDRESS_IS_ZERO = "E250";
    string internal constant DD_ROUTER_ADDRESS_IS_ZERO = "E251";
    string internal constant DD_RECEIVER_ADDRESS_IS_ZERO = "E252";
    string internal constant DD_BOT_ADDRESS_IS_ZERO = "E253";
    string internal constant DD_MARKET_NOT_FOUND = "E254";
    string internal constant DD_ROUTER_NOT_FOUND = "E255";
    string internal constant DD_RECEIVER_NOT_FOUND = "E256";
    string internal constant DD_BOT_NOT_FOUND = "E257";
    string internal constant DD_ROUTER_ALREADY_SET = "E258";
    string internal constant DD_RECEIVER_ALREADY_SET = "E259";
    string internal constant DD_BOT_ALREADY_SET = "E260";
    string internal constant EB_MARKET_INDEX_IS_LESS_THAN_USER_INDEX = "E261";
    string internal constant MV_BLOCK_NOT_YET_MINED = "E262";
    string internal constant MV_SIGNATURE_EXPIRED = "E263";
    string internal constant MV_INVALID_NONCE = "E264";
    string internal constant DD_EXPIRED_DEADLINE = "E265";
    string internal constant LQ_INVALID_DRR_ARRAY = "E266";
    string internal constant LQ_INVALID_SEIZE_ARRAY = "E267";
    string internal constant LQ_INVALID_DEBT_REDEMPTION_RATE = "E268";
    string internal constant LQ_INVALID_SEIZE_INDEX = "E269";
    string internal constant LQ_DUPLICATE_SEIZE_INDEX = "E270";

    string internal constant INVALID_PRICE = "E301";
    string internal constant MARKET_NOT_FRESH = "E302";
    string internal constant BORROW_RATE_TOO_HIGH = "E303";
    string internal constant INSUFFICIENT_TOKEN_CASH = "E304";
    string internal constant INSUFFICIENT_TOKENS_FOR_RELEASE = "E305";
    string internal constant INSUFFICIENT_MNT_FOR_GRANT = "E306";
    string internal constant TOKEN_TRANSFER_IN_UNDERFLOW = "E307";
    string internal constant NOT_PARTICIPATING_IN_BUYBACK = "E308";
    string internal constant NOT_ENOUGH_PARTICIPATING_ACCOUNTS = "E309";
    string internal constant NOTHING_TO_DISTRIBUTE = "E310";
    string internal constant ALREADY_PARTICIPATING_IN_BUYBACK = "E311";
    string internal constant MNT_APPROVE_FAILS = "E312";
    string internal constant TOO_EARLY_TO_DRIP = "E313";
    string internal constant INSUFFICIENT_SHORTFALL = "E315";
    string internal constant HEALTHY_FACTOR_NOT_IN_RANGE = "E316";
    string internal constant BUYBACK_DRIPS_ALREADY_HAPPENED = "E317";
    string internal constant EB_INDEX_SHOULD_BE_GREATER_THAN_INITIAL = "E318";
    string internal constant NO_VESTING_SCHEDULES = "E319";
    string internal constant INSUFFICIENT_UNRELEASED_TOKENS = "E320";
    string internal constant INSUFFICIENT_FUNDS = "E321";
    string internal constant ORACLE_PRICE_EXPIRED = "E322";
    string internal constant TOKEN_NOT_FOUND = "E323";
    string internal constant RECEIVED_PRICE_HAS_INVALID_ROUND = "E324";
    string internal constant FL_PULL_AMOUNT_IS_TOO_LOW = "E325";
    string internal constant INSUFFICIENT_TOTAL_PROTOCOL_INTEREST = "E326";
    string internal constant BB_ACCOUNT_RECENTLY_VOTED = "E327";
    string internal constant ZERO_EXCHANGE_RATE = "E401";
    string internal constant SECOND_INITIALIZATION = "E402";
    string internal constant MARKET_ALREADY_LISTED = "E403";
    string internal constant IDENTICAL_VALUE = "E404";
    string internal constant ZERO_ADDRESS = "E405";
    string internal constant NEW_ORACLE_MISMATCH = "E406";
    string internal constant EC_INVALID_PROVIDER_REPRESENTATIVE = "E407";
    string internal constant EC_PROVIDER_CANT_BE_REPRESENTATIVE = "E408";
    string internal constant OR_ORACLE_ADDRESS_CANNOT_BE_ZERO = "E409";
    string internal constant OR_UNDERLYING_TOKENS_DECIMALS_SHOULD_BE_GREATER_THAN_ZERO = "E410";
    string internal constant OR_REPORTER_MULTIPLIER_SHOULD_BE_GREATER_THAN_ZERO = "E411";
    string internal constant CONTRACT_ALREADY_SET = "E412";
    string internal constant INVALID_TOKEN = "E413";
    string internal constant INVALID_PROTOCOL_INTEREST_FACTOR_MANTISSA = "E414";
    string internal constant INVALID_REDUCE_AMOUNT = "E415";
    string internal constant LIQUIDATION_FEE_MANTISSA_SHOULD_BE_GREATER_THAN_ZERO = "E416";
    string internal constant INVALID_UTILISATION_FACTOR_MANTISSA = "E417";
    string internal constant INVALID_MTOKENS_OR_BORROW_CAPS = "E418";
    string internal constant FL_PARAM_IS_TOO_LARGE = "E419";
    string internal constant MNT_INVALID_NONVOTING_PERIOD = "E420";
    string internal constant INPUT_ARRAY_LENGTHS_ARE_NOT_EQUAL = "E421";
    string internal constant EC_INVALID_BOOSTS = "E422";
    string internal constant EC_ACCOUNT_IS_ALREADY_LIQUIDITY_PROVIDER = "E423";
    string internal constant EC_ACCOUNT_HAS_NO_AGREEMENT = "E424";
    string internal constant OR_TIMESTAMP_THRESHOLD_SHOULD_BE_GREATER_THAN_ZERO = "E425";
    string internal constant OR_UNDERLYING_TOKENS_DECIMALS_TOO_BIG = "E426";
    string internal constant OR_REPORTER_MULTIPLIER_TOO_BIG = "E427";
    string internal constant SHOULD_HAVE_REVOCABLE_SCHEDULE = "E428";
    string internal constant MEMBER_NOT_IN_DELAY_LIST = "E429";
    string internal constant DELAY_LIST_LIMIT = "E430";
}// BSD-3-Clause
pragma solidity 0.8.9;



contract MToken is MTokenInterface, MTokenStorage {

    using SafeERC20 for IERC20;
    using SafeCast for uint256;

    function initialize(
        address admin_,
        SupervisorInterface supervisor_,
        InterestRateModel interestRateModel_,
        uint256 initialExchangeRateMantissa_,
        string memory name_,
        string memory symbol_,
        uint8 decimals_,
        IERC20 underlying_
    ) external {

        require(accrualBlockNumber == 0 && borrowIndex == 0, ErrorCodes.SECOND_INITIALIZATION);

        require(initialExchangeRateMantissa_ > 0, ErrorCodes.ZERO_EXCHANGE_RATE);
        initialExchangeRateMantissa = initialExchangeRateMantissa_;

        _setSupervisor(supervisor_);

        accrualBlockNumber = getBlockNumber();
        borrowIndex = EXP_SCALE; // = 1e18

        setInterestRateModelFresh(interestRateModel_);

        _grantRole(DEFAULT_ADMIN_ROLE, admin_);
        _grantRole(TIMELOCK, admin_);

        underlying = underlying_;
        name = name_;
        symbol = symbol_;
        decimals = decimals_;

        maxFlashLoanShare = 0.1e18; // 10%
        flashLoanFeeShare = 0.0005e18; // 0.05%
    }

    function totalSupply() external view override returns (uint256) {

        return totalTokenSupply;
    }

    function transferTokens(
        address spender,
        address src,
        address dst,
        uint256 tokens
    ) internal {

        require(src != dst, ErrorCodes.INVALID_DESTINATION);

        supervisor.beforeTransfer(address(this), src, dst, tokens);

        uint256 startingAllowance = 0;
        if (spender == src) {
            startingAllowance = type(uint256).max;
        } else {
            startingAllowance = transferAllowances[src][spender];
        }


        accountTokens[src] -= tokens;
        accountTokens[dst] += tokens;

        if (startingAllowance != type(uint256).max) {
            transferAllowances[src][spender] = startingAllowance - tokens;
        }

        emit Transfer(src, dst, tokens);
    }

    function transfer(address dst, uint256 amount) external override nonReentrant returns (bool) {

        transferTokens(msg.sender, msg.sender, dst, amount);
        return true;
    }

    function transferFrom(
        address src,
        address dst,
        uint256 amount
    ) external override nonReentrant returns (bool) {

        transferTokens(msg.sender, src, dst, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {

        address src = msg.sender;
        transferAllowances[src][spender] = amount;
        emit Approval(src, spender, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {

        return transferAllowances[owner][spender];
    }

    function balanceOf(address owner) external view override returns (uint256) {

        return accountTokens[owner];
    }

    function balanceOfUnderlying(address owner) external override returns (uint256) {

        return (accountTokens[owner] * exchangeRateCurrent()) / EXP_SCALE;
    }

    function getAccountSnapshot(address account)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        uint256 mTokenBalance = accountTokens[account];
        uint256 borrowBalance = borrowBalanceStoredInternal(account);
        uint256 exchangeRateMantissa = exchangeRateStoredInternal();
        return (mTokenBalance, borrowBalance, exchangeRateMantissa);
    }

    function getBlockNumber() internal view virtual returns (uint256) {

        return block.number;
    }

    function borrowRatePerBlock() external view override returns (uint256) {

        return interestRateModel.getBorrowRate(getCashPrior(), totalBorrows, totalProtocolInterest);
    }

    function supplyRatePerBlock() external view override returns (uint256) {

        return
            interestRateModel.getSupplyRate(
                getCashPrior(),
                totalBorrows,
                totalProtocolInterest,
                protocolInterestFactorMantissa
            );
    }

    function totalBorrowsCurrent() external override nonReentrant returns (uint256) {

        accrueInterest();
        return totalBorrows;
    }

    function borrowBalanceCurrent(address account) external override nonReentrant returns (uint256) {

        accrueInterest();
        return borrowBalanceStored(account);
    }

    function borrowBalanceStored(address account) public view override returns (uint256) {

        return borrowBalanceStoredInternal(account);
    }

    function borrowBalanceStoredInternal(address account) internal view returns (uint256) {

        BorrowSnapshot storage borrowSnapshot = accountBorrows[account];

        if (borrowSnapshot.principal == 0) return 0;

        return (borrowSnapshot.principal * borrowIndex) / borrowSnapshot.interestIndex;
    }

    function exchangeRateCurrent() public override nonReentrant returns (uint256) {

        accrueInterest();
        return exchangeRateStored();
    }

    function exchangeRateStored() public view override returns (uint256) {

        return exchangeRateStoredInternal();
    }

    function exchangeRateStoredInternal() internal view virtual returns (uint256) {

        if (totalTokenSupply <= 0) {
            return initialExchangeRateMantissa;
        } else {
            return ((getCashPrior() + totalBorrows - totalProtocolInterest) * EXP_SCALE) / totalTokenSupply;
        }
    }

    function getCash() external view override returns (uint256) {

        return getCashPrior();
    }

    function accrueInterest() public virtual override {

        uint256 currentBlockNumber = getBlockNumber();
        uint256 accrualBlockNumberPrior = accrualBlockNumber;

        if (accrualBlockNumberPrior == currentBlockNumber) return;

        uint256 cashPrior = getCashPrior();
        uint256 borrowIndexPrior = borrowIndex;

        uint256 borrowRateMantissa = interestRateModel.getBorrowRate(cashPrior, totalBorrows, totalProtocolInterest);
        require(borrowRateMantissa <= borrowRateMaxMantissa, ErrorCodes.BORROW_RATE_TOO_HIGH);

        uint256 blockDelta = currentBlockNumber - accrualBlockNumberPrior;

        uint256 simpleInterestFactor = borrowRateMantissa * blockDelta;
        uint256 interestAccumulated = (totalBorrows * simpleInterestFactor) / EXP_SCALE;
        totalBorrows += interestAccumulated;
        totalProtocolInterest += (interestAccumulated * protocolInterestFactorMantissa) / EXP_SCALE;
        borrowIndex = borrowIndexPrior + (borrowIndexPrior * simpleInterestFactor) / EXP_SCALE;

        accrualBlockNumber = currentBlockNumber;

        emit AccrueInterest(cashPrior, interestAccumulated, borrowIndex, totalBorrows, totalProtocolInterest);
    }

    function lend(uint256 lendAmount) external override {

        accrueInterest();
        lendFresh(msg.sender, lendAmount);
    }

    function lendFresh(address lender, uint256 lendAmount) internal nonReentrant returns (uint256 actualLendAmount) {

        uint256 wrapBalance = accountTokens[lender];
        supervisor.beforeLend(address(this), lender, wrapBalance);

        require(accrualBlockNumber == getBlockNumber(), ErrorCodes.MARKET_NOT_FRESH);

        uint256 exchangeRateMantissa = exchangeRateStoredInternal();

        actualLendAmount = doTransferIn(lender, lendAmount);

        uint256 lendTokens = (actualLendAmount * EXP_SCALE) / exchangeRateMantissa;

        uint256 newTotalTokenSupply = totalTokenSupply + lendTokens;
        totalTokenSupply = newTotalTokenSupply;
        accountTokens[lender] = wrapBalance + lendTokens;

        emit Lend(lender, actualLendAmount, lendTokens, newTotalTokenSupply);
        emit Transfer(address(this), lender, lendTokens);
    }

    function redeem(uint256 redeemTokens) external override {

        accrueInterest();
        redeemFresh(msg.sender, redeemTokens, 0);
    }

    function redeemUnderlying(uint256 redeemAmount) external override {

        accrueInterest();
        redeemFresh(msg.sender, 0, redeemAmount);
    }

    function redeemFresh(
        address redeemer,
        uint256 redeemTokens,
        uint256 redeemAmount
    ) internal nonReentrant {

        require(redeemTokens == 0 || redeemAmount == 0, ErrorCodes.REDEEM_TOKENS_OR_REDEEM_AMOUNT_MUST_BE_ZERO);

        uint256 exchangeRateMantissa = exchangeRateStoredInternal();

        if (redeemTokens > 0) {
            redeemAmount = (redeemTokens * exchangeRateMantissa) / EXP_SCALE;
        } else {
            redeemTokens = (redeemAmount * EXP_SCALE) / exchangeRateMantissa;
        }

        supervisor.beforeRedeem(address(this), redeemer, redeemTokens);

        require(accrualBlockNumber == getBlockNumber(), ErrorCodes.MARKET_NOT_FRESH);
        require(accountTokens[redeemer] >= redeemTokens, ErrorCodes.REDEEM_TOO_MUCH);
        require(totalTokenSupply >= redeemTokens, ErrorCodes.INVALID_REDEEM);

        uint256 accountTokensNew = accountTokens[redeemer] - redeemTokens;
        uint256 totalSupplyNew = totalTokenSupply - redeemTokens;

        require(getCashPrior() >= redeemAmount, ErrorCodes.INSUFFICIENT_TOKEN_CASH);

        totalTokenSupply = totalSupplyNew;
        accountTokens[redeemer] = accountTokensNew;

        emit Transfer(redeemer, address(this), redeemTokens);
        emit Redeem(redeemer, redeemAmount, redeemTokens, totalSupplyNew);

        doTransferOut(redeemer, redeemAmount);

        supervisor.redeemVerify(redeemAmount, redeemTokens);
    }


    function borrow(uint256 borrowAmount) external override nonReentrant {

        accrueInterest();

        address borrower = msg.sender;

        supervisor.beforeBorrow(address(this), borrower, borrowAmount);

        require(getCashPrior() >= borrowAmount, ErrorCodes.INSUFFICIENT_TOKEN_CASH);

        uint256 accountBorrowsNew = borrowBalanceStoredInternal(borrower) + borrowAmount;
        uint256 totalBorrowsNew = totalBorrows + borrowAmount;

        accountBorrows[borrower].principal = accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = totalBorrowsNew;

        emit Borrow(borrower, borrowAmount, accountBorrowsNew, totalBorrowsNew);

        doTransferOut(borrower, borrowAmount);
    }

    function repayBorrow(uint256 repayAmount) external override {

        accrueInterest();
        repayBorrowFresh(msg.sender, msg.sender, repayAmount);
    }

    function repayBorrowBehalf(address borrower, uint256 repayAmount) external override {

        accrueInterest();
        repayBorrowFresh(msg.sender, borrower, repayAmount);
    }

    function repayBorrowFresh(
        address payer,
        address borrower,
        uint256 repayAmount
    ) internal nonReentrant returns (uint256 actualRepayAmount) {

        supervisor.beforeRepayBorrow(address(this), borrower);

        require(accrualBlockNumber == getBlockNumber(), ErrorCodes.MARKET_NOT_FRESH);

        uint256 borrowBalance = borrowBalanceStoredInternal(borrower);

        if (repayAmount == type(uint256).max) {
            repayAmount = borrowBalance;
        }


        actualRepayAmount = doTransferIn(payer, repayAmount);

        uint256 accountBorrowsNew = borrowBalance - actualRepayAmount;
        uint256 totalBorrowsNew = totalBorrows - actualRepayAmount;

        accountBorrows[borrower].principal = accountBorrowsNew;
        accountBorrows[borrower].interestIndex = borrowIndex;
        totalBorrows = totalBorrowsNew;

        emit RepayBorrow(payer, borrower, actualRepayAmount, accountBorrowsNew, totalBorrowsNew);
    }

    function autoLiquidationRepayBorrow(address borrower_, uint256 repayAmount_) external override nonReentrant {

        supervisor.beforeAutoLiquidationRepay(msg.sender, borrower_, address(this), borrowIndex.toUint224());

        require(accrualBlockNumber == getBlockNumber(), ErrorCodes.MARKET_NOT_FRESH);
        require(totalProtocolInterest >= repayAmount_, ErrorCodes.INSUFFICIENT_TOTAL_PROTOCOL_INTEREST);

        uint256 borrowBalance = borrowBalanceStoredInternal(borrower_);

        accountBorrows[borrower_].principal = borrowBalance - repayAmount_;
        accountBorrows[borrower_].interestIndex = borrowIndex;
        totalBorrows -= repayAmount_;
        totalProtocolInterest -= repayAmount_;

        emit AutoLiquidationRepayBorrow(
            borrower_,
            repayAmount_,
            accountBorrows[borrower_].principal,
            totalBorrows,
            totalProtocolInterest
        );
    }

    function sweepToken(IERC20 token, address receiver_) external override onlyRole(DEFAULT_ADMIN_ROLE) {

        require(token != underlying, ErrorCodes.INVALID_TOKEN);
        uint256 balance = token.balanceOf(address(this));
        token.safeTransfer(receiver_, balance);
    }

    function autoLiquidationSeize(
        address borrower_,
        uint256 seizeUnderlyingAmount_,
        bool isLoanInsignificant_,
        address receiver_
    ) external nonReentrant {

        supervisor.beforeAutoLiquidationSeize(address(this), msg.sender, borrower_);

        uint256 exchangeRateMantissa = exchangeRateStoredInternal();

        uint256 borrowerSeizeTokens;

        if (seizeUnderlyingAmount_ == type(uint256).max) {
            borrowerSeizeTokens = accountTokens[borrower_];
            seizeUnderlyingAmount_ = (borrowerSeizeTokens * exchangeRateMantissa) / EXP_SCALE;
        } else {
            borrowerSeizeTokens = (seizeUnderlyingAmount_ * EXP_SCALE) / exchangeRateMantissa;
        }

        uint256 borrowerTokensNew = accountTokens[borrower_] - borrowerSeizeTokens;
        uint256 totalSupplyNew = totalTokenSupply - borrowerSeizeTokens;


        accountTokens[borrower_] = borrowerTokensNew;
        totalTokenSupply = totalSupplyNew;

        if (isLoanInsignificant_) {
            totalProtocolInterest = totalProtocolInterest + seizeUnderlyingAmount_;
            emit ProtocolInterestAdded(msg.sender, seizeUnderlyingAmount_, totalProtocolInterest);
        } else {
            doTransferOut(receiver_, seizeUnderlyingAmount_);
        }

        emit Seize(
            borrower_,
            receiver_,
            borrowerSeizeTokens,
            borrowerTokensNew,
            totalSupplyNew,
            seizeUnderlyingAmount_
        );
    }


    function maxFlashLoan(address token) external view override returns (uint256) {

        return token == address(underlying) ? _maxFlashLoan() : 0;
    }

    function _maxFlashLoan() internal view returns (uint256) {

        return (getCashPrior() * maxFlashLoanShare) / EXP_SCALE;
    }

    function flashFee(address token, uint256 amount) external view override returns (uint256) {

        require(token == address(underlying), ErrorCodes.FL_TOKEN_IS_NOT_UNDERLYING);
        return _flashFee(amount);
    }

    function _flashFee(uint256 amount) internal view returns (uint256) {

        return (amount * flashLoanFeeShare) / EXP_SCALE;
    }

    function flashLoan(
        IERC3156FlashBorrower receiver,
        address token,
        uint256 amount,
        bytes calldata data
    ) external override nonReentrant returns (bool) {

        require(token == address(underlying), ErrorCodes.FL_TOKEN_IS_NOT_UNDERLYING);
        require(amount <= _maxFlashLoan(), ErrorCodes.FL_AMOUNT_IS_TOO_LARGE);

        accrueInterest();

        uint256 fee = _flashFee(amount);
        supervisor.beforeFlashLoan(address(this), address(receiver), amount, fee);

        underlying.safeTransfer(address(receiver), amount);
        require(
            receiver.onFlashLoan(msg.sender, token, amount, fee, data) == FLASH_LOAN_SUCCESS,
            ErrorCodes.FL_CALLBACK_FAILED
        );

        uint256 actualPullAmount = doTransferIn(address(receiver), amount + fee);
        require(actualPullAmount >= amount + fee, ErrorCodes.FL_PULL_AMOUNT_IS_TOO_LOW);

        totalProtocolInterest += fee;

        emit FlashLoanExecuted(address(receiver), amount, fee);

        return true;
    }


    function setSupervisor(SupervisorInterface newSupervisor) external override onlyRole(DEFAULT_ADMIN_ROLE) {

        _setSupervisor(newSupervisor);
    }

    function _setSupervisor(SupervisorInterface newSupervisor) internal {

        require(
            newSupervisor.supportsInterface(type(SupervisorInterface).interfaceId),
            ErrorCodes.CONTRACT_DOES_NOT_SUPPORT_INTERFACE
        );

        SupervisorInterface oldSupervisor = supervisor;
        supervisor = newSupervisor;
        emit NewSupervisor(oldSupervisor, newSupervisor);
    }

    function setProtocolInterestFactor(uint256 newProtocolInterestFactorMantissa)
        external
        override
        onlyRole(TIMELOCK)
        nonReentrant
    {

        require(
            newProtocolInterestFactorMantissa <= protocolInterestFactorMaxMantissa,
            ErrorCodes.INVALID_PROTOCOL_INTEREST_FACTOR_MANTISSA
        );

        accrueInterest();

        uint256 oldProtocolInterestFactorMantissa = protocolInterestFactorMantissa;
        protocolInterestFactorMantissa = newProtocolInterestFactorMantissa;

        emit NewProtocolInterestFactor(oldProtocolInterestFactorMantissa, newProtocolInterestFactorMantissa);
    }

    function addProtocolInterest(uint256 addAmount_) external override nonReentrant {

        accrueInterest();
        addProtocolInterestInternal(msg.sender, addAmount_);
    }

    function addProtocolInterestBehalf(address payer_, uint256 addAmount_) external override nonReentrant {

        supervisor.isLiquidator(msg.sender);
        addProtocolInterestInternal(payer_, addAmount_);
    }

    function addProtocolInterestInternal(address payer_, uint256 addAmount_) internal {

        require(accrualBlockNumber == getBlockNumber(), ErrorCodes.MARKET_NOT_FRESH);

        uint256 actualAddAmount = doTransferIn(payer_, addAmount_);
        uint256 totalProtocolInterestNew = totalProtocolInterest + actualAddAmount;

        totalProtocolInterest = totalProtocolInterestNew;

        emit ProtocolInterestAdded(payer_, actualAddAmount, totalProtocolInterestNew);
    }

    function reduceProtocolInterest(uint256 reduceAmount, address receiver_)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
        nonReentrant
    {

        accrueInterest();

        require(getCashPrior() >= reduceAmount, ErrorCodes.INSUFFICIENT_TOKEN_CASH);
        require(totalProtocolInterest >= reduceAmount, ErrorCodes.INVALID_REDUCE_AMOUNT);


        uint256 totalProtocolInterestNew = totalProtocolInterest - reduceAmount;
        totalProtocolInterest = totalProtocolInterestNew;

        doTransferOut(receiver_, reduceAmount);

        emit ProtocolInterestReduced(receiver_, reduceAmount, totalProtocolInterestNew);
    }

    function setInterestRateModel(InterestRateModel newInterestRateModel)
        external
        override
        onlyRole(DEFAULT_ADMIN_ROLE)
    {

        accrueInterest();
        setInterestRateModelFresh(newInterestRateModel);
    }

    function setInterestRateModelFresh(InterestRateModel newInterestRateModel) internal {

        require(
            newInterestRateModel.supportsInterface(type(InterestRateModel).interfaceId),
            ErrorCodes.CONTRACT_DOES_NOT_SUPPORT_INTERFACE
        );
        require(accrualBlockNumber == getBlockNumber(), ErrorCodes.MARKET_NOT_FRESH);

        InterestRateModel oldInterestRateModel = interestRateModel;
        interestRateModel = newInterestRateModel;

        emit NewMarketInterestRateModel(oldInterestRateModel, newInterestRateModel);
    }

    function setFlashLoanMaxShare(uint256 newMax) external onlyRole(DEFAULT_ADMIN_ROLE) {

        require(newMax <= EXP_SCALE, ErrorCodes.FL_PARAM_IS_TOO_LARGE);
        emit NewFlashLoanMaxShare(maxFlashLoanShare, newMax);
        maxFlashLoanShare = newMax;
    }

    function setFlashLoanFeeShare(uint256 newFee) external onlyRole(TIMELOCK) {

        require(newFee <= EXP_SCALE, ErrorCodes.FL_PARAM_IS_TOO_LARGE);
        emit NewFlashLoanFee(flashLoanFeeShare, newFee);
        flashLoanFeeShare = newFee;
    }


    function getCashPrior() internal view virtual returns (uint256) {

        return underlying.balanceOf(address(this));
    }

    function doTransferIn(address from, uint256 amount) internal virtual returns (uint256) {

        uint256 balanceBefore = underlying.balanceOf(address(this));
        underlying.safeTransferFrom(from, address(this), amount);

        uint256 balanceAfter = underlying.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, ErrorCodes.TOKEN_TRANSFER_IN_UNDERFLOW);
        return balanceAfter - balanceBefore;
    }

    function doTransferOut(address to, uint256 amount) internal virtual {

        underlying.safeTransfer(to, amount);
    }

    function delegateMntLikeTo(address mntLikeDelegatee) external onlyRole(DEFAULT_ADMIN_ROLE) {

        MntLike(address(underlying)).delegate(mntLikeDelegatee);
    }

    function supportsInterface(bytes4 interfaceId) public view override(AccessControl, IERC165) returns (bool) {

        return
            interfaceId == type(MTokenInterface).interfaceId ||
            interfaceId == type(IERC20).interfaceId ||
            interfaceId == type(IERC3156FlashLender).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}