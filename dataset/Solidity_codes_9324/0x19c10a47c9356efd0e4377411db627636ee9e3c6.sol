
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

interface IERC721Receiver {

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) external returns (bytes4);

}// MIT

pragma solidity ^0.7.0;

interface IERC165 {

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

}// MIT

pragma solidity ^0.7.0;


interface IERC1155 is IERC165 {

    event TransferSingle(address indexed operator, address indexed from, address indexed to, uint256 id, uint256 value);

    event TransferBatch(address indexed operator, address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event ApprovalForAll(address indexed account, address indexed operator, bool approved);

    event URI(string value, uint256 indexed id);

    function balanceOf(address account, uint256 id) external view returns (uint256);


    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);


    function setApprovalForAll(address operator, bool approved) external;


    function isApprovedForAll(address account, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes calldata data) external;


    function safeBatchTransferFrom(address from, address to, uint256[] calldata ids, uint256[] calldata amounts, bytes calldata data) external;

}// MIT

pragma solidity ^0.7.0;


interface IERC1155MetadataURI is IERC1155 {

    function uri(uint256 id) external view returns (string memory);

}// LGPL-3.0-or-later
pragma solidity 0.7.6;


interface IVoucherSets is IERC1155, IERC1155MetadataURI {

    function pause() external;


    function unpause() external;


    function mint(
        address _to,
        uint256 _tokenId,
        uint256 _value,
        bytes calldata _data
    ) external;


    function burn(
        address _account,
        uint256 _tokenId,
        uint256 _value
    ) external;


    function setVoucherKernelAddress(address _voucherKernelAddress) external;


    function setCashierAddress(address _cashierAddress) external;


    function getVoucherKernelAddress() external view returns (address);


    function getCashierAddress() external view returns (address);

}// MIT

pragma solidity ^0.7.0;


interface IERC721 is IERC165 {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);


    function ownerOf(uint256 tokenId) external view returns (address owner);


    function safeTransferFrom(address from, address to, uint256 tokenId) external;


    function transferFrom(address from, address to, uint256 tokenId) external;


    function approve(address to, uint256 tokenId) external;


    function getApproved(uint256 tokenId) external view returns (address operator);


    function setApprovalForAll(address operator, bool _approved) external;


    function isApprovedForAll(address owner, address operator) external view returns (bool);


    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

}// MIT

pragma solidity ^0.7.0;


interface IERC721Metadata is IERC721 {


    function name() external view returns (string memory);


    function symbol() external view returns (string memory);


    function tokenURI(uint256 tokenId) external view returns (string memory);

}// LGPL-3.0-or-later
pragma solidity 0.7.6;


interface IVouchers is IERC721, IERC721Metadata {

    function pause() external;


    function unpause() external;


    function mint(address _to, uint256 _tokenId) external returns (bool);


    function setVoucherKernelAddress(address _voucherKernelAddress) external;


    function setCashierAddress(address _cashierAddress) external;


    function getVoucherKernelAddress() external view returns (address);


