
pragma solidity ^0.7.0;

abstract contract ReentrancyGuard {

    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;

        _;

        _status = _NOT_ENTERED;
    }
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;

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

pragma solidity ^0.7.0;


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
}// MIT

pragma solidity >=0.6.0 <0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}// MIT

pragma solidity ^0.7.0;

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
}// MIT

pragma solidity ^0.7.0;


abstract contract Pausable is Context {
    event Paused(address account);

    event Unpaused(address account);

    bool private _paused;

    constructor () {
        _paused = false;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    modifier whenNotPaused() {
        require(!paused(), "Pausable: paused");
        _;
    }

    modifier whenPaused() {
        require(paused(), "Pausable: not paused");
        _;
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}// LGPL-3.0-or-later

pragma solidity 0.7.6;

enum PaymentMethod {
    ETHETH,
    ETHTKN,
    TKNETH,
    TKNTKN
}

enum Entity {ISSUER, HOLDER, POOL}

enum VoucherState {FINAL, CANCEL_FAULT, COMPLAIN, EXPIRE, REFUND, REDEEM, COMMIT}

enum Condition {NOT_SET, BALANCE, OWNERSHIP} //Describes what kind of condition must be met for a conditional commit

struct ConditionalCommitInfo {
    uint256 conditionalTokenId;
    uint256 threshold;
    Condition condition;
    address gateAddress;
    bool registerConditionalCommit;
}

uint8 constant ONE = 1;

struct VoucherDetails {
    uint256 tokenIdSupply;
    uint256 tokenIdVoucher;
    address issuer;
    address holder;
    uint256 price;
    uint256 depositSe;
    uint256 depositBu;
    PaymentMethod paymentMethod;
    VoucherStatus currStatus;
}

struct VoucherStatus {
    address seller;
    uint8 status;
    bool isPaymentReleased;
    bool isDepositsReleased;
    DepositsReleased depositReleased;
    uint256 complainPeriodStart;
    uint256 cancelFaultPeriodStart;
}

struct DepositsReleased {
    uint8 status;
    uint248 releasedAmount;
}

function isStateCommitted(uint8 _status) pure returns (bool) {
    return _status == determineStatus(0, VoucherState.COMMIT);
}

function isStateRedemptionSigned(uint8 _status)
    pure
    returns (bool)
{
    return _status == determineStatus(determineStatus(0, VoucherState.COMMIT), VoucherState.REDEEM);
}

function isStateRefunded(uint8 _status) pure returns (bool) {
    return _status == determineStatus(determineStatus(0, VoucherState.COMMIT), VoucherState.REFUND);
}

function isStateExpired(uint8 _status) pure returns (bool) {
    return _status == determineStatus(determineStatus(0, VoucherState.COMMIT), VoucherState.EXPIRE);
}

function isStatus(uint8 _status, VoucherState _idx) pure returns (bool) {
    return (_status >> uint8(_idx)) & ONE == 1;
}

function determineStatus(uint8 _status, VoucherState _changeIdx)
    pure
    returns (uint8)
{
    return _status | (ONE << uint8(_changeIdx));
}// LGPL-3.0-or-later
pragma solidity 0.7.6;


interface IVoucherKernel {

    function pause() external;


    function unpause() external;


    function createTokenSupplyId(
        address _seller,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _price,
        uint256 _depositSe,
        uint256 _depositBu,
        uint256 _quantity
    ) external returns (uint256);


    function createPaymentMethod(
        uint256 _tokenIdSupply,
        PaymentMethod _paymentMethod,
        address _tokenPrice,
        address _tokenDeposits
    ) external;


    function setPaymentReleased(uint256 _tokenIdVoucher) external;


    function setDepositsReleased(
        uint256 _tokenIdVoucher,
        Entity _to,
        uint256 _amount
    ) external;


    function isDepositReleased(uint256 _tokenIdVoucher, Entity _to)
        external
        returns (bool);


    function redeem(uint256 _tokenIdVoucher, address _messageSender) external;


    function refund(uint256 _tokenIdVoucher, address _messageSender) external;


    function complain(uint256 _tokenIdVoucher, address _messageSender) external;


    function cancelOrFault(uint256 _tokenIdVoucher, address _messageSender)
        external;


    function cancelOrFaultVoucherSet(uint256 _tokenIdSupply, address _issuer)
        external
        returns (uint256);


    function fillOrder(
        uint256 _tokenIdSupply,
        address _issuer,
        address _holder,
        PaymentMethod _paymentMethod
    ) external;


    function triggerExpiration(uint256 _tokenIdVoucher) external;


    function triggerFinalizeVoucher(uint256 _tokenIdVoucher) external;


    function setSupplyHolderOnTransfer(
        uint256 _tokenIdSupply,
        address _newSeller
    ) external;


    function setCancelFaultPeriod(uint256 _cancelFaultPeriod) external;


    function setBosonRouterAddress(address _bosonRouterAddress) external;


    function setCashierAddress(address _cashierAddress) external;


    function setVoucherTokenAddress(address _voucherTokenAddress) external;


    function setVoucherSetTokenAddress(address _voucherSetTokenAddress)
        external;


    function setComplainPeriod(uint256 _complainPeriod) external;


    function getPromiseKey(uint256 _idx) external view returns (bytes32);


    function getVoucherPriceToken(uint256 _tokenIdSupply)
        external
        view
        returns (address);


    function getVoucherDepositToken(uint256 _tokenIdSupply)
        external
        view
        returns (address);


    function getBuyerOrderCosts(uint256 _tokenIdSupply)
        external
        view
        returns (uint256, uint256);


    function getSellerDeposit(uint256 _tokenIdSupply)
        external
        view
        returns (uint256);


    function getIdSupplyFromVoucher(uint256 _tokenIdVoucher)
        external
        pure
        returns (uint256);


    function getPromiseIdFromVoucherId(uint256 _tokenIdVoucher)
        external
        view
        returns (bytes32);


    function getOrderCosts(uint256 _tokenIdSupply)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        );


    function getRemQtyForSupply(uint256 _tokenSupplyId, address _owner)
        external
        view
        returns (uint256);


    function getVoucherPaymentMethod(uint256 _tokenIdSupply)
        external
        view
        returns (PaymentMethod);


    function getVoucherStatus(uint256 _tokenIdVoucher)
        external
        view
        returns (
            uint8,
            bool,
            bool,
            uint256,
            uint256
        );


    function getSupplyHolder(uint256 _tokenIdSupply)
        external
        view
        returns (address);


    function getVoucherSeller(uint256 _voucherTokenId)
        external
        view
        returns (address);


    function getVoucherHolder(uint256 _tokenIdVoucher)
        external
        view
        returns (address);


    function isInValidityPeriod(uint256 _tokenIdVoucher)
        external
        view
        returns (bool);


    function isVoucherTransferable(uint256 _tokenIdVoucher)
        external
        view
        returns (bool);


    function getBosonRouterAddress() external view returns (address);


    function getCashierAddress() external view returns (address);


    function getTokenNonce(address _seller) external view returns (uint256);


    function getTypeId() external view returns (uint256);


    function getComplainPeriod() external view returns (uint256);


    function getCancelFaultPeriod() external view returns (uint256);


    function getPromiseData(bytes32 _promiseKey)
        external
        view
        returns (
            bytes32,
            uint256,
            uint256,
            uint256,
            uint256
        );


    function getPromiseIdFromSupplyId(uint256 _tokenIdSupply)
        external
        view
        returns (bytes32);


    function getVoucherTokenAddress() external view returns (address);


    function getVoucherSetTokenAddress() external view returns (address);

}// LGPL-3.0-or-later

pragma solidity 0.7.6;


interface ICashier {

    function pause() external;


    function unpause() external;


    function canUnpause() external view returns (bool);


    function withdraw(uint256 _tokenIdVoucher) external;


    function withdrawSingle(uint256 _tokenIdVoucher, Entity _to) external;


    function withdrawDepositsSe(
        uint256 _tokenIdSupply,
        uint256 _burnedQty,
        address payable _messageSender
    ) external;


    function getEscrowAmount(address _account) external view returns (uint256);


    function addEscrowAmount(address _account) external payable;


    function addEscrowTokensAmount(
        address _token,
        address _account,
        uint256 _newAmount
    ) external;


    function onVoucherTransfer(
        address _from,
        address _to,
        uint256 _tokenIdVoucher
    ) external;


    function onVoucherSetTransfer(
        address _from,
        address _to,
        uint256 _tokenSupplyId,
        uint256 _value
    ) external;


    function getVoucherKernelAddress() external view returns (address);


    function getBosonRouterAddress() external view returns (address);


    function getVoucherTokenAddress() external view returns (address);


    function getVoucherSetTokenAddress() external view returns (address);


    function isDisasterStateSet() external view returns (bool);


    function getEscrowTokensAmount(address _token, address _account)
        external
        view
        returns (uint256);


    function setBosonRouterAddress(address _bosonRouterAddress) external;


    function setVoucherKernelAddress(address _voucherKernelAddress) external;


    function setVoucherTokenAddress(address _voucherTokenAddress) external;


    function setVoucherSetTokenAddress(address _voucherSetTokenAddress)
        external;

}// LGPL-3.0-or-later
pragma solidity 0.7.6;



contract Cashier is ICashier, ReentrancyGuard, Ownable, Pausable {

    using SafeERC20 for IERC20;
    using Address for address payable;
    using SafeMath for uint256;

    address private voucherKernel;
    address private bosonRouterAddress;
    address private voucherSetTokenAddress;   //ERC1155 contract representing voucher sets    
    address private voucherTokenAddress;     //ERC721 contract representing vouchers;
    bool private disasterState;

    enum PaymentType {PAYMENT, DEPOSIT_SELLER, DEPOSIT_BUYER}
    enum Role {ISSUER, HOLDER}

    mapping(address => uint256) private escrow; // both types of deposits AND payments >> can be released token-by-token if checks pass
    mapping(address => mapping(address => uint256)) private escrowTokens; //token address => mgsSender => amount

    uint256 internal constant CANCELFAULT_SPLIT = 2; //for POC purposes, this is hardcoded; e.g. each party gets depositSe / 2

    event LogBosonRouterSet(address _newBosonRouter, address _triggeredBy);

    event LogVoucherTokenContractSet(address _newTokenContract, address _triggeredBy);

    event LogVoucherSetTokenContractSet(address _newTokenContract, address _triggeredBy);

    event LogVoucherKernelSet(address _newVoucherKernel, address _triggeredBy);

    event LogWithdrawal(address _caller, address _payee, uint256 _payment);

    event LogAmountDistribution(
        uint256 indexed _tokenIdVoucher,
        address _to,
        uint256 _payment,
        PaymentType _type
    );

    event LogDisasterStateSet(bool _disasterState, address _triggeredBy);
    event LogWithdrawEthOnDisaster(uint256 _amount, address _triggeredBy);
    event LogWithdrawTokensOnDisaster(
        uint256 _amount,
        address _tokenAddress,
        address _triggeredBy
    );

    modifier onlyFromRouter() {

        require(msg.sender == bosonRouterAddress, "UNAUTHORIZED_BR");
        _;
    }

    modifier notZeroAddress(address _addressToCheck) {

        require(_addressToCheck != address(0), "0A");
        _;
    }

    modifier onlyVoucherTokenContract() {

        require(msg.sender == voucherTokenAddress, "UNAUTHORIZED_VOUCHER_TOKEN_ADDRESS"); // Unauthorized token address
        _;
    }

    modifier onlyVoucherSetTokenContract() {

        require(msg.sender == voucherSetTokenAddress, "UNAUTHORIZED_VOUCHER_SET_TOKEN_ADDRESS"); // Unauthorized token address
        _;
    }

    constructor(address _bosonRouterAddress, address _voucherKernel, address _voucherSetTokenAddress, address _voucherTokenAddress) 
        notZeroAddress(_bosonRouterAddress)
        notZeroAddress(_voucherKernel)
        notZeroAddress(_voucherSetTokenAddress)
        notZeroAddress(_voucherTokenAddress)
    {
        bosonRouterAddress = _bosonRouterAddress;
        voucherKernel = _voucherKernel;
        voucherSetTokenAddress = _voucherSetTokenAddress;
        voucherTokenAddress = _voucherTokenAddress;
        emit LogBosonRouterSet(_bosonRouterAddress, msg.sender);
        emit LogVoucherKernelSet(_voucherKernel, msg.sender);
        emit LogVoucherSetTokenContractSet(_voucherSetTokenAddress, msg.sender);
        emit LogVoucherTokenContractSet(_voucherTokenAddress, msg.sender);
    }

    function pause() external override onlyFromRouter {

        _pause();
    }

    function unpause() external override onlyFromRouter {

        _unpause();
    }

    function canUnpause() external view override returns (bool) {

        return !disasterState;
    }

    function setDisasterState() external onlyOwner whenPaused {

        require(!disasterState, "Disaster state is already set");
        disasterState = true;
        emit LogDisasterStateSet(disasterState, msg.sender);
    }

    function withdrawEthOnDisaster() external whenPaused nonReentrant {

        require(disasterState, "Owner did not allow manual withdraw");

        uint256 amount = escrow[msg.sender];

        require(amount > 0, "ESCROW_EMPTY");
        escrow[msg.sender] = 0;
        msg.sender.sendValue(amount);

        emit LogWithdrawEthOnDisaster(amount, msg.sender);
    }

    function withdrawTokensOnDisaster(address _token)
        external
        whenPaused
        nonReentrant
        notZeroAddress(_token)
    {

        require(disasterState, "Owner did not allow manual withdraw");

        uint256 amount = escrowTokens[_token][msg.sender];
        require(amount > 0, "ESCROW_EMPTY");
        escrowTokens[_token][msg.sender] = 0;

        SafeERC20.safeTransfer(IERC20(_token), msg.sender, amount);
        emit LogWithdrawTokensOnDisaster(amount, _token, msg.sender);
    }

    function withdraw(uint256 _tokenIdVoucher)
        external
        override
        nonReentrant
        whenNotPaused
    {

        bool released = distributeAndWithdraw(_tokenIdVoucher, Entity.ISSUER);
        released = distributeAndWithdraw(_tokenIdVoucher, Entity.HOLDER) || released;
        released = distributeAndWithdraw(_tokenIdVoucher, Entity.POOL) || released;
        require (released, "NOTHING_TO_WITHDRAW");
    }

     function withdrawSingle(uint256 _tokenIdVoucher, Entity _to)
        external
        override
        nonReentrant
        whenNotPaused
    {

        require (distributeAndWithdraw(_tokenIdVoucher, _to),
            "NOTHING_TO_WITHDRAW");

    }

    function distributeAndWithdraw(uint256 _tokenIdVoucher, Entity _to)
        internal
        returns (bool)
    {

        VoucherDetails memory voucherDetails;

        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        voucherDetails.tokenIdVoucher = _tokenIdVoucher;
        voucherDetails.tokenIdSupply = IVoucherKernel(voucherKernel)
            .getIdSupplyFromVoucher(voucherDetails.tokenIdVoucher);
        voucherDetails.paymentMethod = IVoucherKernel(voucherKernel)
            .getVoucherPaymentMethod(voucherDetails.tokenIdSupply);

        (
            voucherDetails.currStatus.status,
            voucherDetails.currStatus.isPaymentReleased,
            voucherDetails.currStatus.isDepositsReleased,
            ,
        ) = IVoucherKernel(voucherKernel).getVoucherStatus(
            voucherDetails.tokenIdVoucher
        );

        (
            voucherDetails.price,
            voucherDetails.depositSe,
            voucherDetails.depositBu
        ) = IVoucherKernel(voucherKernel).getOrderCosts(
            voucherDetails.tokenIdSupply
        );

        voucherDetails.issuer = payable(
            IVoucherKernel(voucherKernel).getVoucherSeller(
                _tokenIdVoucher
            )
        );
        voucherDetails.holder = payable(
            IVoucherKernel(voucherKernel).getVoucherHolder(
                voucherDetails.tokenIdVoucher
            )
        );

        bool paymentReleased;
        if (!voucherDetails.currStatus.isPaymentReleased) {
            paymentReleased = releasePayments(voucherDetails, _to);
        }

        bool depositReleased;
        uint256 releasedAmount;
        if (
            !IVoucherKernel(voucherKernel).isDepositReleased(_tokenIdVoucher, _to) &&
            isStatus(voucherDetails.currStatus.status, VoucherState.FINAL)
        ) {
            (depositReleased, releasedAmount) = releaseDeposits(voucherDetails, _to);
        }

        if (paymentReleased) {
            _withdrawPayments(
                _to == Entity.ISSUER ? voucherDetails.issuer : voucherDetails.holder,
                voucherDetails.price,
                voucherDetails.paymentMethod,
                voucherDetails.tokenIdSupply
            );
        }
                    
        if (depositReleased) {
            _withdrawDeposits(
                _to == Entity.ISSUER ? voucherDetails.issuer : _to == Entity.HOLDER ? voucherDetails.holder : owner(),
                releasedAmount,
                voucherDetails.paymentMethod,
                voucherDetails.tokenIdSupply
            );
        }

        return paymentReleased || depositReleased;
    }

    function releasePayments(VoucherDetails memory _voucherDetails, Entity _to) internal returns (bool){

        if (_to == Entity.ISSUER &&
            isStatus(_voucherDetails.currStatus.status, VoucherState.REDEEM)) {
            releasePayment(_voucherDetails, Role.ISSUER);
            return true;
        } 
        
        if (
            _to == Entity.HOLDER &&
            (isStatus(_voucherDetails.currStatus.status, VoucherState.REFUND) ||
            isStatus(_voucherDetails.currStatus.status, VoucherState.EXPIRE) ||
            (isStatus(_voucherDetails.currStatus.status, VoucherState.CANCEL_FAULT) &&
                !isStatus(_voucherDetails.currStatus.status, VoucherState.REDEEM)))
        ) { 
            releasePayment(_voucherDetails, Role.HOLDER);
            return true;
        }
        return false;
    }

    function releasePayment(VoucherDetails memory _voucherDetails, Role _role) internal {

        if (
            _voucherDetails.paymentMethod == PaymentMethod.ETHETH ||
            _voucherDetails.paymentMethod == PaymentMethod.ETHTKN
        ) {
            escrow[_voucherDetails.holder] = escrow[_voucherDetails.holder].sub(
                _voucherDetails.price
            );
        }

        if (
            _voucherDetails.paymentMethod == PaymentMethod.TKNETH ||
            _voucherDetails.paymentMethod == PaymentMethod.TKNTKN
        ) {
            address addressTokenPrice =
                IVoucherKernel(voucherKernel).getVoucherPriceToken(
                    _voucherDetails.tokenIdSupply
                );

            escrowTokens[addressTokenPrice][
                _voucherDetails.holder
            ] = escrowTokens[addressTokenPrice][_voucherDetails.holder].sub(
                _voucherDetails.price
            );
        }

        IVoucherKernel(voucherKernel).setPaymentReleased(
            _voucherDetails.tokenIdVoucher
        );

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _role == Role.ISSUER ? _voucherDetails.issuer : _voucherDetails.holder,
            _voucherDetails.price,
            PaymentType.PAYMENT
        );
    }

    function releaseDeposits(VoucherDetails memory _voucherDetails, Entity _to) internal returns (bool _released, uint256 _amount){

        if (isStatus(_voucherDetails.currStatus.status, VoucherState.COMPLAIN)) {
            _amount = distributeIssuerDepositOnHolderComplain(_voucherDetails, _to);
            
        } else if(_to != Entity.POOL) {
            if (                
                isStatus(_voucherDetails.currStatus.status, VoucherState.CANCEL_FAULT)) {
                _amount = distributeIssuerDepositOnIssuerCancel(_voucherDetails, _to);
            } else if (_to == Entity.ISSUER) { // happy path, seller gets the whole seller deposit
                _amount = distributeFullIssuerDeposit(_voucherDetails);
            }
            
        }

        if (            
            isStatus(_voucherDetails.currStatus.status, VoucherState.REDEEM) ||
            isStatus(_voucherDetails.currStatus.status, VoucherState.CANCEL_FAULT)
        ) {
            if (_to == Entity.HOLDER) {
            _amount = _amount.add(distributeFullHolderDeposit(_voucherDetails));
            }
        } else if (_to == Entity.POOL){
            _amount = _amount.add(distributeHolderDepositOnNotRedeemedNotCancelled(_voucherDetails));
        }

        _released = _amount > 0;

        if (_released) {
            IVoucherKernel(voucherKernel).setDepositsReleased(
                _voucherDetails.tokenIdVoucher, _to, _amount
            );
        }
    }

    function reduceEscrowAmountDeposits(PaymentMethod _paymentMethod, address _entity, uint256 _amount, uint256 _tokenIdSupply) internal {

            if (
                _paymentMethod == PaymentMethod.ETHETH ||
                _paymentMethod == PaymentMethod.TKNETH
            ) {
                escrow[_entity] = escrow[_entity]
                    .sub(_amount);
            }

            if (
                _paymentMethod == PaymentMethod.ETHTKN ||
                _paymentMethod == PaymentMethod.TKNTKN
            ) {
                address addressTokenDeposits =
                    IVoucherKernel(voucherKernel).getVoucherDepositToken(
                        _tokenIdSupply
                    );

                escrowTokens[addressTokenDeposits][
                    _entity
                ] = escrowTokens[addressTokenDeposits][_entity]
                    .sub(_amount);
            }
    }

    function distributeIssuerDepositOnHolderComplain(
        VoucherDetails memory _voucherDetails,
        Entity _to
    ) internal 
        returns (uint256){

        uint256 toDistribute;
        address recipient;
        if (isStatus(_voucherDetails.currStatus.status, VoucherState.CANCEL_FAULT)) {
            uint256 tFraction = _voucherDetails.depositSe.div(CANCELFAULT_SPLIT);


            if (_to == Entity.HOLDER) { //Bu gets, say, a half                
                toDistribute = tFraction;
                recipient = _voucherDetails.holder;
            } else if (_to == Entity.ISSUER) {  //Se gets, say, a quarter
                toDistribute = tFraction.div(CANCELFAULT_SPLIT);
                recipient = _voucherDetails.issuer;
            } else { //slashing the rest
                toDistribute = (_voucherDetails.depositSe.sub(tFraction)).sub(
                    tFraction.div(CANCELFAULT_SPLIT)
                );
                recipient = owner();
            }

        } else if (_to == Entity.POOL){
            toDistribute = _voucherDetails.depositSe;
            recipient = owner();
        } else {
            return 0;
        }

        reduceEscrowAmountDeposits(_voucherDetails.paymentMethod, _voucherDetails.issuer, toDistribute, _voucherDetails.tokenIdSupply);

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            recipient,
            toDistribute,
            PaymentType.DEPOSIT_SELLER
        );

        return toDistribute;
    }

    function distributeIssuerDepositOnIssuerCancel(
        VoucherDetails memory _voucherDetails,
        Entity _to
    ) internal 
        returns (uint256)
    {

        uint256 toDistribute;
        address recipient;
        if (_to == Entity.HOLDER) { //Bu gets, say, a half                
        toDistribute = _voucherDetails.depositSe.sub(
                _voucherDetails.depositSe.div(CANCELFAULT_SPLIT)
            );
            recipient = _voucherDetails.holder;
        } else {  //Se gets, say, a half
            toDistribute = _voucherDetails.depositSe.div(CANCELFAULT_SPLIT);
            recipient = _voucherDetails.issuer;
        } 

        reduceEscrowAmountDeposits(_voucherDetails.paymentMethod, _voucherDetails.issuer, toDistribute, _voucherDetails.tokenIdSupply);

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            recipient,
            toDistribute,
            PaymentType.DEPOSIT_SELLER
        );

        return toDistribute;   
    }

    function distributeFullIssuerDeposit(VoucherDetails memory _voucherDetails)
        internal returns (uint256)
    {

        reduceEscrowAmountDeposits(_voucherDetails.paymentMethod, _voucherDetails.issuer, _voucherDetails.depositSe, _voucherDetails.tokenIdSupply);
      
        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _voucherDetails.issuer,
            _voucherDetails.depositSe,
            PaymentType.DEPOSIT_SELLER
        );

        return _voucherDetails.depositSe;
    }

    function distributeFullHolderDeposit(VoucherDetails memory _voucherDetails)
        internal
        returns (uint256)
    {

        reduceEscrowAmountDeposits(_voucherDetails.paymentMethod, _voucherDetails.holder, _voucherDetails.depositBu, _voucherDetails.tokenIdSupply);
        
        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            _voucherDetails.holder,
            _voucherDetails.depositBu,
            PaymentType.DEPOSIT_BUYER
        );

        return _voucherDetails.depositBu;
    }

    function distributeHolderDepositOnNotRedeemedNotCancelled(
        VoucherDetails memory _voucherDetails        
    ) internal returns (uint256){

        reduceEscrowAmountDeposits(_voucherDetails.paymentMethod, _voucherDetails.holder, _voucherDetails.depositBu, _voucherDetails.tokenIdSupply);       

        emit LogAmountDistribution(
            _voucherDetails.tokenIdVoucher,
            owner(),
            _voucherDetails.depositBu,
            PaymentType.DEPOSIT_BUYER
        );

        return _voucherDetails.depositBu;
    }

    function withdrawDepositsSe(
        uint256 _tokenIdSupply,
        uint256 _burnedQty,
        address payable _messageSender
    ) external override nonReentrant onlyFromRouter notZeroAddress(_messageSender) {

        require(IVoucherKernel(voucherKernel).getSupplyHolder(_tokenIdSupply) == _messageSender, "UNAUTHORIZED_V");

        uint256 deposit =
            IVoucherKernel(voucherKernel).getSellerDeposit(_tokenIdSupply);

        uint256 depositAmount = deposit.mul(_burnedQty);

        PaymentMethod paymentMethod =
            IVoucherKernel(voucherKernel).getVoucherPaymentMethod(
                _tokenIdSupply
            );

        if (paymentMethod == PaymentMethod.ETHETH || paymentMethod == PaymentMethod.TKNETH) {
            escrow[_messageSender] = escrow[_messageSender].sub(depositAmount);
        }

        if (paymentMethod == PaymentMethod.ETHTKN || paymentMethod == PaymentMethod.TKNTKN) {
            address addressTokenDeposits =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _tokenIdSupply
                );

            escrowTokens[addressTokenDeposits][_messageSender] = escrowTokens[
                addressTokenDeposits
            ][_messageSender]
                .sub(depositAmount);
        }

        _withdrawDeposits(
            _messageSender,
            depositAmount,
            paymentMethod,
            _tokenIdSupply
        );
    }

    function _withdrawPayments(
        address _recipient,
        uint256 _amount,
        PaymentMethod _paymentMethod,
        uint256 _tokenIdSupply
    ) internal
      notZeroAddress(_recipient)
    {

        if (_paymentMethod == PaymentMethod.ETHETH || _paymentMethod == PaymentMethod.ETHTKN) {
            payable(_recipient).sendValue(_amount);
            emit LogWithdrawal(msg.sender, _recipient, _amount);
        }

        if (_paymentMethod == PaymentMethod.TKNETH || _paymentMethod == PaymentMethod.TKNTKN) {
            address addressTokenPrice =
                IVoucherKernel(voucherKernel).getVoucherPriceToken(
                    _tokenIdSupply
                );

            SafeERC20.safeTransfer(
                IERC20(addressTokenPrice),
                _recipient,
                _amount
            );
        }
    }

    function _withdrawDeposits(
        address _recipient,
        uint256 _amount,
        PaymentMethod _paymentMethod,
        uint256 _tokenIdSupply
    ) internal    
      notZeroAddress(_recipient)
    {

        require(_amount > 0, "NO_FUNDS_TO_WITHDRAW");

        if (_paymentMethod == PaymentMethod.ETHETH || _paymentMethod == PaymentMethod.TKNETH) {
            payable(_recipient).sendValue(_amount);
            emit LogWithdrawal(msg.sender, _recipient, _amount);
        }

        if (_paymentMethod == PaymentMethod.ETHTKN || _paymentMethod == PaymentMethod.TKNTKN) {
            address addressTokenDeposits =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _tokenIdSupply
                );

            SafeERC20.safeTransfer(
                IERC20(addressTokenDeposits),
                _recipient,
                _amount
            );
        }
    }

    function setBosonRouterAddress(address _bosonRouterAddress)
        external
        override
        onlyOwner
        whenPaused
        notZeroAddress(_bosonRouterAddress)
    {

        bosonRouterAddress = _bosonRouterAddress;

        emit LogBosonRouterSet(_bosonRouterAddress, msg.sender);
    }

    function setVoucherTokenAddress(address _voucherTokenAddress)
        external
        override
        onlyOwner
        notZeroAddress(_voucherTokenAddress)
        whenPaused
    {

        voucherTokenAddress = _voucherTokenAddress;
        emit LogVoucherTokenContractSet(_voucherTokenAddress, msg.sender);
    }

    function setVoucherSetTokenAddress(address _voucherSetTokenAddress)
        external
        override
        onlyOwner
        notZeroAddress(_voucherSetTokenAddress)
        whenPaused
    {

        voucherSetTokenAddress = _voucherSetTokenAddress;
        emit LogVoucherSetTokenContractSet(_voucherSetTokenAddress, msg.sender);
    }

    function addEscrowAmount(address _account)
        external
        override
        payable
        onlyFromRouter
    {

        escrow[_account] = escrow[_account].add(msg.value);
    }

    function addEscrowTokensAmount(
        address _token,
        address _account,
        uint256 _newAmount
    ) external override onlyFromRouter {

        escrowTokens[_token][_account] =  escrowTokens[_token][_account].add(_newAmount);
    }

    function onVoucherTransfer(
        address _from,
        address _to,
        uint256 _tokenIdVoucher
    ) external override nonReentrant onlyVoucherTokenContract {

        address tokenAddress;

        uint256 tokenSupplyId =
            IVoucherKernel(voucherKernel).getIdSupplyFromVoucher(
                _tokenIdVoucher
            );

        PaymentMethod paymentType =
            IVoucherKernel(voucherKernel).getVoucherPaymentMethod(
                tokenSupplyId
            );

        (uint256 price, uint256 depositBu) =
            IVoucherKernel(voucherKernel).getBuyerOrderCosts(tokenSupplyId);

        if (paymentType == PaymentMethod.ETHETH) {
            uint256 totalAmount = price.add(depositBu);

            escrow[_from] = escrow[_from].sub(totalAmount);
            escrow[_to] = escrow[_to].add(totalAmount);
        }

        if (paymentType == PaymentMethod.ETHTKN) {
            escrow[_from] = escrow[_from].sub(price);
            escrow[_to] = escrow[_to].add(price);

            tokenAddress = IVoucherKernel(voucherKernel).getVoucherDepositToken(
                tokenSupplyId
            );

            escrowTokens[tokenAddress][_from] = escrowTokens[tokenAddress][_from].sub(depositBu);
            escrowTokens[tokenAddress][_to] = escrowTokens[tokenAddress][_to].add(depositBu);

        }

        if (paymentType == PaymentMethod.TKNETH) {
            tokenAddress = IVoucherKernel(voucherKernel).getVoucherPriceToken(
                tokenSupplyId
            );        

            escrowTokens[tokenAddress][_from] = escrowTokens[tokenAddress][_from].sub(price);
            escrowTokens[tokenAddress][_to] = escrowTokens[tokenAddress][_to].add(price);

            escrow[_from] = escrow[_from].sub(depositBu);
            escrow[_to] = escrow[_to].add(depositBu);
        }

        if (paymentType == PaymentMethod.TKNTKN) {
            tokenAddress = IVoucherKernel(voucherKernel).getVoucherPriceToken(
                tokenSupplyId
            );

            escrowTokens[tokenAddress][_from] = escrowTokens[tokenAddress][_from].sub(price);
            escrowTokens[tokenAddress][_to] = escrowTokens[tokenAddress][_to].add(price);

            tokenAddress = IVoucherKernel(voucherKernel).getVoucherDepositToken(
                tokenSupplyId
            );

            escrowTokens[tokenAddress][_from] = escrowTokens[tokenAddress][_from].sub(depositBu);
            escrowTokens[tokenAddress][_to] = escrowTokens[tokenAddress][_to].add(depositBu);

        }
    }

    function onVoucherSetTransfer(
        address _from,
        address _to,
        uint256 _tokenSupplyId,
        uint256 _value
    ) external override nonReentrant onlyVoucherSetTokenContract {

        PaymentMethod paymentType =
            IVoucherKernel(voucherKernel).getVoucherPaymentMethod(
                _tokenSupplyId
            );

        uint256 depositSe;
        uint256 totalAmount;

        if (paymentType == PaymentMethod.ETHETH || paymentType == PaymentMethod.TKNETH) {
            depositSe = IVoucherKernel(voucherKernel).getSellerDeposit(
                _tokenSupplyId
            );
            totalAmount = depositSe.mul(_value);

            escrow[_from] = escrow[_from].sub(totalAmount);
            escrow[_to] = escrow[_to].add(totalAmount);
        }

        if (paymentType == PaymentMethod.ETHTKN || paymentType == PaymentMethod.TKNTKN) {
            address tokenDepositAddress =
                IVoucherKernel(voucherKernel).getVoucherDepositToken(
                    _tokenSupplyId
                );

            depositSe = IVoucherKernel(voucherKernel).getSellerDeposit(
                _tokenSupplyId
            );
            totalAmount = depositSe.mul(_value);

            escrowTokens[tokenDepositAddress][_from] = escrowTokens[tokenDepositAddress][_from].sub(totalAmount);
            escrowTokens[tokenDepositAddress][_to] = escrowTokens[tokenDepositAddress][_to].add(totalAmount);
        }

        IVoucherKernel(voucherKernel).setSupplyHolderOnTransfer(
            _tokenSupplyId,
            _to
        );
    }


    function getVoucherKernelAddress() 
        external 
        view 
        override
        returns (address)
    {

        return voucherKernel;
    }

    function getBosonRouterAddress() 
        external 
        view 
        override
        returns (address)
    {

        return bosonRouterAddress;
    }

    function getVoucherTokenAddress() 
        external 
        view 
        override
        returns (address)
    {

        return voucherTokenAddress;
    }

    function getVoucherSetTokenAddress() 
        external 
        view 
        override
        returns (address)
    {

        return voucherSetTokenAddress;
    }

    function isDisasterStateSet() external view override returns(bool) {

        return disasterState;
    }

    function getEscrowAmount(address _account)
        external
        view
        override
        returns (uint256)
    {

        return escrow[_account];
    }

    function getEscrowTokensAmount(address _token, address _account)
        external
        view
        override
        returns (uint256)
    {

        return escrowTokens[_token][_account];
    }

    function setVoucherKernelAddress(address _voucherKernelAddress)
        external
        override
        onlyOwner
        notZeroAddress(_voucherKernelAddress)
        whenPaused
    {

        voucherKernel = _voucherKernelAddress;

        emit LogVoucherKernelSet(_voucherKernelAddress, msg.sender);
    }
}