    function getCashierAddress() external view returns (address);

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


contract VoucherKernel is IVoucherKernel, Ownable, Pausable, ReentrancyGuard {

    using Address for address;
    using SafeMath for uint256;

    uint256 internal constant WEEK = 7 * 1 days;

    address private voucherSetTokenAddress;

    address private voucherTokenAddress;

    struct Promise {
        bytes32 promiseId;
        uint256 nonce; //the asset that is offered
        address seller; //the seller who created the promise
        uint256 validFrom;
        uint256 validTo;
        uint256 price;
        uint256 depositSe;
        uint256 depositBu;
        uint256 idx;
    }

    struct VoucherPaymentMethod {
        PaymentMethod paymentMethod;
        address addressTokenPrice;
        address addressTokenDeposits;
    }

    address private bosonRouterAddress; //address of the Boson Router contract
    address private cashierAddress; //address of the Cashier contract

    mapping(bytes32 => Promise) private promises; //promises to deliver goods or services
    mapping(address => uint256) private tokenNonces; //mapping between seller address and its own nonces. Every time seller creates supply ID it gets incremented. Used to avoid duplicate ID's
    mapping(uint256 => VoucherPaymentMethod) private paymentDetails; // tokenSupplyId to VoucherPaymentMethod

    bytes32[] private promiseKeys;

    mapping(uint256 => bytes32) private ordersPromise; //mapping between an order (supply a.k.a. VoucherSet) and a promise

    mapping(uint256 => VoucherStatus) private vouchersStatus; //recording the vouchers evolution

    mapping(uint256 => uint256) private typeCounters; //counter for ID of a particular type of NFT
    uint256 private constant MASK_TYPE = uint256(type(uint128).max) << 128; //the type mask in the upper 128 bits

    uint256 private constant MASK_NF_INDEX = type(uint128).max; //the non-fungible index mask in the lower 128

    uint256 private constant TYPE_NF_BIT = 1 << 255; //the first bit represents an NFT type

    uint256 private typeId; //base token type ... 127-bits cover 1.701411835*10^38 types (not differentiating between FTs and NFTs)

    uint256 private complainPeriod;
    uint256 private cancelFaultPeriod;

    event LogPromiseCreated(
        bytes32 indexed _promiseId,
        uint256 indexed _nonce,
        address indexed _seller,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _idx
    );

    event LogVoucherCommitted(
        uint256 indexed _tokenIdSupply,
        uint256 _tokenIdVoucher,
        address _issuer,
        address _holder,
        bytes32 _promiseId
    );

    event LogVoucherRedeemed(
        uint256 _tokenIdVoucher,
        address _holder,
        bytes32 _promiseId
    );

    event LogVoucherRefunded(uint256 _tokenIdVoucher);

    event LogVoucherComplain(uint256 _tokenIdVoucher);

    event LogVoucherFaultCancel(uint256 _tokenIdVoucher);

    event LogExpirationTriggered(uint256 _tokenIdVoucher, address _triggeredBy);

    event LogFinalizeVoucher(uint256 _tokenIdVoucher, address _triggeredBy);

    event LogBosonRouterSet(address _newBosonRouter, address _triggeredBy);

    event LogCashierSet(address _newCashier, address _triggeredBy);

    event LogVoucherTokenContractSet(address _newTokenContract, address _triggeredBy);

    event LogVoucherSetTokenContractSet(address _newTokenContract, address _triggeredBy);

    event LogComplainPeriodChanged(
        uint256 _newComplainPeriod,
        address _triggeredBy
    );

    event LogCancelFaultPeriodChanged(
        uint256 _newCancelFaultPeriod,
        address _triggeredBy
    );

    event LogVoucherSetFaultCancel(uint256 _tokenIdSupply, address _issuer);

    event LogFundsReleased(
        uint256 _tokenIdVoucher,
        uint8 _type //0 .. payment, 1 .. deposits
    );

    modifier onlyFromRouter() {

        require(msg.sender == bosonRouterAddress, "UNAUTHORIZED_BR");
        _;
    }

    modifier onlyFromCashier() {

        require(msg.sender == cashierAddress, "UNAUTHORIZED_C");
        _;
    }

    modifier onlyVoucherOwner(uint256 _tokenIdVoucher, address _sender) {

        require(
            IVouchers(voucherTokenAddress).ownerOf(_tokenIdVoucher) == _sender,
            "UNAUTHORIZED_V"
        );
        _;
    }

    modifier notZeroAddress(address _addressToCheck) {

        require(_addressToCheck != address(0), "0A");
        _;
    }

    constructor(address _bosonRouterAddress, address _cashierAddress, address _voucherSetTokenAddress, address _voucherTokenAddress)
    notZeroAddress(_bosonRouterAddress)
    notZeroAddress(_cashierAddress)
    notZeroAddress(_voucherSetTokenAddress)
    notZeroAddress(_voucherTokenAddress)
    {
        bosonRouterAddress = _bosonRouterAddress;
        cashierAddress = _cashierAddress;
        voucherSetTokenAddress = _voucherSetTokenAddress;
        voucherTokenAddress = _voucherTokenAddress;

        emit LogBosonRouterSet(_bosonRouterAddress, msg.sender);
        emit LogCashierSet(_cashierAddress, msg.sender);
        emit LogVoucherSetTokenContractSet(_voucherSetTokenAddress, msg.sender);
        emit LogVoucherTokenContractSet(_voucherTokenAddress, msg.sender);

        setComplainPeriod(WEEK);
        setCancelFaultPeriod(WEEK);
    }

    function pause() external override onlyFromRouter {

        _pause();
    }

    function unpause() external override onlyFromRouter {

        _unpause();
    }

    function createTokenSupplyId(
        address _seller,
        uint256 _validFrom,
        uint256 _validTo,
        uint256 _price,
        uint256 _depositSe,
        uint256 _depositBu,
        uint256 _quantity
    )
    external
    override
    nonReentrant
    onlyFromRouter
    returns (uint256) {

        require(_quantity > 0, "INVALID_QUANTITY");
        require(_validTo >= block.timestamp + 5 minutes, "INVALID_VALIDITY_TO");
        require(_validTo >= _validFrom.add(5 minutes), "VALID_FROM_MUST_BE_AT_LEAST_5_MINUTES_LESS_THAN_VALID_TO");

        bytes32 key;
        key = keccak256(
            abi.encodePacked(_seller, tokenNonces[_seller]++, _validFrom, _validTo, address(this))
        );

        if (promiseKeys.length > 0) {
            require(
                promiseKeys[promises[key].idx] != key,
                "PROMISE_ALREADY_EXISTS"
            );
        }

        promises[key] = Promise({
            promiseId: key,
            nonce: tokenNonces[_seller],
            seller: _seller,
            validFrom: _validFrom,
            validTo: _validTo,
            price: _price,
            depositSe: _depositSe,
            depositBu: _depositBu,
            idx: promiseKeys.length
        });

        promiseKeys.push(key);

        emit LogPromiseCreated(
            key,
            tokenNonces[_seller],
            _seller,
            _validFrom,
            _validTo,
            promiseKeys.length - 1
        );

        return createOrder(_seller, key, _quantity);
    }

    function createPaymentMethod(
        uint256 _tokenIdSupply,
        PaymentMethod _paymentMethod,
        address _tokenPrice,
        address _tokenDeposits
    ) external override onlyFromRouter {       

        paymentDetails[_tokenIdSupply] = VoucherPaymentMethod({
            paymentMethod: _paymentMethod,
            addressTokenPrice: _tokenPrice,
            addressTokenDeposits: _tokenDeposits
        });
    }

    function createOrder(
        address _seller,
        bytes32 _promiseId,
        uint256 _quantity
    ) private returns (uint256) {

        typeId++;
        uint256 tokenIdSupply = TYPE_NF_BIT | (typeId << 128); //upper bit is 1, followed by sequence, leaving lower 128-bits as 0;

        ordersPromise[tokenIdSupply] = _promiseId;

        IVoucherSets(voucherSetTokenAddress).mint(
            _seller,
            tokenIdSupply,
            _quantity,
            ""
        );

        return tokenIdSupply;
    }

    function fillOrder(
        uint256 _tokenIdSupply,
        address _issuer,
        address _holder,
        PaymentMethod _paymentMethod
    )
    external
    override
    onlyFromRouter
    nonReentrant
    {

        require(_doERC721HolderCheck(_issuer, _holder, _tokenIdSupply), "UNSUPPORTED_ERC721_RECEIVED");
        PaymentMethod paymentMethod = getVoucherPaymentMethod(_tokenIdSupply);

        require(paymentMethod == _paymentMethod, "Incorrect Payment Method");
        checkOrderFillable(_tokenIdSupply, _issuer, _holder);

        uint256 voucherTokenId = extract721(_issuer, _holder, _tokenIdSupply);

        emit LogVoucherCommitted(
            _tokenIdSupply,
            voucherTokenId,
            _issuer,
            _holder,
            getPromiseIdFromVoucherId(voucherTokenId)
        );
    }

    function _doERC721HolderCheck(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal returns (bool) {

        if (_to.isContract()) {
            try IERC721Receiver(_to).onERC721Received(_msgSender(), _from, _tokenId, "") returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("UNSUPPORTED_ERC721_RECEIVED");
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }

    function checkOrderFillable(
        uint256 _tokenIdSupply,
        address _issuer,
        address _holder
    ) internal view notZeroAddress(_holder) {

        require(_tokenIdSupply != 0, "UNSPECIFIED_ID");

        require(
            IVoucherSets(voucherSetTokenAddress).balanceOf(_issuer, _tokenIdSupply) > 0,
            "OFFER_EMPTY"
        );

        bytes32 promiseKey = ordersPromise[_tokenIdSupply];

        require(
            promises[promiseKey].validTo >= block.timestamp,
            "OFFER_EXPIRED"
        );
    }

    function extract721(
        address _issuer,
        address _to,
        uint256 _tokenIdSupply
    ) internal returns (uint256) {

        IVoucherSets(voucherSetTokenAddress).burn(_issuer, _tokenIdSupply, 1); // This is hardcoded as 1 on purpose

        uint256 voucherTokenId =
            _tokenIdSupply | ++typeCounters[_tokenIdSupply];

        vouchersStatus[voucherTokenId].status = determineStatus(
            vouchersStatus[voucherTokenId].status,
            VoucherState.COMMIT
        );
        vouchersStatus[voucherTokenId].isPaymentReleased = false;
        vouchersStatus[voucherTokenId].isDepositsReleased = false;
        vouchersStatus[voucherTokenId].seller = getSupplyHolder(_tokenIdSupply);

        IVouchers(voucherTokenAddress).mint(_to, voucherTokenId);

        return voucherTokenId;
    }


    function redeem(uint256 _tokenIdVoucher, address _messageSender)
        external
        override
        whenNotPaused
        onlyFromRouter
        onlyVoucherOwner(_tokenIdVoucher, _messageSender)
    {

        require(
            isStateCommitted(vouchersStatus[_tokenIdVoucher].status),
            "ALREADY_PROCESSED"
        );

        isInValidityPeriod(_tokenIdVoucher);
        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];

        vouchersStatus[_tokenIdVoucher].complainPeriodStart = block.timestamp;
        vouchersStatus[_tokenIdVoucher].status = determineStatus(
            vouchersStatus[_tokenIdVoucher].status,
            VoucherState.REDEEM
        );

        emit LogVoucherRedeemed(
            _tokenIdVoucher,
            _messageSender,
            tPromise.promiseId
        );
    }


    function refund(uint256 _tokenIdVoucher, address _messageSender)
        external
        override
        whenNotPaused
        onlyFromRouter
        onlyVoucherOwner(_tokenIdVoucher, _messageSender)
    {

        require(
            isStateCommitted(vouchersStatus[_tokenIdVoucher].status),
            "INAPPLICABLE_STATUS"
        );

        isInValidityPeriod(_tokenIdVoucher);

        vouchersStatus[_tokenIdVoucher].complainPeriodStart = block.timestamp;
        vouchersStatus[_tokenIdVoucher].status = determineStatus(
            vouchersStatus[_tokenIdVoucher].status,
            VoucherState.REFUND
        );

        emit LogVoucherRefunded(_tokenIdVoucher);
    }

    function complain(uint256 _tokenIdVoucher, address _messageSender)
        external
        override
        whenNotPaused
        onlyFromRouter
        onlyVoucherOwner(_tokenIdVoucher, _messageSender)
    {

        checkIfApplicableAndResetPeriod(_tokenIdVoucher, VoucherState.COMPLAIN);
    }   

    function cancelOrFault(uint256 _tokenIdVoucher, address _messageSender)
        external
        override
        onlyFromRouter
        whenNotPaused
    {

        require(
            vouchersStatus[_tokenIdVoucher].seller ==_messageSender,
            "UNAUTHORIZED_COF"
        );

        checkIfApplicableAndResetPeriod(_tokenIdVoucher, VoucherState.CANCEL_FAULT);
    }

    function checkIfApplicableAndResetPeriod(uint256 _tokenIdVoucher, VoucherState _newStatus)
        internal
    {

        uint8 tStatus = vouchersStatus[_tokenIdVoucher].status;

        require(
            !isStatus(tStatus, VoucherState.FINAL),
            "ALREADY_FINALIZED"
        );

        string memory revertReasonAlready; 
        string memory revertReasonExpired;

        if (_newStatus == VoucherState.COMPLAIN) {
            revertReasonAlready = "ALREADY_COMPLAINED";
            revertReasonExpired = "COMPLAINPERIOD_EXPIRED";
        } else {
            revertReasonAlready = "ALREADY_CANCELFAULT";
            revertReasonExpired = "COFPERIOD_EXPIRED";
        }

        require(
            !isStatus(tStatus, _newStatus),
            revertReasonAlready
        );

        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];
      
        if (
            isStateRedemptionSigned(tStatus) ||
            isStateRefunded(tStatus)
        ) {
            
            require(
                block.timestamp <=
                    vouchersStatus[_tokenIdVoucher].complainPeriodStart +
                        complainPeriod +
                        cancelFaultPeriod,
                revertReasonExpired
            );          
        } else if (isStateExpired(tStatus)) {
            require(
                block.timestamp <=
                    tPromise.validTo + complainPeriod + cancelFaultPeriod,
                revertReasonExpired
            );            
        } else if (
            isStatus(vouchersStatus[_tokenIdVoucher].status, VoucherState((uint8(_newStatus) % 2 + 1))) // making it VoucherState.COMPLAIN or VoucherState.CANCEL_FAULT (opposite to new status) 
        ) {
            uint256 waitPeriod = _newStatus == VoucherState.COMPLAIN ? vouchersStatus[_tokenIdVoucher].complainPeriodStart +
                        complainPeriod : vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart + cancelFaultPeriod;
            require(
                block.timestamp <= waitPeriod,
                revertReasonExpired
            );
        } else if (_newStatus != VoucherState.COMPLAIN && isStateCommitted(tStatus)) {
            require(
                block.timestamp <=
                    tPromise.validTo + complainPeriod + cancelFaultPeriod,
                "COFPERIOD_EXPIRED"
            );
 
        } else {
            revert("INAPPLICABLE_STATUS");
            }
        
            vouchersStatus[_tokenIdVoucher].status = determineStatus(
                tStatus,
                _newStatus
            );

        if (_newStatus == VoucherState.COMPLAIN) {
            if (!isStatus(tStatus, VoucherState.CANCEL_FAULT)) {
            vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart = block
                .timestamp;  //COF period starts
            }
            emit LogVoucherComplain(_tokenIdVoucher);
        } else {
            if (!isStatus(tStatus, VoucherState.COMPLAIN)) {
            vouchersStatus[_tokenIdVoucher].complainPeriodStart = block
            .timestamp; //complain period starts
            }
            emit LogVoucherFaultCancel(_tokenIdVoucher);
        }
    }

    function cancelOrFaultVoucherSet(uint256 _tokenIdSupply, address _issuer)
    external
    override
    onlyFromRouter
    nonReentrant
    whenNotPaused
    returns (uint256)
    {

        require(getSupplyHolder(_tokenIdSupply) == _issuer, "UNAUTHORIZED_COF");

        uint256 remQty = getRemQtyForSupply(_tokenIdSupply, _issuer);

        require(remQty > 0, "OFFER_EMPTY");

        IVoucherSets(voucherSetTokenAddress).burn(_issuer, _tokenIdSupply, remQty);

        emit LogVoucherSetFaultCancel(_tokenIdSupply, _issuer);

        return remQty;
    }


    function setPaymentReleased(uint256 _tokenIdVoucher)
        external
        override
        onlyFromCashier
    {

        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");
        vouchersStatus[_tokenIdVoucher].isPaymentReleased = true;

        emit LogFundsReleased(_tokenIdVoucher, 0);
    }

    function setDepositsReleased(uint256 _tokenIdVoucher, Entity _to, uint256 _amount)
        external
        override
        onlyFromCashier
    {

        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        vouchersStatus[_tokenIdVoucher].depositReleased.status |= (ONE << uint8(_to));

        vouchersStatus[_tokenIdVoucher].depositReleased.releasedAmount = uint248(uint256(vouchersStatus[_tokenIdVoucher].depositReleased.releasedAmount).add(_amount));

        if (vouchersStatus[_tokenIdVoucher].depositReleased.releasedAmount == getTotalDepositsForVoucher(_tokenIdVoucher)) {
            vouchersStatus[_tokenIdVoucher].isDepositsReleased = true;
            emit LogFundsReleased(_tokenIdVoucher, 1); 
        }        
    }

    function isDepositReleased(uint256 _tokenIdVoucher, Entity _to) external view override returns (bool){

        return (vouchersStatus[_tokenIdVoucher].depositReleased.status >> uint8(_to)) & ONE == 1;
    }

    function triggerExpiration(uint256 _tokenIdVoucher) external override {

        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];

        require(tPromise.validTo < block.timestamp && isStateCommitted(vouchersStatus[_tokenIdVoucher].status),'INAPPLICABLE_STATUS');

        vouchersStatus[_tokenIdVoucher].status = determineStatus(
            vouchersStatus[_tokenIdVoucher].status,
            VoucherState.EXPIRE
        );

        emit LogExpirationTriggered(_tokenIdVoucher, msg.sender);
    }

    function triggerFinalizeVoucher(uint256 _tokenIdVoucher) external override {

        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        uint8 tStatus = vouchersStatus[_tokenIdVoucher].status;

        require(!isStatus(tStatus, VoucherState.FINAL), "ALREADY_FINALIZED");

        bool mark;
        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];

        if (isStatus(tStatus, VoucherState.COMPLAIN)) {
            if (isStatus(tStatus, VoucherState.CANCEL_FAULT)) {
                mark = true;
            } else if (
                block.timestamp >=
                vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart +
                    cancelFaultPeriod
            ) {
                mark = true;
            }
        } else if (
            isStatus(tStatus, VoucherState.CANCEL_FAULT) &&
            block.timestamp >=
            vouchersStatus[_tokenIdVoucher].complainPeriodStart + complainPeriod
        ) {
            mark = true;
        } else if (
            isStateRedemptionSigned(tStatus) || isStateRefunded(tStatus)
        ) {
            if (
                block.timestamp >=
                vouchersStatus[_tokenIdVoucher].complainPeriodStart +
                    complainPeriod
            ) {
                mark = true;
            }
        } else if (isStateExpired(tStatus)) {
            if (block.timestamp >= tPromise.validTo + complainPeriod) {
                mark = true;
            }
        }

        require(mark, 'INAPPLICABLE_STATUS');

        vouchersStatus[_tokenIdVoucher].status = determineStatus(
            tStatus,
            VoucherState.FINAL
        );
        emit LogFinalizeVoucher(_tokenIdVoucher, msg.sender);
    }



    function setSupplyHolderOnTransfer(
        uint256 _tokenIdSupply,
        address _newSeller
    ) external override onlyFromCashier {

        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        promises[promiseKey].seller = _newSeller;
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

    function setCashierAddress(address _cashierAddress)
        external
        override
        onlyOwner
        whenPaused
        notZeroAddress(_cashierAddress)
    {

        cashierAddress = _cashierAddress;

        emit LogCashierSet(_cashierAddress, msg.sender);
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

    function setComplainPeriod(uint256 _complainPeriod)
        public
        override
        onlyOwner
    {

        complainPeriod = _complainPeriod;

        emit LogComplainPeriodChanged(_complainPeriod, msg.sender);
    }

    function setCancelFaultPeriod(uint256 _cancelFaultPeriod)
        public
        override
        onlyOwner
    {

        cancelFaultPeriod = _cancelFaultPeriod;

        emit LogCancelFaultPeriodChanged(_cancelFaultPeriod, msg.sender);
    }


    function getPromiseKey(uint256 _idx)
        external
        view
        override
        returns (bytes32)
    {

        return promiseKeys[_idx];
    }

    function getIdSupplyFromVoucher(uint256 _tokenIdVoucher)
        public
        pure
        override
        returns (uint256)
    {

        uint256 tokenIdSupply = _tokenIdVoucher & MASK_TYPE;
        require(tokenIdSupply !=0, "INEXISTENT_SUPPLY");
        return tokenIdSupply;
    }

    function getPromiseIdFromVoucherId(uint256 _tokenIdVoucher)
        public
        view
        override
        returns (bytes32)
    {

        require(_tokenIdVoucher != 0, "UNSPECIFIED_ID");

        uint256 tokenIdSupply = getIdSupplyFromVoucher(_tokenIdVoucher);
        return promises[ordersPromise[tokenIdSupply]].promiseId;
    }

    function getRemQtyForSupply(uint256 _tokenSupplyId, address _tokenSupplyOwner)
        public
        view
        override
        returns (uint256)
    {

        return IVoucherSets(voucherSetTokenAddress).balanceOf(_tokenSupplyOwner, _tokenSupplyId);
    }

    function getOrderCosts(uint256 _tokenIdSupply)
        external
        view
        override
        returns (
            uint256,
            uint256,
            uint256
        )
    {

        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        return (
            promises[promiseKey].price,
            promises[promiseKey].depositSe,
            promises[promiseKey].depositBu
        );
    }

    function getTotalDepositsForVoucher(uint256 _tokenIdVoucher)
        internal
        view
        returns (
            uint256
        )
    {

        bytes32 promiseKey = getPromiseIdFromVoucherId(_tokenIdVoucher);
        
        return promises[promiseKey].depositSe.add(promises[promiseKey].depositBu);
    }

    function getBuyerOrderCosts(uint256 _tokenIdSupply)
        external
        view
        override
        returns (uint256, uint256)
    {

        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        return (promises[promiseKey].price, promises[promiseKey].depositBu);
    }

    function getSellerDeposit(uint256 _tokenIdSupply)
        external
        view
        override
        returns (uint256)
    {

        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        return promises[promiseKey].depositSe;
    }

    function getSupplyHolder(uint256 _tokenIdSupply)
        public
        view
        override
        returns (address)
    {

        bytes32 promiseKey = ordersPromise[_tokenIdSupply];
        return promises[promiseKey].seller;
    }


    function getVoucherSeller(uint256 _voucherTokenId) external view override returns (address) {

        return vouchersStatus[_voucherTokenId].seller;
    }

    function getPromiseData(bytes32 _promiseKey)
        external
        view
        override
        returns (bytes32, uint256, uint256, uint256, uint256 )
    {

        Promise memory tPromise = promises[_promiseKey];
        return (tPromise.promiseId, tPromise.nonce, tPromise.validFrom, tPromise.validTo, tPromise.idx); 
    }

    function getVoucherStatus(uint256 _tokenIdVoucher)
        external
        view
        override
        returns (
            uint8,
            bool,
            bool,
            uint256,
            uint256
        )
    {

        return (
            vouchersStatus[_tokenIdVoucher].status,
            vouchersStatus[_tokenIdVoucher].isPaymentReleased,
            vouchersStatus[_tokenIdVoucher].isDepositsReleased,
            vouchersStatus[_tokenIdVoucher].complainPeriodStart,
            vouchersStatus[_tokenIdVoucher].cancelFaultPeriodStart
        );
    }

    function getVoucherHolder(uint256 _tokenIdVoucher)
        external
        view
        override
        returns (address)
    {

        return IVouchers(voucherTokenAddress).ownerOf(_tokenIdVoucher);
    }

    function getVoucherPriceToken(uint256 _tokenIdSupply)
        external
        view
        override
        returns (address)
    {

        return paymentDetails[_tokenIdSupply].addressTokenPrice;
    }

    function getVoucherDepositToken(uint256 _tokenIdSupply)
        external
        view
        override
        returns (address)
    {

        return paymentDetails[_tokenIdSupply].addressTokenDeposits;
    }

    function getVoucherPaymentMethod(uint256 _tokenIdSupply)
        public
        view
        override
        returns (PaymentMethod)
    {

        return paymentDetails[_tokenIdSupply].paymentMethod;
    }

    function isInValidityPeriod(uint256 _tokenIdVoucher)
        public
        view
        override
        returns (bool)
    {

        Promise memory tPromise =
            promises[getPromiseIdFromVoucherId(_tokenIdVoucher)];
        require(tPromise.validFrom <= block.timestamp, "INVALID_VALIDITY_FROM");
        require(tPromise.validTo >= block.timestamp, "INVALID_VALIDITY_TO");

        return true;
    }

    function isVoucherTransferable(uint256 _tokenIdVoucher)
        external
        view
        override
        returns (bool)
    {

        return
            !(vouchersStatus[_tokenIdVoucher].isPaymentReleased ||
                vouchersStatus[_tokenIdVoucher].isDepositsReleased);
    }

    function getBosonRouterAddress()
        external
        view
        override
        returns (address) 
    {

        return bosonRouterAddress;
    }

    function getCashierAddress()
        external
        view
        override
        returns (address)
    {

        return cashierAddress;
    }

    function getTokenNonce(address _seller)
        external
        view
        override
        returns (uint256) 
    {

        return tokenNonces[_seller];
    }

    function getTypeId()
        external
        view
        override
        returns (uint256)
    {

        return typeId;
    }

    function getComplainPeriod()
        external
        view
        override
        returns (uint256)
    {

        return complainPeriod;
    }

    function getCancelFaultPeriod()
        external
        view
        override
        returns (uint256)
    {

        return cancelFaultPeriod;
    }
    
    function getPromiseIdFromSupplyId(uint256 _tokenIdSupply)
        external
        view
        override
        returns (bytes32) 
    {

        return ordersPromise[_tokenIdSupply];
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
}